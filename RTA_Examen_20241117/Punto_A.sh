#! /bin/bash
#Franco Ramirez

#Crear las particiones LVM en los discos 
sudo fdisk /dev/sdc <<EOF
n
p
1


t
8e
w
EOF

sudo fdisk /dev/sdd <<EOF
n
p
1


t
8e
w
EOF

#Limpiar la metadata para eliminar cualquier tipo de basura
sudo wipefs -a /dev/sdc 
sudo wipefs -a /dev/sdd

#Crear los volúmenes físicos (PVs)
sudo pvcreate /dev/sdc1 /dev/sdd1


#Crear los grupo de volúmenes(VGs)
sudo vgcreate vg_datos /dev/sdc1
sudo vgcreate vg_temp /dev/sdd1

#Crear los volúmenes lógicos (LVs)
#-L: especifica el tamaño del VL
#-n: especifica el nombre del VL
#<vg_name>: especifica el grupo de volúmenes donde se creara el volumen lógico

sudo lvcreate -L 5M -n lv_docker vg_datos
sudo lvcreate -L 1.5G -n lv_workareas vg_datos
sudo lvcreate -L 512M -n lv_swap vg_temp

#Formateamos los LVs
sudo mkfs -t ext4 /dev/mapper/vg_datos-lv_docker
sudo mkfs -t ext4 /dev/mapper/vg_datos-lvworkareas
sudo mkswap /dev/vg_temp/lv_swap

#Montamos los LVs
#Se crea el directorio para montar el volumen lógico de lv_workareas y lv_docker
#Lo montamos al directorio 

sudo mkdir -p /var/lib/docker/
sudo mount /dev/vg_datos/lv_docker /var/lib/docker/

sudo mkdir -p /work
sudo mount /dev/vg_datos/lv_workareas /work/

#activa el LV lv_swap como espacio de intercambio. El espacio swap es un tipo de memoria se utiliza cuando la RAM está llena.
sudo swapon /dev/vg_temp/lv_swap

#Actualizamos /etc/fstab
echo '/dev/vg_datos/lv_docker /var/lib/docker ext4 defaults 0 0' | sudo tee -a /etc/fstab
echo '/dev/vg_datos/lv_workareas /work ext4 defaults 0 0' | sudo tee -a /etc/fstab
echo '/dev/vg_temp/lv_swap none swap sw 0 0' | sudo tee -a /etc/fstab

#Verificamos montajes
df -h
