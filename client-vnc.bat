docker build ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --target client-vnc ^
  -t %DOCKER_USERNAME%/client-vnc:%ONEC_VERSION% ^
  -f client/Dockerfile .
