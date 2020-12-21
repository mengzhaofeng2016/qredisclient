#include "redisnetparser.h"
#include <QString>
#include <QDebug>

RedisNetParser::RedisNetParser(QObject *parent) : QObject(parent)
{

}

void RedisNetParser::parseConfig(QStringList &data, QMap<QString, QString> &out)
{
    if(data.length() == 0) return ;
    if(data[0].startsWith("*")) {
        QString linStr = data[0];
        int liNum = linStr.right(linStr.length()-1).toInt();
        liNum/=2;
        for(int i=0;i<liNum; i++) {

        }
    }
}

int RedisNetParser::getLines(QString &in)
{
    if(in.startsWith("*")) {
        QString n;
        for(int i=1; i<in.length();i++) {
            if(in[i].isDigit()) {
                n += in[i];
            } else {
                in = in.right(in.length() - (i+2));
                break;
            }
        }

        return n.toInt();
    }
    return 0;
}

int RedisNetParser::getNextNum(QString &in)
{
    if(in.startsWith("$")) {
        QString n;
        for(int i=1; i<in.length();i++) {
            if(in[i].isDigit()) {
                n += in[i];
            } else {
                in = in.right(in.length() - (i+2));
                break;
            }
        }

        return n.toInt();
    }
    return 0;
}

QString RedisNetParser::GetNextLine(QString &in)
{


    if(in.startsWith("$")) {
        QString n;
        for(int i=1; i<in.length();i++) {
            if(in[i].isDigit()) {
                n += in[i];
            } else {
                QString res;
                int N = n.toInt();

                int j=i+2;
                for(; j<i+2+N; j++) {

                    if(in[j] == "\r" && in[j+1] == "\n") {

                        break;

                    } else {

                        res.append(in[j]);
                    }
                }

                in = in.right(in.size() - (j+2));

                return res;
            }
        }

    }
    return QString("");
}

int RedisNetParser::GetResultNum(QString &in)
{

    if(in.startsWith(":")) {
        QString n;
        for(int i=1; i<in.length();i++) {
            if(in[i].isDigit()) {
                n += in[i];
            } else {

                break;
            }
        }

        return n.toInt();
    }
    return 0;
}

QString RedisNetParser::getSuccessValue(QString &in)
{
    if(in.startsWith("+")) {
        QString n;
        for(int i=1; i<in.length();i++) {
            if(in[i] == "\r" && in[i+1] == "\n") {

                break;
            }else {
                n += in[i];
            }
        }
        return n;
    }
    return QString("");
}

QString RedisNetParser::getLineValue(QString &in)
{
    if(in.startsWith("$")) {
        int m = getNextNum(in);

        int inx = in.indexOf("\r\n");

        QString res = in.left(inx);


        return res;
    }
    return QString("");
}


bool RedisNetParser::isAll(QString in)
{

    if(in.startsWith("*")) {

        int n = in.size();
        int p = in.lastIndexOf("*");
        int c = 0;
        int m = getLineByPos(in, p);
        if(p >= 0) {
            for(auto i=p; i<n-1; i++) {
                if(in[i] == "\r" && in[i+1] == "\n") {
                    c++;
                }
            }
            if(c == m*2+1) {
                return true;
            } else {
                return false;
            }
        }

    }else if(in.startsWith("$")) {

        int n = getNextNum(in);

        if(n == in.toLocal8Bit().size() - 2) {
            return true;
        } else {
            return false;
        }
    }else if(in.startsWith("+")) {
        return true;
    } else if(in.startsWith("-")) {
        return true;
    } else if(in.startsWith(":")) {
        return true;
    }

    return false;
}

int RedisNetParser::getLineByPos(QString &in, int pos)
{
    if(in[pos] == "*") {
        QString n;
        for(int i=pos+1; i<in.length();i++) {
            if(in[i].isDigit()) {
                n += in[i];
            } else {
                break;
            }
        }

        return n.toInt();
    }
    return 0;
}


