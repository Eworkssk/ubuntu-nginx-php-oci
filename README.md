# eworkssk/ubuntu-nginx-php-oci

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/eworkssk/ubuntu-nginx-php-oci?label=Current%20release&sort=semver&style=for-the-badge)
![Docker Stars](https://img.shields.io/docker/stars/eworkssk/ubuntu-nginx-php-oci?style=for-the-badge)
![Docker Pulls](https://img.shields.io/docker/pulls/eworkssk/ubuntu-nginx-php-oci?style=for-the-badge)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/eworkssk/ubuntu-nginx-php-oci/latest?style=for-the-badge)

Simple to use, yet stable and performant Docker image providing PHP 7.4 with OCI8 extension behind NGINX reverse proxy running the latest version of Ubuntu 20.04 LTS.

**Need PHP 8.0 CLI? Check out our new image: https://github.com/Eworkssk/docker-php-cli**

## :rocket: Getting Started
### :package: Downloading the image
Install the latest stable version of the image:
```
docker pull eworkssk/ubuntu-nginx-php-oci:stable
```
...or download specifically the current stable version:
```
docker pull eworkssk/ubuntu-nginx-php-oci:2.1.2
```

### :cyclone: Using the image 
The image can be used standalone with `docker run` command, or with `docker-compose`, in Swarm mode,...
```
docker run -p 80:80 -v my_website/src:/var/www/html eworkssk/ubuntu-nginx-php-oci:2.1.2
```


### :wrench: Configuration
Image is using multiple environment variables to allow an easy setup of the most common stuff.

##### `$ENVIRONMENT`
_default: development_ \
Specified the type of environment for your application. This variable is available in PHP.

##### `$DOCKER_IMAGE`
_default: eworkssk/ubuntu-nginx-php-oci_ \
Full name of this Docker image!

##### `$DOCKER_IMAGE_EDITION`
_default: default_ \
Edition of this Docker image. For example: `default`.

##### `$DOCKER_IMAGE_VERSION`
_default: 2.1.2_ \
Version of this Docker image you are currently running.

##### `$PHP_FPM_POOL_LISTEN`
_default: /run/php/php${PHP_VERSION}-fpm.sock_ \
Socket file location or IP address on which PHP service will listen for incoming requests. You won't have to change this setting in most cases.

##### `$PHP_FPM_POOL_STATUS`
_default: /status_ \
URL location of PHP's status page. This value is used by health check to determine if PHP service is up and running properly. 

##### `$HEALTHCHECK_LOG_FILE`
_default: /var/log/healthcheck.log_ \
Location of the health check log file.

#### Other "read-only" configuration variables
If you decide to change any these variables, do it on your own risk:
`$NGINX_VERSION`, `$SUPERVISOR_VERSION`, `$PHP_VERSION`, `$PHP_REDIS_VERSION`, `$IMAGICK_VERSION`, `$PHP_IMAGICK_VERSION`, `$ORACLE_INSTANTCLIENT_VERSION`, `$PHP_OCI_VERSION`, `$GHOSTSCRIPT_VERSION`, `$POPPLER_UTILS_VERSION`, `$LOGROTATE_VERSION`


### :heartbeat: Health checking
Our image provides simple health checking script already built-in and enabled by default. You can find health check scripts in `healthcheck` folder. Default configuration:
- runs every 5 seconds with 5 second timeout
- max. 3 retries before marking container as unhealthy
- container staring period is 15 seconds
- both services are checked (Nginx + PHP)
- uses default Docker's `healthcheck` command
- all failures are logged into file, location of the log file can be configured with `HEALTHCHECK_LOG_FILE` environment variable 


### :lock: SSL
SSL is supported and can be configured in Nginx configuration files as usual.


### :ok_hand: Recommendations
We strongly recommend using server with at least 1GB of RAM, alternatively you can lower the value of `pm.max_children` found in `configs/php/pool.conf` to suit your needs. For large websites and powerful servers, we suggest you to do the opposite :wink:

From our experience, running multiple instances of this image even on a single server (for example with Swarm mode), can have very positive effect on service availability. This minimizes the outages in case of container failure (more likely to happen with older/legacy applications).


## :balance_scale: License 
This Docker image was released under the MIT license and you can use it as you wish :sparkles:. For more information check LICENSE.md file. \
For more information about Oracle Instantclient and Oracle Instantclient SDK licenses, check the attached Oracle Instantclient and Oracle Instantclient SDK ZIP files.