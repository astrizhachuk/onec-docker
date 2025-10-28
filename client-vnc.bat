docker build ^
    --pull ^
    --build-arg DOCKER_USERNAME=library ^
    --build-arg BASE_IMAGE=ubuntu ^
    --build-arg BASE_TAG=20.04 ^
    --build-arg ONESCRIPT_PACKAGES="yard" ^
    -t %DOCKER_USERNAME%/oscript-downloader:latest ^
    -f oscript/Dockerfile .

docker build ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --build-arg DOWNLOADER_REGISTRY_URL=%DOCKER_USERNAME% ^
  --build-arg DOWNLOADER_IMAGE=oscript-downloader ^
  --build-arg DOWNLOADER_TAG=latest ^
  --target client-vnc ^
  -t %DOCKER_USERNAME%/client-vnc:%ONEC_VERSION% ^
  -f client/Dockerfile .
