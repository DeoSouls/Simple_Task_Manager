import QtQuick
import QtQuick.Controls
import "../common"

Page {
    id: task

    property var titleTask: "null"
    property var descriptionTask: "null"
    property var dueTimeTask: "null"
    property var statusTask: null
    property var pastPage: null
    property int taskId: 0
    property int spaceId: 0

    background: Rectangle {
        color: ThemeManager.backgroundColor
    }

    Connections {
        target: translator
        function onLanguageChanged() {
            headerTask.text = qsTr("Редактор")
            applyChangesText.text = qsTr("Применить изменения")
        }
    }

    ErrorPopup {
        id: errorPopup
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        borderWidth: 0
    }

    function handleClientMessage(message) {
        if(message["type"] === "updated_task" && message["success"]) {
            console.log("Таски обновлены");
        } else {
            errorPopup.textPopup = message["error"];
            errorPopup.open();
        }
    }

    function reformateTime(dateString) {
        var date = new Date(dateString)
        var hours = date.getHours()      // возвращает часы (0-23)
        var minutes = date.getMinutes()  // возвращает минуты (0-59)
        return hours + ":" + minutes
    }

    anchors.top: parent.top
    anchors.topMargin: 20
    header: ToolBar {
        id: toolBar
        height: 40
        background: null
        Button {
            id: toSpace
            width: 30
            height: 30
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            background: null
            onClicked: {
                task.pastPage.updateData(task.spaceId);
                task.StackView.view.pop();
            }
            onPressed: {
                jumpAnimationToSpace.start()
            }

            Image {
                width: 20
                height: 20
                anchors.centerIn: parent
                source: ThemeManager.isDarkTheme ? "qrc:/new/images/leftWhite.png" : "qrc:/new/images/left.png"
            }

            PropertyAnimation {
                id: jumpAnimationToSpace
                target: toSpace
                property: "scale"
                from: 1.0
                to: 1.2
                duration: 100
                easing.type: Easing.InOutQuad
                onStopped: {
                    toSpace.scale = 1.0
                }
            }
        }
        Text {
            id: headerTask
            anchors.centerIn: parent
            text: qsTr("Редактор")
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
            color: ThemeManager.isDarkTheme ? "white" : "black"
        }
    }

    Flickable {
        width: parent.width
        height: 650
        contentWidth: parent.width
        contentHeight: column.height
        boundsMovement: Flickable.StopAtBounds
        clip: true
        Column {
            id: column
            width: parent.width
            leftPadding: 15
            rightPadding: 15
            spacing: 15
            Rectangle {
                width: parent.width
                height: titleField.contentHeight + 20
                color: "transparent"
                TextField {
                    id: titleField
                    width: parent.width - 30
                    height: parent.height
                    wrapMode: Text.WrapAnywhere
                    background: null

                    font {
                        family: "Jost"
                        pixelSize: 24 + ThemeManager.additionalSize
                    }
                    text: task.titleTask
                    color: ThemeManager.isDarkTheme ? "white" : "black"
                }
            }

            ComboBox {
                id: statusComboBox
                width: parent.width - 30
                height: 40
                model: ["Todo", "In Progress", "Complete"]
                currentIndex: task.statusTask === "In Progress" ? 1 :
                                 task.statusTask === "Complete" ? 2 : 0

                contentItem: Text {
                    leftPadding: 10
                    text: statusComboBox.displayText
                    font.pixelSize: 18 + ThemeManager.additionalSize
                    font.family: "Jost"
                    verticalAlignment: Text.AlignVCenter
                    color: ThemeManager.isDarkTheme ? "white" : "black"
                }

                background: Rectangle {
                    implicitWidth: 120
                    implicitHeight: 40
                    color: ThemeManager.backgroundColor
                    border.color: statusComboBox.model[statusComboBox.currentIndex] === "Todo" ? "gray" :
                                         statusComboBox.model[statusComboBox.currentIndex] === "In Progress" ? "blue" : "green"
                    border.width: statusComboBox.visualFocus ? 2 : 1
                    radius: 2
                }

                onCurrentIndexChanged: {
                    console.log("Выбран статус:", model[currentIndex])
                }
            }

            CustomCalendar {
                id: datePicker
                height: 30
                selectedDate: new Date(task.dueTimeTask) // Начальная дата
                timeSelected: task.reformateTime(task.dueTimeTask)
                startYear: 1950 // Минимальный год
                endYear: 2030 // Максимальный год

                onDateSelected: {
                    console.log("Выбрана дата:", task.reformateTime(task.dueTimeTask))
                }
            }

            Rectangle {
                width: parent.width
                height: descField.contentHeight + 20
                color: "transparent"
                TextArea {
                    id: descField
                    text: task.descriptionTask
                    wrapMode: TextEdit.Wrap
                    font {
                        family: "Jost"
                        pixelSize: 15 + ThemeManager.additionalSize
                    }
                    anchors.top: parent.top
                    anchors.topMargin: 15
                    topPadding: 2
                    leftPadding: 0
                    color: ThemeManager.fontColor
                    width: parent.width - 30
                    height: Math.max(40, contentHeight + 10)


                    // Красивый фон с анимацией
                    background: Rectangle {
                        color: ThemeManager.backgroundColor
                        radius: 5
                    }

                    // Плавное изменение высоты
                    Behavior on height {
                        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                    }
                }
            }

            CustomButton {
                id: applyChanges
                width: parent.width - 40
                height: 60
                anchors.right: parent.right
                anchors.rightMargin: 20
                backColor: "#002aff"
                backHoverColor: "#3d5dff"
                borderRadius: 20
                contentItem: Text {
                    id: applyChangesText
                    text: qsTr("Применить изменения")
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font {
                        family: "Jost"
                        pixelSize: 16 + ThemeManager.additionalSize
                    }
                }

                onClicked: {
                    client.updateTask(task.taskId, titleField.text, descField.text, datePicker.fullDate, statusComboBox.displayText);
                }
            }
        }
    }
}
