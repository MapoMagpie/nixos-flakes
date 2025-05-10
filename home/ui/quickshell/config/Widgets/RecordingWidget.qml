import QtQuick
import Quickshell
import Quickshell.Io
import "../Assets"

Rectangle {
    id: root
    property bool active: false
    required property PanelWindow bar
    property string runningTime: "00:00:00"

    visible: false
    implicitHeight: parent.height
    implicitWidth: indicateText.implicitWidth + 20
    color: root.active ? Colors.withAlpha(Colors.on_primary, 0.8) : Colors.withAlpha(Colors.background, 0.8)
    border.color: Colors.primary
    border.width: 2

    ShaderEffect {
        anchors.fill: parent
        property real time: 0.0
        property var resolution: Qt.size(60, 30)
        fragmentShader: "../Assets/ani.frag.qsb"
        Timer {
            interval: 16
            running: true
            repeat: true
            onTriggered: parent.time += 0.026
        }
    }
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
        onClicked: {
            process_stop.running = true;
        }
    }
}
