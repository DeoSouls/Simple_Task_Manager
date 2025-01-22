#ifndef TASKMANAGERSERVER_H
#define TASKMANAGERSERVER_H

#include <QTcpServer>
#include <QObject>
#include <QSqlDatabase>
#include <QThreadPool>

class TaskManagerServer : public QTcpServer {
        Q_OBJECT
    public:
        explicit TaskManagerServer(QObject *parent = nullptr);

        bool startServer(quint16 port);
        void setReferenceDatabase(const QSqlDatabase &db);
    protected:
        void incomingConnection(qintptr socketDescriptor) override;
    private:
        QThreadPool threads;
        QSqlDatabase m_refDatabase;
};

#endif // TASKMANAGERSERVER_H
