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
import QtMultimedia 5.12

MediaPlayer {
    property int index: -1
    property string playerText: ""
    property bool loop: false
    property int loopCount: 0
    property bool loopStarted: false
    property bool manuallyStopped: false

    notifyInterval: 75

    onPlaybackStateChanged: {
        if (playbackState === MediaPlayer.PlayingState) {
            manuallyStopped = false
            if (loopCount === 0) {
                audioController.playerStarted(this)
            }
        }
        else if (playbackState === MediaPlayer.StoppedState) {
            if (loop && !manuallyStopped) {
                loopCount++
                loopStarted = true
                Qt.callLater(function() {
                    if (loopStarted === true) {
                        seek(0)
                        play()
                        loopStarted = false
                    }
                })
                return
            }

            index = -1
            playerText = ""
            loop = false
            loopCount = 0
            loopStarted = false
            manuallyStopped = false

            audioController.playerStopped(this)
        }
        else if (playbackState === MediaPlayer.PausedState) {
            audioController.updateLastPlayer()
        }

        audioController.playersState()
    }
}