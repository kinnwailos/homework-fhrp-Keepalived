## Домашнее задание: FHRP (HSRP) + Keepalived

**Задание 1 (Cisco Packet Tracer / HSRP)**: настроить отслеживание интерфейса `Gi0/0`

[text](1/hsrp_advanced.pkt)

![alt text](screens/Screenshot_2026-05-03_20-07-09.png)

![alt text](screens/Screenshot_2026-05-03_20-08-36.png)


**Задание 2 (Linux / Keepalived)**: 2 “сервера” с keepalived+web, bash‑скрипт проверки, `vrrp_script` каждые 3 секунды, демонстрация переезда VIP

[theck_web.sh](1/check_web.sh)

[keepalived.conf.j2](ansible/roles/keepalived/templates/keepalived.conf.j2)

[site.yml](ansible/site.yml)

![Screenshot](screens/Screenshot_2026-05-04_20-48-11.png)