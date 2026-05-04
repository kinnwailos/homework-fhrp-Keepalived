## Vagrant: только VM (без автоконфигурации)

`Vagrantfile` в корне поднимает две Ubuntu VM и настраивает private network.

Вся конфигурация приложений выполняется Ansible’ом из каталога `ansible/` (см. корневой `README.md`).

### Что будет сделано при `vagrant up`

1. Поднимутся VM `vm1` и `vm2`:
   - `vm1`: `192.168.56.10`
   - `vm2`: `192.168.56.11`

### Требования на хосте

- установлен `Vagrant`
- установлен provider, обычно `VirtualBox` (или другой, но Vagrantfile заточен под VirtualBox)

### Запуск

В корне репозитория:

```bash
vagrant up
```

Дальше — см. `README.md` → раздел “Задание 2” (Ansible playbook).

