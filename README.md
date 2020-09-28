# Описание

[![forthebadge](http://forthebadge.com/images/badges/built-with-love.svg)](http://forthebadge.com)

В данном репозитории находятся файлы для сборки образов [Docker](https://www.docker.com) с платформой [1С:Предприятие](http://v8.1c.ru) 8.3.

> Скрипт скачивания платформы позаимствован отсюда https://github.com/Infactum/onec_dock/blob/master/download.sh :+1:

Отличия от других сборок:
* Мульти-стейдж для сборки клиента (один докер-файл на все варианты клиентов)
* Веб-сервер (после PR влит в основной репозиторий)
* Исправлены юзеры и группы для 1С
* Автосборка для GitLab

# Использование

В терминале введите:

```bash
$ cp .onec.env.example .onec.env
```

Скорректируйте файл `.onec.env` в соответствии со своим окружением:

* ONEC_USERNAME - учётная запись на http://releases.1c.ru
* ONEC_PASSWORD - пароль для учётной записи на http://releases.1c.ru
* ONEC_VERSION - версия платформы 1С:Преприятия 8.3, которая будет в образе
* DOCKER_USERNAME - учётная запись на [Docker Hub](https://hub.docker.com)

Затем экспортируйте все необходимые переменные:

```bash
$ eval $(cat .onec.env)
```

## Как сбилдить образы

:point_up: Введите в терминале команду `docker build` из соответствующей секции.

## Как запустить в docker-compose
:exclamation: тестировалось только на macOS Mojave и Ubuntu 16.04/18.04

```bash
$ cp .env.example .env
# подправьте файл .env под себя
$ docker-compose up -d
```

# Оглавление

- [Сервер](#Сервер)
- [Сервер с дополнительными языками](#Сервер-с-дополнительными-языками)
- [Клиент](#support)
- [Клиент с поддержкой VNC](#support)
- [Клиент с дополнительными языками](#support)
- [Тонкий клиент](#support)
- [Тонкий клиент с дополнительными языками](#support)
- [Хранилище конфигурации](#contributing)
- [rac-gui](#license)
- [gitsync](#license)
- [oscript](#license)
- [vanessa-runner](#license)

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

// TODO