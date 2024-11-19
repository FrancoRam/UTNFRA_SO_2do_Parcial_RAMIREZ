#Ramirez

#En ./202406/ansible/roles/2do_parcial:

sudo mdkir templates

#En /<Path-Repo>/202406/ansible/roles/2do_parcial/templates:

sudo nano datos_alumno.txt.j2

#Dentro de esta plantilla:
Nombre: {{ nombre }}
Apellido: {{ apellido }}
Division: {{ division }}


sudo nano datos_equipo.txt.j2

#Dentro de esta otra plantilla:
IP: {{ ip }}
Distribucion: {{ distribucion }}
Cantidad de Cores: {{ cores }}


#En /<Path-Repo>/202406/ansible/roles/2do_parcial/vars:
sudo nano main.yml

nombre: Franco
apellido: Ramirez
division: 311
ip: "{{ ansible_default_ipv4.address }}"
distribucion: "{{ ansible_distribution }}"
cores: "{{ ansible_processor_cores }}"


#En /<Path-Repo>/202406/ansible/roles/2do_parcial/tasks:
sudo nano main.yml

#Dentro de este archivo:
---
# tasks file for 2do_parcial
- name: Crear directorios /tmp/2do_parcial/alumno y /tmp/2do_parcial/equipo
  file:
    path: "/tmp/2do_parcial/{{ item }}"
    state: directory
    mode: '0755'
  loop:
    - alumno
    - equipo

- name: Copiar datos_alumno.txt con plantilla
  template:
    src: datos_alumno.txt.j2
    dest: /tmp/2do_parcial/alumno/datos_alumno.txt
    mode: '0644'

- name: Copiar datos_equipo.txt con plantilla
  template:
    src: datos_equipo.txt.j2
    dest: /tmp/2do_parcial/equipo/datos_equipo.txt
    mode: '0644'

- name: Configurar sudoers para 2PSupervisores
  become: yes
  lineinfile:
    path: /etc/sudoers
    regexp: '^%2PSupervisores'
    line: '%2PSupervisores ALL=(ALL) NOPASSWD: ALL'
    validate: '/usr/sbin/visudo -cf %s'


#En /<Path-Repo>/202406/ansible:
ansible-playbook -i inventory/hosts playbook.yml
