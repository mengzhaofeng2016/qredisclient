import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Dialogs 1.2
import QtQml.Models 2.12

Window {
    id: addkrec
    width: 768
    height: 640
    color: Material.backgroundColor
    title: ctitle
    modality: Qt.ApplicationModal

    property int cinx: -1
    property int cdb: -1
    property string table: ""
    property int jw: 768
    property int jh: 640

    property var jsdata: ""
    property var msg: "sss"
    property var msgColor: "red"

    property var cType: "string"
    property string lPat: "LPUSH"
    property var ctitle: ""
    property int cboxInx: 0

    signal updateDbList(var inx, var db, var table, var tkey, var value, var cType)
    signal addSetKeytoJsonView(var key)

    ListModel {
        id: idRss

        ListElement {
            name: "string"
        }

        ListElement {
            name: "hash"
        }

        ListElement {
            name: "set"
        }

        ListElement {
            name: "list"
        }
    }

    GridLayout {
        x: 50
        y: 10
        width: jw - 100
        height: 180

        columnSpacing: 10
        rowSpacing: 10

        id: pglay

        columns: 2
        rows: 3
        Text {

            text: qsTr("数据库索引")
            color: Material.foreground
        }

        Text {
            text: "" + cdb
            color: "yellow"
            font.pixelSize: 24
        }
        Text {
            id: name
            text: qsTr("键值")
            color: Material.foreground
        }

        TextField {
            id: inName
            Layout.fillWidth: true
            selectByMouse: true
            text: cType != "string" ? table : ""
        }

        Text {
            text: qsTr("类型")
            color: Material.foreground
        }

        ComboBox {
            id: redisList
            Layout.fillWidth: true
            model: idRss

            currentIndex: cboxInx

            onCurrentIndexChanged: {

                cType = idRss.get(currentIndex).name

                pglay.update()
            }
        }

        Text {
            visible: cType == "hash"
            text: qsTr("哈希键")
            color: Material.foreground
        }

        TextField {
            visible: cType === "hash"
            id: inValue
            Layout.fillWidth: true
            selectByMouse: true
        }

        RadioButton {
            visible: cType == "list"
            text: "表头"
            checked: true
            onClicked: {
                lPat = "LPUSH"
            }
        }

        RadioButton {
            visible: cType == "list"
            text: "表尾"
            onClicked: {
                lPat = "RPUSH"
            }
        }
    }

    Popup {
        id: sjpopop
        x: 0
        y: 0
        width: addkrec.width
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
            interval: 1000
            running: false
            repeat: false
            onTriggered: {
                sjpopop.close()
            }
        }

        function popen() {
            sjpopop.open()
            idey.start()
        }
    }

    Button {
        text: "取消"
        anchors.bottom: idconfirm.bottom
        anchors.right: idconfirm.left
        anchors.rightMargin: 24
        onClicked: {
            addkrec.close()
        }
    }

    Button {
        id: idconfirm
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 24
        anchors.rightMargin: 50
        text: "添加"

        onClicked: {
            if (cinx == -1 || cdb == -1) {
                msg = "Error:未选择当前数据库"
                msgColor = "#ffaa33"
                sjpopop.open()
                return
            } else if (inName.text.trim() == "") {
                msg = "Error: 键值不能为空"
                msgColor = "#ffaa33"
                sjpopop.open()
                return
            } else if (aidjsonedit.text.trim() == "") {
                msg = "Error: 记录不能为空"
                msgColor = "#ffaa33"
                sjpopop.open()
                return
            } else if (cType == "hash") {
                if (inValue.text.trim() == "") {
                    msg = "Error: 哈希键不能为空"
                    msgColor = "#ffaa33"
                    sjpopop.open()
                    return
                }
            }
            if (cType === "string") {
                if (redisAdapter.setStringKey(cinx, cdb, inName.text,
                                              aidjsonedit.text)) {
                    addkrec.msg = "Info: 添加成功"
                    addkrec.msgColor = "#aaff33"
                    sjpopop.popen()

                    updateDbList(cinx, cdb, inName.text, "",
                                 aidjsonedit.text, cType)
                    addkrec.close()
                } else {
                    addkrec.msg = "Info: 添加失败"
                    addkrec.msgColor = "#aaff33"
                    sjpopop.popen()
                }
            } else if (cType === "hash") {
                if (redisAdapter.setHashKey(cinx, cdb, inName.text,
                                            inValue.text, aidjsonedit.text)) {
                    addkrec.msg = "Info: 添加成功"
                    addkrec.msgColor = "#aaff33"
                    sjpopop.popen()

                    updateDbList(cinx, cdb, inName.text, inValue.text,
                                 aidjsonedit.text, cType)
                    addkrec.close()
                } else {
                    addkrec.msg = "Info: 添加失败"
                    addkrec.msgColor = "#aaff33"
                    sjpopop.popen()
                }
            } else if (cType == "set") {
                if (redisAdapter.setSetKey(cinx, cdb, inName.text,
                                           aidjsonedit.text)) {
                    addkrec.msg = "Info: 添加成功"
                    addkrec.msgColor = "#aaff33"
                    sjpopop.popen()

                    addSetKeytoJsonView(aidjsonedit.text)
                    updateDbList(cinx, cdb, inName.text, "",
                                 aidjsonedit.text, cType)
                    addkrec.close()
                } else {
                    addkrec.msg = "Info: 添加失败"
                    addkrec.msgColor = "#aaff33"
                    sjpopop.popen()
                }
            } else if (cType == "list") {

                if (redisAdapter.pushListKey(cinx, cdb, inName.text,
                                             aidjsonedit.text, lPat)) {
                    addkrec.msg = "Info: 添加成功"
                    addkrec.msgColor = "#aaff33"
                    sjpopop.popen()

                    updateDbList(cinx, cdb, inName.text, "",
                                 aidjsonedit.text, cType)
                    addkrec.close()
                } else {
                    addkrec.msg = "Info: 添加失败"
                    addkrec.msgColor = "#aaff33"
                    sjpopop.popen()
                }
            }
        }
    }

    Rectangle {
        x: 50
        y: 220
        width: jw - 100
        height: 320
        color: "#00000000"
        border.color: "grey"
        ScrollView {
            anchors.fill: parent
            anchors.margins: 1
            clip: true
            id: sv

            TextEdit {
                id: aidjsonedit
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
                    height: aidjsonedit.height + 10
                    color: "#AA333333"

                    Column {
                        id: idslinen
                        width: parent.width
                        topPadding: 6
                        Repeater {
                            model: aidjsonedit.lineCount + 1
                            Text {
                                width: parent.width
                                height: aidjsonedit.lineH === 0 ? 17 : aidjsonedit.lineH
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
                    redisAdapter.setHigher(aidjsonedit.textDocument)

                    aidjsonedit.lineH = aidjsonedit.cursorRectangle.height
                }

                Keys.onPressed: {

                    if ((event.modifiers & Qt.ControlModifier)
                            && (event.key === Qt.Key_S)) {
                        if (aidjsonedit.text !== "") {

                            var str = redisAdapter.formatJson(aidjsonedit.text)

                            aidjsonedit.text = str
                        }
                    }
                }
            }
        }
    }
}
