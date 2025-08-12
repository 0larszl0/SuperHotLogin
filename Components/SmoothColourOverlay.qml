/*
    SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
    SPDX-License-Identifier: GPL-3.0-or-later
*/


import QtQuick 2.0


Item {
    id: overlay

    required property real maxOpacity
    required property real transitionSpeed
    required property string colour

    opacity: 0.0

    Rectangle {
    	anchors.fill: parent
    	color: colour    	
    }

    Behavior on opacity {  // when opacity changes use the ease-in/ease-out curve to adjust to the new value
        SmoothedAnimation { velocity: overlay.transitionSpeed / overlay.maxOpacity }
    }
}
