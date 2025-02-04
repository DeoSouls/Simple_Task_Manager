import QtQuick
import QtQuick.Controls
import "../common"

Page {
    id: mainmenu
    anchors.top: parent.top
    anchors.topMargin: 20

    Connections {
        target: translator
        function onLanguageChanged() {
            textMenu.text = qsTr("Меню")
        }
    }

    header: ToolBar {
        height: 40
        background: null

        Button {
            id: toHome
            width: 30
            height: 30
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            background: null
            onClicked: {
                mainmenu.StackView.view.pop();
            }
            onPressed: {
                jumpAnimationToHome.start()
            }
            Image {
                width: 20
                height: 20
                anchors.centerIn: parent
                source: "qrc:/new/images/left.png"
            }
            PropertyAnimation {
                id: jumpAnimationToHome
                target: toHome
                property: "scale"
                from: 1.0
                to: 1.2
                duration: 100
                easing.type: Easing.InOutQuad
                onStopped: {
                    toHome.scale = 1.0
                }
            }
        }

        Text {
            id: textMenu
            anchors.centerIn: parent
            text: qsTr("Меню")
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
        }
    }
}
