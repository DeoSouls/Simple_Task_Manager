#ifndef TASKSMODEL_H
#define TASKSMODEL_H

#include <QAbstractListModel>
#include <QDateTime>
#include <QJsonObject>
#include <QJsonArray>

struct Tasks {
    QString title;
    QString description;
    QString status;
    QString createTime;
    QString dueTime;
    int spaceId;
    int taskId;
};

class TasksModel : public QAbstractListModel {
        Q_OBJECT
    public:
        enum Roles {
            TitleRole = Qt::UserRole + 1,
            DescriptionRole,
            StatusRole,
            CreateTimeRole,
            DueTimeRole,
            SpaceIdRole,
            TaskIdRole
        };
        explicit TasksModel(QObject *parent = nullptr);

        int rowCount(const QModelIndex &parent = QModelIndex()) const override;

        QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

        QHash<int, QByteArray> roleNames() const override;
    public slots:
        Q_INVOKABLE void updateFromJson(const QJsonArray &data);
        Q_INVOKABLE void removeTask(int row);
        Q_INVOKABLE void addTask(const QString &title, const QString &description, const QString &status, const QString &createTime, const QString& dueTime, int spaceId, int taskId);
    private:
        QList<Tasks> m_tasks;
};

#endif // TASKSMODEL_H
