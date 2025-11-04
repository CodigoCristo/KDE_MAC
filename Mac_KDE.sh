#!/bin/bash
set -e  # Detener en caso de error

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

# Función para imprimir mensajes
print_msg() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Crear directorios necesarios
print_msg "Creando directorios necesarios..."
mkdir -p ~/.config
mkdir -p ~/.local/share/{plasma/look-and-feel,plasma/desktoptheme,icons,color-schemes}

# Instalar dependencias
print_msg "Instalando Klassy..."
yay -S klassy --noansweredit --noconfirm --needed
print_success "Klassy instalado"

# Instalar tema Sumac
print_msg "Clonando repositorio Sumac..."
if [ -d "sumac-theme" ]; then
    rm -rf sumac-theme
fi
git clone --quiet https://github.com/doncsugar/sumac-theme.git

print_msg "Generando temas Plasma de Sumac..."
cd sumac-theme/plasma-styles
./genthemes.sh
cp -r output/sumac-day-plasma ~/.local/share/plasma/desktoptheme/
cp -r output/sumac-night-plasma ~/.local/share/plasma/desktoptheme/
print_success "Temas Plasma de Sumac instalados"

print_msg "Generando iconos de Sumac..."
cd ../icon-packs
./genthemes.sh
cp -r output/Sumac-Day ~/.local/share/icons/
cp -r output/Sumac-Night ~/.local/share/icons/
cd ../..
print_success "Iconos de Sumac instalados"

# Limpiar repositorio clonado
rm -rf sumac-theme

# Instalar esquemas de color Flat Remix
print_msg "Descargando esquemas de color Flat Remix..."
if [ -d "flat-remix-kde" ]; then
    rm -rf flat-remix-kde
fi
git clone --quiet https://github.com/daniruiz/flat-remix-kde/
cd flat-remix-kde/color-schemes
cp *.colors ~/.local/share/color-schemes/
cd ../..
rm -rf flat-remix-kde
print_success "Esquemas de color Flat Remix instalados"

# Instalar efectos KWin
print_msg "Instalando efectos KWin Force Blur..."
yay -S kwin-effects-forceblur kwin-scripts-forceblur --noansweredit --noconfirm --needed
print_success "Efectos KWin instalados"

# Copiar configuraciones desde carpeta MAC
print_msg "Copiando configuraciones de .config..."
cp -r .config/* ~/.config/
print_success "Configuraciones de .config copiadas"

print_msg "Copiando configuraciones de .local..."
cp -r .local/* ~/.local/
print_success "Configuraciones de .local copiadas"

# Configurar SDDM
print_msg "Configurando SDDM..."
SDDM_CONFIG="/etc/sddm.conf.d/kde_settings.conf"

# Crear directorio si no existe
sudo mkdir -p /etc/sddm.conf.d/

if [ ! -f "$SDDM_CONFIG" ]; then
    # Si el archivo no existe, crearlo con el contenido completo
    print_msg "Creando archivo de configuración SDDM..."
    sudo tee "$SDDM_CONFIG" > /dev/null <<'EOF'
[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot
Numlock=on

[Theme]
Current=MacVentura-Dark

[Users]
MaximumUid=60513
MinimumUid=1000
EOF
    print_success "Archivo SDDM creado con configuración completa"
else
    # Si el archivo existe, solo modificar las líneas necesarias
    sudo sed -i 's/^Current=.*$/Current=MacVentura-Dark/' "$SDDM_CONFIG"

    # Verificar si ya existe la línea Numlock=on
    if ! grep -q "^Numlock=on" "$SDDM_CONFIG"; then
        # Verificar si existe la sección [General]
        if grep -q "^\[General\]" "$SDDM_CONFIG"; then
            # Agregar Numlock=on después de la sección [General]
            sudo sed -i '/^\[General\]/a Numlock=on' "$SDDM_CONFIG"
        else
            # Agregar la sección [General] con Numlock=on al final
            echo -e "\n[General]\nNumlock=on" | sudo tee -a "$SDDM_CONFIG" > /dev/null
        fi
    fi
    print_success "Archivo SDDM actualizado"
fi

print_success "SDDM configurado"

# Instalar xdg-user-dirs
print_msg "Instalando xdg-user-dirs..."
yay -S xdg-user-dirs --noansweredit --noconfirm --needed
print_success "xdg-user-dirs instalados"
xdg-user-dirs-update --force

# Mensaje final
echo ""
print_success "¡Instalación completada!"
echo -e "${GREEN}Todos los temas han sido instalados correctamente.${NC}"
echo -e "${BLUE}Reinicia tu sesión para aplicar los cambios.${NC}"
