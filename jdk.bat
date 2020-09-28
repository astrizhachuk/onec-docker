docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg BASE_IMAGE=client-vnc ^
  --build-arg BASE_TAG=%ONEC_VERSION% ^
  -t %DOCKER_USERNAME%/jdk:%ONEC_VERSION% ^
  -f jdk/Dockerfile .