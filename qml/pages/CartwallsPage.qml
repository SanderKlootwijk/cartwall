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
import Lomiri.Components.Popups 1.3
import QtQuick.Layouts 1.3

Page {
    id: cartwallsPage

    property var tempId
    property var tempName

    header: PageHeader {
        id: cartwallsPageHeader

        title: i18n.tr("Cartwalls")

        trailingActionBar {
            numberOfSlots: 4

            actions: [
                Action {
                    text: i18n.tr("New cartwall")
                    iconName: "add"
                    onTriggered: {
                        PopupUtils.open(newCartwallDialogComponent)
                    }
                }
            ]
        }
    }

    ListView {
        id: cartwallsListView

        anchors {
            fill: parent
            topMargin: cartwallsPageHeader.height
        }

        model: root.cartwalls

        delegate: ListItem {
            width: parent.width
            height: units.gu(6)

            leadingActions: ListItemActions {
                actions: [
                    Action {
                        enabled: cartwalls.length > 1 && modelData.id != settings.currentCartwallId
                        iconName: "delete"
                        onTriggered: {
                            deleteCartwall(modelData.id)
                        }
                    }
                ]
            }

            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "edit"
                        onTriggered: {
                            cartwallsPage.tempId = modelData.id
                            cartwallsPage.tempName = modelData.prettyName
                            PopupUtils.open(editCartwallDialogComponent)
                        }
                    }
                ]
            }

            Label {
                width: parent.width - units.gu(8)

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                text: modelData.prettyName
                elide: Text.ElideRight
            }

            Icon {
                width: units.gu(2)
                height: units.gu(2)

                visible: modelData.id == settings.currentCartwallId

                anchors {
                    right: parent.right
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                name: "ok"
                color: theme.palette.normal.baseText
            }

            onClicked: {
                if (modelData.id != settings.currentCartwallId) {
                    root.loadCartwall(modelData.id)
                    root.stopAll()

                    mainPage.bottomEdge.collapse()
                }
            }
        }

        spacing: 1
    }

    Component {
        id: newCartwallDialogComponent

        Dialog {
            id: newCartwallDialog

            title: i18n.tr("New cartwall")

            TextField {
                id: nameField

                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: i18n.tr("Name")
            }

            Button {
                enabled: nameField.text.length > 0

                text: i18n.tr("Create")
                color: theme.palette.normal.positive

                onClicked: {
                    createCartwall(nameField.text)
                    getCartwalls()

                    PopupUtils.close(newCartwallDialog)
                }
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(newCartwallDialog)
            }
        }
    }

    Component {
        id: editCartwallDialogComponent

        Dialog {
            id: editCartwallDialog

            title: i18n.tr("Edit cartwall")

            TextField {
                id: nameField

                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: i18n.tr("Name")
                text: cartwallsPage.tempName
            }

            Button {
                enabled: nameField.text.length > 0

                text: i18n.tr("Save")
                color: theme.palette.normal.positive

                onClicked: {
                    renameCartwall(cartwallsPage.tempId, nameField.text)
                    getCartwalls()

                    PopupUtils.close(editCartwallDialog)
                }
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(editCartwallDialog)
            }
        }
    }
}