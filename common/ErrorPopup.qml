import QtQuick
import QtQuick.Controls

Popup {
    id: root

    property string textPopup: "error message"
    property int borderWidth: 1

    // modal: true
    focus: true
    opacity: 0
    scale: 0.7

    background: Rectangle {
        color: "white"
        border.color: "black"
        border.width: root.borderWidth
        radius: 10
    }

    contentItem: Text {
        text: root.textPopup
        color: "black"
        font {
            family: "Jost"
            pixelSize: 18
        }

        wrapMode: Text.WordWrap

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // Анимация появления
    enter: Transition {
        // Анимация масштаба
        NumberAnimation {
            property: "scale"
            from: 0.7
            to: 1
            duration: 200
            easing.type: Easing.OutBack
        }

        // Анимация прозрачности
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 200
        }
    }

    // Анимация закрытия
    exit: Transition {
        NumberAnimation {
            property: "scale"
            from: 1
            to: 0.7
            duration: 150
        }
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 150
        }
    }

    Timer {
        interval: 2000
        running: root.visible
        onTriggered: root.close()
    }
}
