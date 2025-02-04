#ifndef NOTIFICATIONCLIENT_H
#define NOTIFICATIONCLIENT_H

#include <QObject>

class NotificationClient : public QObject {
        Q_OBJECT
    public:
        explicit NotificationClient(QObject *parent = nullptr);

        Q_INVOKABLE void showNotification(const QString &message);

};

#endif // NOTIFICATIONCLIENT_H
