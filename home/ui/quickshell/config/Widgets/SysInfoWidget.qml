import QtQuick
import QtQuick.Layouts
import Quickshell
import "../Data"
import "../Assets"

// import "../Components"

Rectangle {
    id: root
    required property PanelWindow bar
    Layout.preferredWidth: childrenRect.width + 25
    Layout.fillHeight: true
    color: Colors.withAlpha(Colors.background, 0.8)
    border.color: Colors.primary
    border.width: 2

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 10

        function zeroPad(num, size) {
            var s = num + "";
            while (s.length < size)
                s = "0" + s;
            return s;
        }

        Text {
            id: infos
            property var data: Infos.data
            // anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 12
            font.family: "0xProto Nerd Font"
            font.bold: true
            color: Colors.secondary
            text: this.data ? " %1/%2k  %3  %4  %5".arg(row.zeroPad(this.data.net_rx, 4)).arg(row.zeroPad(this.data.net_tx, 2)).arg(this.data.cpu).arg(this.data.mem).arg(this.data.disk) : "The void"
        }

        // PowerWidget {bar: root.bar}
        SoundWidget {
            bar: root.bar
        }
        // BrightnessWidget {
        //     bar: root.bar
        // }
    }
}
