pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import "../Widgets"

Scope {
    PanelWindow {
        id: bar
        height: 28
        color: "transparent"

        margins {
            top: 4
            bottom: 0
            left: 4
            right: 4
        }

        anchors {
            top: true
            left: true
            right: true
        }

        Rectangle {
            id: barShape

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            color: "transparent"
            anchors.centerIn: parent
            height: parent.height
            width: parent.width
            RowLayout {
                // left
                spacing: 10
                layoutDirection: Qt.LeftToRight
                anchors.left: parent.left
                height: parent.height

                ClockWidget {
                    bar: bar
                }
                WorkspacesWidget {
                    bar: bar
                }
            }

            RowLayout {
                // Centre
                spacing: 0
                anchors.centerIn: parent
                height: parent.height

                ActionWindowWidget {
                    bar: bar
                }
            }

            RowLayout {
                // Right
                spacing: 10
                anchors.right: parent.right
                height: parent.height

                MprisWidget {
                    bar: bar
                }
                RecordingWidget {
                    bar: bar
                }
                SysInfoWidget {
                    bar: bar
                }
                TrayWidget {
                    bar: bar
                }
                NotifitionWidget {
                    bar: bar
                }
            }
        }
    }
}
