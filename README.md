#  Дипломная работа по профессии «Системный администратор -Кримчук Георгий

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal  

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

**Так как прерываемая ВМ проработает не больше 24ч, перед сдачей работы на проверку дипломному руководителю сделайте ваши ВМ постоянно работающими.**

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Использование `Terraform` и `Ansible`

![terraform](https://github.com/George210890/sys-diplom/blob/main/inst-terraform.png)
![ansible](https://github.com/George210890/sys-diplom/blob/main/ansible-ping.png)

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

### Выполнение сайта 

 - Сделал наполнение сайта чуть разным (сам `index.html`), чтобы видеть работу балансировщика.
![](https://github.com/George210890/sys-diplom/blob/main/scr-web1.png)
![](https://github.com/George210890/sys-diplom/blob/main/scr-web2.png)

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

### Выполнение `Target Group`

![Target Group](https://github.com/George210890/sys-diplom/blob/main/target-group.png)

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

### Выполнение бэкенда
![http1](https://github.com/George210890/sys-diplom/blob/main/http-router1.png)

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

### Выполнение `http-router`

![http-router](https://github.com/George210890/sys-diplom/blob/main/http-router.png)

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

### Выполнение `Load Balancer`

![LoadB](https://github.com/George210890/sys-diplom/blob/main/load-balabcer.png)
![LoadB1](https://github.com/George210890/sys-diplom/blob/main/load-b-1.png)


Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Test curl
![curl](https://github.com/George210890/sys-diplom/blob/main/curl.png)

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

### Выполнение мониторинга

- В моём случае я развернул систему на связке `Prometheus` и `Grafana`.Результат следующий:


![Prometheus](https://github.com/George210890/sys-diplom/blob/main/prometheus-node-exporter.png)

- При доработке плейбука с `grafana` была поставлена задача убрать из плейбука явно указанный пароль для `grafana` и сделать его зашифрованным. В этом случае использовал утилиту `ansible-vault`. Воспользовавшись [статьёй](https://habr.com/ru/companies/otus/articles/722106/) из Habr я выполнил следующие действия. По-скольку надо зашифровать один лишь пароль, я вынес его в папку `vars`, предварительно создав её в директории с ролью `grafana`. Далее из этой директории я запустил команду для шифрования значения переменной `ansible-vault encrypt_string --vault-id @prompt < значение переменной >` 

![encr](https://github.com/George210890/sys-diplom/blob/main/encr.png) 

Затем скопировав получившийся шифр заменил на значение в переменной `pass` в директории `vars`. В пелйбуке у меня остались переменные `{{ pass }}`и передаётся теперь в них именно тот шифр, который был создан ранее. Теперь чтобы `ansible` понял, что переменная зашифрована её нужно расшифровать, т.е. нужно запускать плейбук вот такой командой: `ansible-playbook --vault-id @prompt install_all.yml` После было проверенно уже на установленной `grafana`. `ansible` не ругался.

![graf-ans](https://github.com/George210890/sys-diplom/blob/main/graf-ans.png)


### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Логи с серверов через `elasticserch` в `kibana`

![kibana](https://github.com/George210890/sys-diplom/blob/main/kibana-logs.png)


### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Snapshots

![snapshots](https://github.com/George210890/sys-diplom/blob/main/snapshots.png)
![time](https://github.com/George210890/sys-diplom/blob/main/snap2.png)

### Обзор облачного построения

![](https://github.com/George210890/sys-diplom/blob/main/vm-ya.png)
![](https://github.com/George210890/sys-diplom/blob/main/http-router1.png)
![](https://github.com/George210890/sys-diplom/blob/main/ip-addr-ya.png)
![](https://github.com/George210890/sys-diplom/blob/main/net-ya.png)
![](https://github.com/George210890/sys-diplom/blob/main/route-tabl-ya.png)
![](scr/https://github.com/George210890/sys-diplom/blob/main/security-group-ya.png)
![](https://github.com/George210890/sys-diplom/blob/main/subnet-ya.png)
![](https://github.com/George210890/sys-diplom/blob/main/vm-ya.png)
![](https://github.com/George210890/sys-diplom/blob/main/zone-vpc-1.png)
![](https://github.com/George210890/sys-diplom/blob/main/zone-vpc.png)
![](https://github.com/George210890/sys-diplom/blob/main/zone-ya.png)
