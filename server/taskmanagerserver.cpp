#include "taskmanagerserver.h"
#include "requesttask.h"
#include "sessionmanager.h"
#include "clienthandler.h"
#include <QMessageBox>
#include <QJsonDocument>
#include <QJsonObject>
#include <QByteArray>
#include <QSqlQuery>
#include <QCryptographicHash>

TaskManagerServer::TaskManagerServer(QObject *parent) : QTcpServer{parent} {
    threads.setMaxThreadCount(5); // Ограничиваем количество потоков
}

bool TaskManagerServer::startServer(quint16 port) {
    if(!listen(QHostAddress::Any, port)) {
        qCritical() << "Серверу не удалось открыть соединение " << errorString();
        return false;
    }

    qDebug() << "Сервер открыл соединение на порту: " << port;
    return true;
}

void TaskManagerServer::incomingConnection(qintptr socketDescriptor) {
    QThread *thread = new QThread;
    ClientHandler *handler = new ClientHandler(socketDescriptor, m_refDatabase);
    handler->moveToThread(thread);

    connect(thread, &QThread::started, handler, &ClientHandler::handleConnection);
    connect(handler, &ClientHandler::finished, thread, &QThread::quit);
    connect(handler, &ClientHandler::finished, handler, &ClientHandler::deleteLater);
    connect(thread, &QThread::finished, thread, &QThread::deleteLater);

    thread->start();
}

void TaskManagerServer::setReferenceDatabase(const QSqlDatabase &db) {
    m_refDatabase = db;
}
