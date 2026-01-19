pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import Quickshell.Io
import "../Assets"

Rectangle {
    id: root
    required property var modelData
    required property PopupWindow popup
    implicitWidth: text.width
    color: Colors.withAlpha((root.hovering ? Colors.on_background : Colors.background), 0.7)
    border.color: Colors.primary
    border.width: 2
    property bool hovering: false
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
        // text: root.activeWindow?.activated ? root.elideMiddle((root.activeWindow?.appId + " : " + root.activeWindow.title), 70) : "<h_h>"
        text: root.elideMiddle(root.modelData.app_id + " : " + root.modelData.title, 100)
    }
    Process {
        id: process
        running: false
        command: ["niri", "msg", "action", "focus-window", "--id", root.modelData.id]
    }
    Process {
        id: process_close
        running: false
        command: ["niri", "msg", "action", "close-window", "--id", root.modelData.id]
    }
    MouseArea {
        anchors.fill: root
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        hoverEnabled: true
        propagateComposedEvents: true
        onEntered: {
            root.hovering = true;
            root.popup.show();
            // process.running = true;
        }
        onExited: {
            root.hovering = false;
            root.popup.hide();
        }
        onClicked: event => {
            switch (event.button) {
            case Qt.LeftButton:
                process.running = true;
                break;
            case Qt.MiddleButton:
                process_close.running = true;
                break;
            case Qt.RightButton:
                break;
            }
        }
    }
}
