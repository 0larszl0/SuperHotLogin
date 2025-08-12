/*
     SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
     SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.0
import QtQuick.Controls 2.15
import '.'


Item {
    id: chatTerminal
    
    required property InactivityTimer inactivityTimer
    required property int bgScaleFactorX
    required property int bgScaleFactorY

    property Item currentTextInput: userField.textInput

    property alias chatAr: chatArea  // for LoginConsequences

    // -- Enter List of Quotes -- //

    QuoteModel { id: quoteModel }

    // ---- Create Chat Border ---- //

    Rectangle {
        id: chatBorder

        property int borderWidth: 2

	width: parent.width
	height: parent.height

        // Background & Border
        color: "transparent"
        border.color: "white"
        border.width: borderWidth

	// ---- Create Headers that will align with Chat Border ---- //

        ChatHeader {
	    id: clock

	    chatCol: chatColumn
	    borderWidth: parent.borderWidth

	    anchors.left: parent.left
	    anchors.leftMargin: parent.width * 0.02
            anchors.bottom: parent.top
            anchors.bottomMargin: -displayText.height / 2  // shifts the text to make it in-line with the border

	    Timer {
		id: clockTimer

            	interval: 1000
            	repeat: true
            	onTriggered: clock.displayText.text = Qt.formatTime(new Date(), "hh:mm:ss")
	    }

	    Component.onCompleted: {
		if (config.ShowClock === "yes") {
		    clock.displayText.text = Qt.formatTime(new Date(), "hh:mm:ss")
		    clockTimer.start()
		    return null
		}

		clock.visible = false
	    }
        }

	ChatHeader {
	    id: sessions

	    property alias sessionSelection: sessionManager

	    chatCol: chatColumn
	    borderWidth: parent.borderWidth

	    anchors.right: parent.right
	    anchors.rightMargin: parent.width * 0.02
	    anchors.bottom: parent.top
	    anchors.bottomMargin: -displayText.height / 2

	    Binding {
		target: sessions.displayText
		property: "text"
		value: sessionManager.currentText
	    }

	    ComboBox {
	    	id: sessionManager

	    	model: sessionModel  // tested using quoteModel.quotes, with textRole: 'text'
	    	textRole: "name"

	    	enabled: false  // prevents from tabbing to this element at any time-- causes focus conflicts
	    	visible: false
	    	focus: false

		MouseArea {  // stops any unwanted mouse actions happening invisibly
		    anchors.fill: parent
		    onClicked: {}
		}

		onFocusChanged: sessions.displayText.font.bold = !sessions.displayText.font.bold

		// These Keys only are active when the focus is on this ComboBox
	    	Keys.onTabPressed: { sessionManager.currentIndex = (sessionManager.currentIndex + 1) % sessionManager.count}

		// onReturnPressed is main ENTER button on keyboard, onEnterPressed is ENTER button on numpad
	    	Keys.onReturnPressed: {
		    sessionManager.enabled = false
		    sessionManager.focus = false
		    currentTextInput.focus = true
	    	}
	    }

	    Component.onCompleted: {
		if (config.ShowSessions === "no") {
		    sessions.visible = false
		}
	    }
	}

	Keys.onTabPressed: {  // Keys only registers input when a TextInput is being focussed on by default
	    if (config.ShowSessions === "yes") {
	    	sessions.sessionSelection.enabled = true
	    	sessions.sessionSelection.focus = true
	    	currentTextInput.focus = false

	    }
	}


        // ---- Create Chat Area within border ---- //

        Rectangle {
            id: chatArea

	    // Exposed to LoginConsequences
	    property alias chatCol: chatColumn
	    property alias soloMessage: centreMessage
        
            // Sets width & height to be inside border
            width: parent.width - (parent.borderWidth * 2)
            height: parent.height - (parent.borderWidth * 2)

            // aligns the chat area to the parent
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            color: "transparent"
            //border.color: "green"  // --- for testing

            // ---- Create Chat Column, where primary conversation will occur ---- //
            // Column was made so that there would be margin between the messages and the border
            // ChatArea simply ensures everything is aligned and contained within the border

            Column  {
                id: chatColumn

		// Exposed to LoginConsequences
		property alias quoteBubble: quote

		// Internal properties
                property int chatMargin: 40
                property int maxTextWidth: parent.width * 0.7
                property int fontSize: parent.height * 0.035

                // Keeps the contents within the border
                width: parent.width - chatMargin
                // Creates a margin like effect for all items (right & left)
                anchors.horizontalCenter: parent.horizontalCenter

                anchors.top: parent.top  // Keeps contents to start at top
                anchors.topMargin: chatMargin / 2  // provides margin for the top area

                spacing: (chatMargin / 2) * Math.max(scaleFactorY, 0.7)  // gap between elements


		// -- Reset chat window contents -- //
		function resetChat() {
		    currentTextInput = userField.textInput

		    quote.currentLength = 0

		    unameAsk.lastMessageComplete = 0
		    unameAsk.currentLength = 0

		    userField.lastMessageComplete = 0
		    userField.textInput.text = ""

		    passAsk.lastMessageComplete = 0
		    passAsk.currentLength = 0

		    passField.lastMessageComplete = 0
		    passField.textInput.text = ""
		}


		// -- Read a random quote from file -- //
		function getQuote() {
		    var index = Math.floor(Math.random() * quoteModel.quotes.count);  // Math.random gets a random val between 0-1
		    return quoteModel.quotes.get(index).text;
		}

		Component.onCompleted: { 
		    if (config.KeepQuotes === "yes") {
			quote.message = getQuote()  // gets a quote for the first ChatBubble
			return null
		    }

		    quote.message = config.ReplaceQuote
		}

                // ---- Chat window contents ---- //

                ChatBubble {
                    id: quote

		    scaleFactorX: bgScaleFactorX
		    scaleFactorY: bgScaleFactorY

                    message: ""
                    maxTextWidth: chatColumn.maxTextWidth
                    fontSize: chatColumn.fontSize
                    lastMessageComplete: 1  // The first message, so forces it to show

                    onMessageWritten: unameAsk.lastMessageComplete = 1
                }

                ChatBubble {
                    id: unameAsk

		    scaleFactorX: bgScaleFactorX
		    scaleFactorY: bgScaleFactorY

                    message: "Anyway, who is trying to access my system?"
                    maxTextWidth: chatColumn.maxTextWidth
                    fontSize: chatColumn.fontSize

                    onMessageWritten: userField.lastMessageComplete = 1
                }


                ChatInput {
                    id: userField

                    maxTextWidth: chatColumn.maxTextWidth
                    inactivityContainer: inactivityTimer
		    scaleFactorX: bgScaleFactorX
		    scaleFactorY: bgScaleFactorY

                    borderColour: config.InputBorderColour
                    textColour: config.InputColour
                    cursorColour: config.InputCursorColour
                    fontSize: chatColumn.fontSize

                    anchors.right: parent.right

                    onSubmitted: {
			passAsk.lastMessageComplete = 1
			currentTextInput = passField.textInput
		    }
                }

                ChatBubble {
                    id: passAsk

		    scaleFactorX: bgScaleFactorX
		    scaleFactorY: bgScaleFactorY

                    message: "Hmmmm interesting..."
                    maxTextWidth: chatColumn.maxTextWidth
                    fontSize: chatColumn.fontSize

                    onMessageWritten: passField.lastMessageComplete = 1
                }

                ChatInput {
                    id: passField

                    inputType: TextInput.Password
                    maxTextWidth: chatColumn.maxTextWidth
                    inactivityContainer: inactivityTimer
		    scaleFactorX: bgScaleFactorX
		    scaleFactorY: bgScaleFactorY

                    borderColour: config.InputBorderColour
                    textColour: config.InputColour
                    cursorColour: config.InputCursorColour
                    fontSize: chatColumn.fontSize

                    anchors.right: parent.right

                    onSubmitted: {
			sddm.login(
			    userField.textInput.text,
			    passField.textInput.text,
			    sessions.sessionSelection.currentIndex  // uses the selected session
			)
		    }
                }
            }

	    ChatBubble {
		id: centreMessage

		scaleFactorX: bgScaleFactorX
		scaleFactorY: bgScaleFactorY

		message: "---- Chat Ended ----"
		fontSize: chatColumn.fontSize

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter

		enableTypingEffect: false

		lastMessageComplete: 0		 
	    }
        }
    }
}
