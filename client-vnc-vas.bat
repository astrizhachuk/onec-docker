docker build ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --build-arg VAS_VERSION=1.2.025 ^
  --target client-vnc-vas ^
  -t %DOCKER_USERNAME%/client-vnc-vas:%ONEC_VERSION% ^
  -f client/Dockerfile .
