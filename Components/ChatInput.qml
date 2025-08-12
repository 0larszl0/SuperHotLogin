/*
    SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
    SPDX-License-Identifier: GPL-3.0-or-later
*/


import QtQuick 2.15
import QtQml 2.15
import '.'  // Allows access to files inside the same directory


Rectangle {
    id: messageBorder

    required property InactivityTimer inactivityContainer
    required property int scaleFactorX
    required property int scaleFactorY
    
    property int inputType: TextInput.Normal
    property int lastMessageComplete: 0
    property color textColour: "white"
    property color borderColour: "white"
    property int padding: 30
    property int maxTextWidth: parent.width 
    property color cursorColour: "white"
    property int fontSize: 12

    property alias textInput: uinput

    signal submitted()

    color: "transparent"
    border.color: borderColour

    width: messageInner.width + (padding * Math.max(scaleFactorX, 0.8))
    height: messageInner.height + (padding * Math.max(scaleFactorY, 0.8))

    // ---- Determines what happens when we can see the last message or not ---- //
    states: [
        State {  // state for when this item should be hidden
            name: "hidden"
            when: (lastMessageComplete === 0)
            PropertyChanges { target: messageBorder; opacity: 0 }  // Doesn't show message
        },
        State {  // state for when to show this item
            when: (lastMessageComplete === 1)
            PropertyChanges { target: messageBorder; opacity: 1 }  // Shows message
	    PropertyChanges { target: uinput; focus: true }  // Focuses on the input when message shown
        }
    ]

    onStateChanged: {
	if (state !== "hidden") {uinput.forceActiveFocus()}
    }

    Rectangle {
        id: messageInner

        width: Math.min(uinput.contentWidth, maxTextWidth)
        height: uinput.height

        color: "transparent"

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        TextInput {	    
            id: uinput

            color: textColour
	    font.pixelSize: fontSize
	    font.family: "monospace"

	    // -- Selected text colour and background -- //
	    selectionColor: '#' + config.InputSelectColour
	    selectedTextColor: config.InputSelectedTextColour

	    // -- Selects textinput field type -- //
	    echoMode: inputType

	    // - In the case of a password - //
	    passwordCharacter: config.PasswordCharacter
	    passwordMaskDelay: parseInt(config.PasswordMaskDelay)

	    // centers the input along the vertical of the message bubble
            anchors.verticalCenter: parent.verticalCenter

            // Shares width with container
            width: parent.width

            clip: true  // Stops text going beyond boundary of input
	    cursorVisible: true  // ensures that the cursor delegate is shown instead of the standard

	    // reset inactivity timer and send signal that user is active, using cursorPosition is more reliable than Keys.onPressed
	    onCursorPositionChanged: inactivityContainer.resetInactivity()
	    
            cursorDelegate: CursorBlock {
		id: cursorBlock

		inactivityTimer: inactivityContainer
		textInput: uinput
		color: cursorColour

		// -- Bind 'visibleState' property to 'lastMessageComplete' -- //
		// Done deliberately because of how delegates instantiate, a binding is required to get a reactive update of lastMessageComplete

		Binding {
		    target: cursorBlock
		    property: "visibleState"
		    value: lastMessageComplete * 2
		}
	    }

	    onAccepted: {  // when ENTER is pressed
		submitted()
		focus = false  // stops future inputs happening in this input field
	    }

	    MouseArea {  // stops the user from modifying a previous or current input using the mouse
		anchors.fill: parent
		onClicked: {}
	    }
        }
    }
}

