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
import Lomiri.Content 1.3

Item {
    id: lomiriFilePicker
    anchors.fill: parent
    visible: false

    property list<ContentItem> importItems
    property var activeTransfer
    property var fileUrls : new Array

    onImportItemsChanged: {
        if (importItems.length > 0) {
            fileUrls = new Array

            for (var i = 0; i < importItems.length; i++) {
                const url = importItems[i].url
                console.log("URL: " + url)
                if (fileUrls.indexOf(url) == -1) {
                    fileUrls.push(url)
                }
            }

            for (var i in importItems) {
                importItems[i].move("/home/phablet/.local/share/cartwall.sanderklootwijk/")
            }

            lomiriFilePicker.accepted()
            lomiriFilePicker.visible = false
        }
    }

    signal accepted()

    function open() {
        lomiriFilePicker.visible = true
    }

    ContentPeerPicker {
        id: contentPeer
        anchors.fill: parent
        contentType: ContentType.Music
        handler: ContentHandler.Source
        onPeerSelected: { activeTransfer = peer.request() }
        onCancelPressed: { lomiriFilePicker.visible = false }
    }

    ContentTransferHint {
        id: importHint
        anchors.fill: parent
        activeTransfer: lomiriFilePicker.activeTransfer
    }

    Connections {
        target: lomiriFilePicker.activeTransfer
        onStateChanged: {
            if (lomiriFilePicker.activeTransfer.state === ContentTransfer.Charged) {
                importItems = lomiriFilePicker.activeTransfer.items;
            }
        }
    }
}