import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: menuDrawer

    property int userId: 0
    property var container: spacesTab.containerTabs
    property var currentPage: null
    property var initialSpaces: null

    width: parent.width * 0.9
    height: parent.height
    edge: Qt.LeftEdge
    background: Rectangle {
        color: "white"
    }

    // Component.onCompleted: {
    //     if(menuDrawer.userId !== 0) {
    //         client.getSpaces(menuDrawer.userId);
    //     }
    // }

    Popup {
        id: dialogWindow
        anchors.centerIn: parent
        width: 200
        height: 150
        contentItem: Column {
            anchors.fill: parent
            Text {
                width: parent.width
                text: "Придумайте название для своего пространства (название должно быть уникальным)"
                color: "black"
                font {
                    family: "Jost"
                    pixelSize: 15
                }
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            TextField {
                id: spaceText
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 20
                height: 40
                font {
                    family: "Jost"
                    pixelSize: 18
                }
            }
        }
        onClosed: {
            if(spaceText.text.length > 0 && menuDrawer.userId !== 0) {
                client.createSpace(spaceText.text, menuDrawer.userId);
                spaceText.clear();
            }
        }
    }

    Search {
        id: searchMenu
        width: 242
        height: 40
        anchors {
            top: parent.top
            left: parent.left
            topMargin: 23
            leftMargin: 16
        }
        placeholderTextLabel: "Поиск"
    }

    CustomButton {
        width: 50
        height: 50
        borderWidth: 0
        borderRadius: 25
        hoverEnabled: false
        backColor: "transparent"

        anchors {
            top: parent.top
            topMargin: 18
            left: searchMenu.right
            leftMargin: 17
        }

        onClicked: {
            currentPage.StackView.view.push("../SettingsPage/Settings.qml", {});
            menuDrawer.close();
        }

        Image {
            anchors.centerIn: parent
            width: 25
            height: 25
            source: "qrc:/new/images/settings.png"
        }
    }
    ColumnLayout {
        id: tabsContainer
        width: parent.width
        anchors.top: searchMenu.bottom
        anchors.topMargin: 10
        Layout.alignment: Qt.AlignTop
        spacing: 0
        Tab {
            id: homeTab
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            Layout.alignment: Qt.AlignTop
            Image {
                id: imgHomeTab
                width: 24
                height: 19
                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                source: "qrc:/new/images/home.png"
            }
            mouse.onClicked: {
                currentPage.StackView.view.push("../HomePage/Home.qml", { userId: menuDrawer.userId })
            }
        }
        Tab {
            id: favoriteTab
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            Layout.alignment: Qt.AlignTop

            headerTab: "Фавориты"
            isTabs: true
            leftMarginText: 16
        }
        Tab {
            id: spacesTab
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            initialSpaces: menuDrawer.initialSpaces
            Layout.alignment: Qt.AlignTop
            headerTab: "Пространства"
            refsPage: menuDrawer.currentPage
            refsMenu: menuDrawer
            leftMarginText: 16
            isTabs: true

            CustomButton {
                id: createTab
                width: 30
                height: 30
                borderWidth: 0
                borderRadius: 15
                hoverEnabled: false
                backColor: "transparent"
                anchors {
                    right: parent.right
                    rightMargin: 40
                    verticalCenter: parent.verticalCenter
                }
                onClicked: {
                    dialogWindow.open();
                    spacesTab.isClicked = true;
                }

                Image {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    source: "qrc:/new/images/plus.png"
                }
            }
            CustomButton {
                id: searchTab
                width: 20
                height: 20
                borderWidth: 0
                borderRadius: 10
                hoverEnabled: false
                backColor: "transparent"
                anchors {
                    right: parent.right
                    rightMargin: 75
                    verticalCenter: parent.verticalCenter
                }
                onClicked: {

                    // menuDrawer.open();
                }

                Image {
                    anchors.centerIn: parent
                    width: 15
                    height: 15
                    source: "qrc:/new/images/search.png"
                }
            }
            mouse.onClicked: {
                if(menuDrawer.initialSpaces === null) {
                    client.getSpaces(menuDrawer.userId);
                }
            }
        }
    }
}
