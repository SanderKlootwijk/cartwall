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
import Qt.labs.folderlistmodel 2.8
import Qt.labs.platform 1.0
import "../components"

import MediaManager 1.0

Page {
    id: filePage

    property bool selectionMode: false
    property var targetPage: null

    onVisibleChanged: previewPlayer.stop()

    header: PageHeader {
        id: filePageHeader
        title: i18n.tr("Files")

        leadingActionBar {
            actions: [
                Action {
                    visible: !selectionMode
                    text: i18n.tr("Back")
                    iconName: "back"
                    onTriggered: {
                        pageStack.pop()
                    }
                },
                Action {
                    visible: selectionMode
                    text: i18n.tr("Close")
                    iconName: "close"
                    onTriggered: {
                        selectionMode = false
                        pageStack.pop()
                    }
                }
            ]
        }

        trailingActionBar {
            actions: [
                Action {
                    text: i18n.tr("Import")
                    iconName: "add"
                    onTriggered: {
                        previewPlayer.stop()
                        filePicker.open()
                    }
                }
            ]
        }
    }

    FolderListModel {
        id: folderListModel

        folder: "file:///home/phablet/.local/share/cartwall.sanderklootwijk/Files"
    }

    ListView {
        id: folderListView

        anchors {
            fill: parent
            topMargin: filePageHeader.height
        }

        model: folderListModel

        Label {
            anchors.centerIn: parent

            width: parent.width - units.gu(4)

            visible: folderListView.count == 0

            text: i18n.tr("There are no audio files here yet. Tap + to import audio files.")

            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        delegate: ListItem {
            width: parent.width
            height: units.gu(6)

            leadingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        onTriggered: {
                            previewPlayer.stop()
                            MediaManager.deleteFile(fileUrl)
                        }
                    }
                ]
            }

            Label {
                width: fileName == previewPlayer.url ? parent.width - units.gu(4) : parent.width - units.gu(8.5)

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                text: fileName
                elide: Text.ElideRight
            }

            Icon {
                width: units.gu(2.5)
                height: units.gu(2.5)

                visible: fileUrl == previewPlayer.source && previewPlayer.playbackState == MediaPlayer.PlayingState

                anchors {
                    right: parent.right
                    rightMargin: units.gu(1.75)
                    verticalCenter: parent.verticalCenter
                }

                name: "media-playback-stop"
                color: theme.palette.normal.baseText
            }

            onClicked: {
                if (selectionMode) {
                    targetPage.tempFile = fileUrl
                    selectionMode = false
                    pageStack.pop()
                }
                else {
                    if (fileUrl == previewPlayer.source && previewPlayer.playbackState == MediaPlayer.PlayingState) {
                        previewPlayer.stop()
                    }
                    else {
                        previewPlayer.source = fileUrl
                        previewPlayer.play()
                    }
                }
            }
        }

        spacing: 1
    }

    MediaPlayer {
        id: previewPlayer
    }

    Connections {
        target: Qt.application
        
        onAboutToQuit: {
            previewPlayer.stop()
        }
    }
}
