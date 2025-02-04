import QtQuick
import QtQuick.Controls
import "../common"

Page {
    id: login
    anchors.top: parent.top
    anchors.topMargin: 20

    background: Rectangle {
        color: ThemeManager.backgroundColor
    }

    header: ToolBar {
        height: 40
        background: null
        Text {
            id: headerLogin
            anchors.centerIn: parent
            text: qsTr("Авторизация")
            font {
                family: "Jost"
                pixelSize: 18
            }
        }
    }

    ErrorPopup {
        id: errorPopup
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2) -220
        borderWidth: 0
    }

    Connections {
        target: translator
        function onLanguageChanged() {
            headerLogin.text = qsTr("Авторизация")
            loginRect.placeholderTextLabel = qsTr("Логин")
            passRect.placeholderTextLabel = qsTr("Пароль")
            refSignup.text = qsTr("Еще не зарегистрированы? Cюда.")
            inBtn.text = qsTr("Войти")

            errorPopup.textPopup = qsTr("Пожалуйста, заполните все поля");
        }
    }

    function handleClientMessage(message) {
        if(message != undefined && message["success"]) {
            console.log("Успешная регистрация/авторизация: " + message["userId"]);
            login.StackView.view.push("../HomePage/Home.qml", { userId: parseInt(message["userId"]),
                                      userName: message["username"], userImage: message["source"], userEmail: message["email"] });
        } else {
            errorPopup.textPopup = message["error"];
            errorPopup.open();
        }
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -180
        width: 300
        CustomTextField {
            id: loginRect
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
            id: passRect
            anchors.top: loginRect.bottom
            anchors.topMargin: 40
            width: parent.width
            height: 40
            placeholderTextLabel: qsTr("Пароль")
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
        }
        Text {
            id: refSignup
            anchors.top: passRect.bottom
            anchors.topMargin: 32
            anchors.horizontalCenter: parent.horizontalCenter

            text: qsTr("Еще не зарегистрированы? Cюда.")

            font {
                family: "Jost"
                pixelSize: 16 + ThemeManager.additionalSize
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    login.StackView.view.push("../SignUpPage/SignUp.qml", { })
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
            anchors.top: refSignup.bottom
            anchors.topMargin: 40
            width: parent.width
            height: 50

            text: qsTr("Войти")
            font.pixelSize: 18 + ThemeManager.additionalSize
            borderRadius: 17
            backHoverColor: "lightcyan"
            borderWidth: 1

            onClicked: {
                if(loginRect.text.length === 0 || passRect.text === 0) {
                    errorPopup.textPopup = qsTr("Пожалуйста, заполните все поля");
                    errorPopup.open();
                    return;
                }

                client.sendLoginData(loginRect.text, passRect.text);
            }
        }
    }
}
