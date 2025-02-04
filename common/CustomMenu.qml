import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

Drawer {
    id: menuDrawer

    property int userId: 0
    property var container: spacesTab.containerTabs
    property var currentPage: null
    property var initialSpaces: null

    property string headerHome: qsTr("Дом")
    property string userName: ""
    property string userEmail: ""
    property string userImage: ""

    width: parent.width * 0.9
    height: parent.height
    edge: Qt.LeftEdge
    background: Rectangle {
        color: ThemeManager.isDarkTheme ? "#282829" : "white"
    }

    Connections {
        target: translator
        function onLanguageChanged() {
            searchMenu.placeholderTextLabel = qsTr("Поиск")
            favoriteTab.headerTab = qsTr("Фавориты")
            spacesTab.headerTab = qsTr("Пространства")
            menuDrawer.headerHome = qsTr("Дом")
        }
    }

    Popup {
        id: dialogWindow
        anchors.centerIn: parent
        width: 300
        height: 200
        background: Rectangle {
            color: ThemeManager.isDarkTheme ? "#3b3b3b" : "#f0f0f0"
            radius: 5
        }

        contentItem: Column {
            anchors.fill: parent
            Text {
                width: parent.width
                text: qsTr("Придумайте название для своего пространства (название должно быть уникальным)")
                color: ThemeManager.isDarkTheme ? "white" : "black"
                font {
                    family: "Jost"
                    pixelSize: 15 + ThemeManager.additionalSize
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
                    pixelSize: 18 + ThemeManager.additionalSize
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

    MouseArea {
        anchors.fill: parent
        // Обрабатываем клик вне TextField
        onClicked: {
            // Снимаем фокус с TextField
            searchMenu.focus = false
            // Передаём фокус самому контейнеру, чтобы TextField точно его потерял
            parent.forceActiveFocus()
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
        placeholderTextLabel: qsTr("Поиск")
        onTextChanged: {
            menuDrawer.container.updateSearch(searchMenu.text);
        }
    }

    CustomButton {
        width: 50
        height: 50
        borderWidth: 0
        borderRadius: 25
        hoverEnabled: false

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
            width: 30
            height: 30
            source: ThemeManager.isDarkTheme ? "qrc:/new/images/settingsWhite.png" : "qrc:/new/images/settings.png"
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
            headerTab: menuDrawer.headerHome
            Image {
                id: imgHomeTab
                width: 24
                height: 19
                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                source: ThemeManager.isDarkTheme ? "qrc:/new/images/homeWhite.png" : "qrc:/new/images/home.png"
            }
            mouse.onClicked: {
                currentPage.StackView.view.push("../HomePage/Home.qml", { userId: menuDrawer.userId,
                                                    userName: menuDrawer.userName, userImage: menuDrawer.userImage,
                                                    userEmail: menuDrawer.userEmail });
                menuDrawer.close();
            }
        }
        Tab {
            id: favoriteTab
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            Layout.alignment: Qt.AlignTop

            headerTab: qsTr("Фавориты")
            isTabs: true
            leftMarginText: 16
        }
        Tab {
            id: spacesTab
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            spacesArray: menuDrawer.initialSpaces
            Layout.alignment: Qt.AlignTop
            headerTab: qsTr("Пространства")
            refsPage: menuDrawer.currentPage
            refsMenu: menuDrawer
            userName: menuDrawer.userName
            userEmail: menuDrawer.userEmail
            userImage: menuDrawer.userImage
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
                    source: ThemeManager.isDarkTheme ? "qrc:/new/images/plusWhite.png" : "qrc:/new/images/plus.png"
                }
            }
            mouse.onClicked: {
                if(menuDrawer.initialSpaces === null) {
                    client.getSpaces(menuDrawer.userId);
                }
            }
        }
        function findTabsByPartialName(partialName, caseSensitive = false) {
            const results = [];
            const searchTerm = caseSensitive ? partialName : partialName.toLowerCase();

            function search(root) {
                for (let i = 0; i < root.children.length; ++i) {
                    const child = root.children[i];
                    // Проверяем, что свойство name существует и является строкой
                    if (child && child.hasOwnProperty("headerTab") && typeof child.headerTab === "string"
                            && child.headerTab !== "Дом" && child.headerTab !== "Пространства" && child.headerTab !== "Фавориты") {
                        child.visible = false;
                        const childName = caseSensitive ? child.headerTab : child.headerTab.toLowerCase();
                        if (childName.includes(searchTerm)) {
                            results.push(child);
                            child.visible = true;
                        }
                    }

                    // Рекурсивный поиск во вложенных элементах
                    if (child.children && child.children.length > 0) {
                        search(child);
                    }
                }
            }
            search(tabsContainer);
            return results;
        }

        function openVisibleTabs() {
            function search(root) {
                for (let i = 0; i < root.children.length; ++i) {
                    const child = root.children[i];
                    child.visible = true;

                    if (child.children && child.children.length > 0) {
                        search(child);
                    }
                }
            }
            search(tabsContainer);
        }
    }
}
