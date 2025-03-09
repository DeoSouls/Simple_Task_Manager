import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import com.spacemodel.network 1.0
import "../common"

Flickable {
    id: flickable
    width: parent.width - 20
    height: 153
    anchors.horizontalCenter: parent.horizontalCenter
    contentWidth: contentItem.width
    contentHeight: height
    boundsMovement: Flickable.StopAtBounds
    clip: true

    property alias spaceModelList: spaceModel
    property alias spaceModelFiltList: filteredModel
    property var refsHome: null
    property var spacesArray: null
    property int userId: 0
    property string userName: ""
    property string userEmail: ""
    property string userImage: ""

    SpaceModel {
        id: spaceModel
    }

    SpaceModel {
        id: filteredModel
    }

    Connections {
        target: translator
        function onLanguageChanged() {
            textComponent.text = qsTr("Здесь пока ничего нет,\nсоздайте пространство для своих задач\nМеню -> Пространства+")
            // textTasks.text += qsTr(" задач")
        }
    }

    function reformateTime(dateString) {
        var date = new Date(dateString)
        var hours = date.getHours()      // возвращает часы (0-23)
        var minutes = date.getMinutes()  // возвращает минуты (0-59)
        if(isNaN(hours) || isNaN(minutes)) {
            return "00:00"
        } else {
            return hours + ":" + minutes
        }

    }

    Row {
        id: contentItem
        padding: 10
        spacing: 20

        Loader  {
            id: loaderComponent
            sourceComponent: componentWarning
            active: filteredModel.rowCount() === 0

            Connections {
                target: filteredModel
                function onRowsInserted() {
                    loaderComponent.active = filteredModel.rowCount() === 0
                }
                function onRowsRemoved() {
                    loaderComponent.active = filteredModel.rowCount() === 0
                }
            }
        }

        Component {
            id: componentWarning
            Rectangle {
                color: "transparent"
                anchors.fill: flickable

                Text {
                    id: textComponent
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("Здесь пока ничего нет,\nсоздайте пространство для своих задач\nМеню -> Пространства+")
                    font {
                        family: "Jost"
                        pixelSize: 13 + ThemeManager.additionalSize
                    }
                    color: ThemeManager.fontColor
                }
            }
        }

        ListView {
            id: listSpaces
            width: flickable.width
            height: flickable.height
            orientation: ListView.Horizontal
            spacing: 20
            model: filteredModel
            delegate: Rectangle {
                id: tasks_list
                width: 193;
                height: 121;
                radius: 18;
                border.width: ThemeManager.isDarkTheme ? 1 : null
                border.color: "white"
                color: Qt.hsva(Math.random(), 0.2, 1.0, 1.0)
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowColor: ThemeManager.isDarkTheme ? Qt.hsva(Math.random(), 0.9, 1.0, 1.0) : "#80000000"
                    shadowEnabled: true
                    shadowBlur: 0.6    // Мягкость тени
                    shadowVerticalOffset: 3  // Смещение тени вниз
                    shadowHorizontalOffset: 1  // Небольшое смещение вправо
                    autoPaddingEnabled: true  // Автоматическое расширение для тени
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    onClicked: {
                        console.log(flickable.refsHome)
                        if(flickable.refsHome !== null) {
                            flickable.refsHome.view.push("../SpacePage/Space.qml", {
                                spaceId: model.spaceId,
                                userId: flickable.userId,
                                spacename: model.spacename,
                                isFavorite: model.isFavorite,
                                userName: flickable.userName,
                                userEmail: flickable.userEmail,
                                userImage: flickable.userImage,
                                spacesArray: flickable.spacesArray
                            });
                        }
                    }
                }

                Text {
                    width: 115
                    height: 43
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: model.spacename
                    font {
                        pixelSize: 14 + ThemeManager.additionalSize
                        family: "Jost"
                        bold: true
                    }
                    elide: Text.ElideRight
                }
                Image {
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    source: "qrc:/new/images/option.png"

                    MouseArea {
                        id: areaOption
                        anchors.fill: parent
                        onClicked: {
                            buttonMenu.popup();
                        }
                    }

                    Menu {
                        id: buttonMenu
                        y: 0
                        MenuItem {
                            text: qsTr("Удалить")
                            onTriggered: {
                                client.deleteSpace(model.spaceId);
                                spaceModel.removeSpace(index);
                                filteredModel.removeSpace(index);
                            }
                        }
                    }
                }
                Canvas {
                    id: task_line
                    width: 170
                    height: 4
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 63
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.beginPath()
                        ctx.moveTo(0, height / 2) // Начало линии
                        ctx.lineTo(width, height / 2) // Конец линии
                        ctx.strokeStyle = "#C5C0C0" // Цвет линии
                        ctx.lineWidth = 0.5        // Толщина линии
                        ctx.stroke()
                    }
                }
                Row {
                    width: 144
                    height: 36
                    anchors.top: task_line.top
                    anchors.topMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    Image {
                        width: 62
                        height: 26
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/new/images/task_pofiles.png"
                    }
                    Grid {
                        width: 65; height: 35
                        spacing: 4
                        columns: 2
                        Image {
                            width: 16; height: 16
                            source: "qrc:/new/images/time.png"
                        }
                        Text {
                            width: 32; height: 17
                            color: "#222"
                            text: flickable.reformateTime(model.lastDueTime)
                            font {
                                family: "Jost"
                                pixelSize: 10 + ThemeManager.additionalSize
                                bold: true
                            }
                        }
                        Image {
                            width: 16; height: 16
                            source: "qrc:/new/images/time.png"
                        }
                        Text {
                            id: textTasks
                            width: 32; height: 17
                            color: "#222"
                            text: model.taskCount + qsTr(" задач")
                            font {
                                family: "Jost"
                                pixelSize: 10 + ThemeManager.additionalSize
                                bold: true
                            }
                        }
                    }
                }
            }
        }
    }
    function updateSearch(data) {
        const searchTerm = data.toLowerCase();
        flickable.spaceModelFiltList.clearSpace();

        console.log(flickable.spaceModelList.rowCount());
        for (let i = 0; i < flickable.spaceModelList.rowCount(); ++i) {
            const item = flickable.spaceModelList.getSpace(i);
            if (item.spacename.toLowerCase().includes(searchTerm)) {
                flickable.spaceModelFiltList.appendSpace(item);
            }
        }
    }
}
