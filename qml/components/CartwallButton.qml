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
import QtQuick.Controls 2.2 as QtControls
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3
import QtMultimedia 5.12

import MediaManager 1.0

LomiriShape {
    id: cartwallButton

    property string text
    property string audioSource
    property bool loops
    readonly property var mediaPlayer: audioController.playerFor(index)
    property bool playing: mediaPlayer != null && (mediaPlayer.playbackState == MediaPlayer.PlayingState || mediaPlayer.playbackState == MediaPlayer.PausedState || mediaPlayer.loopStarted)
    
    MouseArea {
        anchors.fill: parent

        onClicked: {
            if (!MediaManager.fileExists(audioSource)) {
                console.log("File missing, ignoring playback:", audioSource)
                return
            }

            if (audioController.playerFor(index) == null) {
                if (stopOthers) {
                    stopAll()
                }
                audioController.play(index, loops, text, audioSource)
                return
            }

            if (mediaPlayer.playbackState === MediaPlayer.PausedState) {
                mediaPlayer.play()
                return
            }

            if (audioController.playing(index) == true) {
                audioController.stop(index)
            }            
        }

        onPressAndHold: {
            if (!cartwallButton.playing) {
                pageStack.push(
                    Qt.resolvedUrl("../pages/EditPage.qml"),
                    {
                        tempIndex: index,
                        tempName: text,
                        tempFile: audioSource,
                        tempButtonColor: buttonColor,
                        tempLoop: loops,
                        tempStopOthers: stopOthers
                    }
                )
            }
        }
    }

    source: ShaderEffectSource {
        anchors.fill: parent

        sourceItem: background

        Rectangle {
            id: background
            
            anchors.fill: parent
            
            color: buttonColor
        }
    }

    Label {
        id: textLabel

        width: parent.width - units.gu(1)

        anchors.centerIn: parent

        text: cartwallButton.text
        color: "#FFFFFF"

        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        maximumLineCount: 3
        elide: Text.ElideRight
    }

    Row {
        height: units.gu(1.5)
        spacing: units.gu(0.75)

        anchors {
            right: parent.right
            rightMargin: units.gu(1)
            top: parent.top
            topMargin: units.gu(1)
        }

        Icon {
            id: stopOthersIcon

            width: units.gu(1.5)
            height: units.gu(1.5)

            visible: stopOthers ? true : false

            name: "media-playback-stop"

            color: textLabel.color
        }

        Icon {
            id: loopIcon

            width: units.gu(1.5)
            height: units.gu(1.5)

            visible: cartwallButton.loops ? true : false

            name: "media-playlist-repeat"

            color: textLabel.color
        }
    }

    Label {
        id: positionLabel

        visible: playing
        
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            bottom: progressBar.top
            bottomMargin: units.gu(0.5)
        }

        text: mediaPlayer.position < 0 ? "0:00" : millisecToPlaytime(mediaPlayer.position)
        textSize: Label.XSmall
        color: "#FFFFFF"
    }

    Label {
        id: remainingLabel

        visible: playing
        
        anchors {
            right: parent.right
            rightMargin: units.gu(1)
            bottom: progressBar.top
            bottomMargin: units.gu(0.5)
        }

        text: mediaPlayer.position < 0 ? "-0:00" : "-" + millisecToPlaytime(mediaPlayer.duration - mediaPlayer.position)
        textSize: Label.XSmall
        color: "#FFFFFF"
    }

    QtControls.ProgressBar {
        id: progressBar

        visible: playing

        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            bottom: parent.bottom
            bottomMargin: units.gu(1)
        }

        from: 0
        to: mediaPlayer.duration < 0 ? 1 : mediaPlayer.duration
        value: mediaPlayer.position < 0 ? 0 : mediaPlayer.position

        contentItem: Item {
            id: contentItem
            clip: true

            Rectangle {
                implicitWidth: (progressBar.indeterminate ? 0.25 : progressBar.position) * contentItem.width
                implicitHeight: progressBar.height

                color: lightenHex(buttonColor)
            }
        }

        background: Rectangle {
            implicitWidth: progressBar.Suru.units.gu(32)
            implicitHeight: progressBar.Suru.units.dp(3)

            x: progressBar.leftPadding
            y: progressBar.topPadding + (progressBar.availableHeight - height) / 2
            width: progressBar.availableWidth
            height: progressBar.Suru.units.dp(3)

            color: "#ffffff"
        }
    }

    Timer {
        id: blinkTimer

        interval: LomiriAnimation.SlowDuration
        repeat: true
        running: mediaPlayer.playbackState === MediaPlayer.PausedState

        onTriggered: {
            const opacity = positionLabel.opacity === 1.0 ? 0.4 : 1.0

            positionLabel.opacity = opacity
            remainingLabel.opacity = opacity
            progressBar.opacity = opacity
        }

        onRunningChanged: {
            if (!running) {
                positionLabel.opacity = 1.0
                remainingLabel.opacity = 1.0
                progressBar.opacity = 1.0
            }
        }
    }

    function lightenHex(hex) {
        hex = hex.replace("#","");
        
        const n = parseInt(hex, 16);
        let r = (n >> 16) & 0xff;
        let g = (n >> 8) & 0xff;
        let b = n & 0xff;

        r = Math.round(r + (255 - r) * 0.4);
        g = Math.round(g + (255 - g) * 0.4);
        b = Math.round(b + (255 - b) * 0.4);

        return "#" + ((1 << 24) | (r << 16) | (g << 8) | b).toString(16).slice(1).toUpperCase();
    }
}
