import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Data"
import "../Assets"

Rectangle {
    id: root
    required property PanelWindow bar
    required property PopupWindow sound_popup
    Layout.preferredWidth: childrenRect.width + 25
    Layout.fillHeight: true
    color: Colors.withAlpha(Colors.background, 0.9)
    border.color: Colors.primary
    border.width: 2

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 12

        function zeroPad(num, size) {
            var s = num + "";
            while (s.length < size) {
                s = "0" + s;
            }
            return s;
        }

        SoundWidget {
            popup: root.sound_popup
        }

        Rectangle {
            id: rect
            implicitWidth: infos.width - 10
            Layout.fillHeight: true
            color: "transparent"
            property bool hovering: false
            Text {
                id: infos
                anchors.centerIn: parent
                property var data: Infos.data
                font.pointSize: 12
                font.family: "0xProto Nerd Font"
                font.bold: true
                color: rect.hovering ? Colors.error : Colors.secondary
                text: infos.data ? " %1/%2k  %3  %4  %5".arg(row.zeroPad(infos.data.net_rx, 4)).arg(row.zeroPad(infos.data.net_tx, 2)).arg(infos.data.cpu).arg(infos.data.mem).arg(infos.data.disk) : "The void"
            }
            Process {
                id: process_btop
                running: false
                command: ["kitty", "--app-id=kitty.btop", "-e", "btop"]
            }
            MouseArea {
                anchors.fill: infos
                hoverEnabled: true
                onEntered: {
                    rect.hovering = true;
                }
                onExited: {
                    rect.hovering = false;
                }
                onClicked: {
                    if (process_btop.running) {
                        process_btop.running = false;
                    } else {
                        process_btop.running = true;
                    }
                }
            }
        }
        PowerWidget {
            bar: root.bar
        }
    }
}
