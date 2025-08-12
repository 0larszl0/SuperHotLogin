/*
    SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
    SPDX-License-Identifier: GPL-3.0-or-later
*/


import QtQuick 2.0


Rectangle {
    id: blockCursor

    required property InactivityTimer inactivityTimer
    required property TextInput textInput
    
    // acts as required but isn't to have a default value
    property int visibleState: -1  // [-1, 2]

    width: monoLetter.width
    height: textInput.cursorRectangle.height

    color: "white"

    // ---- Emulate text size ---- //

    Text {  // this adjusts the width of the cursor
	id: monoLetter

	text: "A"
	font.family: textInput.font.family
	font.pixelSize: textInput.font.pixelSize

	visible: false
    }

    // ---- Create a blinking effect only when inactive ---- //
    states: [
    	State {  // active state
            when: (visibleState === 1)
            PropertyChanges { target: blockCursor; opacity: 1 }
        },
        State {  // inactive state
            when: (visibleState === 0)
            PropertyChanges { target: blockCursor; opacity: 0 }
        },
	State {  // input complete state
	    when: (visibleState === -1)
	    PropertyChanges { target: blockCursor; opacity: 0 }
	}
    ]

    onVisibleStateChanged: {  // activates whenever the visibleState property changes
	if (visibleState === 2) {
	    visibleState = 1
	    blinkTimer.start()

	}
    }

    Timer {
    	id: blinkTimer

        repeat: true
        interval: 500

        onTriggered: {
	    if (visibleState !== -1) {
		visibleState = (visibleState - 1) * -1  // continuously flips between 0 and 1

	    }
	}
    }

    // ---- Create a connection to an external QML signal, specifically the ones from InactivityTimer.qml ---- //
    // -- First connection is to the inactivity timer: blink when inactive, and keep solid otherwise -- //
    Connections {
    	target: inactivityTimer

        function onUserInActive() {
	    if (visibleState !== -1) {
		blinkTimer.start()

	    }
        }

        function onUserActive() {
	    if (visibleState !== -1) {
            	blinkTimer.stop()
            	visibleState = 1  // Ensures cursor is visible

	    }
        }
    }

    // -- Second connection is to the textInput the cursor block is attached to -- //
    Connections {
	target: textInput

	function onAccepted() {  // when the input has been ENTERED
	    if (blinkTimer.running) {
		blinkTimer.stop()
	    }

	    visibleState = -1  // hide the cursor
	}

	
	function onCursorPositionChanged() {
	    // checks if the cursor has reached the right-most position
	    if (textInput.cursorPosition > uinput.length - 1) {
		invertedText.text = ''
		return null
	    }

	    // not using textInput.displayText as it's a partial text input and acts funny in certain situations
	    if (textInput.echoMode === TextInput.Password) {
		invertedText.text = textInput.passwordCharacter
		return null
	    }

	    invertedText.text = textInput.text[textInput.cursorPosition]
	}

	function onTextEdited() {

	    // this is to check if the user selected from right to left and deleted the text, as the cursor 
	    // position doesn't change as it's left position was a consistent 0, it will not have updated its
	    // inverted text.
	    if (textInput.length === 0 && invertedText.text !== '') {
		inactivityTimer.resetInactivity()
		invertedText.text = ''
	    }

	}
	
    }

    // ---- Invert character under block cursor ---- //
    Text {  // Note, when opacity of cursor changes, so does this
    	id: invertedText

        anchors.centerIn: parent
        color: "black"
	font.family: textInput.font.family
        font.pointSize: textInput.font.pointSize
	font.bold: true
    }
}
