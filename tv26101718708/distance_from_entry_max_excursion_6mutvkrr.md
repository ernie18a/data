# Distance From Entry + Max Excursion

- url: https://www.tradingview.com/script/6mUtvkRr-Distance-From-Entry-Max-Excursion/
- type: indicator
- pine_id: PUB;e7c83e637cb94f39b624f62e24d7dd59
- version: 3.0

## Description

**What this script does**

This indicator displays a small, fully customizable table on the chart that shows two pieces of information relative to a manually defined entry price:

1. **Distance From Entry** — the absolute difference, in points, between the current price and the entry price, along with whether price is currently above, below, or at that level.
2. **Max Excursion** — the largest favorable move price has made since the most recent time it touched the entry level. If price is currently above entry, this tracks the highest high reached since that last touch; if price is currently below entry, it tracks the lowest low reached since that last touch. The figure shown is the point distance between entry and that extreme.

**How it works (concept)**

The script does not pull live position data from any broker. Pine Script has no access to a connected broker account's open trades, fill price, or quantity, so this tool instead uses a single user-defined input (the entry price you place by clicking on the chart) as its reference point.

From there, the script watches every bar to detect a "touch" of that entry price, defined as any bar whose high-low range brackets the entry level (low <= entry <= high). Each time a touch occurs, the running high/low tracker resets to that bar's range. Between touches, the tracker expands to capture the highest high (if price is above entry) or lowest low (if price is below entry) reached during that stretch. This produces a continuously updating "maximum excursion" figure without requiring the user to manually mark when a trade started or which direction it was — direction is inferred automatically from where price currently sits relative to the entry level.

**Why it's useful**

Traders who manually track trade management metrics — specifically, how far price has moved from an entry level, and the best the trade has looked since price last revisited that level — typically do this with mental math or by eyeballing the chart. This script automates that single calculation and displays it persistently in a screen-fixed table, so it doesn't require redrawing tools or recalculating by hand every time price moves.

**Customization**

Nearly every visual aspect of the table is exposed as an input, organized into grouped sections in the settings panel:

- Table position (any of the 9 standard chart anchor points)
- Cell width/height (manual sizing or auto-fit)
- Text horizontal/vertical alignment
- Text size (5 steps) and font family (default or monospace — the two families Pine Script supports)
- Decimal precision (0–4 digits)
- Optional prefix text and direction wording
- Background color, border color, and border width
- Optional color-coding of text based on whether price is above or below entry

**How to use it**

1. Add the indicator to your chart.
2. When prompted, click on the chart at your entry price (or place it roughly and drag the resulting line to the exact level).
3. The table will appear in your chosen screen corner, showing live point distance from entry and the running maximum excursion since the last touch of that level.
4. Open the indicator's settings at any time to adjust position, sizing, colors, font, and decimal precision to your preference.
5. To start tracking a new trade, simply update the entry price input to the new level.

**Limitations**

- This script does not read live broker/account data of any kind. The entry price is a manual input and will not update automatically when a position is closed or a new one is opened.
- If price gaps cleanly across the entry level on a single bar (the bar's open and close both clear entry, but its high/low range does not bracket the entry price), that bar will not register as a "touch," and the excursion tracker will not reset on that bar. This is uncommon in actively traded intraday futures but can occur around large gaps in thinner markets.
- This tool is for visual reference only. It does not generate buy/sell signals, does not constitute trading advice, and makes no claims about trading performance or outcomes.

## Source Code

````pine
//@version=6
indicator("Distance From Entry + Max Excursion", "DFE/ME", overlay=true)

// ── Entry Info ────────────────────────────────────────────────
entryPrice    = input.price(defval=0.0, title="Entry Price", confirm=true, group="Entry")
showExcursion = input.bool(true, title="Show Max Excursion Row", group="Entry")
showRegret    = input.bool(true, title="Show ME - Current Price Row", group="Entry")
regretLabel   = input.string("Level of Regret", title="Label for ME - Current Price Row", group="Entry")
showPctMove   = input.bool(true, title="Show % of Move Row", group="Entry")

// ── Position & Layout ────────────────────────────────────────
posChoice = input.string("Bottom Right", title="Table Position", options=[
     "Top Left", "Top Center", "Top Right",
     "Middle Left", "Middle Center", "Middle Right",
     "Bottom Left", "Bottom Center", "Bottom Right"], group="Layout")

cellWidth  = 0
cellHeight = 0

hAlignChoice = "Center"
vAlignChoice = "Center"
// ── Text Appearance ──────────────────────────────────────────
sizeChoice    = input.string("Normal", title="Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Text")
fontChoice    = input.string("Default", title="Font Family", options=["Default", "Monospace"], group="Text")
decimals      = input.int(2, title="Decimal Places", minval=0, maxval=4, group="Text")
labelPrefix   = input.string("", title="Prefix Text (Distance row)", group="Text")
showDirection = input.bool(true, title="Show 'above/below entry' text", group="Text")

// ── Colors ────────────────────────────────────────────────────
bgColor     = input.color(color.new(#1E222D, 0), title="Background Color", group="Colors")
borderColor = input.color(color.new(#FFFFFF, 70), title="Border Color", group="Colors")
borderWidth = input.int(1, title="Border Width", minval=0, maxval=5, group="Colors")

useColorCoding = input.bool(true, title="Color-code rows by direction", group="Colors")
neutralColor   = input.color(color.white, title="Neutral / 'At Entry' Color", group="Colors")
aboveColor     = input.color(color.lime, title="Above Entry Color", group="Colors")
belowColor     = input.color(color.red, title="Below Entry Color", group="Colors")
regretColor    = input.color(color.orange, title="Level of Regret Text Color", group="Colors")
pctColor       = input.color(color.yellow, title="% of Move Text Color", group="Colors")

// ── Number Formatting Helper ───────────────────────────────────
formatNum(val, dec) =>
    switch dec
        0 => str.tostring(val, "#")
        1 => str.tostring(val, "#.#")
        2 => str.tostring(val, "#.##")
        3 => str.tostring(val, "#.###")
        4 => str.tostring(val, "#.####")
        => str.tostring(val, "#.##")

// ── Distance Calculation ───────────────────────────────────────
distPoints = math.abs(close - entryPrice)
isAbove    = close > entryPrice
isBelow    = close < entryPrice

distFormatted = formatNum(distPoints, decimals)
directionText = isAbove ? " above entry" : isBelow ? " below entry" : " at entry"
displayText   = labelPrefix + distFormatted + " pts" + (showDirection ? directionText : "")
distColor     = useColorCoding ? (isAbove ? aboveColor : isBelow ? belowColor : neutralColor) : neutralColor

// ── Max Excursion Calculation ───────────────────────────────────
// A "touch" = entry price fell within this bar's high/low range
touched = low <= entryPrice and high >= entryPrice

var float runHigh = na
var float runLow  = na

if touched
    runHigh := high
    runLow  := low
else if not na(runHigh)
    runHigh := math.max(runHigh, high)
    runLow  := math.min(runLow, low)

maxExcursion = isAbove ? (na(runHigh) ? 0.0 : math.round_to_mintick(runHigh - entryPrice)) : isBelow ? (na(runLow) ? 0.0 :  math.round_to_mintick(entryPrice - runLow)) : 0.0
excFormatted = formatNum(maxExcursion, decimals)
excColor     = useColorCoding ? (isAbove ? aboveColor : isBelow ? belowColor : neutralColor) : neutralColor

// ── Level of Regret: ME minus current distance from entry ───────
// Always >= 0 — the running peak can never be closer to entry than the current price is.
giveback        =  math.round_to_mintick(maxExcursion - distPoints)
giveFormatted    = formatNum(giveback, decimals)

// ── % of Move: how much of the peak excursion current price still holds ──
// Guarded against divide-by-zero for the case where no excursion has built up yet.
pctOfMove     = maxExcursion != 0.0 ? (distPoints / maxExcursion) * 100.0 : 0.0
pctFormatted  = formatNum(pctOfMove, decimals)

// ── Style Mappings ─────────────────────────────────────────────
sizeVal = switch sizeChoice
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

fontVal = fontChoice == "Monospace" ? font.family_monospace : font.family_default

hAlignVal = switch hAlignChoice
    "Left"   => text.align_left
    "Center" => text.align_center
    "Right"  => text.align_right
    => text.align_center

vAlignVal = switch vAlignChoice
    "Top"    => text.align_top
    "Center" => text.align_center
    "Bottom" => text.align_bottom
    => text.align_center

posVal = switch posChoice
    "Top Left"       => position.top_left
    "Top Center"     => position.top_center
    "Top Right"      => position.top_right
    "Middle Left"    => position.middle_left
    "Middle Center"  => position.middle_center
    "Middle Right"   => position.middle_right
    "Bottom Left"    => position.bottom_left
    "Bottom Center"  => position.bottom_center
    "Bottom Right"   => position.bottom_right
    => position.bottom_right

// ── Render ────────────────────────────────────────────────────
rowCount = 1 + (showExcursion ? 1 : 0) + (showRegret ? 1 : 0) + (showPctMove ? 1 : 0)

var table distTable = table.new(
     position     = posVal,
     columns      = 1,
     rows         = rowCount,
     bgcolor      = bgColor,
     border_width = borderWidth,
     border_color = borderColor,
     frame_color  = borderColor,
     frame_width  = borderWidth)

if barstate.islast
    table.cell(
         table_id         = distTable,
         column           = 0,
         row              = 0,
         text             = displayText,
         text_color       = distColor,
         text_size        = sizeVal,
         text_font_family = fontVal,
         text_halign      = hAlignVal,
         text_valign      = vAlignVal,
         width            = cellWidth,
         height           = cellHeight)

    nextRow = 1

    if showExcursion
        table.cell(
             table_id         = distTable,
             column           = 0,
             row              = nextRow,
             text             = "Max Excursion: " + excFormatted + " pts",
             text_color       = excColor,
             text_size        = sizeVal,
             text_font_family = fontVal,
             text_halign      = hAlignVal,
             text_valign      = vAlignVal,
             width            = cellWidth,
             height           = cellHeight)
        nextRow := nextRow + 1

    if showRegret
        table.cell(
             table_id         = distTable,
             column           = 0,
             row              = nextRow,
             text             = regretLabel + ": " + giveFormatted + " pts",
             text_color       = regretColor,
             text_size        = sizeVal,
             text_font_family = fontVal,
             text_halign      = hAlignVal,
             text_valign      = vAlignVal,
             width            = cellWidth,
             height           = cellHeight)
        nextRow := nextRow + 1

    if showPctMove
        table.cell(
             table_id         = distTable,
             column           = 0,
             row              = nextRow,
             text             = pctFormatted + "% of Move",
             text_color       = pctColor,
             text_size        = sizeVal,
             text_font_family = fontVal,
             text_halign      = hAlignVal,
             text_valign      = vAlignVal,
             width            = cellWidth,
             height           = cellHeight)
````
