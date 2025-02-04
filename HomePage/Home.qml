import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls 2.15
import com.translator 1.0
import "../common"

Page {
    id: home
    anchors.top: parent.top
    anchors.topMargin: 20

    property int userId: 0
    property string userName: ""
    property string userEmail: ""
    property string userImage: ""

    background: Rectangle {
        color: ThemeManager.backgroundColor
    }

    Connections {
        target: translator
        function onLanguageChanged() {
            homeHeader.text = qsTr("Дом")
            hello_text.text = home.userName + ",\n"+qsTr("Добрый день!")
            textForText.text = qsTr("10 задач на выполнении.")
            placeholderLabel.text = qsTr("Поиск по проектам")+" ..."
            currentSpace.text = qsTr("Текущие проекты")
            seeAll.text = qsTr("Увидеть все")
            progressText.text = qsTr("Прогресс")
        }
    }

    ErrorPopup {
        id: errorPopup
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        borderWidth: 0
    }

    ProfileEdit {
        id: profile
        userId: home.userId
        userName: home.userName
        email: home.userEmail
        profileImage: home.userImage
    }

    function handleClientMessage(message) {
        if(message["type"] === "upd_user" && message["success"]) {
            home.userName = message["username"];

        } else if(message["type"] === "deleted_space" && message["success"]) {
            client.getSpaces(home.userId);
        } else if(message["type"] === "spaces" && message["success"]) {
            menuDrawer.initialSpaces = message["data"];
            proj_listing.spacesArray = message["data"];

            proj_listing.spaceModelList.updateFromJson(message["data"])
            proj_listing.spaceModelFiltList.updateFromJson(message["data"])
        } else if(message != undefined && message["success"]) {
            console.log("Создано пространство id: "+ message["spaceId"]);
            menuDrawer.container.createObjectFromString(message["spaceId"],
                                                           message["spacename"]);

            // if (!Array.isArray(menuDrawer.initialSpaces)) {
            //     menuDrawer.initialSpaces = [];
            // }
            // menuDrawer.initialSpaces.push({
            //     spaceId: message["spaceId"],
            //     spacename: message["spacename"]
            // });
        } else {
            if(message["none"]) {
                console.log("Worked none!!!")
                menuDrawer.initialSpaces = [];
            }

            errorPopup.textPopup = message["error"];
            errorPopup.open();
        }
    }

    CustomMenu {
        id: menuDrawer
        userId: home.userId
        currentPage: home
        userName: home.userName
        userEmail: home.userEmail
        userImage: home.userImage
    }

    Component.onCompleted: {
        client.getSpaces(home.userId);
    }

    header: ToolBar {
        height: 40
        background: null
        CustomButton {
            id: toMainMenu
            width: 30
            height: 40

            borderWidth: 0
            borderRadius: 24
            hoverEnabled: false

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
            id: homeHeader
            anchors.centerIn: parent
            text: qsTr("Дом")
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
            color: ThemeManager.fontColor
        }
        CustomButton {
            id: toProfile
            width: 30
            height: 40

            borderWidth: 0
            borderRadius: 25
            hoverEnabled: false
            backColor: ThemeManager.isDarkTheme ? "#f0f0f0" : "#0f111a"
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            onClicked: {
                profile.open();
            }

            Text {
                anchors.centerIn: parent
                color: ThemeManager.isDarkTheme ? "black" : "white"
                font {
                    family: "Jost"
                    pixelSize: 16 + ThemeManager.additionalSize
                }
                text: home.userName.charAt(0).toUpperCase()
            }
        }
    }


    Item {
        anchors.fill: parent
        Rectangle {
            id: hello_rect
            width: 342
            height: 123 /// 123
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 22
            radius: 12
            color: ThemeManager.isDarkTheme ? "#f0f0f0" : "#2C2C2C"

            Text {
                id: hello_text
                width: 128
                height: 42
                anchors.top: parent.top
                anchors.topMargin: 18
                anchors.left: parent.left
                anchors.leftMargin: 28
                color: ThemeManager.isDarkTheme ? "black" : "white"
                font {
                    pixelSize: 19 + ThemeManager.additionalSize
                    weight: 300
                    family: "Jost"
                }
                text: home.userName + ",\n"+qsTr("Добрый день!")
            }

            Text {
                id: textForText
                width: 114
                height: 14
                anchors.top: hello_text.top
                anchors.topMargin: hello_text.height + 20
                anchors.left: parent.left
                anchors.leftMargin: 28
                color: "#9C9C9C"
                font {
                    pixelSize: 10 + ThemeManager.additionalSize
                    weight: 300
                    family: "Jost"
                }
                text: qsTr("10 задач на выполнении.")
            }

            Rectangle {
                width: 80
                height: 80
                anchors.right: parent.right
                anchors.rightMargin: 22
                anchors.top: parent.top
                anchors.topMargin: 22
                border.width: 1
                radius: 40
                clip: true
                border.color: ThemeManager.isDarkTheme ? "black" : "white"
                color: "transparent"

                Canvas {
                    id: canvas
                    anchors.fill: parent

                    Image {
                        id: sourceImage
                        source: home.userImage === "" ? "qrc:/new/images/Ellipse.png" : home.userImage
                        visible: false
                        onStatusChanged: if (status === Image.Ready) canvas.requestPaint()
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()

                        // Создаем круглую маску
                        ctx.beginPath()
                        ctx.arc(width/2, height/2, Math.min(width, height)/2, 0, Math.PI * 2)
                        ctx.closePath()
                        ctx.clip()

                        // Рисуем изображение
                        if (sourceImage.status === Image.Ready) {
                            ctx.drawImage(sourceImage, 0, 0, width, height)
                        }
                    }

                    // Перерисовка при изменении размера
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                }
            }
        }

        Rectangle {
            id: inputBackground
            width: 200
            height: 26
            radius: 13
            border.width: ThemeManager.isDarkTheme ? 1 : null
            border.color: "white"
            color:  ThemeManager.isDarkTheme ? "#2e2e2e" : "white"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: hello_rect.bottom
            anchors.topMargin: -10
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowColor: ThemeManager.isDarkTheme ? "#2e2e2e" : "black"
                shadowEnabled: true
                shadowBlur: 0.6        // Мягкость тени
                shadowVerticalOffset: 1  // Смещение тени вниз
                shadowHorizontalOffset: 1  // Небольшое смещение вправо
                autoPaddingEnabled: true  // Автоматическое расширение для тени
            }

            Image {
                id: icon_search
                width: 14
                height: 14
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        proj_listing.updateSearch(inputField.text);

                        inputField.focus = false
                        // Передаём фокус самому контейнеру, чтобы TextField точно его потерял
                        parent.forceActiveFocus()
                    }
                }

                source: ThemeManager.isDarkTheme ? "qrc:/new/images/searchWhite.png" : "qrc:/new/images/search.png"
            }

            Timer {
                id: debounceTimer
                interval: 300      // задержка в миллисекундах
                repeat: false
                // При срабатывании таймера вызываем функцию поиска
                onTriggered: {
                    proj_listing.updateSearch(inputField.text);
                }
            }

            TextField {
                id: inputField
                anchors.left: icon_search.right
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 30
                font.pixelSize: 12 + ThemeManager.additionalSize
                font.family: "Jost"
                background: null
                color: ThemeManager.isDarkTheme ? "white" : "black"

                Label {
                    id: placeholderLabel
                    text: qsTr("Поиск по проектам")+" ..."
                    elide: Text.ElideRight
                    color: ThemeManager.isDarkTheme ? "white" : "#524F4F"
                    font {
                        family: "Jost"
                        pixelSize: 12 + ThemeManager.additionalSize
                    }
                    visible: !inputField.text && !inputField.activeFocus
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 16
                    }
                }
                onTextChanged: {
                    if (activeFocus) {
                        debounceTimer.restart();
                    }
                }
            }
        }

        Row {
            id: curr_proj_header
            width: 343
            height: 30
            anchors.top: inputBackground.bottom
            anchors.topMargin: 54
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                id: currentSpace
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Jost"
                font.pixelSize: 16 + ThemeManager.additionalSize
                font.bold: true
                color: ThemeManager.fontColor
                text: qsTr("Текущие проекты")
            }

            Text {
                id: seeAll
                anchors.right: right_image.left
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Jost"
                font.pixelSize: 14 + ThemeManager.additionalSize
                color: "#828282"
                text: qsTr("Увидеть все")
            }

            Image {
                id: right_image
                width: 16
                height: 16
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/new/images/right.png"
            }
        }

        ProjectListing {
            id: proj_listing

            anchors.top: curr_proj_header.bottom
            anchors.topMargin: 10
            refsHome: home.StackView
            userId: home.userId
            userName: home.userName
            userEmail: home.userEmail
            userImage: home.userImage
        }

        Row {
            width: 319
            height: 200
            anchors.top: proj_listing.bottom
            anchors.topMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 13
            Rectangle {
                id: lstat_rect
                width: 152
                height: parent.height
                radius: 13
                color: "#D9FEFF"
                border.width: ThemeManager.isDarkTheme ? 1 : null
                border.color: "white"
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowColor: ThemeManager.isDarkTheme ? Qt.hsva(Math.random(), 0.9, 1.0, 1.0) : "#80000000"
                    shadowEnabled: true
                    shadowBlur: 0.6        // Мягкость тени
                    shadowVerticalOffset: 3  // Смещение тени вниз
                    shadowHorizontalOffset: 1  // Небольшое смещение вправо
                    autoPaddingEnabled: true  // Автоматическое расширение для тени
                }
                Text {
                    id: progressText
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 15
                    text: qsTr("Прогресс")
                    font {
                        family: "Jost"
                        bold: true
                        pixelSize: 14 + ThemeManager.additionalSize
                    }
                }
                Image {
                    width: 80 * 0.9
                    height: 80 * 0.9
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 50
                    source: "qrc:/new/images/diagram_concept.jpg"
                }
                Canvas {
                    id: line_stats
                    width: parent.width
                    height: 2
                    anchors.top: parent.top
                    anchors.topMargin: 130
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.beginPath();
                        ctx.moveTo(0, height/2)
                        ctx.lineTo(width, height/2)
                        ctx.strokeStyle = "#C5C0C0"
                        ctx.lineWidth = 0.5
                        ctx.stroke();
                    }
                }
                Text {
                    width: 70
                    height: 50
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: line_stats.top
                    anchors.topMargin: 10
                    text: "+30\nЗа последнюю\nнеделю"
                    font {
                        family: "Jost"
                        bold: true
                        pixelSize: 10
                    }
                }

                Image {
                    width: 33
                    height: 29
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    anchors.top: line_stats.top
                    anchors.topMargin: 20
                    source: "qrc:/new/images/statisticts.jpg"
                }
            }
            Column {
                width: parent.width - lstat_rect.width
                height: 170
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Rectangle {
                    width: 319-165
                    height: 80
                    radius: 13
                    color: "#FFD3D3"
                    border.width: ThemeManager.isDarkTheme ? 1 : null
                    border.color: "white"
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowColor: ThemeManager.isDarkTheme ? Qt.hsva(Math.random(), 0.9, 1.0, 1.0) : "#80000000"
                        shadowEnabled: true
                        shadowBlur: 0.6        // Мягкость тени
                        shadowVerticalOffset: 3  // Смещение тени вниз
                        shadowHorizontalOffset: 1  // Небольшое смещение вправо
                        autoPaddingEnabled: true  // Автоматическое расширение для тени
                    }
                    Text {
                        width: 70
                        height: 38
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.leftMargin: 10
                        text: "+20\nПроектов"
                        font {
                            family: "Jost"
                            bold: true
                            pixelSize: 14
                        }
                    }
                    Image {
                        width: 59 * 0.8
                        height: 37 * 0.8
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 15
                        source: "qrc:/new/images/statisticts_more.jpg"
                    }
                }
                Rectangle {
                    width: 319-165
                    height: 80
                    radius: 13
                    color: "#FFD3D3"
                    border.width: ThemeManager.isDarkTheme ? 1 : null
                    border.color: "white"
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowColor: ThemeManager.isDarkTheme ? Qt.hsva(Math.random(), 0.9, 1.0, 1.0) : "#80000000"
                        shadowEnabled: true
                        shadowBlur: 0.6    // Мягкость тени
                        shadowVerticalOffset: 3  // Смещение тени вниз
                        shadowHorizontalOffset: 1  // Небольшое смещение вправо
                        autoPaddingEnabled: true  // Автоматическое расширение для тени
                    }
                    Text {
                        width: 70
                        height: 38
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: "+50\nКлиентов"
                        font {
                            family: "Jost"
                            bold: true
                            pixelSize: 14
                        }
                    }
                    Image {
                        width: 59 * 0.8
                        height: 37 * 0.8
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 15
                        source: "qrc:/new/images/statisticts_more.jpg"
                    }
                }
            }
        }
    }
}
