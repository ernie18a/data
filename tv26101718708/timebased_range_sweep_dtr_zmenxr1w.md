# Time-Based Range Sweep (DTR)

- url: https://www.tradingview.com/script/ZmenXr1W-Time-Based-Range-Sweep-DTR/
- type: indicator
- pine_id: PUB;271d87bb0ea44c539b954a90614651cf
- version: 1.0

## Description

SUGGESTED TITLE
Time-Based Range Sweep (TBRS)

SHORT TITLE
TBRS

---

OVERVIEW

Time-Based Range Sweep builds a price range from two user-defined intraday time windows, waits for price to sweep one side of that range after the window closes, and then looks for a specific reversal confirmation before marking an entry, a stop area, and a target area.

The idea behind it is simple: a fixed block of time produces a high and a low. Once that block is finished, those two levels sit on the chart as reference liquidity. Price often runs one side of them before moving in the opposite direction. This script automates the bookkeeping around that sequence — drawing the range, flagging which side was swept, waiting for a confirmation you select, and projecting the resulting levels forward so you are not measuring them by hand.

Each range is independent and each range produces at most one signal per day.

---

HOW IT WORKS

1. RANGE CONSTRUCTION

Two session windows can be enabled independently. Both are interpreted in a timezone you choose (default America/New_York), so the ranges stay anchored to the same clock time regardless of your chart's display timezone.

While a window is open, the script tracks the running highest high and lowest low of every bar inside it, drawing a live box and two solid boundary lines that expand as the window develops. When the window closes, the box is finalized, and dotted or dashed projection lines carry the high and the low forward for a configurable number of bars. Optional labels mark the range title, TBR RANGE HIGH, and TBR RANGE LOW.

Defaults are 01:12–02:12 and 08:12–09:12 New York time, but both windows are fully editable — any two intraday blocks can be used.

2. SWEEP DETECTION

Sweep logic only becomes active after the window has closed. The first bar that trades beyond either boundary is registered as the sweep for that range:

- A bar trading below the range low is a low sweep, which sets a long bias.
- A bar trading above the range high is a high sweep, which sets a short bias.

"Sweep must reclaim range" is on by default. With it enabled, a wick through the level is not enough — the bar must also close back inside the range for the sweep to count, which filters out bars that simply break the level and keep going. Turning it off accepts any penetration of the boundary.

Only the first sweep after each window is used. Once a side has been taken, the range stops looking for further sweeps until the next session.

3. CONFIRMATION MODELS

After a sweep is registered, the script waits for one of three confirmations. You pick which one is active, or choose Any Confirmation and take whichever appears first.

3 Candle Reversal — After the sweep, the script counts consecutive bars closing against the anticipated direction (down closes following a low sweep, up closes following a high sweep) and records the high and low of that sequence. The counter resets if the run is broken before it reaches three. Once at least three have accumulated, the signal fires on a close beyond the sequence extreme — above the sequence high for longs, below the sequence low for shorts.

CISD — A close through the three-bar structural extreme: above the highest high of the previous three bars for longs, below the lowest low of the previous three bars for shorts.

IFVG — A displacement gap in the direction of the bias. For longs, the current bar's low prints above the high from two bars back; for shorts, the current bar's high prints below the low from two bars back.

All confirmations are evaluated on confirmed bar closes, so signals do not appear and disappear intrabar.

4. STOP PLACEMENT

When a signal fires, the stop reference is the most recent confirmed swing pivot that formed at or after the sweep bar — a pivot low for longs, a pivot high for shorts. Pivot strictness is set by the left and right bar inputs.

Because a confirmed pivot requires a fixed number of bars on both sides, fast setups can trigger before one exists. In that case the script falls back to the lowest low or highest high over a configurable lookback. A tick buffer is then applied beyond whichever reference was used.

5. PROJECTION

Three objects are drawn forward from the confirmation bar for a set number of bars:

- Entry level — a horizontal line at the confirmation close, labeled with which confirmation produced it.
- Stop zone — a shaded area between the entry and the calculated stop.
- Target zone — a shaded area between the entry and the opposite side of the range. A long that came from a low sweep targets the range high; a short that came from a high sweep targets the range low.

The target zone is a reference for the measured objective of the setup, not a projection of where price will go.

---

SETTINGS

SESSIONS
- Show London range / Show New York range — enable each window independently.
- Range time — the time window for each range.
- Range label — text shown in the center of each finished box.
- Session timezone — IANA timezone used to interpret both windows.
- Projection bars — how far entry, stop, and target objects extend.
- Extended range line bars — how far the dotted or dashed boundary lines extend past the window.

SWEEP AND CONFIRMATION
- Confirmation mode — 3 Candle Reversal, IFVG, CISD, or Any Confirmation.
- Sweep must reclaim range — require a close back inside the range for a valid sweep.
- Pivot left bars / Pivot right bars — swing strictness for stop placement.
- Stop fallback lookback — used when no confirmed pivot exists between sweep and entry.
- Stop buffer ticks — additional distance beyond the stop reference.

VISUALS
- Entry markers with independent long and short colors and five size options.
- Toggles for target and stop zones, range labels, entry level, and entry type text.
- Label vertical offset and label size.

STYLE
- Colors for range fill, range border, target zone, stop zone, and entry level.
- Extended line style: dotted or dashed.

---

HOW TO USE IT

Set both windows to the time blocks you actually trade and confirm the session timezone matches how you think about those times. The defaults are New York time, so a window entered as 01:12–02:12 is 01:12 New York regardless of where your chart is set.

Intraday timeframes are required, and the timeframe should divide cleanly into the window length so the range is built from a sensible number of bars. A 60-minute window on a 1, 3, 5, or 15 minute chart works; the same window on a 4-hour chart does not.

Start with a single confirmation mode rather than Any Confirmation. The three models have different characteristics: 3 Candle Reversal is the slowest and requires a developed base, CISD is the most immediate, and IFVG requires visible displacement. Any Confirmation takes whichever fires first, which will usually be the fastest of the three.

Tune the pivot inputs to your timeframe. Wider pivot settings produce more meaningful swing stops but increase how often the fallback lookback is used instead.

---

ALERTS

Five alert conditions are available:
- London range confirmation long
- London range confirmation short
- New York range confirmation long
- New York range confirmation short
- Any range confirmation signal

Each fires on the close of the confirmation bar and includes ticker and interval placeholders.

---

NOTES AND LIMITATIONS

- One signal maximum per range per day. Once a range has produced a confirmation, it stops evaluating until the next session.
- Range boxes and boundary lines update live while a window is open. Signals, zones, and entry levels are drawn on confirmed closes only.
- Drawing objects are capped at 500 boxes, lines, and labels. On very long chart histories the oldest objects will be removed by TradingView automatically.
- Sessions are evaluated with the chart's own bars, so illiquid symbols with gaps inside a window may produce ranges built from very few bars.
- Stop and target areas are geometric references derived from the range and recent structure. They are not orders, not backtested results, and carry no assumption about outcome.

---

ORIGINALITY

This is an original implementation written from scratch in Pine Script v6. The individual concepts it draws on — session ranges, liquidity sweeps, change in state of delivery, and inverse fair value gaps — are widely discussed public trading concepts, and no claim of ownership is made over them. What this script contributes is the specific pipeline that links them: an arbitrary time-defined range, an optional reclaim-filtered first sweep, a selectable confirmation stage, a pivot-based stop with a lookback fallback, and a target anchored to the opposite range boundary — all handled per-session with independent state for two windows.

---

DISCLAIMER

This indicator is provided for educational and informational purposes. It does not produce financial advice, and nothing it draws should be treated as a recommendation to buy or sell. Signals are historical observations of price behavior and do not predict future movement. Test any tool thoroughly on your own instruments and timeframes before risking capital, and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("Time-Based Range Sweep", "TBRS", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// --- Constants ---
const string GROUP_SESSIONS = "Sessions"
const string GROUP_SIGNALS = "Sweep & Confirmation"
const string GROUP_STYLE = "Style"
const string GROUP_VISUALS = "Visuals"
const string NEW_YORK_TZ = "America/New_York"
const color BULL_COLOR = #089981
const color BEAR_COLOR = #f23645
const color RANGE_FILL_DEFAULT = #0c514b
const color RANGE_BORDER_DEFAULT = #d4515d
const color TARGET_ZONE_DEFAULT = #2f7d3c
const color STOP_ZONE_DEFAULT = #98445f
const color ENTRY_LINE_DEFAULT = #8aa8e8
const int REVERSAL_CANDLE_COUNT = 3

// --- Inputs ---
showLondonInput = input.bool(true, "Show London range", group = GROUP_SESSIONS, tooltip = "Builds the first range using the selected timezone window.")
londonSessionInput = input.session("0112-0212", "London range time", group = GROUP_SESSIONS, tooltip = "Time window used to build the London range.")
londonRangeLabelInput = input.string("London Time Based Range\n(1:12AM - 2:12AM)", "London range label", group = GROUP_SESSIONS, tooltip = "Text displayed in the center of the London range box.")
showNewYorkInput = input.bool(true, "Show New York range", group = GROUP_SESSIONS, tooltip = "Builds the second range using the selected timezone window.")
newYorkSessionInput = input.session("0812-0912", "New York range time", group = GROUP_SESSIONS, tooltip = "Time window used to build the New York range.")
newYorkRangeLabelInput = input.string("New York Time Based Range\n(8:12AM - 9:12AM)", "New York range label", group = GROUP_SESSIONS, tooltip = "Text displayed in the center of the New York range box.")
timezoneInput = input.string(NEW_YORK_TZ, "Session timezone", group = GROUP_SESSIONS, tooltip = "IANA timezone used to interpret both range windows.")
projectionBarsInput = input.int(24, "Projection bars", minval = 1, maxval = 200, group = GROUP_SESSIONS, tooltip = "Number of chart bars for which trade zones and entry levels remain visible.")
extendedLineBarsInput = input.int(24, "Extended range line bars", minval = 1, maxval = 500, group = GROUP_SESSIONS, tooltip = "Number of future chart bars used to extend the dotted or dashed range lines.")

entryModeInput = input.string("3 Candle Reversal", "Confirmation mode", options = ["3 Candle Reversal", "IFVG", "CISD", "Any Confirmation"], group = GROUP_SIGNALS, tooltip = "Choose one confirmation or Any Confirmation. In Any Confirmation mode, the first valid 3 Candle Reversal, IFVG, or CISD signal triggers the entry.")
requireReclaimInput = input.bool(true, "Sweep must reclaim range", group = GROUP_SIGNALS, tooltip = "Only accept a sweep when the candle closes back inside the range.")
pivotLeftBarsInput = input.int(2, "Pivot left bars", minval = 1, maxval = 10, group = GROUP_SIGNALS, tooltip = "Number of bars required on the left side of a pivot used for the stop.")
pivotRightBarsInput = input.int(2, "Pivot right bars", minval = 1, maxval = 10, group = GROUP_SIGNALS, tooltip = "Number of confirmed bars required on the right side of a pivot used for the stop.")
stopFallbackLookbackInput = input.int(8, "Stop fallback lookback", minval = 2, maxval = 50, group = GROUP_SIGNALS, tooltip = "Fallback lookback used when no confirmed pivot exists between the sweep and entry.")
stopBufferTicksInput = input.int(1, "Stop buffer ticks", minval = 0, maxval = 100, group = GROUP_SIGNALS, tooltip = "Places the stop this many minimum ticks beyond the selected pivot.")

showSignalsInput = input.bool(true, "Show entry markers", group = GROUP_VISUALS, tooltip = "Plots a circle at the high or low of the entry candle.")
longMarkerColorInput = input.color(BULL_COLOR, "Long marker color", group = GROUP_VISUALS, tooltip = "Color of long confirmation circles.")
shortMarkerColorInput = input.color(BEAR_COLOR, "Short marker color", group = GROUP_VISUALS, tooltip = "Color of short confirmation circles.")
markerSizeInput = input.string("Small", "Marker size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GROUP_VISUALS, tooltip = "Controls the size of long and short confirmation circles.")
showTradeZonesInput = input.bool(true, "Show target and stop zones", group = GROUP_VISUALS, tooltip = "Draws projected target, entry, and stop areas from the confirmation candle.")
showLabelsInput = input.bool(true, "Show range labels", group = GROUP_VISUALS, tooltip = "Displays the range title, boundary labels, and sweep direction.")
showEntryLevelInput = input.bool(true, "Show entry level", group = GROUP_VISUALS, tooltip = "Draws the horizontal entry level and the confirmation type at the end of the line.")
showEntryTypeInput = input.bool(true, "Show entry type", group = GROUP_VISUALS, tooltip = "Adds 3 Candle Reversal Entry, IFVG Entry, or CISD Entry to the end of each entry line.")
labelOffsetTicksInput = input.int(12, "Label vertical offset", minval = 0, maxval = 1000, group = GROUP_VISUALS, tooltip = "Moves range and sweep labels away from their reference lines.")
labelSizeInput = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = GROUP_VISUALS, tooltip = "Controls the size of range, sweep, and entry labels.")

rangeFillColorInput = input.color(color.new(RANGE_FILL_DEFAULT, 72), "Range fill", group = GROUP_STYLE, tooltip = "Fill color for the time-based ranges.")
rangeBorderColorInput = input.color(RANGE_BORDER_DEFAULT, "Range border", group = GROUP_STYLE, tooltip = "Color of the range high and low lines.")
targetZoneColorInput = input.color(color.new(TARGET_ZONE_DEFAULT, 72), "Target zone", group = GROUP_STYLE, tooltip = "Color of the projected target area.")
stopZoneColorInput = input.color(color.new(STOP_ZONE_DEFAULT, 68), "Stop zone", group = GROUP_STYLE, tooltip = "Color of the projected stop area.")
entryLineColorInput = input.color(ENTRY_LINE_DEFAULT, "Entry level", group = GROUP_STYLE, tooltip = "Color of the projected entry level.")
extendedLineStyleInput = input.string("Dotted", "Extended line style", options = ["Dotted", "Dashed"], group = GROUP_STYLE, tooltip = "Style used for range high and low lines after the session ends.")

// --- Derived settings ---
labelSize = labelSizeInput == "Tiny" ? size.tiny : labelSizeInput == "Normal" ? size.normal : size.small
labelOffsetPrice = syminfo.mintick * labelOffsetTicksInput
stopBufferPrice = syminfo.mintick * stopBufferTicksInput
extendedLineStyle = extendedLineStyleInput == "Dotted" ? line.style_dotted : line.style_dashed

// --- Helper functions ---
confirmationSelected(string modeName) =>
    entryModeInput == modeName or entryModeInput == "Any Confirmation"

// --- Pivot data used by both sessions ---
pivotLowPrice = ta.pivotlow(low, pivotLeftBarsInput, pivotRightBarsInput)
pivotHighPrice = ta.pivothigh(high, pivotLeftBarsInput, pivotRightBarsInput)
lastPivotLow = ta.valuewhen(not na(pivotLowPrice), pivotLowPrice, 0)
lastPivotHigh = ta.valuewhen(not na(pivotHighPrice), pivotHighPrice, 0)
lastPivotLowBar = ta.valuewhen(not na(pivotLowPrice), bar_index - pivotRightBarsInput, 0)
lastPivotHighBar = ta.valuewhen(not na(pivotHighPrice), bar_index - pivotRightBarsInput, 0)
fallbackStopLow = ta.lowest(low[1], stopFallbackLookbackInput)
fallbackStopHigh = ta.highest(high[1], stopFallbackLookbackInput)

// --- Session state: London ---
londonInSession = showLondonInput and not na(time(timeframe.period, londonSessionInput, timezoneInput))
londonSessionStarted = londonInSession and not londonInSession[1]
londonSessionEnded = not londonInSession and londonInSession[1]

var float londonHigh = na
var float londonLow = na
var int londonStartBar = na
var int londonSweepBar = na
var int londonSweepSide = 0
var float londonSweepExtreme = na
var int londonOppositeCount = 0
var float londonSequenceHigh = na
var float londonSequenceLow = na
var bool londonSequenceReady = false
var bool londonTradeDone = false
var box londonRangeBox = na
var line londonHighLine = na
var line londonLowLine = na

if londonSessionStarted
    londonHigh := high
    londonLow := low
    londonStartBar := bar_index
    londonSweepBar := na
    londonSweepSide := 0
    londonSweepExtreme := na
    londonOppositeCount := 0
    londonSequenceHigh := na
    londonSequenceLow := na
    londonSequenceReady := false
    londonTradeDone := false
    londonRangeBox := box.new(left = bar_index, top = high, right = bar_index, bottom = low, xloc = xloc.bar_index, bgcolor = rangeFillColorInput, border_color = rangeBorderColorInput, border_width = 1)
    londonHighLine := line.new(x1 = bar_index, y1 = high, x2 = bar_index, y2 = high, xloc = xloc.bar_index, color = rangeBorderColorInput, width = 2)
    londonLowLine := line.new(x1 = bar_index, y1 = low, x2 = bar_index, y2 = low, xloc = xloc.bar_index, color = rangeBorderColorInput, width = 2)

if londonInSession
    londonHigh := math.max(nz(londonHigh, high), high)
    londonLow := math.min(nz(londonLow, low), low)
    if not na(londonRangeBox)
        box.set_right(londonRangeBox, bar_index)
        box.set_top(londonRangeBox, londonHigh)
        box.set_bottom(londonRangeBox, londonLow)
    if not na(londonHighLine)
        line.set_y1(londonHighLine, londonHigh)
        line.set_y2(londonHighLine, londonHigh)
        line.set_x2(londonHighLine, bar_index)
    if not na(londonLowLine)
        line.set_y1(londonLowLine, londonLow)
        line.set_y2(londonLowLine, londonLow)
        line.set_x2(londonLowLine, bar_index)

if londonSessionEnded
    int londonEndBar = bar_index - 1
    int londonMidBar = londonStartBar + int(math.floor((londonEndBar - londonStartBar) / 2.0))
    if not na(londonRangeBox)
        box.set_right(londonRangeBox, londonEndBar)
    if not na(londonHighLine)
        line.set_x2(londonHighLine, londonEndBar)
    if not na(londonLowLine)
        line.set_x2(londonLowLine, londonEndBar)
    line.new(x1 = londonEndBar, y1 = londonHigh, x2 = londonEndBar + extendedLineBarsInput, y2 = londonHigh, xloc = xloc.bar_index, color = rangeBorderColorInput, style = extendedLineStyle, width = 2)
    line.new(x1 = londonEndBar, y1 = londonLow, x2 = londonEndBar + extendedLineBarsInput, y2 = londonLow, xloc = xloc.bar_index, color = rangeBorderColorInput, style = extendedLineStyle, width = 2)
    if showLabelsInput
        label.new(x = londonMidBar, y = (londonHigh + londonLow) / 2.0, text = londonRangeLabelInput, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(chart.bg_color, 100), textcolor = chart.fg_color, size = labelSize)
        label.new(x = londonEndBar, y = londonHigh + labelOffsetPrice, text = "TBR RANGE HIGH", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = rangeBorderColorInput, size = labelSize)
        label.new(x = londonEndBar, y = londonLow - labelOffsetPrice, text = "TBR RANGE LOW", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = rangeBorderColorInput, size = labelSize)

if not londonInSession and not na(londonHigh) and not londonTradeDone and na(londonSweepBar)
    londonLowSweep = low < londonLow and (not requireReclaimInput or close > londonLow)
    londonHighSweep = high > londonHigh and (not requireReclaimInput or close < londonHigh)
    if londonLowSweep or londonHighSweep
        londonSweepBar := bar_index
        londonSweepSide := londonLowSweep ? 1 : -1
        londonSweepExtreme := londonLowSweep ? low : high
        londonOppositeCount := 0
        londonSequenceHigh := na
        londonSequenceLow := na
        londonSequenceReady := false
        if showLabelsInput
            label.new(x = bar_index, y = londonLowSweep ? low - labelOffsetPrice : high + labelOffsetPrice, text = londonLowSweep ? "London low sweep" : "London high sweep", xloc = xloc.bar_index, yloc = yloc.price, style = londonLowSweep ? label.style_label_up : label.style_label_down, color = color.new(chart.bg_color, 100), textcolor = londonLowSweep ? BULL_COLOR : BEAR_COLOR, size = labelSize)

if not londonInSession and not na(londonSweepBar) and not londonTradeDone and bar_index > londonSweepBar
    if londonSweepSide == 1
        if close < open
            londonOppositeCount += 1
            londonSequenceHigh := londonOppositeCount == 1 ? high : math.max(londonSequenceHigh, high)
            londonSequenceLow := londonOppositeCount == 1 ? low : math.min(londonSequenceLow, low)
            londonSequenceReady := londonOppositeCount >= REVERSAL_CANDLE_COUNT
        else if not londonSequenceReady
            londonOppositeCount := 0
            londonSequenceHigh := na
            londonSequenceLow := na
    else if londonSweepSide == -1
        if close > open
            londonOppositeCount += 1
            londonSequenceHigh := londonOppositeCount == 1 ? high : math.max(londonSequenceHigh, high)
            londonSequenceLow := londonOppositeCount == 1 ? low : math.min(londonSequenceLow, low)
            londonSequenceReady := londonOppositeCount >= REVERSAL_CANDLE_COUNT
        else if not londonSequenceReady
            londonOppositeCount := 0
            londonSequenceHigh := na
            londonSequenceLow := na

londonSetupActive = not londonInSession and not na(londonSweepBar) and bar_index > londonSweepBar
londonStructureHigh = ta.highest(high[1], 3)
londonStructureLow = ta.lowest(low[1], 3)
londonLongThree = londonSetupActive and londonSweepSide == 1 and londonSequenceReady and close > londonSequenceHigh
londonShortThree = londonSetupActive and londonSweepSide == -1 and londonSequenceReady and close < londonSequenceLow
londonLongCisd = londonSetupActive and londonSweepSide == 1 and not na(londonStructureHigh) and close > londonStructureHigh
londonShortCisd = londonSetupActive and londonSweepSide == -1 and not na(londonStructureLow) and close < londonStructureLow
londonLongIfvg = londonSetupActive and londonSweepSide == 1 and not na(high[2]) and low > high[2]
londonShortIfvg = londonSetupActive and londonSweepSide == -1 and not na(low[2]) and high < low[2]
londonLongConfirmation = (confirmationSelected("3 Candle Reversal") and londonLongThree) or (confirmationSelected("IFVG") and londonLongIfvg) or (confirmationSelected("CISD") and londonLongCisd)
londonShortConfirmation = (confirmationSelected("3 Candle Reversal") and londonShortThree) or (confirmationSelected("IFVG") and londonShortIfvg) or (confirmationSelected("CISD") and londonShortCisd)
londonLongSignal = barstate.isconfirmed and not londonTradeDone and londonLongConfirmation
londonShortSignal = barstate.isconfirmed and not londonTradeDone and londonShortConfirmation
londonLongEntryType = entryModeInput == "3 Candle Reversal" or (entryModeInput == "Any Confirmation" and londonLongThree) ? "3 Candle Reversal Entry" : entryModeInput == "IFVG" or (entryModeInput == "Any Confirmation" and londonLongIfvg) ? "IFVG Entry" : "CISD Entry"
londonShortEntryType = entryModeInput == "3 Candle Reversal" or (entryModeInput == "Any Confirmation" and londonShortThree) ? "3 Candle Reversal Entry" : entryModeInput == "IFVG" or (entryModeInput == "Any Confirmation" and londonShortIfvg) ? "IFVG Entry" : "CISD Entry"
londonLongEntryText = showEntryTypeInput ? londonLongEntryType : "Entry"
londonShortEntryText = showEntryTypeInput ? londonShortEntryType : "Entry"
londonLongStopBase = not na(lastPivotLow) and not na(lastPivotLowBar) and lastPivotLowBar >= londonSweepBar ? lastPivotLow : fallbackStopLow
londonShortStopBase = not na(lastPivotHigh) and not na(lastPivotHighBar) and lastPivotHighBar >= londonSweepBar ? lastPivotHigh : fallbackStopHigh
londonLongStop = nz(londonLongStopBase, low) - stopBufferPrice
londonShortStop = nz(londonShortStopBase, high) + stopBufferPrice

if londonLongSignal
    londonTradeDone := true
    if showTradeZonesInput
        box.new(left = bar_index, top = math.max(londonHigh, close), right = bar_index + projectionBarsInput, bottom = math.min(londonHigh, close), xloc = xloc.bar_index, bgcolor = targetZoneColorInput, border_color = color.new(BULL_COLOR, 100))
        box.new(left = bar_index, top = math.max(close, londonLongStop), right = bar_index + projectionBarsInput, bottom = math.min(close, londonLongStop), xloc = xloc.bar_index, bgcolor = stopZoneColorInput, border_color = color.new(BEAR_COLOR, 100))
    if showEntryLevelInput
        line.new(x1 = bar_index, y1 = close, x2 = bar_index + projectionBarsInput, y2 = close, xloc = xloc.bar_index, color = entryLineColorInput, width = 2)
        label.new(x = bar_index + projectionBarsInput, y = close, text = londonLongEntryText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = entryLineColorInput, size = labelSize)

if londonShortSignal
    londonTradeDone := true
    if showTradeZonesInput
        box.new(left = bar_index, top = math.max(londonShortStop, close), right = bar_index + projectionBarsInput, bottom = math.min(londonShortStop, close), xloc = xloc.bar_index, bgcolor = stopZoneColorInput, border_color = color.new(BEAR_COLOR, 100))
        box.new(left = bar_index, top = math.max(close, londonLow), right = bar_index + projectionBarsInput, bottom = math.min(close, londonLow), xloc = xloc.bar_index, bgcolor = targetZoneColorInput, border_color = color.new(BEAR_COLOR, 100))
    if showEntryLevelInput
        line.new(x1 = bar_index, y1 = close, x2 = bar_index + projectionBarsInput, y2 = close, xloc = xloc.bar_index, color = entryLineColorInput, width = 2)
        label.new(x = bar_index + projectionBarsInput, y = close, text = londonShortEntryText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = entryLineColorInput, size = labelSize)

// --- Session state: New York ---
newYorkInSession = showNewYorkInput and not na(time(timeframe.period, newYorkSessionInput, timezoneInput))
newYorkSessionStarted = newYorkInSession and not newYorkInSession[1]
newYorkSessionEnded = not newYorkInSession and newYorkInSession[1]

var float newYorkHigh = na
var float newYorkLow = na
var int newYorkStartBar = na
var int newYorkSweepBar = na
var int newYorkSweepSide = 0
var float newYorkSweepExtreme = na
var int newYorkOppositeCount = 0
var float newYorkSequenceHigh = na
var float newYorkSequenceLow = na
var bool newYorkSequenceReady = false
var bool newYorkTradeDone = false
var box newYorkRangeBox = na
var line newYorkHighLine = na
var line newYorkLowLine = na

if newYorkSessionStarted
    newYorkHigh := high
    newYorkLow := low
    newYorkStartBar := bar_index
    newYorkSweepBar := na
    newYorkSweepSide := 0
    newYorkSweepExtreme := na
    newYorkOppositeCount := 0
    newYorkSequenceHigh := na
    newYorkSequenceLow := na
    newYorkSequenceReady := false
    newYorkTradeDone := false
    newYorkRangeBox := box.new(left = bar_index, top = high, right = bar_index, bottom = low, xloc = xloc.bar_index, bgcolor = rangeFillColorInput, border_color = rangeBorderColorInput, border_width = 1)
    newYorkHighLine := line.new(x1 = bar_index, y1 = high, x2 = bar_index, y2 = high, xloc = xloc.bar_index, color = rangeBorderColorInput, width = 2)
    newYorkLowLine := line.new(x1 = bar_index, y1 = low, x2 = bar_index, y2 = low, xloc = xloc.bar_index, color = rangeBorderColorInput, width = 2)

if newYorkInSession
    newYorkHigh := math.max(nz(newYorkHigh, high), high)
    newYorkLow := math.min(nz(newYorkLow, low), low)
    if not na(newYorkRangeBox)
        box.set_right(newYorkRangeBox, bar_index)
        box.set_top(newYorkRangeBox, newYorkHigh)
        box.set_bottom(newYorkRangeBox, newYorkLow)
    if not na(newYorkHighLine)
        line.set_y1(newYorkHighLine, newYorkHigh)
        line.set_y2(newYorkHighLine, newYorkHigh)
        line.set_x2(newYorkHighLine, bar_index)
    if not na(newYorkLowLine)
        line.set_y1(newYorkLowLine, newYorkLow)
        line.set_y2(newYorkLowLine, newYorkLow)
        line.set_x2(newYorkLowLine, bar_index)

if newYorkSessionEnded
    int newYorkEndBar = bar_index - 1
    int newYorkMidBar = newYorkStartBar + int(math.floor((newYorkEndBar - newYorkStartBar) / 2.0))
    if not na(newYorkRangeBox)
        box.set_right(newYorkRangeBox, newYorkEndBar)
    if not na(newYorkHighLine)
        line.set_x2(newYorkHighLine, newYorkEndBar)
    if not na(newYorkLowLine)
        line.set_x2(newYorkLowLine, newYorkEndBar)
    line.new(x1 = newYorkEndBar, y1 = newYorkHigh, x2 = newYorkEndBar + extendedLineBarsInput, y2 = newYorkHigh, xloc = xloc.bar_index, color = rangeBorderColorInput, style = extendedLineStyle, width = 2)
    line.new(x1 = newYorkEndBar, y1 = newYorkLow, x2 = newYorkEndBar + extendedLineBarsInput, y2 = newYorkLow, xloc = xloc.bar_index, color = rangeBorderColorInput, style = extendedLineStyle, width = 2)
    if showLabelsInput
        label.new(x = newYorkMidBar, y = (newYorkHigh + newYorkLow) / 2.0, text = newYorkRangeLabelInput, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(chart.bg_color, 100), textcolor = chart.fg_color, size = labelSize)
        label.new(x = newYorkEndBar, y = newYorkHigh + labelOffsetPrice, text = "TBR RANGE HIGH", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = rangeBorderColorInput, size = labelSize)
        label.new(x = newYorkEndBar, y = newYorkLow - labelOffsetPrice, text = "TBR RANGE LOW", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = rangeBorderColorInput, size = labelSize)

if not newYorkInSession and not na(newYorkHigh) and not newYorkTradeDone and na(newYorkSweepBar)
    newYorkLowSweep = low < newYorkLow and (not requireReclaimInput or close > newYorkLow)
    newYorkHighSweep = high > newYorkHigh and (not requireReclaimInput or close < newYorkHigh)
    if newYorkLowSweep or newYorkHighSweep
        newYorkSweepBar := bar_index
        newYorkSweepSide := newYorkLowSweep ? 1 : -1
        newYorkSweepExtreme := newYorkLowSweep ? low : high
        newYorkOppositeCount := 0
        newYorkSequenceHigh := na
        newYorkSequenceLow := na
        newYorkSequenceReady := false
        if showLabelsInput
            label.new(x = bar_index, y = newYorkLowSweep ? low - labelOffsetPrice : high + labelOffsetPrice, text = newYorkLowSweep ? "New York low sweep" : "New York high sweep", xloc = xloc.bar_index, yloc = yloc.price, style = newYorkLowSweep ? label.style_label_up : label.style_label_down, color = color.new(chart.bg_color, 100), textcolor = newYorkLowSweep ? BULL_COLOR : BEAR_COLOR, size = labelSize)

if not newYorkInSession and not na(newYorkSweepBar) and not newYorkTradeDone and bar_index > newYorkSweepBar
    if newYorkSweepSide == 1
        if close < open
            newYorkOppositeCount += 1
            newYorkSequenceHigh := newYorkOppositeCount == 1 ? high : math.max(newYorkSequenceHigh, high)
            newYorkSequenceLow := newYorkOppositeCount == 1 ? low : math.min(newYorkSequenceLow, low)
            newYorkSequenceReady := newYorkOppositeCount >= REVERSAL_CANDLE_COUNT
        else if not newYorkSequenceReady
            newYorkOppositeCount := 0
            newYorkSequenceHigh := na
            newYorkSequenceLow := na
    else if newYorkSweepSide == -1
        if close > open
            newYorkOppositeCount += 1
            newYorkSequenceHigh := newYorkOppositeCount == 1 ? high : math.max(newYorkSequenceHigh, high)
            newYorkSequenceLow := newYorkOppositeCount == 1 ? low : math.min(newYorkSequenceLow, low)
            newYorkSequenceReady := newYorkOppositeCount >= REVERSAL_CANDLE_COUNT
        else if not newYorkSequenceReady
            newYorkOppositeCount := 0
            newYorkSequenceHigh := na
            newYorkSequenceLow := na

newYorkSetupActive = not newYorkInSession and not na(newYorkSweepBar) and bar_index > newYorkSweepBar
newYorkStructureHigh = ta.highest(high[1], 3)
newYorkStructureLow = ta.lowest(low[1], 3)
newYorkLongThree = newYorkSetupActive and newYorkSweepSide == 1 and newYorkSequenceReady and close > newYorkSequenceHigh
newYorkShortThree = newYorkSetupActive and newYorkSweepSide == -1 and newYorkSequenceReady and close < newYorkSequenceLow
newYorkLongCisd = newYorkSetupActive and newYorkSweepSide == 1 and not na(newYorkStructureHigh) and close > newYorkStructureHigh
newYorkShortCisd = newYorkSetupActive and newYorkSweepSide == -1 and not na(newYorkStructureLow) and close < newYorkStructureLow
newYorkLongIfvg = newYorkSetupActive and newYorkSweepSide == 1 and not na(high[2]) and low > high[2]
newYorkShortIfvg = newYorkSetupActive and newYorkSweepSide == -1 and not na(low[2]) and high < low[2]
newYorkLongConfirmation = (confirmationSelected("3 Candle Reversal") and newYorkLongThree) or (confirmationSelected("IFVG") and newYorkLongIfvg) or (confirmationSelected("CISD") and newYorkLongCisd)
newYorkShortConfirmation = (confirmationSelected("3 Candle Reversal") and newYorkShortThree) or (confirmationSelected("IFVG") and newYorkShortIfvg) or (confirmationSelected("CISD") and newYorkShortCisd)
newYorkLongSignal = barstate.isconfirmed and not newYorkTradeDone and newYorkLongConfirmation
newYorkShortSignal = barstate.isconfirmed and not newYorkTradeDone and newYorkShortConfirmation
newYorkLongEntryType = entryModeInput == "3 Candle Reversal" or (entryModeInput == "Any Confirmation" and newYorkLongThree) ? "3 Candle Reversal Entry" : entryModeInput == "IFVG" or (entryModeInput == "Any Confirmation" and newYorkLongIfvg) ? "IFVG Entry" : "CISD Entry"
newYorkShortEntryType = entryModeInput == "3 Candle Reversal" or (entryModeInput == "Any Confirmation" and newYorkShortThree) ? "3 Candle Reversal Entry" : entryModeInput == "IFVG" or (entryModeInput == "Any Confirmation" and newYorkShortIfvg) ? "IFVG Entry" : "CISD Entry"
newYorkLongEntryText = showEntryTypeInput ? newYorkLongEntryType : "Entry"
newYorkShortEntryText = showEntryTypeInput ? newYorkShortEntryType : "Entry"
newYorkLongStopBase = not na(lastPivotLow) and not na(lastPivotLowBar) and lastPivotLowBar >= newYorkSweepBar ? lastPivotLow : fallbackStopLow
newYorkShortStopBase = not na(lastPivotHigh) and not na(lastPivotHighBar) and lastPivotHighBar >= newYorkSweepBar ? lastPivotHigh : fallbackStopHigh
newYorkLongStop = nz(newYorkLongStopBase, low) - stopBufferPrice
newYorkShortStop = nz(newYorkShortStopBase, high) + stopBufferPrice

if newYorkLongSignal
    newYorkTradeDone := true
    if showTradeZonesInput
        box.new(left = bar_index, top = math.max(newYorkHigh, close), right = bar_index + projectionBarsInput, bottom = math.min(newYorkHigh, close), xloc = xloc.bar_index, bgcolor = targetZoneColorInput, border_color = color.new(BULL_COLOR, 100))
        box.new(left = bar_index, top = math.max(close, newYorkLongStop), right = bar_index + projectionBarsInput, bottom = math.min(close, newYorkLongStop), xloc = xloc.bar_index, bgcolor = stopZoneColorInput, border_color = color.new(BEAR_COLOR, 100))
    if showEntryLevelInput
        line.new(x1 = bar_index, y1 = close, x2 = bar_index + projectionBarsInput, y2 = close, xloc = xloc.bar_index, color = entryLineColorInput, width = 2)
        label.new(x = bar_index + projectionBarsInput, y = close, text = newYorkLongEntryText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = entryLineColorInput, size = labelSize)

if newYorkShortSignal
    newYorkTradeDone := true
    if showTradeZonesInput
        box.new(left = bar_index, top = math.max(newYorkShortStop, close), right = bar_index + projectionBarsInput, bottom = math.min(newYorkShortStop, close), xloc = xloc.bar_index, bgcolor = stopZoneColorInput, border_color = color.new(BEAR_COLOR, 100))
        box.new(left = bar_index, top = math.max(close, newYorkLow), right = bar_index + projectionBarsInput, bottom = math.min(close, newYorkLow), xloc = xloc.bar_index, bgcolor = targetZoneColorInput, border_color = color.new(BEAR_COLOR, 100))
    if showEntryLevelInput
        line.new(x1 = bar_index, y1 = close, x2 = bar_index + projectionBarsInput, y2 = close, xloc = xloc.bar_index, color = entryLineColorInput, width = 2)
        label.new(x = bar_index + projectionBarsInput, y = close, text = newYorkShortEntryText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = entryLineColorInput, size = labelSize)

// --- Entry circles at the actual entry candle extreme ---
plotshape((showSignalsInput and markerSizeInput == "Tiny" and londonLongSignal) ? low : na, title = "London long tiny", style = shape.circle, location = location.absolute, color = longMarkerColorInput, size = size.tiny)
plotshape((showSignalsInput and markerSizeInput == "Small" and londonLongSignal) ? low : na, title = "London long small", style = shape.circle, location = location.absolute, color = longMarkerColorInput, size = size.small)
plotshape((showSignalsInput and markerSizeInput == "Normal" and londonLongSignal) ? low : na, title = "London long normal", style = shape.circle, location = location.absolute, color = longMarkerColorInput, size = size.normal)
plotshape((showSignalsInput and markerSizeInput == "Large" and londonLongSignal) ? low : na, title = "London long large", style = shape.circle, location = location.absolute, color = longMarkerColorInput, size = size.large)
plotshape((showSignalsInput and markerSizeInput == "Huge" and londonLongSignal) ? low : na, title = "London long huge", style = shape.circle, location = location.absolute, color = longMarkerColorInput, size = size.huge)
plotshape((showSignalsInput and markerSizeInput == "Tiny" and londonShortSignal) ? high : na, title = "London short tiny", style = shape.circle, location = location.absolute, color = shortMarkerColorInput, size = size.tiny)
plotshape((showSignalsInput and markerSizeInput == "Small" and londonShortSignal) ? high : na, title = "London short small", style = shape.circle, location = location.absolute, color = shortMarkerColorInput, size = size.small)
plotshape((showSignalsInput and markerSizeInput == "Normal" and londonShortSignal) ? high : na, title = "London short normal", style = shape.circle, location = location.absolute, color = shortMarkerColorInput, size = size.normal)
plotshape((showSignalsInput and markerSizeInput == "Large" and londonShortSignal) ? high : na, title = "London short large", style = shape.circle, location = location.absolute, color = shortMarkerColorInput, size = size.large)
plotshape((showSignalsInput and markerSizeInput == "Huge" and londonShortSignal) ? high : na, title = "London short huge", style = shape.circle, location = location.absolute, color = shortMarkerColorInput, size = size.huge)
plotshape((showSignalsInput and markerSizeInput == "Tiny" and newYorkLongSignal) ? low : na, title = "New York long tiny", style = shape.circle, location = location.absolute, color = longMarkerColorInput, size = size.tiny)
plotshape((showSignalsInput and markerSizeInput == "Small" and newYorkLongSignal) ? low : na, title = "New York long small", style = shape.circle, location = location.absolute, color = longMarkerColorInput, size = size.small)
plotshape((showSignalsInput and markerSizeInput == "Normal" and newYorkLongSignal) ? low : na, title = "New York long normal", style = shape.circle, location = location.absolute, color = longMarkerColorInput, size = size.normal)
plotshape((showSignalsInput and markerSizeInput == "Large" and newYorkLongSignal) ? low : na, title = "New York long large", style = shape.circle, location = location.absolute, color = longMarkerColorInput, size = size.large)
plotshape((showSignalsInput and markerSizeInput == "Huge" and newYorkLongSignal) ? low : na, title = "New York long huge", style = shape.circle, location = location.absolute, color = longMarkerColorInput, size = size.huge)
plotshape((showSignalsInput and markerSizeInput == "Tiny" and newYorkShortSignal) ? high : na, title = "New York short tiny", style = shape.circle, location = location.absolute, color = shortMarkerColorInput, size = size.tiny)
plotshape((showSignalsInput and markerSizeInput == "Small" and newYorkShortSignal) ? high : na, title = "New York short small", style = shape.circle, location = location.absolute, color = shortMarkerColorInput, size = size.small)
plotshape((showSignalsInput and markerSizeInput == "Normal" and newYorkShortSignal) ? high : na, title = "New York short normal", style = shape.circle, location = location.absolute, color = shortMarkerColorInput, size = size.normal)
plotshape((showSignalsInput and markerSizeInput == "Large" and newYorkShortSignal) ? high : na, title = "New York short large", style = shape.circle, location = location.absolute, color = shortMarkerColorInput, size = size.large)
plotshape((showSignalsInput and markerSizeInput == "Huge" and newYorkShortSignal) ? high : na, title = "New York short huge", style = shape.circle, location = location.absolute, color = shortMarkerColorInput, size = size.huge)

// --- Alerts ---
alertcondition(londonLongSignal, "London range confirmation long", "London range low sweep confirmed long on {{ticker}} {{interval}}")
alertcondition(londonShortSignal, "London range confirmation short", "London range high sweep confirmed short on {{ticker}} {{interval}}")
alertcondition(newYorkLongSignal, "New York range confirmation long", "New York range low sweep confirmed long on {{ticker}} {{interval}}")
alertcondition(newYorkShortSignal, "New York range confirmation short", "New York range high sweep confirmed short on {{ticker}} {{interval}}")
alertcondition(londonLongSignal or londonShortSignal or newYorkLongSignal or newYorkShortSignal, "Any range confirmation signal", "Time-based range confirmation signal on {{ticker}} {{interval}}")
````
