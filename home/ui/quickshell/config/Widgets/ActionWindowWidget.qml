import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Data"
import "../Assets"
import "../Components"

Rectangle {
    id: root

    required property PanelWindow bar
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    color: Colors.withAlpha(Colors.background, 0.9)
    border.color: Colors.primary
    border.width: 2
    implicitHeight: parent.height
    implicitWidth: text.width
    function elideMiddle(str, maxLength) {
        if (str.length <= maxLength)
            return str;
        const half = Math.floor((maxLength - 3) / 2);
        return str.slice(0, half) + "..." + str.slice(-half);
    }

    Text {
        id: text
        font.pointSize: 12
        font.family: "0xProto Nerd Font"
        font.bold: true
        color: Colors.secondary
        leftPadding: 10
        rightPadding: 10
        anchors.centerIn: parent
        text: root.activeWindow?.activated ? root.elideMiddle((root.activeWindow?.appId + " : " + root.activeWindow.title), 70) : "<h_h>"
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        hoverEnabled: true
        onWheel: event => {
            process_focus_window.action = (event.angleDelta.y > 0) ? "focus-window-up-or-column-left" : "focus-window-down-or-column-right";
            process_focus_window.running = true;
        }
        Process {
            id: process_focus_window
            running: false
            property string action: "focus-window-down-or-column-left"
            // focus-window-down-or-column-left
            command: ["niri", "msg", "action", this.action]
        }
        // onEntered: {
        //     let pos = root.mapToItem(popup.parent, 0, root.height);
        //     popup.x = pos.x - (root.activedWorkspaceIndex * 80);
        //     popup.y = pos.y;
        //     popup.show();
        // }
        onClicked: event => {
            switch (event.button) {
            case Qt.LeftButton:
                popup.toggleVisibility();
                break;
            case Qt.MiddleButton:
                break;
            case Qt.RightButton:
                break;
            }
        }
        // onExited: {
        //     popup.hide();
        // }
    }

    WindowsPopup {
        id: popup
        bar: root.bar
    }
}
