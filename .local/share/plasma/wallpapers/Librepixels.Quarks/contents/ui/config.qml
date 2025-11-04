/*
 *   SPDX-FileCopyrightText: 2025 adolfo <adolfo@librepixels.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQControls

Kirigami.FormLayout {
    id: root

    property alias cfg_gradientStart: gradientStart.color
    property alias cfg_gradientEnd: gradientEnd.color
    property alias cfg_quarksColor: quarksColor.color

    KQControls.ColorButton {
        id: gradientStart
        Kirigami.FormData.label: i18n('Gradient start:')
        showAlphaChannel: true
    }
    KQControls.ColorButton {
        id: gradientEnd
        Kirigami.FormData.label: i18n('Gradient end:')
        showAlphaChannel: true
    }
    Label {

    }
    KQControls.ColorButton {
        id: quarksColor
        Kirigami.FormData.label: i18n('Quarks color:')
        showAlphaChannel: true
    }
}
