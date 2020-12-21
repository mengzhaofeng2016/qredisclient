import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 2.5

import QtQuick.Controls.Material 2.12
import QtQml.Models 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

Item {
    id: idredisMenu

    property real mw: parent.height / 5
    width: mw < 256 ? 256 : mw
    height: parent.height
    property int cinx: -1
    property int cdb: 0
    property int dbn: 0
    property var dbkeys: []
    property var progress: null
    property string maybeText: ""
    property string dname: ""
    property string newame: ""
    property var curlview: null
    property var currly: null
    property var curitm: null
    property string curtype: ""

    signal newQueryValue(var cinx, var db, var table, string res)
    signal newHashKeys(var cinx, var db, var table, var keys)
    signal newSetKeys(var cinx, var db, var table, var keys, var cursor)
    signal newListKeys(var cinx, var db, var table, var keys, var stop, var total)
    signal showAddKrec(var cinx, var cdb, var table, var ctype)

    Component.onCompleted: {
        redisAdapter.updateDevice.connect(idredisMenu.updateDevice)
        redisAdapter.notifyDbKn.connect(idredisMenu.updateDbInx)
        //  redisAdapter.notifyDbKeys.connect(idredisMenu.updateDbKeys)
        updateDevice()
        //redisList.model = idRedisModel
    }

    function updateDbInx(db, n) {

        idDbModel.append({
                             "name": "+ DB" + db + "(" + n + ")",
                             "index": db,
                             "num": n,
                             "keymodel": createdModel.createObject(idredisMenu)
                         })
    }

    function getCTitle() {
        return redisList.model.get(cinx).text
    }

    function updateDevice() {

        cinx = -1
        var redis = redisAdapter.redis
        var m = createdModel.createObject(idredisMenu)
        for (var i = 0; i < redis.length; i++) {
            m.append({
                         "text": redis[i].name
                     })
        }

        redisList.model = m
    }

    Button {
        x: 10
        y: 10
        id: idaddbtn
        width: idredisMenu.width - 20
        height: 48
        text: "+添加连接"

        onClicked: {
            idaddRedis.stitle = "添加连接"
            idaddRedis.clear()
            idaddRedis.show()
        }
    }

    AddRedis {
        id: idaddRedis
        visible: false
    }

    ListModel {
        id: idRedisModel
    }

    Component {
        id: createdModel
        ListModel {}
    }

    ComboBox {
        id: redisList
        visible: true
        //        currentIndex: coxinx
        y: 64
        x: 10
        width: parent.width - 130
        model: idRedisModel

        Timer {
            id: idey
            interval: 1000
            running: false
            repeat: false
            onTriggered: {
                if (progress != null) {
                    progress.start()
                }
                cinx = redisList.currentIndex

                redisAdapter.auth(cinx)

                idDbModel.clear()
                var n = redisAdapter.queryDbs(cinx)
                dbn = n

                if (progress != null) {
                    progress.fin()
                }
            }
        }

        onCurrentIndexChanged: {

            idey.start()
        }
    }

    Button {
        id: idm
        anchors.left: redisList.right
        anchors.leftMargin: 8
        anchors.verticalCenter: redisList.verticalCenter
        width: redisList.height
        height: redisList.height
        enabled: cinx != -1

        Image {
            anchors.centerIn: parent
            width: 18
            height: 18
            source: "assets/modify.svg"
            focus: true
        }

        onClicked: {

            var data = redisAdapter.redis[cinx]
            idaddRedis.initData(data.name, data.host, data.port, data.pass,
                                data.uuid)
            idaddRedis.visible = true
        }
    }

    Button {
        anchors.left: idm.right
        anchors.leftMargin: 8
        anchors.verticalCenter: redisList.verticalCenter
        width: redisList.height
        height: redisList.height
        enabled: cinx != -1

        Image {
            anchors.centerIn: parent
            width: 18
            height: 18
            source: "assets/delete.svg"
            focus: true
        }

        onClicked: {
            redisAdapter.delRedis(cinx)
        }
    }

    ListModel {
        id: idDbModel
    }

    Menu {
        id: keyMenu
        MenuItem {
            text: "新增"
            onClicked: {
                showAddKrec(cinx, cdb, "", "string")
            }
        }
    }

    Menu {
        id: inkeyMenu
        MenuItem {
            text: "新增"
            onClicked: {
                showAddKrec(cinx, cdb, idredisMenu.newame, idredisMenu.curtype)
            }
        }
        MenuItem {
            text: "删除"
            onClicked: {
                idlg.show()
            }
        }
    }

    function updateDbList(inx, db, table, tkey, value, cType) {

        if (progress != null) {
            progress.start()
        }

        var n = redisAdapter.queryDbsN(inx, db)

        var m = idDbModel.get(db)

        idDbModel.set(db, {
                          "name": "+ DB" + db + "(" + n + ")",
                          "index": db,
                          "num": n,
                          "keymodel": m.keymodel
                      })

        var keys = redisAdapter.dbkeys(inx, db)
        n = keys.length

        var keymodel = m.keymodel

        keymodel.clear()

        for (var i = 0; i < n; i++) {
            keymodel.append({
                                "name": keys[i],
                                "inx": i
                            })
        }

        idredisMenu.curlview.model = keymodel

        if (cType === "hash") {

            n = redisAdapter.getHKn(cinx, db, table)

            var res = redisAdapter.getHKeys(cinx, db, table, "", 0, 30)

            if (res.length > 0) {
                var cur = parseInt(res[0])
                idredisMenu.curlview.tCursor = cur

                newHashKeys(cinx, db, table, res)
            }
        } else if (cType === "set") {

            n = redisAdapter.getSKn(cinx, db, table)

            res = redisAdapter.getSKeys(cinx, db, table, "", 0, 30)

            if (res.length > 0) {
                cur = parseInt(res[0])
                idredisMenu.curlview.tCursor = cur
                var li = []
                for (var i = 1; i < res.length; i++) {
                    li.push(res[i])
                }

                newSetKeys(cinx, db, table, li, cur)
            }
        } else if (cType === "list") {

            n = redisAdapter.getLKn(cinx, db, table)

            res = redisAdapter.getLKeys(cinx, db, table, 0, 29)

            newListKeys(cinx, db, table, res, res.length, n)
        }

        if (progress != null) {
            progress.fin()
        }
    }

    Window {
        id: idlg
        visible: false
        title: "删除"
        modality: Qt.WindowModal
        x: 480
        y: 240
        width: 400
        height: 200
        color: Material.backgroundColor

        Popup {
            id: shpop
            x: 0
            y: 0
            width: parent.width
            height: 40
            modal: false
            focus: false
            closePolicy: Popup.CloseOnPressOutside
            contentItem: Text {
                text: "删除失败"
                color: "#ffaa33"
            }
        }

        Rectangle {
            color: Material.background
            implicitWidth: 400
            implicitHeight: 100
            Text {
                id: ideltext
                text: "确认删除?"
                color: Material.foreground
                anchors.centerIn: parent
            }
        }

        Item {
            anchors.bottom: parent.bottom
            implicitWidth: 400
            implicitHeight: 100
            Button {
                text: "取消"
                anchors.right: dconfim.left
                anchors.top: dconfim.top
                anchors.rightMargin: 36
                onClicked: {
                    idlg.close()
                }
            }

            Button {
                id: dconfim
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: 24
                anchors.rightMargin: 36
                text: "删除"
                onClicked: {
                    if (redisAdapter.delKey(cinx, idredisMenu.cdb,
                                            idredisMenu.dname)) {
                        idlg.close()

                        var n = idDbModel.count

                        for (var i = 0; i < n; i++) {
                            var m = idDbModel.get(i)

                            if (m.index === idredisMenu.cdb) {
                                if (m.num > 1) {

                                    idDbModel.set(i, {
                                                      "name": "+ DB" + m.index + " ("
                                                              + (m.num - 1) + ")",
                                                      "index": m.index,
                                                      "num": m.num - 1,
                                                      "keymodel": m.keymodel
                                                  })
                                } else {
                                    idDbModel.set(i, {
                                                      "name": "+ DB" + m.index,
                                                      "index": m.index,
                                                      "num": 0,
                                                      "keymodel": m.keymodel
                                                  })
                                }
                            }
                        }

                        if (progress != null) {
                            progress.start()
                        }
                        var keys = redisAdapter.dbkeys(cinx, idredisMenu.cdb)
                        var n = keys.length

                        var keymodel = idredisMenu.curlview.model

                        keymodel.clear()

                        for (var i = 0; i < n; i++) {
                            keymodel.append({
                                                "name": keys[i],
                                                "inx": i
                                            })
                        }

                        idredisMenu.curlview.model = keymodel
                        idredisMenu.curlview.visible = true
                        idredisMenu.curlview.height = 24 * n
                        idredisMenu.curlview.curInx = idredisMenu.cdb
                        idredisMenu.curitm.height = idredisMenu.currly.height
                                + idredisMenu.curlview.height

                        if (progress != null) {
                            progress.fin()
                        }
                    } else {
                        shpop.open()
                    }
                }
            }
        }
    }

    ListView {
        id: idDbView
        x: 10
        anchors.top: redisList.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 10
        clip: true
        width: idaddbtn.width
        model: idDbModel
        property var lastid: null
        property int curInx: 0
        delegate: ItemDelegate {

            width: idaddbtn.width
            height: 36
            id: itm
            property bool expended: false

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    idredisMenu.cdb = index
                    idredisMenu.dname = name
                    idredisMenu.curlview = lview
                    idredisMenu.curitm = null
                    idredisMenu.currly = null
                    idredisMenu.newame = ""
                    idredisMenu.curtype = ""

                    if (mouse.button === Qt.RightButton) {
                        idredisMenu.cdb = index

                        keyMenu.popup()
                    } else if (mouse.button === Qt.LeftButton) {

                        if (idDbView.lastid != null) {
                            idDbView.lastid.down = false
                        }
                        itm.down = true
                        idDbView.lastid = itm
                        idDbView.curInx = index

                        if (itm.expended) {
                            lview.visible = false
                            itm.height = 36
                        } else {

                            if (progress != null) {
                                progress.start()
                            }
                            var keys = redisAdapter.dbkeys(cinx, index)
                            var n = keys.length

                            keymodel.clear()

                            for (var i = 0; i < n; i++) {
                                keymodel.append({
                                                    "name": keys[i],
                                                    "inx": i
                                                })
                            }

                            lview.model = keymodel
                            lview.visible = true
                            lview.height = 24 * n
                            lview.curInx = index
                            itm.height = rly.height + lview.height

                            if (progress != null) {
                                progress.fin()
                            }
                        }

                        itm.expended = !itm.expended
                    }
                }
            }

            Rectangle {

                anchors.top: rly.bottom
                width: parent.width
                height: 1
                color: "#AA333333"
            }
            RowLayout {
                id: rly
                width: parent.width
                height: 35

                Text {
                    Layout.fillWidth: true
                    text: name
                    color: Material.foreground
                }

                Item {
                    width: 40
                    height: 40
                    opacity: 0.5
                    Image {
                        anchors.centerIn: parent
                        width: 14
                        height: 14
                        source: itm.expended ? "assets/down.svg" : "assets/right.svg"
                    }
                }
            }

            ListView {
                id: lview
                visible: false
                x: 0
                y: 36
                width: parent.width
                height: 200

                property int curInx: 0
                property int tCount: 0
                property int tCursor: 0

                delegate: ItemDelegate {
                    width: lview.width
                    anchors.leftMargin: 10
                    height: 24
                    id: idkeymitm
                    text: name
                    ToolTip.visible: hovered
                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.text: idkeymitm.text

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: {

                            var t = redisAdapter.typeKey(cinx,
                                                         lview.curInx, name)

                            idredisMenu.cdb = lview.curInx
                            idredisMenu.dname = name
                            idredisMenu.curlview = lview
                            idredisMenu.curitm = itm
                            idredisMenu.currly = rly
                            idredisMenu.newame = name
                            idredisMenu.curtype = t

                            if (mouse.button === Qt.RightButton) {

                                ideltext.text = "确认删除 " + name + "?"
                                inkeyMenu.popup()
                            } else if (mouse.button === Qt.LeftButton) {

                                if (progress != null) {
                                    progress.start()
                                }

                                if (t === "string") {

                                    var res = redisAdapter.getKv(cinx,
                                                                 lview.curInx,
                                                                 name)

                                    newQueryValue(cinx, lview.curInx, name, res)
                                } else if (t === "hash") {

                                    var n = redisAdapter.getHKn(cinx,
                                                                lview.curInx,
                                                                name)

                                    idkeymitm.text = name + "(" + n + ")"

                                    res = redisAdapter.getHKeys(cinx,
                                                                lview.curInx,
                                                                name, "", 0, 30)

                                    if (res.length > 0) {
                                        var cur = parseInt(res[0])
                                        lview.tCursor = cur

                                        newHashKeys(cinx, lview.curInx,
                                                    name, res)
                                    }
                                } else if (t === "set") {

                                    n = redisAdapter.getSKn(cinx,
                                                            lview.curInx, name)
                                    idkeymitm.text = name + "(" + n + ")"

                                    res = redisAdapter.getSKeys(cinx,
                                                                lview.curInx,
                                                                name, "", 0, 30)

                                    if (res.length > 0) {
                                        cur = parseInt(res[0])
                                        lview.tCursor = cur
                                        var li = []
                                        for (var i = 1; i < res.length; i++) {
                                            li.push(res[i])
                                        }

                                        newSetKeys(cinx, lview.curInx,
                                                   name, li, cur)
                                    }
                                } else if (t === "list") {

                                    n = redisAdapter.getLKn(cinx,
                                                            lview.curInx, name)
                                    idkeymitm.text = name + "(" + n + ")"

                                    res = redisAdapter.getLKeys(cinx,
                                                                lview.curInx,
                                                                name, 0, 29)

                                    newListKeys(cinx, lview.curInx, name, res,
                                                res.length, n)
                                }

                                if (progress != null) {
                                    progress.fin()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
