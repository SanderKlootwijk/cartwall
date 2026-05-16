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

import QtQuick 2.7
import Lomiri.Components 1.3
import QtMultimedia 5.4

import MediaManager 1.0

LomiriShape {
    id: cartwallButton

    property string text
    property string audioSource
    property bool loops

    Connections {
        target: root
        onStopAll: {
            mediaPlayer.stop()
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            if (!MediaManager.fileExists(audioSource)) {
                console.log("File missing, ignoring playback:", audioSource)
                return
            }

            if (mediaPlayer.playbackState != MediaPlayer.PlayingState) {
                mediaPlayer.play()
            } else {
                mediaPlayer.stop()
            }
        }
        
        onPressAndHold: {
            pageStack.push(
                Qt.resolvedUrl("../pages/EditPage.qml"),
                {
                    tempIndex: index,
                    tempName: text,
                    tempFile: audioSource,
                    tempButtonColor: buttonColor,
                    tempLoop: loops
                }
            )
        }
    }

    source: ShaderEffectSource {
        anchors.fill: parent

        sourceItem: mediaPlayer.playbackState == 1 ? progressBar : background

        ProgressBar {
            id: progressBar
            
            anchors.fill: parent

            minimumValue: 0
            maximumValue: mediaPlayer.duration
            value: mediaPlayer.position
        }

        Rectangle {
            id: background

            anchors.fill: parent

            color: buttonColor
        }
    }

    Label {
        width: parent.width - units.gu(0.5)

        anchors.centerIn: parent
        
        text: cartwallButton.text
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    Icon {
        id: duckIcon

        width: units.gu(2)
        height: units.gu(2)

        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            top: parent.top
            topMargin: units.gu(1)
        }
        
        visible: cartwallButton.duck ? true : false

        name: "audio-speakers-symbolic"
        
        color: "white"
    }

    Icon {
        id: loopIcon

        width: units.gu(2)
        height: units.gu(2)

        anchors {
            right: parent.right
            rightMargin: units.gu(1)
            top: parent.top
            topMargin: units.gu(1)
        }
        
        visible: cartwallButton.loops ? true : false

        name: "media-playlist-repeat"
        
        color: "white"
    }

    MediaPlayer {
        id: mediaPlayer

        loops: cartwallButton.loops ? MediaPlayer.Infinite : 0

        source: cartwallButton.audioSource
    }
}