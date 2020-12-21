import QtQuick 2.0
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import io.junsie.mredis 1.0
import QtQuick.Dialogs 1.2

Window {
    id: idaddList

    property string stitle: "添加连接"

    property var em: TextInput.Password
    property string msg: ""
    property string msgColor: Material.foreground

    width: 640
    height: 480
    color: Material.backgroundColor
    title: stitle
    modality: Qt.ApplicationModal

    signal testRedis

    RedisMeta {
        id: redisMeta
    }

    Component.onCompleted: {

        inName.text = ""
        inHost.text = ""
        inPort.text = ""
        inPass.text = ""
    }

    function initData(name, host, port, pass, uuid) {
        inName.text = name
        inHost.text = host
        inPort.text = port
        inPass.text = pass
        redisMeta.uuid = uuid
        stitle = qsTr("修改连接")
    }

    function clear() {
        inName.text = ""
        inHost.text = ""
        inPort.text = ""
        inPass.text = ""
        redisMeta.uuid = ""
    }

    Popup {
        id: popup
        x: 0
        y: 0
        width: parent.width
        height: 40
        modal: false
        focus: false
        closePolicy: Popup.CloseOnPressOutside
        contentItem: Text {
            text: msg
            color: msgColor
        }
    }

    GridLayout {
        anchors.fill: parent
        anchors.leftMargin: 50
        anchors.rightMargin: 50
        anchors.topMargin: 30

        columnSpacing: 10
        rowSpacing: 10

        columns: 2
        rows: 5
        Text {
            id: name
            text: qsTr("名称")
            color: Material.foreground
        }

        TextField {
            id: inName
            Layout.fillWidth: true
            selectByMouse: true
        }

        Text {
            text: qsTr("主机")
            color: Material.foreground
        }

        TextField {
            id: inHost
            Layout.fillWidth: true
            selectByMouse: true
        }

        Text {
            text: qsTr("端口")
            color: Material.foreground
        }

        TextField {
            id: inPort
            Layout.fillWidth: true
            selectByMouse: true
        }

        Text {
            text: qsTr("密码")
            color: Material.foreground
        }

        Item {
            Layout.fillWidth: true
            height: 40

            TextField {
                anchors.left: parent.left
                anchors.right: checkBox.left
                height: 40
                echoMode: checkBox.checked ? TextInput.Normal : TextInput.Password
                id: inPass
                Layout.fillWidth: true
                selectByMouse: true
            }

            CheckBox {
                id: checkBox
                anchors.right: parent.right
                text: qsTr("显示密码")
            }
        }

        Item {
            height: 10
        }

        Item {
            height: 10
        }

        Button {
            text: "测试连接"
            onClicked: {
                if (validTest()) {
                    var res = redisAdapter.testRedis(redisMeta)
                    if (res) {
                        msg = qsTr("连接成功！")
                        msgColor = "green"
                        popup.open()
                    } else {
                        msg = qsTr("连接失败")
                        msgColor = "red"
                        popup.open()
                    }
                }
            }
        }

        Button {
            //anchors.right: parent.right
            Layout.alignment: Qt.AlignRight
            text: stitle
            onClicked: {
                if (validTest("add")) {
                    var res = redisAdapter.testRedis(redisMeta) //先测试连接是否通畅
                    if (false === res) {
                        msg = qsTr("连接失败")
                        msgColor = "red"
                        popup.open()
                    } else {

                        var ret = redisAdapter.newRedis(redisMeta)

                        if (ret !== "") {
                            msg = ret
                            msgColor = "red"
                            popup.open()
                        } else {
                            idaddList.close()
                        }
                    }
                }
            }
        }
    }

    function validTest(t) {
        redisMeta.name = inName.text
        redisMeta.host = inHost.text
        redisMeta.port = inPort.text
        redisMeta.pass = inPass.text

        if (inHost.text == "") {
            msg = qsTr("请输入主机名")
            msgColor = "red"
            popup.open()
            return false
        } else if (inPort.text == "") {
            msg = qsTr("请输入端口号")
            msgColor = "red"
            popup.open()
            return false
        } else {

            if (t === "add") {
                if (inName.text == "") {
                    msg = qsTr("请输入数据库名")
                    msgColor = "red"
                    popup.open()
                    return false
                }
            }
            return true
        }
    }
}
