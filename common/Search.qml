import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

TextField {
    id: root

    property color backColor: ThemeManager.isDarkTheme ? "#282829" : "#EFEFEF"
    property color borderColor: ThemeManager.isDarkTheme ? "white" : "black"
    property int borderWidth: ThemeManager.isDarkTheme ? 1 : 0
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
        pixelSize: 18 + ThemeManager.additionalSize
    }
    color: ThemeManager.isDarkTheme ? "white" : "black"
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

        MouseArea {
            anchors.fill: parent
            // Обрабатываем клик вне TextField
            onClicked: {
                // Снимаем фокус с TextField
                root.focus = false
                // Передаём фокус самому контейнеру, чтобы TextField точно его потерял
                parent.forceActiveFocus()
            }
        }
        source: ThemeManager.isDarkTheme ? "qrc:/new/images/searchWhite.png" : "qrc:/new/images/search.png"
    }

    Label {
        id: placeholderLabel
        text: root.placeholderTextLabel
        color: ThemeManager.isDarkTheme ? "white" : "#524F4F"
        font {
            family: "Jost"
            pixelSize: 18 + ThemeManager.additionalSize
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
