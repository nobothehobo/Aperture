#!/usr/bin/env bash
set -euo pipefail

python3 -m pip install --quiet pillow
cat aegis7-source.tgz.b64.000 aegis7-source.tgz.b64.001 aegis7-source.tgz.b64.002 aegis7-source.tgz.b64.003 | base64 --decode > /tmp/aegis7-source.tgz
echo 'c793d2ebc9aea5b7cc500cafc69e94f81e5a11f24d9cd5d5fabd04dc09d8a11b  /tmp/aegis7-source.tgz' | sha256sum -c
rm -rf Aegis7_Transforming_Robot_Mod
tar -xzf /tmp/aegis7-source.tgz
cat v050-patch.b64.000 v050-patch.b64.001 v050-patch.b64.002 v050-patch.b64.003 | base64 --decode > /tmp/aegis7-v050-patch.tgz
echo '6435bd8a89bbc974ec16318a8a8b95db8d332849b1ea2e8aa9a7682deeee0c16  /tmp/aegis7-v050-patch.tgz' | sha256sum -c
tar -xzf /tmp/aegis7-v050-patch.tgz -C Aegis7_Transforming_Robot_Mod
rm -f Aegis7_Transforming_Robot_Mod/src/client/java/com/noah/aegis7/client/input/SteamDeckGamepadInput.java
python3 v050-generate-textures.py

cd Aegis7_Transforming_Robot_Mod
python verify-project.py
gradle clean build --stacktrace --warning-mode all 2>&1 | tee ../v050-build.log

JAR=build/libs/aegis7-0.5.0.jar
test -s "$JAR"
for entry in \
  fabric.mod.json \
  com/noah/aegis7/Aegis7Mod.class \
  com/noah/aegis7/Aegis7Client.class \
  com/noah/aegis7/client/gui/AegisRadialScreen.class \
  com/noah/aegis7/client/model/AegisModel.class \
  com/noah/aegis7/state/RobotChassis.class \
  assets/aegis7/textures/entity/stratos.png \
  assets/aegis7/textures/entity/wraith.png \
  assets/aegis7/textures/entity/vanguard.png; do
  jar tf "$JAR" | grep -Fx "$entry"
done
if jar tf "$JAR" | grep -q SteamDeckGamepadInput.class; then
  echo 'Legacy direct controller reader still present.' >&2
  exit 1
fi
unzip -p "$JAR" fabric.mod.json | grep -F '"version": "0.5.0"'
cp "$JAR" ../Aegis-7-Fabric-1.21.1-v0.5.0.jar
sha256sum ../Aegis-7-Fabric-1.21.1-v0.5.0.jar > ../Aegis-7-Fabric-1.21.1-v0.5.0.jar.sha256

sudo apt-get update -qq
sudo apt-get install -y -qq xvfb
set +e
timeout 180s xvfb-run -a gradle runClient --console=plain > ../v050-client.log 2>&1
client_status=$?
set -e
client_log=run/logs/latest.log
test -f "$client_log"
if grep -Eqi 'Mixin apply for mod aegis7 failed|MixinApplyError.*aegis7|Could not execute entrypoint.*aegis7|Exception in thread "Render thread"|Minecraft has crashed|NoClassDefFoundError.*aegis7' "$client_log"; then
  tail -n 250 "$client_log"
  exit 1
fi
grep -F 'Aegis-7 systems online.' "$client_log"
grep -E 'Sound engine started|minecraft:textures/atlas' "$client_log"
[[ "$client_status" == 0 || "$client_status" == 124 ]]

mkdir -p run
printf 'eula=true\n' > run/eula.txt
set +e
timeout 120s gradle runServer --console=plain > ../v050-server.log 2>&1
server_status=$?
set -e
server_log=run/logs/latest.log
test -f "$server_log"
if grep -Eqi 'Could not execute entrypoint.*aegis7|Minecraft has crashed|Exception in thread "Server thread"|NoClassDefFoundError.*aegis7' "$server_log"; then
  tail -n 220 "$server_log"
  exit 1
fi
grep -F 'Aegis-7 systems online.' "$server_log"
grep -E 'Done \([0-9.]+s\)!|For help, type "help"' "$server_log"
[[ "$server_status" == 0 || "$server_status" == 124 ]]

cd ..
rm -rf release-v050-final
mkdir release-v050-final
cp Aegis-7-Fabric-1.21.1-v0.5.0.jar* release-v050-final/
echo "$GITHUB_RUN_ID" > release-v050-final/RUN_ID.txt
echo 'Aegis-7 v0.5.0 passed source/resource validation, Java 21 and Fabric compilation/remapping, production-JAR inspection, client resource startup, and dedicated-server startup. Direct Steam Deck polling is absent.' > release-v050-final/BUILD_PASSED.txt
git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
git add -A release-v050-final
git diff --cached --quiet || { git commit -m 'Publish tested Aegis-7 v0.5.0 release'; git push origin HEAD:aegis7-build; }
