import QtQuick
import QtQuick.Controls
import "../common"

Page {
    id: login
    anchors.top: parent.top
    anchors.topMargin: 20
    header: ToolBar {
        height: 40
        background: null
        Text {
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

    function handleClientMessage(message) {
        if(message != undefined && message["success"]) {
            console.log("Успешная регистрация/авторизация: " + message["userId"]);
            login.StackView.view.push("../HomePage/Home.qml", { userId: parseInt(message["userId"]) })
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
            placeholderTextLabel: "Логин"
            font {
                family: "Jost"
                pixelSize: 18
            }
        }
        CustomTextField {
            id: passRect
            anchors.top: loginRect.bottom
            anchors.topMargin: 40
            width: parent.width
            height: 40
            placeholderTextLabel: "Пароль"
            font {
                family: "Jost"
                pixelSize: 18
            }
        }
        Text {
            id: refSignup
            anchors.top: passRect.bottom
            anchors.topMargin: 32
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Еще не зарегистрированы? Cюда."

            font {
                family: "Jost"
                pixelSize: 16
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

            text: "Войти"
            font.pixelSize: 18
            borderRadius: 17
            backHoverColor: "lightcyan"
            borderWidth: 1

            onClicked: {
                if(loginRect.text.length === 0 || passRect.text === 0) {
                    errorPopup.textPopup = "Пожалуйста, заполните все поля";
                    errorPopup.open();
                    return;
                }

                client.sendLoginData(loginRect.text, passRect.text);
            }
        }
    }
}
