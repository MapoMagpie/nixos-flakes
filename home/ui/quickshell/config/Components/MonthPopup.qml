pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls

import "../Assets"
import "../Data"

PopupWindow {
    id: win
    required property PanelWindow bar

    visible: true
    color: "transparent"
    anchor.window: bar
    anchor.rect.x: 0
    anchor.rect.y: bar.height
    width: 330
    height: 250

    function toggleVisibility() {
        if (win.visible) {
            baseRect.state = "Closed";
        } else {
            win.visible = true;
            baseRect.state = "Open";
        }
    }

    Rectangle {
        id: baseRect
        color: Colors.withAlpha(Colors.secondary_container, 0.70)
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        // MouseArea {
        //     anchors.fill: parent
        //     hoverEnabled: true
        //     onExited: {
        //         baseRect.state = "Closed";
        //     }
        // }

        state: "Closed"
        states: [
            State {
                name: "Closed"
                PropertyChanges {
                    baseRect.opacity: 0
                }
            },
            State {
                name: "Open"
                PropertyChanges {
                    baseRect.opacity: 1
                }
            }
        ]
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        onOpacityChanged: if (opacity == 0) {
            win.visible = false;
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                implicitWidth: 30
                Layout.fillHeight: true
                color: Colors.secondary

                Text {
                    rotation: -90
                    anchors.centerIn: parent
                    color: Colors.on_secondary
                    text: Time.data?.dayName + ", " + Time.data?.monthName + " " + Time.data?.year
                    font.pointSize: 13
                    font.italic: true
                }
            }

            MonthGrid {
                id: cal
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 10
                spacing: 5
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        baseRect.state = "Open";
                    }
                    onExited: {
                        baseRect.state = "Closed";
                    }
                    // onWheel: {
                    //     cal.month = cal.month + 1;
                    // }
                }

                delegate: Rectangle {
                    id: calRect
                    required property var model
                    color: (model.month === cal.month) ? (calRect.model.day == Time.data?.dayNumber) ? Colors.tertiary : Colors.secondary : Colors.on_secondary

                    Text {
                        anchors.centerIn: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignVCenter
                        text: calRect.model.day
                        color: (calRect.model.month === cal.month) ? (calRect.model.day == Time.data?.dayNumber) ? Colors.on_tertiary : Colors.on_secondary : Colors.secondary
                    }
                }
            }
        }
    }
}
