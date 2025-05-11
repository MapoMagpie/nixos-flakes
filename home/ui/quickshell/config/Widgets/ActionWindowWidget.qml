import QtQuick
import Quickshell.Wayland
import "../Assets"

Rectangle {
    id: container

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
        text: container.activeWindow?.activated ? container.elideMiddle((container.activeWindow?.appId + " : " + container.activeWindow.title), 70) : "<h_h>"
    }
}
