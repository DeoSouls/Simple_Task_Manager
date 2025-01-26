import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

TextField {
    id: root

    property color backColor: "#EFEFEF"
    property color borderColor: "black"
    property int borderWidth: 0
    property int borderRadius: 10
    property string placeholderTextLabel: "label"

    background: Rectangle {
        color: root.backColor
        border.width: root.borderWidth
        border.color: root.borderColor
        radius: root.borderRadius
    }

    font {
        family: "Jost"
        pixelSize: 18
    }
    leftPadding: 35
    verticalAlignment: TextInput.AlignVCenter

    Image {
        width: 16
        height: 16
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 9
        }
        source: "qrc:/new/images/search.png"
    }

    Label {
        id: placeholderLabel
        text: root.placeholderTextLabel
        color: "#524F4F"
        font {
            family: "Jost"
            pixelSize: 18
        }

        visible: true
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 35
        }

        states: [
            State {
                name: "focused"
                when: root.activeFocus || root.text.length > 0
                PropertyChanges {
                    target: placeholderLabel
                    visible: false
                }
            }
        ]
    }
}
