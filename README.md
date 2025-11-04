# KDE Plasma Theme Mac Ventura

![KDE_MAC.png](KDE_MAC.png)

Dotfiles para transformar Arch Linux con KDE Plasma en un entorno estilo macOS Ventura.

## Requisitos Previos

Debes tener **KDE Plasma instalado** en Arch Linux. Si aún no lo tienes:

```bash
sudo pacman -S plasma-meta kde-applications sddm
sudo systemctl enable sddm
```

## Actualiza el sistema
```bash
sudo pacman -Syu
yay -Syu
```

## Instalación Automática

```bash
git clone https://github.com/CodigoCristo/KDE_MAC.git
cd KDE_MAC
chmod +x Mac_KDE.sh
./Mac_KDE.sh
```

Después de ejecutar el script, **reinicia tu sesión** para aplicar todos los cambios.

## Instalación Manual

Si prefieres hacerlo paso a paso:

### 1. Clonar el repositorio
```bash
git clone https://github.com/CodigoCristo/KDE_MAC.git
cd KDE_MAC
```

### Crear las carpetas
```bash
mkdir -p ~/.config
mkdir -p ~/.local/share/{plasma/look-and-feel,plasma/desktoptheme,icons,color-schemes}
```

### 2. Instalar Klassy
```bash
yay -S klassy
```

### 3. Instalar tema Sumac
```bash
git clone https://github.com/doncsugar/sumac-theme.git
cd sumac-theme/plasma-styles
./genthemes.sh
cp -r output/sumac-day-plasma ~/.local/share/plasma/desktoptheme/
cp -r output/sumac-night-plasma ~/.local/share/plasma/desktoptheme/

cd ../icon-packs
./genthemes.sh
cp -r output/Sumac-Day ~/.local/share/icons/
cp -r output/Sumac-Night ~/.local/share/icons/
cd ../..
```

### 4. Instalar esquemas de color Flat Remix
```bash
git clone https://github.com/daniruiz/flat-remix-kde/
cd flat-remix-kde/color-schemes
cp *.colors ~/.local/share/color-schemes/
cd ../..
```

### 5. Instalar efectos KWin
```bash
yay -S kwin-effects-forceblur kwin-scripts-forceblur
```

### 6. Copiar configuraciones
```bash
cp -r .config/* ~/.config/
cp -r .local/* ~/.local/
```

### 7. Configurar SDDM
```bash
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
```

### 8. Actualizar directorios de usuario
```bash
sudo pacman -S xdg-user-dirs
xdg-user-dirs-update --force
```

Reinicia tu sesión para aplicar los cambios.
