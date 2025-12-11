/*****************************************************************************
* SuperHotLogin SDDM Theme
* Copyright (C) 2025 Oliver Winhammar
*
* This file is part of SuperHotLogin.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <https://www.gnu.org/licenses/>.
*
****************************************************************************/


import QtQuick 2.0
import QtQuick.Window 2.2  // To get the screen's width and height primarily
import "Components"


Item {
    id: main
    
    width: Screen.width
    height: Screen.height

    // ---- Set Inactivity Timer (for inputs) ---- //

    InactivityTimer {
    	id: globalInactivityTimer
    	timeout: 4000
    }

    Image {
	id: monitorBg

	property string defaultBackgroundUrl: "Images/the-setup.png"
	property string backgroundUrl: defaultBackgroundUrl
	property real scaleFactorX: paintedWidth / sourceSize.width
	property real scaleFactorY: paintedHeight / sourceSize.height

	// Matches parent dimensions for image fill
	width: parent.width
	height: parent.height

	source: Qt.resolvedUrl(backgroundUrl)
	fillMode: Image.PreserveAspectCrop
    }

    PowerPress {
	id: rigPowerButton

	monitorBackground: monitorBg
	backgroundSwitchUrl: "Images/rig-shutdown-press.png"
	activeTextArea: chatWrapper.currentTextInput
	
	positionX: 110
	positionY: 561

	buttonWidth: 33
	buttonHeight: 37

	onReleased: sddm.powerOff()

    }
    
    PowerPress {
	id: monitorPowerButton

	monitorBackground: monitorBg
	backgroundSwitchUrl: "Images/monitor-poweroff-press.png"
	activeTextArea: chatWrapper.currentTextInput

	positionX: 1011
	positionY: 814

	buttonWidth: 23
	buttonHeight: 26

	onReleased: chatWrapper.toggleMonitorPower()
    }

    PowerPress {
	id: rigRestartButton

	monitorBackground: monitorBg
	backgroundSwitchUrl: "Images/rig-restart-press.png"
	activeTextArea: chatWrapper.currentTextInput

	positionX: 110
	positionY: 626

	buttonWidth: 33
	buttonHeight: 37

	onReleased: sddm.reboot()

    }

    ChatWrapper {
	id: chatWrapper

	property real monitorBgLeftOffset: -((monitorBg.paintedWidth / 2) - (width / 2))
        property real monitorBgTopOffset: -((monitorBg.paintedHeight / 2) - (height / 2))

	// properties to make the distortion fit the monitor screen from the original/undistorted size
	property int distortionOffsetX: 26
	property real distortionWidthLost: 1.075
	property int distortionOffsetY: 21
	property real distortionHeightLost: 1.1

	mainInactivityTimer: globalInactivityTimer

        // Not applying a min/max here, so I can pass the scaleFactor variables by reference instead of by value
	scaleFactorX: monitorBg.scaleFactorX
	scaleFactorY: monitorBg.scaleFactorY
	
	// Offset positions here so child objects can simply inherit them
	// Also assume any raw value inputted are specially calculated or inspected, DO NOT CHANGE THEM
	anchors.horizontalCenter: monitorBg.horizontalCenter
	anchors.horizontalCenterOffset: monitorBgLeftOffset + ((356 - distortionOffsetX) * monitorBg.scaleFactorX)

	anchors.verticalCenter: monitorBg.verticalCenter
	anchors.verticalCenterOffset: monitorBgTopOffset + ((207 - distortionOffsetY) * monitorBg.scaleFactorY)

        // Adjusts width and height to match scaling of fillMode
        width: monitorBg.paintedWidth * (0.466 * distortionWidthLost)
        height: monitorBg.paintedHeight * (0.487 * distortionHeightLost)

	z: 1
    }

    SmoothColourOverlay {
        id: redOverlay

        property bool transitionActive: false

        maxOpacity: 0.2
        transitionSpeed: 0.04
        colour: "red"

        anchors.fill: parent
        z: 2

        onOpacityChanged: {  // this simply makes the opacity value continously bounce between 0 and maxOpacity
            // if the opacity val has reached the upper or lower limit, bounce to the other limit
            if (opacity === maxOpacity || opacity === 0.0) {

                // check if the transitions should stop and when the overlay effect has died down
                if (!transitionActive && opacity === 0.0 ) { return null }

                // otherwise bounce to the opposite limit
                opacity = maxOpacity - opacity
            }
        }
    }

    SmoothColourOverlay {
        id: darkOverlay  

        maxOpacity: 0.6
        transitionSpeed: 0.1
        colour: "black"

        anchors.fill: parent
    }


    // any overlays within here will automatically be on top
    LoginConsequences { 
	warningOverlay: redOverlay
	lowLightOverlay: darkOverlay
	chatArea: chatWrapper.chatArea

	anchors.fill: parent
    }

}
