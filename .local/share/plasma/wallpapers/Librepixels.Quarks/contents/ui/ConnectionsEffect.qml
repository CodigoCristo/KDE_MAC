import QtQuick
import QtQuick.Shapes
import org.kde.plasma.plasmoid
import QtQuick.Controls

Rectangle {
    id: connectionsRoot
    color: "transparent"
    clip: false // Permite que las conexiones y puntos salgan del área

    property int numPoints: 125
    property real movementRangeMin: 0.15
    property real movementRangeMax: 0.38
    property real connectionThreshold: 36
    property real animationSpeed: 0.6
    property int pointSize: 2
    property color lineColor: root.configuration.quarksColor

    property int maxConnections: 190

    Item {
        id: container
        anchors.fill: parent

        Repeater {
            id: pointRepeater
            model: connectionsRoot.numPoints
            delegate: Rectangle {
                width: connectionsRoot.pointSize
                height: connectionsRoot.pointSize
                radius: width / 2
                color: lineColor

                property real angle: Math.random() * 2 * Math.PI
                property real rand: Math.random()
                property real pointRadius: Math.pow(rand, 0.65) * (Math.min(container.width, container.height) / 2)
                property real centerX: container.width/2 + Math.cos(angle) * pointRadius
                property real centerY: container.height/2 + Math.sin(angle) * pointRadius

                property real moveRadius: (connectionsRoot.movementRangeMin +
                Math.random() * (connectionsRoot.movementRangeMax - connectionsRoot.movementRangeMin))
                * (Math.min(container.width, container.height) / 2)

                property real dx: (Math.random() - 0.5) * connectionsRoot.animationSpeed
                property real dy: (Math.random() - 0.5) * connectionsRoot.animationSpeed

                x: centerX
                y: centerY
            }
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = connectionsRoot.lineColor;
            ctx.lineWidth = 1;

            var nodes = [];
            for (var i = 0; i < pointRepeater.count; ++i) {
                var p = pointRepeater.itemAt(i);
                nodes.push({ x: p.x + p.width/2, y: p.y + p.height/2 });
            }

            var connectionCount = 0; // 🔹 contador de conexiones

            for (var i = 0; i < nodes.length; ++i) {
                for (var j = i+1; j < nodes.length; ++j) {
                    if (connectionCount >= connectionsRoot.maxConnections)
                        break; // 🔹 ya alcanzamos el límite

                        var d = Math.hypot(nodes[i].x - nodes[j].x, nodes[i].y - nodes[j].y);
                    if (d < connectionsRoot.connectionThreshold) {
                        ctx.globalAlpha = Math.max(0.2, 1.0 - d / connectionsRoot.connectionThreshold);
                        ctx.beginPath();
                        ctx.moveTo(nodes[i].x, nodes[i].y);
                        ctx.lineTo(nodes[j].x, nodes[j].y);
                        ctx.stroke();
                        connectionCount++; // 🔹 sumamos una conexión
                    }
                }
                if (connectionCount >= connectionsRoot.maxConnections)
                    break;
            }
        }

        Timer {
            interval: 15; running: true; repeat: true
            onTriggered: {
                const margin = 12;
                const width = container.width;
                const height = container.height;
                for (var i = 0; i < pointRepeater.count; ++i) {
                    var p = pointRepeater.itemAt(i);

                    p.x += p.dx;
                    p.y += p.dy;

                    if (p.x < margin) p.dx += (margin - p.x) * 0.07;
                    if (p.x > width - margin - p.width) p.dx -= (p.x - (width - margin - p.width)) * 0.07;
                    if (p.y < margin) p.dy += (margin - p.y) * 0.07;
                    if (p.y > height - margin - p.height) p.dy -= (p.y - (height - margin - p.height)) * 0.07;

                    p.dx += (Math.random() - 0.5) * 0.08;
                    p.dy += (Math.random() - 0.5) * 0.08;

                    var speed = Math.hypot(p.dx, p.dy);
                    if (speed > connectionsRoot.animationSpeed * 1.5) {
                        p.dx *= 0.9;
                        p.dy *= 0.9;
                    }

                    var dist = Math.hypot(p.x - p.centerX, p.y - p.centerY);
                    if (dist > p.moveRadius) {
                        var angle = Math.atan2(p.y - p.centerY, p.x - p.centerX);
                        p.dx -= Math.cos(angle) * 0.5;
                        p.dy -= Math.sin(angle) * 0.5;
                    }
                }
                canvas.requestPaint();
            }
        }
    }
}
