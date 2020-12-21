import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls 2.12

Window {
    id: root
    width: Screen.width
    height: Screen.height
    minimumHeight: 768
    minimumWidth: 1024
    visible: true
    title: qsTr("Redis Client 1.0")
    color: Material.backgroundColor

    property var cdata: [{
            "name": "hello",
            "type": "string",
            "value": "world"
        }]

    Component.onCompleted: {
        idredisMenu.newQueryValue.connect(root.newQueryValue)
        idredisMenu.newHashKeys.connect(root.newHashKeys)
        keylistView.newQueryValue.connect(root.newQueryValueEx)
        idredisMenu.newSetKeys.connect(root.newSetKeys)
        keylistView.newSetValue.connect(root.newSetValue)
        idredisMenu.newListKeys.connect(root.newListKeys)
        keylistView.newListValue.connect(root.newListValue)
        keylistView.showAddKrec.connect(root.showAddKrec)
        idredisMenu.showAddKrec.connect(root.showAddKrec)
        addkrec.updateDbList.connect(root.updateDbList)
        jsonView.addSetKeytoJsonView.connect(root.addSetKeytoJsonView)
        addkrec.addSetKeytoJsonView.connect(root.addSetKeytoJsonView)
        jsonView.updateListKeytfromJsonView.connect(
                    root.updateListKeytfromJsonView)

        jsonView.updateDbList.connect(root.updateDbList)
    }

    function addSetKeytoJsonView(key) {
        keylistView.addSetKeytoJsonView(key)
    }

    function updateListKeytfromJsonView(cinx, cdb, table, linx, value) {
        keylistView.updateListKeytfromJsonView(cinx, cdb, table, linx, value)
    }

    function newQueryValue(cinx, cdb, table, vv) {
        keylistView.visible = false

        print(table)
        jsonView.newQueryValue(cinx, cdb, table, vv)

        idprogress.start()
    }

    function newQueryValueEx(cinx, cdb, table, key, vv) {
        jsonView.newQueryValueEx(cinx, cdb, table, key, vv)
    }

    function newHashKeys(cinx, db, table, keys) {

        keylistView.visible = true
        keylistView.cinx = cinx
        keylistView.cdb = db
        keylistView.table = table

        keylistView.newHashKeys(keys)

        jsonView.clearView()
    }

    function newSetKeys(cinx, db, table, keys, cursor) {
        keylistView.newSetKeys(cinx, db, table, keys, cursor)
    }

    function newSetValue(cinx, cdb, table, key) {
        jsonView.newSetValue(cinx, cdb, table, key)
    }

    function newListKeys(cinx, db, table, keys, stop, total) {
        keylistView.newListKeys(cinx, db, table, keys, stop, total)
    }

    function newListValue(cinx, cdb, table, value, linx) {
        print("xxxxxxxxxxx " + linx)
        jsonView.newListValue(cinx, cdb, table, value, linx)
    }

    function showAddKrec(cinx, cdb, table, ctype) {
        addkrec.cinx = cinx
        addkrec.cdb = cdb
        addkrec.table = table
        addkrec.cType = ctype
        addkrec.ctitle = idredisMenu.getCTitle()

        if (ctype === "string") {
            addkrec.cboxInx = 0
        } else if (ctype === "hash") {
            addkrec.cboxInx = 1
        } else if (ctype === "set") {
            addkrec.cboxInx = 2
        } else if (ctype === "list") {
            addkrec.cboxInx = 3
        }

        addkrec.show()
    }

    function updateDbList(inx, db, table, tkey, value, cType) {
        idredisMenu.updateDbList(inx, db, table, tkey, value, cType)
    }

    AddKRecord {
        id: addkrec
        visible: false
    }

    RedisList {
        id: idredisMenu
        progress: idprogress
    }

    Rectangle {
        id: splitLine
        anchors.left: idredisMenu.right

        height: parent.height
        width: 2
        color: "#AA333333"
    }

    KeyListView {
        id: keylistView
        visible: false
        width: 288
        height: root.height
        anchors.left: splitLine.right
        kw: 286
        kh: root.height
        progress: idprogress
        Rectangle {
            id: splitLine1
            anchors.right: keylistView.right
            height: parent.height
            width: 2
            color: "#AA333333"
        }
    }

    JsonView {
        id: jsonView
        visible: true
        anchors.left: keylistView.visible ? keylistView.right : splitLine.right
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        jw: root.width - idredisMenu.width
        jh: root.height
        //        width: 300
        //        height: 400
        //        x: 300
        //        y: 200
        // data: cdata
    }

    RedisProgress {
        pw: root.width
        ph: 1
        x: 0
        y: 0
        visible: false
        id: idprogress
    }
}
