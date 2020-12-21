import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQml.Models 2.12
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

Item {
    id: keylistView

    property real kw: 256
    property real kh: parent.height
    property int cinx: 0
    property int cdb: 0
    property string table: ""
    property int tCursor: 0
    property int tstart: 0
    property var progress: null
    property string cType: "hash"

    property int cPage: 1

    property var ckeys: null
    property var cvalues: null

    property var cCurMap: null

    property bool hasLast: false
    property bool hasNext: true

    property int lTotal: 0

    property string delkey: ""

    signal newQueryValue(var cinx, var cdb, var table, var key, string res)
    signal newSetValue(var cinx, var cdb, var table, var key)
    signal newListValue(var cinx, var cdb, var table, var value, var linx)
    signal showAddKrec(var cinx, var cdb, var table, var cType)

    function addSetKeytoJsonView(key) {
        if (cType == "set") {
            if (ckeys == null) {
                ckeys = []
            }

            ckeys.push(key)
            flushKeys(ckeys)
        }
    }

    function updateListKeytfromJsonView(cinx, cdb, table, linx, value) {
        if (cType == "list") {
            var i = linx - tstart
            if (i >= 0 && i < ckeys.length) {
                ckeys[i] = value
            }

            flushKeys(ckeys)
        }
    }

    function newHashKeys(keys) {
        cType = "hash"
        cPage = 1

        initHashKeys(keys)

        if (keys.length > 1) {
            tCursor = parseInt(keys[0])

            if (cCurMap == null)
                cCurMap = []
            cCurMap.push(keys)
        }
        keylistView.visible = true
    }

    function initHashKeys(keys) {

        ckeys = []
        cvalues = []
        tCursor = parseInt(keys[0])

        if (tCursor == 0) {
            hasNext = false
        }

        for (var i = 1; i < keys.length; i++) {
            if (i % 2 == 1) {
                ckeys.push(keys[i])
            } else {
                cvalues.push(keys[i])
            }
        }

        flushKeys(ckeys)
    }

    function flushKeys(keys) {
        idkeym.clear()
        var n = keys.length
        for (var i = 0; i < n; i++) {
            idkeym.append({
                              "name": keys[i],
                              "inx": i
                          })
        }

        ckeys = keys

        idktips.text = "记录： " + keys.length + "条"

        if (tCursor == 0) {
            hasNext = false
        }
    }

    function newSetKeys(cinx, db, table, keys, cursor) {
        // keylistView.newSetKeys(cinx, db, table, keys, cursor)
        cType = "set"

        ckeys = keys
        keylistView.cinx = cinx
        keylistView.cdb = db
        keylistView.table = table
        keylistView.tCursor = cursor
        flushKeys(keys)
        keylistView.visible = true
    }

    function newListKeys(cinx, db, table, keys, stop, total) {
        // keylistView.newSetKeys(cinx, db, table, keys, cursor)
        cType = "list"

        lTotal = total
        ckeys = keys
        keylistView.cinx = cinx
        keylistView.cdb = db
        keylistView.table = table
        keylistView.tCursor = stop
        buildListkeys()
        keylistView.visible = true
    }

    function buildListkeys() {
        var n = ckeys.length
        idkeym.clear()
        for (var i = 0; i < n; i++) {
            idkeym.append({
                              "name": ckeys[i],
                              "inx": i,
                              "value": ckeys[i]
                          })
        }

        idktips.text = "记录： " + ckeys.length + "条"

        hasLast = false

        if (tCursor < lTotal) {
            hasNext = true
        } else {
            hasNext = false
        }
    }

    ListModel {
        id: idkeym
    }

    Button {
        x: 10
        y: 10
        id: idaddbtn
        width: parent.width - 20
        height: 48
        text: "+添加记录"

        onClicked: {
            showAddKrec(cinx, cdb, table, cType)
        }
    }

    Item {
        x: 10
        y: 64
        visible: cType != "list"
        width: keylistView.width - 20
        height: 60
        TextField {
            id: keySearch
            width: parent.width
            height: 40
            anchors.bottom: parent.bottom
            placeholderText: "搜索"
            selectByMouse: true
            onEditingFinished: {

                cCurMap = []
                hasLast = false

                if (cType == "hash") {
                    var res = redisAdapter.getHKeys(cinx, cdb, table,
                                                    keySearch.text, 0, 100)

                    cPage = 1

                    if (res.length > 1) {
                        tCursor = parseInt(res[0])

                        cCurMap = []
                        cCurMap.push(res)

                        initHashKeys(res)
                    }
                } else if (cType == "set") {
                    var res = redisAdapter.getSKeys(cinx, cdb, table,
                                                    keySearch.text, 0, 100)
                    if (res.length > 1) {
                        tCursor = parseInt(res[0])

                        if (cCurMap == null)
                            cCurMap = []
                        cCurMap.push(res)

                        var keys = []
                        for (var i = 1; i < res.length; i++) {
                            keys.push(res[i])
                        }
                        flushKeys(keys)
                    }
                }

                //flushKeys(nkeys)
            }
        }
    }

    Item {
        x: 10
        y: 128
        width: keylistView.width - 20
        height: 46
        Text {
            id: idktips

            anchors.bottom: btline.top
            anchors.bottomMargin: 10
            text: qsTr("记录")
            color: Material.foreground
            verticalAlignment: Text.AlignVCenter
        }

        Button {
            id: lastPage
            anchors.right: idpage.left
            anchors.bottom: btline.top
            anchors.bottomMargin: 5
            height: 36
            text: "上一页"
            enabled: hasLast
            font.pixelSize: 10
            onClicked: {
                var res = cCurMap[cPage - 2]

                var lres = cCurMap[cPage - 1]
                initHashKeys(res)
                cPage -= 1

                if (cPage == 1) {
                    hasLast = false
                }
                hasNext = true
            }
        }

        Text {
            id: idpage
            anchors.right: nextPage.left
            anchors.bottom: nextPage.bottom
            width: 36
            height: 36
            text: "" + cPage
            color: Material.foreground
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Button {
            id: nextPage
            anchors.right: parent.right
            anchors.bottom: btline.top
            anchors.bottomMargin: 5
            height: 36
            text: "下一页"
            enabled: hasNext
            font.pixelSize: 10

            onClicked: {
                if (cCurMap != null && cPage + 1 <= cCurMap.length) {
                    var res = cCurMap[cPage]
                    cPage += 1
                    initHashKeys(res)
                } else {
                    var cn = 30
                    if (keySearch.text != "") {
                        cn = 100
                    } else {
                        cn = 30
                    }

                    if (cType == "hash") {
                        var res = redisAdapter.getHKeys(cinx, cdb, table,
                                                        keySearch.text,
                                                        tCursor, cn)

                        if (res.length > 1) {
                            tCursor = parseInt(res[0])

                            cPage += 1

                            if (cCurMap == null)
                                cCurMap = []
                            cCurMap.push(res)
                            initHashKeys(res)
                        }
                    } else if (cType == "set") {

                        var res = redisAdapter.getSKeys(cinx, cdb, table,
                                                        keySearch.text,
                                                        tCursor, cn)
                        if (res.length > 1) {
                            tCursor = parseInt(res[0])

                            cPage += 1

                            if (cCurMap == null)
                                cCurMap = []
                            cCurMap.push(res)

                            var keys = []
                            for (var i = 1; i < res.length; i++) {
                                keys.push(res[i])
                            }

                            flushKeys(keys)
                        }
                    } else if (cType == "list") {

                        var res = redisAdapter.getLKeys(cinx, cdb, table,
                                                        tCursor, 30)
                        if (res.length > 0) {
                            tstart = tCursor
                            cPage += 1
                            tCursor += res.length
                            if (cCurMap == null)
                                cCurMap = []
                            cCurMap.push(res)

                            ckeys = res
                            buildListkeys()
                        } else {
                            hasNext = false
                        }
                    }
                }

                hasLast = true
            }
        }

        Rectangle {
            id: btline
            width: parent.width
            height: 1
            color: "#66AAAAAA"
            anchors.bottom: parent.bottom
        }
    }

    //    Item {
    //        x: 10
    //        y: 10
    //        width: keylistView.width - 20
    //        height: 46
    //        anchors.top: idklist.bottom
    //        Text {
    //            id: idktotal

    //            anchors.bottom: ztline.top
    //            anchors.bottomMargin: 10
    //            text: qsTr("总计")
    //            color: Material.foreground
    //            verticalAlignment: Text.AlignVCenter
    //        }

    //        Rectangle {
    //            id: ztline
    //            width: parent.width
    //            height: 1
    //            color: "#66AAAAAA"
    //            anchors.bottom: parent.bottom
    //        }
    //    }
    Window {
        id: idellg
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
                    if (cType == "hash") {
                        if (redisAdapter.delHashKey(cinx, cdb, table, delkey)) {
                            var n = ckeys.length
                            var nkeys = []
                            for (var i = 0; i < n; i++) {
                                if (ckeys[i] === delkey) {

                                } else {
                                    nkeys.push(ckeys[i])
                                }
                            }

                            flushKeys(nkeys)

                            idellg.close()
                        } else {
                            shpop.open()
                        }
                    } else if (cType == "set") {
                        if (redisAdapter.delSetKey(cinx, cdb, table, delkey)) {
                            n = ckeys.length
                            nkeys = []
                            for (var i = 0; i < n; i++) {
                                if (ckeys[i] === delkey) {

                                } else {
                                    nkeys.push(ckeys[i])
                                }
                            }

                            flushKeys(nkeys)

                            idellg.close()
                        } else {
                            shpop.open()
                        }
                    } else if (cType == "list") {
                        if (redisAdapter.delListKey(cinx, cdb, table, delkey)) {
                            n = ckeys.length
                            nkeys = []
                            for (var i = 0; i < n; i++) {
                                if (ckeys[i] === delkey) {

                                } else {
                                    nkeys.push(ckeys[i])
                                }
                            }

                            flushKeys(nkeys)

                            idellg.close()
                        } else {
                            shpop.open()
                        }
                    }
                }
            }
        }
    }

    Menu {
        id: inkeyListMenu
        MenuItem {
            text: "删除"
            onClicked: {
                shpop.close()
                idellg.show()
            }
        }
    }

    //    ScrollView {
    //        x: 0
    //        y: 180
    //        width: kw
    //        height: kh - 120
    //        clip: true
    ListView {
        id: idklist
        y: 180
        width: parent.width
        height: kh - 180
        model: idkeym
        clip: true
        delegate: Item {
            height: 36
            width: kw
            Rectangle {
                color: "#ff333333"
                id: lnum
                x: 0
                y: 0
                height: 36
                width: 48
                Text {
                    x: 0
                    y: 0
                    height: 36
                    width: 48
                    font.pixelSize: 14
                    font.weight: Font.ExtraBold
                    text: "" + index
                    color: "yellow"

                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
            ItemDelegate {
                anchors.left: lnum.right
                text: name
                height: 36
                width: kw - 48
                font: {
                    color: "grey"
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {

                        if (mouse.button === Qt.RightButton) {
                            if (cType == "list") {
                                delkey = value
                            } else {
                                delkey = name
                            }
                            inkeyListMenu.popup()
                        } else if (mouse.button === Qt.LeftButton) {
                            if (keylistView.cType == "hash") {
                                if (progress != null) {
                                    progress.start()
                                }

                                newQueryValue(cinx, cdb, table, name,
                                              cvalues[index])
                                if (progress != null) {
                                    progress.fin()
                                }
                            } else if (keylistView.cType == "set") {
                                newSetValue(cinx, cdb, table, name)
                            } else if (keylistView.cType == "list") {


                                newListValue(cinx, cdb, table, value,
                                             tstart + inx)
                            }
                        }
                    }
                }
            }
        }
    }
    //    }
}
