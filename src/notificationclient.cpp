#include "notificationclient.h"
// #include <QJniObject>  // Важно: именно QJniObject, а не qjniobject.h
// #include <QtCore>

NotificationClient::NotificationClient(QObject *parent): QObject{parent} {}

void NotificationClient::showNotification(const QString &message) {
    // QJniObject javaNotification = QJniObject::fromString(message);
    // QJniObject::callStaticMethod<void>(
    //     "org/qtproject/example/appSimpleTaskManager/com/appsimpletaskmanager/NotificationClient",
    //     "notify",
    //     "(Landroid/content/Context;Ljava/lang/String;)V",
    //     QNativeInterface::QAndroidApplication::context(),
    //     javaNotification.object<jstring>());
}
