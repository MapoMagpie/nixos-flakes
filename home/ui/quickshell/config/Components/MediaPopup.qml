pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../MenuWidgets"
import "../Assets"

PopupWindow {
    id: win
    required property PanelWindow bar

    visible: false
    color: "transparent"
    anchor.window: bar
    anchor.rect.x: bar.width - width - 10
    anchor.rect.y: bar.height + 10
    implicitWidth: 500
    implicitHeight: column.height

    function toggleVisibility() {
        if (win.visible) {
            column.state = "Closed";
        } else {
            win.visible = true;
            column.state = "Open";
        }
    }

    ColumnLayout {
        id: column
        width: parent.width
        anchors.top: parent.top
        spacing: 8

        state: "Closed"
        states: [
            State {
                name: "Open"
                PropertyChanges {
                    column.opacity: 1
                }
            },
            State {
                name: "Closed"
                PropertyChanges {
                    column.opacity: 0
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
            id: mpris
            color: Colors.withAlpha(Colors.surface, 0.70)
            Layout.preferredWidth: parent.width - 10
            implicitHeight: 250
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            border {
                color: Colors.primary
                width: 2
            }
            MprisCardWidget {
                width: parent.width - 4
                height: parent.height - 4
                anchors.centerIn: parent
            }

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: -5
                anchors.leftMargin: -5
                height: headerText.height + 5
                width: headerText.width + 10
                color: Colors.primary

                Text {
                    id: headerText
                    anchors.centerIn: parent
                    text: "Mpris"
                    color: Colors.on_primary
                }
            }
        }

        SoundChannelWidget {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.preferredWidth: parent.width - 10
        }
    }
}
