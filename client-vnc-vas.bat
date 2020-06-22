docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg BASE_IMAGE=client-vnc^
  --build-arg BASE_TAG=%ONEC_VERSION% ^
  --build-arg VAS_VERSION=1.2.025 ^
  -t %DOCKER_USERNAME%/client-vnc-vas:%ONEC_VERSION% ^
  -f client-vnc-vas/Dockerfile .
