import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// Bar switch for `nightmode`: one click keeps the machine awake with the lid
// closed, long enough to listen to a video while falling asleep.
BarWidget {
  id: root
  moduleName: "zen.nightmode"

  // The script lives inside the plugin rather than elsewhere on PATH, so the
  // button and command cannot drift apart and renaming the folder is safe.
  readonly property string script: String(Qt.resolvedUrl("bin/nightmode")).replace("file://", "")

  readonly property string duration: String(root.setting("duration", "2h"))
  readonly property int stepMinutes: Number(root.setting("stepMinutes", 30))
  readonly property bool showRemaining: root.setting("showRemaining", true) === true
  readonly property bool suspendAtEnd: root.setting("suspendAtEnd", true) === true

  property bool armed: false
  property int remaining: 0
  property string lid: "open"

  readonly property string icon: "󰤄"
  readonly property string step: root.stepMinutes + "m"
  // A countdown does not fit in a vertical bar.
  readonly property bool withLabel: root.armed && root.showRemaining && !root.vertical

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function humanLeft(secs) {
    var h = Math.floor(secs / 3600)
    var m = Math.floor((secs % 3600) / 60)
    if (h > 0)
      return h + "h" + (m < 10 ? "0" : "") + m
    return Math.max(1, m) + "min"
  }

  function poll() {
    if (!stateProc.running)
      stateProc.running = true
  }

  function applyState(output) {
    try {
      var state = JSON.parse(String(output || "").trim())
      root.armed = state.active === true
      root.remaining = Number(state.remaining || 0)
      root.lid = String(state.lid || "open")
    } catch (error) {
      root.armed = false
      root.remaining = 0
    }
  }

  function invoke(args) {
    if (actionProc.running)
      return
    var argv = [root.script].concat(args)
    if (!root.suspendAtEnd)
      argv.push("--no-suspend")
    actionProc.command = argv
    actionProc.running = true
  }

  Process {
    id: stateProc
    command: [root.script, "state"]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyState(text)
    }
  }

  Process {
    id: actionProc
    onExited: root.poll()
  }

  // The countdown is displayed by the minute, so there is no need to poll faster.
  Timer {
    interval: root.armed ? 10000 : 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.poll()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.withLabel ? root.icon + " " + root.humanLeft(root.remaining) : root.icon
    fontSize: root.withLabel ? Style.font.body : Style.bar.iconFont
    active: root.armed
    dimmed: !root.armed
    tooltipText: (root.armed
      ? "Keep Awake - " + root.humanLeft(root.remaining) + " remaining"
        + " - lid " + (root.lid === "closed" ? "closed" : "open")
      : "Keep Awake - off")
      + "\nLeft click: toggle " + root.duration
      + " - Right click: add " + root.stepMinutes + " min"

    onPressed: function (which) {
      if (which === Qt.RightButton)
        root.invoke(["extend", "+" + root.step])
      else if (which === Qt.MiddleButton)
        root.invoke(["off"])
      else
        root.invoke(["toggle", root.duration])
    }

    onWheelMoved: function (delta) {
      if (!root.armed)
        return
      root.invoke(["extend", (delta > 0 ? "+" : "-") + root.step])
    }
  }
}
