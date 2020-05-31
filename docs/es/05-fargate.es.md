# Continuous Delivery en Fargate

Ahora vamos a desplegar un clúster de Fargate y usar GitAction para hacer CD

## Destruir

En primer lugar destruimos la infraestructura de Docker Swarm ejectutando ``make swarm_destroy``

## Crear el clúster y la tarea con Terraform

### 1. Ruta a la imagen de docker-hub

En primer lugar podéis usar el archivo ``terraform/fargate/terraform.tfvars.example`` y generar un archivo tfvars propio mediante ``cp terraform.tfvars.example terraform.tfvars``

En ese archivo podréis configurar la ruta a la imagen de vuestro fork del repo de simple-flask-web. Sustituid ``"escarti/simple-flask-web:latest"`` por vuestra ruta de docker-hub.

### 2. Crear el clúster

Ahora ejecutamos ``make deploy_fargate`` para crear nuestro clúster y lanzar las tareas y el servicio.

Una vez terminado tanto en el archivo ``fargate.tfvars`` como en los outputs encontraréis la DNS pública del balanceador de carga. Por ejemplo:

``alb_dns = "superman-alb-fargate-1604704153.us-east-1.elb.amazonaws.com"``

## Adaptar GitHub Actions

Ahora que hemos destruido nuestro clúster de Swarm deberemos adaptar nuestro workflow para que no intente desplegar, puesto que dará error.

Partimos de este paso:

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

Para ahorrarnos tener que tocar el código manualmente en el futuro, vamos a introducir una variable de despligue con la que identificaremos si queremos desplegar en fargate o en swarm.

Nos vamos a www.github.com y en el fork de nuestro repo en Settings > Secrets > Add Secret añadimos:

``DEPLOY_MODE`` con el contenido ``fargate``

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
      run: echo ::set-env name=CURR_TAG::sha-$(echo $GITHUB_SHA | cut -c 1-7)

    - name: Set env DEPLOY_MODE
      run: echo ::set-env name=DEPLOY_MODE::${{ secrets.DEPLOY_MODE }}
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

### Test final

Para probar que todo funciona volvemos a cambiar el mensaje de nuestro "Hello World" con el que queramos para verificar que los despliegues se están realizando con éxito.

## FIN

Con esto finaliza la práctica de Fargate. Espero que lo hayáis disfrutado.

