# Intra Checklist

- url: https://www.tradingview.com/script/YSJZTSz4-Intra-Checklist/
- type: indicator
- pine_id: PUB;495eebf051ca4234903c1de1e97b6b41
- version: 1.0

## Description

Checklist for use with Intra Technical Analysis.


Checklist currently contains 9 criteria:


- The Ranges = Mark the ranges.

- HTF Reversion Theory = What's the set up?

- Master & Controller (ext.) = The external legs data points.

- Master & Controller (int.) = The internal legs data points.

- Find the Chain = Look for the active chain & consider the chain breaks.

- Activation Points = What is price holding to bring you up or down?

- De-activation Points = Do you know where the TT is and is it confirming via -1 / mirror?

- Find the Targets = Comparative analysis, where is price going after your entry?

- Clear the Runway = Is the runway clear? What levels, if any, remain to be tested?



Criteria and sequencing may change as it's used & improved over time. 


Enjoy!

## Source Code

````pine
//@version=6
indicator("Intra Checklist", overlay = true)

// =====================================================
// SETTINGS
// =====================================================

showPanel = input.bool(true, "Show Checklist Panel")

panelPosition = input.string(
     "Top Right",
     "Panel Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

textSize = input.string(
     "Normal",
     "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"])

bgColor        = input.color(color.new(color.black, 10), "Background Color")
headerColor    = input.color(color.rgb(35, 35, 35), "Header Color")
checkedColor   = input.color(color.lime, "Checked Color")
uncheckedColor = input.color(color.gray, "Unchecked Color")

// =====================================================
// CHECKLIST ITEMS
// =====================================================

rangeCheck        = input.bool(false, "The Ranges", group = "Trading Checklist")
reversionCheck    = input.bool(false, "HTF Reversion Theory", group = "Trading Checklist")
masterExtCheck    = input.bool(false, "Master & Controller (ext.)", group = "Trading Checklist")
masterIntCheck    = input.bool(false, "Master & Controller (int.)", group = "Trading Checklist")
chainBreakCheck   = input.bool(false, "Find the Chain", group = "Trading Checklist")
activationCheck   = input.bool(false, "Activation Points", group = "Trading Checklist")
deactivationCheck = input.bool(false, "De-activation Points", group = "Trading Checklist")
targetsCheck      = input.bool(false, "Find the Targets", group = "Trading Checklist")
runwayCheck       = input.bool(false, "Clear the Runway", group = "Trading Checklist")

// =====================================================
// TABLE POSITION
// =====================================================

tablePos =
     panelPosition == "Top Right" ? position.top_right :
     panelPosition == "Top Left" ? position.top_left :
     panelPosition == "Bottom Right" ? position.bottom_right :
     position.bottom_left

// =====================================================
// TEXT SIZE
// =====================================================

txtSize =
     textSize == "Tiny" ? size.tiny :
     textSize == "Small" ? size.small :
     textSize == "Large" ? size.large :
     size.normal

// =====================================================
// TABLE
// =====================================================

var table checklist = table.new(
     position = tablePos,
     columns = 2,
     rows = 15,
     border_width = 1)

// =====================================================
// DRAW ROW FUNCTION
// =====================================================

f_drawRow(_row, _label, _checked) =>
    icon = _checked ? "✓" : "✘"
    col  = _checked ? checkedColor : uncheckedColor

    table.cell(
         table_id = checklist,
         column = 0,
         row = _row,
         text = icon,
         text_color = col,
         text_size = txtSize,
         bgcolor = bgColor)

    table.cell(
         table_id = checklist,
         column = 1,
         row = _row,
         text = _label,
         text_color = color.white,
         text_size = txtSize,
         bgcolor = bgColor)

// =====================================================
// RENDER TABLE
// =====================================================

if barstate.islast and showPanel

    table.clear(
         table_id = checklist,
         start_column = 0,
         start_row = 0,
         end_column = 1,
         end_row = 14)

    // HEADER

    table.cell(
         table_id = checklist,
         column = 0,
         row = 0,
         text = "",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = txtSize)

    table.cell(
         table_id = checklist,
         column = 1,
         row = 0,
         text = "Intra Checklist",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = txtSize)

    // =================================================
    // CHECKLIST ITEMS
    // =================================================

    f_drawRow(1, "The Ranges", rangeCheck)
    f_drawRow(2, "HTF Reversion Theory", reversionCheck)
    f_drawRow(3, "Master & Controller (ext.)", masterExtCheck)
    f_drawRow(4, "Master & Controller (int.)", masterIntCheck)
    f_drawRow(5, "Find the Chain", chainBreakCheck)
    f_drawRow(6, "Activation Points", activationCheck)
    f_drawRow(7, "De-activation Points", deactivationCheck)
    f_drawRow(8, "Find the Targets", targetsCheck)
    f_drawRow(9, "Clear the Runway", runwayCheck)
````
