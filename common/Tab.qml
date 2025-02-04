import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import com.translator 1.0

Rectangle {
    id: homeTab
    color: activeFocus? "gray" : ThemeManager.isDarkTheme ? "#282829" : "white"
    focus: false
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#E5E5E5"
    }

    property string headerTab: ""
    property string userName: ""
    property string userEmail: ""
    property string userImage: ""
    property var containerTabs: tabsContainer
    property int leftMarginText: 51
    property int spaceId: 0
    property bool isTabs: false
    property bool isContainer: false
    property bool isClicked: false
    property var spacesArray: []
    property ListModel initialSpaces: initialSpacesModel
    property var refsPage: null
    property var refsMenu: null
    property alias mouse: mouseArea

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            homeTab.isClicked = !homeTab.isClicked
            homeTab.focus = true;
            console.log("id: "+homeTab.spaceId);
        }
    }

    Label {
        font {
            family: "Jost"
            pixelSize: 18 + ThemeManager.additionalSize
        }
        anchors {
            left: parent.left
            leftMargin: homeTab.leftMarginText
            verticalCenter: parent.verticalCenter
        }
        text: homeTab.headerTab
        color: ThemeManager.isDarkTheme ? "white" : "black"
    }

    states: [
        State {
            name: "clicked"
            when: homeTab.isClicked
            PropertyChanges {
                target: imgRightTab
                rotation: 90
            }
            PropertyChanges {
                target: tabsContainer
                visible: true
            }
        }
    ]

    Image {
        id: imgRightTab
        visible: homeTab.isTabs
        width: 15
        height: 15
        anchors {
            right: parent.right
            rightMargin: 16
            verticalCenter: parent.verticalCenter
        }
        source: ThemeManager.isDarkTheme ? "qrc:/new/images/right.png" : "qrc:/new/images/rightBlack.png"

        Behavior on rotation {
            RotationAnimation {
                duration: 200
                direction: RotationAnimation.Shortest
            }
        }
    }

    ListModel {
        id: initialSpacesModel
        dynamicRoles: true
    }

    ListModel {
        id: filteredModel
        dynamicRoles: true
    }

    onSpacesArrayChanged: {
        if(spacesArray !== null) {
            console.log(spacesArray);
            initializeModel(spacesArray);
        }
    }

    function initializeModel(jsonArray) {
        initialSpacesModel.clear()
        filteredModel.clear()
        if(!Array.isArray(jsonArray)) {
            console.error("Invalid data format");
        }

        for (var i = 0; i < jsonArray.length; i++) {
            var item = jsonArray[i];
            if(item && typeof item === "object") {
                initialSpacesModel.append({
                    spacename: item.spacename,
                    spaceId: item.spaceId
                });

                filteredModel.append({
                    spacename: item.spacename,
                    spaceId: item.spaceId
                });
            }
        }
    }

    Flickable {
        id: flick
        width: parent.width
        height: 500
        anchors.top: homeTab.bottom
        contentWidth: tabsContainer.width
        contentHeight: tabsContainer.height
        boundsBehavior: Flickable.StopAtBounds
        ColumnLayout {
            id: tabsContainer
            visible: false
            width: parent.width
            Layout.alignment: Qt.AlignTop
            spacing: 0
            Loader {
                id: loaderList
                Layout.alignment: Qt.AlignTop
                onLoaded: {
                    if (item) {
                        item.visible = true // Принудительно показываем
                    }
                }
                sourceComponent: homeTab.initialSpaces !== null ? initialComponent : null
            }
            Component {
                id: initialComponent
                ListView {
                    id: spacesList
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    implicitHeight: contentHeight // Для автоматического расчета
                    Layout.preferredHeight: contentHeight // Явное указание
                    interactive: true
                    model: filteredModel
                    delegate: SpaceTab {
                        width: 322
                        height: 45
                        headerTab: model.spacename
                        spaceId: model.spaceId
                        leftMarginText: 70
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.AllButtons // Разрешаем все типы кликов

                            onClicked: {
                                console.log("CLICKED! Space:", model.spacename)
                                // 4. Проверяем доступность объектов

                                homeTab.refsPage.StackView.view.push("../SpacePage/Space.qml", {
                                    spaceId: model.spaceId,
                                    userId: homeTab.refsPage.userId,
                                    spacename: model.spacename,
                                    userName: homeTab.userName,
                                    userEmail: homeTab.userEmail,
                                    userImage: homeTab.userImage,
                                    spacesArray: homeTab.spacesArray
                                });
                                homeTab.refsMenu.close();
                            }
                        }
                        Image {
                            anchors.left: parent.left
                            anchors.leftMargin: 37
                            anchors.verticalCenter: parent.verticalCenter
                            width: 18
                            height: 13
                            source: "qrc:/new/images/taskMenu.png"
                        }
                    }
                }
            }

            function createObjectFromString(spaceId, headerSpace) {
                homeTab.initialSpaces.append({
                    spacename: headerSpace,
                    spaceId: spaceId
                });

                filteredModel.append({
                    spacename: headerSpace,
                    spaceId: spaceId
                });

            }

            function updateSearch(data) {
                const searchTerm = data.toLowerCase();
                filteredModel.clear();

                for (let i = 0; i < homeTab.initialSpaces.count; ++i) {
                    const item = homeTab.initialSpaces.get(i);
                    if (item.spacename.toLowerCase().includes(searchTerm)) {
                        filteredModel.append(item);
                    }
                }
            }
        }
    }


}
