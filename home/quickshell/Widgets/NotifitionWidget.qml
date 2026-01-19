import QtQuick
import Quickshell
import "../Assets"
import "../Components"
import "../Data"

Rectangle {
    id: root
    property bool active: false
    required property PanelWindow bar
    visible: NotifServer.notifCount > 0
    implicitHeight: parent.height
    implicitWidth: indicateText.implicitWidth + 20
    color: root.active ? Colors.withAlpha(Colors.on_primary, 1.0) : Colors.withAlpha(Colors.background, 0.9)
    border.color: Colors.error
    border.width: 2

    Text {
        id: indicateText
        anchors.centerIn: parent
        font.pointSize: 12
        font.family: "0xProto Nerd Font"
        font.bold: true
        color: Colors.secondary
        text: " " + NotifServer.notifCount
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            popup.toggleVisibility();
        }
        onExited: {
            popup.hide();
        }
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

    NotificationPopupPanel {
        id: popup
        bar: root.bar
    }
}
