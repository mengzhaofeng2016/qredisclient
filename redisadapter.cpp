#include "redisadapter.h"
#include <QDebug>
#include <QApplication>
#include <QFile>
#include <QUuid>
#include <QThreadPool>
#include "redisnetparser.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDate>
#include <QDir>
#include <QStandardPaths>

RedisAdapter::RedisAdapter(QObject *parent) : QObject(parent)
{
    QStringList applicationDirPath = QStandardPaths::standardLocations(QStandardPaths::DataLocation);

    if(applicationDirPath.length() > 0) {
        QString path = applicationDirPath[0];
        QDir d;
        d.mkdir(path);
        metaPath = path + "/meta";
        //初始化
        initMeta();
    }
}

QString RedisAdapter::validateJson(QString str)
{


    auto doc = QJsonDocument::fromJson(str.toUtf8());

    if(doc.isArray()) {

        return str;
    }

    if(doc.isObject()) {
        return str;
    }

    QJsonValue v(str);

    if(v.isBool()) {
        return str;
    } else if(v.isDouble()) {
        return str;
    } else if(v.isString()) {
        return str;
    } else {

    }

    return "";
}

QString RedisAdapter::newRedis(RedisMeta *meta)
{
    for(auto &m: redis) {

        if(m->getId() == meta->getId()) {
            if(m->client && m->client->state() == QAbstractSocket::ConnectedState) {
                m->client->close();
            }

            meta->genid();
            *m = *meta;
            connect(m, &RedisMeta::notifyDbKn, this, &RedisAdapter::notifyDbKn);
            connect(m, &RedisMeta::notifyDbKeys, this, &RedisAdapter::notifyDbKeys);

            saveMeta();
            emit updateDevice();
            return QString("");
        }
    }

    meta->genid();
    auto n = RedisMeta::copy(meta);
    connect(n, &RedisMeta::notifyDbKn, this, &RedisAdapter::notifyDbKn);
    connect(n, &RedisMeta::notifyDbKeys, this, &RedisAdapter::notifyDbKeys);

    redis.push_back(n);

    emit updateDevice();


    saveMeta();

    return QString("");
}

bool RedisAdapter::testRedis(RedisMeta *meta)
{
    if(meta->pass != "") {
        return meta->auth();
    } else {
        return meta->connectHost();
    }


}

void RedisAdapter::delRedis(int inx)
{
    auto m = redis.at(inx);
    delete m;

    redis.removeAt(inx);

    saveMeta();

    emit updateDevice();
}

void RedisAdapter::auth(int inx)
{
    auto meta = redis.at(inx);
    if(meta != nullptr) {
        meta->auth();
    }
}

void RedisAdapter::queryConfig(int inx)
{
    auto meta = redis[inx];
    if(meta != nullptr) {
        meta->queryConfig();
    }
}

int RedisAdapter::queryDbs(int inx)
{
    return  redis[inx]->queryDbs();
}

int RedisAdapter::queryDbsN(int inx, int db)
{
    return redis[inx]->queryDbsN(db);
}

QList<QString> RedisAdapter::dbkeys(int inx, int db)
{
    return redis[inx]->getDbKeys(db);
}


QString RedisAdapter::typeKey(int inx, int db, QString key)
{
    return redis[inx]->typeKey(db, key);
}

QString RedisAdapter::getKv(int inx, int db, QString key)
{
    return redis[inx]->getKv(db,key);
}

void RedisAdapter::setKv(int inx, int db, QString key, QString value)
{

}

QList<QString> RedisAdapter::getHKeys(int inx, int db, QString key, QString mat, int start, int count)
{
    return redis[inx]->getHKeys(db, key, mat, start, count);
}

QString RedisAdapter::getHKv(int inx, int db, QString table, QString key)
{
    return redis[inx]->getHKv(db, table, key);
}

int RedisAdapter::getHKn(int inx, int db, QString table)
{
    return redis[inx]->getHKn(db, table);
}

int RedisAdapter::getSKn(int inx, int db, QString key)
{
    return redis[inx]->getSKn(db, key);
}

QList<QString> RedisAdapter::getSKeys(int inx, int db, QString key, QString mat,  int start, int count)
{
    return redis[inx]->getSKeys(db,key,mat, start, count);
}

QList<QString> RedisAdapter::getLKeys(int inx, int db, QString key, int start, int stop)
{
    return redis[inx]->getLKeys(db,key, start, stop);
}

int RedisAdapter::getLKn(int inx, int db, QString key)
{
    return redis[inx]->getLKn(db, key);
}

bool RedisAdapter::setStringKey(int inx, int db, QString table, QString value)
{
    return  redis[inx]->setStringKey(db, table, toJsonValue(value));
}

bool RedisAdapter::setHashKey(int inx, int db, QString table, QString key, QString value)
{
    return redis[inx]->setHashKey(db, table, key, toJsonValue(value));
}

bool RedisAdapter::setSetKey(int inx, int db, QString table, QString key)
{
    return redis[inx]->setSetKey(db, table, toJsonValue(key));
}

bool RedisAdapter::setListKey(int inx, int db, QString table, int linx, QString value)
{
    return redis[inx]->setListKey(db, table, linx, toJsonValue(value));
}

bool RedisAdapter::pushListKey(int inx, int db, QString table, QString value, QString pat)
{
    return redis[inx]->pushListKey(db, table, toJsonValue(value), pat);
}

bool RedisAdapter::insertListKey(int inx, int db, QString table, QString target, QString value, QString pat)
{
    return redis[inx]->insertListKey(db, table, target, toJsonValue(value), pat);
}

bool RedisAdapter::delKey(int inx, int db, QString key)
{
    return redis[inx]->delKey(db, key);
}

bool RedisAdapter::delHashKey(int inx, int db, QString table, QString key)
{
    return redis[inx]->delHashKey(db, table, key);
}

bool RedisAdapter::delSetKey(int inx, int db, QString table, QString key)
{
    return redis[inx]->delSetKey(db, table, key);
}

bool RedisAdapter::delListKey(int inx, int db, QString table, QString key)
{
    return redis[inx]->delListKey(db, table, key);
}

bool RedisAdapter::remKey(int inx, int db, QString oldkey, QString newkey)
{
    return redis[inx]->remKey(db, oldkey, newkey);
}

void RedisAdapter::initMeta()
{
    QFile file(metaPath);
    file.open(QIODevice::ReadOnly);
    QDataStream in(&file);

    while(!in.atEnd()) {
        auto* meta = new RedisMeta();

        in >> *meta;

        if(meta->getId() == "") {
            continue;
        }

        connect(meta, &RedisMeta::notifyDbKn, this, &RedisAdapter::notifyDbKn);
        connect(meta, &RedisMeta::notifyDbKeys, this, &RedisAdapter::notifyDbKeys);
        redis.append(meta);
    }

    file.close();
}

void RedisAdapter::saveMeta()
{
    QFile file(metaPath);
    file.open(QIODevice::WriteOnly);
    QDataStream out(&file);

    for(auto &meta: redis) {
        if(meta->getId() == "") continue;
        out << *meta;
    }

    file.close();
}

QString RedisAdapter::formatJson(QString str)
{

    auto doc = QJsonDocument::fromJson(str.toUtf8());
    //    if(doc.isEmpty() || doc.isNull()) {
    //        return QString("~~error~~!!~~");
    //    }
    QJsonObject obj = doc.object();
    QString res;
    if(doc.isArray()) {
        auto a = doc.array();

        convertArray(a, res, QString(""));
    } else if(doc.isObject()) {
        auto a = doc.object();
        convertObject(a, res, QString(""));
    } else {
        //        QJsonValue v(str);

        //        if(v.isBool()) {
        //            return str;
        //        } else if(v.isDouble()) {
        //            return str;
        //        } else {
        //            auto reg = QRegularExpression(QStringLiteral("^\".*\\n*.*\"$"));
        //            auto mat = reg.match(str);
        //            if(mat.hasMatch())
        //                return str;

        //            reg = QRegularExpression(QStringLiteral("^[0-9\\.\\+-e]*$"));
        //            mat = reg.match(str);
        //            if(mat.hasMatch())
        //                return str;
        //        }

        return str;
    }


    return res;
}

void RedisAdapter::setHigher(QQuickTextDocument *doc)
{
    if(doc == nullptr) {

    }
    if(higher == nullptr) {
        higher = new MHigher(doc);
    } else {
        delete higher;
        higher = new MHigher(doc);
    }
}

void RedisAdapter::convertObject(QJsonObject &obj, QString &res, QString tab)
{

    res += "{\n";

    auto keys = obj.keys();
    qsizetype n = keys.size() - 1;

    QString dou;
    for(auto i=0; i<=n; i++) {
        auto k = keys[i];
        auto value = obj[k];
        res += tab + "\t\"" + k + "\": ";

        if(i != n) {
            dou = ",";
        } else {
            dou = "";
        }

        if(value.isArray()) {

            auto a = value.toArray();
            convertArray(a, res, QString(tab + "\t"));
        }else if(value.isObject()) {

            auto a = value.toObject();
            convertObject(a, res, QString(tab + "\t"));
        } else if(value.isString()) {
            res += "\"";
            //res += replaceN(value.toString()) + "\"";
            res += value.toString() + "\"";


        } else if(value.isDouble()) {
            res += QString::number(value.toDouble());

        } else if(value.isBool()) {
            res += (value.toBool()?"true":"false");

        } else if(value.isNull()) {
            res += "null";

        }

        res += dou;
        res += "\n";
    }

    res += tab + "}";
}

void RedisAdapter::convertArray(QJsonArray &ary, QString &res, QString tab)
{
    res += "[\n";

    for(qsizetype i =0; i<ary.size(); i++) {
        auto a = ary.at(i);
        if(a.isObject()) {
            auto b = a.toObject();
            res += QString(tab + "\t");
            convertObject(b, res, QString(tab + "\t"));

        }else if(a.isArray()) {
            res += QString(tab + "\t");
            auto b = a.toArray();
            convertArray(b, res, QString(tab + "\t"));
        } else if(a.isString()) {
            res += tab + "\t\"";
            //res += replaceN(a.toString()) + "\"";
            res += a.toString() + "\"";
        } else if(a.isDouble()) {
            res += tab + "\t";
            res += QString::number(a.toDouble());
        } else if(a.isBool()) {
            res += tab + "\t";
            res += (a.toBool()?"true":"false");
        } else if(a.isNull()) {
            res += tab + "\t";
            res += "null";
        }

        if(i != ary.size() - 1) {
            res += ",\n";
        } else {
            res += "\n";
        }
    }



    res += tab + "]";
}

QString RedisAdapter::replaceN(QString mid)
{
    QString ns;
    for(int i=0; i<mid.length(); i++) {
        if(mid[i] == "\n"){
            ns += "\\n";
        } else {
            ns += mid[i];
        }
    }

    return ns;
}

QString RedisAdapter::toJsonValue(QString &in)
{
    auto doc = QJsonDocument::fromJson(in.toUtf8());
    if(doc.isArray() || doc.isObject()) {
        return QString(doc.toJson());
    }else {

        return in.trimmed();
    }
}

RedisMeta::RedisMeta(QObject *parent): QObject(parent)
{

}

RedisMeta *RedisMeta::copy(RedisMeta *other)
{
    auto meta = new RedisMeta();
    meta->host = other->host;
    meta->name = other->name;
    meta->port = other->port;
    meta->pass = other->pass;
    meta->uuid = other->uuid;
    return meta;
}

void RedisMeta::genid()
{
    uuid = QUuid::createUuid().toString();
}

void RedisMeta::run()
{
    if(this->job != nullptr) {
        job(this);
        job = nullptr;
    }
}

RedisMeta &RedisMeta::operator=(const RedisMeta &other)
{
    this->name = other.name;
    this->host = other.host;
    this->port = other.port;
    this->pass = other.pass;
    this->uuid = other.uuid;
    return *this;
}

QDataStream& operator>>(QDataStream& stream, RedisMeta& meta) {


    stream >> meta.name;
    stream >> meta.host;
    stream >> meta.port;
    stream >> meta.pass;
    stream >> meta.uuid;

    return stream;
}

QDataStream& operator<<(QDataStream& stream, RedisMeta& meta) {

    stream << meta.name << meta.host << meta.port << meta.pass << meta.uuid;
    return stream;
}


bool RedisMeta::connectHost()
{
    if(client == nullptr) {
        client = new QTcpSocket(this);
    }

    if(client->state() != QAbstractSocket::ConnectedState){

        client->connectToHost(host, port.toShort());

        return  client->waitForConnected(3000);
    } else {
        return true;
    }

}


bool RedisMeta::auth()
{

    if(connectHost()){

        QString com("AUTH ");
        com = com+ pass + "\r\n";
        client->write(com.toLocal8Bit());

        client->waitForReadyRead();

        auto data = client->readAll();

        return true;
    } else {
        return false;
    }

}

void RedisMeta::queryConfig()
{
    if(connectHost()){
        QString com("CONFIG get *\r\n");

        client->write(com.toLocal8Bit());

        client->waitForReadyRead();

        int n = client->bytesAvailable();


    }
}

int RedisMeta::queryDbs()
{
    if(connectHost()){
        QString com("CONFIG get databases\r\n");

        QString res = confirmCom(com);
        auto list = res.split("\r\n");

        if(list.length() != 6) return -1;

        dbn = list.at(4).toInt();

        for(int i=0; i<dbn; i++) {
            QString com = QString("SELECT %1 \r\n").arg(i);

            confirmCom(com);

            com = "DBSIZE\r\n";
            QString res = confirmCom(com);
            if(res.startsWith(":")) {
                QString n;
                for(int i=1; i<res.length();i++) {
                    if(res[i].isDigit()) {
                        n += res[i];
                    }else {
                        break;
                    }
                }


                emit notifyDbKn(i, n.toInt());
            }

        }

        //  QThreadPool::globalInstance()->start(this);

        return dbn;
    } else {
        return -2;
    }
}

int RedisMeta::queryDbsN(int db)
{
    selectDb(db);

    QString com = "DBSIZE\r\n";
    QString res = confirmCom(com);

    if(res.startsWith(":")) {
        QString n;
        for(int i=1; i<res.length();i++) {
            if(res[i].isDigit()) {
                n += res[i];
            }else {
                break;
            }
        }

        return n.toInt();
    }
    return 0;
}

QList<QString> RedisMeta::getDbKeys(int db)
{

    if(connectHost()){

        selectDb(db);

        QString com("KEYS *\r\n");

        QString rdata = confirmCom(com);

        int n = RedisNetParser::getLines(rdata);

        QList<QString> list;
        for(int i=0; i<n; i++) {
            list.append(RedisNetParser::GetNextLine(rdata));
        }


        return list;
    }

    return QList<QString>();
}

QString RedisMeta::typeKey(int db, QString key)
{
    selectDb(db);


    QString com = QString("TYPE %1\r\n").arg(key);

    QString res = confirmCom(com);

    QString r = RedisNetParser::getSuccessValue(res);

    return r;
}

QString RedisMeta::getKv(int db, QString key)
{
    selectDb(db);
    QString com = QString("GET %1\r\n").arg(key);
    QString res = confirmCom(com);


    QString xx = RedisNetParser::GetNextLine(res);


    return xx;
}

QList<QString> RedisMeta::getHKeys(int db, QString key, QString mat, int start, int count)
{
    selectDb(db);

    if(mat != "") {

        mat = "*" + mat;
    }
    mat += "*";

    QString com = QString("HSCAN %1 %2 MATCH %3 COUNT %4\r\n").arg(key).arg(start).arg(mat).arg(count);
    QString res = confirmCom(com);


    int p = res.indexOf("$");

    if(p >= 0) {
        QString rr = res.right(res.size() - p);
        QString cursor = RedisNetParser::GetNextLine(rr);

        QList<QString> list;
        list.append(cursor);

        int n = RedisNetParser::getLines(rr);


        for(auto i =0; i<n; i++) {
            list.append(RedisNetParser::GetNextLine(rr));
        }
        return list;
    }



    return QList<QString>();
}

QString RedisMeta::getHKv(int db, QString table, QString key)
{

    selectDb(db);
    QString com = QString("HGET %1 %2\r\n").arg(table).arg(key);

    QString res = confirmCom(com);

    res = RedisNetParser::getLineValue(res);

    return res;
}

int RedisMeta::getHKn(int db, QString table)
{
    selectDb(db);
    QString com = QString("HLEN %1\r\n").arg(table);

    QString res = confirmCom(com);

    return RedisNetParser::GetResultNum(res);
}

QList<QString> RedisMeta::getSKeys(int db, QString key, QString mat, int start, int count)
{
    selectDb(db);

    if(mat != "") {

        mat = "*" + mat;
    }
    mat += "*";
    QString com = QString("SSCAN %1 %2 MATCH %3 COUNT %4\r\n").arg(key).arg(start).arg(mat).arg(count);


    QString res = confirmCom(com);

    int p = res.indexOf("$");
    if(p >= 0) {
        QString rr = res.right(res.size() - p);
        QString cursor = RedisNetParser::GetNextLine(rr);
        QList<QString> list;
        list.append(cursor);
        int n = RedisNetParser::getLines(rr);

        for(auto i =0; i<n; i++) {
            list.append(RedisNetParser::GetNextLine(rr));
        }
        return list;
    }

    return QList<QString>();
}


int RedisMeta::getSKn(int db, QString key)
{
    selectDb(db);
    QString com = QString("SCARD %1 \r\n").arg(key);
    QString res = confirmCom(com);


    return RedisNetParser::GetResultNum(res);
}

QList<QString> RedisMeta::getLKeys(int db, QString key, int start, int stop)
{
    selectDb(db);



    QString com = QString("LRANGE %1 %2 %3\r\n").arg(key).arg(start).arg(stop);


    QString res = confirmCom(com);


    int n = RedisNetParser::getLines(res);

    QList<QString> list;
    for(int i=0; i<n; i++) {
        list.append(RedisNetParser::GetNextLine(res));
    }


    return list;
}

int RedisMeta::getLKn(int db, QString key)
{
    selectDb(db);
    QString com = QString("LLEN %1\r\n").arg(key);

    QString res = confirmCom(com);
    return RedisNetParser::GetResultNum(res);
}

bool RedisMeta::setStringKey(int db, QString table, QString value)
{
    selectDb(db);

    QString com = QString("*3\r\n$3\r\nSET\r\n$%1\r\n%2\r\n$%3\r\n%4\r\n").arg(table.size()).arg(table).arg(value.toLocal8Bit().size()).arg(value);

    QString res = confirmCom(com);
    if(res.indexOf("OK") >= 0) {
        return true;
    } else {
        return false;
    }
}

bool RedisMeta::setHashKey(int db, QString table, QString key, QString value)
{
    selectDb(db);
    QString com = QString("*4\r\n$4\r\nHSET\r\n$%1\r\n%2\r\n$%3\r\n%4\r\n$%5\r\n%6\r\n").arg(table.toLocal8Bit().size()).arg(table).arg(key.toLocal8Bit().size()).arg(key).arg(value.toLocal8Bit().size()).arg(value);
    QString res = confirmCom(com);


    if(res.indexOf("1") >= 0 || res.indexOf("0") >= 0 ) {
        return true;
    } else {
        return false;
    }

}

bool RedisMeta::setSetKey(int db, QString table, QString key)
{
    selectDb(db);
    QString com = QString("SADD %1 %2\r\n").arg(table).arg(key);
    QString res = confirmCom(com);


    if(res.indexOf("1") >= 0) {
        return true;
    } else {
        return false;
    }
}

bool RedisMeta::setListKey(int db, QString table, int linx, QString value)
{
    selectDb(db);
    QString com = QString("LSET %1 %2 %3\r\n").arg(table).arg(linx).arg(value);
    QString res = confirmCom(com);
    if(res.indexOf("OK") >= 0) {
        return true;
    } else {
        return false;
    }
}

bool RedisMeta::pushListKey(int db, QString table, QString value, QString pat)
{
    selectDb(db);


    QString com = QString("%1 %2 %3\r\n").arg(pat).arg(table).arg(value);
    QString res = confirmCom(com);

    int n = RedisNetParser::GetResultNum(res);
    if(n > 0) {
        return true;
    } else {
        return false;
    }
}

bool RedisMeta::insertListKey(int db, QString table, QString target, QString value, QString pat)
{
    selectDb(db);
    QString com = QString("LINSERT %1 %2 %3 %4\r\n").arg(table).arg(pat).arg(target).arg(value);
    QString res = confirmCom(com);
    if(res.indexOf("OK") >= 0) {
        return true;
    } else {
        return false;
    }
}

bool RedisMeta::delKey(int db, QString key)
{

    selectDb(db);

    QString com = QString("DEL %1\r\n").arg(key);

    QString res = confirmCom(com);

    if(res.indexOf("1") >= 0) {
        return true;
    } else {
        return false;
    }
}

bool RedisMeta::delHashKey(int db, QString table, QString key)
{
    selectDb(db);
    QString com = QString("HDEL %1 %2\r\n").arg(table).arg(key);

    QString res = confirmCom(com);
    if(res.indexOf("1") >=0) {
        return true;
    } else {
        return false;
    }
}

bool RedisMeta::delSetKey(int db, QString table, QString key)
{
    selectDb(db);
    QString com = QString("SREM %1 %2\r\n").arg(table).arg(key);

    QString res = confirmCom(com);



    int n = RedisNetParser::getNextNum(res);

    if(n >= 0) {
        return true;
    } else {
        return false;
    }
}

bool RedisMeta::delListKey(int db, QString table, QString key)
{
    selectDb(db);
    QString com = QString("LREM %1 0 %2\r\n").arg(table).arg(key);

    QString res = confirmCom(com);

    int n = RedisNetParser::getNextNum(res);
    if(n >= 0) {
        return true;
    } else {

        return false;
    }
}

bool RedisMeta::remKey(int db, QString oldkey, QString newkey)
{
    selectDb(db);
    QString com = QString("RENAME %1 %2\r\n").arg(oldkey).arg(newkey);
    QString res = confirmCom(com);
    if(res.indexOf("OK") >= 0) {

        return true;
    } else {
        return false;
    }
}

//内部调用
QString RedisMeta::confirmCom(QString &com)
{
    client->write(com.toLocal8Bit());
    QString res;


    while(client->waitForReadyRead(10000)){



        if(client->bytesAvailable() > 0) {
            auto data = client->readAll();

            if(QString(data).indexOf("Authentication required") >= 0) {
                if(true == auth()){
                    client->write(com.toLocal8Bit());

                    client->waitForReadyRead();

                    data = client->readAll();
                    res += data;
                } else {
                    emit systemError(com);
                }
            } else {
                res += data;
            }

            if(QString(data).endsWith("\r\n")) {
                if(RedisNetParser::isAll(res)){

                    break;
                }else {

                }
            }
        } else {

            emit readTimeout(com);
        }

    }



    return res;
}

void RedisMeta::selectDb(int db)
{


    if(auth()) {
        QString com = QString("SELECT %1\r\n").arg(db);

        confirmCom(com);
    } else {
        emit readTimeout("connect error");
    }




}


