import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Item {
    id: configRoot

    QtObject {
        id: unidWeatherValue
        property var value
    }

    QtObject {
        id: locationOrMaxMin
        property var value
    }

    signal configurationChanged

    property alias cfg_temperatureUnit: unidWeatherValue.value
    property alias cfg_locOrMaxMin: locationOrMaxMin.value
    property alias cfg_latitudeC: latitude.text
    property alias cfg_longitudeC: longitude.text
    property alias cfg_useCoordinatesIp: autamateCoorde.checked

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
        ComboBox {
            textRole: "text"
            valueRole: "value"
            Kirigami.FormData.label: i18n("Info In second Bar:")
            id: valueForSizeFont
            model: [
                {text: i18n("Location"), value: 1},
                {text: i18n("Max and Min"), value: 2},
            ]
            onActivated: locationOrMaxMin.value = currentValue
            Component.onCompleted: currentIndex = indexOfValue(locationOrMaxMin.value)
        }
    }
}
