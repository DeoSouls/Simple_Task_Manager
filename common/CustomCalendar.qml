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
        spacing: 15

        // День
        ComboBox {
            id: dayCombo
            Layout.fillWidth: true
            height: 28
            font {
                family: "Jost"
                pixelSize: 13
            }
            model: ListModel { id: daysModel }
            onActivated: {
                day = parseInt(currentText)
                currentIndex = day - 1 // Обновляем индекс
            }
            currentIndex: {
                var idx = day - 1
                return idx >= 0 && idx < count ? idx : 0
            }

            delegate: ItemDelegate {
                width: dayCombo.width
                text: model.text
                highlighted: dayCombo.highlightedIndex === index
            }
        }

        // Месяц
        ComboBox {
            id: monthCombo
            Layout.fillWidth: true
            font {
                family: "Jost"
                pixelSize: 13
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

            delegate: ItemDelegate {
                width: monthCombo.width
                text: model.text
                highlighted: monthCombo.highlightedIndex === index
            }
        }

        // Год
        ComboBox {
            id: yearCombo
            Layout.fillWidth: true
            font {
                family: "Jost"
                pixelSize: 13
            }
            model: ListModel { id: yearsModel }
            currentIndex: year - startYear
            onActivated: year = parseInt(currentText)

            delegate: ItemDelegate {
                width: yearCombo.width
                text: model.text
                highlighted: yearCombo.highlightedIndex === index
            }
        }

        TextField {
            id: timeField
            placeholderText: "ЧЧ:ММ"
            inputMask: "99:99"
            Layout.fillWidth: true
            height: 25
            font {
                family: "Jost"
                pixelSize: 13
            }

            onTextChanged: {
                if (text.length === 6) {
                    var parts = text.split(':');
                    var hours = parseInt(parts[0], 10);
                    var minutes = parseInt(parts[1], 10);

                    if (hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59) {
                        color = "black"; // Валидное время
                    } else {
                        color = "red"; // Невалидное время
                    }
                } else {
                    color = "black"; // Неполный ввод
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
