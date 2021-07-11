# Описание

В данном репозитории находятся файлы для сборки образов [Docker](https://www.docker.com) с платформой [1С:Предприятие](http://v8.1c.ru) 8.3 и утилитами для автоматизации процессов разработки.

> Скрипт скачивания платформы позаимствован отсюда https://github.com/Infactum/onec_dock/blob/master/download.sh :+1:

Отличия от других сборок:
* Мульти-стейдж для сборки клиента (один докер-файл на все варианты клиентов)
* Веб-сервер (после PR влит в основной репозиторий)
* Исправлены юзеры и группы для 1с
* Автосборка для GitLab

# Использование

Добавить следующие переменные окружения:

* ONEC_USERNAME - учётная запись на http://releases.1c.ru
* ONEC_PASSWORD - пароль для учётной записи на http://releases.1c.ru
* ONEC_VERSION - версия платформы 1С:Преприятия 8.3, которая будет в образе
* DOCKER_USERNAME - учётная запись на [Docker Hub](https://hub.docker.com)
* ONESCRIPT_VERSION - версия OneScript (испльзуется только в образах с утилитами)


## Как сбилдить образы

:point_up: Введите в терминале команду `docker build` из соответствующей секции.

## Как запустить в docker-compose

```bash
$ docker-compose up -d
```

# Оглавление

- [Сервер](#сервер)
- [Сервер с дополнительными языками]
- [Клиент]
- [Клиент с поддержкой VNC]
- [Клиент с дополнительными языками]
- [Тонкий клиент]
- [Тонкий клиент с дополнительными языками]
- [Хранилище конфигурации]
- [rac-gui]
- [gitsync]
- [OneScript](#onescript)
- [vanessa-runner]

## Сервер
[(Наверх)](#Оглавление)

```bash
# win
docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
  --build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
  --build-arg ONEC_VERSION=%ONEC_VERSION% ^
  -t %DOCKER_USERNAME%/server:%ONEC_VERSION% ^
  -f server/Dockerfile .
```

```bash
#linux
docker build \
  --build-arg DOCKER_USERNAME=${DOCKER_USERNAME} \
  --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
  --build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
  --build-arg ONEC_VERSION=${ONEC_VERSION} \
  -t %DOCKER_USERNAME%/server:${ONEC_VERSION} \
  -f server/Dockerfile .
```

## Сервер с дополнительными языками<a name="Сервер-с-дополнительными-языками"></a>
[(Наверх)](#Оглавление)

```bash

```

## OneScript
[(Наверх)](#Оглавление)

```bash
# win
docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
  --build-arg BASE_IMAGE=client-vnc ^
  --build-arg BASE_TAG=%ONEC_VERSION% ^
  --build-arg ONESCRIPT_VERSION=1.6.0 ^
  -t %DOCKER_USERNAME%/client-oscript-1.6.0:%ONEC_VERSION% ^
  -f oscript/Dockerfile .
```

```bash
#linux
docker build ^
  --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% \
  --build-arg BASE_IMAGE=client-vnc \
  --build-arg BASE_TAG=%ONEC_VERSION% \
  --build-arg ONESCRIPT_VERSION=1.6.0 \
  -t %DOCKER_USERNAME%/client-oscript-1.6.0:%ONEC_VERSION% \
  -f oscript/Dockerfile .
```

// TODO
