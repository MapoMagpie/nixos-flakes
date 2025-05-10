import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

IconImage {
    id: root
    required property SystemTrayItem item
    required property PanelWindow bar

    source: root.item.icon
    implicitSize: 15
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            switch (event.button) {
            case Qt.LeftButton:
                root.item.activate();
                break;
            case Qt.RightButton:
                // console.log("tray right click, ", root.item.hasMenu);
                if (root.item.hasMenu) {
                    // the bellow is kinda hard coded, find a better solution
                    const pos = root.mapToItem(menuAnchor.parent, 0, root.parent.parent.height);
                    menuAnchor.anchor.rect = pos;
                    menuAnchor.open();
                }
                break;
            }
        }
    }
    QsMenuAnchor {
        id: menuAnchor
        menu: root.item.menu
        anchor.window: root.bar
        // anchor.adjustment: PopupAdjustment.Flip
    }
}
