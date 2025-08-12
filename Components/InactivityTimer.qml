/*
    SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
    SPDX-License-Identifier: GPL-3.0-or-later
*/


import QtQuick 2.0


Item {
    id: inactivityContainer

    property int timeout: 5000
    property bool idle: true

    signal userInActive()
    signal userActive()

    Timer {
	id: inactivityTimer

	interval: timeout
	repeat: false  // only has to do one interval to make the change
	
        onTriggered: {
	    userInActive()
	    idle = true
	}
    }

    function resetInactivity() {
	if (idle) {  // checks if was inactive-- saves sending redundant signals
	    userActive();  // send an event signal, that signifies a present and active user
	    idle = false;
	}

	inactivityTimer.restart();  // restart timer
    }
}
