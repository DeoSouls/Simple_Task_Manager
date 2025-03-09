#include "client.h"
#include <QJsonDocument>
#include <QJsonObject>

Client::Client(QObject* parent) : QObject(parent), socket(new QTcpSocket(this)) {
    connectToServer("127.0.0.1", 12345);
}

void Client::connectToServer(const QString& host, quint16 port) {
    socket->connectToHost(host, port);
    connect(socket, &QTcpSocket::connected, this, &Client::onConnected);
    connect(socket, &QTcpSocket::readyRead, this, &Client::receiveData);
    connect(socket, &QTcpSocket::disconnected, this, &Client::onDisconnected);
    if (!socket->waitForConnected(3000)) {
        qDebug() << "Ошибка подключения к серверу:" << socket->errorString();
    } else {
        qDebug() << "Успешно подключено к серверу!";
    }
}

void Client::onConnected() {
    qDebug() << "Соединение с сервером установлено!";
}

void Client::sendLoginData(const QString& username, const QString& password) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "login";
        reqObj["username"] = username;
        reqObj["password"] = password;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::updateUserData(const QString& username, const QString& email, const QString& password, int userId, const QString& source) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "update_user";
        reqObj["userId"] = userId;
        reqObj["username"] = username;
        reqObj["email"] = email;
        reqObj["password"] = password;
        reqObj["source"] = source;
        // Для существующей сессии
        reqObj["token"] = token;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::sendRegisterData(const QString& username, const QString& email, const QString& password) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "register";
        reqObj["username"] = username;
        reqObj["email"] = email;
        reqObj["password"] = password;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::createSpace(const QString& spacename, int userId) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "create_space";
        reqObj["spacename"] = spacename;
        reqObj["userId"] = userId;
        // Для существующей сессии
        reqObj["token"] = token;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::getSpaces(int userId) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "spaces";
        reqObj["userId"] = userId;
        // Для существующей сессии
        reqObj["token"] = token;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::updateSpace(int spaceId) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "update_space";
        reqObj["spaceId"] = spaceId;
        // Для существующей сессии
        reqObj["token"] = token;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::deleteSpace(int spaceId) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "delete_space";
        reqObj["spaceId"] = spaceId;
        // Для существующей сессии
        reqObj["token"] = token;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::createTask(const QString& title, const QString& description, const QString& status, const QString& due_time, int spaceId) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "create_task";
        reqObj["title"] = title;
        reqObj["description"] = description;
        reqObj["status"] = status;
        reqObj["due_time"] = due_time;
        reqObj["space_id"] = spaceId;
        // Для существующей сессии
        reqObj["token"] = token;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::getTasks(int spaceId) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "tasks";
        reqObj["spaceId"] = spaceId;
        // Для существующей сессии
        reqObj["token"] = token;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::updateTask(int taskId, const QString& title, const QString& description, const QString& dueTime, const QString& status) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "update_task";
        reqObj["taskId"] = taskId;
        reqObj["title"] = title;
        reqObj["description"] = description;
        reqObj["dueTime"] = dueTime;
        reqObj["status"] = status;
        // Для существующей сессии
        reqObj["token"] = token;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::deleteTask(int taskId) {
    if (socket->state() == QAbstractSocket::ConnectedState) {
        QJsonObject reqObj;
        reqObj["endpoint"] = "delete_task";
        reqObj["taskId"] = taskId;
        // Для существующей сессии
        reqObj["token"] = token;

        QByteArray jsonData = QJsonDocument(reqObj).toJson(QJsonDocument::Compact);

        socket->write(jsonData);
        socket->flush();
        if (!socket->waitForBytesWritten(3000)) {
            qDebug() << "Ошибка отправки данных:" << socket->errorString();
        } else {
            qDebug() << "Данные отправлены:" << jsonData;
        }
    } else {
        qDebug() << "Сокет не подключен!";
    }
}

void Client::receiveData() {
    // Чтение данных сервера
    QByteArray responseData = socket->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData);
    QJsonObject response = jsonDoc.object();

    bool success = response.value("success").toBool();
    if(!success) {
        qDebug() << "Ошибка: " << response.value("error").toString();
        setMessage(QVariant::fromValue(response));
        return;
    }

    if(!response.value("token").isUndefined()) {
        token = response.value("token").toString();
        qDebug() << "Token: " << token;
    }

    setMessage(QVariant::fromValue(response));
}

QVariant Client::getMessage() const {
    return m_message;
}

void Client::setMessage(const QVariant& message) {
    // if (m_message != message) {
    //     m_message = message;
    //     emit messageChanged();
    // }

    m_message = message;
    emit messageChanged();
}

void Client::onDisconnected() {
    qDebug() << "Соединение с сервером разорвано.";
    // Попробовать переподключиться
    socket->connectToHost("127.0.0.1", 12345);
}
