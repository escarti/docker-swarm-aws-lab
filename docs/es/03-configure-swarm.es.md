# Configurar el SWARM

Ahora que ya tenemos desplegada toda la infraestructura nos conectaremos a cada una de las instancias para configurar nuestros SWARM

En el archivo [/terraform/swarm_members/swarmec2.tfvars](../../terraform/swarm_members/swarmec2.tfvars) encontraremos las direcciones IP públicas y si lo hemos hecho todo bien podremos conectarnos con el siguiente comando:

``ssh -i ~/.ssh/docker-swarm-key ec2-user@EC2_PUB_IP``

## Iniciar el SWARM

En primer lugar nos conectaremos a la máquina manager con:

``ssh -i ~/.ssh/docker-swarm-key ec2-user@MANAGER_IP``

y ejecutamos ``docker swarm init`` y si todo ha ido bien tendremos un mensaje tal que así:

```bash
[ec2-user@ip-10-0-6-24 ~]$ docker swarm init
Swarm initialized: current node (kp06yf7lxqi63oltcvkq37g0n) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-161qkd1gwvbhio8lhvv5pc79agdr31azh1d253oe1ed2dg6oku-60eyb1ltfl0w29sjw6ypfft95 10.0.6.24:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

## Añadir workers

Desde otro terminal ejecutamos ``ssh -i ~/.ssh/docker-swarm-key ec2-user@WOKER_1_IP`` para conectarnos a la IP de nuestro primer worker.

Veréis que el comando anterior nos ha devuelto lo siguiente:

```bash
docker swarm join --token SWMTKN-1-161qkd1gwvbhio8lhvv5pc79agdr31azh1d253oe1ed2dg6oku-60eyb1ltfl0w29sjw6ypfft95 10.0.6.24:2377
```

Esto es justamente lo que ejecutaremos en los worker-nodes para que se unan al swarm. Así que nos conectamos uno tras otro a todos los workers y los vamos uniendo al swarm.

Ahora nos conectamos al manager y ejecutamos

``sudo docker node ls``

Si todo ha ido bien deberíamos ver todas las máquinas unidas al swarm:

```bash
ec2-user@ip-10-0-6-24 ~]$ sudo docker node ls
ID                            HOSTNAME                     STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
kp06yf7lxqi63oltcvkq37g0n *   ip-10-0-6-24.ec2.internal    Ready               Active              Leader              19.03.6-ce
1m3rrv0qgrpoxx204cc2mihnj     ip-10-0-6-70.ec2.internal    Ready               Active                                  19.03.6-ce
4u5hkp93i7jrfj6bxote6yytz     ip-10-0-8-173.ec2.internal   Ready               Active                                  19.03.6-ce
o1104qg0pmp3hqxi5ljvi1h9c     ip-10-0-11-10.ec2.internal   Ready               Active                                  19.03.6-ce
```
## Smoke test

Ahora haremos un pequeño smoke-test y desplegaremos un contenedor de nginx y veremos si podemos acceder. 

Ejecutamos ``docker service create --name web --replicas 4 --publish published=80,target=80 nginx`` y validamos con ``docker service ps web``.

Si todo ha ido bien deberías ver:
```bash
[ec2-user@ip-10-0-6-24 ~]$ docker service ps web
ID                  NAME                IMAGE               NODE                         DESIRED STATE       CURRENT STATE            ERROR               PORTS
a9e5koctwvt8        web.1               nginx:latest        ip-10-0-6-70.ec2.internal    Running             Running 14 seconds ago                       
8jn3vk8osdp7        web.2               nginx:latest        ip-10-0-6-24.ec2.internal    Running             Running 18 seconds ago                       
548guimgr2dk        web.3               nginx:latest        ip-10-0-8-173.ec2.internal   Running             Running 13 seconds ago                       
sjmylyn9ajlp        web.4               nginx:latest        ip-10-0-11-10.ec2.internal   Running             Running 18 seconds ago       
```

Ahora podemos visitar la DNS de nuestro balanceador de carga y deberíamos poder ver los contenedores de nginx vivos :)
> La DNS la encontraréis en [/terraform/swarm_members/swarmec2.tfvars](../../terraform/swarm_members/swarmec2.tfvars)

## EJERCICIOS

1. Escribir un script que tenga como entrada el archivo /terraform/swarm_members/swarmec2.tfvars y que se conecte automáticamente a cada una de las instancia y ejecute los comandos necesarios.
2. Modificar los provisioners de terraform para que hagan lo mismo que en el punto 1.

