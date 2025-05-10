pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../Assets"

Rectangle {
    id: root
    required property PanelWindow bar
    implicitHeight: parent.height
    implicitWidth: rows.implicitWidth + 20
    color: Colors.withAlpha(Colors.background, 0.8)
    border.color: Colors.primary
    border.width: 2

    RowLayout {
        id: rows
        spacing: 10
        anchors.centerIn: parent
        Repeater {
            model: SystemTray.items
            TrayItem {
                required property SystemTrayItem modelData
                item: modelData
                bar: root.bar
            }
        }
    }
}
