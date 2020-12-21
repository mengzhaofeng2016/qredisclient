/****************************************************************************
** Generated QML type registration code
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>

#include <redisadapter.h>

void qml_register_types_io_junsie_mredis()
{
    qmlRegisterTypesAndRevisions<RedisAdapter>("io.junsie.mredis", 1);
    qmlRegisterTypesAndRevisions<RedisMeta>("io.junsie.mredis", 1);
    qmlRegisterModule("io.junsie.mredis", 1, 0);
}

static const QQmlModuleRegistration registration("io.junsie.mredis", 1, qml_register_types_io_junsie_mredis);
