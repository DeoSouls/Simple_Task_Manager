#include "imagetobytearray.h"
#include <QDebug>
#include <QFile>
#include <QUrl>

ImageToByteArray::ImageToByteArray(QObject *parent) : QObject(parent) {}

QByteArray ImageToByteArray::convertImgToArray(const QString& source) {
    qDebug() << "Source path:" << source;
    QFile file(QUrl(source).toLocalFile());
    if(!file.open(QIODevice::ReadOnly)) {
        qDebug() << "Failed to open file:" << file.errorString();
        return QByteArray();
    }

    return file.readAll();
}
