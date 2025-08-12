/*
    SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
    SPDX-License-Identifier: GPL-3.0-or-later
*/


import QtQuick 2.0
//import QtQuick.Controls 2.15
import '.'

/*
Note to self, if ever debugging in the future, sddm actions like login, shutdown, or reboot, don't get
simulated in sddm-greeter or in qmlscene, hence the text for maxAttempt - 1 that's under the Connections 
section will not work properly.

Additionally, SDDM for some strange reason sends two onLoginFailed responses per login attempt...
For devs looking at this, I've ensured that it is not because of this theme as it is replicated in 
other official themes such as breeze. Hence you'll notice everything that relies on the number of 
loginAttempts is multiplied by, or has a compared value that is a multiple of, two.
*/


Item {
    id: loginActivityContainer

    required property SmoothColourOverlay warningOverlay
    required property SmoothColourOverlay lowLightOverlay
    required property Rectangle chatArea

    // This section of properties should try to match the appropriate values in /etc/security/faillock.conf
    property int maxAttempts: parseInt(config.MaxLoginAttempts) * 2  // deny
    property int failInterval: parseInt(config.FailInterval)
    property int unlockTime: parseInt(config.UnlockTime)

    property int loginAttempts: 0

    /*
    // Debug buttons for loginAttempts
    // Note, get a thorough understanding of how this file works! You may get unexpected outputs when you reach
    // maxAttempts - 1, cos usually additional things under sddm.onLoginFailed occur, but in testing it does not
    Button {
	background: Rectangle { color: "red" }
	width: 100
	height: 100
	anchors.horizontalCenter: parent.horizontalCenter

	onClicked: {
	    chatArea.chatCol.resetChat()
	    loginAttempts += 2
	}
    }

    Button {
	onClicked: loginAttempts -= 2
    }
    */

    states: [
	State {
	    when: loginAttempts === 0
	    PropertyChanges { target: failedResetTimer; running: false }  // doesn't need to decrement loginAttempts when already at minimum
	},

	State {
	    when: loginAttempts === maxAttempts - 2  // the last login attempt
	    PropertyChanges { target: failedResetTimer; running: true }
	    PropertyChanges { target: warningOverlay; transitionActive: true; opacity: warningOverlay.maxOpacity }
	},

	State {
	    when: loginAttempts === maxAttempts
	    PropertyChanges { target: warningOverlay; transitionActive: false }
	    PropertyChanges { target: lowLightOverlay; opacity: lowLightOverlay.maxOpacity }
	    PropertyChanges { target: failedResetTimer; running: false }
	    PropertyChanges { target: unlockTimer; running: true}
	    PropertyChanges { target: chatArea.chatCol.quoteBubble; lastMessageComplete: 0 }
	    PropertyChanges { target: chatArea.soloMessage; lastMessageComplete: 1 }
	}
    ]

    Timer {
	id: failedResetTimer

	running: false
	repeat: true
	interval: failInterval * 1000  // puts it in ms

	onTriggered: {
	    if (loginAttempts > 0) {
		loginAttempts -= 2
		chatArea.chatCol.quoteBubble.changeMessage("HELLLOOOOO?? Anyone at home? I mean if you want in, just get the login correct, EZ :)")
	    }

	    if (loginAttempts == maxAttempts - 2) {  // if loginAttempts has become one less than the warningOverlay threshold 
		warningOverlay.transitionActive = false  // stop the warning overlay
	    }
	}
    }

    Timer {
	id: unlockTimer

	running: false
	repeat: false
	interval: unlockTime * 1000

	onTriggered: {
	    loginAttempts = 0
	    lowLightOverlay.opacity = 0

	    // Any message changes should be made before the property 'lastMessageComplete' is updated.
	    // Don't need to use .changeMessage(...) here
	    chatArea.chatCol.quoteBubble.message = "Hey! You actually stuck around?! Obviously someone's desperate to get in ;)"
	    chatArea.chatCol.quoteBubble.lastMessageComplete = 1
	    chatArea.soloMessage.lastMessageComplete = 0

	    stop()
	}
    }

    Connections {
	target: sddm

	function onLoginSucceeded() {
	    loginAttempts = maxAttempts  // closes all processes
	    lowLightOverlay.opacity = 0  // refuse the darkness
	    
	}

	function onLoginFailed() {
	    chatArea.chatCol.resetChat()  // reset the chat to await new changes after loginAttempts has been incremented
	    loginAttempts += 1
	    
	    if (loginAttempts === maxAttempts - 2) {
		chatArea.chatCol.quoteBubble.changeMessage("Are you sure you are who you say you are?")
	    }	
	}
    }
}

