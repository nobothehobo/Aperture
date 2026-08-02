#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path

source = Path('v050-final-build.sh').read_text()
needle = "python3 v050-generate-textures.py\n"
insert = needle + (
    "cp v050-PlayerEntityRendererMixin.java "
    "Aegis7_Transforming_Robot_Mod/src/client/java/com/noah/aegis7/mixin/client/PlayerEntityRendererMixin.java\n"
    "grep -q 'renderer.getModel().setVisible' "
    "Aegis7_Transforming_Robot_Mod/src/client/java/com/noah/aegis7/mixin/client/PlayerEntityRendererMixin.java\n"
    "if grep -Eq '^[[:space:]]*@Shadow|import org\\.spongepowered\\.asm\\.mixin\\.Shadow' "
    "Aegis7_Transforming_Robot_Mod/src/client/java/com/noah/aegis7/mixin/client/PlayerEntityRendererMixin.java; then exit 1; fi\n"
)
if needle not in source:
    raise SystemExit('Could not locate Aegis texture-generation insertion point')
if 'cp v050-PlayerEntityRendererMixin.java' not in source:
    source = source.replace(needle, insert, 1)
source = source.replace('timeout 180s xvfb-run', 'timeout 55s xvfb-run')
source = source.replace('timeout 120s gradle runServer', 'timeout 45s gradle runServer')
Path('/tmp/v050-final-build-fixed.sh').write_text(source)
PY

bash /tmp/v050-final-build-fixed.sh
