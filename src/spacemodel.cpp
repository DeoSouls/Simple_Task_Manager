#include "spacemodel.h"

SpaceModel::SpaceModel(QObject *parent) : QAbstractListModel(parent) {}

int SpaceModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;
    return m_spaces.count();
}

QVariant SpaceModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
        return QVariant();

    const Spaces &space = m_spaces[index.row()];
    switch (role) {
    case SpaceIdRole:
        return space.spaceId;
    case SpaceNameRole:
        return space.spacename;
    case TaskCountRole:
        return space.taskCount;
    case LastDueTimeRole:
        return space.lastDueTime;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> SpaceModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[SpaceIdRole] = "spaceId";
    roles[SpaceNameRole] = "spacename";
    roles[TaskCountRole] = "taskCount";
    roles[LastDueTimeRole] = "lastDueTime";
    return roles;
}

void SpaceModel::updateFromJson(const QJsonArray &data) {

    if (!m_spaces.isEmpty()) {
        beginRemoveRows(QModelIndex(), 0, m_spaces.size() - 1);
        m_spaces.clear();
        endRemoveRows();
    }
    // Добавляем новые элементы
    if (!data.isEmpty()) {
        beginInsertRows(QModelIndex(), 0, data.size() - 1);
        for (const QJsonValue &value : data) {
            QJsonObject obj = value.toObject();
            m_spaces.append({obj["spaceId"].toInt(),
                             obj["spacename"].toString(),
                             obj["taskCount"].toInt(),
                             obj["lastDueTime"].toString()});
        }
        endInsertRows(); // Отправляет rowsInserted
    }
}

void SpaceModel::removeSpace(int row) {
    beginRemoveRows(QModelIndex(), row, row);
    m_spaces.removeAt(row);
    endRemoveRows();
}

void SpaceModel::clearSpace() {
    beginResetModel();
    m_spaces.clear();
    endResetModel();
}

QVariantMap SpaceModel::getSpace(int row) const {
    QVariantMap result;
    if (row < 0 || row >= m_spaces.size())
        return result;

    QHash<int, QByteArray> roles = roleNames();
    QHashIterator<int, QByteArray> it(roles);
    while (it.hasNext()) {
        it.next();
        result[it.value()] = data(index(row, 0), it.key());
    }
    return result;
}

void SpaceModel::appendSpace(const QVariantMap &item) {
    beginInsertRows(QModelIndex(), m_spaces.size(), m_spaces.size());
    // Преобразование QVariantMap в ваш тип данных
    Spaces space;
    space.spacename = item["spacename"].toString();
    space.spaceId = item["spaceId"].toInt();
    space.taskCount = item["taskCount"].toInt();
    space.lastDueTime = item["lastDueTime"].toString();
    // Установка других полей...
    m_spaces.append(space);
    endInsertRows();
}
