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
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtMultimedia 5.4
import "components"
import "pages"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'cartwall.sanderklootwijk'
    automaticOrientation: true

    width: units.gu(75)
    height: units.gu(110)

    signal stopAll()

    Settings {
        id: settings

        property string cartwallData: "[]"
    }

    ListModel {
        id: cartwallModel
    }

    Component.onCompleted: {
        Theme.name = "Lomiri.Components.Themes.SuruDark"

        var array = JSON.parse(settings.cartwallData)

        for (var i = 0; i < array.length; ++i) {
            cartwallModel.append({
                "name": array[i].name || "",
                "file": array[i].file || "",
                "buttonColor": array[i].buttonColor || "",
                "loop": !!array[i].loop
            })
        }
    }

    PageStack {
        id: pageStack

        anchors.fill: parent

        Component.onCompleted: push(mainPage)
    }

    property var filePicker: lomiriFilePicker.createObject(root)
    readonly property Component lomiriFilePicker: Qt.createComponent("components/LomiriFilePicker.qml", Component.PreferSynchronous)

    // Pages

    MainPage {
        id: mainPage

        visible: false

        anchors.fill: parent
    }

    FilePage {
        id: filePage

        visible: false

        anchors.fill: parent
    }

    // Functions
    function saveModel() {
        var array = []

        for (var i = 0; i < cartwallModel.count; ++i) {
            var item = cartwallModel.get(i)

            array.push({
                name: item.name,
                file: item.file,
                buttonColor: item.buttonColor,
                loop: item.loop
                })
        }

        settings.cartwallData = JSON.stringify(array)
    }
}
