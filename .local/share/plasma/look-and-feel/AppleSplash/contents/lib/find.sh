num=$(awk '/\[Containments\]/ {if (found) print containment; found=0} /formfactor=0/ {found=1} /\[Containments\]\[([0-9]+)\]/ {containment = gensub(/.*\[Containments\]\[([0-9]+)\].*/, "\\1", "g")}' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
)

fle=$(awk '/\[Containments\]\['"$num"'\]\[Wallpaper\]\[org\.kde\.image\]\[General\]/ {found=1; print; next}
     found && /^\[/ {found=0} found {print}' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" | grep -E '\bImage\b' | sed 's/Image=//g')

# Verificar si fle es un directorio
if [ -d "$fle" ]; then
    # Buscar la imagen de menor peso en el directorio
    fle=$(find "$fle" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) -printf "%s %p\n" | sort -n | awk '{print $2}' | head -n 1)
fi

# Si fle está vacío, buscar en kdeglobals
if [ -z "$fle" ]; then
    lookAndFeel=$(awk -F'=' '/^LookAndFeelPackage=/ {print $2; exit}' "$HOME/.config/kdeglobals")

    # Verificar si se encontró un LookAndFeelPackage
    if [ -n "$lookAndFeel" ]; then
        fle=$(awk -F'=' '/^Image=/ {print $2; exit}' "$HOME/.local/share/plasma/look-and-feel/$lookAndFeel/contents/defaults")

        # Verificar si el path de imagen en fle es un directorio
        if [ -d "$HOME/.local/share/wallpapers/$fle/contents" ]; then
            # Buscar la imagen de menor peso en el directorio de wallpapers
            fle=$(find "$HOME/.local/share/wallpapers/$fle/contents" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) -printf "%s %p\n" | sort -n | awk '{print $2}' | head -n 1)
        fi
    fi
fi

echo "$fle"




