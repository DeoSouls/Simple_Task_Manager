import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    color: "white"
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#E5E5E5"
    }

    property string headerTab: "Дом"
    property int leftMarginText: 51
    property int spaceId: 0
    // property alias mouseTab: mouseArea

    // MouseArea {
    //     id: mouseArea
    //     anchors.fill: parent
    //     onClicked: {
    //         root.focus = true;
    //     }
    // }

    Label {
        font {
            family: "Jost"
            pixelSize: 18
        }
        anchors {
            left: parent.left
            leftMargin: root.leftMarginText
            verticalCenter: parent.verticalCenter
        }
        text: root.headerTab
    }
}
