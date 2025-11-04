/*
    SPDX-FileCopyrightText: zayronxio
    SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick 2.12
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    property string codeleng: ((Qt.locale().name)[0]+(Qt.locale().name)[1])
    property bool formato12Hour: plasmoid.configuration.hourFormat
    property bool visibleTxt: Plasmoid.configuration.activeText

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    function desktoptext(languageCode) {
        const translations = {
            "es": "son las",         // Spanish
            "en": "it is",           // English
            "hi": "यह",              // Hindi
            "fr": "il est",          // French
            "de": "es ist",          // German
            "it": "sono le",         // Italian
            "pt": "são",             // Portuguese
            "ru": "сейчас",          // Russian
            "zh": "现在是",           // Chinese (Mandarin)
            "ja": "今",              // Japanese
            "ko": "지금은",           // Korean
            "nl": "het is"           // Dutch
        };

        // Return the translation for the language code or default to English if not found
        return translations[languageCode] || translations["en"];
    }

    FontLoader {
    id: milk
    source: "../fonts/Milkshake.ttf"
    }
    FontLoader {
    id: metro
    source: "../fonts/Metropolis-Black.ttf"
    }

          fullRepresentation: RowLayout {
              Layout.minimumWidth: 150
              Layout.minimumHeight: 150
              Layout.preferredWidth: Layout.minimumWidth
              Layout.preferredHeight: Layout.minimumHeight
    Rectangle {
        id: base
        Layout.preferredWidth: (parent.height < parent.width) ? parent.height : parent.width
        Layout.preferredHeight: (parent.height < parent.width) ? parent.height : parent.width
        color: Plasmoid.configuration.customColor
        radius: parent.height/2
        opacity: Plasmoid.configuration.opacity/100
        anchors.centerIn: parent
        layer.enabled: true
             layer.effect: OpacityMask {
             maskSource: mask
             invert: true
             }
    }
    Column {
        id: mask
        width: base.width
        height: base.height
        anchors.centerIn: parent
        visible: false
            Text {
                text: desktoptext(codeleng)
                color: visibleTxt ? "black" : "transparent"
                font.pixelSize: hora.font.pixelSize /1.7
                font.family: milk.name
                anchors.bottom: parent.bottom
                anchors.bottomMargin: mask.height/2 + hora.height/3
                anchors.left: parent.left
                anchors.leftMargin: hora.implicitWidth < parent.width*.9 ? (parent.width - hora.implicitWidth)/2 : parent.width * 0.09
            }
            Text {
                id: hora
                color: "blue"

                // Crear una instancia de la fecha una vez para reutilizarla
                property var currentDate: new Date()

                // Formato de 12 horas, con AM/PM si es necesario
                text: formato12Hour
                ? (currentDate.getHours() === 0
                ? "12:" + Qt.formatDateTime(currentDate, "mm")  // Si es medianoche, mostrar 12
                : (currentDate.getHours() <= 12
                ? currentDate.getHours() + ":" + Qt.formatDateTime(currentDate, "mm")  // Mostrar hora en la mañana o exactamente a las 12
                : (currentDate.getHours() - 12) + ":" + Qt.formatDateTime(currentDate, "mm")))  // Restar 12 para PM
                : Qt.formatDateTime(currentDate, "HH:mm")  // Formato de 24 horas

                font.pixelSize: Math.min(mask.width, mask.height) * 0.32
                anchors.centerIn: parent
                font.family: metro.name
            }
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    hora.currentDate = new Date()
                    hora.text = formato12Hour
                    ? (hora.currentDate.getHours() === 0
                    ? "12:" + Qt.formatDateTime(hora.currentDate, "mm")  // Si es medianoche, mostrar 12
                    : (hora.currentDate.getHours() <= 12
                    ? hora.currentDate.getHours() + ":" + Qt.formatDateTime(hora.currentDate, "mm")  // Mostrar hora en la mañana o exactamente a las 12
                    : (hora.currentDate.getHours() - 12) + ":" + Qt.formatDateTime(hora.currentDate, "mm")))  // Restar 12 para PM
                    : Qt.formatDateTime(hora.currentDate, "HH:mm")  // Formato de 24 horas
                }
            }
    }
     }
}

