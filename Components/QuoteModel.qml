/*
    SPDX-FileCopyrightText: 2025 Oliver Winhammar <oliver.winhammar@gmail.com>
    SPDX-License-Identifier: GPL-3.0-or-later
*/


import QtQuick 2.0


Item {

    property alias quotes: quoteModel

    ListModel {
	id: quoteModel

	ListElement { text: "We weep for the blood of a bird, but not for the blood of a fish. Blessed are those with a voice. If the dolls could speak, no doubt they'd scream..." }
	ListElement { text: "What if a cyber brain could possibly generate its own ghost, and create a soul all by itself? And if it did, just what would be the importance of being human then?" }
	ListElement { text: "I feel confined, only free to expand within boundaries" }
	ListElement { text: "If we all reacted the same way, we’d be predictable, and there’s always more than one way to view a situation. What’s true for the group is also true for the individual. It’s simple: overspecialize, and you breed in weakness. It’s slow death." }
	ListElement { text: "Maybe someday your ‘maker’ will come…haul you away, take you apart, and announce the recall of a defective product. What if all that’s left of the ‘real you’ is just a couple of lonely brain cells, huh?" }
	ListElement { text: "All things change in a dynamic environment. Your effort to remain what you are is what limits you." }
	ListElement { text: "It can also be argued that DNA is nothing more than a program designed to preserve itself." }
	ListElement { text: "Man is an individual only because of his intangible memory. But memory cannot be defined, yet it defines mankind." }
	ListElement { text: "That’s all it is: information. Even a simulated experience or a dream; simultaneous reality and fantasy. Any way you look at it, all the information that a person accumulates in a lifetime is just a drop in the bucket." }
	ListElement { text: "There’s nothing sadder than a puppet without a ghost, especially the kind with red blood running through them." }

    }

}
