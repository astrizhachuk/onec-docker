docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg BASE_IMAGE=client-oscript-1.2.0 ^
  --build-arg BASE_TAG=%ONEC_VERSION% ^
  -t %DOCKER_USERNAME%/runner:%ONEC_VERSION% ^
  -f vanessa-runner/Dockerfile .
