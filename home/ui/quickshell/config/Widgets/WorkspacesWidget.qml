import QtQuick
import Quickshell
import Quickshell.Io
import "../Data"
import "../Assets"
import "../Components"

Rectangle {
    id: root
    required property PanelWindow bar
    property bool active: false
    property var workspaces: Niri.workspaces
    property var activedWorkspace: Niri.activedWorkspace
    property var activedWorkspaceIndex: Niri.activedWorkspaceIndex

    color: root.active ? Colors.withAlpha(Colors.on_primary, 0.8) : Colors.withAlpha(Colors.background, 0.8)
    border.color: Colors.primary
    border.width: 2
    width: 80
    height: parent.height

    Text {
        id: text
        anchors.centerIn: parent
        font.pointSize: 12
        font.family: "0xProto Nerd Font"
        font.bold: true
        color: Colors.secondary
        text: root.activedWorkspace
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        hoverEnabled: true
        onWheel: event => {
            process_focus_workspace.direction = (event.angleDelta.y > 0) ? "up" : "down";
            process_focus_workspace.running = true;
        }
        Process {
            id: process_focus_workspace
            running: false
            property string direction: "down"
            command: ["niri", "msg", "action", "focus-workspace-" + this.direction]
        }
        Process {
            id: process_overview
            running: false
            property string direction: "down"
            command: ["niri", "msg", "action", "toggle-overview"]
        }
        onEntered: {
            let pos = root.mapToItem(popup.parent, 0, root.height);
            popup.x = pos.x - (root.activedWorkspaceIndex * 80);
            popup.y = pos.y;
            popup.show();
        }
        onClicked: event => {
            switch (event.button) {
            case Qt.LeftButton:
                process_overview.running = true;
                break;
            case Qt.MiddleButton:
                break;
            case Qt.RightButton:
                break;
            }
        }
        onExited: {
            popup.hide();
        }
    }

    WorkspacePopup {
        id: popup
        bar: root.bar
    }

    Component.onCompleted: () => {
        popup.onVisibleChanged.connect(() => {
            root.active = popup.visible;
        });
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
}
