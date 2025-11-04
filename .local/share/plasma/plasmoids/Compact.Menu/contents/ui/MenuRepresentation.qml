/*
 *  SPDX-FileCopyrightText: zayronxio
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts 1.11
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.components 3.0 as PC3

import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.coreaddons 1.0 as KCoreAddons // kuser
//import org.kde.plasma.private.shell 2.0
import org.kde.plasma.private.sessions as Sessions
import org.kde.kwindowsystem 1.0
//import org.kde.kquickcontrolsaddons 2.0
//import org.kde.plasma.private.quicklaunch 1.0
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kcmutils as KCM
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Item{
    id: main
    property int menuPos: Plasmoid.configuration.displayPosition
    property int showApps: Plasmoid.configuration.viewUser ? 0 : 1

    property int sizeSideIcons: Plasmoid.configuration.sizeSideIcons

    onVisibleChanged: {
        root.visible = !root.visible
    }

    PlasmaExtras.Menu {
        id: contextMenu

        PlasmaExtras.MenuItem {
            action: Plasmoid.internalAction("configure")
        }
    }

    SoInfo {
        id: soInfo
        visible: false
    }

    Plasmoid.status: root.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    PlasmaCore.Dialog {
        id: root

        objectName: "popupWindow"
        flags: Qt.WindowStaysOnTopHint
        //flags: Qt.Dialog | Qt.FramelessWindowHint
        location: PlasmaCore.Types.Floating
        hideOnWindowDeactivate: true

        property int iconSize: Kirigami.Units.iconSizes.large
        property int cellSizeHeight: iconSize
                                     + Kirigami.Units.gridUnit * 2
                                     + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                                                     highlightItemSvg.margins.left + highlightItemSvg.margins.right))
        property int cellSizeWidth: cellSizeHeight

        property bool searching: (searchField.text != "")

        property bool showFavorites

        onVisibleChanged: {
            if (visible) {
                root.showFavorites = Plasmoid.configuration.showFavoritesFirst
                var pos = popupPosition(width, height);
                x = pos.x;
                y = pos.y;
                reset();
                animation1.start()
            }else{
                rootItem.opacity = 0
            }
        }

        onHeightChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        onWidthChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        function toggle(){
            main.visible =  !main.visible
        }


        function reset() {
            //searchField.text = "";

            if(showFavorites)
                globalFavoritesGrid.tryActivate(0,0)
            else
                mainColumn.visibleGrid.tryActivate(0,0)


        }

        function popupPosition(width, height) {
            var screenAvail = kicker.availableScreenRect;
            var screen = kicker.screenGeometry;
            var panelH = kicker.height
            var panelW = kicker.width
            var horizMidPoint = screen.x + (screen.width / 2);
            var vertMidPoint = screen.y + (screen.height / 2);
            var appletTopLeft = parent.mapToGlobal(0, 0);

            function calculatePosition(x, y) {
                return Qt.point(x, y);
            }

            if (menuPos === 0) {
                switch (plasmoid.location) {
                    case PlasmaCore.Types.BottomEdge:
                        var x = appletTopLeft.x < screen.width - width ? appletTopLeft.x : screen.width - width - 8;
                        var y = appletTopLeft.y - height - Kirigami.Units.gridUnit
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.TopEdge:
                        x = appletTopLeft.x < screen.width - width ? appletTopLeft.x + panelW - Kirigami.Units.gridUnit / 3 : screen.width - width;
                        y = appletTopLeft.y + kicker.height + Kirigami.Units.gridUnit
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.LeftEdge:
                        x = appletTopLeft.x + panelW + Kirigami.Units.gridUnit / 2;
                        y = appletTopLeft.y < screen.height - height ? appletTopLeft.y : appletTopLeft.y - height + iconUser.height / 2;
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.RightEdge:
                        x = appletTopLeft.x - width - Kirigami.Units.gridUnit / 2;
                        y = appletTopLeft.y < screen.height - height ? appletTopLeft.y : screen.height - height - Kirigami.Units.gridUnit / 5;
                        return calculatePosition(x, y);

                    default:
                        return;
                }
            } else if (menuPos === 2) {
                x = horizMidPoint - width / 2;
                y = screen.height - height - panelH - Kirigami.Units.gridUnit / 2;
                return calculatePosition(x, y);
            } else if (menuPos === 1) {
                x = horizMidPoint - width / 2;
                y = vertMidPoint - height / 2;
                return calculatePosition(x, y);
            }
        }

        FocusScope {
            id: rootItem
            Layout.minimumWidth:  Kirigami.Units.gridUnit*17
            Layout.maximumWidth:  minimumWidth
            Layout.minimumHeight: Kirigami.Units.gridUnit*32
            Layout.maximumHeight: minimumHeight
            focus: true


            KCoreAddons.KUser {   id: kuser  }



            OpacityAnimator { id: animation1; target: rootItem; from: 0; to: 1; easing.type: Easing.InOutQuad;  }

            Sessions.SessionManagement {
                id: sm
            }

            P5Support.DataSource {
                id: executable
                engine: "executable"
                connectedSources: []
                onNewData: {
                    var exitCode = data["exit code"]
                    var exitStatus = data["exit status"]
                    var stdout = data["stdout"]
                    var stderr = data["stderr"]
                    exited(sourceName, exitCode, exitStatus, stdout, stderr)
                    disconnectSource(sourceName)
                }
                function exec(cmd) {
                    if (cmd) {
                        connectSource(cmd)
                    }
                }
                signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
            }

            PlasmaExtras.Highlight  {
                id: delegateHighlight
                visible: false
                z: -1 // otherwise it shows ontop of the icon/label and tints them slightly
            }

            Kirigami.Heading {
                id: dummyHeading
                visible: false
                width: 0
                level: 5
            }

            TextMetrics {
                id: headingMetrics
                font: dummyHeading.font
            }

            Item {
                id : headingSvg
                width: parent.height + backgroundSvg.margins.bottom + backgroundSvg.margins.top
                //height:  root.cellSizeHeight * Plasmoid.configuration.numberRows  + Kirigami.Units.gridUnit * 2 + backgroundSvg.margins.bottom - 1 //<>+ paginationBar.height
                height: parent.width*.4 + backgroundSvg.margins.left
            }

            Item {
                id: backgroundPlasmoid
                width: parent.width + backgroundSvg.margins.left + backgroundSvg.margins.right
                height: parent.height + backgroundSvg.margins.top + backgroundSvg.margins.bottom
                visible: false
                KSvg.FrameSvgItem {
                    imagePath: "dialogs/background"
                    clip: true
                    width: parent.width
                    height: parent.height
                }
            }
            Rectangle {
                width: backgroundPlasmoid.width
                height: backgroundPlasmoid.height
                y:  - backgroundSvg.margins.top
                x: - backgroundSvg.margins.left
                color: "transparent"
                visible: true
                opacity: 0.5
                Rectangle {
                    id: baseGrid
                    width: parent.width - 54
                    height: parent.height
                    color: Kirigami.Theme.backgroundColor
                    Rectangle {
                        width: 1
                        height: parent.height
                        anchors.right: parent.right
                        color: "white"
                        opacity: 0.4
                    }
                    Rectangle {
                        width: 1
                        height: parent.height
                        anchors.right: parent.right
                        anchors.rightMargin: 1
                        color: "black"
                        opacity: 0.3
                    }
                }
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: backgroundPlasmoid
                }
            }


            RowLayout {
                id: rowSearchField
                width: backgroundPlasmoid.width*.8
                anchors{
                    bottom: parent.bottom
                    bottomMargin: Kirigami.Units.gridUnit*1
                    left: parent.left
                    leftMargin: (backgroundPlasmoid.width + backgroundSvg.margin.left)*.1 - backgroundSvg.margin.right
                }


                PC3.TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: i18n("Type here to search ...")
                    topPadding: 10
                    bottomPadding: 10
                    leftPadding: ((parent.width - width)/2) + Kirigami.Units.iconSizes.small*2
                    text: ""
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                    onTextChanged: {
                        runnerModel.query = text;
                    }

                    Keys.onPressed: (event)=> {
                                        if (event.key === Qt.Key_Escape) {
                                            event.accepted = true;
                                            if(root.searching){
                                                searchField.clear()
                                            } else {
                                                root.toggle()
                                            }
                                        }

                                        if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                                            event.accepted = true;
                                            if(root.showFavorites)
                                            globalFavoritesGrid.tryActivate(0,0)
                                            else
                                            mainColumn.visibleGrid.tryActivate(0,0)
                                        }
                                    }

                    function backspace() {
                        if (!root.visible) {
                            return;
                        }
                        focus = true;
                        text = text.slice(0, -1);
                    }

                    function appendText(newText) {
                        if (!root.visible) {
                            return;
                        }
                        focus = true;
                        text = text + newText;
                    }
                    Kirigami.Icon {
                        source: 'search'
                        anchors {
                            left: searchField.left
                            verticalCenter: searchField.verticalCenter
                            leftMargin: Kirigami.Units.smallSpacing * 2

                        }
                        height: Kirigami.Units.iconSizes.small
                        width: height
                    }

                }

                Item {
                    Layout.fillWidth: true
                }


            }


            Item {
                id: selectorAppsFavsOrAll
                width: baseGrid.width
                height: 30
                anchors.left: parent.left
                anchors.leftMargin: - backgroundSvg.margins.left
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.gridUnit
                Text {
                    height: parent.height
                    text: showApps === 1 ? "   All apps" : "   Pinned"
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                }
                Button {
                    height: parent.height
                    text: showApps === 0 ? " All apps" : "Pinned"
                    icon.source: showApps === 1 ? "arrow-left" : "arrow-right"
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    onClicked: {
                        var apps = showApps
                        showApps = apps === 0 ? 1 : 0
                    }
                }

            }
            //
            //
            //
            //
            //

            ItemGridView {
                id: globalFavoritesGrid
                visible: showApps === 0
                anchors {
                    top: selectorAppsFavsOrAll.bottom
                    topMargin: Kirigami.Units.gridUnit * .5
                }

                dragEnabled: true
                dropEnabled: true
                width: baseGrid.width - backgroundSvg.margins.left
                height: parent.height - Kirigami.Units.gridUnit * 4 - selectorAppsFavsOrAll.height - rowSearchField.height
                focus: true
                cellWidth:   root.width*.6
                cellHeight:  48
                iconSize:    32
                onKeyNavUp: searchField.focus = true
                Keys.onPressed:(event)=> {
                                   if(event.modifiers & Qt.ControlModifier ||event.modifiers & Qt.ShiftModifier){
                                       searchField.focus = true;
                                       return
                                   }
                                   if (event.key === Qt.Key_Tab) {
                                       event.accepted = true;
                                       searchField.focus = true
                                   }
                               }
            }
            /* zayron code*/
            /*
             *
             */

            Column {
                id: places
                width: 48
                height: parent.height
                anchors.right: parent.right
                anchors.rightMargin: - backgroundSvg.margins.right/2
                anchors.top: parent.top
                spacing: 16
                Rectangle {
                    id: maskavatar
                    height: parent.height*.75
                    width: height
                    radius: height/2
                    visible: false
                }
                Image {
                    id: avatar
                    source: kuser.faceIconUrl
                    height: 32
                    width: height
                    anchors.horizontalCenter: parent.horizontalCenter
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: maskavatar
                    }
                }

                ListModel {
                    id: userDirs
                    ListElement {
                        text: "Home"
                        icon: "user-home-symbolic"
                        command: "xdg-open $HOME"
                    }
                    ListElement {
                        text: "Documents"
                        icon: "folder-documents-symbolic"
                        command: "xdg-open $(xdg-user-dir DOCUMENTS)"
                    }
                    ListElement {
                        text: "Music"
                        icon: "folder-music-symbolic"
                        command: "xdg-open $(xdg-user-dir MUSIC)"
                    }
                    ListElement {
                        text: "Pictures"
                        icon: "folder-pictures-symbolic"
                        command: "xdg-open $(xdg-user-dir PICTURES)"
                    }
                    ListElement {
                        text: "Videos"
                        icon: "folder-videos-symbolic"
                        command: "xdg-open $(xdg-user-dir VIDEOS)"
                    }
                    ListElement {
                        text: "System Settings"
                        icon: "configure"
                        command: "systemsettings"
                    }
                    ListElement {
                        text: "About"
                        icon: "help-about-symbolic"
                        command: "soInfo.visible = true"
                    }
                }
                Column {
                    width: parent.width
                    height: parent.height

                    ListView {
                        id: listPlaces
                        model: userDirs
                        width: parent.width
                        height: parent.height
                        interactive: false
                        delegate: Component {
                            Item {
                                width: parent.width
                                height: 48 // Altura total del elemento
                                Column {
                                    width: 32
                                    height: 32
                                    anchors.horizontalCenter:  parent.horizontalCenter
                                    Kirigami.Icon {
                                        id: lefticon
                                        source: model.icon
                                        width: height
                                        isMask: Plasmoid.configuration.forceColor
                                        color: Kirigami.Theme.textColor
                                        height: Plasmoid.configuration.sizeSideIcons //22 // Altura del icono
                                        anchors.horizontalCenter:  parent.horizontalCenter
                                        visible: true
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: places.spacing
                                        color: "transparent"
                                    }
                                }
                                MouseArea {
                                    width: parent.width
                                    height: parent.height
                                    anchors.centerIn: parent
                                    onClicked: {
                                        if (model.text === "About") {
                                            soInfo.visible = true
                                        } else {
                                            executable.exec(model.command);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            //
            //
            //
            //
            //

            Item {
                id: shutdownIcon
                width: places.width
                height: 32
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit*1
                anchors.right: parent.right
                anchors.rightMargin: - backgroundSvg.margins.right/2

                Kirigami.Icon {
                    id: iconShutdown
                    source: "system-shutdown"
                    color: Kirigami.Theme.textColor
                    width: 32
                    height: 32
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    height: parent.height
                    width: parent.width
                    anchors.centerIn: parent
                    onClicked: {
                        sm.requestLogoutPrompt()
                    }
                }
            }

            //
            //
            //
            //
            //
            Item{
                id: mainGrids
                visible: !globalFavoritesGrid.visible

                anchors {
                    top: selectorAppsFavsOrAll.bottom
                    topMargin: Kirigami.Units.gridUnit * .5
                    //left: parent.left
                    //right: parent.right

                }

                width: baseGrid.width - backgroundSvg.margins.left
                height: parent.height - Kirigami.Units.gridUnit * 4 - selectorAppsFavsOrAll.height - rowSearchField.height

                Item {
                    id: mainColumn
                    //width: root.cellSize *  Plasmoid.configuration.numberColumns + Kirigami.Units.gridUnit
                    width: rootItem.width
                    height: root.cellSizeHeight * Plasmoid.configuration.numberRows

                    property Item visibleGrid: allAppsGrid

                    function tryActivate(row, col) {
                        if (visibleGrid) {
                            visibleGrid.tryActivate(row, col);
                        }
                    }

                    ItemGridView {
                        id: allAppsGrid

                        //width: root.cellSize *  Plasmoid.configuration.numberColumns + Kirigami.Units.gridUnit
                        width: baseGrid.width - backgroundSvg.margins.left
                        height: root.height - Kirigami.Units.gridUnit * 4 - selectorAppsFavsOrAll.height - rowSearchField.height
                        cellWidth:   root.width*.6
                        cellHeight:  48
                        iconSize:    32
                        enabled: (opacity == 1) ? 1 : 0
                        z:  enabled ? 5 : -1
                        dropEnabled: false
                        dragEnabled: false
                        opacity: root.searching ? 0 : 1
                        onOpacityChanged: {
                            if (opacity == 1) {
                                //allAppsGrid.scrollBar.flickableItem.contentY = 0;
                                mainColumn.visibleGrid = allAppsGrid;
                            }
                        }
                        onKeyNavUp: searchField.focus = true
                    }

                    ItemMultiGridView {
                        id: runnerGrid
                        width: baseGrid.width - backgroundSvg.margins.left
                        height: root.height - Kirigami.Units.gridUnit * 4 - selectorAppsFavsOrAll.height - rowSearchField.height
                        cellWidth:   root.width*.6
                        cellHeight:  48
                        enabled: (opacity == 1.0) ? 1 : 0
                        z:  enabled ? 5 : -1
                        model: runnerModel
                        grabFocus: true
                        opacity: root.searching ? 1.0 : 0.0
                        onOpacityChanged: {
                            if (opacity == 1.0) {
                                mainColumn.visibleGrid = runnerGrid;
                            }
                        }
                        onKeyNavUp: searchField.focus = true
                    }

                    Keys.onPressed: (event)=> {
                                        if(event.modifiers & Qt.ControlModifier ||event.modifiers & Qt.ShiftModifier){
                                            searchField.focus = true;
                                            return
                                        }
                                        if (event.key === Qt.Key_Tab) {
                                            event.accepted = true;
                                            searchField.focus = true
                                        } else if (event.key === Qt.Key_Backspace) {
                                            event.accepted = true;
                                            if(root.searching)
                                            searchField.backspace();
                                            else
                                            searchField.focus = true
                                        } else if (event.key === Qt.Key_Escape) {
                                            event.accepted = true;
                                            if(root.searching){
                                                searchField.clear()
                                            } else {
                                                root.toggle()
                                            }
                                        } else if (event.text !== "") {
                                            event.accepted = true;
                                            searchField.appendText(event.text);
                                            showApps = 1
                                        }
                                    }
                }
            }




            Keys.onPressed: (event)=> {
                                if(event.modifiers & Qt.ControlModifier ||event.modifiers & Qt.ShiftModifier){
                                    searchField.focus = true;
                                    return
                                }
                                if (event.key === Qt.Key_Escape) {
                                    event.accepted = true;
                                    if (root.searching) {
                                        reset();
                                    } else {
                                        root.visible = false;
                                    }
                                    return;
                                }

                                if (searchField.focus) {
                                    return;
                                }

                                if (event.key === Qt.Key_Backspace) {
                                    event.accepted = true;
                                    searchField.backspace();
                                }  else if (event.text !== "") {
                                    event.accepted = true;
                                    searchField.appendText(event.text);
                                }
                            }

        }

        function setModels(){
            globalFavoritesGrid.model = globalFavorites
            allAppsGrid.model = rootModel.modelForRow(0);
        }

        Component.onCompleted: {
            rootModel.refreshed.connect(setModels)
            reset();
            rootModel.refresh();
        }
    }


}
