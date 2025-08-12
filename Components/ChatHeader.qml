/*
     SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
     SPDX-License-Identifier: GPL-3.0-or-later
*/


import QtQuick 2.0



Item {

    required property Column chatCol
    required property int borderWidth

    property alias displayText: textHeader

    width: rectHeader.width
    height: rectHeader.height

    Rectangle {
	id: rectHeader

    	color: "transparent"

        // matches child dimensions
        width: textHeader.implicitWidth + (chatCol.fontSize * 0.6)
        height: textHeader.implicitHeight

	anchors.centerIn: parent

        Rectangle {  // positioned and scaled to hide the border of the chat
            color: "black"

            anchors.verticalCenter: parent.verticalCenter
            // gives a slight offset whenever the height of the text is even
            anchors.verticalCenterOffset: displayText.height % 2 === 0 ? 1 : 0

            width: parent.width
            height: borderWidth
        }

        Text {
            id: textHeader

            font.pixelSize: chatCol.fontSize * 0.8
            color: "white"
            font.letterSpacing: 2

            anchors.centerIn: parent

        }
    }
}
