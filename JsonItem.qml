import QtQuick 2.0
import QtQuick.Layouts 1.1

import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12

Item {
    id: jitem
    property var idata: {
        "name": "sss",
        "type": "string",
        "value": ""
    }

    Component.onCompleted: {
        print(idata.name)
    }

    height: 24

    RowLayout {
        anchors.fill: parent
        spacing: 1

        Item {

            Layout.minimumWidth: 100
            height: parent.height

            TextInput {
                id: idan
                height: parent.height
                anchors.right: parent.right
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                Layout.fillWidth: true
                selectByMouse: true

                readOnly: true
                text: jitem.idata.name
                color: Material.foreground
                onFocusChanged: {
                    idan.readOnly = !idan.readOnly
                }
            }
        }

        Item {
            width: 10
            height: parent.height
            Text {
                anchors.centerIn: parent
                id: name
                text: qsTr(":")
                color: Material.foreground
            }
        }

        Item {
            Layout.fillWidth: true
            height: parent.height
            TextInput {

                id: tid
                visible: jitem.idata.type === "string"
                         || jitem.idata.type === "number"
                         || jitem.idata.type === "boolean"
                height: parent.height
                Layout.fillWidth: true
                selectByMouse: true
                text: jitem.idata.value
                verticalAlignment: Text.AlignVCenter
                readOnly: true
                color: Material.foreground
                onFocusChanged: {
                    tid.readOnly = !tid.readOnly
                }
            }
        }
    }
}
