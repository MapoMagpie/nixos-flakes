pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Services.Pipewire

import "../Assets"

PopupWindow {
    id: win
    required property PanelWindow bar

    visible: false
    color: "transparent"
    anchor.window: bar
    anchor.rect.x: bar.width - width - 10
    anchor.rect.y: bar.height + 10
    implicitWidth: 500
    implicitHeight: 250

    Rectangle {
        color: Colors.withAlpha(Colors.surface, 0.70)
        anchors.centerIn: parent
        width: parent.width - 10
        height: parent.height - 10
        border {
            color: Colors.primary
            width: 2
        }

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 10
            anchors.topMargin: 26
            anchors.bottomMargin: 10
            clip: true
            spacing: 14

            model: ScriptModel {
                id: script
                values: Pipewire.nodes.values.filter(node => node.audio != null && !node.description.startsWith("Tiger")).sort((a, b) => a.id - b.id)
            }

            delegate: Slider {
                id: slider
                required property PwNode modelData
                required property int index
                property bool isDefaultSink: slider.modelData.id === Pipewire.defaultAudioSink.id
                width: parent.width
                height: 30
                snapMode: Slider.NoSnap

                PwObjectTracker {
                    objects: [slider.modelData]
                }

                background: Rectangle {
                    id: sliderback
                    anchors.centerIn: parent
                    color: slider.isDefaultSink ? Colors.on_tertiary : Colors.on_primary
                    height: slider.height
                    width: slider.availableWidth
                    Layout.alignment: Qt.AlignTop
                    clip: true

                    Rectangle {
                        color: slider.isDefaultSink ? Colors.tertiary : Colors.primary
                        width: slider.visualPosition * slider.availableWidth
                        height: slider.height
                    }

                    Text {
                        id: text
                        property string icon: (!slider.modelData?.isSink) ? "  " : "  "
                        anchors.leftMargin: 10
                        verticalAlignment: Text.AlignVCenter
                        anchors.fill: parent
                        color: Colors.on_primary
                        font.bold: true
                        text: text.icon + ((slider.modelData?.description == "") ? slider.modelData?.name : slider.modelData?.description)
                    }
                }

                handle: Rectangle {
                    visible: false
                }
                value: slider.modelData?.audio?.volume * 100
                from: 0
                to: 100

                onValueChanged: {
                    slider.modelData.audio.volume = (slider.value / 100);
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: event => {
                        if (event.button === Qt.RightButton && slider.modelData.isSink) {
                            Pipewire.preferredDefaultAudioSink = slider.modelData;
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: -5
            anchors.leftMargin: -5
            height: headerText.height + 5
            width: headerText.width + 10
            color: Colors.primary

            Text {
                id: headerText
                anchors.centerIn: parent
                text: "Audio"
                color: Colors.on_primary
            }
        }

        Text {
            visible: script.values.length == 0
            anchors.centerIn: parent
            text: "No Active Audio Channels"
            color: Colors.primary
            font.pointSize: 16
        }
    }
}
