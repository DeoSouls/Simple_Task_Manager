#include "clienthandler.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QCryptographicHash>
#include "sessionmanager.h"

ClientHandler::ClientHandler(qintptr socketDescriptor, const QSqlDatabase &refDb, QObject *parent)
    : QObject(parent), m_socketDescriptor(socketDescriptor), m_refDatabase(refDb) {
    initializeDatabase();
}

void ClientHandler::initializeDatabase() {
    // Создаем уникальное имя подключения
    QString connectionName = QString("Connection_%1").arg(m_socketDescriptor);

    // Клонируем эталонное подключение
    db = QSqlDatabase::cloneDatabase(m_refDatabase, connectionName);

    if (!db.open()) {
        qDebug() << "Database connection error:" << db.lastError().text();
        return;
    }

    // Проверяем существование таблицы
    if(!db.tables().contains("users")) {
        QSqlQuery query(db);
        query.exec("CREATE TABLE IF NOT EXISTS users ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                   "username TEXT UNIQUE,"
                   "password_hash TEXT,"
                   "email TEXT UNIQUE,"
                   "created_at DATETIME DEFAULT CURRENT_TIMESTAMP)");
    }
}

void ClientHandler::handleConnection() {
    m_socket = new QTcpSocket;
    if (!m_socket->setSocketDescriptor(m_socketDescriptor)) {
        qDebug() << "Socket error:" << m_socket->errorString();
        emit finished();
        return;
    }

    connect(m_socket, &QTcpSocket::readyRead, this, &ClientHandler::readData);
    connect(m_socket, &QTcpSocket::disconnected, this, &ClientHandler::disconnected);

    qDebug() << "Connected to session!";

    // Создаем новую сессию или восстанавливаем существующую
    // createNewSession();
    // QByteArray sessionData = loadSessionData();
    // socket->write("Connected! Session data: " + sessionData);
}

void ClientHandler::saveSessionData(const QByteArray &data) {
    // SessionManager::updateSession(db, sessionId, data);
}

QByteArray ClientHandler::loadSessionData() {
    // return SessionManager::getSessionData(db, sessionId);
}

void ClientHandler::readData() {
    QByteArray requestData = m_socket->readAll();
    qDebug() << "Received data:" << requestData;

    QJsonDocument jsonDoc = QJsonDocument::fromJson(requestData);
    QJsonObject request = jsonDoc.object();

    QJsonObject response;
    QString endpoint = request.value("endpoint").toString();
    if (endpoint == "login") {
        response = handleLogin(request);
    } else if (endpoint == "register") {
        response = handleRegister(request);
    } else if (endpoint == "tasks") {
        response = handleGetTasks(request);
    } else {
        response["success"] = false;
        response["error"] = "Unknown endpoint.";
    }

    // Отправка ответа
    QByteArray responseData = QJsonDocument(response).toJson();
    m_socket->write(responseData);
    m_socket->flush();

    // Сохраняем данные в сессии
    // saveSessionData(data);

    // Отправляем ответ клиенту
    // socket->write("Data saved to session: " + data);
}

QJsonObject ClientHandler::handleLogin(const QJsonObject& request) {
    QString username = request.value("username").toString();
    QString password = request.value("password").toString();

    QByteArray passwordHash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);

    QSqlQuery query(m_refDatabase); //
    query.prepare("SELECT id, username, password_hash FROM users WHERE username = :username LIMIT 1");
    query.bindValue(":username", username);

    QJsonObject response;
    if (query.exec() && query.next()) {
        int userId = query.value("id").toInt();
        QString storedPasswordHash = query.value("password_hash").toString();

        if(passwordHash.toHex() == storedPasswordHash) {
            QString token = SessionManager::instance().createSession(userId);

            response["success"] = true;
            response["token"] = token;
        } else {
            response["success"] = false;
            response["error"] = "Неверный пароль";
        }
    } else {
        response["success"] = false;
        response["error"] = "Неверный логин.";
    }

    return response;
}

QJsonObject ClientHandler::handleRegister(const QJsonObject& request) {
    QString username = request.value("username").toString();
    QString email = request.value("email").toString();
    QString password = request.value("password").toString();

    QByteArray passwordHash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);

    QSqlQuery query(m_refDatabase);
    query.prepare("INSERT INTO users (username, password_hash, email) "
                  "VALUES (:username, :password, :email) RETURNING id");
    query.bindValue(":username", username);
    query.bindValue(":password", QString(passwordHash.toHex()));
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

QJsonObject ClientHandler::handleGetTasks(const QJsonObject& request) {
    ///
}

QJsonObject ClientHandler::handleLogout(const QJsonObject &request) {
    QString token = request.value("token").toString();
    SessionManager::instance().removeSession(token);

    QJsonObject response;
    response["success"] = true;
    response["message"] = "User logged out successfully.";
    return response;
}


void ClientHandler::disconnected() {
    qDebug() << "Client disconnected";
    m_socket->deleteLater();
    db.close();
    emit finished();
}
