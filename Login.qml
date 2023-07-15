import "components"

import QtQuick 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.13

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

SessionManagementScreen {
    id: root
    property Item mainPasswordBox: passwordBox

    property bool showUsernamePrompt: !showUserList

    property string lastUserName
    property bool loginScreenUiVisible: false

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + units.smallSpacing

    signal loginRequest(string username, string password)

    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    /*
    * Login has been requested with the following username and password
    * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
    */
    function startLogin() {
        var username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        var password = passwordBox.text

        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    Input {
        id: userNameInput
        Layout.fillWidth: true
        text: lastUserName
        visible: showUsernamePrompt
        focus: showUsernamePrompt && !lastUserName //if there's a username prompt it gets focus first, otherwise password does
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Username")
        Layout.bottomMargin: 10

        onAccepted:
            if (root.loginScreenUiVisible) {
                passwordBox.forceActiveFocus()
            }
    }

    Input {
        id: passwordBox
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
        focus: !showUsernamePrompt || lastUserName
        echoMode: TextInput.Password

        Layout.fillWidth: true

        onAccepted: {
            if (root.loginScreenUiVisible) {
                startLogin();
            }
        }

        Keys.onEscapePressed: {
            mainStack.currentItem.forceActiveFocus();
        }

        //if empty and left or right is pressed change selection in user switch
        //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
        Keys.onPressed: {
            if (event.key == Qt.Key_Left && !text) {
                userList.decrementCurrentIndex();
                event.accepted = true
            }
            if (event.key == Qt.Key_Right && !text) {
                userList.incrementCurrentIndex();
                event.accepted = true
            }
        }

        Connections {
            target: sddm
            onLoginFailed: {
                passwordBox.selectAll()
                passwordBox.forceActiveFocus()
            }
        }
    }
    Button {
        id: loginButton
        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log In")

        Layout.topMargin: 20
        Layout.fillWidth: true
        
        font.pointSize: config.fontSize
        font.family: config.font

        contentItem: Text {
            text: loginButton.text
            font: loginButton.font
            opacity: enabled ? 1.0 : 0.8
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Item {
            width: loginButton.width
            height: loginButton.height
            
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: loginButton.width
                    height: loginButton.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: loginButton.width
                        height: loginButton.height
                        radius: loginButton.height
                    }
                }
            }

            Rectangle {
                id: angledRect
                width: parent.width * 1.2
                height: parent.width * 1.2
                anchors.centerIn: parent

                rotation: 160

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#044baf" }
                    GradientStop { position: 0.4; color: "#075e90" }
                    GradientStop { position: 1.0; color: "#0975b1" }
                }
            }
        }

        onClicked: startLogin();
    }

}
