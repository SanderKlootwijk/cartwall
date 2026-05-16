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

Button {
    id: colorButton

    width: units.gu(6)
    height: units.gu(6)

    onClicked: tempButtonColor = color

    Icon {
        width: units.gu(2.5)
        height: units.gu(2.5)

        anchors.centerIn: parent

        visible: parent.color == tempButtonColor

        name: "tick"
        color: theme.palette.normal.baseText
    }
}