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
    width: 50
    height: parent.height
    color: root.active ? Colors.withAlpha(Colors.on_primary, 1.0) : Colors.withAlpha(Colors.background, 1.0)
    border.color: Colors.error
    border.width: 2

    ShaderEffect {
        width: parent.width - 8
        height: parent.height - 8
        anchors.centerIn: parent
        property real time: 0.0
        property var resolution: Qt.size(1.0, 1.0)
        property real brightness: root.active ? 1.0 : 1.5
        // blending: true
        fragmentShader: "../Assets/wheel.frag.qsb"
        Timer {
            interval: 16
            running: true
            repeat: true
            onTriggered: parent.time += 0.010
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
