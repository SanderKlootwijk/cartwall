/*
 * Copyright (C) 2026  Sander Klootwijk
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * cartwall is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import QtMultimedia 5.4
import "../components"

Page {
    id: mainPage

    property alias bottomEdge: bottomEdge
    property bool editMode: false

    readonly property var mediaPlayer: audioController.playerFor(lastPlayerIndex)

    header: PageHeader {
        id: mainPageHeader
        title: i18n.tr("Cartwall")
        subtitle: settings.currentCartwallPrettyName

        trailingActionBar {
            numberOfSlots: 4

            actions: [
                Action {
                    text: i18n.tr("Settings")
                    iconName: "settings"
                    enabled: !editMode
                    onTriggered: pageStack.push(settingsPage)
                },
                Action {
                    text: i18n.tr("Files")
                    iconName: "folder-symbolic"
                    enabled: !editMode
                    onTriggered: {
                        pageStack.push(filePage)
                    }
                },
                Action {
                    text: i18n.tr("Edit")
                    iconName: "edit"
                    onTriggered: {
                        if (editMode) {
                            editMode = false
                        }
                        else {
                            stopAll()
                            editMode = true
                        }
                    }
                }
            ]
        }
    }

    Rectangle {
        z: 1
        
        width: parent.width
        height: units.gu(1)

        anchors {
            top: mainPageHeader.bottom
            horizontalCenter: parent.horizontalCenter
        }

        color: theme.palette.normal.background
    }
    
    GridView {
        id: cartwallView

        cacheBuffer: (cartwallView.count / columns) * cellHeight

        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                duration: LomiriAnimation.SnapDuration
                easing: LomiriAnimation.StandardEasing
            }
        }

        Timer {
            interval: 400
            running: true
            onTriggered: cartwallView.opacity = 1
        }

        Label {
            anchors.centerIn: parent

            width: parent.width - units.gu(4)

            visible: cartwallView.count == 0 && !editMode

            opacity: visible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: LomiriAnimation.SnapDuration
                    easing: LomiriAnimation.StandardEasing
                }
            }

            text: i18n.tr("This cartwall is empty. Enter edit mode to add new buttons.")

            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        clip: true
        interactive: true
        model: cartwallModel

        cellWidth: width / columns
        cellHeight: cellWidth

        property int columns: root.width / units.gu(13)
        property real buttonSize: (root.width - (columns * units.gu(1)) - units.gu(1)) / columns

        anchors {
            top: mainPageHeader.bottom
            topMargin: units.gu(0.5)
            bottom: controlsView.top
            bottomMargin: units.gu(0.5)
            left: parent.left
            leftMargin: units.gu(0.5)
            right: parent.right
            rightMargin: units.gu(0.5)
        }

        delegate: Item {
            width: cartwallView.cellWidth
            height: cartwallView.cellHeight

            property int fromIndex: index
            property real dragX: 0
            property real dragY: 0
            property bool dragging: false

            Item {
                id: content
                anchors.centerIn: parent
                width: cartwallView.buttonSize
                height: cartwallView.buttonSize
                x: dragX
                y: dragY
                z: dragging ? 1000 : 0

                CartwallButton {
                    id: cartwallButton
                    anchors.fill: parent
                    enabled: !editMode
                    text: name
                    audioSource: file
                    loops: loop

                    scale: {
                        if (editMode == true && dragging == false) {
                            0.95
                        }
                        else {
                            1.0
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: LomiriAnimation.SnapDuration
                            easing: LomiriAnimation.StandardEasing
                        }
                    }

                    opacity: {
                        if (editMode == true && dragging == false) {
                            0.75
                        }
                        else {
                            1.0
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: LomiriAnimation.SnapDuration
                            easing: LomiriAnimation.StandardEasing
                        }
                    }

                    rotation: 0

                    SequentialAnimation on rotation {
                        id: simpleWiggle

                        loops: Animation.Infinite
                        running: editMode && !dragging
                        
                        onRunningChanged: {
                            if (!running) {
                                cartwallButton.rotation = 0
                            }
                        }

                        NumberAnimation {
                            to: -1
                            duration: LomiriAnimation.FastDuration
                            easing: LomiriAnimation.StandardEasing
                        }
                        NumberAnimation {
                            to: 0.75
                            duration: LomiriAnimation.SlowDuration
                            easing: LomiriAnimation.StandardEasing
                        }
                        NumberAnimation {
                            to: -0.5
                            duration: LomiriAnimation.FastDuration
                            easing: LomiriAnimation.StandardEasing
                        }
                        NumberAnimation {
                            to: 0
                            duration: LomiriAnimation.SlowDuration
                            easing: LomiriAnimation.StandardEasing
                        }
                    }
                }
            }

            MouseArea {
                id: dragArea

                anchors.fill: parent

                enabled: editMode

                property point startPos

                onPressAndHold: {
                    cartwallView.interactive = false
                    dragging = true
                    fromIndex = index
                    startPos = Qt.point(mouse.x, mouse.y)
                }

                pressAndHoldInterval: LomiriAnimation.SnapDuration

                onPositionChanged: {
                    if (!editMode || !dragging) {
                        return
                    }

                    dragX = mouse.x - startPos.x
                    dragY = mouse.y - startPos.y

                    var pos = mapToItem(cartwallView.contentItem, mouse.x, mouse.y)

                    var toIndex = cartwallView.indexAt(pos.x, pos.y)

                    if (toIndex >= 0 && toIndex !== fromIndex) {
                        cartwallModel.move(fromIndex, toIndex, 1)
                        fromIndex = toIndex
                    }
                }

                onReleased: {
                    if (!dragging) {
                        return
                    }

                    cartwallView.interactive = true
                    dragging = false
                    dragX = 0
                    dragY = 0

                    saveOrder()
                }
            }
        }
    }

    Item {
        id: newButton

        visible: editMode && cartwallModel.count < 50

        opacity: visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: LomiriAnimation.SnapDuration
                easing: LomiriAnimation.StandardEasing
            }
        }

        width: cartwallView.cellWidth
        height: cartwallView.cellHeight

        x: cartwallView.x + (cartwallModel.count % cartwallView.columns) * cartwallView.cellWidth
        y: cartwallView.y + Math.floor(cartwallModel.count / cartwallView.columns) * cartwallView.cellHeight - cartwallView.contentY
        
        LomiriShape {
            anchors.centerIn: parent

            width: cartwallView.buttonSize
            height: cartwallView.buttonSize

            scale: 0.95

            color: theme.palette.normal.base

            Icon {
                width: units.gu(2.5)
                height: units.gu(2.5)

                anchors.centerIn: parent
                
                name: "add"
                color: theme.palette.normal.baseText
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    pageStack.push(
                        Qt.resolvedUrl("../pages/EditPage.qml"),
                        {
                            tempIndex: -1,
                            tempName: "",
                            tempFile: "",
                            tempButtonColor: "#62237c",
                            tempLoop: false,
                            tempStopOthers: false
                        }
                    )
                }
            }
        }
    }

    Rectangle {
        z: 1
        
        width: parent.width
        height: units.gu(1)

        anchors {
            bottom: controlsView.top
            horizontalCenter: parent.horizontalCenter
        }

        color: theme.palette.normal.background
    }

    Rectangle {
        z: 10
        
        id: controlsView

        width: parent.width
        height: cartwallView.buttonSize / 2 + units.gu(2)

        anchors {
            bottom: bottomEdgeItem.top
            horizontalCenter: parent.horizontalCenter
        }

        color: theme.palette.normal.background

        Rectangle {
            width: parent.width
            height: units.dp(1)

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            color: theme.palette.normal.base
        }

        Label {
            visible: !audioController.allPlayersStopped

            width: parent.width - units.gu(2)
            
            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                bottom: mediaPlayerSlider.top
                bottomMargin: units.gu(0.5)
            }

            text: lastPlayerText
        }

        Slider {
            id: mediaPlayerSlider

            enabled: !editMode
            visible: !audioController.allPlayersStopped

            height: units.gu(2)

            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                right: pauseButton.left
                rightMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }

            onPressedChanged: {
                if (!pressed) {
                    mediaPlayer.seek(mediaPlayerSlider.value)
                }
            }

            live: true

            function formatValue(v) {
                return millisecToPlaytime(v)
            }

            minimumValue: 0
            maximumValue: mediaPlayer.duration
            value: progressBar.value

            Connections {
                target: progressBar
                
                onValueChanged: {
                    if (!mediaPlayerSlider.pressed) {
                        mediaPlayerSlider.value = progressBar.value
                    }
                }
            }
        }

        ProgressBar {
            id: progressBar

            opacity: 0

            minimumValue: 0
            value: mediaPlayer.position
            maximumValue: mediaPlayer.duration

            Connections {
                target: mediaPlayer

                onValueChanged: {
                    value = mediaPlayer.position
                }
            }
        }

        Item {
            visible: !audioController.allPlayersStopped

            width: mediaPlayerSlider.width
            height: units.gu(2)

            anchors {
                top: mediaPlayerSlider.bottom
                topMargin: units.gu(0.5)
                horizontalCenter: mediaPlayerSlider.horizontalCenter
            }

            Label {
                id: playbacktime
                
                anchors {
                    left: parent.left
                }
                
                text: millisecToPlaytime(progressBar.value)
            }

            Label {
                id: fullduration
                
                anchors {
                    right: parent.right
                }
                
                text: millisecToPlaytime(progressBar.maximumValue)
            }
        }

        Button {
            id: pauseButton

            enabled: !editMode && !audioController.allPlayersStopped

            width: cartwallView.buttonSize / 2
            height: cartwallView.buttonSize / 2

            anchors {
                right: stopAllButton.left
                rightMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }

            Icon {
                width: units.gu(2.5)
                height: units.gu(2.5)

                anchors.centerIn: parent
                
                name: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                color: "#ffffff"
            }

            onClicked: {
                if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                    mediaPlayer.pause()
                }
                else {
                    mediaPlayer.play()
                }
            }
        }

        Button {
            id: stopAllButton

            enabled: !editMode

            width: cartwallView.buttonSize / 2
            height: cartwallView.buttonSize / 2

            anchors {
                right: parent.right
                rightMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }
            
            color: theme.palette.normal.negative

            Icon {
                width: units.gu(2.5)
                height: units.gu(2.5)

                anchors.centerIn: parent
                
                name: "media-playback-stop"
                color: "#ffffff"
            }

            onClicked: stopAll()
        }
    }

    Item {
        id: bottomEdgeItem

        enabled: !editMode
        
        width: parent.width
        height: units.gu(4)
        
        anchors.bottom: parent.bottom
        
        // Put grey line on top of bottomEdgeItem
        Rectangle {
            width: parent.width
            height: units.gu(0.1)
            color: theme.palette.normal.base
        }

        MouseArea {
            anchors.fill: parent

            onClicked: bottomEdge.commit()
        }
    }
    
    BottomEdge {
        id: bottomEdge

        enabled: !editMode

        hint.iconName: "go-up"

        contentComponent: CartwallsPage {
            width: root.width
            height: root.height
        }
    }
}