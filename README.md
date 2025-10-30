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

### Примеры запуска

- [Сборка образов для 1С:Платформа](#сборка-образов-для-1сплатформа)
  - [Процесс сборки образов](#процесс-сборки-образов)
    - [Примеры запуска](#примеры-запуска)
    - [Сервер](#сервер)
    - [Сервер с дополнительными языками](#сервер-с-дополнительными-языками)
    - [Клиент](#клиент)
    - [Клиент с дополнительными языками](#клиент-с-дополнительными-языками)
    - [Клиент с поддержкой VNC](#клиент-с-поддержкой-vnc)
    - [Клиент с дополнительными языками и поддержкой VNC](#клиент-с-дополнительными-языками-и-поддержкой-vnc)
    - [Хранилище конфигурации](#хранилище-конфигурации)
    - [Хранилище конфигурации с сервером apache](#хранилище-конфигурации-с-сервером-apache)
    - [OneScript](#onescript)
  - [Как запустить в docker-compose](#как-запустить-в-docker-compose)
  - [Как запустить тестирование VA](#как-запустить-тестирование-va)
  - [Как работать с удаленных хранилищем](#как-работать-с-удаленных-хранилищем)


- [rac-gui]
- [gitsync]
- [vanessa-runner]

### Сервер

[(наверх)](#оглавление)

```bash
# windows
docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  -t %DOCKER_USERNAME%/server:%ONEC_VERSION% ^
  -f server/Dockerfile .

# linux
docker build \
  --build-arg DOCKER_USERNAME=${DOCKER_USERNAME} \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  -t ${DOCKER_USERNAME}/server:${ONEC_VERSION} \
  -f server/Dockerfile .
```

### Сервер с дополнительными языками

[(наверх)](#оглавление)

```bash
# windows
docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --build-arg nls_enabled=true ^
  -t %DOCKER_USERNAME%/server:%ONEC_VERSION% ^
  -f server/Dockerfile .

# linux
docker build \
  --build-arg DOCKER_USERNAME=${DOCKER_USERNAME} \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --build-arg nls_enabled=true \
  -t ${DOCKER_USERNAME}/server:${ONEC_VERSION} \
  -f server/Dockerfile .
```

### Клиент

[(наверх)](#оглавление)

```bash
# windows
docker build ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --target client ^
  -t %DOCKER_USERNAME%/client:%ONEC_VERSION% ^
  -f client/Dockerfile .

# linux
docker build \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --target client \
  -t %DOCKER_USERNAME%/client:${ONEC_VERSION} \
  -f client/Dockerfile .
```

### Клиент с дополнительными языками

[(наверх)](#оглавление)

```bash
# windows
docker build ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --build-arg nls_enabled=true ^
  --target client ^
  -t %DOCKER_USERNAME%/client:%ONEC_VERSION% ^
  -f client/Dockerfile .

# linux
docker build \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --build-arg nls_enabled=true \
  --target client \
  -t %DOCKER_USERNAME%/client:${ONEC_VERSION} \
  -f client/Dockerfile .
```

### Клиент с поддержкой VNC

[(наверх)](#оглавление)

```bash
# windows
docker build ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --target client-vnc ^
  -t %DOCKER_USERNAME%/client:%ONEC_VERSION% ^
  -f client/Dockerfile .

# linux
docker build \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --target client-vnc \
  -t %DOCKER_USERNAME%/client:${ONEC_VERSION} \
  -f client/Dockerfile .
```

### Клиент с дополнительными языками и поддержкой VNC

[(наверх)](#оглавление)

```bash
# windows
docker build ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  --build-arg nls_enabled=true ^
  --target client-vnc ^
  -t %DOCKER_USERNAME%/client:%ONEC_VERSION% ^
  -f client/Dockerfile .

# linux
docker build \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  --build-arg nls_enabled=true \
  --target client-vnc \
  -t %DOCKER_USERNAME%/client:${ONEC_VERSION} \
  -f client/Dockerfile .
```

### Хранилище конфигурации

```bash
# windows
docker build ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  -t %DOCKER_USERNAME%/crs:%ONEC_VERSION% ^
  -f crs/Dockerfile .

# linux
docker build \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  -t %DOCKER_USERNAME%/crs:${ONEC_VERSION} \
  -f crs/Dockerfile .
```

### Хранилище конфигурации с сервером apache

```bash
# windows
docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  -t %DOCKER_USERNAME%/crs-apache:%ONEC_VERSION% ^
  -f crs-apache/Dockerfile .

# linux
docker build \
  --build-arg DOCKER_USERNAME=${DOCKER_USERNAME} \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  -t %DOCKER_USERNAME%/crs-apache:${ONEC_VERSION} \
  -f crs-apache/Dockerfile .
```

### OneScript

[(наверх)](#оглавление)

```bash
# windows
docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg BASE_IMAGE=client-vnc ^
  --build-arg BASE_TAG=%ONEC_VERSION% ^
  --build-arg ONESCRIPT_VERSION=1.6.0 ^
  -t %DOCKER_USERNAME%/oscript-1.6.0:%ONEC_VERSION% ^
  -f oscript/Dockerfile .

# linux
docker build \
  --build-arg DOCKER_USERNAME=${DOCKER_USERNAME} \
  --build-arg BASE_IMAGE=client-vnc \
  --build-arg BASE_TAG=${ONEC_VERSION} \
  --build-arg ONESCRIPT_VERSION=1.6.0 \
  -t ${DOCKER_USERNAME}/oscript-1.6.0:${ONEC_VERSION} \
  -f oscript/Dockerfile .
```

## Как запустить в docker-compose

```bash
docker-compose up -d
```

## Как запустить тестирование VA

Через переменную окружения ONEC_EXEC_PARAMS можно задать строку запуска клиента 1С.

```bash
# windows
docker run --rm -it -p 5900:5900/tcp ^
  --env-file=.env.docker  ^
  -v %CD%\nethasp.ini:/opt/1cv8/current/conf/nethasp.ini ^
  -v %CD%\VAParams.json:/home/usr1cv8/VAParams.json ^
  %DOCKER_USERNAME%/va:%ONEC_VERSION%

# linux
docker run --rm -it -p 5900:5900/tcp \
  --env-file=.env.docker  \
  -v $(pwd)/nethasp.ini:/opt/1cv8/current/conf/nethasp.ini \
  -v $(pwd)/VAParams.json:/home/usr1cv8/VAParams.json \
  ${DOCKER_USERNAME}/va:${ONEC_VERSION}
```

где файл ```.env.docker``` содержит инициализацию переменных окружения:

```bash
ONEC_EXEC_PARAMS=ENTERPRISE /F/home/usr1cv8/base /N Администратор /TESTMANAGER /Execute /va.epf /C"StartFeaturePlayer;workspaceRoot=/home/usr1cv8/project;VBParams=/home/usr1cv8/VAParams.json"
```

Пример иллюстрирует запуск контейнера, в котором будет открыта обработка VA в режиме предприятия 1С, с последующим удалением контейнера по завершению работы. Процесс тестирования описывается параметрами запуска VA в файле VAParams.json. Сам процесс тестирования можно контролировать подключившись к рабочему столу через порт 5900, например, с помощью [VNC Viewer](https://www.realvnc.com/en/connect/download/viewer/).

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
