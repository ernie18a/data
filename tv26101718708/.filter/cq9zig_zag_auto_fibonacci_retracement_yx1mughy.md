# CQ_(9)_Zig Zag Auto Fibonacci Retracement

- url: https://www.tradingview.com/script/YX1MuGHy-CQ-9-Zig-Zag-Auto-Fibonacci-Retracement/
- type: indicator
- pine_id: PUB;eb3dec18a2fc49e381f287bc40cacfca
- version: 1.0

## Description

================================================================================
CQ_(9)_[ZIG ZAG AUTO FIBONACCI RETRACEMENT]
USER MANUAL
================================================================================
Author handle : CQuevedo345
Platform      : TradingView
Language      : Pine Script v6
Type          : Overlay indicator
Built from    : Section 1 = CQ_(5)_Zig Zag Trend Metrics (ported verbatim)
                Section 2 = CQ_(8)_Auto Fibonacci Retracement (adapted to be
                            fed by the zigzag's last confirmed leg)

--------------------------------------------------------------------------------
1. WHAT THIS INDICATOR DOES
--------------------------------------------------------------------------------
This script merges two tools into one overlay:

  A) A ZIG ZAG SWING ENGINE that detects confirmed swing highs and lows over
     a user-defined lookback period, connects them with lines, labels each
     swing with its price/percent change and bar-time distance from the prior
     opposite swing, and (optionally) shows a running statistics table of the
     average up-leg and down-leg size/duration.

  B) An AUTO FIBONACCI RETRACEMENT + GAUGE that is automatically anchored to
     whatever the zigzag currently considers its LAST CONFIRMED LEG. As the
     zigzag confirms new swings, the Fibonacci grid re-anchors itself with no
     manual drawing required.

Because the retracement math is direction-agnostic (0% is always the newest
pivot, 100% is always the older pivot), the readout flips meaning depending on
the leg type:

  - Last leg is BEARISH (High -> Low)  => retracement is measured UP from the
    low, i.e. it reads as a potential BULLISH bounce.
  - Last leg is BULLISH (Low -> High)  => retracement is measured DOWN from
    the high, i.e. it reads as a potential BEARISH pullback.

--------------------------------------------------------------------------------
2. HOW THE ZIG ZAG ENGINE WORKS (SECTION 1)
--------------------------------------------------------------------------------
- Every bar, the script checks whether the current bar's high is the highest
  high of the last "Period" bars (a confirmed pivot high) or the current low
  is the lowest low of the last "Period" bars (a confirmed pivot low).
- "direction" flips to +1 on a new pivot high context and -1 on a new pivot
  low context. A swing point is only "added" the first time direction flips;
  while direction stays the same, the existing extreme point is simply
  UPDATED (extended) if price makes a more extreme high/low.
- Each swing point gets a label showing:
    * Pattern tag: HH / LH (higher high / lower high) or LL / HL
      (lower low / higher low)
    * The price or percent change versus the most recent OPPOSITE swing
      (format controlled by the "Δ Format" input)
    * Elapsed bars ("⏱") since that opposite swing
    * Optionally, a second "cycle" line showing elapsed bars since the
      previous SAME-type swing (Show "Display Cycle")
- Connecting lines:
    * Thin "range lines" link consecutive same-type swings (high-to-high,
      low-to-low) if "Range Lines" is enabled.
    * Thick colored lines link low-to-high (bullish leg, up color) and
      high-to-low (bearish leg, down color) — these are the zigzag's main
      visible backbone and are what Section 2 anchors to.
    * A fill (linefill) shades the area between the most recent high-to-high
      and low-to-low lines.
- A statistics table (optional) shows the GEOMETRIC AVERAGE of the last N
  ("Averaging") up-leg and down-leg price changes and their average bar
  durations. Geometric averaging is used instead of arithmetic to better
  represent compounding percentage moves.

--------------------------------------------------------------------------------
3. HOW THE FIBONACCI ENGINE WORKS (SECTION 2)
--------------------------------------------------------------------------------
- A "leg bridge" watches the zigzag's internal arrays every bar. Whenever the
  zigzag's lastSwingType is "high" and a bullish line exists, that bullish
  line becomes the active Fibonacci anchor (0%=high just made, 100%=the low
  it came from). Whenever lastSwingType is "low" and a bearish line exists,
  that bearish line becomes the anchor instead (0%=low just made, 100%=the
  high it came from).
- The active leg line is automatically restyled DASHED with hollow circle (◯)
  markers at both ends so you can see at a glance which leg is currently
  driving the Fibonacci grid. When a newer leg takes over, the old leg is
  reverted back to its normal solid zigzag styling.
- Standard retracement levels drawn: 0%, 25%, 40%, 50%, 60%, 75%, 90%, 100%
  (each individually toggleable).
- Extended/projection levels are drawn AUTOMATICALLY, only when price has
  actually traded through the prior threshold level: -25%, -50%, -100%,
  -150%, -200%, 125%, 150%, 200%. These auto-lines fade in only when needed,
  keeping the chart clean during normal retracements.
- Each level shows:
    * A short horizontal "identifier" line from the pivot's opposite end out
      to the current bar (dotted for internal levels, solid+thick for 0%/100%)
    * A small tick/handle at the right-hand gauge column
    * A label with the level percentage and (optionally) the exact price
- GAUGE (drawn at the 100% level position, right side of chart by default):
    * Outer dotted box + white/colored end lines = the highest/lowest price
      reached since the anchor leg was confirmed (the "extreme" reading,
      also shown as a small ▲/▼ % label).
    * Inner solid box + thick colored line = current CLOSE plotted against
      the 0% pivot price, i.e. a compact visual "how far has price already
      retraced/extended" bar.
- PROFIT LABEL (drawn at the 0% level): shows the raw $ change of the current
  close versus the 0% pivot price, with a tooltip giving the % change too.
- An optional raw CLOSE PRICE line/area/histogram/step/cross/column/circle
  plot can be overlaid for reference (off by default).

--------------------------------------------------------------------------------
4. INPUT REFERENCE
--------------------------------------------------------------------------------
♦ lines (zigzag)
  - Period                 : Lookback bars used to confirm a pivot high/low
  - Color ↑ / ↓             : Colors of the bullish/bearish zigzag legs
  - Width                  : Line width of the zigzag legs
  - Range Lines / color    : Toggle + color for the thin high-to-high /
                              low-to-low connector lines
  - Highlight Last Confirmed Leg : Toggle the dashed+circle styling on the
                              active leg
  - Marker Size            : Size of the hollow circle end markers

♦ labels (zigzag)
  - Δ Format               : "Percent" or "Absolute" for the swing-label
                              price change readout
  - Text Size              : Size of zigzag swing labels
  - Display Cycle          : Adds a second same-type elapsed-time line to
                              each swing label

♦ statistics table (zigzag)
  - Show Stats table       : Toggle the table on/off
  - Location / Size        : Table position and text size
  - Averaging              : Number of past legs used in the geometric
                              average calculation

🪙 Fibonacci Retracement — ⚙ Master Control
  - Enable Fibonacci Gauge : Master on/off switch for Section 2
  - 25% / 40% / 50% / 60% / 75% / 90% : Toggle each standard retracement level

Close Price Plot
  - Show Line Graph, Color, Width, Style : Optional raw price plot overlay

Color Settings
  - BEARISH / BULLISH theme colors (note: named for the CURRENT tendency the
    retracement implies, not the leg direction itself — see Section 1 note
    above)
  - Use Trend Colors for Labels (+ independent label colors if disabled)
  - Label Side (vs Gauge)  : Left or Right label placement
  - Gauge ⁞▌ toggle + Bullish/Bearish highlight colors
  - Gauge X-Offset         : Horizontal offset of the gauge column from the
                              anchor bar
  - Level Tick Length (Right) : Length of the small tick marks at the gauge
  - Show Price on Labels   : Adds the exact price under each % label
  - Label Size
  - Gauge at Line End (vs Current Bar) : Anchors the gauge column to the end
                              of the active leg line instead of following the
                              live/current bar

♦ Last Confirmed Leg
  - Dash Last Leg          : Restyle the active leg as dashed
  - Mark Start/End (Hollow Circles) : Add ◯ markers at both ends
  - Circle Size

--------------------------------------------------------------------------------
5. READING THE CHART — QUICK GUIDE
--------------------------------------------------------------------------------
1. Find the DASHED leg with ◯ markers — that is the leg currently driving the
   Fibonacci grid.
2. Check which color theme is active at the gauge (BULLISH vs BEARISH theme
   color) to know whether the retracement is reading as an up-bounce or a
   down-pullback.
3. Use the OUTER gauge box to see how far price has already run beyond the
   0%/100% pivots (the extreme reached since the leg was confirmed).
4. Use the INNER gauge box/line to see where the current close sits relative
   to the 0% pivot right now.
5. The PROFIT label at 0% gives you a quick $ (and, via tooltip, %) read of
   how far price has moved from the most recent extreme pivot.
6. Auto-extension levels (125%, 150%, 200%, -50%, -100%, etc.) only appear
   once price has actually traded past the prior level — their absence means
   price hasn't reached that extension yet.

--------------------------------------------------------------------------------
6. TECHNICAL NOTES / ARCHITECTURE
--------------------------------------------------------------------------------
- indicator() flags: max_labels_count=500, max_lines_count=500,
  max_boxes_count=500, explicit_plot_zorder=true, max_bars_back=4000.
- Section 1 is ported VERBATIM from CQ_(5)_Zig Zag Trend Metrics — no logic
  was altered, only reused as the pivot/leg source of truth.
- Section 2 does not run its own pivot detection; it reads directly from the
  Section 1 arrays (swingHighValues/BarIndexes, swingLowValues/BarIndexes,
  bullishLines, bearishLines, lastSwingType) each bar via the "leg bridge"
  block, so the two sections always stay in sync.
- Persistent var objects (lines/boxes/labels) are reused and repositioned in
  place each bar rather than deleted/recreated, following the standard CQ
  collect-then-update pattern for efficient rendering.
- request.security() is used once to pull a small multi-value tuple
  (volume, OHLC variants, ATR14, RSI-of-PVT, etc.) — several of these fields
  are legacy/reserved from the source script and only k_atr14 and k_high/
  k_low are actively used by the current Fibonacci logic.
- Colors for the "BULLISH"/"BEARISH" theme inputs are intentionally reversed
  relative to leg direction — they represent the TENDENCY implied by the
  retracement, not the raw zigzag leg color. This mirrors the source script
  (CQ_(8)) naming convention; see Section 3 note if this feels
  counter-intuitive at first.

--------------------------------------------------------------------------------
7. VERSION / COMPATIBILITY
--------------------------------------------------------------------------------
- Written for Pine Script v6.
- overlay=true — must be applied directly to the price chart, not a
  separate pane.
- No alerts or strategy logic included; this is a pure visual/analysis tool.

================================================================================
END OF MANUAL
================================================================================

## Source Code

````pine
//@fract
//@version=6
indicator("CQ_(9)_Zig Zag Auto Fibonacci Retracement", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500, explicit_plot_zorder=true, max_bars_back=4000)

////////////////////////////////////////////////////////////////////////////
////  SECTION 1 — ZIG ZAG TREND METRICS (ported verbatim, unmodified)     ///
////  Source: CQ_(5)_Zig Zag Trend Metrics                                ///
////////////////////////////////////////////////////////////////////////////

// INPUT SETTINGS
period                            = input.int(45, "Period", minval=2)
color lineUpColor                 = input(title="Color ↑", defval=#6ba583, inline="lines", group="♦︎ lines")
color lineDnColor                 = input(title="↓", defval=#d75442, inline="lines", group="♦︎ lines")
lw                                = input.int(2, "Width", [1, 2, 3, 4], inline="lines", group="♦︎ lines")
bool rangeLines                   = input.bool(true, "Range Lines", inline = 'rangelines', group = "♦︎ lines")
color rnglineColor                = input(title="", defval=#000000, inline="rangelines", group="♦︎ lines")
//bool rnglineextend              = input.bool(false, "Extend", inline = 'rangelines', group = "lines")
bool   highlightLastLeg           = input.bool(true, "Highlight Last Confirmed Leg (Dashed + Circles)", inline = 'lastleg', group = "♦︎ lines")
string lastLegMarkerSzRaw         = input.string("Normal", "Marker Size", options=["Tiny","Small","Normal","Large","Huge"], inline = 'lastleg', group = "♦︎ lines")
lastLegMarkerSz                   = lastLegMarkerSzRaw == "Tiny" ? size.tiny : lastLegMarkerSzRaw == "Small" ? size.small : lastLegMarkerSzRaw == "Normal" ? size.normal : lastLegMarkerSzRaw == "Large" ? size.large : size.huge
delta                             = input.string('Percent', '𝜟 Format', options = [ 'Percent', 'Absolute'], group = '♦︎ labels', inline = 'st')
txtsz                             = input.string("Small", title="Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group = "♦︎ labels", inline = 'st')
bool cyclelab                     = input.bool(false, "Display Cycle", "Add Highs/Lows Cycle to the labels", group = "♦︎ labels")
showtable                         = input.bool(false, 'Show Stats table', group = '♦︎ statistics table')
locationtable                     = input.string('Bottom Right', 'Location', ['Top Right','Top Left', 'Bottom Right', 'Bottom Left'], group = '♦︎ statistics table', inline = 'tbpr')
sizetable                         = input.string('Normal', 'Size', ['Large', 'Normal', 'Small', 'Tiny'], group = '♦︎ statistics table', inline = 'tbpr')
avgln                             = input.int(10, "Averaging", minval=2, step=1, tooltip="Number of past occurrences to average", group = '♦︎ statistics table')
ts                                = txtsz == "Tiny"   ? size.tiny  :txtsz == "Small"  ? size.small :txtsz == "Normal" ? size.normal:txtsz == "Large"  ? size.large : size.huge

// Variables {
// LAST SWING TYPE
var string lastSwingType = ""
// SWING HIGHS
var float[] swingHighValues       = array.new_float(0)
var int[]   swingHighBarIndexes   = array.new_int(0)
var label[] swingHighLabels       = array.new_label(0)
// SWING LOWS
var float[] swingLowValues        = array.new_float(0)
var int[]   swingLowBarIndexes    = array.new_int(0)
var label[] swingLowLabels        = array.new_label(0)
// LINES
var line[]  highToHighLines       = array.new_line(0)
var line[]  lowToLowLines         = array.new_line(0)
var line[]  bullishLines          = array.new_line(0)
var line[]  bearishLines          = array.new_line(0)
// STS
var float[] highToHighPriceDiffs  = array.new_float(0)
var int[]   highToHighTimeDiffs   = array.new_int(0)
var float[] lowToLowPriceDiffs    = array.new_float(0)
var int[]   lowToLowTimeDiffs     = array.new_int(0)

var float[] bullishPriceDiffs     = array.new_float(0)
var float[] bullishPrcDiffs       = array.new_float(0)
var int[]   bullishTimeDiffs      = array.new_int(0)
var float[] bearishPriceDiffs     = array.new_float(0)
var float[] bearishPrcDiffs       = array.new_float(0)
var int[]   bearishTimeDiffs      = array.new_int(0)
//}
pH = 0 == ta.highestbars(high, period) ? high : na
pL = 0 == ta.lowestbars(low, period) ? low  : na
// Adds a new swing high point, calculates differences (same-type and cross-type), creates a label, and draws connecting lines{
f_addHighSwingPoint(highValue, barIndex) =>
    // Calculate opposite-type differences (with most recent low)
    oppPriceDiff  = (array.size(swingLowValues) > 0) ? highValue - array.get(swingLowValues, 0) : 0.0
    oppPctDiff = (array.size(swingLowValues) > 0) ? oppPriceDiff / array.get(swingLowValues, 0) * 100 : 0.0
    oppTimeDiff   = (array.size(swingLowBarIndexes) > 0) ? barIndex - array.get(swingLowBarIndexes, 0) : 0
    // Calculate same-type differences (with previous high)
    samePriceDiff = (array.size(swingHighValues) > 0) ? highValue - array.get(swingHighValues, 0) : 0.0
    sameTimeDiff  = (array.size(swingHighBarIndexes) > 0) ? barIndex - array.get(swingHighBarIndexes, 0) : 0
    patternH = ""
    if array.size(swingHighValues) > 0
        patternH := (highValue > array.get(swingHighValues, 0)) ? "ʜʜ" : "ʟʜ"
    labelText = ""
    if array.size(swingLowValues) > 0
        textx = delta=="Percent"?(str.tostring(oppPctDiff, format.percent)):str.tostring(oppPriceDiff, "#.##")
        labelText := str.tostring(patternH) + "\n+" + textx  + "\n⏱" + str.tostring(oppTimeDiff) //"L↑H " + str.tostring(oppPriceDiff, "#.##")
    if array.size(swingHighValues) > 0 and cyclelab
        labelText := labelText +  "\nʜɪɢʜ ᴄʏᴄʟᴇ\n"  + "⏱" + str.tostring(sameTimeDiff)   //+ str.tostring(samePriceDiff, "#.##")
    // Create label at swing high point
    newLabel = label.new(barIndex, highValue, labelText, textcolor = #6ba583,
                  style=label.style_label_down, color=color.new(#000000, 100), size=ts, text_formatting = text.format_bold)
    // Store swing high data
    array.unshift(swingHighValues, highValue)
    array.unshift(swingHighBarIndexes, barIndex)
    array.unshift(swingHighLabels, newLabel)
    // Draw lin connection betwn cons swing highs
    // if previous high exists
    if array.size(swingHighValues) > 1
        prevBar   = array.get(swingHighBarIndexes, 1)
        prevValue = array.get(swingHighValues, 1)
        newLine = rangeLines?line.new(prevBar, prevValue, barIndex, highValue, color=rnglineColor, width=1, style = line.style_solid):na
        array.unshift(highToHighLines, newLine)
        // Calculate and store differences for this high-to-high line
        priceDiff = highValue - prevValue
        timeDiff  = barIndex - prevBar
        array.unshift(highToHighPriceDiffs, priceDiff)
        array.unshift(highToHighTimeDiffs, timeDiff)
    // Draw bullish line if the last swing was 
    // (from a low to this high)
    if array.size(swingLowValues) > 0 and lastSwingType != "high"
        prevLowBar   = array.get(swingLowBarIndexes, 0)
        prevLowValue = array.get(swingLowValues, 0)
        newBullishLine = line.new(prevLowBar, prevLowValue, barIndex, highValue, color=lineUpColor, width=lw, style = line.style_solid)
        array.unshift(bullishLines, newBullishLine)
        bullishPdiff = highValue - prevLowValue
        bullishTdiff = barIndex - prevLowBar
        array.unshift(bullishPriceDiffs, bullishPdiff)
        array.unshift(bullishPrcDiffs, oppPctDiff)
        array.unshift(bullishTimeDiffs, bullishTdiff)
//}
// Updates the current swing high point 
// if a new candidate is more extreme, recalculates differences, 
// updates the label text, and updates connecting lines{
f_updateHighSwingPoint(highValue, barIndex) =>
    if highValue > array.get(swingHighValues, 0)
        array.set(swingHighValues, 0, highValue)
        array.set(swingHighBarIndexes, 0, barIndex)
        oppPriceDiff  = (array.size(swingLowValues) > 0) ? highValue - array.get(swingLowValues, 0) : 0.0
        oppPctDiff = (array.size(swingLowValues) > 0) ? oppPriceDiff / array.get(swingLowValues, 0) * 100 : 0.0
        oppTimeDiff   = (array.size(swingLowBarIndexes) > 0) ? barIndex - array.get(swingLowBarIndexes, 0) : 0
        samePriceDiff = (array.size(swingHighValues) > 1) ? highValue - array.get(swingHighValues, 1) : 0.0
        sameTimeDiff  = (array.size(swingHighBarIndexes) > 1) ? barIndex - array.get(swingHighBarIndexes, 1) : 0
        labelText = ""
        patternH = ""
        if array.size(swingHighValues) > 1
            patternH := (highValue > array.get(swingHighValues, 1)) ? "ʜʜ" : "ʟʜ"
        if array.size(swingLowValues) > 0
            textx = delta=="Percent"?(str.tostring(oppPctDiff, format.percent)):str.tostring(oppPriceDiff, "#.##")
            labelText := str.tostring(patternH) + "\n+"+ textx + "\n⏱" + str.tostring(oppTimeDiff)    //+ str.tostring(oppPriceDiff, "#.##")
        if array.size(swingHighValues) > 1 and cyclelab
            labelText := labelText + "\nʜɪɢʜ ᴄʏᴄʟᴇ\n" + "⏱" + str.tostring(sameTimeDiff)  //str.tostring(samePriceDiff, "#.##") + 
        // Update label for current swing high
        lbl = array.get(swingHighLabels, 0)
        label.set_xy(lbl, barIndex, highValue)
        label.set_text(lbl, labelText)
        // Update high-to-high connection if it exists 
        if array.size(swingHighValues) > 1 and array.size(highToHighLines) > 0
            prevBar = array.get(swingHighBarIndexes, 1)
            prevValue = array.get(swingHighValues, 1)
            line.set_xy1(array.get(highToHighLines, 0), array.get(swingHighBarIndexes, 1), array.get(swingHighValues, 1))
            line.set_xy2(array.get(highToHighLines, 0), barIndex, highValue)
            // Upd stored diffs for high-to-high connection
            array.set(highToHighPriceDiffs, 0, highValue - prevValue)
            array.set(highToHighTimeDiffs, 0, barIndex - prevBar)
        // Upd bullish connection
        if array.size(swingLowValues) > 0 and array.size(bullishLines) > 0
            prevLowBar = array.get(swingLowBarIndexes, 0)
            prevLowValue = array.get(swingLowValues, 0)
            line.set_xy1(array.get(bullishLines, 0), prevLowBar, prevLowValue)
            line.set_xy2(array.get(bullishLines, 0), barIndex, highValue)
            array.set(bullishPriceDiffs, 0, highValue - prevLowValue)
            array.set(bullishPrcDiffs, 0, (highValue - prevLowValue)/prevLowValue * 100)
            array.set(bullishTimeDiffs, 0, barIndex - prevLowBar)
    0.
//}
// Adds a new swing low point, calculates differences (same-type and cross-type),creates a label, and draws connecting lines{
f_addLowSwingPoint(lowValue, barIndex) =>
    // Calculate opposite-type differences (with most recent high)
    oppPriceDiff  = (array.size(swingHighValues) > 0) ? lowValue - array.get(swingHighValues, 0) : 0.0
    oppPctDiff = (array.size(swingHighValues) > 0) ? oppPriceDiff / array.get(swingHighValues, 0) * 100 : 0.0
    oppTimeDiff   = (array.size(swingHighBarIndexes) > 0) ? barIndex - array.get(swingHighBarIndexes, 0) : 0
    // Calculate same-type differences (with previous low)
    samePriceDiff = (array.size(swingLowValues) > 0) ? lowValue - array.get(swingLowValues, 0) : 0.0
    sameTimeDiff  = (array.size(swingLowBarIndexes) > 0) ? barIndex - array.get(swingLowBarIndexes, 0) : 0
    labelText = ""
    patternL = ""
    if array.size(swingLowValues) > 0
        patternL := (lowValue < array.get(swingLowValues, 0)) ? "ʟʟ" : "ʜʟ"
    if array.size(swingHighValues) > 0
        textx = delta=="Percent"?(str.tostring(oppPctDiff, format.percent)):str.tostring(oppPriceDiff, "#.##")
        labelText := str.tostring(patternL) + "\n" + textx + "\n⏱" + str.tostring(oppTimeDiff)   //"H↓L "+ str.tostring(oppPriceDiff, "#.##")
    if array.size(swingLowValues) > 0 and cyclelab
        labelText := labelText + "\nʟᴏᴡ ᴄʏᴄʟᴇ\n"  + "⏱" + str.tostring(sameTimeDiff)   //+ str.tostring(samePriceDiff, "#.##")
    // Create label at swing low point
    newLabel = label.new(barIndex, lowValue, labelText, textcolor = #d75442,
                  style=label.style_label_up, color=color.new(#000000, 100), size=ts, text_formatting = text.format_bold)
    // Store swing low data
    array.unshift(swingLowValues, lowValue)
    array.unshift(swingLowBarIndexes, barIndex)
    array.unshift(swingLowLabels, newLabel)
    // connection line betwn consecutive swing lows
    if array.size(swingLowValues) > 1 
        prevBar   = array.get(swingLowBarIndexes, 1)
        prevValue = array.get(swingLowValues, 1)
        newLine = rangeLines?line.new(prevBar, prevValue, barIndex, lowValue, color=rnglineColor, width=1, style = line.style_solid):na
        array.unshift(lowToLowLines, newLine)
        // Calculate and store differences for this low-to-low line
        priceDiff = lowValue - prevValue
        timeDiff  = barIndex - prevBar
        array.unshift(lowToLowPriceDiffs, priceDiff)
        array.unshift(lowToLowTimeDiffs, timeDiff)
    // Draw bearish line if the last swing was of the opposite type (from a high to this low)
    if array.size(swingHighValues) > 0 and lastSwingType != "low"
        prevHighBar   = array.get(swingHighBarIndexes, 0)
        prevHighValue = array.get(swingHighValues, 0)
        newBearishLine = line.new(prevHighBar, prevHighValue, barIndex, lowValue, color=lineDnColor, width=lw, style = line.style_solid)
        array.unshift(bearishLines, newBearishLine)
        bearishPdiff = lowValue - prevHighValue
        bearishTdiff = barIndex - prevHighBar
        array.unshift(bearishPriceDiffs, bearishPdiff)
        array.unshift(bearishPrcDiffs, oppPctDiff)
        array.unshift(bearishTimeDiffs, bearishTdiff)
//}
// Updates the current swing low point if a new is more extreme, recalculates differences, updates the lab text, and connecting lines{
f_updateLowSwingPoint(lowValue, barIndex) =>
    if lowValue < array.get(swingLowValues, 0)
        array.set(swingLowValues, 0, lowValue)
        array.set(swingLowBarIndexes, 0, barIndex)
        oppPriceDiff  = (array.size(swingHighValues) > 0) ? lowValue - array.get(swingHighValues, 0) : 0.0
        oppPctDiff = (array.size(swingHighValues) > 0) ? oppPriceDiff / array.get(swingHighValues, 0) * 100 : 0.0
        oppTimeDiff   = (array.size(swingHighBarIndexes) > 0) ? barIndex - array.get(swingHighBarIndexes, 0) : 0
        samePriceDiff = (array.size(swingLowValues) > 1) ? lowValue - array.get(swingLowValues, 1) : 0.0
        sameTimeDiff  = (array.size(swingLowBarIndexes) > 1) ? barIndex - array.get(swingLowBarIndexes, 1) : 0
        labelText = ""
        patternL = ""
        if array.size(swingLowValues) > 1
            patternL := (lowValue < array.get(swingLowValues, 1)) ? "ʟʟ" : "ʜʟ"
        if array.size(swingHighValues) > 0
            textx = delta=="Percent"?(str.tostring(oppPctDiff, format.percent)):str.tostring(oppPriceDiff, "#.##")
            labelText := str.tostring(patternL)+ "\n"+ textx + "\n⏱" + str.tostring(oppTimeDiff) //"L↑H "+ str.tostring(oppPriceDiff, "#.##")
        if array.size(swingLowValues) > 1 and cyclelab
            labelText := labelText + "\nʟᴏᴡ ᴄʏᴄʟᴇ\n"  + "⏱" + str.tostring(sameTimeDiff)   //+ str.tostring(samePriceDiff, "#.##")
        // Update label for current swing low
        lbl = array.get(swingLowLabels, 0)
        label.set_xy(lbl, barIndex, lowValue)
        label.set_text(lbl, labelText)
        // Update low-to-low connection if it exists
        if array.size(swingLowValues) > 1 and array.size(lowToLowLines) > 0
            prevBar = array.get(swingLowBarIndexes, 1)
            prevValue = array.get(swingLowValues, 1)
            line.set_xy1(array.get(lowToLowLines, 0), prevBar, prevValue)
            line.set_xy2(array.get(lowToLowLines, 0), barIndex, lowValue)
            array.set(lowToLowPriceDiffs, 0, lowValue - prevValue)
            array.set(lowToLowTimeDiffs, 0, barIndex - prevBar)
        // Update bearish connection if exists
        if array.size(swingHighValues) > 0 and array.size(bearishLines) > 0
            prevHighBar = array.get(swingHighBarIndexes, 0)
            prevHighValue = array.get(swingHighValues, 0)
            line.set_xy1(array.get(bearishLines, 0), prevHighBar, prevHighValue)
            line.set_xy2(array.get(bearishLines, 0), barIndex, lowValue)
            array.set(bearishPriceDiffs, 0, lowValue - prevHighValue)
            array.set(bearishPrcDiffs, 0, (lowValue - prevHighValue)/prevHighValue * 100)
            array.set(bearishTimeDiffs, 0, barIndex - prevHighBar)
    0.
//}
if array.size(highToHighLines) > 0 and array.size(lowToLowLines) > 0
    linefill.new(array.get(highToHighLines, 0), array.get(lowToLowLines, 0), color.rgb(0, 0, 0, 95))
// Process pivs {
var int direction = 0
direction := (not na(pH) and na(pL)) ? 1 : (not na(pL) and na(pH)) ? -1 : direction
bool directionChanged = direction != nz(direction[1])
bool bullish = direction == 1
bool bearish = direction == -1
bool bull = direction[1]==-1 and direction==1
bool bear = direction[1]==1 and direction==-1

if direction==1
    if lastSwingType != "high"
        f_addHighSwingPoint(pH, bar_index)
        lastSwingType := "high"
    else
        f_updateHighSwingPoint(pH, bar_index)

if direction==-1
    if lastSwingType != "low"
        f_addLowSwingPoint(pL, bar_index)
        lastSwingType := "low"
    else
        f_updateLowSwingPoint(pL, bar_index)
//}
// Function for geometric averaging {
f_geometric_avg(_source, _condition, _length) =>
    var float geom_avg = na
    var float[] valuesArray = array.new_float()
    if _condition
        if _source > 0
            array.push(valuesArray, _source)
            while array.size(valuesArray) > _length
                array.shift(valuesArray)
        n = array.size(valuesArray)
        if n > 0
            logSum = 0.0
            for val in valuesArray
                logSum += math.log(val)
            geom_avg := math.exp(logSum / n)
        else
            geom_avg := na
    geom_avg
var float sourcebull = na
var float sourcebear = na
var int sourcebullt = na
var int sourcebeart = na

if array.size(bullishPriceDiffs)>0 and array.size(bullishPrcDiffs)>0
    sourcebull := delta=="Percent"?array.get(bullishPrcDiffs, 0) : array.get(bullishPriceDiffs, 0)
    sourcebullt:=array.get(bullishTimeDiffs, 0)
conditionbull = lastSwingType=="low" and lastSwingType[1]== "high" 
rma_valuebull = f_geometric_avg(sourcebull, conditionbull, avgln)
rma_valuebullt = f_geometric_avg(sourcebullt, conditionbull, avgln)
if array.size(bearishPriceDiffs)>0 and array.size(bearishPrcDiffs)>0
    sourcebear := delta=="Percent"?array.get(bearishPrcDiffs, 0) : array.get(bearishPriceDiffs, 0)
    sourcebeart:=array.get(bearishTimeDiffs, 0) 
conditionbear = lastSwingType=="high" and lastSwingType[1] == "low" 
rma_valuebear = f_geometric_avg(math.abs(sourcebear), conditionbear, avgln)
rma_timebear = f_geometric_avg(sourcebeart, conditionbear, avgln)
//}
//Table{
var table_loc = locationtable == 'Top Right' ? position.top_right : locationtable == 'Bottom Right' ? position.bottom_right : locationtable == 'Top Center' ? position.top_center : locationtable == 'Top Left' ? position.top_left  : position.bottom_left
var table_size = sizetable == 'Large' ? size.large : sizetable == 'Normal' ? size.normal : sizetable == 'Small' ? size.small : size.tiny
var table = showtable ? table.new(table_loc, 16, 16, #2a2e39, #1e1e1e, 2, #1f232f, 2) : na
table_cell(column, row, txt, signal = false) =>
    table.cell(table, column, row, txt, 0, 0, signal ? #ffffff : #ffffff, text_size = table_size)
table_cell_bg(column, row, col) =>
    table.cell_set_bgcolor(table, column, row, col)
if barstate.islast and showtable
    table_cell(0, 0, "STATISTICS TABLE")
    table_cell(0, 1, "ɢᴇᴏᴍᴇᴛʀɪᴄ\nᴀᴠᴇʀᴀɢɪɴɢ")
    table_cell(1, 1, "𝞓 ᴘʀɪᴄᴇ")
    table_cell(2, 1, "𝞓 ᴛɪᴍᴇ")
    table_cell(0, 2, 'ᴜᴘᴛʀᴇɴᴅ')
    table_cell(0, 3, 'ᴅᴏᴡɴᴛʀᴇɴᴅ')
    table_cell(1, 2, "+"+str.tostring(rma_valuebull, delta=="Percent"?format.percent:format.mintick))
    table_cell(1, 3, "-"+str.tostring(rma_valuebear, delta=="Percent"?format.percent:format.mintick))
    table_cell(2, 2, str.tostring(rma_valuebullt, format.mintick))
    table_cell(2, 3, str.tostring(rma_timebear, format.mintick))
    table.cell_set_text_font_family(table, 0,0, font.family_monospace)
    table.cell_set_text_formatting(table, 1, 1, text.format_bold)
    table.cell_set_text_formatting(table, 2, 1, text.format_bold)
    table.cell_set_text_formatting(table, 0, 2, text.format_bold)
    table.cell_set_text_formatting(table, 0, 3, text.format_bold)
    table.cell_set_text_color(table, 0, 1, color.gray)
    table.cell_set_text_size(table, 0, 1, size.small)
    table.merge_cells(table, 0,0,2,0)
//}

////////////////////////////////////////////////////////////////////////////
////  SECTION 2 — FIBONACCI RETRACEMENT + GAUGE                           ///
////  Ported from CQ_(8)_Auto Fibonacci Retracement.                      ///
////  Fed by the zigzag's LAST CONFIRMED LEG (Section 1) instead of its   ///
////  own pivot engine. The retracement math is direction-agnostic        ///
////  (0% = newest pivot, 100% = older pivot), so:                        ///
////    • last leg BEARISH (ends at a Low)  → retracement reads as a      ///
////      BULLISH bounce measured up from that low                       ///
////    • last leg BULLISH (ends at a High) → retracement reads as a      ///
////      BEARISH pullback measured down from that high                  ///
////////////////////////////////////////////////////////////////////////////

var COLOR_TRANSP = color.rgb(255, 255, 255, 100)
var basicgr      = '⚙️ Master Control'

show_indicator = input.bool(true, '⚡ Enable Fibonacci Gauge', group = '🪙 F i b o n a c c i  R e t r a c e m e n t')

// ─── CLOSE PRICE PLOT ──────────────────────────────────────────────────────────
plot_gr = 'Close Price Plot'

show_close_plot  = input.bool  (false,        'Show Line Graph', group = plot_gr)
close_plot_color = input.color (color.blue, 'Color'          , inline = 'pltclose', group = plot_gr)
close_plot_width = input.int   (1,            'Width'          , minval = 1, maxval = 10, inline = 'pltclose', group = plot_gr)

_close_plot_style_raw = input.string('Line', 'Style',
     options = ['Line', 'Stepline', 'Histogram', 'Cross', 'Area', 'Columns', 'Circles'],
     group   = plot_gr)

close_plot_style = switch _close_plot_style_raw
    'Line'      => plot.style_line
    'Stepline'  => plot.style_stepline
    'Histogram' => plot.style_histogram
    'Cross'     => plot.style_cross
    'Area'      => plot.style_area
    'Columns'   => plot.style_columns
    'Circles'   => plot.style_circles
    => plot.style_line

plot(show_close_plot ? close : na, title = 'Close', color = close_plot_color, linewidth = close_plot_width, style = close_plot_style)
// ─────────────────────────────────────────────────────────────────────────────

fb250 = input(true, '25% ', inline = 'fbl', group = basicgr)
fb400 = input(true, '40% ', inline = 'fbl', group = basicgr)
fb500 = input(true, '50% ', inline = 'fbl', group = basicgr)
fb600 = input(true, '60% ', inline = 'fbl', group = basicgr)
fb750 = input(true, '75% ', inline = 'fbl', group = basicgr)
fb900 = input(true, '90%',  inline = 'fbl', group = basicgr)

// ─── COLOR SETTINGS ───────────────────────────────────────────────────────────
view_gr = 'Color Settings'

col_bull = input.color(color.rgb(255, 138,  61), 'BEARISH (▲ Now Bullish Tendency / Last Leg: BEARISH)',  inline = 'theme', group = view_gr)
col_bear = input.color(color.rgb( 38, 166, 154), 'BULLISH (▼ Now Bearish Tendency / Last Leg: BULLISH)', inline = 'theme', group = view_gr)

lbl_use_theme_color = input.bool(true, 'Use Trend Colors for Labels', inline = 'lblcol0', group = view_gr, tooltip = 'When enabled, labels follow the BULLISH/BEARISH theme colors above. Disable to set independent label colors below.')
lbl_col_bull         = input.color(color.rgb(255, 138,  61), 'Label ▲', inline = 'lblcol0', group = view_gr)
lbl_col_bear         = input.color(color.rgb( 38, 166, 154), 'Label ▼', inline = 'lblcol0', group = view_gr)

_lbl_side_raw = input.string('Right', 'Label Side (vs Gauge)', options = ['Left', 'Right'], inline = 'lblside0', group = view_gr, tooltip = 'Choose which side of the gauge the fib level labels are displayed on')
lbl_style     = _lbl_side_raw == 'Left' ? label.style_label_right : label.style_label_left
lbl_align     = _lbl_side_raw == 'Left' ? text.align_right        : text.align_left

fb_guide_draw           = input.bool (true, 'Gauge ⁞▌',                              inline = 'gauge', group = view_gr)
fb_guide_highlight_bull = input.color(color.rgb( 38, 166, 154, 40), 'Bullish Highlight ▲', inline = 'gauge', group = view_gr)
fb_guide_highlight_bear = input.color(color.rgb(255, 138,  61, 40), 'Bearish Highlight ▼', inline = 'gauge', group = view_gr)

// ─── LAYOUT ───────────────────────────────────────────────────────────────────
fb_gauge_position = input.int (defval = -2, title = 'Gauge X-Offset',            inline = 'pos', group = view_gr)
fb_line_lenght    = input.int (defval =  1, minval = 1, maxval = 9,
                                title = 'Level Tick Length (Right)',              inline = 'pos', group = view_gr)
draw_simplelabel  = input.bool(true, 'Show Price on Labels',                      inline = 'lbl', group = view_gr)

_lbl_size_raw = input.string('Small', 'Label Size',
     options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'],
     inline  = 'lbl', group = view_gr)

fb_lbl_size = switch _lbl_size_raw
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Normal' => size.normal
    'Large'  => size.large
    'Huge'   => size.huge
    => size.small

gauge_at_line_end = input.bool(false, 'Gauge at Line End  (vs Current Bar)', group = view_gr)
// ─────────────────────────────────────────────────────────────────────────────

// ─── LAST CONFIRMED LEG STYLE ──────────────────────────────────────────────────
lastleg_gr        = '♦︎ Last Confirmed Leg'
dash_last_leg     = input.bool(true, "Dash Last Leg", inline = 'lastleg1', group = lastleg_gr)
mark_last_leg     = input.bool(true, "Mark Start/End (Hollow Circles)", inline = 'lastleg1', group = lastleg_gr)

_lastleg_size_raw = input.string('Normal', 'Circle Size',
     options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'],
     group   = lastleg_gr)

lastleg_mark_size = switch _lastleg_size_raw
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Normal' => size.normal
    'Large'  => size.large
    'Huge'   => size.huge
    => size.normal
// ─────────────────────────────────────────────────────────────────────────────

[k_volume, k_open, k_close, k_high, k_low, k_hlc3, k_hlcc4, k_ohlc4, k_hl2, k_close_mintick, k_trtrue, k_atr14, k_atr14_mintick, k_rsipvt14] = request.security(syminfo.tickerid, '', [volume, open, close, high, low, hlc3, hlcc4, ohlc4, hl2, str.tostring(close, format.mintick), ta.tr(true), ta.atr(14), str.tostring(ta.atr(14), format.mintick), ta.rsi(ta.pvt, 14)])

// ─── LEG BRIDGE: pull the zigzag's last confirmed leg into the Fib engine ─────
var line  fb_lineLast   = na
var float fb_pLast      = 0.0
var int   fb_iLast      = 0
var bool  fb_isHighLast = false

fb_new_line = false

if lastSwingType == "high" and array.size(bullishLines) > 0
    // last confirmed leg is BULLISH (low → high): retracement will read BEARISH (pullback down)
    fb_new_line   := fb_lineLast != array.get(bullishLines, 0)
    fb_lineLast   := array.get(bullishLines, 0)
    fb_pLast      := array.get(swingHighValues, 0)
    fb_iLast      := array.get(swingHighBarIndexes, 0)
    fb_isHighLast := true

if lastSwingType == "low" and array.size(bearishLines) > 0
    // last confirmed leg is BEARISH (high → low): retracement will read BULLISH (bounce up)
    fb_new_line   := fb_lineLast != array.get(bearishLines, 0)
    fb_lineLast   := array.get(bearishLines, 0)
    fb_pLast      := array.get(swingLowValues, 0)
    fb_iLast      := array.get(swingLowBarIndexes, 0)
    fb_isHighLast := false

// ─── LAST CONFIRMED LEG HIGHLIGHT (dashed style + hollow circle markers) ──────
// Restyles the zigzag's own active leg line in place (it's the same object as
// bullishLines[0]/bearishLines[0]) so it visually stands out from older legs.
// When a new leg takes over, the previous one is reverted back to its normal
// solid zigzag style before the new one gets dashed.
var line  hl_activeLine  = na   // the line currently wearing the highlight
var label hl_circleStart = na
var label hl_circleEnd   = na
var bool  hl_visible     = false

if (dash_last_leg or mark_last_leg) and not na(fb_lineLast)
    // a new leg just took over: put the previous leg back to its normal solid style
    if fb_new_line and not na(hl_activeLine) and hl_activeLine != fb_lineLast
        _prevLegColor = fb_isHighLast ? lineDnColor : lineUpColor  // superseded leg was the opposite type
        line.set_style(hl_activeLine, line.style_solid)
        line.set_width(hl_activeLine, lw)
        line.set_color(hl_activeLine, _prevLegColor)

    _hlColor = fb_isHighLast ? lineUpColor : lineDnColor

    if dash_last_leg
        line.set_style(fb_lineLast, line.style_dashed)
        line.set_width(fb_lineLast, lw)
        line.set_color(fb_lineLast, _hlColor)

    if mark_last_leg
        if na(hl_circleStart)
            hl_circleStart := label.new(line.get_x1(fb_lineLast), line.get_y1(fb_lineLast), '◯',
                 style = label.style_label_center, color = color.new(#000000, 100),
                 textcolor = _hlColor, size = lastleg_mark_size)
            hl_circleEnd   := label.new(line.get_x2(fb_lineLast), line.get_y2(fb_lineLast), '◯',
                 style = label.style_label_center, color = color.new(#000000, 100),
                 textcolor = _hlColor, size = lastleg_mark_size)
            hl_circleStart := label.new(line.get_x1(fb_lineLast), line.get_y1(fb_lineLast), '◯',
                 style = label.style_label_center, color = color.new(#000000, 100),
                 textcolor = _hlColor, size = lastleg_mark_size)
            hl_circleEnd   := label.new(line.get_x2(fb_lineLast), line.get_y2(fb_lineLast), '◯',
                 style = label.style_label_center, color = color.new(#000000, 100),
                 textcolor = _hlColor, size = lastleg_mark_size)

        label.set_xy       (hl_circleStart, line.get_x1(fb_lineLast), line.get_y1(fb_lineLast))
        label.set_textcolor(hl_circleStart, _hlColor)
        label.set_size      (hl_circleStart, lastleg_mark_size)

        label.set_xy       (hl_circleEnd, line.get_x2(fb_lineLast), line.get_y2(fb_lineLast))
        label.set_textcolor(hl_circleEnd, _hlColor)
        label.set_size      (hl_circleEnd, lastleg_mark_size)
    else if hl_visible
        // markers turned off: remove them
        label.delete(hl_circleStart)
        label.delete(hl_circleEnd)
        hl_circleStart := na
        hl_circleEnd   := na

    hl_activeLine := fb_lineLast
    hl_visible    := true

if not (dash_last_leg or mark_last_leg) and hl_visible
    // feature turned off entirely: revert the line and remove the circles
    if not na(hl_activeLine)
        _revertColor = fb_isHighLast ? lineUpColor : lineDnColor
        line.set_style(hl_activeLine, line.style_solid)
        line.set_width(hl_activeLine, lw)
        line.set_color(hl_activeLine, _revertColor)
    if not na(hl_circleStart)
        label.delete(hl_circleStart)
        label.delete(hl_circleEnd)
        hl_circleStart := na
        hl_circleEnd   := na
    hl_visible := false


fb_retracement(_show, _fib_level, _switch) =>
    if not show_indicator
        bool(na)
    else
        _col      = fb_isHighLast ? col_bull : col_bear  // Reverse colors to correspond tendency
        _lbl_col  = lbl_use_theme_color ? _col : (fb_isHighLast ? lbl_col_bull : lbl_col_bear)
        _gauge_hl = fb_isHighLast ? fb_guide_highlight_bear : fb_guide_highlight_bull

        _price             = fb_pLast + (line.get_y1(fb_lineLast) - fb_pLast) * _fib_level
        _fibo_id_line_show = false
        _position          = bar_index - line.get_x2(fb_lineLast)
        _fbr_max_highest   = math.max(ta.highest(high, nz(math.max(1, _position), 1)), fb_pLast)
        _fbr_min_lowest    = math.min(ta.lowest (low,  nz(math.max(1, _position), 1)), fb_pLast)
        _fbr_line_max      = fb_pLast < _price ? _fbr_max_highest : fb_pLast > _price ? _fbr_min_lowest : fb_pLast
        _fibo_id_line_show := fb_pLast < _price and _price - k_atr14 / 4 <= _fbr_line_max ? true
                             : fb_pLast > _price and _price + k_atr14 / 4 >= _fbr_line_max ? true : false

        _gauge_x = gauge_at_line_end ? line.get_x2(fb_lineLast) : bar_index

        if _switch == 'auto' and not na(fb_lineLast)
            fibo_id_auto     = line.new(line.get_x2(fb_lineLast), _price, bar_index + 6, _price,
                                 style = line.style_solid,
                                 color = color.new(_col, _fibo_id_line_show ? 0 : 100),
                                 width = 1, extend = extend.none)
            fibo_id_ext_auto = line.new(_gauge_x + fb_gauge_position - 2, _price, _gauge_x + fb_gauge_position + 1, _price,
                                 color = color.new(_col, 0), width = 1, extend = extend.none)
            fb_label_auto    = label.new(x = _gauge_x + fb_gauge_position, y = _price,
                                 text      = str.tostring(math.round(_fib_level, 02), '000%') + (draw_simplelabel ? '\n' + str.tostring(_price, ' $00,000') : ''),
                                 textcolor = color.new(_lbl_col, 0),
                                 style     = lbl_style,
                                 textalign = lbl_align,
                                 color     = #00000000,
                                 size      = fb_lbl_size)
            line.delete (fibo_id_auto[1])
            line.delete (fibo_id_ext_auto[1])
            label.delete(fb_label_auto[1])
            if not _show
                line.delete (fibo_id_auto)
                line.delete (fibo_id_ext_auto)
                label.delete(fb_label_auto)

        if _show and _switch == ''
            var fibo_id     = line.new(fb_iLast, _price, bar_index, _price, color = color.new(_col, 0), width = 2, extend = extend.none, style = line.style_solid)  // Extremes lihes
            var fibo_id_ext = line.new(fb_iLast, _price, bar_index, _price, color = color.new(_col, 0), width = 2, extend = extend.none, style = line.style_solid)
            var fb_label    = label.new(x = bar_index, y = _price, text = '',
                                 textcolor = COLOR_TRANSP,
                                 style     = lbl_style,
                                 textalign = lbl_align,
                                 color     = color.rgb(0, 0, 0, 100),
                                 size      = fb_lbl_size)


            if not na(fb_lineLast)
                line.set_xy1   (fibo_id, _fib_level == 1.0 ? line.get_x1(fb_lineLast) : line.get_x2(fb_lineLast), _price)
                line.set_xy2   (fibo_id, _fib_level == 1.0 or _fib_level == 0.0 ? _gauge_x + fb_gauge_position - 2 : bar_index, _price)
                line.set_color (fibo_id, color.new(_col, _fib_level == 0.0 ? 0 : _fib_level == 1.0 ? 0 : _fibo_id_line_show ? 0 : 70))
                line.set_style (fibo_id, _fib_level == 0.0 or _fib_level == 1.0 ? line.style_solid : line.style_dotted)
                line.set_width (fibo_id, _fib_level == 0.0 or _fib_level == 1.0 ? 4 : 1)

                line.set_xy1  (fibo_id_ext, _gauge_x + fb_gauge_position - 1, _price)
                line.set_xy2  (fibo_id_ext, _gauge_x + fb_gauge_position + fb_line_lenght, _price)
                line.set_color(fibo_id_ext, color.new(_col, 0))
                line.set_width(fibo_id_ext, _fib_level == 0.0 or _fib_level == 1.0 or _fib_level == 0.60 ? 2 : 1)

                label.set_xy       (fb_label, _gauge_x + fb_gauge_position, _price)
                label.set_text     (fb_label, str.tostring(math.round(_fib_level, 02), '00%') + (draw_simplelabel ? '\n' + str.tostring(_price, '$0,000') : ''))
                label.set_tooltip  (fb_label, str.tostring(((_price - fb_pLast) / fb_pLast) * 100, format.percent) + ' ' + str.tostring(math.round(_price - fb_pLast, 0), '$00,000') + ' from 00% ' + str.tostring(math.round(fb_pLast, 0), '$00,000'))
                label.set_textcolor(fb_label, color.new(_lbl_col, 0))
                label.set_size     (fb_label, fb_lbl_size)

                // ── GAUGE (outer box = max/min extreme, inner box = close vs. pivot) ──────
                if _fib_level == 1.0
                    var box   fibo_box_max       = na
                    var line  fibo_line_max      = na
                    var line  fibo_line_min      = na
                    var box   fibo_box_ext       = na
                    var line  fibo_line_ext      = na
                    var label fibo_extreme_label = na
                    var bool  fibo_gauge_visible = false   // tracks whether the gauge is currently drawn

                    if fb_guide_draw
                        _extreme_price = fb_isHighLast ? _fbr_min_lowest : _fbr_max_highest
                        _extreme_chg   = (_extreme_price - fb_pLast) / fb_pLast * 100
                        _extreme_sign  = _extreme_chg >= 0 ? '▲ ' : '▼ '
                        _extreme_txt   = _extreme_sign
                                       + str.tostring(_extreme_price, '$0,000')
                                       + '\n' + str.tostring(math.round(_extreme_chg, 2), '0.0') + '%'

                        if not fibo_gauge_visible
                            // outer box: highest/lowest extreme reached since the pivot
                            fibo_box_max  := box.new (bar_index, close, bar_index, fb_pLast,
                                                  border_color = color.new(_col, 50),
                                                  border_width = 1,
                                                  border_style = line.style_dotted,
                                                  bgcolor      = color.new(color.black, 80),
                                                  text         = 'AFR',
                                                  text_valign  = text.align_top,
                                                  text_size    = size.tiny,
                                                  text_color   = color.white)
                            fibo_line_max := line.new(bar_index, close, bar_index, fb_pLast, color = color.white, width = 1)
                            fibo_line_min := line.new(bar_index, close, bar_index, fb_pLast, color = _col, width = 1)
                            // inner box: current close vs. the 0% pivot price
                            fibo_box_ext  := box.new (bar_index, close, bar_index, fb_pLast,
                                                  border_color = color.new(_col, 70),
                                                  border_width = 5,   // Gauge width
                                                  bgcolor      = color.new(_col, 70))
                            fibo_line_ext := line.new(bar_index, close, bar_index, fb_pLast, color = _gauge_hl, width = 4)
                            fibo_extreme_label := label.new(
                                                  x         = _gauge_x + fb_gauge_position - 2,
                                                  y         = _extreme_price,
                                                  text      = _extreme_txt,
                                                  textcolor = color.new(_lbl_col, 0),
                                                  style     = label.style_label_right,
                                                  textalign = text.align_right,
                                                  color     = color.new(_col, 90),
                                                  size      = fb_lbl_size)
                            fibo_gauge_visible := true

                        // outer box: max/min extreme
                        box.set_lefttop     (fibo_box_max,  _gauge_x + fb_gauge_position - 1, _fbr_max_highest)
                        box.set_rightbottom (fibo_box_max,  _gauge_x + fb_gauge_position + 1, _fbr_min_lowest)
                        box.set_border_color(fibo_box_max,  color.rgb(73, 73, 73, 30))
                        box.set_bgcolor     (fibo_box_max,  color.rgb(73, 73, 73, 50))
                        box.set_text_color  (fibo_box_max,  color.white)
                        line.set_xy1        (fibo_line_max, _gauge_x + fb_gauge_position - 1, _fbr_max_highest)
                        line.set_xy2        (fibo_line_max, _gauge_x + fb_gauge_position + 1, _fbr_max_highest)
                        line.set_xy1        (fibo_line_min, _gauge_x + fb_gauge_position - 1, _fbr_min_lowest)
                        line.set_xy2        (fibo_line_min, _gauge_x + fb_gauge_position + 1, _fbr_min_lowest)
                        line.set_color      (fibo_line_min, _col)
                        // inner box: current close vs. pivot
                        box.set_lefttop     (fibo_box_ext,  _gauge_x + fb_gauge_position,     close)
                        box.set_rightbottom (fibo_box_ext,  _gauge_x + fb_gauge_position,     fb_pLast)
                        box.set_border_color(fibo_box_ext,  color.new(_col, 50))
                        box.set_bgcolor     (fibo_box_ext,  color.new(_col, 70))
                        line.set_xy1        (fibo_line_ext, _gauge_x + fb_gauge_position,     close)
                        line.set_xy2        (fibo_line_ext, _gauge_x + fb_gauge_position,     close)
                        line.set_color      (fibo_line_ext, _gauge_hl)

                        // update every bar / left label position
                        label.set_xy       (fibo_extreme_label, _gauge_x + fb_gauge_position - 0, _extreme_price)
                        label.set_text     (fibo_extreme_label, _extreme_txt)
                        label.set_textcolor(fibo_extreme_label, color.new(_lbl_col, 0))
                        label.set_color    (fibo_extreme_label, color.new(_col, 90))
                        label.set_size     (fibo_extreme_label, fb_lbl_size)
                        label.set_style    (fibo_extreme_label, label.style_label_right)
                        label.set_textalign(fibo_extreme_label, text.align_right)

                    if not fb_guide_draw and fibo_gauge_visible
                        // toggle just turned off: remove the gauge instead of leaving it frozen on screen
                        box.delete  (fibo_box_max)
                        line.delete (fibo_line_max)
                        line.delete (fibo_line_min)
                        box.delete  (fibo_box_ext)
                        line.delete (fibo_line_ext)
                        label.delete(fibo_extreme_label)
                        fibo_gauge_visible := false

                // ── PROFIT LABEL AT 0% PIVOT ────────────────────────────────────────────
                if _fib_level == 0.0
                    var label fibo_prof_label   = na
                    var bool  fibo_prof_visible = false

                    if fb_guide_draw
                        _profit_txt = str.tostring(math.round(close - fb_pLast, 0), '$0,000')
                        if not fibo_prof_visible
                            fibo_prof_label   := label.new(bar_index, close, _profit_txt, size = fb_lbl_size)
                            fibo_prof_visible := true
                        label.set_xy       (fibo_prof_label, _gauge_x + fb_gauge_position + 4, close - 100)
                        label.set_text     (fibo_prof_label, _profit_txt)
                        label.set_tooltip  (fibo_prof_label,
                                            str.tostring(((close - fb_pLast) / fb_pLast) * 100,
                                            format.percent) + ' ' + _profit_txt + ' from 00% ' + str.tostring(math.round(fb_pLast, 0), '$00,000'))
                        label.set_color    (fibo_prof_label, color.new(_col, 100))
                        label.set_textcolor(fibo_prof_label, color.white)
                        label.set_size     (fibo_prof_label, fb_lbl_size)
                        label.set_style    (fibo_prof_label, label.style_label_right)
                        label.set_textalign(fibo_prof_label, text.align_right)

                    if not fb_guide_draw and fibo_prof_visible
                        // toggle just turned off: remove the label instead of leaving it frozen on screen
                        label.delete(fibo_prof_label)
                        fibo_prof_visible := false

        bool(na)  // explicit, consistent return type across both top-level branches

// ─── RANGE FLAGS ──────────────────────────────────────────────────────────────
fb_new = fb_pLast[1] != fb_pLast or fb_new_line or fb_iLast[1] != fb_iLast

fb_height    = line.get_y1(fb_lineLast) - fb_pLast
fb_k_low_cr  = ta.lowest (k_low,  2)
fb_k_high_cr = ta.highest(k_high, 2)

fb_over_1500  = fb_height < 0 and fb_k_low_cr  < fb_height * 1.500 + fb_pLast or fb_height > 0 and fb_k_high_cr > fb_height * 1.500 + fb_pLast
fb_over_1     = fb_height < 0 and fb_k_low_cr  < line.get_y1(fb_lineLast)      or fb_height > 0 and fb_k_high_cr > line.get_y1(fb_lineLast)
fb_over_1000  = fb_height < 0 and fb_k_low_cr  < fb_height * 0.750 + fb_pLast  or fb_height > 0 and fb_k_high_cr > fb_height * 0.750 + fb_pLast
fb_under_0    = fb_height < 0 and fb_k_low_cr  > fb_pLast                       or fb_height > 0 and fb_k_high_cr < fb_pLast
fb_under_1000 = fb_height < 0 and fb_k_low_cr  > fb_height * -0.400 + fb_pLast  or fb_height > 0 and fb_k_high_cr < fb_height * -0.400 + fb_pLast
fb_under_1500 = fb_height < 0 and fb_k_low_cr  > fb_height * -0.500 + fb_pLast  or fb_height > 0 and fb_k_high_cr < fb_height * -0.500 + fb_pLast
fb_under_m1   = fb_height < 0 and fb_k_low_cr  > fb_height * -1     + fb_pLast  or fb_height > 0 and fb_k_high_cr < fb_height * -1     + fb_pLast

// ─── DRAW ─────────────────────────────────────────────────────────────────────
fb_retracement(fb_under_m1  , -2.000, 'auto')
fb_retracement(fb_under_1500, -1.500, 'auto')
fb_retracement(fb_under_1000, -1.000, 'auto')
fb_retracement(fb_under_0   , -0.500, 'auto')
fb_retracement(true         , -0.250, 'auto')
fb_retracement(true         ,  0.000, '')
fb_retracement(fb250        ,  0.250, '')
fb_retracement(fb400        ,  0.400, '')
fb_retracement(fb500        ,  0.500, '')
fb_retracement(fb600        ,  0.600, '')
fb_retracement(fb750        ,  0.750, '')
fb_retracement(fb900        ,  0.900, '')
fb_retracement(true         ,  1.000, '')
fb_retracement(fb_over_1000 ,  1.250, 'auto')
fb_retracement(fb_over_1    ,  1.500, 'auto')
fb_retracement(fb_over_1500 ,  2.000, 'auto')

////////////////////////////////////////////////////////////////////////////
////  END                                                                 ///
////////////////////////////////////////////////////////////////////////////

//EOF
````
