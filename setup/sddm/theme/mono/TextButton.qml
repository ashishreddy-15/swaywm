import QtQuick

// Plain text button for the bottom strip: muted text, fg + a flat accent
// line along the strip's bottom edge on hover/focus (no pill shapes).
Item {
    id: btn

    property alias text: label.text
    signal clicked

    implicitWidth: label.implicitWidth + 20
    implicitHeight: parent ? parent.height : 30
    activeFocusOnTab: enabled

    readonly property bool hot: enabled && (mouse.containsMouse || activeFocus)

    Text {
        id: label
        anchors.centerIn: parent
        font.family: config.font
        font.pixelSize: 12
        font.weight: Font.Medium
        font.hintingPreference: Font.PreferFullHinting
        color: !btn.enabled ? config.dim : btn.hot ? config.fg : config.muted
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: label.width
        height: 2
        color: config.accent
        visible: btn.hot
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: btn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (btn.enabled) btn.clicked()
    }

    Keys.onReturnPressed: btn.clicked()
    Keys.onEnterPressed: btn.clicked()
    Keys.onSpacePressed: btn.clicked()
}
