import QtQuick
import QtQuick.Controls
import "../common"
// import com.client.network 1.0

Page {
    id: signup
    anchors.top: parent.top
    anchors.topMargin: 20

    background: Rectangle {
        color: ThemeManager.backgroundColor
    }

        ErrorPopup {
            id: errorPopup
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2) -260

            borderWidth: 0
        }

        Connections {
            target: translator
            function onLanguageChanged() {
                headerSign.text = qsTr("Регистрация")
                nameRect.placeholderTextLabel = qsTr("Логин")
                passRect.placeholderTextLabel = qsTr("Пароль")
                confPassRect.placeholderTextLabel = qsTr("Подтверждение пароля")
                refLogin.text = qsTr("Уже зарегистрированы? Cюда.")
                inBtn.text = qsTr("Начать")

                errorPopup.textPopup = qsTr("Пожалуйста, заполните все поля");
                errorPopup.textPopup = qsTr("Пароли должны совпадать!")
            }
        }

        function handleClientMessage(message) {
            if(message != undefined && message["success"]) {
                console.log("Успешная регистрация/авторизация");
                signup.StackView.view.push("../HomePage/Home.qml", { userId: parseInt(message["userId"]),
                                               userName: message["username"], userEmail: message["email"] })
            } else {
                errorPopup.textPopup = message["error"];
                errorPopup.open();
            }
        }

        header: ToolBar {
            height: 40
            background: null
            Text {
                id: headerSign
                anchors.centerIn: parent
                text: qsTr("Регистрация")
                font {
                    family: "Jost"
                    pixelSize: 18 + ThemeManager.additionalSize
                }
            }
        }
        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -220
            width: 300
            CustomTextField {
                id: nameRect
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                height: 40
                placeholderTextLabel: qsTr("Логин")
                font {
                    family: "Jost"
                    pixelSize: 18 + ThemeManager.additionalSize
                }
            }
            CustomTextField {
                id: emailRect
                anchors.top: nameRect.bottom
                anchors.topMargin: 17
                width: parent.width
                height: 40
                placeholderTextLabel: "E-mail"
                font {
                    family: "Jost"
                    pixelSize: 18
                }
            }
            CustomTextField {
                id: passRect
                anchors.top: emailRect.bottom
                anchors.topMargin: 17
                width: parent.width
                height: 40
                placeholderTextLabel: qsTr("Пароль")
                font {
                    family: "Jost"
                    pixelSize: 18 + ThemeManager.additionalSize
                }
            }
            CustomTextField {
                id: confPassRect
                anchors.top: passRect.bottom
                anchors.topMargin: 17

                width: parent.width
                height: 40
                borderWidth: 1

                placeholderTextLabel: qsTr("Подтверждение пароля")
                font {
                    family: "Jost"
                    pixelSize: 18 + ThemeManager.additionalSize
                }
            }

            Text {
                id: refLogin
                anchors.top: confPassRect.bottom
                anchors.topMargin: 32
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Уже зарегистрированы? Cюда.")
                font {
                    family: "Jost"
                    pixelSize: 16 + ThemeManager.additionalSize
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        signup.StackView.view.pop()
                    }
                }
                Rectangle {
                    id: underline
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "black"
                }
            }

            CustomButton {
                id: inBtn
                anchors.top: refLogin.bottom
                anchors.topMargin: 32
                width: parent.width
                height: 50

                text: qsTr("Начать")
                font.pixelSize: 18 + ThemeManager.additionalSize
                borderRadius: 17
                backHoverColor: "lightcyan"
                borderWidth: 1

                onClicked: {
                    if(nameRect.text.length === 0 || emailRect.text.length === 0 || confPassRect.text.length === 0) {
                        errorPopup.textPopup = qsTr("Пожалуйста, заполните все поля");
                        errorPopup.open();
                        return;
                    }

                    if(passRect.text !== confPassRect.text) {
                        errorPopup.textPopup = qsTr("Пароли должны совпадать!")
                        errorPopup.open();
                        return;
                    }
                    client.sendRegisterData(nameRect.text, emailRect.text, confPassRect.text)
                }
            }
        }
    }
