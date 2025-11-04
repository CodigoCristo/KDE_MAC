# KDE Plasma Theme Mac Ventura

![KDE_MAC.png](KDE_MAC.png)

Dotfiles para transformar Arch Linux con KDE Plasma en un entorno estilo macOS Ventura.

## Instalación Automática

```bash
chmod +x Mac_KDE.sh
./Mac_KDE.sh
```

Después de ejecutar el script, **reinicia tu sesión** para aplicar todos los cambios.

## Instalación Manual

Si prefieres hacerlo paso a paso:

### 1. Instalar Klassy
```bash
yay -S klassy
```

### 2. Instalar tema Sumac
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
```

### 3. Instalar esquemas de color Flat Remix
```bash
git clone https://github.com/daniruiz/flat-remix-kde/
cd flat-remix-kde/color-schemes
cp *.colors ~/.local/share/color-schemes/
```

### 4. Instalar efectos KWin
```bash
yay -S kwin-effects-forceblur kwin-scripts-forceblur
```

### 5. Copiar configuraciones
```bash
cp -r .config/* ~/.config/
cp -r .local/* ~/.local/
```

### 6. Configurar SDDM
```bash
sudo sed -i 's/^Current=.*$/Current=MacVentura-Dark/' /etc/sddm.conf.d/kde_settings.conf
```

### 7. Actualizar directorios de usuario
```bash
yay -S xdg-user-dirs
xdg-user-dirs-update --force
```

Reinicia tu sesión para aplicar los cambios.