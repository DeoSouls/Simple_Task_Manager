import QtQuick
import QtQuick.Controls
import com.client.network 1.0
import com.translator 1.0
import "LoginPage"
import "common"

ApplicationWindow {
    width: 367
    height: 752
    visible: true
    color: ThemeManager.backgroundColor
    title: qsTr("Simple Task Manager")

    Client {
        id: client
    }

    StackView {
        id: stackView
        anchors.fill: parent

        Connections {
            target: client

            // Реагирование на изменение message
            function onMessageChanged() {
                // Проверка текущего элемента
                if (stackView.currentItem && typeof stackView.currentItem.handleClientMessage === "function") {
                    stackView.currentItem.handleClientMessage(client.message)
                }
            }
        }

        Component.onCompleted: {
            stackView.contentItem.context.client = client;
        }
        initialItem: Login {}
    }
}

// "C:\Qt\6.8.1\mingw_64\bin\lupdate.exe" . -ts translations\appSimpleTaskManager_ru.ts translations\appSimpleTaskManager_en.ts translations\appSimpleTaskManager_de.ts

