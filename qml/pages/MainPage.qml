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
import QtQuick.Layouts 1.3
import QtMultimedia 5.4
import "../components"

Page {
    id: mainPage

    header: PageHeader {
        id: mainPageHeader
        title: i18n.tr("Cartwall")

        trailingActionBar {
            actions: [
                Action {
                    text: i18n.tr("Settings")
                    iconName: "settings"
                    onTriggered: pageStack.push(settingsPage)
                },
                Action {
                    text: i18n.tr("Files")
                    iconName: "folder-symbolic"
                    onTriggered: {
                        pageStack.push(filePage)
                    }
                }
            ]
        }
    }

    Rectangle {
        id: controlsView

        width: parent.width
        height: cartwallView.buttonSize + units.gu(2)

        anchors {
            top: mainPageHeader.bottom
            horizontalCenter: parent.horizontalCenter
        }

        color: theme.palette.normal.background

        Button {
            id: stopAllButton

            width: cartwallView.buttonSize
            height: cartwallView.buttonSize

            anchors {
                top: parent.top
                topMargin: units.gu(1)
                left: parent.left
                leftMargin: units.gu(1)
            }

            text: "Stop All"

            onClicked: root.stopAll()
        }

        Button {
            id: newButton

            width: cartwallView.buttonSize
            height: cartwallView.buttonSize

            anchors {
                top: parent.top
                topMargin: units.gu(1)
                left: stopAllButton.right
                leftMargin: units.gu(1)
            }

            text: "New"

            onClicked: {
                pageStack.push(
                    Qt.resolvedUrl("../pages/EditPage.qml"),
                    {
                        tempIndex: -1,
                        tempName: "",
                        tempFile: "",
                        tempButtonColor: "#553277",
                        tempLoop: false
                    }
                )
            }
        }

        Rectangle {
            width: parent.width
            height: units.dp(1)

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            color: theme.palette.normal.base
        }
    }

    Rectangle {
        z: 1
        
        width: parent.width
        height: units.gu(1)

        anchors {
            top: cartwallFlickable.top
            horizontalCenter: parent.horizontalCenter
        }

        color: theme.palette.normal.background
    }

    Flickable {
        id: cartwallFlickable

        width: parent.width
        height: parent.height - mainPageHeader.height - controlsView.height

        anchors {
            bottom: parent.bottom
            topMargin: mainPageHeader.height + controlsView.height
        }

        contentWidth: cartwallView.width
        contentHeight: cartwallView.height

        clip: true

        Grid {
            id: cartwallView

            width: root.width

            columns: width / units.gu(13)
            property real buttonSize: (width - (columns * units.gu(1)) - units.gu(1)) / columns

            leftPadding: units.gu(1)
            topPadding: units.gu(1)
            bottomPadding: units.gu(1)
            rowSpacing: units.gu(1)
            columnSpacing: units.gu(1)

            Repeater {
                model: cartwallModel

                delegate: CartwallButton {
                    width: cartwallView.buttonSize
                    height: cartwallView.buttonSize

                    text: name
                    audioSource: file
                    loops: loop
                }
            }
        }
    }
}