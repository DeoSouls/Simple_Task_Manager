import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import com.tasksmodel.network 1.0
import "../common"

Page {
    id: space

    property string spacename: "Space"
    property int spaceId: 0
    property int userId: 0
    property string userName: ""
    property string userImage: ""
    property string userEmail: ""
    property bool isFavorite: false
    property var spacesArray: []

    anchors.top: parent.top
    anchors.topMargin: 20

    background: Rectangle {
        color: ThemeManager.backgroundColor
    }

    ErrorPopup {
        id: errorPopup
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        borderWidth: 0
    }

    TasksModel {
        id: tasksModel
    }

    CreateTaskForm {
        id: createForm
        spaceId: space.spaceId
        tasksModel: tasksModel
    }

    function updateData(spaceId) {
        client.getTasks(spaceId);
    }

    function handleClientMessage(message) {
        if(message["type"] === "get_tasks" && message["success"]) {
            console.log("Получены таски");
            tasksModel.updateFromJson(message["data"]);
        } else if(message["type"] === "deleted_task" && message["success"]) {
            console.log("Таск удален" + message["taskId"]);
        } else if(message["type"] === "updated_space" && message["success"]) {
            console.log("Space обновлен " + message["spaceId"]);
        } else if(message["type"] === "created_task" && message["success"]) {
            console.log("Создан таск id: "+ message["taskId"]);
            tasksModel.addTask(message["title"], message["description"],
                                message["status"],
                                message["createTime"],
                                message["dueTime"],
                                message["spaceId"],
                                message["taskId"]);
        } else if(message != undefined && message["success"]) {
            console.log("Создано пространство id: "+ message["spaceId"]);
            menuDrawer.container.createObjectFromString(message["spaceId"],
                                                        message["spacename"]);
            if (!Array.isArray(menuDrawer.initialSpaces)) {
                menuDrawer.initialSpaces = [];
            }
            menuDrawer.initialSpaces.push({
                spaceId: message["spaceId"],
                spacename: message["spacename"]
            });
        } else {
            errorPopup.textPopup = message["error"];
            errorPopup.open();

            if(message["invalid_token"]) {
                space.StackView.view.push("../LoginPage/Login.qml", {});
            }
        }
    }

    function reformateDate(dateString) {
        var date = new Date(dateString)
        return Qt.formatDateTime(date, "dd.MM.yyyy")
    }

    CustomMenu {
        id: menuDrawer
        userId: space.userId
        userName: space.userName
        userEmail: space.userEmail
        userImage: space.userImage
        currentPage: space
        initialSpaces: space.spacesArray
    }

    Component.onCompleted: {
        if(space.spaceId !== 0) {
            client.getTasks(space.spaceId);
        }
    }

    header: ToolBar {
        height: 40
        background: null
        CustomButton {
            id: toMainMenu
            width: 48
            height: 48

            borderWidth: 0
            borderRadius: 24
            hoverEnabled: false

            backColor: ThemeManager.backgroundColor

            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }

            onClicked: {
                menuDrawer.open();
            }

            Image {
                anchors.centerIn: parent
                width: 24
                height: 24
                source: ThemeManager.isDarkTheme ? "qrc:/new/images/menuWhite.png" : "qrc:/new/images/menu.png"
            }
        }
        Text {
            anchors.centerIn: parent
            text: space.spacename
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
            color: ThemeManager.fontColor
            elide: Qt.ElideRight
        }
        CustomButton {
            id: toAddFavorite
            width: 48
            height: 48

            property bool isFavorite: space.isFavorite

            borderWidth: 0
            borderRadius: 24
            hoverEnabled: false

            backColor: ThemeManager.backgroundColor

            anchors {
                right: parent.right
                rightMargin: 50
                verticalCenter: parent.verticalCenter
            }

            states: [
                State {
                    name: "favorite"
                    when: toAddFavorite.isFavorite
                    PropertyChanges {
                        target: starImg
                        source: ThemeManager.isDarkTheme ? "qrc:/new/images/star_white.png" : "qrc:/new/images/star_black.png"
                    }
                }
            ]


            onClicked: {
                toAddFavorite.isFavorite = !toAddFavorite.isFavorite
                // createForm.open();
                if(toAddFavorite.isFavorite) {
                    client.updateSpace(space.spaceId);
                }
            }

            Image {
                id: starImg
                anchors.centerIn: parent
                width: 25
                height: 25
                source: ThemeManager.isDarkTheme ? "qrc:/new/images/nstar_white.png" : "qrc:/new/images/nstar_black.png"
            }
        }
        CustomButton {
            id: toCreateTask
            width: 48
            height: 48

            borderWidth: 0
            borderRadius: 24
            hoverEnabled: false

            backColor: ThemeManager.backgroundColor

            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }

            onClicked: {
                createForm.open();
            }

            Image {
                anchors.centerIn: parent
                width: 30
                height: 30
                source: ThemeManager.isDarkTheme ? "qrc:/new/images/plusWhite.png" : "qrc:/new/images/plus.png"
            }
        }
    }
    Flickable {
        id: nameColumns
        width: 343
        height: 500
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        contentWidth: contentItem.childrenRect.width
        contentHeight: contentItem.childrenRect.height
        boundsMovement: Flickable.StopAtBounds
        clip: true
        Rectangle {
            width: 320 * 3
            height: 400
            color: "transparent" // Делаем фон прозрачным
            Rectangle {
                id: columnsRect
                color: "transparent"
                width: parent.width
                height: 30
                anchors.top: parent.top
                Rectangle {width: parent.width; height: 1; anchors.top: parent.top; color: ThemeManager.isDarkTheme ? "white" : "black";}
                Rectangle {width: 1; height: parent.height; anchors.left: parent.left; color: ThemeManager.isDarkTheme ? "white" : "black";}
                Row {
                    width: parent.width
                    Repeater {
                        model: ["Title", "Description", "Status", "Date create", "Date finish"]
                        Rectangle {
                            width: columnsRect.width / 5
                            height: 30
                            color: "transparent"
                            Text {
                                anchors.centerIn: parent
                                font {
                                    family: "Jost"
                                    pixelSize: 16 + ThemeManager.additionalSize
                                }
                                text: modelData
                                color: ThemeManager.fontColor
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: ThemeManager.isDarkTheme ? "white" : "black";}
                        }
                    }
                }
                Rectangle {width: parent.width; height: 1; anchors.bottom: parent.bottom; color: ThemeManager.isDarkTheme ? "white" : "black";}
            }
            // Здесь можно добавить дополнительное содержимое
            ListView {
                id: contentRect
                anchors.top: columnsRect.bottom
                anchors.bottom: parent.bottom
                width: parent.width
                model: tasksModel
                delegate: Rectangle {
                    width: parent.width
                    height: 55
                    color: "transparent"
                    MouseArea {
                        id: toDescriptionTask
                        anchors.fill: parent
                        onClicked: {
                            console.log("to Task "+ model.taskId);
                            space.StackView.view.push(Qt.resolvedUrl("../TaskPage/Task.qml"), {
                                taskId: model.taskId,
                                titleTask: model.title,
                                descriptionTask: model.description,
                                dueTimeTask: model.dueTime,
                                statusTask: model.status,
                                spaceId: space.spaceId,
                                pastPage: space
                            });
                        }
                    }
                    Rectangle {width: 1; height: parent.height; anchors.left: parent.left; color: ThemeManager.isDarkTheme ? "white" : "black";}
                    Row {
                        anchors.top: parent.top
                        width: parent.width
                        height: 55
                        Rectangle {
                            width: parent.width / 5
                            height: 55
                            color: "transparent"
                            clip: true
                            Rectangle {
                                id: statusFlag
                                anchors.left: parent.left
                                anchors.leftMargin: -8
                                anchors.verticalCenter: parent.verticalCenter
                                width: 15
                                height: 38
                                radius: 7
                                property color statusColor: model.status === "In Progress" ? "blue" :
                                                                model.status === "Complete" ? "green" : "gray"
                                color: statusFlag.statusColor
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    id: shadowEffect
                                    shadowColor: statusFlag.statusColor
                                    shadowEnabled: true
                                    shadowScale: 1.5
                                    paddingRect: Qt.rect(0,0,0,0)
                                }
                            }

                            Text {
                                anchors.fill: parent  // Заполняет всё доступное пространство родителя
                                padding: 5
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font {
                                    family: "Jost"
                                    pixelSize: 16 + ThemeManager.additionalSize
                                }
                                wrapMode: Text.WordWrap
                                text: model.title
                                color: ThemeManager.fontColor
                                elide: Text.ElideRight
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: ThemeManager.isDarkTheme ? "white" : "black";}
                        }
                        Rectangle {
                            width: parent.width / 5
                            height: 55
                            color: "transparent"
                            Text {
                                anchors.fill: parent  // Заполняет всё доступное пространство родителя
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font {
                                    family: "Jost"
                                    pixelSize: 14 + ThemeManager.additionalSize
                                }
                                wrapMode: Text.WrapAnywhere
                                text: model.description
                                elide: Text.ElideRight
                                color: ThemeManager.fontColor
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: ThemeManager.isDarkTheme ? "white" : "black";}
                        }
                        Rectangle {
                            width: parent.width / 5
                            height: 55
                            color: "transparent"
                            Text {
                                anchors.centerIn: parent
                                font {
                                    family: "Jost"
                                    pixelSize: 16 + ThemeManager.additionalSize
                                }
                                wrapMode: Text.WordWrap
                                text: model.status
                                color: ThemeManager.fontColor
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: ThemeManager.isDarkTheme ? "white" : "black";}
                        }
                        Rectangle {
                            width: parent.width / 5
                            height: 55
                            color: "transparent"
                            Text {
                                anchors.fill: parent  // Заполняет всё доступное пространство родителя
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font {
                                    family: "Jost"
                                    pixelSize: 15 + ThemeManager.additionalSize
                                }
                                wrapMode: Text.WordWrap
                                text: space.reformateDate(model.createTime)
                                color: ThemeManager.fontColor
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: ThemeManager.isDarkTheme ? "white" : "black";}
                        }
                        Rectangle {
                            width: parent.width / 5
                            height: 55
                            color: "transparent"
                            Text {
                                anchors.fill: parent  // Заполняет всё доступное пространство родителя
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font {
                                    family: "Jost"
                                    pixelSize: 15 + ThemeManager.additionalSize
                                }
                                wrapMode: Text.WordWrap
                                text: space.reformateDate(model.dueTime)
                                color: ThemeManager.fontColor
                            }

                            CustomButton {
                                width: 40
                                height: 40
                                borderWidth: 0
                                borderRadius: 20
                                hoverEnabled: false
                                backColor: "transparent"
                                anchors {
                                    right: parent.right
                                    rightMargin: 7
                                    verticalCenter: parent.verticalCenter
                                }

                                onClicked: {
                                    client.deleteTask(model.taskId);
                                    tasksModel.removeTask(index);
                                }

                                Image {
                                    anchors.centerIn: parent
                                    width: 20
                                    height: 20
                                    source: ThemeManager.isDarkTheme ? "qrc:/new/images/trashWhite.png" : "qrc:/new/images/trash.png"
                                }
                            }

                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: ThemeManager.isDarkTheme ? "white" : "black";}
                        }
                    }
                    Rectangle {width: parent.width; height: 1; anchors.bottom: parent.bottom; color: ThemeManager.isDarkTheme ? "white" : "black";}
                }
            }
        }
    }
}
