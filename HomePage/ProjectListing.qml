import QtQuick
import QtQuick.Effects

Flickable {
    id: flickable
    width: 343
    height: 153
    anchors.horizontalCenter: parent.horizontalCenter
    contentWidth: contentItem.width // Указываем ширину контента для горизонтального свайпа
    contentHeight: contentItem.height // Контент фиксированной высоты
    boundsMovement: Flickable.StopAtBounds
    clip: true
    Rectangle {
        id: contentItem
        width: (193*3) + 50 // Содержимое шире Flickable в 3 раза
        height: flickable.height
        color: "transparent"
        Row {
            leftPadding: 5; rightPadding: 5
            spacing: 20
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 10
            Rectangle {
                id: tasks_list
                width: 193;
                height: 121;
                radius: 18;
                color: "#FFFCDD";
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowColor: "black"
                    shadowEnabled: true
                    shadowScale: 0.92
                    paddingRect: Qt.rect(10,10,10,10);
                }

                Text {
                    width: 115
                    height: 43
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: "Создать свой\nТаск менеджер"
                    font {
                        pixelSize: 14
                        family: "Jost"
                        bold: true
                    }
                }
                Image {
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    source: "qrc:/new/images/option.png"
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
                            text: "09:30"
                            font {
                                family: "Jost"
                                pixelSize: 10
                                bold: true
                            }
                        }
                        Image {
                            width: 16; height: 16
                            source: "qrc:/new/images/time.png"
                        }
                        Text {
                            width: 32; height: 17
                            color: "#222"
                            text: "10 задач"
                            font {
                                family: "Jost"
                                pixelSize: 10
                                bold: true
                            }
                        }
                    }
                }
            }
            Rectangle {
                width: 193;
                height: 121;
                radius: 18;
                color: "#E5FFD6";
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowColor: "black"
                    shadowEnabled: true
                    shadowScale: 0.92
                    paddingRect: Qt.rect(10,10,10,10);
                }

                Text {
                    width: 115
                    height: 43
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: "Простое мобильное\nчат-приложение"
                    font {
                        pixelSize: 14
                        family: "Jost"
                        bold: true
                    }
                }
                Image {
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    source: "qrc:/new/images/option.png"
                }
                Canvas {
                    id: task_line2
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
                    anchors.top: task_line2.top
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
                            text: "09:30"
                            font {
                                family: "Jost"
                                pixelSize: 10
                                bold: true
                            }
                        }
                        Image {
                            width: 16; height: 16
                            source: "qrc:/new/images/time.png"
                        }
                        Text {
                            width: 32; height: 17
                            color: "#222"
                            text: "10 задач"
                            font {
                                family: "Jost"
                                pixelSize: 10
                                bold: true
                            }
                        }
                    }
                }
            }
            Rectangle {
                width: 193;
                height: 121;
                radius: 18;
                color: "#FFD3D3";
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowColor: "black"
                    shadowEnabled: true
                    shadowScale: 0.92
                    paddingRect: Qt.rect(10,10,10,10);
                }
                Text {
                    width: 115
                    height: 43
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: "Проект по\nмаркетингу"
                    font {
                        pixelSize: 14
                        family: "Jost"
                        bold: true
                    }
                }
                Image {
                    width: 24
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    source: "qrc:/new/images/option.png"
                }
                Canvas {
                    id: task_line3
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
                    anchors.top: task_line3.top
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
                            text: "09:30"
                            font {
                                family: "Jost"
                                pixelSize: 10
                                bold: true
                            }
                        }
                        Image {
                            width: 16; height: 16
                            source: "qrc:/new/images/time.png"
                        }
                        Text {
                            width: 32; height: 17
                            color: "#222"
                            text: "10 задач"
                            font {
                                family: "Jost"
                                pixelSize: 10
                                bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
