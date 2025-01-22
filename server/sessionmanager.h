#ifndef SESSIONMANAGER_H
#define SESSIONMANAGER_H

#include <QObject>
#include <QMutex>
#include <QDateTime>

struct ClientSession {
    QString token;
    int userId;
    QDateTime lastActivity;
};

class SessionManager {
    public:
        static SessionManager& instance();

        QString createSession(int userId);

        bool validateSession(const QString &token);

        void removeSession(const QString &token);
        SessionManager() = default;
    private:
        QString generateToken();

        QHash<QString, ClientSession> sessions;
        QMutex mutex;
};

#endif // SESSIONMANAGER_H
