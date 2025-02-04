import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Controls.Material

Button {
    id: root

    property color backColor: "transparent"
    property color backHoverColor: "#444"
    property color borderColor: ThemeManager.isDarkTheme ? "white" : "black"
    property int borderWidth: 0
    property int borderRadius: 10
    property bool layerEnabled: false
    property alias rectButton: buttonRect

    Material.elevation: 0

    background: Rectangle {
        id: buttonRect
        color: root.hovered ? root.backHoverColor : root.backColor
        border.color: root.borderColor
        border.width: root.borderWidth
        radius: root.borderRadius
        layer.enabled: root.layerEnabled
        layer.effect: MultiEffect {
            shadowColor: "gray"
            shadowEnabled: true
            shadowScale: 1
            paddingRect: Qt.rect(0,0,0,0);
        }

        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }

    contentItem: Text {
        text: parent.text
        font.family: "Jost"
        font.pixelSize: 16 + ThemeManager.additionalSize
        color: ThemeManager.isDarkTheme ? "white" : "black"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    onPressed: {
        jump.start()
    }

    PropertyAnimation {
        id: jump
        target: root
        property: "scale"
        from: 1.0
        to: 1.1
        duration: 100
        easing.type: Easing.InOutQuad
        onStopped: {
            root.scale = 1.0
        }
    }
}
