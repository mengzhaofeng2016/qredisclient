import QtQuick 2.15
import QtQuick.Window 2.2
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml.Models 2.0
import QtQuick.Layouts 1.1

Item {
    id: jsonView

    //    width: 400
    //    height: 400
    property var jsdata: ""
    property var msg: ""
    property var msgColor: "red"
    property var jw: 640
    property var jh: 480

    property int cinx: 0
    property int cdb: 0
    property string table: ""
    property string tkey: ""
    property string tvalue: ""
    property string cType: "string"

    property int linx: 0

    property bool seted:false


    signal addSetKeytoJsonView(var key)
    signal updateListKeytfromJsonView(var cinx, var cdb, var table, var linx, var value)
    signal updateDbList(var inx, var db, var table, var tkey, var value, var cType)

    function setHigher(){
        if(seted == false)
        redisAdapter.setHigher(idjsonedit.textDocument)

        seted = true
    }

    function newQueryValue(cinx, cdb, table, vv) {

        jsonView.cType = "string"
        jsonView.cinx = cinx
        jsonView.cdb = cdb
        jsonView.table = table

        setHigher()

        var str = redisAdapter.formatJson(vv)

        if (str === "~~error~~!!~~") {
            idjsonedit.clear()
            idjsonedit.append(vv)
        } else {
            //idjsonedit.text = str
            idjsonedit.clear()
            idjsonedit.append(str)

            //redisAdapter.setHigher(idjsonedit.textDocument)
            idtableinput.text = table
            controlpan.visible = true
        }




        //idjsonedit.selectAll()

    }

    function newSetValue(cinx, cdb, table, key) {
        controlpan.visible = true
        jsonView.cType = "set"
        jsonView.cinx = cinx
        jsonView.cdb = cdb
        jsonView.table = table
        jsonView.tkey = key

        setHigher()

        var str = redisAdapter.formatJson(key)

        if (str === "~~error~~!!~~") {

            idjsonedit.clear()
            idjsonedit.append(key)
            controlpan.visible = true
            idtableinput.text = table
        } else {
            idjsonedit.clear()
            idjsonedit.append(str)

            //redisAdapter.setHigher(idjsonedit.textDocument)
            idtableinput.text = table
            controlpan.visible = true
        }

    }

    function newListValue(cinx, cdb, table, value, linx) {

        setHigher()
        controlpan.visible = true
        jsonView.cType = "list"
        jsonView.cinx = cinx
        jsonView.cdb = cdb
        jsonView.table = table
        jsonView.tvalue = value
        jsonView.linx = linx

        var str = redisAdapter.formatJson(value)

        if (str === "~~error~~!!~~") {

            idjsonedit.clear()
            idjsonedit.append(value)
            controlpan.visible = true
            idtableinput.text = table
        } else {
            idjsonedit.clear()
            idjsonedit.append(str)

            // redisAdapter.setHigher(idjsonedit.textDocument)
            idtableinput.text = table
            controlpan.visible = true
        }

       // redisAdapter.setHigher(idjsonedit.textDocument)
    }

    function newQueryValueEx(cinx, cdb, table, ky, vv) {
        jsonView.cinx = cinx
        jsonView.cdb = cdb
        jsonView.table = table
        jsonView.tkey = ky
        jsonView.cType = "hash"
        setHigher()

        var str = redisAdapter.formatJson(vv)

        if (str === "~~error~~!!~~") {
            idjsonedit.clear()
            idjsonedit.append(vv)
        } else {

            idjsonedit.clear()
            idjsonedit.append(str)

            //  redisAdapter.setHigher(idjsonedit.textDocument)
            idtableinput.text = table
            idkeyinput.text = tkey
            controlpan.visible = true
        }

    }

    function clearView() {
        idjsonedit.text = ""
    }

    Component.onCompleted: {
        controlpan.visible = false

    }

    Popup {
        id: jpopup
        x: parent.width - jpopup.width
        y: 80
        width: parent.width / 3

        height: 40
        modal: false
        focus: false
        closePolicy: Popup.CloseOnPressOutside
        contentItem: Text {
            text: msg
            color: msgColor
        }

        Timer {
            id: idey
            interval: 2000
            running: false
            repeat: false
            onTriggered: {
                jpopup.close()
            }
        }

        function popen() {
            jpopup.open()
            idey.start()
        }
    }

    Item {
        id: controlpan
        x: 0
        y: 0
        width: parent.width - 24
        height: 60

        Row {

            width: parent.width
            height: 60
            bottomPadding: 10
            spacing: 10
            Text {
                id: tabletext
                width: 100
                text: cType.toUpperCase() + qsTr("表")
                height: 60
                color: Material.foreground
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignBottom
                bottomPadding: 14
                rightPadding: 20
            }
            TextField {
                id: idtableinput
                anchors.bottom: parent.bottom
                width: parent.width / 5
                height: 40
                selectByMouse: true
                verticalAlignment: Text.AlignVCenter
            }

            Button {
                y: 10
                text: qsTr("更新表名")

                onClicked: {
                    if (idtableinput.text.trim() != jsonView.table) {
                        if (redisAdapter.remKey(cinx, cdb, jsonView.table,
                                                idtableinput.text)) {
                            jsonView.msg = "Info: 更新成功"
                            jsonView.msgColor = "#aaff33"
                            jpopup.popen()
                            updateDbList(cinx, cdb, table, tkey, tvalue, cType)
                        } else {
                            jsonView.msg = "Info: 更新失败"
                            jsonView.msgColor = "#ff0033"
                            jpopup.popen()
                        }
                    }
                }
            }

            Text {
                id: keytext
                visible: cType === "hash"
                width: 60
                text: qsTr("键")
                height: 60
                color: Material.foreground
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignBottom
                bottomPadding: 14
                rightPadding: 20
            }
            TextField {
                visible: cType === "hash"
                id: idkeyinput
                anchors.bottom: parent.bottom
                width: parent.width / 5
                height: 40
                selectByMouse: true
                readOnly: true
                verticalAlignment: Text.AlignVCenter
            }

            //            Button {
            //                y: 10
            //                visible: cType === "hash"
            //                text: "更新键值"
            //            }
        }

        Button {
            anchors.right: parent.right
            text: "保存"
            anchors.bottom: parent.bottom

            onClicked: {

                if (cType === "string") {

                    if (redisAdapter.setStringKey(jsonView.cinx, jsonView.cdb,
                                                  jsonView.table,
                                                  idjsonedit.text)) {
                        jsonView.msg = "Info: 更新成功"
                        jsonView.msgColor = "#aaff33"
                        jpopup.popen()
                    } else {
                        jsonView.msg = "Info: 更新失败"
                        jsonView.msgColor = "#aaff33"
                        jpopup.popen()
                    }
                } else if (cType === "hash") {

                    if (redisAdapter.setHashKey(cinx, cdb, jsonView.table,
                                                jsonView.tkey,
                                                idjsonedit.text)) {
                        jsonView.msg = "Info: 更新成功"
                        jsonView.msgColor = "#aaff33"
                        jpopup.popen()
                    } else {
                        jsonView.msg = "Info: 更新失败"
                        jsonView.msgColor = "#aaff33"
                        jpopup.popen()
                    }
                } else if (cType == "set") {
                    if (redisAdapter.setSetKey(cinx, cdb, jsonView.table,
                                               idjsonedit.text)) {
                        jsonView.msg = "Info: 更新成功"
                        jsonView.msgColor = "#aaff33"
                        jpopup.popen()

                        addSetKeytoJsonView(idjsonedit.text)
                    } else {
                        jsonView.msg = "Info: 更新失败"
                        jsonView.msgColor = "#aaff33"
                        jpopup.popen()
                    }
                } else if (cType == "list") {
                    if (redisAdapter.setListKey(cinx, cdb, jsonView.table,
                                                jsonView.linx,
                                                idjsonedit.text)) {
                        jsonView.msg = "Info: 更新成功"
                        jsonView.msgColor = "#aaff33"
                        jpopup.popen()

                        updateListKeytfromJsonView(cinx, cdb, jsonView.table,
                                                   jsonView.linx,
                                                   idjsonedit.text)
                    } else {
                        jsonView.msg = "Info: 更新失败"
                        jsonView.msgColor = "#aaff33"
                        jpopup.popen()
                    }
                }
            }
        }

        Rectangle {
            x: 0
            anchors.bottom: controlpan.bottom
            width: parent.width
            height: 2
            color: "#AA333333"
        }
    }

    ScrollView {
        x: 0
        y: controlpan.visible ? controlpan.height : 0
        width: jw
        height: jh - 60
        clip: true

        TextEdit {
            id: idjsonedit
            x: 0
            width: jw
            //                height: 640
            color: Material.foreground
            selectionColor: Material.backgroundDimColor
            selectByMouse: true
            text: jsdata
            font.pointSize: 9
            selectByKeyboard: true
            focus: true
            Keys.enabled: true
            tabStopDistance: 32
            wrapMode: TextEdit.Wrap

            leftPadding: 33
            topPadding: 6

            property real lineH: 0

            Rectangle {
                x: 0
                y: 0
                width: 30
                height: idjsonedit.height + 10
                color: "#AA333333"

                Column {
                    id: idslinen
                    width: parent.width
                    topPadding: 6
                    Repeater {
                        model: idjsonedit.lineCount + 1
                        Text {

                            width: parent.width
                            height: idjsonedit.lineH == 0 ? 17 : idjsonedit.lineH
                            text: "" + (index + 1)
                            color: "green"
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: 13
                            font.weight: Font.ExtraBold
                        }
                    }
                }
            }

            Component.onCompleted: {
                idslinen.visible = true
                redisAdapter.setHigher(idjsonedit.textDocument)

                idjsonedit.lineH = idjsonedit.cursorRectangle.height
            }

            Keys.onPressed: {

                if ((event.modifiers & Qt.ControlModifier)
                        && (event.key === Qt.Key_S)) {
                    if (idjsonedit.text !== "") {

                        var str = redisAdapter.formatJson(idjsonedit.text)

                        idjsonedit.text = str

                        msg = "Info: 已验证，JSON有效"
                        msgColor = "#aaff33"
                        jpopup.popen()
                    }
                }
            }
        }
    }
}
