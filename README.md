# MOSS_Frontend

Frontend for the MOSS chatbot

## Deployment Guide
### With Docker
A Dockerfile exists at the root directory and can be used to build a docker image, with `nginx` being the web server.

Nginx configuration file `nginx.conf` is also located at the root directory. If you need to override the default configuration, you can modify this file.

### Without Docker
If you want to use Canvaskit, you might want to optimize the web application for China's network environment.
- Refer to [this](https://github.com/flutter/flutter/issues/70101) issue to bring canvaskit and fonts offline (or move them to CDN).

We recommend using `html` as the web renderer.

Build with `flutter build web --release --web-renderer <canvaskit|html|auto>`.
