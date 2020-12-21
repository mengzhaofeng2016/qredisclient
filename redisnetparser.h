#ifndef REDISNETPARSER_H
#define REDISNETPARSER_H

#include <QObject>
#include <QMap>

class RedisNetParser : public QObject
{
    Q_OBJECT
public:
    explicit RedisNetParser(QObject *parent = nullptr);

    void parseConfig(QStringList& data, QMap<QString,QString> &out);

    static int getLines(QString& in);
    static int getNextNum(QString &in);
    static QString GetNextLine(QString& in);
    static int GetResultNum(QString &in);
    static QString getSuccessValue(QString& in);
    static QString getLineValue(QString &in);
    static bool isAll(QString in);

    static int getLineByPos(QString &in, int pos);

signals:


private:

};

#endif // REDISNETPARSER_H
