import QtQuick
import Quickshell
import Quickshell.Io
import "../Assets"

Rectangle {
    id: root
    property bool hovering: false
    required property PanelWindow bar
    property string runningTime: "00:00:00"

    visible: false
    height: parent.height
    width: 100
    color: root.hovering ? Colors.withAlpha(Colors.on_primary, 1.0) : Colors.withAlpha(Colors.background, 0.9)
    border.color: Colors.error
    border.width: 2

    // ShaderEffect {
    //     width: parent.width - 8
    //     height: parent.height - 8
    //     anchors.centerIn: parent
    //     property real time: 0.0
    //     property var resolution: Qt.size(1.0, 1.0)
    //     property real brightness: 0.5
    //     // blending: true
    //     fragmentShader: "../Assets/ani.frag.qsb"
    //     Timer {
    //         interval: 16
    //         running: true
    //         repeat: true
    //         onTriggered: parent.time += 0.010
    //     }
    // }

    Process {
        id: process
        running: true
        command: ["sh", "-c", "ps -p $(pidof wf-recorder) -o etime="]
        stderr: SplitParser {
            onRead: data => {
                root.visible = false;
                timer.stop();
            }
        }
        stdout: SplitParser {
            onRead: data => {
                if (/\d{2}:\d{2}/.test(data)) {
                    root.runningTime = data.trim();
                    if (!root.visible) {
                        root.visible = true;
                        timer.start();
                    }
                }
            }
        }
    }

    Timer {
        id: timer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            process.running = true;
        }
    }

    Text {
        id: indicateText
        anchors.centerIn: parent
        font.pointSize: 12
        font.family: "0xProto Nerd Font"
        font.bold: true
        color: Colors.secondary
        //  https://unicodes.jessetane.com/%EF%80%BD
        text: "  " + root.runningTime
    }

    IpcHandler {
        target: "recording"
        function setStatus(running: bool): bool {
            root.visible = running;
            if (root.visible) {
                timer.start();
            } else {
                timer.stop();
            }
            return true;
        }
    }

    Process {
        id: process_stop
        running: false
        command: ["pkill", "wf-recorder"]
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            root.hovering = true;
        }
        onExited: {
            root.hovering = false;
        }
        onClicked: {
            process_stop.running = true;
        }
    }
}
