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
        return true;
    }
    return false;
}

void SessionManager::removeSession(const QString &token) {
    QMutexLocker locker(&mutex);
    sessions.remove(token);
}

QString SessionManager::generateToken() {
    QByteArray randomData = QString::number(QDateTime::currentMSecsSinceEpoch()).toUtf8()
    + QByteArray::number(QRandomGenerator::global()->generate());
    QByteArray hash = QCryptographicHash::hash(randomData, QCryptographicHash::Sha256);
    return QString(hash.toHex());
}
