#!/bin/bash

# Directorio origen (donde están las carpetas)
ORIGEN="$(pwd)"

# Directorio destino
DESTINO="$HOME"

echo "Copiando carpetas al home: $DESTINO"

for carpeta in .config .icons .local .var; do
    if [ -d "$ORIGEN/$carpeta" ]; then
        cp -rfv "$ORIGEN/$carpeta/." "$DESTINO/$carpeta/"
        echo "✓ $carpeta copiada"
    else
        echo "✗ $carpeta no encontrada en $ORIGEN"
    fi
done
clear
# Copiar tema SDDM
echo "✓ Copiar SDDM Tema Utterly-Nord a /usr/share/sddm/themes/"
if [ -d "$ORIGEN/sddm/themes/Utterly-Nord" ]; then
    sudo cp -rfv "$ORIGEN/sddm/themes/Utterly-Nord" /usr/share/sddm/themes/
    echo "✓ Tema Utterly-Nord copiado a /usr/share/sddm/themes/"
else
    echo "✗ Carpeta sddm/themes/Utterly-Nord no encontrada en $ORIGEN"
fi

echo "¡Listo!"
