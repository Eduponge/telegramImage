#!/bin/bash

# Geração do screenshot
# Comando para gerar o screenshot

# Comando para crop centralizado usando ImageMagick
convert powerbi_screenshot.png -crop 600x374+100+113 powerbi_screenshot.png

# Envio da imagem para o Telegram
# Comando para enviar a imagem