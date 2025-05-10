import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "../Assets"
import "../Components"

Rectangle {
    id: root
    property bool active: false
    required property PanelWindow bar

    visible: Mpris.players.values.length > 0
    implicitHeight: parent.height
    implicitWidth: indicateText.implicitWidth + 20
    color: root.active ? Colors.withAlpha(Colors.on_primary, 0.8) : Colors.withAlpha(Colors.background, 0.8)
    border.color: Colors.primary
    border.width: 2

    ShaderEffect {
        anchors.fill: parent
        property real time: 0.0
        property var resolution: Qt.size(60, 30)
        fragmentShader: "../Assets/ani.frag.qsb"
        Timer {
            interval: 16
            running: true
            repeat: true
            onTriggered: parent.time += 0.026
        }
    }
    Text {
        id: indicateText
        anchors.centerIn: parent
        font.pointSize: 12
        font.family: "0xProto Nerd Font"
        font.bold: true
        color: Colors.secondary
        text: " " + Mpris.players.values.length
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            popup.toggleVisibility();
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

    MprisPopupPanel {
        id: popup
        bar: root.bar
    }
}
