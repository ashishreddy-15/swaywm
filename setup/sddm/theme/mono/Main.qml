// mono: SDDM login theme matching the sway setup.
// Palette lives in theme.conf (copied from colors.md); exposed here as config.*
//
// Keys (password field): Enter log in · Esc clear · Up/Down switch user
//                        Tab moves to session / power buttons
//
// Test without logging out:
//   sddm-greeter-qt6 --test-mode --theme ~/swaywm/setup/sddm/theme/mono

import QtQuick

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.bg

    // Fonts are copied here by setup/sddm.sh; the sddm user can't read ~/.local.
    FontLoader { source: "fonts/MapleMono-NF-Light.ttf" }
    FontLoader { source: "fonts/MapleMono-NF-Regular.ttf" }
    FontLoader { source: "fonts/MapleMono-NF-Medium.ttf" }

    // ── State ─────────────────────────────────────────────────
    property int userIndex: Math.max(0, userModel.lastIndex)
    property int sessionIndex: Math.max(0, sessionModel.lastIndex)
    property bool busy: false
    property bool failed: false
    property string message: ""
    property bool capsOn: typeof keyboard !== "undefined" && keyboard.capsLock

    readonly property var user: users.count > 0 ? users.itemAt(userIndex) : null
    readonly property string userName: user ? user.name : userModel.lastUser
    readonly property var session: sessions.count > 0 ? sessions.itemAt(sessionIndex) : null

    // Models are only reachable through delegates, so keep hidden copies.
    Item {
        visible: false
        Repeater {
            id: users
            model: userModel
            delegate: Item {
                required property string name
                required property string realName
            }
        }
        Repeater {
            id: sessions
            model: sessionModel
            delegate: Item {
                required property string name
            }
        }
    }

    function login() {
        if (busy || userName === "")
            return
        busy = true
        failed = false
        message = ""
        sddm.login(userName, password.text, sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            busy = false
            failed = true
            message = "wrong password"
            password.text = ""
            password.forceActiveFocus()
        }
        function onLoginSucceeded() {
            message = ""
        }
        function onInformationMessage(msg) {
            message = msg
        }
    }

    property date now: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    // Click anywhere to get back to the password field.
    MouseArea {
        anchors.fill: parent
        onClicked: password.forceActiveFocus()
    }

    // SDDM opens one window per screen. Show the form only on the largest
    // screen (the Samsung when docked, the laptop otherwise); the rest stay
    // black. Qt's "primary" screen is just the first one sway announces, and
    // the Screen attached property is unreliable on Wayland, so compare this
    // window's real size (sway makes it fullscreen) with the largest screen.
    readonly property bool mainScreen: {
        let largest = 0
        for (const s of Qt.application.screens)
            largest = Math.max(largest, s.width * s.height)
        return largest === 0 || width * height >= largest
    }

    // ── Everything visible lives on the main screen only ──────
    Item {
        id: content
        anchors.fill: parent
        visible: root.mainScreen
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
        Component.onCompleted: opacity = 1

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -parent.height * 0.06
            spacing: 0

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(root.now, config.clockFormat)
                color: config.fg
                font.family: config.font
                font.pixelSize: 84
                font.weight: Font.Light
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(root.now, config.dateFormat).toLowerCase()
                color: config.muted
                font.family: config.font
                font.pixelSize: 15
                font.hintingPreference: Font.PreferFullHinting
            }

            Item { width: 1; height: 56 }

            // User: plain text; arrows hint only when there is a choice
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: (root.user && root.user.realName !== "" ? root.user.realName : root.userName)
                      + (users.count > 1 ? "  ↑↓" : "")
                color: config.muted
                font.family: config.font
                font.pixelSize: 14
                font.hintingPreference: Font.PreferFullHinting
            }

            Item { width: 1; height: 12 }

            // Password field: surface fill, hairline border, flat accent edge
            Rectangle {
                id: field
                width: 320
                height: 40
                color: config.surface
                border.width: 1
                border.color: config.border
                radius: 0

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    focus: true
                    activeFocusOnTab: true
                    clip: true
                    readOnly: root.busy
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    passwordMaskDelay: 0
                    color: config.fg
                    selectionColor: config.raised
                    selectedTextColor: config.fg
                    font.family: config.font
                    font.pixelSize: 14
                    font.hintingPreference: Font.PreferFullHinting

                    cursorDelegate: Rectangle {
                        width: 2
                        color: config.accent
                    }

                    onAccepted: root.login()
                    onTextEdited: {
                        root.failed = false
                        root.message = ""
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            text = ""
                            root.failed = false
                            root.message = ""
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
                            if (users.count > 1) {
                                const step = event.key === Qt.Key_Down ? 1 : -1
                                root.userIndex = (root.userIndex + step + users.count) % users.count
                                text = ""
                            }
                            event.accepted = true
                        } else if (event.text.length === 1) {
                            // Wayland gives no Caps Lock state; infer it from letter case vs Shift.
                            const ch = event.text
                            if (ch.toUpperCase() !== ch.toLowerCase()) {
                                const shift = (event.modifiers & Qt.ShiftModifier) !== 0
                                root.capsOn = (ch === ch.toUpperCase()) !== shift
                            }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 6    // clear of the cursor
                        text: "password"
                        color: config.dim
                        font: password.font
                        visible: password.text === "" && !root.busy
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 3
                    anchors.bottomMargin: 1
                    height: 2
                    color: root.failed ? config.red : config.accent
                    visible: root.failed || password.activeFocus
                }
            }

            Item { width: 1; height: 12 }

            // Status line; fixed height so nothing jumps
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                height: 16
                text: root.failed ? root.message
                    : root.busy ? "logging in…"
                    : root.capsOn ? "caps lock is on"
                    : root.message
                color: root.failed ? config.red
                     : (!root.busy && root.capsOn) ? config.amber
                     : config.muted
                font.family: config.font
                font.pixelSize: 12
                font.hintingPreference: Font.PreferFullHinting
            }
        }

        // ── Bottom strip, like waybar: bg with a hairline on top ──
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 30
            color: config.bg

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: config.border
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 6
                height: parent.height

                TextButton {
                    visible: sessions.count > 1
                    text: root.session ? root.session.name.toLowerCase() : ""
                    onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessions.count
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 6
                height: parent.height

                TextButton {
                    text: "suspend"
                    enabled: sddm.canSuspend
                    onClicked: sddm.suspend()
                }
                TextButton {
                    text: "reboot"
                    enabled: sddm.canReboot
                    onClicked: sddm.reboot()
                }
                TextButton {
                    text: "shutdown"
                    enabled: sddm.canPowerOff
                    onClicked: sddm.powerOff()
                }
            }
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
