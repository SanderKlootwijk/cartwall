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
import Lomiri.Components.Popups 1.3
import QtQuick.Layouts 1.3
import QtMultimedia 5.4
import "../components"

import MediaManager 1.0

Page {
    id: editPage

    property bool loading: false

    property var tempIndex
    property string tempName: ""
    property string tempFile: ""
    property string tempButtonColor: ""
    property bool tempLoop: false

    Component.onCompleted: {
        nameField.text = tempName
    }

    header: PageHeader {
        id: editPageHeader
        title: tempIndex == -1 ? i18n.tr("New") : i18n.tr("Edit")

        leadingActionBar {
            actions: [
                Action {
                    text: i18n.tr("Back")
                    iconName: "back"
                    onTriggered: {
                        if (hasChanges()) {
                            PopupUtils.open(discardDialogComponent)
                        } else {
                            pageStack.pop()
                        }
                    }
                }
            ]
        }

        trailingActionBar {
            actions: [
                Action {
                    text: "Save"
                    iconName: "tick"
                    onTriggered: {
                        if (tempIndex === -1) {
                            cartwallModel.append({
                                name: nameField.text,
                                file: tempFile,
                                buttonColor: tempButtonColor,
                                loop: tempLoop
                            })
                            saveModel()
                            pageStack.pop()
                        } else {
                            cartwallModel.set(tempIndex, {
                                name: nameField.text,
                                file: tempFile,
                                buttonColor: tempButtonColor,
                                loop: tempLoop
                            })
                            saveModel()
                            pageStack.pop()
                        }
                    }
                },
                Action {
                    visible: tempIndex !== -1
                    text: i18n.tr("Delete")
                    iconName: "delete"
                    onTriggered: PopupUtils.open(deleteDialogComponent)
                }
            ]
        }
    }

    Column {
        width: parent.width
        
        anchors {
            left: parent.left
            top: editPageHeader.bottom
        }

        ListItem {
            id: audioTitle

            height: units.gu(5.25)

            divider.colorFrom: theme.palette.normal.background
            divider.colorTo: theme.palette.normal.background

            Label {
                width: parent.width - units.gu(4)

                anchors {
                    bottom: parent.bottom
                    bottomMargin: units.gu(1.25)
                    left: parent.left
                    leftMargin: units.gu(2)
                }
                
                text: i18n.tr("Audio") + ":"

                color: theme.palette.normal.backgroundSecondaryText
                font.bold: true
                elide: Text.ElideRight
            }
        }

        ListItem {
            id: fileField
            
            width: parent.width
            height: units.gu(6)

            Label {
                width: parent.width - units.gu(8.5)

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                text: tempFile === ""
                    ? "Choose audio file…"
                    : tempFile.replace("file:///home/phablet/.local/share/cartwall.sanderklootwijk/", "")

                color: tempFile === "" || MediaManager.fileExists(tempFile)
                    ? theme.palette.normal.text
                    : theme.palette.normal.negative

                elide: Text.ElideRight
            }

            Icon {
                id: nextIcon

                width: units.gu(2.5)
                height: units.gu(2.5)

                anchors {
                    right: parent.right
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                name: "next"
            }

            onClicked: {
                filePage.selectionMode = true
                filePage.targetPage = editPage
                pageStack.push(filePage)
            }
        }

        ListItem {
            id: appearanceTitle

            height: units.gu(6.25)

            divider.colorFrom: theme.palette.normal.background
            divider.colorTo: theme.palette.normal.background

            Label {
                width: parent.width - units.gu(4)

                anchors {
                    bottom: parent.bottom
                    bottomMargin: units.gu(1.25)
                    left: parent.left
                    leftMargin: units.gu(2)
                }
                
                text: i18n.tr("Name and color") + ":"

                color: theme.palette.normal.backgroundSecondaryText
                font.bold: true
                elide: Text.ElideRight
            }
        }

        ListItem {
            id: nameListItem

            width: parent.width
            height: units.gu(6)

            divider.colorFrom: theme.palette.normal.background
            divider.colorTo: theme.palette.normal.background

            TextField {
                id: nameField
                
                width: parent.width - units.gu(4)

                anchors.centerIn: parent

                inputMethodHints: Qt.ImhNoPredictiveText
            }
        }

        ListItem {
            id: colorListItem
            
            width: parent.width
            height: units.gu(9)
        
            Flickable {
                width: parent.width
                height: units.gu(6)

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    bottom: parent.bottom
                    bottomMargin: units.gu(2)
                }

                contentWidth: colorRow.width + units.gu(4)
                contentHeight: height

                clip: true

                Row {
                    id: colorRow

                    height: parent.height
                    spacing: units.gu(1)

                    ColorButton { color: "#8F8A94" }
                    ColorButton { color: "#553277" }
                    ColorButton { color: "#D6AF2B" }
                    ColorButton { color: "#2E8A5A" }
                    ColorButton { color: "#B83F3F" }
                    ColorButton { color: "#2F75B8" }
                }
            }
        }

        ListItem {
            id: loopTitle

            height: units.gu(6.25)

            divider.colorFrom: theme.palette.normal.background
            divider.colorTo: theme.palette.normal.background

            Label {
                width: parent.width - units.gu(4)

                anchors {
                    bottom: parent.bottom
                    bottomMargin: units.gu(1.25)
                    left: parent.left
                    leftMargin: units.gu(2)
                }
                
                text: i18n.tr("Playback") + ":"

                color: theme.palette.normal.backgroundSecondaryText
                font.bold: true
                elide: Text.ElideRight
            }
        }
        
        ListItem {
            id: loopListItem

            enabled: settings.source == "empty" ? false : true

            onClicked: loopSwitch.checked ? loopSwitch.checked = false : loopSwitch.checked = true

            Label {
                width: parent.width - units.gu(10)

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: units.gu(2)
                }
                
                text: i18n.tr("Loop")

                elide: Text.ElideRight
            }

            Switch {
                id: loopSwitch

                checked: tempLoop

                Behavior on checked {
                    enabled: false
                }

                onCheckedChanged: tempLoop = checked
                
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: units.gu(2)
                } 
            }
        }
    }

    Component {
         id: deleteDialogComponent

         Dialog {
             id: deleteDialog

             title: "Delete"

             text: "Are you sure that you want to delete this button?"

             Button {
                 text: "Delete"
                 color: theme.palette.normal.negative

                 onClicked: {
                    cartwallModel.remove(tempIndex, 1)
                    saveModel()
                    PopupUtils.close(deleteDialog)
                    pageStack.pop()
                 }
             }

             Button {
                 text: "Cancel"
                 onClicked: PopupUtils.close(deleteDialog)
             }
         }
    }

    Component {
        id: discardDialogComponent

        Dialog {
            id: discardDialog

            title: "Discard changes"

            text: "Are you sure you want to discard your changes?"

            Button {
                text: "Discard"
                color: theme.palette.normal.negative

                onClicked: {
                    PopupUtils.close(discardDialog)
                    pageStack.pop()
                }
            }

            Button {
                text: "Cancel"
                onClicked: PopupUtils.close(discardDialog)
            }
        }
    }

    function hasChanges() {
        if (tempIndex === -1) {
            return (
                nameField.text !== "" ||
                tempFile !== "" ||
                tempButtonColor !== "#553277" ||
                tempLoop !== false
            )
        } else {
            var item = cartwallModel.get(tempIndex)

            return (
                nameField.text !== item.name ||
                tempFile !== item.file ||
                tempButtonColor !== item.buttonColor ||
                tempLoop !== item.loop
            )
        }
    }
}