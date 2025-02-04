#ifndef SPACEMODEL_H
#define SPACEMODEL_H

#include <QAbstractListModel>
#include <QDateTime>
#include <QJsonObject>
#include <QJsonArray>

struct Spaces {
    int spaceId;
    QString spacename;
    int taskCount;
    QString lastDueTime;
};

class SpaceModel : public QAbstractListModel {
        Q_OBJECT
    public:
        enum Roles {
            SpaceIdRole = Qt::UserRole + 1,
            SpaceNameRole,
            TaskCountRole,
            LastDueTimeRole
        };
        explicit SpaceModel(QObject *parent = nullptr);

        int rowCount(const QModelIndex &parent = QModelIndex()) const override;

        QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

        QHash<int, QByteArray> roleNames() const override;
    public slots:
        Q_INVOKABLE void updateFromJson(const QJsonArray &data);
        Q_INVOKABLE void removeSpace(int row);
        Q_INVOKABLE void clearSpace();
        Q_INVOKABLE QVariantMap getSpace(int row) const;
        Q_INVOKABLE void appendSpace(const QVariantMap &item);
    private:
        QList<Spaces> m_spaces;
};

#endif // SPACEMODEL_H
