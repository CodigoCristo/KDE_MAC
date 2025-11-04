import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Image {
    id: root

    property url urlwallpaper: ""
    Plasma5Support.DataSource {

        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd) {
            connectSource(cmd)
        }
        signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: executable
        onExited: {
            var output = stdout.trim();
            if (exitCode === 0 && (output.endsWith(".png") || output.endsWith(".jpg") || output.endsWith(".jpeg"))) {
                urlwallpaper = output;
                source = urlwallpaper;
            }
        }
    }

    source: ""

    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0
        TextMetrics {
            id: units
            text: "M"
            property int gridUnit: boundingRect.height
            property int largeSpacing: units.gridUnit
            property int smallSpacing: Math.max(2, gridUnit/4)
        }

        Image {
            id: logo
            property real size: units.gridUnit * 8

            anchors.centerIn: parent

            source: "images/logo.svg"

        }

        Image {
            id: busyIndicator
            y: parent.height - (parent.height - logo.y) / 2 - height/2
            anchors.horizontalCenter: parent.horizontalCenter
            source: "images/loading-00.svg"
            sourceSize.height: units.gridUnit * 1.5
            sourceSize.width: units.gridUnit * 1.5
            RotationAnimator on rotation {
                id: rotationAnimator
                from: 0
                to: 360
                duration: 800
                loops: Animation.Infinite
            }
        }

    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 1000
        easing.type: Easing.InOutQuad
    }
    Component.onCompleted: {
        executable.exec("bash $HOME/.local/share/plasma/look-and-feel/AppleSplash/contents/lib/find.sh")
    }
}
