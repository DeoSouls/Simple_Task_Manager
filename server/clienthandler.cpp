#include "clienthandler.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QJsonArray>
#include <QCryptographicHash>
#include "sessionmanager.h"

ClientHandler::ClientHandler(qintptr socketDescriptor, const QSqlDatabase &refDb, QObject *parent)
    : QObject(parent), m_socketDescriptor(socketDescriptor), m_refDatabase(refDb) {
    initializeEndpointHandlers();
    initializeDatabase();
}

void ClientHandler::initializeEndpointHandlers() {
    // Используем лямбда-функции для привязки методов класса
    endpointHandlers["login"] = [this](const QJsonObject& req) {
        return this->handleLogin(req);
    };

    endpointHandlers["register"] = [this](const QJsonObject& req) {
        return this->handleRegister(req);
    };

    endpointHandlers["update_user"] = [this](const QJsonObject& req) {
        return this->handleUpdUser(req);
    };

    endpointHandlers["create_space"] = [this](const QJsonObject& req) {
        return this->handleCreateSpace(req);
    };

    endpointHandlers["spaces"] = [this](const QJsonObject& req) {
        return this->handleGetSpaces(req);
    };

    endpointHandlers["update_space"] = [this](const QJsonObject& req) {
        return this->handleUpdateSpace(req);
    };

    endpointHandlers["delete_space"] = [this](const QJsonObject& req) {
        return this->handleDeleteSpace(req);
    };

    endpointHandlers["create_task"] = [this](const QJsonObject& req) {
        return this->handleCreateTasks(req);
    };

    endpointHandlers["tasks"] = [this](const QJsonObject& req) {
        return this->handleGetTasks(req);
    };

    endpointHandlers["update_task"] = [this](const QJsonObject& req) {
        return this->handleUpdTask(req);
    };

    endpointHandlers["delete_task"] = [this](const QJsonObject& req) {
        return this->handleDltTask(req);
    };
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
                   "source TEXT,"
                   "email TEXT UNIQUE,"
                   "created_at DATETIME DEFAULT CURRENT_TIMESTAMP)");

        query.exec("CREATE TABLE IF NOT EXISTS spaces ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                   "spacename TEXT,"
                   "user_id INTEGER,"
                   "isFavorite BOOLEAN CHECK (isFavorite IN (0, 1)) DEFAULT 0,"
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
}

void ClientHandler::readData() {
    QByteArray requestData = m_socket->readAll();

    QJsonDocument jsonDoc = QJsonDocument::fromJson(requestData);
    QJsonObject request = jsonDoc.object();

    QJsonObject response;
    QString endpoint = request.value("endpoint").toString();

    auto it = endpointHandlers.find(endpoint);
    if(it != endpointHandlers.end()) {
        try {
            EndPointHandlerFunc handler = it.value();
            response = handler(requestJson);
        } catch (const std::exception& e) {
            qCritical() << "Exception during handling endpoint" << endpoint << ":" << e.what();
            response = {
                {"status", "error"},
                {"message", "Internal server error during handling."}
            };
        } catch (...) {
            qCritical() << "Unknown exception during handling endpoint" << endpoint;
            response = {
                {"status", "error"},
                {"message", "Unknown internal server error."}
            };
        }
    } else {
        qWarning() << "Unknown endpoint requested:" << endpoint;
        response = {
            {"status", "error"},
            {"message", "Unknown endpoint"}
        };
        // Добавляем исходный endpoint для отладки, если нужно
        response["requested_endpoint"] = endpoint;
    }

    // Отправка ответа
    QByteArray responseData = QJsonDocument(response).toJson();
    m_socket->write(responseData);
    m_socket->flush();
}

QJsonObject ClientHandler::handleLogin(const QJsonObject& request) {
    QString username = request.value("username").toString();
    QString password = request.value("password").toString();

    QByteArray passwordHash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);

    QSqlQuery query(m_refDatabase); //
    query.prepare("SELECT id, username, password_hash, source, email FROM users WHERE username = ? LIMIT 1");
    query.addBindValue(username);

    QJsonObject response;
    if (!m_refDatabase.isOpen()) {
        response["success"] = false;
        response["error"] = "Ошибка подключения к базе данных";
        return response;
    }

    if (!query.exec()) {
        qDebug() << "SQL error:" << query.lastError().text();
        response["success"] = false;
        response["error"] = "Ошибка базы данных";
        return response;
    }

    if (query.next()) {
        int userId = query.value("id").toInt();
        QString source = query.value("source").toString();
        QString email = query.value("email").toString();
        QString storedPasswordHash = query.value("password_hash").toString();

        if(QString(passwordHash.toHex()) == storedPasswordHash) {

            // Создание сессии для клиента
            QString token = SessionManager::instance().createSession(userId);

            response["success"] = true;
            response["token"] = token;
            response["username"] = username;
            response["source"] = source;
            response["email"] = email;
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

        // Создание сессии для клиента
        QString token = SessionManager::instance().createSession(userId);

        qDebug() << "Пользователь успешно зарегистрирован: " << username;
        response["success"] = true;
        response["token"] = token;
        response["username"] = username;
        response["email"] = email;
        response["userId"] = userId;
    } else {
        response["success"] = false;
        response["error"] = "Invalid username or password.";
    }

    return response;
}

QJsonObject ClientHandler::handleCreateSpace(const QJsonObject& request) {
    // Проверка на валидность токена
    QString token = request.value("token").toString();
    if(!SessionManager::instance().validateSession(token)) {
        SessionManager::instance().removeSession(token);

        QJsonObject response;
        response["success"] = false;
        response["error"] = "Invalid token.";
        response["invalid_token"] = true;
        return response;
    }

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
    // Проверка на валидность токена
    QString token = request.value("token").toString();
    if(!SessionManager::instance().validateSession(token)) {
        SessionManager::instance().removeSession(token);

        QJsonObject response;
        response["success"] = false;
        response["error"] = "Invalid token.";
        response["invalid_token"] = true;
        return response;
    }

    int userId = request.value("userId").toInt();
    QSqlQuery query(m_refDatabase);
    query.prepare("SELECT spaces.id, spaces.spacename, spaces.isFavorite, COUNT(tasks.id) AS task_count, "
                  "MAX(tasks.due_time) AS last_task_time "
                  "FROM spaces "
                  "LEFT JOIN tasks ON spaces.id = tasks.space_id "
                  "WHERE spaces.user_id = :user_id "
                  "GROUP BY spaces.id, spaces.spacename");
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
        int task_count = query.value("task_count").toInt();
        bool is_favorite = query.value("isFavorite").toBool();
        QString last_task_time = query.value("last_task_time").toString();

        responseToArray["spaceId"] = spaceId;
        responseToArray["spacename"] = spacename;
        responseToArray["taskCount"] = task_count;
        responseToArray["isFavorite"] = is_favorite;
        responseToArray["lastDueTime"] = last_task_time;
        responseArray.append(responseToArray);
    }

    if(responseArray.isEmpty()) {
        response["success"] = false;
        response["none"] = true;
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
    // Проверка на валидность токена
    QString token = request.value("token").toString();
    if(!SessionManager::instance().validateSession(token)) {
        SessionManager::instance().removeSession(token);

        QJsonObject response;
        response["success"] = false;
        response["error"] = "Invalid token.";
        response["invalid_token"] = true;
        return response;
    }

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

        QString currentTime = QDateTime::currentDateTimeUtc().toString();
        response["success"] = true;
        response["taskId"] = taskId;
        response["title"] = title;
        response["description"] = description;
        response["status"] = status;
        response["createTime"] = currentTime;
        response["dueTime"] = due_time;
        response["spaceId"] = spaceId;
        response["type"] = "created_task";
    } else {
        response["success"] = false;
        response["error"] = "Invalid create task.";
    }

    return response;
}

QJsonObject ClientHandler::handleGetTasks(const QJsonObject& request) {
    // Проверка на валидность токена
    QString token = request.value("token").toString();
    if(!SessionManager::instance().validateSession(token)) {
        SessionManager::instance().removeSession(token);

        QJsonObject response;
        response["success"] = false;
        response["error"] = "Invalid token.";
        response["invalid_token"] = true;
        return response;
    }

    int spaceId = request.value("spaceId").toInt();
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

QJsonObject ClientHandler::handleUpdateSpace(const QJsonObject& request) {
    // Проверка на валидность токена
    QString token = request.value("token").toString();
    if(!SessionManager::instance().validateSession(token)) {
        SessionManager::instance().removeSession(token);

        QJsonObject response;
        response["success"] = false;
        response["error"] = "Invalid token.";
        response["invalid_token"] = true;
        return response;
    }

    int spaceId = request.value("spaceId").toInt();

    QSqlQuery query(m_refDatabase);
    query.prepare("UPDATE spaces SET isFavorite = 1 WHERE id = :space_id");
    query.bindValue(":space_id", spaceId);

    QJsonObject response;
    if (query.exec()) {
        qDebug() << "Спейс успешно обновлен: " << spaceId;

        response["success"] = true;
        response["spaceId"] = spaceId;
        response["type"] = "updated_space";
    } else {
        response["success"] = false;
        response["error"] = "Invalid delete space.";
    }

    return response;
}

QJsonObject ClientHandler::handleDeleteSpace(const QJsonObject& request) {
    // Проверка на валидность токена
    QString token = request.value("token").toString();
    if(!SessionManager::instance().validateSession(token)) {
        SessionManager::instance().removeSession(token);

        QJsonObject response;
        response["success"] = false;
        response["error"] = "Invalid token.";
        response["invalid_token"] = true;
        return response;
    }

    int spaceId = request.value("spaceId").toInt();

    QSqlQuery query(m_refDatabase);
    query.prepare("DELETE FROM spaces WHERE id = :space_id");
    query.bindValue(":space_id", spaceId);

    QJsonObject response;
    if (query.exec()) {
        qDebug() << "Спейс успешно удален: " << spaceId;

        response["success"] = true;
        response["spaceId"] = spaceId;
        response["type"] = "deleted_space";
    } else {
        response["success"] = false;
        response["error"] = "Invalid delete space.";
    }

    return response;
}

QJsonObject ClientHandler::handleUpdTask(const QJsonObject& request) {
    // Проверка на валидность токена
    QString token = request.value("token").toString();
    if(!SessionManager::instance().validateSession(token)) {
        SessionManager::instance().removeSession(token);

        QJsonObject response;
        response["success"] = false;
        response["error"] = "Invalid token.";
        response["invalid_token"] = true;
        return response;
    }

    QString title = request.value("title").toString();
    QString description = request.value("description").toString();
    QString status = request.value("status").toString();
    QString dueTime = request.value("dueTime").toString();
    int taskId = request.value("taskId").toInt();

    QSqlQuery query(m_refDatabase);
    query.prepare("UPDATE tasks SET title = :title, description = :description, status = :status, due_time = :due_time "
                  "WHERE id = :task_id");
    query.bindValue(":title", title);
    query.bindValue(":description", description);
    query.bindValue(":status", status);
    query.bindValue(":due_time", dueTime);
    query.bindValue(":task_id", taskId);

    QJsonObject response;
    if (!query.exec()) {
        qDebug() << "Error updating task:" << query.lastError().text();
        // Обработка ошибки
        response["success"] = false;
        response["error"] = "Invalid update task.";
    }

    // Проверка количества обновленных строк
    if (query.numRowsAffected() == 0) {
        qDebug() << "No rows were updated";
        response["success"] = false;
        response["error"] = "Invalid update task.";
    }

    response["success"] = true;
    response["taskId"] = taskId;
    response["type"] = "updated_task";

    return response;
}

QJsonObject ClientHandler::handleDltTask(const QJsonObject& request) {
    // Проверка на валидность токена
    QString token = request.value("token").toString();
    if(!SessionManager::instance().validateSession(token)) {
        SessionManager::instance().removeSession(token);

        QJsonObject response;
        response["success"] = false;
        response["error"] = "Invalid token.";
        response["invalid_token"] = true;
        return response;
    }

    int taskId = request.value("taskId").toInt();

    QSqlQuery query(m_refDatabase);
    query.prepare("DELETE FROM tasks WHERE id = :task_id");
    query.bindValue(":task_id", taskId);

    QJsonObject response;
    if (query.exec()) {
        qDebug() << "Таск успешно удален: " << taskId;

        response["success"] = true;
        response["taskId"] = taskId;
        response["type"] = "deleted_task";
    } else {
        response["success"] = false;
        response["error"] = "Invalid delete task.";
    }

    return response;
}

QJsonObject ClientHandler::handleUpdUser(const QJsonObject& request) {
    // Проверка на валидность токена
    QString token = request.value("token").toString();
    if(!SessionManager::instance().validateSession(token)) {
        SessionManager::instance().removeSession(token);

        QJsonObject response;
        response["success"] = false;
        response["error"] = "Invalid token.";
        response["invalid_token"] = true;
        return response;
    }

    int userId = request.value("userId").toInt();
    QString username = request.value("username").toString();
    QString email = request.value("email").toString();
    QString password = request.value("password").toString();
    QString source = request.value("source").toString();

    QByteArray passwordHash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);

    QSqlQuery query(m_refDatabase);
    query.prepare("UPDATE users SET username = :username, password_hash = :password, email = :email, source = :source "
                  "WHERE id = :user_id ");
    query.bindValue(":username", username);
    query.bindValue(":password", QString(passwordHash.toHex()));
    query.bindValue(":email", email);
    query.bindValue(":source", source);
    query.bindValue(":user_id", userId);

    QJsonObject response;
    if (query.exec()) {
        qDebug() << "Пользователь обновлен: " << username;
        response["success"] = true;
        response["username"] = username;
        response["source"] = source;
        response["userId"] = userId;
        response["type"] = "upd_user";
    } else {
        response["success"] = false;
        response["error"] = "Invalid username or password.";
    }

    return response;
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
