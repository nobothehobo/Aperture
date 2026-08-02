"""Temporary cloud-build bootstrap for Aegis-7 texture generation."""
import os
import subprocess
import sys

if os.environ.get("AEGIS_PIL_BOOTSTRAP") != "1":
    try:
        import PIL  # noqa: F401
    except ModuleNotFoundError:
        env = os.environ.copy()
        env["AEGIS_PIL_BOOTSTRAP"] = "1"
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--quiet", "pillow"],
            env=env,
        )
