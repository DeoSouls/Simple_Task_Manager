#ifndef CLIENT_H
#define CLIENT_H

#include <QObject>
#include <QTcpSocket>

class Client : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariant message READ getMessage WRITE setMessage NOTIFY messageChanged)
    public:
        explicit Client(QObject* parent = nullptr);

        Q_INVOKABLE void connectToServer(const QString& host, quint16 port);
        Q_INVOKABLE void sendLoginData(const QString& username, const QString& password);
        Q_INVOKABLE void sendRegisterData(const QString& username, const QString& email, const QString& password);

        QVariant getMessage() const;
        void setMessage(const QVariant& message);
    signals:
        void messageChanged();
    private:
        QTcpSocket* socket;
        QVariant m_message;
    private slots:
        void receiveData();
        void onConnected();
        void onDisconnected();
};

#endif // CLIENT_H
