pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import "../Data"
import "../MenuWidgets"

PopupWindow {
    id: win
    required property PanelWindow bar
    color: "transparent"
    // color: Colors.error
    visible: false
    anchor.window: bar
    anchor.rect.y: bar.height + 0
    anchor.rect.x: 0
    implicitWidth: bar.width
    implicitHeight: rows.height

    function toggleVisibility() {
        if (win.visible) {
            this.hide();
        } else {
            this.show();
        }
    }
    function show() {
        win.visible = true;
        rows.state = "Open";
        hideTimer.stop();
    }
    function hide() {
        hideTimer.start();
    }

    Timer {
        id: hideTimer
        interval: 500
        running: false
        onTriggered: {
            rows.state = "Closed";
        }
    }

    ColumnLayout {
        id: rows
        anchors.centerIn: parent
        spacing: 5
        property var windows: Niri.windows

        state: "Closed"
        states: [
            State {
                name: "Open"
                PropertyChanges {
                    rows.opacity: 1
                }
            },
            State {
                name: "Closed"
                PropertyChanges {
                    rows.opacity: 0
                }
            }
        ]

        onOpacityChanged: {
            if (opacity == 0) {
                win.visible = false;
            }
        }

        MouseArea {
            Layout.alignment: Qt.AlignLeft
            // anchors.fill: parent
            hoverEnabled: true
            onExited: {
                rows.state = "Closed";
            }
            onEntered: {
                hideTimer.stop();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 160
            }
        }

        Repeater {
            model: rows.windows
            delegate: WindowItem {
                anchors.horizontalCenter: rows.horizontalCenter
            }
        }
    }
}
