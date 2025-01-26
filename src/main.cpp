#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "../server/taskmanagerserver.h"
#include <QMessageBox>
#include <QtSql/QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QFontDatabase>
#include "client.h"
#include "tasksmodel.h"

bool connectToDatabase(const QString &dbPath) {
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE"); // Указываем драйвер SQLite
    db.setDatabaseName(dbPath); // Путь к файлу базы данных

    if (!db.open()) {
        qCritical() << "Error: Unable to connect to database:" << db.lastError().text();
        return false;
    }

    QSqlQuery query;
    if (query.exec("DROP TABLE IF EXISTS tasks")) {
        qDebug() << "Таблица успешно удалена";
    } else {
        qDebug() << "Ошибка удаления таблицы" << query.lastError();
    }
    // Create users table
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

    qDebug() << "Connected and created tables database successfully! " + db.databaseName();
    return true;
}

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    // Регистрация шрифта из ресурсов
    int fontId = QFontDatabase::addApplicationFont(":/fonts/fonts/Jost/static/Jost-Regular.ttf");
    if (fontId == -1) {
        qWarning() << "Не удалось загрузить шрифт!";
        return -1;
    }

    // Получение имени шрифта
    QString fontFamily = QFontDatabase::applicationFontFamilies(fontId).at(0);
    qDebug() << "Загружен шрифт:" << fontFamily;

    // qDebug() << "Available drivers:" << QSqlDatabase::drivers();

    QSqlDatabase defaultDB = QSqlDatabase::addDatabase("QSQLITE", "MASTER_CONNECTION"); // Указываем драйвер SQLite
    defaultDB.setDatabaseName("sTaskManager.db"); // Путь к файлу базы данных

    if (!defaultDB.open()) {
        qDebug() << "Error: Unable to connect to database:" << defaultDB.lastError().text();
        return false;
    }

    QSqlQuery query(defaultDB);
    // if (query.exec("DROP TABLE IF EXISTS spaces")) {
    //     qDebug() << "Таблица успешно удалена";
    // } else {
    //     qDebug() << "Ошибка удаления таблицы" << query.lastError();
    // }
    // Create users table
    query.exec("CREATE TABLE IF NOT EXISTS spaces ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT,"
               "spacename TEXT,"
               "user_id INTEGER,"
               "created_at DATETIME DEFAULT CURRENT_TIMESTAMP,"
               "FOREIGN KEY (user_id) REFERENCES users(id))");

    query.exec("CREATE TABLE IF NOT EXISTS users ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT,"
               "username TEXT UNIQUE,"
               "password_hash TEXT,"
               "email TEXT UNIQUE,"
               "created_at DATETIME DEFAULT CURRENT_TIMESTAMP)");

    qDebug() << "Connected and created tables database successfully! " + defaultDB.databaseName();


    // Запуск сервера
    quint16 port = 12345;
    TaskManagerServer server;
    server.setReferenceDatabase(defaultDB);
    if(!server.startServer(port)) {
        QMessageBox::critical(nullptr, "Server connection failed", "Не удалось открыть соединение");
    }

    qmlRegisterType<TasksModel>("com.tasksmodel.network", 1, 0, "TasksModel");
    qmlRegisterType<Client>("com.client.network", 1, 0, "Client");
    // import com.client.network 1.0

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("SimpleTaskManager", "Main");

    return app.exec();
}
