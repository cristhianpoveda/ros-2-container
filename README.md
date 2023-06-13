# biautonomouscar-ros-container

## Crear imagen personalizada

1) listar las dependencias apt necesarias en el archivo apt-requirements.txt

2) listar las dependencias de python3 necesarias en el archivo py-requirements.txt

3) Configurar la imagen base deseada en el archivo build-image.sh
    $ bash build-image.sh -h
    Muestra los argumentos de entrada necesarios para crear la imagen.

4) Correr el archivo build-image.sh
    $ bash build-image.sh [OPTIONS]

    4.1) Los argumentos del archivo build-image.sh son:
    -i nombre de la imagen a construir
    -t tag de la imagen a construir
    -n tag de la nueva imagen

Nota: para trabajar en pc se recomienda la imagen ros:foxy-ros-base
      para trabajar en jetson se recomienda la imagen dustynv/ros:foxy-ros-base-lt4-[VERISON-LT4]

## Crear y correr contenedor a partir de la imagen construida

1) Correr el archivo run-container.sh
    $ bash run-container.sh [OPTIONS]

    1.1) Los argumentos del archivo run-container.sh son:
    * -n nombre de la imagen base
    * -t tag de la imagen base
    * -d ROS_DOMAIN_ID para el contenedor

### Modificar paquetes de ROS 2 propios del contenedor

1) todos los paquetes de ROS 2 creados dentro del workspace predefinido, se comparten dinámicamente con el host (máquina que corre el contenedor) en el directorio ros-pkgs. Se pueden modificar con cualquier IDE desde fuera del contenedor y el cambio se refleha inmediatamente en el contenedor.

2) construir los paquetes modificados dentro del contenedor
    $ colcon build [OPTIONS]

Nota: al salir del contenedor este se elimina, pero los paquetes o cambios realizados se guardan en el directorio ros-pkgs y se cargan en cada nuevo contenedor creado con el script run-container.sh

## Configurar ROS_DOMAIN_ID

1) Al correr un contenedor incluir en $ docker run o en el archivo de compose la opcion:
    --env ROS_DOMAIN_ID="valor"
    Usar un numero diferente a 0 menor a 102. Debe compartir el mismo valor en todos los contenedores.

## Comunicar contenedores en el mismo host

1) Asegurar que ambos contenedores tienen el mismo usuario. Es decir que el UID es el mismo en ambos.

2) Al correr un contenedor incluir en $ docker run o en el archivo de compose la opcion:
    --ipc host
    habilita en el contenedor la memoria compartida del sistema (shared_memory), para que los nodos de ROS 2 se encuentren.

## Comunicar contenedores en hosts diferentes
Ej: contenedor en PC con contenedor en Jetson

1) Conectar ambos dispositivos a la misma red

2) Al correr un contenedor incluir en $ docker run o en el archivo de compose la opcion:
    --network host
    hace que el contenedor herede/comparta la misma IP del host. Si el comando "ping" entre contenedores es exitoso, se puede comunicar nodos de ROS 2.

## Uso de GPU

1) Instalar drivers de la GPU y el paquete nvidia-docker2, seguir los pasos del tutorial:
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

2) Al correr un contenedor incluir en $ docker run o en el archivo de compose la opcion:
    --gpus [OPTIONS]
    en options se selecciona las unidades GPU para habilitar en el contenedor

    Ej: --gpus all
    habilita todas las unidades GPU disponibles en la máquina.

3) Validar el uso de la GPU dentro del contenedor con el comando:
    $ nvidia-smi
    debe imprimir una tabla con las versiones de driver y la información de las GPU habilitadas.

## Acceso a dispositivos externos conectados por serial

1) Si se crea un "non-root user" dentro del contenedor, se debe agregar un archivo de rules para otorgar permisos de lectura y escritura en los puertos seriales.

    1.1) crear el archivo: /etc/udev/rules.d/99-serial.rules
        se debe incluir el 99 para que el sistema lea primero los archivos rules automaticos.

    1.2) dentro del archivo: /etc/udev/rules.d/99-serial.rules escribir la siguiente línea:
        KERNEL=="ttyUSB[0-9]*", MODE="0666"

2) Al correr un contenedor incluir en $ docker run o en el archivo de compose la opcion:
    --volume /dev:/dev
    el volumen otorga el acceso del contenedor a la carpeta /dev de la máquina local. Si se conecta o desconecta cualquier dispositivo serial, el cambio se ve reflejado inmediatamente en el contenedor.

## Uso de la pantalla
Ej: rviz2, rqt...

1) Al correr un contenedor incluir en $ docker run o en el archivo de compose las opciones:
    --env DISPLAY=${DISPLAY}
    --volume "/tmp/.X11-unix:/tmp/.X11-unix:rw"
    --privileged