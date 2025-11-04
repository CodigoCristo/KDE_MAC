import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.11
import org.kde.kirigami as Kirigami

Item {
    id: configRoot

    QtObject {
        id: unidWeatherValue
        property var value
    }

    signal configurationChanged

    property alias cfg_temperatureUnit: unidWeatherValue.value
    property alias cfg_latitudeC: latitude.text
    property alias cfg_longitudeC: longitude.text
    property alias cfg_useCoordinatesIp: autamateCoorde.checked
    property alias cfg_boldfonts: boldfont.checked

    Kirigami.FormLayout {
        width: parent.width

        ComboBox {
            textRole: "text"
            valueRole: "value"
            id: positionComboBox
            Kirigami.FormData.label: i18n("Temperature Unit:")
            model: [
                {text: i18n("Celsius (°C)"), value: 0},
                {text: i18n("Fahrenheit (°F)"), value: 1},
            ]
            onActivated: unidWeatherValue.value = currentValue
            Component.onCompleted: currentIndex = indexOfValue(unidWeatherValue.value)
        }

        CheckBox {
            id: autamateCoorde
            Kirigami.FormData.label: i18n('Use IP location')
        }
        TextField {
            id: latitude
            visible: !autamateCoorde.checked
            Kirigami.FormData.label: i18n("Latitude:")
            width: 200
        }
        TextField {
            id: longitude
            visible: !autamateCoorde.checked
            Kirigami.FormData.label: i18n("Longitude:")
            width: 200
        }
        CheckBox {
            id: boldfont
            Kirigami.FormData.label: i18n('Bold font:')
        }
    }
}
