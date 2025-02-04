import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    color: ThemeManager.isDarkTheme ? "#3b3b3b" : "white"
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#E5E5E5"
    }

    property string headerTab: ""
    property int leftMarginText: 51
    property int spaceId: 0

    Label {
        width: 200
        font {
            family: "Jost"
            pixelSize: 18 + ThemeManager.additionalSize
        }
        anchors {
            left: parent.left
            leftMargin: root.leftMarginText
            verticalCenter: parent.verticalCenter
        }
        text: root.headerTab
        color: ThemeManager.fontColor
        elide: Text.ElideRight
    }
}
