pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "../Data"
import "../MenuWidgets"

PopupWindow {
    id: win
    required property PanelWindow bar
    property int notifCount: NotifServer.notifCount
    property bool showAll: false
    color: "transparent"
    visible: false

    onNotifCountChanged: {
        // console.log("onNotifCountChanged ", notiModel.values.length);
        if (win.showAll) {
            notiModel.values = [...NotifServer.notifServer.trackedNotifications.values];
        }
    }

    anchor.window: bar
    anchor.rect.x: bar.width - width - 10
    anchor.rect.y: bar.height + 10
    width: columns.width
    height: columns.height

    function toggleVisibility() {
        if (win.visible) {
            columns.state = "Closed";
        } else {
            win.visible = true;
            win.showAll = true;
            notiModel.values = [...NotifServer.notifServer.trackedNotifications.values];
            columns.state = "Open";
        }
    }

    Rectangle {
        id: columns
        anchors.centerIn: parent
        width: 500
        implicitHeight: 700
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
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 100
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
            columns.state = "Open";
            notiModel.values = [n];
            if (n.actions.length === 0) {
                timer.restart();
            }
        });
    }
    Timer {
        id: timer
        interval: 5000
        onTriggered: {
            columns.state = "Closed";
        }
    }
}
