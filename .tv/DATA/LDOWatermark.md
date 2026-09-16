<!-- tradingview-pine-id: PUB;810b573ff9db4121b23eb659bb6a8975 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# LDO-Watermark

Source: https://www.tradingview.com/script/MdG2ciJh-LDO-Watermark/

## Description

Watermark — quick guide

To shrink it (no script) — Chart settings → Canvas:

Untick Description — removes the big second line. This is 90% of the fix.
Untick Interval if you don't want the , 15.
Click the colour swatch beside the dropdown → drop opacity to ~10%, or 0% to remove it.
Can't be done here: moving it, or changing its size.

To move or resize it (script)

Untick all three boxes above, so the native one is gone.
Add LDO-Watermark to the chart.
In its settings: Position (9 anchors), Size, Colour (transparency lives in the colour picker), Nudge sideways/vertically for anything between anchors.
Tick Description only if you want the long exchange name back.
One catch: the script's watermark sits in front of the candles, not behind. Keep transparency at 85% or higher.

---

## Source Code

````pine
//@version=6
// LDO-Watermark v1.0 — replacement for TradingView's fixed chart watermark.
// The native one cannot be moved or resized from Pine. Turn it off in
// Chart settings > Canvas (untick Ticker / Interval / Description, or set its
// colour swatch to 0% opacity), then use this instead.
// Note: this draws IN FRONT of the candles, not behind them like the native
// watermark. Keep the transparency high.
indicator("LDO-Watermark", overlay = true)

string G_TXT = "Content"
string G_POS = "Placement"
string G_STY = "Style"

// ─── Content ─────────────────────────────────────────────────────────────────
bool showTicker   = input.bool(true,  "Ticker",      inline = "line1", group = G_TXT)
bool showInterval = input.bool(true,  "Interval",    inline = "line1", group = G_TXT)
bool showDesc     = input.bool(false, "Description", inline = "line1", group = G_TXT,
     tooltip = "The long exchange description — this is what makes the native watermark so large.")

string customText = input.string("", "Custom text", group = G_TXT,
     tooltip = "Leave blank to use the ticker/interval/description above. Anything typed here replaces them entirely.")

// ─── Placement ───────────────────────────────────────────────────────────────
string pos = input.string("Middle centre", "Position", group = G_POS, options = [
     "Top left",    "Top centre",    "Top right",
     "Middle left", "Middle centre", "Middle right",
     "Bottom left", "Bottom centre", "Bottom right"])

int nudgeH = input.int(0, "Nudge sideways", minval = 0, maxval = 60, group = G_POS,
     tooltip = "Spaces inserted before the text. Pushes it away from its anchor.")

int nudgeV = input.int(0, "Nudge vertically", minval = 0, maxval = 20, group = G_POS,
     tooltip = "Blank lines inserted before the text. Pushes it down from a top anchor, up from a bottom one.")

// ─── Style ───────────────────────────────────────────────────────────────────
string txtSize = input.string("Huge", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = G_STY)

color txtColor = input.color(color.new(#787B86, 85), "Colour", group = G_STY,
     tooltip = "Transparency is part of this colour. 85% is roughly the native watermark; go higher to recede further.")

bool descSmaller = input.bool(true, "Draw the description one size down", group = G_STY)

// ─── Build ───────────────────────────────────────────────────────────────────
string mainLine = customText != "" ? customText :
     (showTicker ? syminfo.ticker : "") +
     (showTicker and showInterval ? ", " : "") +
     (showInterval ? timeframe.period : "")

string descLine = customText != "" or not showDesc ? "" : syminfo.description

string padH = nudgeH > 0 ? str.repeat(" ",  nudgeH) : ""
string padV = nudgeV > 0 ? str.repeat("\n", nudgeV) : ""

// The 9 anchors are all TradingView exposes; the nudges cover the gaps between.
string anchor = pos == "Top left"      ? position.top_left      :
     pos == "Top centre"    ? position.top_center    :
     pos == "Top right"     ? position.top_right     :
     pos == "Middle left"   ? position.middle_left   :
     pos == "Middle centre" ? position.middle_center :
     pos == "Middle right"  ? position.middle_right  :
     pos == "Bottom left"   ? position.bottom_left   :
     pos == "Bottom centre" ? position.bottom_center : position.bottom_right

string sizeMain = txtSize == "Tiny"   ? size.tiny   :
     txtSize == "Small"  ? size.small  :
     txtSize == "Normal" ? size.normal :
     txtSize == "Large"  ? size.large  :
     txtSize == "Huge"   ? size.huge   : size.auto

string sizeDesc = not descSmaller ? sizeMain :
     txtSize == "Huge"   ? size.large  :
     txtSize == "Large"  ? size.normal :
     txtSize == "Normal" ? size.small  :
     txtSize == "Small"  ? size.tiny   : sizeMain

var table wm = na
if barstate.islast
    if na(wm)
        wm := table.new(position = anchor, columns = 1, rows = 2)
    table.cell(wm, 0, 0, padV + padH + mainLine, text_color = txtColor, text_size = sizeMain)
    table.cell(wm, 0, 1, descLine == "" ? "" : padH + descLine, text_color = txtColor, text_size = sizeDesc)
````
