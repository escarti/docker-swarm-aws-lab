# Continuous Delivery en Fargate

Ahora vamos a desplegar un clúster de Fargate y usar GitAction para hacer CD

## Infraestructura

## Crear el clúster y la tarea con Terraform

En primer lugar hemos de desplegar el clúster de fargate y destruir la infraestructura de swarm. Para eso simplemente ponemos la variable `swarm_mode  = false` y en el directorio de terraform ejecutamos `terraform apply`

### 1. Ruta a la imagen de docker-hub

Ahora podéis usar en el archivo tfvars que ya teníamos e introducimos en la variable `image         = "MY_IMAGE_DOCKER_HUB_REPO"` vuestra ruta de docker-hub de la imagen.
Además ponemos la variable `fargate_mode  = true` para que se construya el módulo de fargate.

### 2. Crear el clúster

En el directorio de terraform ejecutamos `terraform apply`.

Una vez terminado tanto en el archivo ``fargate.tfvars`` como en los outputs encontraréis la DNS pública del balanceador de carga. Por ejemplo:

``alb_dns = "superman-alb-fargate-1604704153.us-east-1.elb.amazonaws.com"``

## Adaptar GitHub Actions

Ahora que hemos destruido nuestro clúster de Swarm deberemos adaptar nuestro workflow para añadir los pasos a seguir para desplegar en Fargate.

Dado que las condiciones "if" no aceptan secrets en GitHub actions debemos hacer un workaround y usar variables de entorno. El step modificado queda así:

```
    - name: Deploy new image on docker-swarm
      if: ${{ github.ref == 'refs/heads/master' && env.DEPLOY_MODE == 'swarm' }}
      uses: fifsky/ssh-action@master
      with:
        command: |
          docker service update --image ${{ github.repository  }}:${{ env.CURR_TAG }} webapp
        host: ${{ secrets.HOST }}
        user: ec2-user
        key: ${{ secrets.PRIVATE_KEY}}
      env:
        DEPLOY_MODE: ${{ secrets.DEPLOY_MODE }}
```

Ahora crearemos un job diferente para los deploys de fargate.

```
  deploy_fargate:
    needs: build-test-push
    runs-on: ubuntu-latest
```

Dado que los jobs pueden correr en diferentes máquinas deberemos volver a declarar las variables de entorno por si acaso.

```
    steps:

    - name: Set env TAG
      run: echo "CURR_TAG=sha-$(echo $GITHUB_SHA | cut -c 1-7)" >> $GITHUB_ENV

    - name: Set env DEPLOY_MODE
      run: echo "DEPLOY_MODE=${{ secrets.DEPLOY_MODE }}" >> $GITHUB_ENV
```    

Todos lo pasos tendrán un condicional para que sólo se ejecuten en la rama máster y en caso de que tenamos el modo de despliegue en 'fargate'

```
if: ${{ github.ref == 'refs/heads/master' && env.DEPLOY_MODE == 'fargate' }}
```

AWS tiene una documentación muy detallada de cómo usar GitHub actions para desplegar en Fargate [aquí](https://aws.amazon.com/blogs/opensource/github-actions-aws-fargate/)

En primer lugar añadimos el bloque que nos autenticará en AWS.

```
    - name: Configure AWS credentials from Test account
      if: ${{ github.ref == 'refs/heads/master' && env.DEPLOY_MODE == 'fargate' }}
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}
```

Como véis deberemos añadir los correspondientes secrets en el repo bajo Settings > Secrets:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION

Idealmente deberíamos tener nuestra "taks-definition" bajo control de versiones pero en este caso nos limitamos a bajar la última versión del clúster y adaptarla

```
    - name: Download task definition
      if: ${{ github.ref == 'refs/heads/master' && env.DEPLOY_MODE == 'fargate' }}
      run: |
        aws ecs describe-task-definition --task-definition ${{ env.ONWER_ID }}-sfw-task --query taskDefinition > task-definition.json
```

> EJERCICIO: Crear un repo que contenga exclusivamente nuestro task-definition.json y adaptar GitHub actions para que haga commit/push en ese repo cada vez que despleguemos un nuevo task-definition.json en nuestro clúster.

AWS tiene una acción que nos permite inyectar la nueva imágen en un task-definition.json

```
    - name: Fill in the new image ID in the Amazon ECS task definition
      if: ${{ github.ref == 'refs/heads/master' && env.DEPLOY_MODE == 'fargate' }}
      id: task-def
      uses: aws-actions/amazon-ecs-render-task-definition@v1
      with:
        task-definition: task-definition.json
        container-name: simple_flask_web
        image: ${{ github.repository  }}:${{ env.CURR_TAG }}
```

Acto seguido desplegamos la imágen:

```
    - name: Deploy Amazon ECS task definition
      if: ${{ github.ref == 'refs/heads/master' && env.DEPLOY_MODE == 'fargate' }}
      uses: aws-actions/amazon-ecs-deploy-task-definition@v1
      with:
        task-definition: ${{ steps.task-def.outputs.task-definition }}
        service: ${{ env.ONWER_ID }}-sfw-service
        cluster: ${{ env.ONWER_ID }}-ecs-cluster
        wait-for-service-stability: true
```

Como véis aquí necesitamos saber el owner id así que incluimos:

```
env:
  ONWER_ID: $VUESTRO_OWNER_ID
```

justo después `on` y antes de `jobs`

### Test final

Para probar que todo funciona volvemos a cambiar el mensaje de nuestro "Hello World" con el que queramos para verificar que los despliegues se están realizando con éxito.

## FIN

Con esto finaliza la práctica de Fargate. Espero que lo hayáis disfrutado.

