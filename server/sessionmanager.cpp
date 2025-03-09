#include "sessionmanager.h"
#include <QDateTime>
#include <QCryptographicHash>
#include <QRandomGenerator>

SessionManager& SessionManager::instance() {
    static SessionManager instance;
    return instance;
}

QString SessionManager::createSession(int userId) {
    QMutexLocker locker(&mutex);
    QString token = generateToken();
    ClientSession session = {token, userId, QDateTime::currentDateTime()};
    sessions.insert(token, session);
    return token;
}

bool SessionManager::validateSession(const QString &token) {
    QMutexLocker locker(&mutex);
    if (sessions.contains(token)) {
        sessions[token].lastActivity = QDateTime::currentDateTime(); // Обновляем время активности

        QStringList parts = token.split("|");
        if (parts.size() != 2) return false;

        QByteArray data = QByteArray::fromBase64(parts[0].toUtf8());
        QByteArray hash = QByteArray::fromBase64(parts[1].toUtf8());

        // Проверяем целостность данных
        QByteArray expectedHash = QCryptographicHash::hash(data, QCryptographicHash::Sha256);
        if (hash != expectedHash) return false;

        // Извлекаем expiration из данных
        qint64 expiration;
        memcpy(&expiration, data.constData(), sizeof(expiration));

        return QDateTime::currentSecsSinceEpoch() <= expiration;
    }
    return false;
}

void SessionManager::removeSession(const QString &token) {
    QMutexLocker locker(&mutex);
    sessions.remove(token);
}

QString SessionManager::generateToken() {
    // QByteArray randomData = QString::number(QDateTime::currentMSecsSinceEpoch()).toUtf8()
    // + QByteArray::number(QRandomGenerator::global()->generate());
    // Генерация уникальных компонентов
    const qint64 timestamp = QDateTime::currentSecsSinceEpoch();
    const qint64 expiration = timestamp + 10 * 60;
    const quint32 random = QRandomGenerator::global()->generate();

    // Формирование данных для хеширования
    QByteArray data;
    data.append(reinterpret_cast<const char*>(&expiration), sizeof(expiration));
    data.append(reinterpret_cast<const char*>(&random), sizeof(random));
    const QByteArray salt = "secure_salt_555";
    data.append(salt);

    QByteArray hash = QCryptographicHash::hash(data, QCryptographicHash::Sha256);
    QByteArray token = data.toBase64() + "|" + hash.toBase64(); // Сохраняем данные и хеш
    return QString(token);
}
