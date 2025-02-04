pragma Singleton
import QtQuick

QtObject {
    id: themeManager

    // Свойства
    property color backgroundColor: "#f0f0f0"
    property color fontColor: "#242424"
    property bool isDarkTheme: false
    property int additionalSize: 0

    // Методы
    function toggleTheme(isDark) {
        isDarkTheme = isDark;
        backgroundColor = isDark ? "#242424" : "#f0f0f0";
        fontColor = isDarkTheme ? "#f0f0f0" : "#000000";
    }

    function addingSize(size) {
        additionalSize = size;
    }
}
