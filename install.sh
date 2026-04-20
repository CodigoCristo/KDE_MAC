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

echo "¡Listo!"
