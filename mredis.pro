QT += quick qml widgets

CONFIG += qt plugin qmltypes
CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0


SOURCES += \
        jober.cpp \
        main.cpp \
        mhigher.cpp \
        redisadapter.cpp \
        redisnetparser.cpp

RESOURCES += qml.qrc

RC_ICONS = mredis.ico

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = ./

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH = ./

QML_IMPORT_NAME = io.junsie.mredis
QML_IMPORT_MAJOR_VERSION = 1

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    jober.h \
    mhigher.h \
    redisadapter.h \
    redisnetparser.h

DISTFILES += \
    mredis.ico

