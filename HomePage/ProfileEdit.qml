import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtCore
import image.converter 1.0
import "../common"

Drawer {
    id: profile
    edge: Qt.BottomEdge
    width: parent.width
    height: parent.height * 0.9

    property int userId: 0
    property string userName: ""
    property string email: ""
    property var profileImage: null

    background: Rectangle {
        color: ThemeManager.backgroundColor
    }

    Connections {
        target: translator
        function onLanguageChanged() {
            headerText.text = qsTr("Редактор профиля")
            nameRect.placeholderTextLabel = qsTr("Логин")
            passRect.placeholderTextLabel = qsTr("Пароль")
            confPassRect.placeholderTextLabel = qsTr("Подтверждение пароля")
            inBtn.text = qsTr("Применить изменения")

            errorPopup.textPopup = qsTr("Пожалуйста, заполните все поля");
            errorPopup.textPopup = qsTr("Пароли должны совпадать!")
            // textTasks.text += qsTr(" задач")
        }
    }

    ErrorPopup {
        id: errorPopup
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        borderWidth: 0
    }

    ImageConverter {
        id: imageConverter
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["Image files (*.jpg *.jpeg *.png)"]
        currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

        onAccepted: {
            profileImg.source = selectedFile;
            profile.profileImage = selectedFile;
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: 150
        height: 4
        radius: 2
        color: "lightgray"
    }

    Text {
        id: headerText
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        font {
            family: "Jost"
            pixelSize: 16 + ThemeManager.additionalSize
        }
        color: ThemeManager.fontColor
        text: qsTr("Редактор профиля")
    }

    Column {
        width: parent.width
        padding: 15
        spacing: 20
        Rectangle {
            width: parent.width
            height: 150
            color: "transparent"
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -15
                width: 100
                height: 100
                color: "transparent"
                clip: true
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: {
                        fileDialog.open();
                    }
                }

                Image {
                    id: profileImg
                    width: 100
                    height: 100
                    source: profile.profileImage === null ||
                            profile.profileImage === "" ? ThemeManager.isDarkTheme ? "qrc:/new/images/profileWhite.png" : "qrc:/new/images/profileBlack.png" : profile.profileImage
                }
            }
        }
        CustomTextField {
            id: nameRect
            width: parent.width -30
            height: 40
            placeholderTextLabel: qsTr("Логин")
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
            text: profile.userName
        }
        CustomTextField {
            id: emailRect
            width: parent.width -30
            height: 40
            placeholderTextLabel: "E-mail"
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
            text: profile.email
        }
        CustomTextField {
            id: passRect
            width: parent.width -30
            height: 40
            placeholderTextLabel: qsTr("Пароль")
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
        }
        CustomTextField {
            id: confPassRect

            width: parent.width -30
            height: 40
            borderWidth: 1

            placeholderTextLabel: qsTr("Подтверждение пароля")
            font {
                family: "Jost"
                pixelSize: 18 + ThemeManager.additionalSize
            }
        }

        CustomButton {
            id: inBtn
            width: parent.width -30
            height: 50

            text: qsTr("Применить изменения")
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

                client.updateUserData(nameRect.text, emailRect.text, confPassRect.text, profile.userId, profile.profileImage);
            }
        }
    }
}
