import QtQuick 2.0

Rectangle {
    id: idprogress
    property real pw: 512
    property real ph: 2
    property real dura: 1000
    property real nw: 512
    property real bw: 0
    property real rw: 0
    color: "green"
    property bool sclose: false

    width: rw
    height: ph

    function start() {
        bw = 0
        nw = 0.3 * pw
        sclose = false
        dura = 10000
        idprogress.visible = true
        idani.start()
    }

    function fin() {
        idani.stop()
        bw = nw
        nw = pw
        sclose = true
        dura = 1000
        idani.start()
    }

    function onFin() {
        if (sclose)
            idprogress.visible = false
    }

    Component.onCompleted: {

        idani.finished.connect(idprogress.onFin)
    }

    SequentialAnimation {
        id: idani
        loops: 1
        //! [1]
        ParallelAnimation {

            NumberAnimation {
                target: idprogress
                property: "rw"
                easing.type: Easing.OutQuart
                from: bw
                to: nw
                duration: dura
            }
        }
    }
}
