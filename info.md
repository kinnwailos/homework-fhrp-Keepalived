## Домашнее задание: FHRP (HSRP) + Keepalived

В репозитории лежат материалы и заготовки для сдачи **двух заданий**:

- **Задание 1 (Cisco Packet Tracer / HSRP)**: настроить отслеживание интерфейса `Gi0/0` для **группы 1** (по аналогии с уже настроенным `Gi0/1` для группы 0), проверить отказ, приложить `.pkt` и скриншот настройки.
- **Задание 2 (Linux / Keepalived)**: 2 “сервера” с keepalived+web, bash‑скрипт проверки, `vrrp_script` каждые 3 секунды, демонстрация переезда VIP.

### Структура

- [`1/hsrp_active.pkt`](1/hsrp_active.pkt), [`1/hsrp_advanced.pkt`](1/hsrp_advanced.pkt): схемы Packet Tracer из лекции
- [`1/check_web.sh`](1/check_web.sh): bash‑скрипт проверки порта веб‑сервера и наличия `index.html` (копия для сдачи; “исходник” для Ansible — [`ansible/roles/keepalived/files/check_web.sh`](ansible/roles/keepalived/files/check_web.sh))
- [`1/keepalived-vrrp-script-master.conf`](1/keepalived-vrrp-script-master.conf): (опционально) старый пример шаблона MASTER
- [`1/keepalived-vrrp-script-backup.conf`](1/keepalived-vrrp-script-backup.conf): (опционально) старый пример шаблона BACKUP
- [`Vagrantfile`](Vagrantfile): поднимает две Ubuntu VM (только “железо”/сеть)
- [`ansible/site.yml`](ansible/site.yml): главный playbook (вся настройка для задания 2)

---

## Задание 1. Cisco Packet Tracer (HSRP + track)

### Что нужно сделать

На схеме уже настроено отслеживание интерфейса **`Gi0/1` для группы 0**. Требуется **аналогично** настроить отслеживание интерфейса **`Gi0/0` для группы 1**.

Ожидаемая логика: при падении линка (кабель/интерфейс down) “активный” маршрутизатор для группы 1 должен смениться, чтобы трафик продолжал ходить.

### Где взять схему

Открой в Cisco Packet Tracer один из файлов:
- [`1/hsrp_active.pkt`](1/hsrp_active.pkt) (обычно базовый вариант)
- [`1/hsrp_advanced.pkt`](1/hsrp_advanced.pkt) (если по лекции работали с ним)

### Как настроить track для `Gi0/0` (группа 1)

1) На роутере, где уже настроен track для группы 0, посмотри текущую конфигурацию HSRP и track:

- в CLI:
  - `show run | include standby|track`
  - `show standby brief`
  - `show track`

2) Найди существующую настройку для **группы 0** (примерная идея, у тебя номера могут отличаться):

- есть `track <id> interface Gi0/1 ...`
- и внутри интерфейса есть что-то вроде `standby 0 track <id> decrement <X>`

3) Добавь аналогично для **группы 1**, но уже на `Gi0/0`:

- создай/используй отдельный `track` для `Gi0/0`
- в HSRP для группы 1 добавь `standby 1 track <id> decrement <X>`

Важно:
- `track` должен ссылаться на **`Gi0/0`**
- `standby` должен быть для **группы 1**

### Как проверить (что надо для скриншота)

1) Сделай ping между `PC0` и `Server0` (чтобы было видно, что связь есть).
2) “Выдерни” один кабель между **одним из роутеров** и `Switch0` (чтобы интерфейс стал down).
3) Проверь, что:
   - `ping` продолжается/восстанавливается
   - в `show standby brief` видно переключение активного для группы 1

### Что отправлять на проверку

- итоговую схему `.pkt` (с сохранённой настройкой) — стартовые варианты в репозитории: [`1/hsrp_active.pkt`](1/hsrp_active.pkt), [`1/hsrp_advanced.pkt`](1/hsrp_advanced.pkt)
- скриншот, где виден процесс настройки (CLI‑команды/ввод) и/или проверка `show standby brief` + ping

---

## Задание 2. Keepalived + bash‑скрипт + web (через Vagrant)

### Идея решения

Vagrant используется **чтобы поднять 2 VM**.

Файлы для сдачи (артефакты):
- bash‑скрипт: [`1/check_web.sh`](1/check_web.sh) (и зеркало для роли Ansible: [`ansible/roles/keepalived/files/check_web.sh`](ansible/roles/keepalived/files/check_web.sh))
- конфигурация Keepalived (шаблон, из которого собирается `/etc/keepalived/keepalived.conf` на VM): [`ansible/roles/keepalived/templates/keepalived.conf.j2`](ansible/roles/keepalived/templates/keepalived.conf.j2)

Вся настройка выполняется **Ansible** (роли + переменные):
- установка пакетов
- конфигурация `nginx`
- конфигурация `keepalived` (VRRP unicast + VIP)
- копирование `check_web.sh` и подключение его в `vrrp_script` (каждые 3 секунды)

После применения playbook’а на обеих VM будет:

- `nginx` на `:80`
- `index.html` в `/var/www/html/index.html`
- `keepalived` с VIP **`192.168.56.15/24`**
- `vrrp_script` каждые **3 секунды**, который запускает `/usr/local/bin/check_web.sh 80 /var/www/html`
  - если порт недоступен **или** нет `index.html` → скрипт возвращает код != 0 → VIP переезжает на второй узел

### Запуск

В корне репозитория:

```bash
vagrant up
```

Применить Ansible (на хосте):

```bash
cd ansible
ansible-playbook -i inventory.ini site.yml
```

Примечание по inventory:
- `ansible/inventory.ini` подключается к VM через **port forwarding** (`127.0.0.1:2222` и `127.0.0.1:2200`), как в выводе `vagrant ssh-config`.
- Это полезно, если на хосте есть маршрутизация/VPN, из‑за которой прямой доступ к адресам private network (`192.168.56.x`) ломается.

Примечание по VirtualBox 7.x:
- адреса `private_network` должны попадать в диапазон из `/etc/vbox/networks.conf` (часто это `192.168.56.0/21`). Поэтому в `Vagrantfile` используются `192.168.56.10/11` и VIP `192.168.56.15`.

Проверка, где VIP сейчас (на каком узле):

```bash
vagrant ssh vm1 -c "ip -o -4 addr show | grep 192.168.56.15 || true"
vagrant ssh vm2 -c "ip -o -4 addr show | grep 192.168.56.15 || true"
```

### Демонстрация переезда VIP (скриншот)

```bash
vagrant ssh vm1 -c "ip -o -4 addr show | grep 192.168.56.15 || true"
vagrant ssh vm2 -c "ip -o -4 addr show | grep 192.168.56.15 || true"

vagrant ssh vm1 -c "sudo systemctl stop nginx"
sleep 7

vagrant ssh vm1 -c "ip -o -4 addr show | grep 192.168.56.15 || true"
vagrant ssh vm2 -c "ip -o -4 addr show | grep 192.168.56.15 || true"

vagrant ssh vm2 -c "curl -s http://192.168.56.15/ | head"
```

Ожидаемо: после остановки nginx на `vm1` VIP появится на `vm2`, а `curl` по VIP вернёт страницу с `BACKUP`/`vm2`.

### Что отправлять на проверку

- [`1/check_web.sh`](1/check_web.sh) (копия для сдачи; держите синхронно с [`ansible/roles/keepalived/files/check_web.sh`](ansible/roles/keepalived/files/check_web.sh))
- [`ansible/site.yml`](ansible/site.yml)
- [`ansible/roles/keepalived/templates/keepalived.conf.j2`](ansible/roles/keepalived/templates/keepalived.conf.j2) (и/или весь [`ansible/roles/keepalived/`](ansible/roles/keepalived/))
- скриншот, где видно “до/после” переезда VIP и `curl` по VIP

