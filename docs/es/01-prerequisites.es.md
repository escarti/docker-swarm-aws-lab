# 01. Pre-requisitos

Vamos a definir la infraestructura como código con terraform y desplegarla en AWS. Vamos a aprovisionar nuestras instancias usando Ansible, por lo que tendremos que instalar todos esos recursos.

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

2. Instala Ansible

    - MacOS:
        ```bash
        brew install ansible
        ```

    - Ubuntu:
        ``` bash
        sudo apt update
        sudo apt install software-properties-common
        sudo apt-add-repository --yes --update ppa:ansible/ansible
        sudo apt install ansible
        ```
    - Otros:
    [Visitar enlace](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

3. Instala terraform 0.12.24. Recomiendo usar [tfswitch](https://warrensbox.github.io/terraform-switcher/) para alternar entre versiones
 
    - MacOs:
        ```bash
        brew install warrensbox/tap/tfswitch
        tfswitch 0.12.24
        ```

    - Ubuntu
        ```bash
        sudo apt-get install wget unzip
        export VER="0.12.24"
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