pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../Assets"
import "../Data"

PopupWindow {
    id: win
    required property PanelWindow bar
    property var x
    property var y

    color: "transparent"
    visible: false
    anchor.window: bar
    anchor.rect.x: this.x
    anchor.rect.y: this.y
    width: rows.width
    height: rows.height + 10

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
        onTriggered: {
            rows.state = "Closed";
        }
    }

    RowLayout {
        id: rows
        width: 80 * rows.workspaces.length
        anchors.centerIn: parent
        spacing: 0
        property var workspaces: Niri.workspaces
        property var activedWorkspace: Niri.activedWorkspace

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
            anchors.fill: parent
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
            model: rows.workspaces
            delegate: Rectangle {
                id: square
                required property var modelData

                height: 30
                width: 80
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: rows.activedWorkspace === square.modelData.name ? Colors.withAlpha(Colors.primary, 0.7) : Colors.withAlpha(Colors.background, 0.7)
                border.color: Colors.primary
                border.width: 2
                Text {
                    font.pointSize: 12
                    font.family: "0xProto Nerd Font"
                    font.bold: true
                    color: Colors.secondary
                    anchors.centerIn: parent
                    text: square.modelData.name ?? "TEMP"
                }
                Process {
                    id: process
                    running: false
                    command: ["niri", "msg", "action", "focus-workspace", square.modelData.name]
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        process.running = true;
                        // rows.state = "Closed";
                    }
                }
            }
        }
    }
}
