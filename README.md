# openchat_frontend

Frontend for the MOSS chatbot

## Deployment Guide
### 1. Prepare dependencies
`flutter pub run flutter_native_splash:create`

### 2. Build
You might want to optimize the web application for China's network environment.
- Refer to [this](https://github.com/flutter/flutter/issues/70101) issue to bring canvaskit and fonts offline.

Then build with `flutter build <platform>`.
