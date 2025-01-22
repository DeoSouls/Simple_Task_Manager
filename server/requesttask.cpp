#include "requesttask.h"
#include "sessionmanager.h"
#include <QSqlQuery>
#include <QCryptographicHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QThread>

RequestTask::RequestTask(qintptr socketDescriptor, QObject* parent) : m_socketDescriptor(socketDescriptor), QThread(parent) {}

void RequestTask::run() {
    QTcpSocket socket;
    if (!socket.setSocketDescriptor(m_socketDescriptor)) {
        qDebug() << "Ошибка установки дескриптора сокета:" << socket.errorString();
        return;
    }

    // Перемещаем сокет в текущий поток

    connect(&socket, &QTcpSocket::readyRead, this, &RequestTask::handleRequest);
    // Создаём сокет на куче
    // QTcpSocket* socket = new QTcpSocket();

    // // Устанавливаем дескриптор сокета
    // if (!socket->setSocketDescriptor(m_socketDescriptor)) {
    //     qDebug() << "Ошибка установки дескриптора сокета:" << socket->errorString();
    //     delete socket; // Удаляем сокет при ошибке
    //     return;
    // }

    // // Подключаем сигналы сокета
    // connect(socket, &QTcpSocket::readyRead, this, &RequestTask::handleRequest);
    // connect(socket, &QTcpSocket::disconnected, this, [this, socket]() {
    //     socket->deleteLater();
    //     quit(); // Завершаем цикл обработки событий
    // });

    // Запускаем цикл обработки событий
    // exec();
    // if(!m_socket) return;
    // while(m_socket->state() == QAbstractSocket::ConnectedState) {
    //     if(!m_socket->waitForReadyRead(5000)) {
    //         qDebug() << "Тайм-аут ожидания данных.";
    //         continue; // Продолжаем ожидание
    //     }

    //     // Чтение данных клиента
    //     // QByteArray requestData = m_socket->readAll();
    //     // QJsonDocument jsonDoc = QJsonDocument::fromJson(requestData);
    //     // QJsonObject request = jsonDoc.object();

    //     // Обработка запроса
    //     handleRequest();

    //     // Отправка ответа
    //     // QByteArray responseData = QJsonDocument(response).toJson();
    //     // socket->write(responseData);
    //     // socket->flush();
    // }
    // socket->disconnectFromHost(); ///
    // socket->deleteLater(); ///
}

void RequestTask::handleRequest() {
    QTcpSocket* socket = qobject_cast<QTcpSocket*>(sender());
    if (!socket->isOpen()) {
        qDebug() << "Сокет закрыт!";
        return;
    }
    if (!socket) return;
    QByteArray requestData = socket->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(requestData);
    QJsonObject request = jsonDoc.object();

    QJsonObject response;
    QString endpoint = request.value("endpoint").toString();
    if (endpoint == "login") {
        response = handleLogin(request);
    } else if (endpoint == "register") {
        qDebug() << "Все прекрасно работает!";
        response = handleRegister(request);
    } else if (endpoint == "tasks") {
        response = handleGetTasks(request);
    } else {
        response["success"] = false;
        response["error"] = "Unknown endpoint.";
    }

    // Отправка ответа
    QByteArray responseData = QJsonDocument(response).toJson();
    socket->write(responseData);
    socket->flush();
}

QJsonObject RequestTask::handleLogin(const QJsonObject& request) {
    QString username = request.value("username").toString();
    QString password = request.value("password").toString();

    QByteArray passwordHash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);

    QSqlQuery query;
    query.prepare("SELECT id FROM users WHERE username = ? AND password_hash = ?");
    query.addBindValue(username);
    query.addBindValue(QString(passwordHash.toHex()));

    QJsonObject response;
    if (query.exec() && query.next()) {
        int userId = query.value("id").toInt();
        QString token = SessionManager::instance().createSession(userId);

        response["success"] = true;
        response["token"] = token;
    } else {
        response["success"] = false;
        response["error"] = "Invalid username or password.";
    }

    return response;
}

QJsonObject RequestTask::handleRegister(const QJsonObject& request) {
    QString username = request.value("username").toString();
    QString email = request.value("email").toString();
    QString password = request.value("password").toString();

    QByteArray passwordHash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);

    QSqlQuery query;
    query.prepare("INSERT INTO users (username, password_hash, email) "
                  "VALUES (:username, :password, :email) RETURNING id");
    query.bindValue(":username", username);
    query.bindValue(":password", passwordHash);
    query.bindValue(":email", email);

    QJsonObject response;
    if (query.exec() && query.next()) {
        int userId = query.value("id").toInt();
        QString token = SessionManager::instance().createSession(userId);

        qDebug() << "Пользователь успешно зарегистрирован: " << username;
        response["success"] = true;
        response["token"] = token;
    } else {
        response["success"] = false;
        response["error"] = "Invalid username or password.";
    }

    return response;
}

QJsonObject RequestTask::handleGetTasks(const QJsonObject& request) {
    ///
}

QJsonObject RequestTask::handleLogout(const QJsonObject &request) {
    QString token = request.value("token").toString();
    SessionManager::instance().removeSession(token);

    QJsonObject response;
    response["success"] = true;
    response["message"] = "User logged out successfully.";
    return response;
}
