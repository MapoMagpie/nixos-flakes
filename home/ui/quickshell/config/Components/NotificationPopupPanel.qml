pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "../Data"
import "../MenuWidgets"
import "../Assets"

PopupWindow {
    id: win
    required property PanelWindow bar
    property int notifCount: NotifServer.notifCount
    property bool showAll: false
    color: "transparent"
    visible: false

    onNotifCountChanged: {
        if (win.showAll) {
            notiModel.values = [...NotifServer.notifServer.trackedNotifications.values];
        } else {
            notiModel.values = notiModel.values.filter(n => n.tracked);
        }
        if (win.notifCount === 0) {
            columns.state = "Closed";
        }
    }

    anchor.window: bar
    anchor.rect.x: bar.width - width - 5
    anchor.rect.y: bar.height + 10
    implicitWidth: 500
    implicitHeight: 600

    function toggleVisibility() {
        if (win.visible) {
            this.hide();
        } else {
            this.show();
        }
    }

    function show() {
        win.visible = true;
        win.showAll = true;
        notiModel.values = [...NotifServer.notifServer.trackedNotifications.values];
        columns.state = "Open";
        hideTimer.stop();
    }

    function hide() {
        hideTimer.restart();
    }

    Rectangle {
        id: columns
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        color: "transparent"
        state: "Closed"
        states: [
            State {
                name: "Open"
                PropertyChanges {
                    columns.opacity: 1
                }
            },
            State {
                name: "Closed"
                PropertyChanges {
                    columns.opacity: 0
                }
            }
        ]
        onOpacityChanged: {
            if (opacity == 0) {
                win.visible = false;
                win.showAll = false;
                notiModel.values = [];
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onExited: {
                columns.state = "Closed";
            }
            onEntered: {
                hideTimer.stop();
            }
        }
        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            clip: true
            spacing: 10

            model: ScriptModel {
                id: notiModel
                values: []
            }

            delegate: NotificationEntry {
                width: columns.width
            }
        }
    }
    Component.onCompleted: () => {
        NotifServer.notifServer.onNotification.connect(n => {
            win.visible = true;
            win.showAll = false;
            columns.state = "Open";
            notiModel.values.push(n);
            hideTimer.interval = 5000;
            hideTimer.restart();
        });
    }
    Timer {
        id: hideTimer
        interval: 200
        onTriggered: {
            columns.state = "Closed";
            hideTimer.interval = 200;
        }
    }
}
