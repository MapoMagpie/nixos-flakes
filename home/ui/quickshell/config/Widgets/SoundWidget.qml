import QtQuick
import Quickshell
import "../Data"
import "../Assets"
import "../Components"

Text {
    id: root
    required property PanelWindow bar
    property bool hovering: false
    text: " " + Math.round(Audio.volume * 100)
    font.pointSize: 12
    font.family: "0xProto Nerd Font"
    font.bold: true
    color: root.hovering ? Colors.error : Colors.secondary

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        hoverEnabled: true
        onEntered: {
            root.hovering = true;
        }
        onExited: {
            root.hovering = false;
        }
        onClicked: mouse => {
            switch (mouse.button) {
            case Qt.LeftButton:
                popup.visible = !popup.visible;
                break;
            case Qt.MiddleButton:
                Audio.sink.audio.muted = !Audio.muted;
                break;
            case Qt.RightButton:
                Audio.source.audio.muted = !Audio.source.audio.muted;
                break;
            }
        }
        onWheel: event => Audio.wheelAction(event)
    }

    SoundChannelMenu {
        id: popup
        bar: root.bar
    }
}
