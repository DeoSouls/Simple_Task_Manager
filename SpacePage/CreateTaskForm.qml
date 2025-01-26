import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

Drawer {
    id: root
    edge: Qt.TopEdge
    width: parent.width
    height: parent.height * 0.9

    property var spaceId: 0
    property var tasksModel: null

    Column {
        width: parent.width - 30
        // height: parent.height
        anchors.centerIn: parent
        spacing: 40
        CustomTextField {
            id: titleRect
            width: parent.width
            height: 40
            placeholderTextLabel: "Название таска"
            font {
                family: "Jost"
                pixelSize: 18
            }
        }
        CustomTextField {
            id: descRect
            width: parent.width
            height: 40
            placeholderTextLabel: "Описание таска"
            font {
                family: "Jost"
                pixelSize: 18
            }
        }
        ComboBox {
            id: statusComboBox
            width: parent.width
            height: 40
            model: ["Todo", "In Progress", "Complete"]

            contentItem: Text {
                leftPadding: 10
                text: statusComboBox.displayText
                font.pixelSize: 18
                font.family: "Jost"
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                implicitWidth: 120
                implicitHeight: 40
                border.color: statusComboBox.pressed ? "#17a81a" : "#21be2b"
                border.width: statusComboBox.visualFocus ? 2 : 1
                radius: 2
            }

            onCurrentIndexChanged: {
                console.log("Выбран статус:", model[currentIndex])
            }
        }
        CustomCalendar {
            id: datePicker
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

            text: "Создать"
            font.pixelSize: 18
            borderRadius: 17
            backHoverColor: "lightcyan"
            borderWidth: 1

            onClicked: {
                console.log(datePicker.fullDate)
                var currentDate = new Date();
                var formattedDate = Qt.formatDateTime(currentDate, "yyyy-MM-dd");

                client.createTask(titleRect.text, descRect.text, statusComboBox.displayText, datePicker.fullDate, root.spaceId);
                root.tasksModel.addTask(titleRect.text, descRect.text, statusComboBox.displayText, formattedDate, datePicker.fullDate, root.spaceId);
            }
        }
    }
}
