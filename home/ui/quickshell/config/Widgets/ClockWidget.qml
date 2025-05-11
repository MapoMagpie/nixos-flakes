import QtQuick
import Quickshell
import "../Data"
import "../Assets"
import "../Components"

Rectangle {
    id: root
    required property PanelWindow bar
    property bool hovering: false
    implicitHeight: parent.height
    implicitWidth: text.implicitWidth
    color: root.hovering ? Colors.withAlpha(Colors.on_primary, 1.0) : Colors.withAlpha(Colors.background, 0.9)
    border.color: Colors.primary
    border.width: 2

    Text {
        id: text
        property var time: Time.data
        anchors.verticalCenter: parent.verticalCenter
        leftPadding: 10
        rightPadding: 10
        font.pointSize: 12
        font.family: "0xProto Nerd Font"
        font.bold: true
        color: Colors.secondary
        text: this.time ? (this.time.time.hours + ":" + this.time.time.minutes + ":" + this.time.time.seconds + " " + this.time.dayNumber + "/" + this.time.monthNumber + "/" + this.time.year) : "The void"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                monthPopup.toggleVisibility();
            }
            onEntered: {
                root.hovering = true;
            }
            onExited: {
                root.hovering = false;
            }
        }
    }

    MonthPopup {
        id: monthPopup
        bar: root.bar
    }
}
