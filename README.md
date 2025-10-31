- [Сборка образов для 1С:Платформа](#сборка-образов-для-1сплатформа)
  - [Процесс сборки образов](#процесс-сборки-образов)
    - [Сервер](#сервер)
    - [Сервер с дополнительными языками](#сервер-с-дополнительными-языками)
    - [Клиент](#клиент)
    - [Клиент с дополнительными языками](#клиент-с-дополнительными-языками)
    - [Клиент с поддержкой VNC](#клиент-с-поддержкой-vnc)
    - [Клиент с дополнительными языками и поддержкой VNC](#клиент-с-дополнительными-языками-и-поддержкой-vnc)
    - [EDT](#edt)
  - [Как запустить в docker-compose](#как-запустить-в-docker-compose)
  - [Как работать с удаленных хранилищем](#как-работать-с-удаленных-хранилищем)

# Сборка образов для 1С:Платформа

В репозитории находятся файлы для сборки образов [Docker](https://www.docker.com) с платформой [1С:Предприятие](http://v8.1c.ru) 8.3 и утилитами для автоматизации процессов разработки.

> Скрипт скачивания платформы позаимствован отсюда https://github.com/Infactum/onec_dock/blob/master/download.sh :+1:

Отличия от других сборок:

* [Multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) (один Dockerfile для всех вариантов клиента 1с)
* Исправлены юзеры и группы для 1с
* Автосборка для GitLab
* Добавлена возможность альтернативного открытия клиентского приложения без переопределения `entrypoint` с помощью передачи параметров запуска через переменную окружения `ONEC_EXEC_PARAMS`

## Процесс сборки образов

1. Добавить переменные окружения.

   ```text
   ONEC_USERNAME - учетная запись на http://releases.1c.ru
   ONEC_PASSWORD - пароль для учетной записи на http://releases.1c.ru
   ONEC_VERSION - версия платформы 1С:Предприятие 8.3, которая будет в образе
   DOCKER_USERNAME - учетная запись на [Docker Hub](https://hub.docker.com) или другого репозитория образов
   ```

2. Сформировать образ через CLI.

### Сервер

[(наверх)](#оглавление)

```bash
# windows
docker build ^
    --pull ^
    --build-arg DOCKER_USERNAME=library ^
    --build-arg BASE_IMAGE=ubuntu ^
    --build-arg BASE_TAG=20.04 ^
    --build-arg ONESCRIPT_PACKAGES="yard" ^
    -t %DOCKER_USERNAME%/oscript-downloader:latest ^
    -f oscript/Dockerfile .

docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --build-arg DOWNLOADER_REGISTRY_URL=%DOCKER_USERNAME% ^
  --build-arg DOWNLOADER_IMAGE=oscript-downloader ^
  --build-arg DOWNLOADER_TAG=latest ^
  -t %DOCKER_USERNAME%/server:%ONEC_VERSION% ^
  -f server/Dockerfile .

# linux
docker build \
    --pull \
    --build-arg DOCKER_USERNAME=library \
    --build-arg BASE_IMAGE=ubuntu \
    --build-arg BASE_TAG=20.04 \
    --build-arg ONESCRIPT_PACKAGES="yard" \
    -t ${DOCKER_USERNAME}/oscript-downloader:latest \
    -f oscript/Dockerfile .

docker build \
  --build-arg DOCKER_USERNAME=${DOCKER_USERNAME} \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --build-arg DOWNLOADER_REGISTRY_URL=${DOCKER_USERNAME} \
  --build-arg DOWNLOADER_IMAGE=oscript-downloader \
  --build-arg DOWNLOADER_TAG=latest \
  -t ${DOCKER_USERNAME}/server:${ONEC_VERSION} \
  -f server/Dockerfile .
```

### Сервер с дополнительными языками

[(наверх)](#оглавление)

```bash
# windows
docker build ^
    --pull ^
    --build-arg DOCKER_USERNAME=library ^
    --build-arg BASE_IMAGE=ubuntu ^
    --build-arg BASE_TAG=20.04 ^
    --build-arg ONESCRIPT_PACKAGES="yard" ^
    -t %DOCKER_USERNAME%/oscript-downloader:latest ^
    -f oscript/Dockerfile .

docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --build-arg DOWNLOADER_REGISTRY_URL=%DOCKER_USERNAME% ^
  --build-arg DOWNLOADER_IMAGE=oscript-downloader ^
  --build-arg DOWNLOADER_TAG=latest ^
  --build-arg nls_enabled=true ^
  -t %DOCKER_USERNAME%/server:%ONEC_VERSION% ^
  -f server/Dockerfile .

# linux
docker build \
    --pull \
    --build-arg DOCKER_USERNAME=library \
    --build-arg BASE_IMAGE=ubuntu \
    --build-arg BASE_TAG=20.04 \
    --build-arg ONESCRIPT_PACKAGES="yard" \
    -t ${DOCKER_USERNAME}/oscript-downloader:latest \
    -f oscript/Dockerfile .

docker build \
  --build-arg DOCKER_USERNAME=${DOCKER_USERNAME} \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --build-arg DOWNLOADER_REGISTRY_URL=${DOCKER_USERNAME} \
  --build-arg DOWNLOADER_IMAGE=oscript-downloader \
  --build-arg DOWNLOADER_TAG=latest \
  --build-arg nls_enabled=true \
  -t ${DOCKER_USERNAME}/server:${ONEC_VERSION} \
  -f server/Dockerfile .
```

### Клиент

[(наверх)](#оглавление)

```bash
# windows
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
  --target client ^
  -t %DOCKER_USERNAME%/client:%ONEC_VERSION% ^
  -f client/Dockerfile .

# linux
docker build \
    --pull \
    --build-arg DOCKER_USERNAME=library \
    --build-arg BASE_IMAGE=ubuntu \
    --build-arg BASE_TAG=20.04 \
    --build-arg ONESCRIPT_PACKAGES="yard" \
    -t ${DOCKER_USERNAME}/oscript-downloader:latest \
    -f oscript/Dockerfile .

docker build \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --build-arg DOWNLOADER_REGISTRY_URL=${DOCKER_USERNAME} \
  --build-arg DOWNLOADER_IMAGE=oscript-downloader \
  --build-arg DOWNLOADER_TAG=latest \
  --target client \
  -t ${DOCKER_USERNAME}/client:${ONEC_VERSION} \
  -f client/Dockerfile .
```

### Клиент с дополнительными языками

[(наверх)](#оглавление)

```bash
# windows
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
  --build-arg nls_enabled=true ^
  --target client ^
  -t %DOCKER_USERNAME%/client:%ONEC_VERSION% ^
  -f client/Dockerfile .

# linux
docker build \
    --pull \
    --build-arg DOCKER_USERNAME=library \
    --build-arg BASE_IMAGE=ubuntu \
    --build-arg BASE_TAG=20.04 \
    --build-arg ONESCRIPT_PACKAGES="yard" \
    -t ${DOCKER_USERNAME}/oscript-downloader:latest \
    -f oscript/Dockerfile .

docker build \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --build-arg DOWNLOADER_REGISTRY_URL=${DOCKER_USERNAME} \
  --build-arg DOWNLOADER_IMAGE=oscript-downloader \
  --build-arg DOWNLOADER_TAG=latest \
  --build-arg nls_enabled=true \
  --target client \
  -t ${DOCKER_USERNAME}/client:${ONEC_VERSION} \
  -f client/Dockerfile .
```

### Клиент с поддержкой VNC

[(наверх)](#оглавление)

```bash
# windows
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

# linux
docker build \
    --pull \
    --build-arg DOCKER_USERNAME=library \
    --build-arg BASE_IMAGE=ubuntu \
    --build-arg BASE_TAG=20.04 \
    --build-arg ONESCRIPT_PACKAGES="yard" \
    -t ${DOCKER_USERNAME}/oscript-downloader:latest \
    -f oscript/Dockerfile .

docker build \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --build-arg DOWNLOADER_REGISTRY_URL=${DOCKER_USERNAME} \
  --build-arg DOWNLOADER_IMAGE=oscript-downloader \
  --build-arg DOWNLOADER_TAG=latest \
  --target client-vnc \
  -t ${DOCKER_USERNAME}/client-vnc:${ONEC_VERSION} \
  -f client/Dockerfile .
```

### Клиент с дополнительными языками и поддержкой VNC

[(наверх)](#оглавление)

```bash
# windows
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
  --build-arg nls_enabled=true ^
  --target client-vnc ^
  -t %DOCKER_USERNAME%/client-vnc:%ONEC_VERSION% ^
  -f client/Dockerfile .

# linux
docker build \
    --pull \
    --build-arg DOCKER_USERNAME=library \
    --build-arg BASE_IMAGE=ubuntu \
    --build-arg BASE_TAG=20.04 \
    --build-arg ONESCRIPT_PACKAGES="yard" \
    -t ${DOCKER_USERNAME}/oscript-downloader:latest \
    -f oscript/Dockerfile .

docker build \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --build-arg DOWNLOADER_REGISTRY_URL=${DOCKER_USERNAME} \
  --build-arg DOWNLOADER_IMAGE=oscript-downloader \
  --build-arg DOWNLOADER_TAG=latest \
  --build-arg nls_enabled=true \
  --target client-vnc \
  -t ${DOCKER_USERNAME}/client-vnc:${ONEC_VERSION} \
  -f client/Dockerfile .
```

### EDT

[(наверх)](#оглавление)

```bash
# windows
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
  --build-arg BASE_IMAGE=azul/zulu-openjdk ^
  --build-arg BASE_TAG=17 ^
  --build-arg EDT_VERSION=2024.2.6 ^
  --build-arg DOWNLOADER_REGISTRY_URL=%DOCKER_USERNAME% ^
  --build-arg DOWNLOADER_IMAGE=oscript-downloader ^
  --build-arg DOWNLOADER_TAG=latest ^
  -t %DOCKER_USERNAME%/edt:%ONEC_VERSION% ^
  -f edt/Dockerfile .

# linux
docker build \
    --pull \
    --build-arg DOCKER_USERNAME=library \
    --build-arg BASE_IMAGE=ubuntu \
    --build-arg BASE_TAG=20.04 \
    --build-arg ONESCRIPT_PACKAGES="yard" \
    -t ${DOCKER_USERNAME}/oscript-downloader:latest \
    -f oscript/Dockerfile .

docker build \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --build-arg BASE_IMAGE=azul/zulu-openjdk \
  --build-arg BASE_TAG=17 \
  --build-arg EDT_VERSION=2024.2.6 \
  --build-arg DOWNLOADER_REGISTRY_URL=${DOCKER_USERNAME} \
  --build-arg DOWNLOADER_IMAGE=oscript-downloader \
  --build-arg DOWNLOADER_TAG=latest \
  -t ${DOCKER_USERNAME}/edt:${ONEC_VERSION} \
  -f edt/Dockerfile .
```

## Как запустить в docker-compose

```bash
docker-compose up -d
```

## Как работать с удаленных хранилищем

```bash
docker run --rm -d -p 80:80 crs-apache:8.3.17.1549
```

Пользовательские хранилища располагаются внутри volume в каталоге `/home/usr1cv8/.1cv8/repo`. По неизвестным пока причинам 1С не работает с хранилищами через -v (1С зависает).

Пример доступа к хранилищу:

> /home/usr1cv8/.1cv8/repo/base1

```bash
http://localhost:80/repo/repo.1ccr/base1
```

> /home/usr1cv8/.1cv8/repo/base2

```bash
http://localhost:80/repo/repo.1ccr/base2
```
