import QtQuick
import QtQuick.Controls

TextField {
    id: root
    property color backgroundColor: ThemeManager.backgroundColor
    property color borderColor: ThemeManager.isDarkTheme ? "white" : "black"
    property color borderFocusedColor: "blue"
    property int borderWidth: 1
    property string placeholderTextLabel: "label"
    leftPadding: 0
    rightPadding: 0
    padding: 0

    background: Rectangle {
        color: root.backgroundColor
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left    // добавляем привязку слева
            anchors.right: parent.right  // добавляем привязку справа
            height: root.borderWidth
            color: root.activeFocus ? root.borderFocusedColor : root.borderColor

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }

    color: ThemeManager.isDarkTheme ? "white" : "black";
    selectionColor: "lightblue"
    selectedTextColor: ThemeManager.isDarkTheme ? "black" : "white"
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
            pixelSize: 16 + ThemeManager.additionalSize
            bold: true
        }
        color: ThemeManager.isDarkTheme ? "white" : "black"
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
                    font.pixelSize: 10 + ThemeManager.additionalSize
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
