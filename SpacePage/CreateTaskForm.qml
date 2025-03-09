import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

Drawer {
    id: root
    edge: Qt.TopEdge
    width: parent.width
    height: parent.height * 0.9

    background: Rectangle {
        color: ThemeManager.backgroundColor
    }

    property var spaceId: 0
    property var tasksModel: null

    Connections {
        target: translator
        function onLanguageChanged() {
            headerText.text = qsTr("Создание задачи")
            titleRect.placeholderTextLabel = qsTr("Название таска")
            smartTextArea.text = qsTr("Описание таска")

            inBtn.text = qsTr("Создать")
        }
    }

    Text {
        id: headerText
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        font {
            family: "Jost"
            pixelSize: 18 + ThemeManager.additionalSize
        }
        color: ThemeManager.fontColor
        text: qsTr("Создание задачи")
    }

    Column {
        width: parent.width - 30
        // height: parent.height
        anchors.centerIn: parent
        spacing: 40
        CustomTextField {
            id: titleRect
            width: parent.width
            height: 40
            placeholderTextLabel: qsTr("Название таска")
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
        }
        TextArea {
            id: smartTextArea
            text: qsTr("Описание таска")
            wrapMode: TextEdit.Wrap
            font {
                family: "Jost"
                pixelSize: 15 + ThemeManager.additionalSize
            }
            topPadding: 10
            bottomPadding: 10
            color: ThemeManager.fontColor
            width: parent.width
            height: Math.min(Math.max(40, contentHeight + 20), 200)


            // Красивый фон с анимацией
            background: Rectangle {
                color: ThemeManager.backgroundColor
                border.color: ThemeManager.fontColor
                border.width: 1
                radius: 5
            }

            // Плавное изменение высоты
            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }
        }
        ComboBox {
            id: statusComboBox
            width: parent.width
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
            anchors.horizontalCenter: parent.horizontalCenter
            selectedDate: new Date(2000, 0, 1) // Начальная дата
            startYear: 1950 // Минимальный год
            endYear: 2030 // Максимальный год

            onDateSelected: {
                console.log("Выбрана дата:", selectedDate.toLocaleDateString())
            }
        }
        CustomButton {
            id: inBtn
            width: parent.width
            height: 50

            text: qsTr("Создать")

            font.pixelSize: 18 + ThemeManager.additionalSize
            borderRadius: 17
            backHoverColor: "lightcyan"
            borderWidth: 1

            onClicked: {
                console.log(datePicker.fullDate)
                var currentDate = new Date();
                var formattedDate = Qt.formatDateTime(currentDate, "yyyy-MM-dd");

                client.createTask(titleRect.text, smartTextArea.text, statusComboBox.displayText, datePicker.fullDate, root.spaceId);
                // root.tasksModel.addTask(titleRect.text, descRect.text, statusComboBox.displayText, formattedDate, datePicker.fullDate, root.spaceId);
            }
        }
    }
}
