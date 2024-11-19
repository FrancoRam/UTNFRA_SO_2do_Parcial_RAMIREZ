#!/bin/bash

# EL SIGUIENTE ES UNA Copia de archivo Script alojado en /usr/local/bin/RamirezAltaUser-Groups.sh
# SE DIO PERMISOS DE EJECUCION PREVIAMENTE
# LA EJECUCION DEL MISMO SE REALIZO CON EL SIGUIENTE COMANDO:
# sudo /usr/local/bin/RamirezAltaUser-Groups.sh vagrant /home/vagrant/repogit/UTN-FRA_SO_Examenes/202406/bash_script/Lista_Usuarios.txt
# 1ER PARAMETRO: USUARIO 'VAGRANT'
# 2DO PARAMETRO: LISTA DE USUARIOS 'Lista_Usuarios.txt'

# Validación de parámetros
if [[ $# -ne 2 ]]; then
    echo "Uso: $0 <usuario_existente> <ruta_lista_usuarios.txt>"
    exit 1
fi

# Parámetros
USUARIO_BASE=$1
LISTA_USUARIOS=$2

# Validar que el usuario (vagrant) base exista
if ! id "$USUARIO_BASE" &>/dev/null; then
    echo "El usuario base $USUARIO_BASE no existe."
    exit 1
fi

# Validar que la lista de usuariuos exista
if [[ ! -f $LISTA_USUARIOS ]]; then
    echo "El archivo $LISTA_USUARIOS no existe."
    exit 1
fi

# Obtener hash de la contraseña del usuario base
PASSWORD_HASH=$(sudo grep "^$USUARIO_BASE:" /etc/shadow | awk -F ':' '{print $2}')
if [[ -z $PASSWORD_HASH ]]; then
    echo "No se pudo obtener el hash de la contraseña del usuario $USUARIO_BASE."
    exit 1
fi

# Leer el archivo de usuarios
while IFS=',' read -r usuario grupo directorio_home; do
    # Ignorar líneas que sean de comentarios  #
    [[ $usuario =~ ^# ]] && continue

    # Crear el grupo si NO existe
    if ! getent group "$grupo" &>/dev/null; then
        sudo groupadd "$grupo"
        echo "Grupo $grupo creado."
    else
        echo "Grupo $grupo ya existe."
    fi

    # Crear el usuario si NO existe
    if ! id "$usuario" &>/dev/null; then
        sudo useradd -m -d "$directorio_home" -s /bin/bash -g "$grupo" -p "$PASSWORD_HASH" "$usuario"
        echo "Usuario $usuario creado y asignado al grupo $grupo."
    else
        echo "Usuario $usuario ya existe."
    fi
done < "$LISTA_USUARIOS"
