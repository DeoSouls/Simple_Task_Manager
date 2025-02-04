#include "translator.h"

Translator::Translator(QObject *parent) : QObject{parent} {}

void Translator::changeLanguage(const QString &language) {
    if (!m_translator.isEmpty()) {
        qApp->removeTranslator(&m_translator);
    }

    QString translationFile = QString(":/qt/qml/SimpleTaskManager/translations/appSimpleTaskManager_%1.qm").arg(language);
    if(m_translator.load(translationFile)) {
        qApp->installTranslator(&m_translator);
        emit languageChanged();
    } else {
        qWarning() << "Не удалось загрузить перевод:" << translationFile;
    }
}
