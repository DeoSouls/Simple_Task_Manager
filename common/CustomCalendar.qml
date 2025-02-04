import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: datePicker
    width: 320
    height: 28

    property date selectedDate: new Date()
    property int startYear: 1900
    property int endYear: new Date().getFullYear() + 10
    property date fullDate: datePicker.getDateTimeForDB()
    property string timeSelected: ""

    signal dateSelected(date selectedDate)

    function updateDays() {
        daysModel.clear()
        const daysInMonth = new Date(year, month + 1, 0).getDate()
        var prevDay = day
        for(let i = 1; i <= daysInMonth; i++) {
            daysModel.append({text: i.toString()})
        }
        day = Math.min(prevDay, daysInMonth)

        // Форсируем обновление индекса
        Qt.callLater(() => dayCombo.currentIndex = day - 1)
    }

    function updateYears() {
        yearsModel.clear()
        for(let i = startYear; i <= endYear; i++) {
            yearsModel.append({text: i.toString()})
        }
    }

    Component.onCompleted: {
        month = selectedDate.getMonth()
        year = selectedDate.getFullYear()
        updateDays()
        updateYears()
    }

    property int day: selectedDate.getDate()
    property int month: selectedDate.getMonth()
    property int year: selectedDate.getFullYear()

    onDayChanged: updateSelectedDate()
    onMonthChanged: {
        updateDays()
        updateSelectedDate()
    }
    onYearChanged: {
        updateDays()
        updateSelectedDate()
    }

    function updateSelectedDate() {
        var newDate = new Date(year, month, day)
        selectedDate = newDate
        dateSelected(newDate)
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        // День
        ComboBox {
            id: dayCombo
            Layout.preferredWidth: 70  // Фиксированная ширина
            Layout.fillWidth: false
            height: 50
            font {
                family: "Jost"
                pixelSize: 13 + ThemeManager.additionalSize
            }
            model: ListModel { id: daysModel }
            onActivated: {
                day = parseInt(currentText)
                currentIndex = day - 1
            }
            currentIndex: {
                var idx = day - 1
                return idx >= 0 && idx < count ? idx : 0
            }

            contentItem: Text {
                text: dayCombo.displayText
                color: ThemeManager.fontColor
                font: dayCombo.font
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
            }

            delegate: ItemDelegate {
                width: dayCombo.width
                height: 50
                contentItem: Text {
                    text: model.text
                    color: ThemeManager.fontColor
                    font: dayCombo.font
                    verticalAlignment: Text.AlignVCenter
                    // leftPadding: 12
                }
                highlighted: dayCombo.highlightedIndex === index

                background: Rectangle {
                    color: ThemeManager.backgroundColor
                }
            }

            background: Rectangle {
                implicitWidth: dayCombo.width
                implicitHeight: dayCombo.height
                color: ThemeManager.backgroundColor
                border.color: ThemeManager.fontColor
                border.width: 1
                radius: 4
            }
        }

        // Месяц
        ComboBox {
            id: monthCombo
            Layout.preferredWidth: 70  // Фиксированная ширина
            Layout.fillWidth: false
            height: 50
            font {
                family: "Jost"
                pixelSize: 13 + ThemeManager.additionalSize
            }
            model: ListModel {
                id: monthsModel
                Component.onCompleted: {
                    var months = []
                    for(var i = 0; i < 12; i++) {
                        months.push(Qt.locale().standaloneMonthName(i, Locale.LongFormat))
                    }
                    append(months.map(function(m) { return { text: m } }))
                }
            }
            currentIndex: month
            onActivated: month = index

            contentItem: Text {
                text: monthCombo.displayText
                color: ThemeManager.fontColor
                font: monthCombo.font
                verticalAlignment: Text.AlignVCenter
            }

            delegate: ItemDelegate {
                width: monthCombo.width
                height: 50
                contentItem: Text {
                    text: model.text
                    color: ThemeManager.fontColor
                    font: monthCombo.font
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: monthCombo.highlightedIndex === index

                background: Rectangle {
                    color: ThemeManager.backgroundColor
                }
            }

            background: Rectangle {
                implicitWidth: monthCombo.width
                implicitHeight: monthCombo.height
                color: ThemeManager.backgroundColor
                border.color: ThemeManager.fontColor
                border.width: 1
                radius: 4
            }
        }

        // Год
        ComboBox {
            id: yearCombo
            Layout.preferredWidth: 70  // Фиксированная ширина
            Layout.fillWidth: false
            height: 50
            font {
                family: "Jost"
                pixelSize: 12 + ThemeManager.additionalSize
            }
            model: ListModel { id: yearsModel }
            currentIndex: year - startYear
            onActivated: year = parseInt(currentText)

            contentItem: Text {
                text: yearCombo.displayText
                color: ThemeManager.fontColor
                font: yearCombo.font
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
            }

            delegate: ItemDelegate {
                width: yearCombo.width
                height: 50
                contentItem: Text {
                    text: model.text
                    color: ThemeManager.fontColor
                    font: yearCombo.font
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: yearCombo.highlightedIndex === index

                background: Rectangle {
                    color: ThemeManager.backgroundColor
                }
            }

            background: Rectangle {
                implicitWidth: yearCombo.width
                implicitHeight: yearCombo.height
                color: ThemeManager.backgroundColor
                border.color: ThemeManager.fontColor
                border.width: 1
                radius: 4
            }
        }

        TextField {
            id: timeField
            inputMask: "00:00; "
            Layout.preferredWidth: 60  // Фиксированная ширина
            Layout.fillWidth: false
            height: 50
            font {
                family: "Jost"
                pixelSize: 13 + ThemeManager.additionalSize
            }
            text: "00:00"
            color: ThemeManager.fontColor
            leftPadding: 5
            rightPadding: 5
            topPadding: 15
            bottomPadding: 15

            background: Rectangle {
                color: ThemeManager.backgroundColor
                border.width: 1
                border.color: ThemeManager.fontColor
                radius: 4
            }

            property bool valid: false

            onTextChanged: {
                if (text.length === 5) {
                    var parts = text.split(':')
                    if (parts.length !== 2) {
                        valid = false
                        return
                    }

                    var hours = parseInt(parts[0], 10)
                    var minutes = parseInt(parts[1], 10)
                    valid = !isNaN(hours) && !isNaN(minutes) &&
                             hours >= 0 && hours <= 23 &&
                             minutes >= 0 && minutes <= 59
                } else {
                    valid = text.length === 0 // Считаем пустое поле валидным
                }

                color = valid ? ThemeManager.fontColor : "red"
                if (valid && text.length === 5) {
                    // Обновляем время в datePicker только при валидном значении
                    datePicker.timeSelected = text
                }
            }
        }
    }
    function getDateTimeForDB() {
        // Получаем дату из календаря
        const date = datePicker.selectedDate

        // Парсим время из текстового поля
        const timeParts = timeField.text.split(':')
        const hours = parseInt(timeParts[0]) || 0
        const minutes = parseInt(timeParts[1]) || 0

        // Создаем новый объект Date с объединенными значениями
        const fullDate = new Date(
            date.getFullYear(),
            date.getMonth(),
            date.getDate(),
            hours,
            minutes
        )

        // Форматируем для SQL (YYYY-MM-DD HH:MM:SS)
        return Qt.formatDateTime(fullDate, "yyyy-MM-dd HH:mm:ss")
    }
}
