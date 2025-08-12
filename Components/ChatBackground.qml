/*
    SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
    SPDX-License-Identifier: GPL-3.0-or-later
*/


import QtQuick 2.0
import QtMultimedia 6.0


Item {

    required property string mediaPath

    property real initVideoOpacity: 0.75
    property real videoOpacity: initVideoOpacity

    Connections {
	target: Qt.application

	function onAboutToQuit() {  // when SIGINT has been passed
	    mediaPlayer.stop()  // stop video, to prevent application from hanging-- prevalent in test-mode
	}
    }
    
    MediaPlayer {
	id: mediaPlayer

	source: Qt.resolvedUrl(mediaPath)
	videoOutput: mediaOutput  // this is the way to reference VideoOutput in qt6
	autoPlay: true
	loops: 1  // MediaPlayer.Infinite doesn't work reliably in qt6-- only loops once :(

	onMediaStatusChanged: {
	    if (mediaStatus === MediaPlayer.EndOfMedia) {  // in the event the mediaplayer were to terminate on itself
		pause()
		position = 0  // tells MediaPlayer to go to position 0ms, i.e. the start of the current media
		play()  // restarts playback
	    }
	}
    }

    ShaderEffectSource {
	id: cornerCutSource

	sourceItem: mediaOutput
	live: true
	hideSource: true
    }
    
    ShaderEffect {
	id: cornerCut
	
        anchors.fill: cornerCutSource.sourceItem
	opacity: cornerCutSource.sourceItem.opacity

        property variant source: cornerCutSource
        property real radius: 0.99 // from 0 (large radius) to 1 (low radius)-- think of it like how far from the center does the radius need to be

        //fragmentShader: Qt.resolvedUrl("../Shaders/videoFrame.frag")  // used in qt5 to compile in runtime
	fragmentShader: Qt.resolvedUrl("../Shaders/videoFrame.frag.qsb")
    }

    ShaderEffectSource {
	id: edgeFadeSource

	sourceItem: cornerCut
	live: true
	hideSource: true
    }

    ShaderEffect {
	
	anchors.fill: cornerCutSource.sourceItem
	opacity: cornerCutSource.sourceItem.opacity	

	property variant source: edgeFadeSource
	property real edgeFadeSize: 40
	property real itemWidth: parent.width
	property real itemHeight: parent.height

	property bool fadeInX: true
	property bool fadeInY: true

	//fragmentShader: Qt.resolvedUrl("../Shaders/fadeEdges.frag")
	fragmentShader: Qt.resolvedUrl("../Shaders/fadeEdges.frag.qsb")
    }
    
    VideoOutput {
	id: mediaOutput

	//source: mediaPlayer  // this is how you'd reference the mediaPlayer in qt5, in qt6 it's the other way round
	fillMode: VideoOutput.Stretch
	opacity: videoOpacity

	anchors.fill: parent
    }    
}
