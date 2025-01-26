import QtQuick
import QtQuick.Controls

TextField {
    id: root
    property color backgroundColor: "transparent"
    property color borderColor: "black"
    property color borderFocusedColor: "blue"
    property int borderWidth: 1
    property string placeholderTextLabel: "label"

    background: Rectangle {
        color: root.backgroundColor
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: root.borderWidth
            color: root.activeFocus ? root.borderFocusedColor : root.borderColor

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }

    color: "black";
    selectionColor: "lightblue"
    selectedTextColor: "white"
    Label {
        id: placeholderLabel
        text: root.placeholderTextLabel
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10
            verticalCenterOffset: -3
        }
        font {
            family: "Jost"
            pixelSize: 16
            bold: true
        }

        transform: Translate {
            id: placeholderTranslate
        }

        states: [
            State {
                name: "focused"
                when: root.activeFocus || root.text.length > 0
                PropertyChanges {
                    target: placeholderTranslate
                    x: -10
                    y: -17
                }
                PropertyChanges {
                    target: placeholderLabel
                    font.pixelSize: 10
                }
            }
        ]

        transitions: Transition {
            NumberAnimation {
                properties: "x,y,font.pixelSize"
                duration: 150
            }
        }
    }
}
