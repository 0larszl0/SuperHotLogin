/*
    SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
    SPDX-License-Identifier: GPL-3.0-or-later
*/


import QtQuick 2.0
import QtQuick.Controls 2.15


RoundButton {

    required property Image monitorBackground
    required property string backgroundSwitchUrl
    required property TextInput activeTextArea
    required property int positionX
    required property int positionY
    required property int buttonWidth
    required property int buttonHeight

    property real monitorBgLeftOffset: -((monitorBackground.paintedWidth / 2) - (width / 2))
    property real monitorBgTopOffset: -((monitorBackground.paintedHeight / 2) - (height / 2))

    // Scale width and height based on background fillMode
    width: buttonWidth * monitorBackground.scaleFactorX
    height: buttonHeight * monitorBackground.scaleFactorY

    // Position button accordingly
    anchors.horizontalCenter: monitorBackground.horizontalCenter
    anchors.horizontalCenterOffset: monitorBgLeftOffset + (positionX * monitorBackground.scaleFactorX)

    anchors.verticalCenter: monitorBackground.verticalCenter
    anchors.verticalCenterOffset: monitorBgTopOffset + (positionY * monitorBackground.scaleFactorY)

    // Make the background transparent
    background: Rectangle { opacity: 0; radius: parent.radius }

    // Removes the option to tab to this button
    activeFocusOnTab: false

    MouseArea {
       anchors.fill: parent
       enabled: false
       cursorShape: Qt.PointingHandCursor
    }

    // Change the appearance of the background on press
    onPressed: monitorBg.backgroundUrl = backgroundSwitchUrl

    // When the mouse is let go from within the round button
    onReleased: {
        monitorBg.backgroundUrl = monitorBg.defaultBackgroundUrl
        activeTextArea.focus = true
    }

    // When the mouse is let go from outside the round button
    onCanceled: {
        monitorBg.backgroundUrl = monitorBg.defaultBackgroundUrl
        activeTextArea.focus = true  // refocuses on the currently available TextInput
    }
}
