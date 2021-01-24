# 01. Pre-requisitos

Vamos a definir la infraestructura como código con terraform y desplegarla en AWS.

1. Instala [AWS CLI](https://docs.aws.amazon.com/es_es/cli/latest/userguide/install-macos.html)

    - MacOS:
        ```bash
        brew install awscli
        ```
    - Ubuntu:
        ```bash
        sudo apt-get update
        sudo apt-get install awscli
        ```
    - Otros:
    [Visitar enlace](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

3. Instala terraform 0.14.4. Recomiendo usar [tfswitch](https://warrensbox.github.io/terraform-switcher/) para alternar entre versiones
 
    - MacOs:
        ```bash
        brew install warrensbox/tap/tfswitch
        tfswitch 0.14.4
        ```

    - Ubuntu
        ```bash
        sudo apt-get install wget unzip
        export VER="0.14.4"
        wget https://releases.hashicorp.com/terraform/${VER}/terraform_${VER}_linux_amd64.zip
        unzip terraform_${VER}_linux_amd64.zip
        sudo mv terraform /usr/local/bin/
        terraform --version
        curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
        ```

    - Otros:
        [Visita enlace](www.google.com)

4. Crea un perfil de aws con las credenciales de la cuenta que vas a usar para desplegar la infraestructura.

    ``aws configure --profile=docker-swarm-aws``

5. Se requiere cuenta de GitHub

6. Se requiere cuenta de DockerHub
