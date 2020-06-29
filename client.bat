docker build ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --target client ^
  -t %DOCKER_USERNAME%/client:%ONEC_VERSION% ^
  -f client/Dockerfile .
