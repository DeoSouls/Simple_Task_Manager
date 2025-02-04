#ifndef IMAGETOBYTEARRAY_H
#define IMAGETOBYTEARRAY_H

#include <QObject>

class ImageToByteArray : public QObject {
        Q_OBJECT
    public:
        explicit ImageToByteArray(QObject *parent = nullptr);
        Q_INVOKABLE QByteArray convertImgToArray(const QString& source);
};

#endif // IMAGETOBYTEARRAY_H
