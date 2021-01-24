# Infraestructura de terraform con AWS

Para testear docker swarm en AWS debemos empezar por el networking:

## Networking

Para este laboratorio en particular vamos a desplegar una red con:

- 1 VPC - [vpc.tf](../../terraform/network/vpc.tf) 
- hasta 3 redes públicas - [subnets.tf](../../terraform/network/subnets.tf) 
- hasta 3 redes privadas - [subnets.tf](../../terraform/network/subnets.tf) 
- 1 nat gateway en cada red pública - [gateways.tf](../../terraform/network/gateways.tf)
- 1 internet gateway para el VPC - [gateways.tf](../../terraform/network/gateways.tf)
- 3 tablas de enrutado privadas (1 por cada nat gateway) - [route_tables.tf](../../terraform/network/route_tables.tf)
- 1 tabla de enrutado pública - [route_tables.tf](../../terraform/network/route_tables.tf)

### Desplegando la infraestructura para el clúster de SWARM

En primer lugar necesitaremos una clave ssh para conectarnos a las instancias. La generaremos usando este comando:

``ssh-keygen -f ~/.ssh/docker-swarm-key``

1. Para desplegar la infraestructura navegamos a la carpenta /terraform/
 
    ``cd /terraform/``

 2. A continuación usamos el archivo terraform.tfvars.example para crear nuestro propio archivo de variables

    ``cp terraform.tfvars.example terraform.tfvars``

3. Ahora editaremos la información con el contenido de las variables que queramos. Es especialmente importante que el ``aws_profile`` coincida con el vuestro. También es muy recomendable que la variable ``owner_id`` tenga un nombre único para poder identificar vuestros recursos.  (p.ej "batman" o "superman")

    > Si no habéis configurado el perfíl de AWS, ahora es el momento 
        ``aws configure --profile=docker-swarm-aws``


4. Ahora iniciamos terraform con ``terraform init``
5. Hacemos un ``terraform plan`` y si todo está correcto un ``terraform apply``

El terraform apply desplegará un clúster de SWARM:

1. Una instancia maestra
2. Una instancia worker por cada subred pública que tengamos
3. Un balanceador de carga que apunte a todas las instancias en el puerto 80 a través de una única DNS
4. Los security groups y demás recursos necesarios

> Nota: Las alojamos en las redes públicas por simplificar. Esto no sería adecuado para un set-up de producción.

## FIN

Con esto damos por finalizada esta parte de la práctica. Ya tenemos la infraestructura necesaria para crear nuestro swarm y empezar a desplegar contenedores.

## Ejercicios extra

1. Modificar la infraestructura para alojar las instancias en las subredes privadas
    > Hará falta un recurso extra para poder configurarlo todo :)    