# eworkssk/ubuntu-nginx-php-oci

> :bangbang: We are currently in the process of writing documentation and stabilizing the next version of the Docker image. Documentation in this file might be either heavily outdated or not yet usable. Please, come back in a few days! :blush:

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/eworkssk/ubuntu-nginx-php-oci?label=Current%20release&sort=semver&style=for-the-badge)
![Docker Stars](https://img.shields.io/docker/stars/eworkssk/ubuntu-nginx-php-oci?style=for-the-badge)
![Docker Pulls](https://img.shields.io/docker/pulls/eworkssk/ubuntu-nginx-php-oci?style=for-the-badge)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/eworkssk/ubuntu-nginx-php-oci/latest?style=for-the-badge)

Simple to use, yet stable and performant Docker image providing PHP 7.4 with OCI8 extension behind NGINX reverse proxy running the latest version of Ubuntu 20.04 LTS.

*The image will be now regularly updated and tested-through every 2-3 months*

:information_source: If you don't need the PHP OCI8 extension, you can use our `base` image build. \
:mag_right: Check out also `ssh2` and `ffmpeg` versions of the image.

## Getting Started :racing_car:
### Downloading image
We always provide 2 versions of the image: beta and stable. Beta is always available a few days before the actual stable release, so there is really no point of using it!
```
docker pull eworkssk/ubuntu-nginx-php-oci:stable
```
...or download specifically the current stable version:
```
docker pull eworkssk/ubuntu-nginx-php-oci:2.0.0
```

## License 
This Docker image was released under the MIT license and you can use it as you wish :sparkles:. For more information check LICENSE.md file. \
For more information about Oracle Instantclient and Oracle Instantclient SDK licenses, check the attached Oracle Instantclient and Oracle Instantclient SDK ZIP files.