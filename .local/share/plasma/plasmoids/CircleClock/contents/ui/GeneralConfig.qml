import QtQuick
import Qt.labs.platform
import QtQuick.Controls
import QtQuick.Layouts 1.11

Item {
    id: configRoot

    signal configurationChanged

    property alias cfg_opacity: porcetageOpacity.value
    property alias cfg_customColor: colorDialog.color
    property alias cfg_hourFormat: horsFormat.checked
    property alias cfg_activeText: activeText.checked

    ColorDialog {
        id: colorDialog
    }

    ColumnLayout {
        spacing: units.smallSpacing * 2

        GridLayout{
            columns: 2
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Opacity:")
                horizontalAlignment: Text.AlignRight
            }

            SpinBox{
                id: porcetageOpacity

                from: 30
                to: 100
                stepSize: 10
                // suffix: " " + i18nc("pixels","px.")
            }
            Label {
                Layout.minimumWidth: root.width/2
                horizontalAlignment: Label.AlignRight
                text: i18n("Color:")
            }
            Rectangle {
                id: colorhex
                color: colorDialog.color
                border.color: "#B3FFFFFF"
                border.width: 1
                width: 64
                radius: 4
                height: 24
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        colorDialog.open()
                    }
                }
            }
            Label {
                Layout.minimumWidth: root.width/2
            }
            CheckBox {
                id: horsFormat
                text: i18n("12 Hour Format")
            }
            Label {
                Layout.minimumWidth: root.width/2
            }
            CheckBox {
                id: activeText
                text: i18n("Active Text:")
            }
        }
}

}
