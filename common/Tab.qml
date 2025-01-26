import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: homeTab
    color: activeFocus? "#F1F1F1" : "white"
    focus: false
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#E5E5E5"
    }

    property string headerTab: "Дом"
    property var containerTabs: tabsContainer
    property int leftMarginText: 51
    property int spaceId: 0
    property bool isTabs: false
    property bool isContainer: false
    property bool isClicked: false
    property var initialSpaces: null
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
            pixelSize: 18
        }
        anchors {
            left: parent.left
            leftMargin: homeTab.leftMarginText
            verticalCenter: parent.verticalCenter
        }
        text: homeTab.headerTab
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
        source: "qrc:/new/images/right.png"

        Behavior on rotation {
            RotationAnimation {
                duration: 200
                direction: RotationAnimation.Shortest
            }
        }
    }
    ColumnLayout {
        id: tabsContainer
        visible: false
        width: parent.width
        anchors.top: homeTab.bottom
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
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                implicitHeight: contentHeight // Для автоматического расчета
                Layout.preferredHeight: contentHeight // Явное указание
                interactive: true
                model: homeTab.initialSpaces
                delegate: SpaceTab {
                    width: 320
                    height: 45
                    headerTab: modelData.spacename
                    spaceId: modelData.spaceId
                    leftMarginText: 70
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.AllButtons // Разрешаем все типы кликов

                        onClicked: {
                            console.log("CLICKED! Space:", modelData.spacename)
                            // 4. Проверяем доступность объектов

                            homeTab.refsPage.StackView.view.push("../SpacePage/Space.qml", {
                                spaceId: modelData.spaceId,
                                userId: homeTab.refsPage.userId,
                                spacename: modelData.spacename,
                                initialSpaces: homeTab.initialSpaces
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
                    Component.onCompleted: {
                        console.log("SpaceTab created for:", modelData.spacename)
                    }
                    // mouseTab.onClicked: {
                    //     homeTab.refsStackView.push("../SpacePage/Space.qml", { spaceId: modelData.spaceId, userId: homeTab.refsMenu.userId, spacename: modelData.spacename });
                    //     homeTab.refsMenu.close();
                    // }
                }
            }
        }

        function createObjectFromString(spaceId, headerSpace, stackView, menuDrawer) {
            var qmlString = `import QtQuick; import QtQuick.Controls; import QtQuick.Layouts 1.12; import "../common"; import "../SpacePage"
                Tab {
                    id: spaceTab
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    headerTab: "${headerSpace}"
                    spaceId: ${spaceId}
                    leftMarginText: 70
                    Image {
                        anchors.left: parent.left
                        anchors.leftMargin: 37
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18
                        height: 13
                        source: "qrc:/new/images/taskMenu.png"
                    }
                    mouse.onClicked: {
                        stackView.push("../SpacePage/Space.qml", {
                                        spaceId: spaceTab.spaceId,
                                        userId: menuDrawer.userId,
                                        spacename: "${headerSpace}",
                                        initialSpaces: menuDrawer.initialSpaces });
                        menuDrawer.close();
                    }
                }`;
            var object = Qt.createQmlObject(qmlString, tabsContainer, "dynamicObject");
        }
    }
}
