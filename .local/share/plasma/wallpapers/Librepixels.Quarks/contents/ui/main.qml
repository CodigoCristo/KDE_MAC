/*
 *  SPDX-FileCopyrightText: 2025 zayronxio <adolfo@librepixels.com>
 *
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import org.kde.plasma.plasmoid

WallpaperItem {
    id: root

    property color firstColor: root.configuration.gradientStart
    property color endColor: root.configuration.gradientEnd
    // Propiedad para controlar la opacidad del ruido
    property real noiseOpacity: 0.5
    // Propiedad para activar/desactivar el ruido
    property bool noiseEnabled: true

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: firstColor } // Puedes cambiar los colores
            GradientStop { position: 1.0; color: endColor }
        }
    }

    // Capa de ruido procedural
    ShaderEffect {
        anchors.fill: parent
        property real noiseOpacity: root.noiseOpacity // Ajusta opacidad del ruido
        visible: noiseEnabled

        fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform lowp float noiseOpacity;

        // Simple pseudo-random noise basado en coordenadas
        highp float random(vec2 co) {
        highp float a = 12.9898;
        highp float b = 78.233;
        highp float c = 43758.5453;
        highp float dt= dot(co.xy ,vec2(a,b));
        highp float sn= mod(dt, 3.14);
        return fract(sin(sn) * c);
    }

    void main() {
    float n = random(qt_TexCoord0.xy * 512.0); // Ajusta 512 para la escala del ruido
    gl_FragColor = vec4(vec3(n), noiseOpacity);
    }
    "
    }
    ConnectionsEffect {
        width: 320
        height: 320
        anchors.centerIn:  parent
    }
}

