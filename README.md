# develop Odoo in docker

### introduction
Coding Debuging Odoo in Docker

### Install the runtime environment

#### Ubuntu
- install docker 

ref. https://docs.docker.com/engine/install/ubuntu/

- install docker compose

#### MAC 
- install docker for desktop

ref. https://docs.docker.com/desktop/mac/install/

- install docker compose


#### Windows 
- install docker for desktop

ref. https://docs.docker.com/desktop/windows/install/

- install docker compose


 **Important**

. Place the Odoo source code in the root directory, that is, the entire directory of the Odoo source code containing `odoo-bin

. Unofficial Addons are stored in the root directory addons


### run odoo

1. Clone this repository to a local directory, for example odoo-docker
2. Execute the following command to run Odoo

```bash

cd odoo-docker
docker-compose -p odoo15 up -d

```
3. Docker will pull the relevant images and run the project
4. Browser open http://localhost:8000



### FAQ

1. #### Docker reports an error Get https://registry-1.docker.io/v2/: unable to connect to HTTP proxy 127.0.0.1:1080, in this case you need to use the Docker image registry
 
  Adjust the docker configuration to add the Chinese local registrar image，
  ```json
  {
    "registry-mirrors": [
      "https://registry.docker-cn.com",
      "https://docker.mirrors.ustc.edu.cn"
    ]
  }
  ```


