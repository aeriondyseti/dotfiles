import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Commons

// Bottom taskbar: a full-width frosted bar along the bottom edge (one per
// screen) mirroring Omarchy's top bar. Centered icons: one per window on the
// current workspace, plus minimized windows.
//   Left click:   hide (minimize) the window, or show it again on this workspace.
//   Middle click: close.
// Minimized windows live on the hidden special:minimized workspace (Super+M)
// and are drawn dimmed. Windows asking for attention (Hyprland "urgent")
// pulse amber until focused.
Item {
  id: root

  property var shell: null

  readonly property string minimizedWorkspace: "special:minimized"
  readonly property int iconSize: 18
  readonly property int stripHeight: Style.bar.sizeHorizontal
  readonly property color urgentColor: "#f0a820"

  function isMinimized(toplevel) {
    return toplevel.workspace !== null && toplevel.workspace.name === root.minimizedWorkspace
  }

  // Windows on the focused workspace, then minimized windows (always shown,
  // so they can be restored from any workspace).
  readonly property var windows: {
    var current = Hyprland.focusedWorkspace
    var here = []
    var minimized = []
    var values = Hyprland.toplevels.values
    for (var i = 0; i < values.length; i++) {
      var t = values[i]
      if (t.workspace === null) continue
      if (isMinimized(t)) minimized.push(t)
      else if (current !== null && t.workspace.id === current.id) here.push(t)
    }
    return here.concat(minimized)
  }

  function appId(toplevel) {
    if (toplevel.wayland && toplevel.wayland.appId) return toplevel.wayland.appId
    var ipc = toplevel.lastIpcObject
    return ipc && ipc.class ? ipc.class : ""
  }

  function iconFor(toplevel) {
    var id = appId(toplevel)
    var entry = id ? DesktopEntries.heuristicLookup(id) : null
    var path = Quickshell.iconPath(entry && entry.icon ? entry.icon : id, true)
    return path.length > 0 ? path : Quickshell.iconPath("application-x-executable", true)
  }

  // Runs `hyprctl dispatch <lua>` without a shell (argv form).
  function dispatch(lua) {
    Quickshell.execDetached(["hyprctl", "dispatch", lua])
  }

  function windowSelector(toplevel) {
    var address = String(toplevel.address)
    return "address:" + (address.indexOf("0x") === 0 ? address : "0x" + address)
  }

  function moveTo(toplevel, workspace) {
    dispatch("hl.dsp.window.move({ workspace = \"" + workspace + "\", follow = false, window = \"" + windowSelector(toplevel) + "\" })")
  }

  function minimize(toplevel) {
    moveTo(toplevel, root.minimizedWorkspace)
  }

  function restore(toplevel) {
    var current = Hyprland.focusedWorkspace
    moveTo(toplevel, current ? String(current.id) : "1")
  }

  function close(toplevel) {
    dispatch("hl.dsp.window.close({ window = \"" + windowSelector(toplevel) + "\" })")
  }

  // Thin teal line along the bottom edge of Omarchy's top bar (the bar has no
  // border option). Normal exclusion stacks it just below the bar's space.
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors.top: true
      anchors.left: true
      anchors.right: true
      implicitHeight: 1
      exclusionMode: ExclusionMode.Normal
      exclusiveZone: 0
      color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.18)

      WlrLayershell.namespace: "aerion-bar-edge"
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      mask: Region {}
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: strip
      required property var modelData
      screen: modelData

      // Full width, like the top bar (transparent; Hyprland blurs behind it).
      anchors.bottom: true
      anchors.left: true
      anchors.right: true
      implicitHeight: root.stripHeight
      exclusiveZone: root.stripHeight
      color: "transparent"

      WlrLayershell.namespace: "aerion-taskbar"
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      // Teal line along the top edge, mirroring the line under the top bar.
      Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.18)
      }

      RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Style.space(1)

        Repeater {
          model: root.windows

          Item {
            id: item
            required property var modelData
            readonly property var toplevel: modelData
            readonly property bool focused: toplevel.activated
            readonly property bool minimized: root.isMinimized(toplevel)
            readonly property bool urgent: toplevel.urgent

            implicitWidth: root.iconSize + Style.space(10)
            implicitHeight: root.stripHeight

            // Attention pulse
            Rectangle {
              anchors.fill: parent
              anchors.margins: Style.space(2)
              radius: Style.space(2)
              color: root.urgentColor
              visible: item.urgent
              opacity: 0.2
              SequentialAnimation on opacity {
                running: item.urgent
                loops: Animation.Infinite
                NumberAnimation { to: 0.6; duration: 650; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.2; duration: 650; easing.type: Easing.InOutSine }
              }
            }

            IconImage {
              anchors.centerIn: parent
              implicitSize: root.iconSize
              source: root.iconFor(item.toplevel)
              opacity: item.minimized ? 0.4 : (item.focused ? 1 : 0.8)
            }

            // Focus underline
            Rectangle {
              anchors.bottom: parent.bottom
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.bottomMargin: Style.space(1)
              width: item.focused ? root.iconSize : (item.minimized ? 0 : Style.space(4))
              height: Style.space(1)
              radius: height / 2
              color: item.urgent ? root.urgentColor : Color.accent
              opacity: item.focused ? 1 : 0.45
              Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            }

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.MiddleButton
              cursorShape: Qt.PointingHandCursor
              onClicked: function(mouse) {
                var t = item.toplevel
                if (mouse.button === Qt.MiddleButton) root.close(t)
                else if (item.minimized) root.restore(t)
                else root.minimize(t)
              }
            }
          }
        }
      }
    }
  }
}
