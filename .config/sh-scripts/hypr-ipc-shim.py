#!/usr/bin/env python3
"""Legacy -> Lua dispatch translator sitting between Waybar and Hyprland.

Waybar (through 0.15.0) still writes old-style dispatcher strings to Hyprland's
request socket, e.g. "dispatch workspace 2". A Hyprland started from a
hyprland.lua config evaluates the payload of `dispatch` as Lua, so those
requests die with a syntax error and clicking a workspace does nothing.
See Waybar issues #5008 and #5035.

This proxy publishes a fake instance directory next to the real one, holding a
passthrough symlink for the event socket and a rewriting proxy for the request
socket. Only Waybar is pointed at it, via HYPRLAND_INSTANCE_SIGNATURE; every
other client keeps talking to Hyprland directly.

Requests that are not one of the known legacy workspace dispatchers are relayed
byte for byte, so a Waybar that learns Lua syntax upstream keeps working and
this shim quietly becomes a passthrough.
"""

import hashlib
import os
import re
import socket
import sys
import threading

# Unix socket paths are capped at 108 bytes including the terminator, and a
# Hyprland signature already eats ~60 of them, so the shim directory is named
# after a short digest rather than by decorating the signature.
SUN_PATH_MAX = 107
SHIM_DIR_PREFIX = "wbshim-"
# Written so waybar-launch.sh can discover the signature it must hand to Waybar.
STATE_FILE = "hypr-waybar-shim.his"
DEBUG = os.environ.get("HYPR_SHIM_DEBUG") == "1"

# "dispatch workspace 2" / "dispatch workspace name:web"
RE_WORKSPACE = re.compile(
    r"\Adispatch\s+(?:workspace|focusworkspaceoncurrentmonitor)\s+(\S.*)\Z", re.S
)
# "dispatch togglespecialworkspace" / "dispatch togglespecialworkspace magic"
RE_SPECIAL = re.compile(r"\Adispatch\s+togglespecialworkspace(?:\s+(\S.*))?\Z", re.S)


def log(msg):
    if DEBUG:
        print(f"[hypr-ipc-shim] {msg}", file=sys.stderr, flush=True)


def lua_str(value):
    """Quote an arbitrary workspace selector for embedding in Lua source."""
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def rewrite(request):
    """Translate a legacy workspace dispatch into its Lua equivalent.

    Returns the request unchanged when it is not one we know how to translate.
    """
    stripped = request.strip()

    m = RE_WORKSPACE.match(stripped)
    if m:
        # The Lua workspace field takes the same selector strings the legacy
        # dispatcher did ("2", "name:web", "e+1"), so pass the argument through.
        return f"dispatch hl.dsp.focus({{workspace={lua_str(m.group(1).strip())}}})"

    m = RE_SPECIAL.match(stripped)
    if m:
        name = (m.group(1) or "").strip()
        # Waybar may hand us either "magic" or the fully qualified
        # "special:magic"; toggle_special wants the bare name.
        if name.startswith("special:"):
            name = name[len("special:"):]
        if not name:
            return "dispatch hl.dsp.workspace.toggle_special()"
        return f"dispatch hl.dsp.workspace.toggle_special({lua_str(name)})"

    return request


def read_request(conn):
    """Read one request. Waybar writes a single command and then waits."""
    conn.settimeout(0.25)
    chunks = []
    try:
        while True:
            data = conn.recv(65536)
            if not data:
                break
            chunks.append(data)
            if len(data) < 65536:
                break
    except socket.timeout:
        pass
    return b"".join(chunks)


def relay(request, real_socket_path):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as up:
        up.settimeout(5)
        up.connect(real_socket_path)
        up.sendall(request)
        try:
            up.shutdown(socket.SHUT_WR)
        except OSError:
            pass
        reply = b""
        while True:
            try:
                data = up.recv(65536)
            except socket.timeout:
                break
            if not data:
                break
            reply += data
        return reply


def handle(conn, real_socket_path):
    with conn:
        try:
            request = read_request(conn)
            if not request:
                return
            text = request.decode("utf-8", "replace")
            translated = rewrite(text)
            if translated != text:
                log(f"{text!r} -> {translated!r}")
            payload = translated.encode("utf-8")
            conn.settimeout(5)
            conn.sendall(relay(payload, real_socket_path))
        except OSError as exc:
            log(f"connection failed: {exc}")


def shim_signature(his):
    digest = hashlib.sha256(his.encode()).hexdigest()[:8]
    return SHIM_DIR_PREFIX + digest


def main():
    # Prefer the real signature the launcher passes down, so re-running this
    # from Waybar's own environment cannot stack a shim on top of a shim.
    his = os.environ.get("HYPR_SHIM_REAL_HIS") or os.environ.get(
        "HYPRLAND_INSTANCE_SIGNATURE"
    )
    if not his:
        sys.exit("HYPRLAND_INSTANCE_SIGNATURE is not set; is Hyprland running?")
    if his.startswith(SHIM_DIR_PREFIX):
        sys.exit("refusing to shim a shim; pass the real Hyprland signature")

    runtime = os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"
    real_dir = os.path.join(runtime, "hypr", his)
    real_socket = os.path.join(real_dir, ".socket.sock")
    if not os.path.exists(real_socket):
        sys.exit(f"Hyprland request socket not found at {real_socket}")

    signature = shim_signature(his)
    shim_dir = os.path.join(runtime, "hypr", signature)
    for name in (".socket.sock", ".socket2.sock"):
        candidate = os.path.join(shim_dir, name)
        if len(candidate.encode()) > SUN_PATH_MAX:
            sys.exit(f"shim path too long for a unix socket: {candidate}")
    os.makedirs(shim_dir, exist_ok=True)

    # Events are read-only and need no translation, so hand Waybar the real one.
    events = os.path.join(shim_dir, ".socket2.sock")
    if os.path.islink(events) or os.path.exists(events):
        os.unlink(events)
    os.symlink(os.path.join(real_dir, ".socket2.sock"), events)

    listen_path = os.path.join(shim_dir, ".socket.sock")
    if os.path.exists(listen_path):
        os.unlink(listen_path)

    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(listen_path)
    os.chmod(listen_path, 0o600)
    server.listen(16)

    state_path = os.path.join(runtime, STATE_FILE)
    with open(state_path, "w") as state_file:
        state_file.write(signature + "\n")
    print(signature, flush=True)
    log(f"listening on {listen_path}, upstream {real_socket}")

    try:
        while True:
            conn, _ = server.accept()
            threading.Thread(
                target=handle, args=(conn, real_socket), daemon=True
            ).start()
    except KeyboardInterrupt:
        pass
    finally:
        server.close()
        for path in (listen_path, events, os.path.join(runtime, STATE_FILE)):
            try:
                os.unlink(path)
            except OSError:
                pass


if __name__ == "__main__":
    main()
