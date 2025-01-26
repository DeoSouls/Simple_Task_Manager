#include "tasksmodel.h"

TasksModel::TasksModel(QObject *parent) : QAbstractListModel(parent) {}

int TasksModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;
    return m_tasks.count();
}

QVariant TasksModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
        return QVariant();

    const Tasks &task = m_tasks[index.row()];
    switch (role) {
    case TitleRole:
        return task.title;
    case DescriptionRole:
        return task.description;
    case StatusRole:
        return task.status;
    case CreateTimeRole:
        return task.createTime;
    case DueTimeRole:
        return task.dueTime;
    case SpaceIdRole:
        return task.spaceId;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> TasksModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    roles[DescriptionRole] = "description";
    roles[StatusRole] = "status";
    roles[CreateTimeRole] = "createTime";
    roles[DueTimeRole] = "dueTime";
    roles[SpaceIdRole] = "spaceId";
    return roles;
}

void TasksModel::updateFromJson(const QJsonArray &data) {
    beginResetModel();
    m_tasks.clear();
    for (const QJsonValue &value : data) {
        QJsonObject obj = value.toObject();
        m_tasks.append({obj["title"].toString(),
                        obj["description"].toString(),
                        obj["status"].toString(),
                        obj["createTime"].toString(),
                        obj["dueTime"].toString(),
                        obj["spaceId"].toInt()});
    }
    endResetModel();
}

void TasksModel::addTask(const QString &title, const QString &description, const QString &status, const QString& createTime, const QString& dueTime, int spaceId) {
    beginInsertRows(QModelIndex(), m_tasks.size(), m_tasks.size());
    m_tasks.append({title, description, status, createTime, dueTime, spaceId});
    endInsertRows();
}
