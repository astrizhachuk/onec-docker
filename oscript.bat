docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg BASE_IMAGE=client-vnc ^
  --build-arg BASE_TAG=%ONEC_VERSION% ^
  --build-arg ONESCRIPT_VERSION=1.2.0 ^
  -t %DOCKER_USERNAME%/client-oscript-1.2.0:%ONEC_VERSION% ^
  -f oscript/Dockerfile .
