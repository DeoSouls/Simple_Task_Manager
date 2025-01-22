#ifndef REQUESTTASK_H
#define REQUESTTASK_H

#include <QTcpSocket>
#include <QThread>

class RequestTask : public QThread {
    public:
        explicit RequestTask(qintptr socketDescriptor, QObject* parent = nullptr);
    protected:
        void run() override;
    private slots:
        void handleRequest();
    private:
        QTcpSocket* m_socket;
        qintptr m_socketDescriptor;
        QJsonObject handleLogin(const QJsonObject &request);
        QJsonObject handleRegister(const QJsonObject &request);
        QJsonObject handleGetTasks(const QJsonObject &request);

        QJsonObject handleLogout(const QJsonObject &request);

};

#endif // REQUESTTASK_H
