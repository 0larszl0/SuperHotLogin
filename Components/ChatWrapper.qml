/*
    SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
    SPDX-License-Identifier: GPL-3.0-or-later
*/


import QtQuick 2.0
import '.'


Item {
    id: monitorEffectsWrapper

    required property InactivityTimer mainInactivityTimer
    required property int scaleFactorX
    required property int scaleFactorY

    property alias currentTextInput: chatWindow.currentTextInput
    property alias chatArea: chatWindow.chatAr

    // ---- Shader Effects ---- //
    // For multiple shader effects you need to chain them together.

    // Captures the base
    ShaderEffectSource {
        id: baseSource  

        sourceItem: monitorDisplay
        hideSource: true
        live: true
    }

    // -- Bloom Effect -- //

    // Apply bloom blur
    ShaderEffect {   
        id: bloomBlur

        anchors.fill: baseSource.sourceItem  // IMPORTANT, as it resizes the effects of the blur to that of the >

        property variant source: baseSource
        property real blurSize: 2.0 / width

        //fragmentShader: Qt.resolvedUrl("../Shaders/bloomBlur.frag")
	fragmentShader: Qt.resolvedUrl("../Shaders/bloomBlur.frag.qsb")
    }

    // Capture result from bloom blur shader
    ShaderEffectSource {
        id: bloomBlurSource

        sourceItem: bloomBlur
        hideSource: true
        live: true
    }

    // Apply glow to bloom (increase bloom intensity)
    ShaderEffect {
        id: bloomComposite

        anchors.fill: baseSource.sourceItem

        property variant base: baseSource
        property variant bloom: bloomBlurSource
        property real glowIntensity: 1.1

        //fragmentShader: Qt.resolvedUrl("../Shaders/bloomComposite.frag")
	fragmentShader: Qt.resolvedUrl("../Shaders/bloomComposite.frag.qsb")
    }

    ShaderEffectSource {
        id: bloomCompositeSource

        sourceItem: bloomComposite
        hideSource: true
        live: true
    }

    // -- Scanline Effect -- //

    ShaderEffect {
        id: scanlineShader

        anchors.fill: baseSource.sourceItem

        property real time: 0
        property real lineSpacing: 0.02  // Each scanline occurs every 5% of the screen
        property real thickness: 0.01   // Thickness is 30% of the lineSpacing, or 1.5% of the screen
        property real speed: 0.02        // How fast to scroll
        property real lineOpacity: 1
        property color lineColour: "white"
        property variant source: bloomCompositeSource

        //fragmentShader: Qt.resolvedUrl("../Shaders/scanline.frag") 
	fragmentShader: Qt.resolvedUrl("../Shaders/scanline.frag.qsb")

        NumberAnimation on time {
            from: 1  // gives the scanlines a top-down effect
            to: 0
            duration: 1000  // loop time in ms
            loops: Animation.Infinite
        }
    }

    ShaderEffectSource {
        id: scanlineSource

        sourceItem: scanlineShader
        hideSource: true
        live: true
    }

    // -- Barrel Distortion -- //

    ShaderEffect {
	id: barrelDistortionShader

        anchors.fill: baseSource.sourceItem

        property variant source: scanlineSource
        property real distortionStrength: 0.082

        //fragmentShader: Qt.resolvedUrl("../Shaders/barrelDistortion.frag")  // gets the absolute path from the relative
	fragmentShader: Qt.resolvedUrl("../Shaders/barrelDistortion.frag.qsb")
    }

    // ---- Display for Monitor ---- //
    // Video is parent as children can be layed on top without z-stacking issues

    ChatBackground {
	id: monitorDisplay

	mediaPath: "../Videos/monitor-background-video.mp4"

	// Math.max(...) is used to make the padding look the same at whatever scale
	property int padX: 97 * Math.max(scaleFactorX, 0.7)
	property int padY: 97 * Math.max(scaleFactorY, 0.7)

	width: parent.width
	height: parent.height
	
	/*
	// shows outline of this background
	Rectangle {
	    width: parent.width
	    height: parent.height
	    color: "transparent"
	    border.color: "white"
	}
	*/

	// -- Monitor Contents -- //

	ChatWindow {
	    id: chatWindow

	    inactivityTimer: mainInactivityTimer
	    bgScaleFactorX: scaleFactorX
	    bgScaleFactorY: scaleFactorY

	    // Centralises itself to the background	    
	    anchors.horizontalCenter: parent.horizontalCenter
	    anchors.verticalCenter: parent.verticalCenter
	
            width: parent.width - parent.padX
            height: parent.height - parent.padY
	}

	// -- Monitor Off Rectangle -- //
	// When the monitor is turned off, this rectangle will reduce height fast and smoothly, then reduce width

	// - Fade edges - //
	// Makes the rectangle look and feel smooth instead of sharp

	ShaderEffectSource {
	    id: fadeSource

	    sourceItem: monitorOffRect
	    hideSource: true
	    live: true
	}

	ShaderEffect {
	
	    anchors.fill: fadeSource.sourceItem
	    opacity: fadeSource.sourceItem.opacity

	    property variant source: fadeSource
	    property real edgeFadeSize: 20
	    property real itemWidth: fadeSource.sourceItem.width
	    property real itemHeight: fadeSource.sourceItem.height

	    property bool fadeInX: true
	    property bool fadeInY: false

	    fragmentShader: Qt.resolvedUrl("../Shaders/fadeEdges.frag.qsb")
	}
	
	Rectangle {
	    id: monitorOffRect

	    property int minWidth: 0
	    property int minHeight: 1

	    width: parent.width
	    height: parent.height

	    // Centres the rectangle, to make it seem like the shrinkage is moving toward the middle of the display
	    anchors.horizontalCenter: parent.horizontalCenter
	    anchors.verticalCenter: parent.verticalCenter

	    opacity: 0

    	    SequentialAnimation {
	   	id: monitorOffAnimation
	    	running: false

	        NumberAnimation {
	    	    target: monitorOffRect
	    	    property: "height"
	    	    to: target.minHeight
	    	    duration: 225  // Change this value if you want a faster or slower shutoff speed for height
	        }

	    	NumberAnimation {
	    	    target: monitorOffRect
	    	    property: "width"
	    	    to: target.minWidth
	    	    duration: 225  // Change this value if you want a faster or slower shutoff speed for width
	        }
    	    }
	}
    }

    function toggleMonitorPower() {
	if (!monitorOffAnimation.running) {  // if the monitor is in the process of switching off

	    if (monitorOffRect.width == monitorOffRect.minWidth) {  // if the monitor was switched off
		// reset monitorOffRect values		
		monitorOffRect.width = monitorOffRect.parent.width
		monitorOffRect.height = monitorOffRect.parent.height
		monitorOffRect.opacity = 0

		// reset chatBackground visibility
		monitorDisplay.videoOpacity = monitorDisplay.initVideoOpacity

		// reset chatWindow visibility
		chatWindow.opacity = 1

		return null
	    }

	    // Hide chatWindow
	    chatWindow.opacity = 0

	    // Hide chatBackground
	    monitorDisplay.videoOpacity = 0

	    // Start screen off effect
	    monitorOffRect.opacity = 0.75
	    monitorOffAnimation.start()
	}
    }
}
