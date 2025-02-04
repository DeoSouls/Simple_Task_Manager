import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import com.translator 1.0
import "../common"

Page {
    id: settings
    anchors.top: parent.top
    anchors.topMargin: 20

    background: Rectangle {
        color: ThemeManager.backgroundColor
    }

    Connections {
        target: translator
        function onLanguageChanged() {
            headerSet.text = qsTr("Настройки")
            gammaSet.text = qsTr("Цветовая гамма")
            gammaLight.text = qsTr("Светлая")
            gammaDark.text = qsTr("Темная")

            fontSize.text = qsTr("Размер шрифта")

            langSet.text = qsTr("Настройки языка")
            langRus.text = qsTr("Русский")
            langEng.text = qsTr("Английский")
            langGer.text = qsTr("Немецкий")
        }
    }

    header: ToolBar {
        height: 40
        background: null
        Button {
            id: toHome
            width: 30
            height: 30
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            background: null
            onClicked: {
                settings.StackView.view.pop();
            }
            onPressed: {
                jumpAnimationToHome.start()
            }

            Image {
                width: 20
                height: 20
                anchors.centerIn: parent
                source: ThemeManager.isDarkTheme ? "qrc:/new/images/leftWhite.png" : "qrc:/new/images/left.png"
            }

            PropertyAnimation {
                id: jumpAnimationToHome
                target: toHome
                property: "scale"
                from: 1.0
                to: 1.2
                duration: 100
                easing.type: Easing.InOutQuad
                onStopped: {
                    toHome.scale = 1.0
                }
            }
        }
        Text {
            id: headerSet
            anchors.centerIn: parent
            text: qsTr("Настройки")
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
            color: ThemeManager.fontColor
        }
    }

    Column {
        width: parent.width
        topPadding: 25
        leftPadding: 25
        rightPadding: 25
        spacing: 30
        Text {
            id: gammaSet
            font {
                family: "Jost"
                pixelSize: 22 + ThemeManager.additionalSize
                bold: true
            }
            text: qsTr("Цветовая гамма")
            color: ThemeManager.fontColor
        }

        Row {
            width: parent.width - parent.rightPadding * 2
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.6        // Мягкость тени
                shadowColor: "#80000000"  // Полупрозрачный черный цвет
                shadowVerticalOffset: 3  // Смещение тени вниз
                shadowHorizontalOffset: 1  // Небольшое смещение вправо
                autoPaddingEnabled: true  // Автоматическое расширение для тени
            }

            ButtonGroup {
                id: buttonGroup
                exclusive: true
            }

            CustomButton {
                width: parent.width / 2
                height: 40
                borderWidth: checked ? 2 : 1
                borderColor: ThemeManager.fontColor
                backColor: ThemeManager.backgroundColor
                checkable: true
                checked: true

                backHoverColor: "#a8a8a8"
                rectButton.bottomLeftRadius: 5
                rectButton.topLeftRadius: 5
                borderRadius: 0

                ButtonGroup.group: buttonGroup

                Text {
                    id: gammaLight
                    anchors.centerIn: parent
                    font {
                        family: "Jost"
                        pixelSize: 15 + ThemeManager.additionalSize
                    }
                    text: qsTr("Светлая")
                    color: ThemeManager.fontColor
                }

                onClicked: {
                    ThemeManager.toggleTheme(false);
                }
            }

            CustomButton {
                width: parent.width / 2
                height: 40
                borderWidth: checked ? 2 : 1
                borderColor: ThemeManager.fontColor
                backColor: ThemeManager.backgroundColor
                checkable: true
                rectButton.bottomRightRadius: 5
                rectButton.topRightRadius: 5

                backHoverColor: "#a8a8a8"
                borderRadius: 0
                ButtonGroup.group: buttonGroup

                Text {
                    id: gammaDark
                    anchors.centerIn: parent
                    font {
                        family: "Jost"
                        pixelSize: 15 + ThemeManager.additionalSize
                    }
                    text: qsTr("Темная")
                    color: ThemeManager.fontColor
                }

                onClicked: {
                    ThemeManager.toggleTheme(true);
                }
            }
        }
        Rectangle { width: parent.width - parent.rightPadding * 2; height: 1; color: "lightgray"}

        Text {
            id: fontSize
            font {
                family: "Jost"
                pixelSize: 22 + ThemeManager.additionalSize
                bold: true
            }
            text: qsTr("Размер шрифта")
            color: ThemeManager.fontColor
        }

        Row {
            width: parent.width - parent.rightPadding * 2
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.6        // Мягкость тени
                shadowColor: "#80000000"  // Полупрозрачный черный цвет
                shadowVerticalOffset: 3  // Смещение тени вниз
                shadowHorizontalOffset: 1  // Небольшое смещение вправо
                autoPaddingEnabled: true  // Автоматическое расширение для тени
            }

            ButtonGroup {
                id: buttonGroup2
                exclusive: true
            }

            CustomButton {
                width: parent.width / 5
                height: 40
                borderWidth: checked ? 2 : 1
                borderColor: ThemeManager.fontColor
                backColor: ThemeManager.backgroundColor
                checkable: true
                checked: true

                backHoverColor: "#a8a8a8"
                rectButton.bottomLeftRadius: 5
                rectButton.topLeftRadius: 5
                borderRadius: 0

                ButtonGroup.group: buttonGroup2

                Text {
                    anchors.centerIn: parent
                    font {
                        family: "Jost"
                        pixelSize: 10
                    }
                    text: "аА"
                    color: ThemeManager.fontColor
                }
                onClicked: {
                    ThemeManager.addingSize(1);
                }
            }

            CustomButton {
                width: parent.width / 5
                height: 40
                borderWidth: checked ? 2 : 1
                borderColor: ThemeManager.fontColor
                backColor: ThemeManager.backgroundColor
                checkable: true

                backHoverColor: "#a8a8a8"
                borderRadius: 0
                ButtonGroup.group: buttonGroup2

                Text {
                    anchors.centerIn: parent
                    font {
                        family: "Jost"
                        pixelSize: 11
                    }
                    text: "аА"
                    color: ThemeManager.fontColor
                }
                onClicked: {
                    ThemeManager.addingSize(2);
                }
            }

            CustomButton {
                width: parent.width / 5
                height: 40
                borderWidth: checked ? 2 : 1
                borderColor: ThemeManager.fontColor
                backColor: ThemeManager.backgroundColor
                checkable: true

                backHoverColor: "#a8a8a8"
                borderRadius: 0

                ButtonGroup.group: buttonGroup2

                Text {
                    anchors.centerIn: parent
                    font {
                        family: "Jost"
                        pixelSize: 12
                    }
                    text: "аА"
                    color: ThemeManager.fontColor
                }
                onClicked: {
                    ThemeManager.addingSize(3);
                }
            }

            CustomButton {
                width: parent.width / 5
                height: 40
                borderWidth: checked ? 2 : 1
                borderColor: ThemeManager.fontColor
                backColor: ThemeManager.backgroundColor
                checkable: true

                backHoverColor: "#a8a8a8"
                borderRadius: 0

                ButtonGroup.group: buttonGroup2

                Text {
                    anchors.centerIn: parent
                    font {
                        family: "Jost"
                        pixelSize: 13
                    }
                    text: "аА"
                    color: ThemeManager.fontColor
                }
                onClicked: {
                    ThemeManager.addingSize(4);
                }
            }

            CustomButton {
                width: parent.width / 5
                height: 40
                borderWidth: checked ? 2 : 1
                borderColor: ThemeManager.fontColor
                backColor: ThemeManager.backgroundColor
                checkable: true

                backHoverColor: "#a8a8a8"
                rectButton.bottomRightRadius: 5
                rectButton.topRightRadius: 5
                borderRadius: 0

                ButtonGroup.group: buttonGroup2

                Text {
                    anchors.centerIn: parent
                    font {
                        family: "Jost"
                        pixelSize: 14
                    }
                    text: "аА"
                    color: ThemeManager.fontColor
                }

                onClicked: {
                    ThemeManager.addingSize(5);
                }
            }
        }
        Rectangle { width: parent.width - parent.rightPadding * 2; height: 1; color: "lightgray"}

        Text {
            id: langSet
            font {
                family: "Jost"
                pixelSize: 22 + ThemeManager.additionalSize
                bold: true
            }
            text: qsTr("Настройки языка")
            color: ThemeManager.fontColor
        }

        Row {
            width: parent.width - parent.rightPadding * 2
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.6        // Мягкость тени
                shadowColor: "#80000000"  // Полупрозрачный черный цвет
                shadowVerticalOffset: 3  // Смещение тени вниз
                shadowHorizontalOffset: 1  // Небольшое смещение вправо
                autoPaddingEnabled: true  // Автоматическое расширение для тени
            }

            ButtonGroup {
                id: buttonGroup3
                exclusive: true
            }

            CustomButton {
                width: parent.width / 3
                height: 40
                borderWidth: checked ? 2 : 1
                borderColor: ThemeManager.fontColor
                backColor: ThemeManager.backgroundColor
                checkable: true
                checked: true

                backHoverColor: "#a8a8a8"
                rectButton.bottomLeftRadius: 5
                rectButton.topLeftRadius: 5
                borderRadius: 0

                ButtonGroup.group: buttonGroup3

                Text {
                    id: langRus
                    anchors.centerIn: parent
                    font {
                        family: "Jost"
                        pixelSize: 15 + ThemeManager.additionalSize
                    }
                    text: qsTr("Русский")
                    color: ThemeManager.fontColor
                }
                onClicked: {
                    translator.changeLanguage("ru")
                }
            }

            CustomButton {
                width: parent.width / 3
                height: 40
                borderWidth: checked ? 2 : 1
                borderColor: ThemeManager.fontColor
                backColor: ThemeManager.backgroundColor
                checkable: true

                backHoverColor: "#a8a8a8"
                borderRadius: 0
                ButtonGroup.group: buttonGroup3

                Text {
                    id: langEng
                    anchors.centerIn: parent
                    font {
                        family: "Jost"
                        pixelSize: 15 + ThemeManager.additionalSize
                    }
                    text: qsTr("Английский")
                    color: ThemeManager.fontColor
                }
                onClicked: {
                    translator.changeLanguage("en")
                }
            }

            CustomButton {
                width: parent.width / 3
                height: 40
                borderWidth: checked ? 2 : 1
                borderColor: ThemeManager.fontColor
                backColor: ThemeManager.backgroundColor
                checkable: true

                backHoverColor: "#a8a8a8"
                rectButton.bottomRightRadius: 5
                rectButton.topRightRadius: 5
                borderRadius: 0

                ButtonGroup.group: buttonGroup3

                Text {
                    id: langGer
                    anchors.centerIn: parent
                    font {
                        family: "Jost"
                        pixelSize: 15 + ThemeManager.additionalSize
                    }
                    text: qsTr("Немецкий")
                    color: ThemeManager.fontColor
                }
                onClicked: {
                    translator.changeLanguage("de")
                }
            }
        }
        Rectangle { width: parent.width - parent.rightPadding * 2; height: 1; color: "lightgray"}
    }
}
