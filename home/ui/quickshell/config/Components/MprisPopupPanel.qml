pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../Data"
import "../MenuWidgets"
import "../Assets"

PopupWindow {
    id: win
    required property PanelWindow bar
    color: "transparent"
    visible: false

    anchor.window: bar
    anchor.rect.x: bar.width - width - 10
    anchor.rect.y: bar.height + 10
    width: 500
    height: cardbox.height

    function toggleVisibility() {
        if (win.visible) {
            cardbox.state = "Closed";
        } else {
            win.visible = true;
            cardbox.state = "Open";
        }
    }

    ColumnLayout {
        id: cardbox
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        state: "Closed"
        states: [
            State {
                name: "Open"
                PropertyChanges {
                    cardbox.opacity: 1
                }
            },
            State {
                name: "Closed"
                PropertyChanges {
                    cardbox.opacity: 0
                }
            }
        ]

        onOpacityChanged: {
            if (opacity == 0) {
                win.visible = false;
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 160
            }
        }

        Rectangle {
            // FIRST CARD
            color: Colors.withAlpha(Colors.background, 0.79)
            Layout.fillWidth: true
            Layout.preferredHeight: 240
            RowLayout {
                spacing: 5
                anchors.fill: parent

                ColumnLayout {
                    // slider and mpris
                    Layout.preferredWidth: 3
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: 10
                    Layout.rightMargin: 5
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: 1
                        spacing: 10

                        Repeater {
                            model: [
                                {
                                    node: Audio.sink,
                                    colors: [Colors.on_tertiary_container, Colors.tertiary_container],
                                    icon: Audio.volIcon
                                },
                                {
                                    node: Audio.source,
                                    colors: [Colors.on_secondary_container, Colors.secondary_container],
                                    icon: Audio.micIcon
                                },
                            ]

                            GenericAudioSlider {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                required property var modelData
                                node: modelData.node
                                foregroundColor: modelData.colors[0]
                                backgroundColor: modelData.colors[1]
                                icon: modelData.icon
                            }
                        }
                    }

                    MprisWidget {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: 5
                    }
                }
            }
        }
    }
}
