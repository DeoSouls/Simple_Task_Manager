#include "clienthandler.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QJsonArray>
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
    if(!db.tables().contains("users") || !db.tables().contains("spaces") || !db.tables().contains("tasks")) {
        QSqlQuery query(db);
        query.exec("CREATE TABLE IF NOT EXISTS users ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                   "username TEXT UNIQUE,"
                   "password_hash TEXT,"
                   "email TEXT UNIQUE,"
                   "created_at DATETIME DEFAULT CURRENT_TIMESTAMP)");

        query.exec("CREATE TABLE IF NOT EXISTS spaces ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                   "spacename TEXT,"
                   "user_id INTEGER,"
                   "created_at DATETIME DEFAULT CURRENT_TIMESTAMP,"
                   "FOREIGN KEY (user_id) REFERENCES users(id))");

        query.exec("CREATE TABLE IF NOT EXISTS tasks ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                   "title TEXT NOT NULL,"
                   "description TEXT,"
                   "status TEXT NOT NULL DEFAULT 'pending',"
                   "space_id INTEGER,"
                   "due_time DATETIME,"
                   "created_at DATETIME DEFAULT CURRENT_TIMESTAMP,"
                   "FOREIGN KEY (space_id) REFERENCES spaces(id))");
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
    } else if (endpoint == "create_space") {
        response = handleCreateSpace(request);
    } else if (endpoint == "spaces") {
        response = handleGetSpaces(request);
    } else if (endpoint == "create_task") {
        response = handleCreateTasks(request);
    }else if (endpoint == "tasks") {
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

        qDebug() << "id пользователя: " << userId;
        if(passwordHash.toHex() == storedPasswordHash) {
            QString token = SessionManager::instance().createSession(userId);

            response["success"] = true;
            response["token"] = token;
            response["userId"] = userId;
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
        response["userId"] = userId;
    } else {
        response["success"] = false;
        response["error"] = "Invalid username or password.";
    }

    return response;
}

QJsonObject ClientHandler::handleCreateSpace(const QJsonObject& request) {
    QString spacename = request.value("spacename").toString();
    int userId = request.value("userId").toInt();

    QSqlQuery query(m_refDatabase);
    query.prepare("INSERT INTO spaces (spacename, user_id) "
                  "VALUES (:spacename, :user_id) RETURNING id, user_id");
    query.bindValue(":spacename", spacename);
    query.bindValue(":user_id", userId);

    QJsonObject response;
    if (query.exec() && query.next()) {
        int spaceId = query.value("id").toInt();
        int user_id = query.value("user_id").toInt();
        // QString token = SessionManager::instance().createSession(userId);

        qDebug() << "Пространство успешно создано: " << user_id;
        response["success"] = true;
        response["spaceId"] = spaceId;
        response["spacename"] = spacename;
    } else {
        response["success"] = false;
        response["error"] = "Invalid create space.";
    }

    return response;
}

QJsonObject ClientHandler::handleGetSpaces(const QJsonObject& request) {
    int userId = request.value("userId").toInt();
    // validate session
    QSqlQuery query(m_refDatabase);
    query.prepare("SELECT id, spacename FROM spaces WHERE user_id = :user_id");
    query.bindValue(":user_id", userId);

    QJsonObject response;
    QJsonArray responseArray;
    if (!query.exec()){
        response["success"] = false;
        response["error"] = "No spaces found for this user.";
        return response;
    }

    while(query.next()) {
        QJsonObject responseToArray;
        qDebug() << "Пространство: " << userId;
        int spaceId = query.value("id").toInt();
        QString spacename = query.value("spacename").toString();
        // QString token = SessionManager::instance().createSession(userId);

        responseToArray["spaceId"] = spaceId;
        responseToArray["spacename"] = spacename;
        responseArray.append(responseToArray);
    }

    if(responseArray.isEmpty()) {
        response["success"] = false;
        response["error"] = "None spaces";
        return response;
    } else {
        response["success"] = true;
        response["type"] = "spaces";
        response["data"] = responseArray;
        return response;
    }
}

QJsonObject ClientHandler::handleCreateTasks(const QJsonObject& request) {
    QString title = request.value("title").toString();
    QString description = request.value("description").toString();
    QString status = request.value("status").toString();
    QString due_time = request.value("due_time").toString();
    int spaceId = request.value("space_id").toInt();

    QSqlQuery query(m_refDatabase);
    query.prepare("INSERT INTO tasks (title, description, status, due_time, space_id) "
                  "VALUES (:title, :description, :status, :due_time, :spaceId) RETURNING id");
    query.bindValue(":title", title);
    query.bindValue(":description", description);
    query.bindValue(":status", status);
    query.bindValue(":due_time", due_time);
    query.bindValue(":spaceId", spaceId);

    QJsonObject response;
    if (query.exec() && query.next()) {
        int taskId = query.value("id").toInt();
        // QString token = SessionManager::instance().createSession(userId);

        qDebug() << "Таск успешно создан: " << taskId;
        response["success"] = true;
        response["taskId"] = taskId;
        response["type"] = "created_task";
    } else {
        response["success"] = false;
        response["error"] = "Invalid create task.";
    }

    return response;
}

QJsonObject ClientHandler::handleGetTasks(const QJsonObject& request) {
    int spaceId = request.value("spaceId").toInt();
    // validate session
    QSqlQuery query(m_refDatabase);
    query.prepare("SELECT id, title, description, status, due_time, created_at FROM tasks WHERE space_id = :space_id");
    query.bindValue(":space_id", spaceId);

    QJsonObject response;
    QJsonArray responseArray;
    if (!query.exec()){
        response["success"] = false;
        response["error"] = "No spaces found for this user.";
        return response;
    }

    while(query.next()) {
        QJsonObject responseToArray;
        int taskId = query.value("id").toInt();
        QString title = query.value("title").toString();
        QString description = query.value("description").toString();
        QString status = query.value("status").toString();
        QString due_time = query.value("due_time").toString();
        QString created_at = query.value("created_at").toString();

        // QString token = SessionManager::instance().createSession(userId);
        qDebug() << "Таск: " << taskId;

        responseToArray["taskId"] = taskId;
        responseToArray["title"] = title;
        responseToArray["description"] = description;
        responseToArray["status"] = status;
        responseToArray["createTime"] = created_at;
        responseToArray["dueTime"] = due_time;
        responseToArray["spaceId"] = spaceId;
        responseArray.append(responseToArray);
    }

    if(responseArray.isEmpty()) {
        response["success"] = false;
        response["error"] = "None tasks";
        return response;
    } else {
        response["success"] = true;
        response["type"] = "get_tasks";
        response["data"] = responseArray;
        return response;
    }
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
