import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Ui

// Local vault selector. Omarchy's shared Dropdown currently calls helper
// functions declared inside a ListView; on this Qt build those functions are
// not exposed by the ListView, so the menu opens but cannot select a row.
Item {
  id: root
  property string label: ""
  property string value: ""
  property var options: []
  property color foreground: Color.popups.text
  property string fontFamily: Style.font.family
  property bool hasCursor: false
  readonly property bool popupOpen: popup.opened
  signal changed(string value)
  signal doneEditing()

  function open() { popup.open() }
  function close() { popup.close() }
  function optionValue(o) { return (o && typeof o === "object") ? String(o.value) : String(o) }
  function optionLabel(o) { return (o && typeof o === "object") ? String(o.label) : String(o) }
  function currentLabel() {
    for (var i = 0; i < options.length; i++)
      if (optionValue(options[i]) === value) return optionLabel(options[i])
    return value
  }

  implicitHeight: Style.spacing.controlHeight + Style.spacing.huge
  width: parent ? parent.width : Style.spacing.dropdownWidth

  Column {
    anchors.fill: parent
    spacing: Style.spacing.labelGap
    Text {
      textFormat: Text.PlainText
      text: root.label
      color: Qt.darker(root.foreground, 1.4)
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
    }
    BorderSurface {
      id: trigger
      width: parent.width
      height: Style.spacing.controlHeight
      radius: Style.cornerRadius
      color: Style.controlFill(trigger.activeFocus, root.hasCursor, root.foreground, Color.accent)
      borderSpec: Border.controlSpec(trigger.activeFocus ? "focus" : (root.hasCursor ? "hover-cursor" : "normal"), root.foreground, Color.accent)
      activeFocusOnTab: true
      Text {
        textFormat: Text.PlainText
        anchors.left: parent.left; anchors.right: chevron.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: trigger.borderLeft + Style.spacing.controlPaddingX
        anchors.rightMargin: trigger.borderRight + Style.spacing.md
        text: root.currentLabel(); color: root.foreground
        font.family: root.fontFamily; font.pixelSize: Style.font.body
        elide: Text.ElideRight
      }
      Text {
        textFormat: Text.PlainText
        id: chevron; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: trigger.borderRight + Style.spacing.controlGap
        text: "󰅀"; color: Qt.darker(root.foreground, 1.2)
        font.family: root.fontFamily; font.pixelSize: Style.font.body
      }
      MouseArea {
        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
        onClicked: { trigger.forceActiveFocus(); popup.opened ? popup.close() : popup.open() }
      }
    }
  }

  Popup {
    id: popup
    x: 0
    y: root.height + Style.spacing.xxs
    width: root.width
    padding: Style.spacing.hairline
    focus: true
    onClosed: root.doneEditing()
    background: BorderSurface {
      color: Color.popups.background
      borderSpec: Border.localOrSurfaceSpec("popups", "border", Color.popups.border, Color.popups.border, Style.normalBorderWidth)
      radius: Style.cornerRadius
    }
    contentItem: Column {
      spacing: Style.spacing.labelGap
      Repeater {
        model: root.options
        delegate: Rectangle {
          required property var modelData
          width: popup.width - popup.leftPadding - popup.rightPadding
          height: Style.spacing.popupRowHeight
          color: mouse.containsMouse ? Style.hoverFillFor(root.foreground, Color.accent) : "transparent"
          Text {
            textFormat: Text.PlainText
            anchors.fill: parent; anchors.leftMargin: Style.spacing.controlPaddingX; anchors.rightMargin: Style.spacing.controlPaddingX
            verticalAlignment: Text.AlignVCenter
            text: root.optionLabel(modelData)
            color: mouse.containsMouse ? Style.hoverStateColor(root.foreground, Color.accent) : root.foreground
            font.family: root.fontFamily; font.pixelSize: Style.font.body
            elide: Text.ElideRight
          }
          MouseArea {
            id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: { root.value = root.optionValue(modelData); root.changed(root.value); popup.close() }
          }
        }
      }
    }
  }
}
