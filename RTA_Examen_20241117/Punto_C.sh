#!/bin/bash
# Definir variables
DOCKER_IMAGE_NAME="web1-ramirez"
DOCKER_HUB_REPO="francoram/web1-ramirez"
PORT=8080

#Dentro de la carpeta <Path-Repo>/202406/docker/ edite el archivo index.html con los correspondientes datos
# sudo nano index.html

#agrego el usuario actual y reinicio la sesion (ctrl+c & vagrant ssh) para que pertenezca al grupo del usuario actual en caso de ser necesario
sudo usermod -a -G docker $(whoami)

#inicio sesion en Dockerhub
docker login -u francoram

#creo el archivo Dockerfile en <Path-Repo>/202406/docker/
echo "Creando Dockerfile..."
sudo touch Dockerfile

cat <<EOF > Dockerfile
# Usa la imagen oficial de Nginx como base
FROM nginx:latest

# Copia el archivo index.html modificado a la carpeta correspondiente en el contenedor
COPY index.html /usr/share/nginx/html/index.html

# Se exoine el puerto 80 del contenedor
EXPOSE 80
EOF

#creo el archivo run.sh
sudo nano run.sh

#Dentro de run.sh: 
#!/bin/bash
#Ramirez

# Ejecuta la imagen de Docker en el puerto 8080
#sudo docker run -d -p 8080:80 francoram/web1-ramirez

# previo a construir la imagen ampliamos el tamaño de lv-docker
sudo lvextend -l +125 /dev/mapper/vg_datos-lv_docker

#Redimensiona el sistema de archivos para usar el nuevo espacio
sudo resize2fs /dev/mapper/vg_datos-lv_docker
df -h /var/lib/docker


#Construir la imagen Docker
echo "Construyendo la imagen Docker..."./r
sudo docker build -t $DOCKER_IMAGE_NAME .

#Etiquetar la imagen para Docker Hub
echo "Etiquetando la imagen para Docker Hub..."
sudo docker tag $DOCKER_IMAGE_NAME $DOCKER_HUB_REPO

#Subir la imagen a Docker Hub
echo "Subiendo la imagen a Docker Hub..."
sudo docker push $DOCKER_HUB_REPO

# Ejecutar run.sh
echo "Ejecutando el script run.sh..."
sudo chmod +x run.sh

./run.sh
