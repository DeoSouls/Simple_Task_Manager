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
    property var initialSpaces: null

    anchors.top: parent.top
    anchors.topMargin: 20

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

    function handleClientMessage(message) {
        if(message["type"] === "get_tasks" && message["success"]) {
            console.log("Получены таски");
            tasksModel.updateFromJson(message["data"]);
        } else if(message["type"] === "created_task" && message["success"]) {
            console.log("Создан таск id: "+ message["taskId"]);
        } else if(message != undefined && message["success"]) {
            console.log("Создано пространство id: "+ message["spaceId"]);
            menuDrawer.container.createObjectFromString(message["spaceId"],
                                                           message["spacename"],
                                                           StackView.view,
                                                           menuDrawer);
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
        }
    }

    function reformateDate(dateString) {
        var date = new Date(dateString)
        return Qt.formatDateTime(date, "dd-MM-yyyy")
    }

    CustomMenu {
        id: menuDrawer
        userId: space.userId
        currentPage: space
        initialSpaces: space.initialSpaces
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

            backColor: "transparent"

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
                source: "qrc:/new/images/menu.png"
            }
        }
        Text {
            anchors.centerIn: parent
            text: space.spacename
            font {
                family: "Jost"
                pixelSize: 18
            }
        }
        CustomButton {
            id: toCreateTask
            width: 48
            height: 48

            borderWidth: 0
            borderRadius: 24
            hoverEnabled: false

            backColor: "transparent"

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
                source: "qrc:/new/images/plus.png"
            }
        }
    }
    Flickable {
        id: nameColumns
        width: 343
        height: 453
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        contentWidth: contentItem.childrenRect.width
        contentHeight: contentItem.childrenRect.height
        boundsMovement: Flickable.StopAtBounds
        clip: true
        Rectangle {
            width: 320 * 3
            height: 400 // Увеличиваем высоту для возможности вертикальной прокрутки
            color: "transparent" // Делаем фон прозрачным
            Rectangle {
                id: columnsRect
                color: "transparent"
                width: parent.width
                height: 30
                anchors.top: parent.top
                Rectangle {width: parent.width; height: 1; anchors.top: parent.top; color: "black";}
                Rectangle {width: 1; height: parent.height; anchors.left: parent.left; color: "black";}
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
                                    pixelSize: 16
                                }
                                text: modelData
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: "black";}
                        }
                    }
                }
                Rectangle {width: parent.width; height: 1; anchors.bottom: parent.bottom; color: "black";}
            }
            // Здесь можно добавить дополнительное содержимое
            ListView {
                anchors.top: columnsRect.bottom
                anchors.bottom: parent.bottom
                width: parent.width
                model: tasksModel
                delegate: Rectangle {
                    width: parent.width
                    height: 45
                    color: "transparent"
                    Rectangle {width: 1; height: parent.height; anchors.left: parent.left; color: "black";}
                    Row {
                        anchors.top: parent.top
                        width: parent.width
                        height: 45
                        Rectangle {
                            width: parent.width / 5
                            height: 45
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
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                padding: 5
                                font {
                                    family: "Jost"
                                    pixelSize: 16
                                }
                                wrapMode: Text.WordWrap
                                text: model.title
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: "black";}
                        }
                        Rectangle {
                            width: parent.width / 5
                            height: 45
                            color: "transparent"
                            Text {
                                anchors.fill: parent  // Заполняет всё доступное пространство родителя
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font {
                                    family: "Jost"
                                    pixelSize: 14
                                }
                                wrapMode: Text.WrapAnywhere
                                text: model.description
                                elide: Text.ElideRight
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: "black";}
                        }
                        Rectangle {
                            width: parent.width / 5
                            height: 45
                            color: "transparent"
                            Text {
                                anchors.centerIn: parent
                                font {
                                    family: "Jost"
                                    pixelSize: 16
                                }
                                wrapMode: Text.WordWrap
                                text: model.status
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: "black";}
                        }
                        Rectangle {
                            width: parent.width / 5
                            height: 45
                            color: "transparent"
                            Text {
                                anchors.fill: parent  // Заполняет всё доступное пространство родителя
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font {
                                    family: "Jost"
                                    pixelSize: 15
                                }
                                wrapMode: Text.WordWrap
                                text: space.reformateDate(model.createTime)
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: "black";}
                        }
                        Rectangle {
                            width: parent.width / 5
                            height: 45
                            color: "transparent"
                            Text {
                                anchors.fill: parent  // Заполняет всё доступное пространство родителя
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font {
                                    family: "Jost"
                                    pixelSize: 15
                                }
                                wrapMode: Text.WordWrap
                                text: space.reformateDate(model.dueTime)
                            }
                            Rectangle {width: 1; height: parent.height; anchors.right: parent.right; color: "black";}
                        }
                    }
                    Rectangle {width: parent.width; height: 1; anchors.bottom: parent.bottom; color: "black";}
                }
            }
        }
    }
}
