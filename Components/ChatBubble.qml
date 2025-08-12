/*
    SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
    SPDX-License-Identifier: GPL-3.0-or-later
*/



import QtQuick 2.0


Rectangle {
    id: messageBorder

    required property int scaleFactorX
    required property int scaleFactorY

    // - Optional properties for the user - //
    property int lastMessageComplete: 0  // using ints as this is based on opacity
    property string message: ''
    property color messageColour: config.SystemMessageColour
    property color borderColour: config.SystemBorderColour
    property int padding: 30
    property int maxTextWidth: parent.width
    property int fontSize: 12  // default font size
    property bool enableTypingEffect: true

    // - Internal property - //
    property int currentLength: 0

    signal messageWritten

    color: "transparent"
    border.color: borderColour

    width: messageInner.width + (padding * Math.max(scaleFactorX, 0.8))
    height: messageInner.height + (padding * Math.max(scaleFactorY, 0.8))


    // --- Changes the message shown on this ChatBubble --- //
    function changeMessage(newMessage) {
	currentLength = 0
	message = newMessage
	typeTimer.running = enableTypingEffect
    }


    // ---- Determines what happens when we can see the message or not ---- //
    states: [
	State {
	    name: "hidden"
	    when: (lastMessageComplete === 0)
	    PropertyChanges { target: typeTimer; running: false }  // Doesn't start writing text
            PropertyChanges { target: messageBorder; opacity: 0 }  // Doesn't show message
	},
	State {
	    name: "visible"
	    when: (lastMessageComplete === 1)
	    PropertyChanges { target: messageBorder; opacity: 1 }  // Shows message
	    PropertyChanges { target: typeTimer; running: enableTypingEffect }  // Starts writing text
	}
    ]

    Rectangle {
        id: messageInner

        width: Math.min(label.implicitWidth, maxTextWidth)
        height: label.height

        color: "transparent"

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

	Timer {  // Create a type-writer effect for the Text object
	    id: typeTimer

	    interval: parseInt(config.TypeWriterSpeed)  // ms
	    repeat: true  // ensures timer continuously executes at each interval
	    
	    onTriggered: {  // per interval, increase length of exposed text (by incrementing counter-- currentLength)
		
		if (currentLength < message.length) {
		    currentLength++;
		    return;
		}
		
		messageWritten();
		stop();
	    }
	}

        Text {
            id: label

            color: messageColour
    	    font.pixelSize: fontSize
	    font.family: "monospace"

	    // depending if this message wants a typing effect, will determine if the message is gradually revealed or not
	    text: enableTypingEffect ? message.substring(0, currentLength) : message

            // Spreads words out to fit width
            horizontalAlignment: Text.AlignJustify

            // Shares width with container, for wrapping to work properly
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }
}
