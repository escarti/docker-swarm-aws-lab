# Continuous Delivery en Swarm

En esta práctica vamos a configurar nuestro sistema de despliegue continuo usando GitActions.

## Pre-requisitos

### Código

En primer lugar necesitaremos un repositorio de GitHub que usaremos para nuestro código fuente.

Para ello he preparado un repositorio con una web simple en FLASK que usaremos como ejemplo para desplegar.

El [repositorio](https://github.com/escarti/simple-flask-web) lo podéis [forkear aquí](https://github.com/escarti/simple-flask-web/fork)

### Docker-Hub

Ahora crearemos un repositorio para almacenar nuestras imágenes y le damos el nombre idéntico al fork o copia de nuestro repositorio con el código de la webapp (Esto es para minimizar el código que habremos de adaptar en los siguientes pasos). Podéis hacer click [aquí](https://hub.docker.com/repository/create)

## GitAction

Una vez clonado nuestro vamos al archivo .github/workflows/main.yaml donde podremos ver nuestro archivo de CI/CD

### GitHub Action file en detalle

En primer lugar vemos cuales son nuestras condiciones para lanzar nuestra acción:

```
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
```
Se trata de un push a master o un pull-request a master

El archivo contiene un único "job" que se ejecuta en una máquina ubuntu:

```
# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job for building testing and pushing image
  build-test-push:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest
```

El job consta de varios pasos:

1. En primer lugar hacemos checkout del código y creamos una variable de entorno para todo el job con el tag que queremos darle a nuestra imagen de Docker.

```
    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
    # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
    - uses: actions/checkout@v2
    
    - name: Set env
      run: echo ::set-env name=CURR_TAG::sha-$(echo $GITHUB_SHA | cut -c 1-7)
```

2. Haciendo uso de la potencia de GitHub Actions de poder compartir código de CI/CD al tratarse de meros archivos, usamos el [código que proporciona el propio docker](https://github.com/docker/build-push-action) para construir y tagear nuestra imagen. *IMPORTANTE* observar que en este paso tenemos puesto ``push: false`` para no subir nuestra imagen puesto que todavía no está testeada.

```    
    - uses: docker/build-push-action@v1
      with:
        tag_with_ref: true
        tags: latest,${{ env.CURR_TAG }}
        push: false
```

3. Usando docker compose cambiamos el entrypoint de nuestra imagen al vuelo para que se nos ejecuten los tests.

```   
    - name: Test the image
      run: docker-compose -f docker-compose_test.yaml up --exit-code-from webapp
      env:
        IMAGE: ${{ github.repository  }}:${{ env.CURR_TAG }}
```

4. Los siguientes pasos se ejecutan tan solo en la rama máster. El proceso de PR estaría validado y podríamos mergear nuestra rama en master. Si estamos en la rama master, además subiremos nuestra imagen a docker-hub

```
    - uses: docker/build-push-action@v1
      if: ${{ github.ref == 'refs/heads/master' }}
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        repository: ${{ secrets.DOCKER_REPO  }}
        tag_with_ref: true
        tag_with_sha: true
        tags: latest
```

5. Por último con nuestra imagen subida ya podemos actualizar automáticamente nuestro docker swarm. 

```
    - name: Deploy new image on docker-swarm
      if: ${{ github.ref == 'refs/heads/master' }}
      uses: fifsky/ssh-action@master
      with:
        command: |
          docker service update --image ${{ github.repository  }}:${{ env.CURR_TAG }} webapp
        host: ${{ secrets.HOST }}
        user: ec2-user
        key: ${{ secrets.PRIVATE_KEY}}
```

## Docker Swarm

Como véis, vuestro GitHub Actions workflow estará fallando dado que no habéis puesto los secrets correspondientes.

Debermos ir al repo y en la pestaña Settings -> Secrets añadir las siguientes variables:

DOCKER_PASSWORD: Password de dockerhub
DOCKER_REPO: Repo de dockerhub
DOCKER_USERNAME: Username de dockerhub
HOST: IP pública de nuestra máquina master del swarm
PRIVATE_KEY: Clave privada para conectarnos por SSH a nuestra máquina

Una vez hecho esto, hacemos un commit a master en nuestro repo de simple-flask-web para que se suba la imagen de Docker. Aseguraos de que los test pasan ;).

> El último paso fallará puesto que no hemos iniciado aún nuestro servicio en docker-swarm

Nos volvemos a conectar a la máquina maestra y lanzamos un servicio con 4 réplicas de nuestra simple-flask-app

``ssh -i ~/.ssh/docker-swarm-key ec2-user@MANAGER_IP``

``docker service create --name webapp --replicas 4 --publish published=80,target=5000 ${my_image_name}``

Ejectutamos ``docker service ps webapp`` y ``docker service inspect --pretty webapp`` para ver los detalles del servicio.

Si ahora visitamos la URL del balanceador de carga nos saldrá nuestra web "Hello World".

## Rolling update

Como hemos visto, nuestro archivo de CI/CD nos actualiza automáticamente el cluster de swarm cuando hay un cambio en master.

Vamos a ponerlo a prueba.

Cambiemos "Hello World!" por "Hello Developers!" y no os olvidéis de adaptar los test también.

## Simulación de errores

Ahora vamos a ir apagando los workers uno a uno y ejecutando ``docker service ps webapp`` para ver como nuestro máster se las apaña.

La primera vez que ejectuamos el comando veremos algo así:

```
          DESIRED STATE       CURRENT STATE            ERROR               PORTS
mv0p02yb78ku        webapp.1            escarti/simple-flask-web:sha-d21ec9b   ip-10-0-11-48.ec2.internal   Running             Running 56 seconds ago                       
l0cacdoh5c2r        webapp.2            escarti/simple-flask-web:sha-d21ec9b   ip-10-0-7-253.ec2.internal   Running             Running 55 seconds ago                       
qfth96ds4s23        webapp.3            escarti/simple-flask-web:sha-d21ec9b   ip-10-0-7-197.ec2.internal   Running             Running 56 seconds ago                       
w4n48k6fhcv5        webapp.4            escarti/simple-flask-web:sha-d21ec9b   ip-10-0-8-209.ec2.internal   Running             Running 56 seconds ago
```

Vamos a terminar manualmente dos de nuestros workers desde la consola de Amazon.

Pasados unos minutos volvemos a ejecutar ``docker service ps webapp`` y veremos que seguimos teniendo 4 replicas activas ahora distribuidas en tan solo 2 nodos.

```
 DESIRED STATE       CURRENT STATE                ERROR               PORTS
mv0p02yb78ku        webapp.1            escarti/simple-flask-web:sha-d21ec9b   ip-10-0-11-48.ec2.internal   Running             Running 4 minutes ago                            
l0cacdoh5c2r        webapp.2            escarti/simple-flask-web:sha-d21ec9b   ip-10-0-7-253.ec2.internal   Running             Running 4 minutes ago                            
2vimz2cn7k3z        webapp.3            escarti/simple-flask-web:sha-d21ec9b   ip-10-0-7-253.ec2.internal   Running             Running about a minute ago                       
qfth96ds4s23         \_ webapp.3        escarti/simple-flask-web:sha-d21ec9b   ip-10-0-7-197.ec2.internal   Shutdown            Running about a minute ago                       
no1ngmkxxdre        webapp.4            escarti/simple-flask-web:sha-d21ec9b   ip-10-0-11-48.ec2.internal   Running             Running about a minute ago                       
w4n48k6fhcv5         \_ webapp.4        escarti/simple-flask-web:sha-d21ec9b   ip-10-0-8-209.ec2.internal   Shutdown            Running 4 minutes ago 
```

## Referencias

https://github.com/marketplace/actions/build-and-push-docker-images
