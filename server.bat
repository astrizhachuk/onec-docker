docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  -t %DOCKER_USERNAME%/server:%ONEC_VERSION% ^
  -f server/Dockerfile .
