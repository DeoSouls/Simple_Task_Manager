#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <QObject>
#include <QTranslator>
#include <QApplication>

class Translator : public QObject {
        Q_OBJECT
    private:
        QTranslator m_translator;
    public:
        explicit Translator(QObject *parent = nullptr);
        Q_INVOKABLE void changeLanguage(const QString &language);
    signals:
        void languageChanged();
};

#endif // TRANSLATOR_H
