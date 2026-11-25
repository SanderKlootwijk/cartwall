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
import Lomiri.Content 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQuick.LocalStorage 2.7
import QtMultimedia 5.12
import "components"
import "pages"

MainView {
    id: root

    objectName: 'mainView'
    applicationName: 'cartwall.sanderklootwijk'
    property string version: "1.0"
    automaticOrientation: true

    width: units.gu(75)
    height: units.gu(110)

    theme.name: {
        switch (settings.theme) {
            case 0: return "";
            case 1: return "Ubuntu.Components.Themes.Ambiance";
            case 2: return "Ubuntu.Components.Themes.SuruDark";
            default: return "";
        }
    }

    signal stopAll()

    Connections {
        target: Qt.application
        
        onAboutToQuit: {
            stopAll()
        }
    }

    Settings {
        id: settings

        property int theme: 0

        property int currentCartwallId: 1
        property string currentCartwallPrettyName
    }

    // LocalStorage
    property string dbName: "CartwallData"
    property string dbVersion: "1.0"
    property string dbDescription: "Database for cartwall"
    property int dbEstimatedSize: 10000

    property var db: LocalStorage.openDatabaseSync(
        dbName,
        dbVersion,
        dbDescription,
        dbEstimatedSize
    )

    property var cartwalls: []
    property var cartwallNames: []
    property var lastPlayerIndex: -1
    property string lastPlayerText

    Component.onCompleted: {
        initializeDatabase()

        getCartwalls()

        if (cartwalls.length === 0) {
            settings.currentCartwallId = createCartwall(i18n.tr("Empty cartwall"))
            getCartwalls()
        }

        initializeCartwall()
    }

    // PageStack
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

    CartwallsPage {
        id: cartwallsPage

        visible: false

        anchors.fill: parent
    }

    SettingsPage {
        id: settingsPage

        visible: false

        anchors.fill: parent
    }

    AboutPage {
        id: aboutPage

        visible: false

        anchors.fill: parent
    }

    // Cartwall ListModel
    ListModel {
        id: cartwallModel
    }

    // Audio Controller
    Item {
        id: audioController

        property var players: [player1, player2, player3, player4, player5, player6, player7, player8, player9, player10]
        property var playerHistory: []
        property bool allPlayersStopped: playerHistory.length === 0
        
        function play(index, loop, playerText, source) {
            for (let player of players) {
                if (player.playbackState === MediaPlayer.PausedState)
                    continue

                if (player.playbackState !== MediaPlayer.PlayingState) {
                    player.index = index
                    player.loop = loop
                    player.playerText = playerText
                    player.source = source
                    player.manuallyStopped = false
                    player.play()
                    return true
                }
            }
            return false
        }

        function stop(index) {
            var player = playerFor(index)

            player.manuallyStopped = true
            player.stop()
        }

        function playing(index) {
            var player = playerFor(index)

            if (player.playbackState == MediaPlayer.PlayingState) {
                return true
            }
            else {
                return false
            }
        }

        function playerFor(index) {
            for (let player of players) {
                if (player.index === index)
                    return player
            }
            return null
        }

        function playersState() {
            audioController.allPlayersStopped = true

            for (let player of players) {
                if (player.playbackState === MediaPlayer.PlayingState || player.playbackState === MediaPlayer.PausedState) {
                    audioController.allPlayersStopped = false
                    break
                }
            }
        }

        function playerStarted(player) {
            let history = playerHistory.filter(p => p !== player)

            history.push(player)

            playerHistory = history

            updateLastPlayer()
        }

        function playerStopped(player) {
            playerHistory = playerHistory.filter(p => p !== player)

            updateLastPlayer()
        }

        function updateLastPlayer() {
            for (let i = playerHistory.length - 1; i >= 0; i--) {
                let player = playerHistory[i]

                if (player.playbackState === MediaPlayer.PlayingState || player.playbackState === MediaPlayer.PausedState) {
                    root.lastPlayerIndex = player.index
                    root.lastPlayerText = player.playerText
                    return
                }
            }

            root.lastPlayerIndex = -1
            root.lastPlayerText = ""
        }

        CartwallPlayer {
            id: player1
        }

        CartwallPlayer {
            id: player2
        }

        CartwallPlayer {
            id: player3
        }

        CartwallPlayer {
            id: player4
        }

        CartwallPlayer {
            id: player5
        }

        CartwallPlayer {
            id: player6
        }

        CartwallPlayer {
            id: player7
        }

        CartwallPlayer {
            id: player8
        }

        CartwallPlayer {
            id: player9
        }

        CartwallPlayer {
            id: player10
        }
    }

    // Database Functions    
    function initializeDatabase() {
        db.transaction(function(tx) {
            tx.executeSql(
                "CREATE TABLE IF NOT EXISTS cartwalls (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "prettyName TEXT NOT NULL" +
                ")"
            );

            tx.executeSql(
                "CREATE TABLE IF NOT EXISTS cartwall_buttons (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "cartwallId INTEGER NOT NULL," +
                "name TEXT NOT NULL," +
                "file TEXT," +
                "buttonColor TEXT," +
                "loop INTEGER NOT NULL DEFAULT 0," +
                "stopOthers INTEGER NOT NULL DEFAULT 0," +
                "sortOrder INTEGER NOT NULL DEFAULT 0," +
                "FOREIGN KEY(cartwallId) REFERENCES cartwalls(id)" +
                ")"
            );
        })
    }

    function createCartwall(prettyName) {
        var cartwallId

        db.transaction(function(tx) {
            var result = tx.executeSql(
                "INSERT INTO cartwalls (prettyName) VALUES (?)",
                [prettyName]
            )

            cartwallId = result.insertId
        })

        return cartwallId
    }

    function getCartwalls() {
        var result = []
        var names = []

        db.transaction(function(tx) {
            var rows = tx.executeSql(
                "SELECT id, prettyName " +
                "FROM cartwalls " +
                "ORDER BY id"
            )

            for (var i = 0; i < rows.rows.length; ++i) {
                var row = rows.rows.item(i)

                result.push({
                    id: row.id,
                    prettyName: row.prettyName
                })

                names.push(row.prettyName)
            }

            var results = tx.executeSql(
                "SELECT prettyName " +
                "FROM cartwalls " +
                "WHERE id = ?",
                [settings.currentCartwallId]
            )

            if (results.rows.length > 0) {
                settings.currentCartwallPrettyName = results.rows.item(0).prettyName
            }
        })

        cartwalls = result
        cartwallNames = names
    }

    function loadCartwall(cartwallId) {
        settings.currentCartwallId = cartwallId
        initializeCartwall()
    }

    function initializeCartwall() {
        cartwallModel.clear()

        db.transaction(function(tx) {
            var results = tx.executeSql(
                "SELECT prettyName " +
                "FROM cartwalls " +
                "WHERE id = ?",
                [settings.currentCartwallId]
            )

            if (results.rows.length > 0) {
                settings.currentCartwallPrettyName = results.rows.item(0).prettyName
            }
            
            var results = tx.executeSql(
                "SELECT id, name, file, buttonColor, loop, stopOthers, sortOrder " +
                "FROM cartwall_buttons " +
                "WHERE cartwallId = ? " +
                "ORDER BY sortOrder",
                [settings.currentCartwallId]
            )

            for (var i = 0; i < results.rows.length; ++i) {
                var row = results.rows.item(i)

                cartwallModel.append({
                    id: row.id,
                    name: row.name || "",
                    file: row.file || "",
                    buttonColor: row.buttonColor || "",
                    loop: Boolean(row.loop),
                    stopOthers: Boolean(row.stopOthers),
                    sortOrder: row.sortOrder
                })
            }
        })
    }

    function addItem(name, file, buttonColor, loop, stopOthers) {
        var sortOrder = cartwallModel.count
        var buttonId

        db.transaction(function(tx) {
            var result = tx.executeSql(
                "INSERT INTO cartwall_buttons " +
                "(cartwallId, name, file, buttonColor, loop, stopOthers, sortOrder) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)",
                [
                    settings.currentCartwallId,
                    name,
                    file,
                    buttonColor,
                    loop ? 1 : 0,
                    stopOthers ? 1 : 0,
                    sortOrder
                ]
            )

            buttonId = result.insertId
        })

        cartwallModel.append({
            id: buttonId,
            name: name,
            file: file,
            buttonColor: buttonColor,
            loop: loop,
            stopOthers: stopOthers,
            sortOrder: sortOrder
        })
    }

    function removeItem(index) {
        var id = cartwallModel.get(index).id

        db.transaction(function(tx) {
            tx.executeSql(
                "DELETE FROM cartwall_buttons WHERE id = ?",
                [id]
            )

            cartwallModel.remove(index)

            for (var i = 0; i < cartwallModel.count; ++i) {
                var itemId = cartwallModel.get(i).id

                tx.executeSql(
                    "UPDATE cartwall_buttons " +
                    "SET sortOrder = ? " +
                    "WHERE id = ?",
                    [i, itemId]
                )

                cartwallModel.setProperty(i, "sortOrder", i)
            }
        })
    }

    function updateItem(index) {
        var item = cartwallModel.get(index)

        db.transaction(function(tx) {
            tx.executeSql(
                "UPDATE cartwall_buttons SET " +
                "name = ?, " +
                "file = ?, " +
                "buttonColor = ?, " +
                "loop = ?, " +
                "stopOthers = ? " +
                "WHERE id = ?",
                [
                    item.name,
                    item.file,
                    item.buttonColor,
                    item.loop ? 1 : 0,
                    item.stopOthers ? 1 : 0,
                    item.id
                ]
            )
        })
    }

    function saveOrder() {
        db.transaction(function(tx) {
            for (var i = 0; i < cartwallModel.count; ++i) {
                var id = cartwallModel.get(i).id

                tx.executeSql(
                    "UPDATE cartwall_buttons " +
                    "SET sortOrder = ? " +
                    "WHERE id = ?",
                    [i, id]
                )

                cartwallModel.setProperty(i, "sortOrder", i)
            }
        })
    }

    function renameCartwall(cartwallId, prettyName) {
        db.transaction(function(tx) {
            tx.executeSql(
                "UPDATE cartwalls " +
                "SET prettyName = ? " +
                "WHERE id = ?",
                [prettyName, cartwallId]
            )
        })

        getCartwalls()
    }

    function deleteCartwall(cartwallId) {
        db.transaction(function(tx) {
            tx.executeSql(
                "DELETE FROM cartwall_buttons WHERE cartwallId = ?",
                [cartwallId]
            )

            tx.executeSql(
                "DELETE FROM cartwalls WHERE id = ?",
                [cartwallId]
            )
        })

        getCartwalls()

        if (settings.currentCartwallId === cartwallId) {
            cartwallModel.clear()
        }
    }

    function millisecToPlaytime(millisec) {
        millisec = Math.max(0, millisec || 0);

        return Math.floor(millisec / 60000) + ":" + ("0" + Math.floor((millisec % 60000) / 1000)).slice(-2);
    }
}