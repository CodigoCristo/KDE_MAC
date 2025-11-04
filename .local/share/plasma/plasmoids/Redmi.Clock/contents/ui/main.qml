import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid
import "components" as Components
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    width: 250
    height: 250

    property color colorPlasmoid: Plasmoid.configuration.colorHex
    Plasmoid.backgroundHints: "NoBackground"

    Components.WeatherData {
        id: weatherData
    }

    function getDate(type) {
        var value = type === "d" ? "dddd" : type === "m" ? "MMMM" : ""
        var date = new Date();
        var monthName = date.toLocaleString(Qt.locale(), value);
        return monthName;
    }

    FontLoader {
        id: quicksand
        source: "../fonts/Quicksand-Regular.otf"
    }

    function eliminteZero(a) {
        if (a[0] === '0') {
            if (a[1] > '0') {
                return a[1]
            } else {
                return a
            }
        } else {
            return a
        }
    }
    Column {
        id: wrapper
        width: firsText.width
        height: firsText.height*3
        anchors.centerIn: root
        Text {
            id: firsText
            width: root.width > root.height ? root.height : root.width
            height: width/3
            font.family: quicksand.name
            font.pixelSize: height*.8
            text: Qt.formatDateTime(new Date(), "h:mm");
            color: colorPlasmoid
        }
        Row {
            width: firsText.width
            height: firsText.height
            Row {
                id: date
                width: dayOfMont.implicitWidth + separ.implicitWidth + mont.implicitWidth
                height: firsText.height
                Text {
                    id: dayOfMont
                    width: date.width - separ.implicitWidth - mont.implicitWidth
                    height: parent.height
                    font.family: quicksand.name
                    font.pixelSize: height*.8
                    text: Qt.formatDateTime(new Date(), "dd");
                    color: colorPlasmoid
                }
                Text {
                    id: separ
                    width: date.width - dayOfMont.implicitWidth - mont.implicitWidth
                    height: parent.height
                    font.family: quicksand.name
                    font.pixelSize: height*.8
                    text: Qt.formatDateTime(new Date(), "/");
                    color: colorPlasmoid
                    opacity: 0.5
                }
                Text {
                    id: mont
                    width: date.width - dayOfMont.implicitWidth - separ.implicitWidth
                    height: parent.height
                    font.family: quicksand.name
                    font.pixelSize: height*.8
                    text:  eliminteZero(Qt.formatDateTime(new Date(), "MM"))
                    color: colorPlasmoid
                }
            }

            Text {
                id: day
                width: firsText.width - date.width
                height: firsText.height
                font.family: quicksand.name
                font.pixelSize: height*.3
                text: getDate("d").substring(0,3)
                topPadding : height*.14
                color: colorPlasmoid
                opacity: 0.5
            }
        }
        Row {
            width: firsText.width
            height: firsText.height
            Item {
                id: wrapperCurrentTemp
                width: currentTemp.implicitWidth
                height: currentTemp.implicitHeight
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    id: currentTemp
                    width: parent.width
                    height: parent.height
                    font.family: quicksand.name
                    font.pixelSize: firsText.height*.8
                    text: Math.round(weatherData.temperaturaActual) + "° "
                    color: colorPlasmoid
                }
            }

            Kirigami.Icon {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: firsText.height*.13
                source: weatherData.iconWeatherCurrent
                width: parent.height*.55
                height: width
                color: colorPlasmoid
            }
        }

    }
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            day.text = (Qt.formatDateTime(new Date(), "dddd"))[0]+(Qt.formatDateTime(new Date(), "dddd"))[1]+(Qt.formatDateTime(new Date(), "dddd"))[2]
            mont.text =  eliminteZero(Qt.formatDateTime(new Date(), "MM"))
            dayOfMont.text = Qt.formatDateTime(new Date(), "dd");
            firsText.text = Qt.formatDateTime(new Date(), "h:mm");
        }
    }
}
