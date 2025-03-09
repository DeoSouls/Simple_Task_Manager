#ifndef CLIENTHANDLER_H
#define CLIENTHANDLER_H

#include <QTcpSocket>
#include <QSqlDatabase>
#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>

class ClientHandler : public QObject {
        Q_OBJECT
    public:
        explicit ClientHandler(qintptr socketDescriptor, const QSqlDatabase &refDb, QObject *parent = nullptr);
    public slots:
        void handleConnection();
        void readData();
        void disconnected();
    signals:
        void finished();
    private:
        QSqlDatabase m_refDatabase;
        QTcpSocket* m_socket;
        qintptr m_socketDescriptor;
        QString sessionId;
        QSqlDatabase db;

        void initializeDatabase();
        QJsonObject handleLogin(const QJsonObject& request);
        QJsonObject handleRegister(const QJsonObject &request);
        QJsonObject handleUpdUser(const QJsonObject& request);
        QJsonObject handleCreateSpace(const QJsonObject& request);
        QJsonObject handleUpdateSpace(const QJsonObject& request);
        QJsonObject handleGetSpaces(const QJsonObject& request);
        QJsonObject handleCreateTasks(const QJsonObject &request);
        QJsonObject handleGetTasks(const QJsonObject& request);
        QJsonObject handleDeleteSpace(const QJsonObject& request);
        QJsonObject handleUpdTask(const QJsonObject& request);
        QJsonObject handleDltTask(const QJsonObject& request);
        QJsonObject handleLogout(const QJsonObject &request);
};

#endif // CLIENTHANDLER_H
