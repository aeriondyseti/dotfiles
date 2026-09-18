import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.Commons
import qs.Ui

// Taskbar: one icon per open window.
//   Left click:   focus it (switching workspace if needed); on the focused
//                 window, minimize it; on a minimized window, restore it here.
//   Right click:  minimize / restore.
//   Middle click: close.
// Minimized windows live on the hidden special:minimized workspace (Super+M)
// and are drawn dimmed. Windows asking for attention (Hyprland "urgent")
// pulse in the attention color until focused.
BarWidget {
  id: root
  moduleName: "aerion.taskbar"

  readonly property string minimizedWorkspace: "special:minimized"
  readonly property int iconSize: Number(setting("iconSize", 18))
  readonly property color urgentColor: String(setting("urgentColor", "#f0a820"))

  function isMinimized(toplevel) {
    return toplevel.workspace !== null && toplevel.workspace.name === root.minimizedWorkspace
  }

  // Real windows only, grouped by workspace (minimized ones last).
  readonly property var windows: {
    var list = []
    var values = Hyprland.toplevels.values
    for (var i = 0; i < values.length; i++) {
      var t = values[i]
      if (t.workspace === null) continue
      if (t.workspace.id < 0 && !isMinimized(t)) continue // other special workspaces (scratchpad)
      list.push({ toplevel: t, order: i })
    }
    list.sort(function(a, b) {
      var wa = isMinimized(a.toplevel) ? 1000 : a.toplevel.workspace.id
      var wb = isMinimized(b.toplevel) ? 1000 : b.toplevel.workspace.id
      return wa !== wb ? wa - wb : a.order - b.order
    })
    return list.map(function(entry) { return entry.toplevel })
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

  function dispatch(lua) {
    if (root.bar) root.bar.run("hyprctl dispatch " + Util.shellQuote(lua))
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
    focusLater.target = toplevel
    focusLater.restart()
  }

  function focus(toplevel) {
    if (toplevel.wayland) toplevel.wayland.activate()
  }

  // Give Hyprland a moment to finish the move before activating.
  Timer {
    id: focusLater
    property var target: null
    interval: 60
    onTriggered: if (target) root.focus(target)
  }

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight
  visible: root.windows.length > 0

  GridLayout {
    id: row
    anchors.fill: parent
    columns: root.vertical ? 1 : Math.max(1, root.windows.length)
    columnSpacing: Style.space(1)
    rowSpacing: Style.space(1)

    Repeater {
      model: root.windows

      Item {
        id: item
        required property var modelData
        readonly property var toplevel: modelData
        readonly property bool focused: toplevel.activated
        readonly property bool minimized: root.isMinimized(toplevel)
        readonly property bool urgent: toplevel.urgent

        implicitWidth: root.vertical ? root.barSize : root.iconSize + Style.space(10)
        implicitHeight: root.vertical ? root.iconSize + Style.space(8) : root.barSize

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
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
          cursorShape: Qt.PointingHandCursor

          onClicked: function(mouse) {
            var t = item.toplevel
            if (mouse.button === Qt.MiddleButton) {
              if (t.wayland) t.wayland.close()
            } else if (item.minimized) {
              root.restore(t)
            } else if (mouse.button === Qt.RightButton || item.focused) {
              root.minimize(t)
            } else {
              root.focus(t)
            }
          }
          onEntered: if (root.bar) root.bar.showTooltip(item, item.toplevel.title || root.appId(item.toplevel))
          onExited: if (root.bar) root.bar.hideTooltip(item)
        }
      }
    }
  }
}
