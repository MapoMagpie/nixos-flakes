pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import "../Widgets"
import "../Assets"

Scope {
    PanelWindow {
        id: bar
        height: 28
        color: "transparent"

        margins {
            top: 3
            bottom: 3
            left: 3
            right: 3
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

                ActionWindowWidget {}
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
