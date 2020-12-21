#ifndef REDISADAPTER_H
#define REDISADAPTER_H

#include <QTcpSocket>
#include <QDataStream>
#include <qqml.h>
#include <QRunnable>
#include <QQuickTextDocument>
#include "mhigher.h"

class RedisMeta;
typedef void (*jober)(RedisMeta* meta);

class RedisMeta : public QObject, public QRunnable {
    Q_OBJECT

    Q_PROPERTY(QString name READ getName WRITE setName)
    Q_PROPERTY(QString host READ getHost WRITE setHost)
    Q_PROPERTY(QString port READ getPort WRITE setPort)
    Q_PROPERTY(QString pass READ getPass WRITE setPass)
    Q_PROPERTY(QString uuid READ getId WRITE setUuid)


    QML_ELEMENT

public:
    explicit RedisMeta(QObject* parent = nullptr);

    static RedisMeta* copy(RedisMeta* other);
public:
    void setName(const QString& name){this->name = name;}
    QString getName(){return name;}
    void setHost(const QString& host){this->host = host;}
    QString getHost(){return host;}
    void setPort(const QString& port){this->port = port;}
    QString getPort(){return port;}
    void setPass(const QString& pass){this->pass = pass;}
    QString getPass(){return pass;}

    QString getId() {
        return uuid;
    }
    void setUuid(QString &uuid){
        this->uuid = uuid;
    }

    QList<QString> getDBKeys(int dbInx);

    void genid();

    void run();

    RedisMeta& operator=(const RedisMeta &other);

    friend QDataStream& operator>>(QDataStream&, RedisMeta&);
    friend QDataStream& operator<<(QDataStream&, RedisMeta&);

    friend class RedisAdapter;

private slots:
    bool connectHost();

    bool auth();
    void queryConfig();
    int queryDbs();
    int queryDbsN(int db);
    QList<QString> getDbKeys(int db);
    QString typeKey(int db, QString key);

    QString getKv(int db, QString key);
    QList<QString> getHKeys(int db, QString key, QString mat, int start, int count);
    QString getHKv(int db, QString table, QString key);
    int getHKn(int db, QString table);
    QList<QString> getSKeys(int db, QString key, QString mat,  int start, int count);
    int getSKn(int db, QString key);

    QList<QString> getLKeys(int db, QString key, int start, int stop);
    int getLKn(int db, QString key);



    //添加
    bool setStringKey(int db, QString table, QString value);
    bool setHashKey(int db, QString table, QString key, QString value);
    bool setSetKey(int db, QString table, QString key);
    bool setListKey(int db, QString table, int linx, QString value);
    bool pushListKey(int db, QString table, QString value, QString pat);
    bool insertListKey(int db, QString table, QString target, QString value, QString pat);

    //删除
    bool delKey(int db, QString key);
    bool delHashKey(int db, QString table, QString key);
    bool delSetKey(int db, QString table, QString key);
    bool delListKey(int db, QString table, QString key);

    //更新表名
    bool remKey(int db, QString oldkey, QString newkey);

private:
    QString confirmCom(QString& com);
    void selectDb(int db);

signals:
    void notifyDbKn(int i, int n);
    void notifyDbKeys(int dbInx);
    void systemError(QString com);
    void readTimeout(QString com);


private:
    QString name;
    QString host;
    QString port;
    QString pass;
    QString uuid;

    int dbn;

    QMap<int, QList<QString> > m_dbkeys;

    QTcpSocket* client = nullptr;
    jober job = nullptr;
};

class RedisAdapter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QList<RedisMeta*> redis READ getRedis WRITE setRedis)

    QML_ELEMENT
public:
    explicit RedisAdapter(QObject *parent = nullptr);


public slots:
    void setRedis(QList<RedisMeta*>& list){redis = list;}
    QList<RedisMeta*> getRedis(){return redis;}
    QString validateJson(QString str);
    QString formatJson(QString str);
    void setHigher(QQuickTextDocument *doc);

    QString newRedis(RedisMeta* meta);
    bool testRedis(RedisMeta* meta);
    void delRedis(int inx);




    void auth(int inx);
    void queryConfig(int inx);
    int queryDbs(int inx);
    int queryDbsN(int inx, int db);
    QList<QString> dbkeys(int inx, int db);
    QString typeKey(int inx, int db, QString key);
    QString getKv(int inx, int db, QString key);
    void setKv(int inx, int db, QString key, QString value);

    QList<QString> getHKeys(int inx, int db, QString key, QString mat, int start, int count);
    QString getHKv(int inx, int db, QString table, QString key);
    int getHKn(int inx, int db, QString table);

    int getSKn(int inx, int db, QString key);
    QList<QString> getSKeys(int inx, int db, QString key, QString mat, int start, int count);

    QList<QString> getLKeys(int inx, int db, QString key, int start, int stop);
    int getLKn(int inx, int db, QString key);


    bool setStringKey(int inx, int db, QString table, QString value);
    bool setHashKey(int inx, int db, QString table, QString key, QString value);
    bool setSetKey(int inx, int db, QString table, QString key);
    bool setListKey(int inx, int db, QString table, int linx, QString value);
    bool pushListKey(int inx, int db, QString table, QString value, QString pat);
    bool insertListKey(int inx, int db, QString table, QString target, QString value, QString pat);

    bool delKey(int inx, int db, QString key);
    bool delHashKey(int inx, int db, QString table, QString key);
    bool delSetKey(int inx, int db, QString table, QString key);
    bool delListKey(int inx, int db, QString table, QString key);

    bool remKey(int inx, int db, QString oldkey, QString newkey);

signals:
    void redisLost(RedisMeta* meta);
    void netError(RedisMeta* meta);
    void updateDevice();
    void notifyDbKn(int dbInx, int n);
    void notifyDbKeys(int dbInx);
    void readTimeout(QString com);

private:
    void initMeta();
    void saveMeta();

    void convertObject(QJsonObject& obj, QString &str, QString tab);
    void convertArray(QJsonArray& ary, QString &str, QString tab);

    QString replaceN(QString str);

    QString toJsonValue(QString &in);

private:
    QList<RedisMeta*> redis;
    QString metaPath;
    MHigher* higher = nullptr;
};

#endif // REDISADAPTER_H
