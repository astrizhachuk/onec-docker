# --target client-vnc-vas
docker build ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  -t %DOCKER_USERNAME%/client:%ONEC_VERSION% ^
  -f client-all/Dockerfile .