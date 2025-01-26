import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls 2.15
import "../common"

Page {
    id: home
    anchors.top: parent.top
    anchors.topMargin: 20

    property int userId: 0

    ErrorPopup {
        id: errorPopup
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        borderWidth: 0
    }

    function handleClientMessage(message) {
        if(message["type"] === "spaces" && message["success"]) {
            menuDrawer.initialSpaces = message["data"];
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

    CustomMenu {
        id: menuDrawer
        userId: home.userId
        currentPage: home
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
            text: qsTr("Дом")
            font {
                family: "Jost"
                pixelSize: 18
            }
        }
        CustomButton {
            id: toSetting
            width: 50
            height: 50

            borderWidth: 0
            borderRadius: 25
            hoverEnabled: false

            backColor: "transparent"

            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }

            onClicked: {
                home.StackView.view.push("../SettingsPage/Settings.qml", {})
            }

            Image {
                anchors.centerIn: parent
                width: 24
                height: 24
                source: "qrc:/new/images/settings.png"
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
            color: "#2C2C2C"

            Text {
                id: hello_text
                width: 128
                height: 42
                anchors.top: parent.top
                anchors.topMargin: 22
                anchors.left: parent.left
                anchors.leftMargin: 28
                color: "white"
                font {
                    pixelSize: 19
                    weight: 300
                    family: "Jost"
                }
                text: "Влад,\nДобрый день!"
            }

            Text {
                width: 114
                height: 14
                anchors.top: hello_text.top
                anchors.topMargin: hello_text.height + 17
                anchors.left: parent.left
                anchors.leftMargin: 28
                color: "#9C9C9C"
                font {
                    pixelSize: 10
                    weight: 300
                    family: "Jost"
                }
                text: "10 задач на выполнении."
            }

            Rectangle {
                width: 80
                height: 80
                anchors.right: parent.right
                anchors.rightMargin: 22
                anchors.top: parent.top
                anchors.topMargin: 22
                Image {
                    anchors.fill: parent
                    source: "qrc:/new/images/Ellipse.png"
                }
            }
        }

        Rectangle {
            id: inputBackground
            width: 200
            height: 26
            radius: 13
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: hello_rect.bottom
            anchors.topMargin: -10
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowColor: "black"
                shadowEnabled: true
                shadowScale: 0.92
                paddingRect: Qt.rect(0,0,0,0);
            }

            Image {
                id: icon_search
                width: 14
                height: 14
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/new/images/search.png"
            }

            TextField {
                id: inputField
                anchors.left: icon_search.right
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 30
                placeholderText: "Поиск по проектам ..."
                font.pixelSize: 14
                font.family: "Jost"
                background: null
            }
        }

        Row {
            id: curr_proj_header
            width: 343
            height: 23
            anchors.top: inputBackground.bottom
            anchors.topMargin: 54
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                font.family: "Jost"
                font.pixelSize: 16
                font.bold: true
                text: "Текущие проекты"
            }

            Text {
                anchors.right: right_image.left
                font.family: "Jost"
                font.pixelSize: 14
                color: "#646363"
                text: "Увидеть все"
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
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowColor: "black"
                    shadowEnabled: true
                    shadowScale: 0.92
                    paddingRect: Qt.rect(0,0,0,0);
                }
                Text {
                    width: 61
                    height: 20
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 15
                    text: "Прогресс"
                    font {
                        family: "Jost"
                        bold: true
                        pixelSize: 14
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
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowColor: "black"
                        shadowEnabled: true
                        shadowScale: 0.90
                        paddingRect: Qt.rect(0,0,0,0);
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
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowColor: "black"
                        shadowEnabled: true
                        shadowScale: 0.90
                        paddingRect: Qt.rect(0,0,0,0);
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
