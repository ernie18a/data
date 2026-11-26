# BarrettFVG Trendline

- url: https://www.tradingview.com/script/JpkdOdm9-BarrettFVG-Trendline/
- type: indicator
- pine_id: PUB;dab2ebca72c34e9c97e7975ac299f101
- version: 5.0

## Description

**BarrettFVG Trendline**

BarrettFVG Trendline plots dynamic, self-adjusting liquidity trendlines from swing pivots and flags the moment price breaks structure — giving a clean visual read on trend continuation vs. exhaustion, with built-in alerts for both directions.

**How it works**
- Detects pivot highs/lows over a configurable lookback period and connects consecutive pivots into a sloped trendline (upper resistance line from lower pivots, lower support line from higher pivots).
- Lines auto-extend and re-slope each bar until price closes through them, at which point the line is invalidated and a new one begins forming from the next valid pivot sequence.
- A padded "buffer zone" (ATR-based) is plotted alongside each line and filled, giving a visual cushion rather than a single hard price level.
- When price closes through an active line, the indicator marks a breakout signal (triangle up/down) and fires an alert.

**How to use it**
- Use the trendline breaks as a read on structural shifts — a break of a rising support line can signal loss of upward momentum; a break of a falling resistance line can signal a shift toward buyers regaining control.
- Works on any timeframe and instrument; built and tested primarily on MNQ futures.
- Combine with your own bias/context tools (HTF trend, session levels, order flow) rather than trading breaks in isolation — this indicator identifies structure breaks, it does not predict direction on its own.

**Alerts**
Three alert conditions are built in — right-click the indicator → Add Alert:
- *Breaking Up* — fires when the resistance trendline is broken to the upside
- *Breaking Down* — fires when the support trendline is broken to the downside
- *Any Breakout* — fires on either signal

**Settings**
- Period — pivot lookback length
- Padding — width of the buffer zone around each trendline
- Line colors (up/down)
- Toggle for breakout markers

**Credit**
This script is built on the open-source trendline/breakout logic originally published by **StratifyTrade** ("Liquidity Trendline With Signals"), used and adapted under the terms of its **CC BY-NC-SA 4.0** license. Alert functionality and rebranding added by BarrettFVG.

---

## Disclaimer

*This script is for educational and informational purposes only and does not constitute financial, investment, or trading advice. Trading futures and other financial instruments involves substantial risk of loss and is not suitable for all investors. Past performance, backtested results, or historical signals are not indicative of future results. Always conduct your own due diligence and consult a licensed financial professional before making trading decisions. The creator assumes no liability for any losses incurred from use of this script.*

---

## Source Code

````pine
// Original logic licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © StratifyTrade — original author, "Liquidity Trendline With Signals"
// Modified/rebranded: BarrettFVG — added alertcondition() calls for entry/breakout signals
// This derivative remains under CC BY-NC-SA 4.0 per the ShareAlike clause (non-commercial use only).
// Ported from Pine v5 to v6: replaced implicit float->bool pivot checks (if ph / if pl) with
// explicit not na() checks, and replaced history-references on UDT fields (high[len], bar_index[i], etc.)
// with the equivalent built-in series (high[len], bar_index[i], low[1]...), both of which v6 no
// longer allows.

//@version=6
indicator(
       "BarrettFVG Trendline"
     , "BarrettFVG Trendline"
     , overlay = true
     , max_lines_count = 500
     , max_labels_count = 500
     , max_bars_back   = 5000
     )

// ── 1 · BOS CONFIRMATION ─────────────────────────────────────────────────────
// The core confirmation gate — start here, since this decides whether a raw
// break counts as a real signal at all.
useBOS  = input.bool(true, "Require BOS confirmation", tooltip = "After a trendline break, wait for price to also take out the last confirmed swing before treating it as a real signal. Turn off to fire on the raw break alone — Displacement/Delta below still apply either way.", group = "1 · BOS")
bosWait = input.int(10, "Max bars to wait for BOS", minval = 0, tooltip = "How many bars a break is allowed to wait for BOS to confirm before the pending signal expires unfired. 0 = must confirm on the same candle as the break.", group = "1 · BOS")
bosLine = input.bool(true, "Draw BOS level line", tooltip = "Dotted line from the swing that was taken out, across to the candle that broke it — a visual reference for what BOS actually confirmed against.", group = "1 · BOS")

// ── 2 · SELECTIVITY FILTERS ──────────────────────────────────────────────────
// Real-price conviction checks on the confirming candle — the BOS candle if
// BOS is on, the break candle itself if off. Both are optional, stackable.
useDisp = input.bool(true, "Require Displacement on Confirm Candle", tooltip = "MASTER SWITCH. Requires the confirm candle to show genuine conviction: a real range, a real body, closing in the signal's direction — instead of a break/BOS firing on a quiet, indecisive candle.", group = "2 · FILTERS")
dispRangeAtr  = input.float(1.0, "    ↳ Min Range (ATR)", minval = 0.1, step = 0.1, group = "2 · FILTERS", tooltip = "The confirm candle's high-low range must be at least this many multiples of ATR(14) to count as real conviction. Higher = stricter, fewer signals.")
dispBodyRatio = input.float(0.5, "    ↳ Min Body Ratio", minval = 0.0, maxval = 1.0, step = 0.05, group = "2 · FILTERS", tooltip = "The confirm candle's body (open-to-close) must be at least this fraction of its full range. A candle that's mostly wick with a tiny body fails this even if the range is large. 0 disables this specific check.")
dispRequireDirectionalClose = input.bool(true, "    ↳ Require Directional Close", group = "2 · FILTERS", tooltip = "The confirm candle must close in the signal's direction — green for bullish, red for bearish. Stops a technically large candle that closed the 'wrong' way from still counting.")

useDelta = input.bool(false, "Require Orderflow (Delta) Confirmation", tooltip = "MASTER SWITCH. A second, stricter layer on top of Displacement. Estimates buy/sell pressure from OHLCV (Pine cannot access true bid/ask data) and requires it to favor the signal's direction.", group = "2 · FILTERS")
deltaBarMinRatio   = input.float(0.25, "    ↳ Confirm Candle Min Delta Ratio", minval = 0.0, maxval = 1.0, step = 0.05, group = "2 · FILTERS", tooltip = "The confirm candle's estimated buy-vs-sell imbalance must be at least this fraction of its total volume, in the signal's direction. 0.25 ≈ a 62/38 split or stronger.")
deltaRequireVolume = input.bool(true, "    ↳ Require Above-Average Volume", group = "2 · FILTERS", tooltip = "The confirm candle's volume must exceed its recent average, so the delta reading is backed by real participation rather than a thin, low-volume bar.")
deltaVolLen  = input.int(20, "        ↳ Volume Average Length", minval = 2, maxval = 200, group = "2 · FILTERS", tooltip = "Lookback for the average-volume comparison used by 'Require Above-Average Volume' just above.")
deltaVolMult = input.float(1.2, "        ↳ Volume Multiple", minval = 0.5, step = 0.1, group = "2 · FILTERS", tooltip = "The confirm candle's volume must exceed this multiple of its recent average to pass the volume check.")
requireCumDelta = input.bool(true, "    ↳ Require Cumulative Delta Agreement", tooltip = "Sums estimated delta from the trendline break through the confirm bar and requires the net total to favor the trade direction — catches a break that confirms while broader orderflow since the break has actually been against it.", group = "2 · FILTERS")
cumDeltaMaxBars = input.int(20, "        ↳ Cumulative Delta Max Bars", minval = 2, maxval = 100, group = "2 · FILTERS", tooltip = "Caps how many bars back from the confirm bar the cumulative delta sum will reach, so an old break doesn't drag in unrelated history.")

// ── 3 · RISK & TRADE LEVELS ──────────────────────────────────────────────────
slMethod = input.string("Structure lookback extreme", "SL Method", options = ["Structure lookback extreme", "Trendline break level"], group = "3 · RISK", tooltip = "Structure lookback extreme: SL sits beyond the lowest low / highest high over a lookback window — wider, more generic. Trendline break level: SL sits just beyond the exact price the trendline broke at — tight, thesis-specific (if price reclaims that level, the breakout is invalidated).")
slLookbackBars = input.int(30, "Structure Lookback Bars", minval = 1, group = "3 · RISK", tooltip = "Only used when SL Method is Structure lookback extreme — how many bars back to scan for the SL reference.")
slBufferTicks  = input.int(1, "SL Buffer (ticks)", minval = 0, group = "3 · RISK", tooltip = "Extra ticks added beyond the SL reference price, whichever method is active, as a small margin of safety.")
rrRatioBreak  = input.float(2.0, "TP R Multiple — Trendline Break Level", minval = 0.1, step = 0.1, group = "3 · RISK", tooltip = "Take-profit distance as a multiple of risk (the SL distance), used only when SL Method is Trendline break level.")
rrRatioStruct = input.float(1.0, "TP R Multiple — Structure Lookback", minval = 0.1, step = 0.1, group = "3 · RISK", tooltip = "Take-profit distance as a multiple of risk (the SL distance), used only when SL Method is Structure lookback extreme.")
showTradeTracker = input.bool(true, "Show Visual SL/TP Tracker", group = "3 · RISK", tooltip = "Draws the SL and TP as lines/labels when a signal fires, and removes them once the trade closes (hits either level).")
cooldownBars   = input.int(15, "Signal Cooldown Bars", minval = 0, group = "3 · RISK", tooltip = "Minimum bars required between two signals in the same direction, so a choppy stretch can't fire several entries back-to-back off the same underlying move.")

// ── 4 · MARKET STRUCTURE (SHORT & LONG TERM TREND) ──────────────────────────
showTrendTable = input.bool(true, "Show Trend Table", group = "4 · STRUCTURE", tooltip = "Short and long-term trend read: direction plus streak length, the number of consecutive same-direction structure confirmations.")
shortStructLen = input.int(7, "Short-Term Pivot Length (L/R)", minval = 2, maxval = 30, group = "4 · STRUCTURE", tooltip = "Every pivot needs this many bars AFTER it forms to confirm, so lower = faster to react, at the cost of noisier pivots.")
longStructLen  = input.int(14, "Long-Term Pivot Length (L/R)", minval = 5, maxval = 100, group = "4 · STRUCTURE", tooltip = "Meaningfully longer than the short-term scale so it captures bigger swings directly. Tags aren't drawn for this scale — only the trend table shows its state.")
showShortTags = input.bool(true, "Show Short-Term HH/HL/LH/LL Tags", group = "4 · STRUCTURE", tooltip = "Draws HH/HL/LH/LL labels on the chart at each confirmed short-term pivot.")

// ── 5 · KEY LEVELS ───────────────────────────────────────────────────────────
// Display only — no gating, no entry logic.
showKeyLevels = input.bool(true, "Show Key Levels", group = "5 · KEY LEVELS", tooltip = "PDH, PDL, PWH, PWL, Asia High/Low, and London High/Low, drawn as dotted reference lines extending back to their origin.")
includePw     = input.bool(true, "Include Prev Week High/Low", group = "5 · KEY LEVELS", tooltip = "Adds PWH/PWL alongside the daily levels. Turn off to show only PDH/PDL plus the session levels.")
asiaSess      = input.session("2000-0000", "Asia Session (EST)", group = "5 · KEY LEVELS", tooltip = "Window used to compute the Asia High/Low levels.")
londonSess    = input.session("0200-0500", "London Session (EST)", group = "5 · KEY LEVELS", tooltip = "Window used to compute the London High/Low levels.")

// ── 6 · VWAPS ────────────────────────────────────────────────────────────────
showVwaps = input.bool(true, "Show VWAPs", group = "6 · VWAPS", tooltip = "Draws both the TDO VWAP and the NY Session VWAP described below.")
tdoColor  = input.color(color.blue, "TDO VWAP Color (18:00 EST)", group = "6 · VWAPS", tooltip = "Anchors at 18:00 EST and runs continuously until the next day's anchor — unlike the NY Session VWAP below, this one never disappears.")
nyColor   = input.color(#9c27b0, "NY Session VWAP Color", group = "6 · VWAPS", tooltip = "Anchors at 09:30 EST and disappears outside the NY session — unlike TDO VWAP, this one does not run continuously.")

// ── 7 · SESSION GATE ─────────────────────────────────────────────────────────
useSess = input.bool(true, "Gate alerts by session", group = "7 · SESSIONS", tooltip = "Restricts signals/alerts to the two trading windows below. Trendlines and key levels still draw around the clock either way — this only affects when a signal is allowed to fire.")
sess1   = input.session("1800-0000", "Trading Time Window 1 (EST)", group = "7 · SESSIONS")
sess2   = input.session("0700-1600", "Trading Time Window 2 (EST)", group = "7 · SESSIONS")
sessTz  = input.string("America/New_York", "Timezone", tooltip = "Handles EST/EDT automatically.", group = "7 · SESSIONS")

// ── 8 · CORE SETTINGS (rarely changed) ───────────────────────────────────────
// The trendline detection itself, plus cosmetic/technical settings that get
// set once and left alone.
len   = input.int(5, "Period  ", tooltip = "Pivot lookback used to detect the swing highs/lows that form the trendlines.", inline = "a", group = "8 · CORE")
cup   = input.color(#0044ff, "", "", inline = "a", group = "8 · CORE")
cdn   = input.color(#ff2b00, "", "", inline = "a", group = "8 · CORE")
space = input.float(2, "Padding", tooltip = "ATR-based buffer added around each trendline. Also used as the SL reference when SL Method is Trendline break level.", inline = "b", group = "8 · CORE", step = 0.1)
shs   = input.bool(true, "Show Breakouts", tooltip = "Show the ▲/▼ entry markers on the chart.", inline = "z", group = "8 · CORE")
recent= input.bool(true, "Only show most recent signal per direction", tooltip = "Keeps one marker per direction on the chart, deleting older ones. Reduces clutter on lower timeframes.", group = "8 · CORE")
mkSzIn= input.string("Normal", "Marker size", options = ["Tiny", "Small", "Normal"], group = "8 · CORE")
keepHist = input.int(20, "Keep last N broken trendlines", minval = 0, maxval = 200, tooltip = "Broken trendlines are kept on the chart as history. Each one costs 2 of the script's 500 line budget, and when that budget runs out TradingView silently deletes the OLDEST drawings. Capping retention here keeps you well under the limit. 0 = delete broken trendlines immediately.", group = "8 · CORE")
structTagMaxLabels = input.int(25, "Max Stored Structure Tags", minval = 5, maxval = 100, group = "8 · CORE", tooltip = "How many short-term HH/HL/LH/LL tags stay on the chart before the oldest ones get deleted.")
structBullColor = input.color(color.new(color.green, 0), "Bull Structure Color", group = "8 · CORE", tooltip = "Used for HH/HL tags and the trend table's bullish text.")
structBearColor = input.color(color.new(color.red, 0), "Bear Structure Color", group = "8 · CORE", tooltip = "Used for LH/LL tags and the trend table's bearish text.")

mkSize = switch mkSzIn
    "Small"  => size.small
    "Normal" => size.normal
    => size.tiny

ph = ta.pivothigh(high, len, len)
pl = ta.pivotlow (low , len, len)

type store
    float src
    int   n

type draw
    line[] upln
    line[] dnln

var store[] upbin = array.new<store>()
var store[] dnbin = array.new<store>()

var draw d = draw.new(array.new<line>(), array.new<line>())

atr   = ta.atr(200)
atr14 = ta.atr(14)

// ============================================================
//                     KEY LEVELS (display only)
// ============================================================
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

var float asiaHigh = na
var float asiaLow  = na
int  asiaTime      = time(timeframe.period, asiaSess, "America/New_York")
bool inAsiaSession  = not na(asiaTime)
bool asiaStarted    = inAsiaSession and na(asiaTime[1])
if asiaStarted
    asiaHigh := high
    asiaLow  := low
else if inAsiaSession
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow  := na(asiaLow)  ? low  : math.min(asiaLow, low)

var float londonHigh = na
var float londonLow  = na
int  londonTime      = time(timeframe.period, londonSess, "America/New_York")
bool inLondonSession  = not na(londonTime)
bool londonStarted    = inLondonSession and na(londonTime[1])
if londonStarted
    londonHigh := high
    londonLow  := low
else if inLondonSession
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow  := na(londonLow)  ? low  : math.min(londonLow, low)

var array<line>  keyLines  = array.new_line()
var array<label> keyLabels = array.new_label()

f_drawKey(float price, string txt, color col) =>
    if not na(price)
        keyLines.push(line.new(bar_index, price, bar_index + 5, price, xloc = xloc.bar_index, extend = extend.left, color = col, style = line.style_dotted, width = 2))
        keyLabels.push(label.new(bar_index + 6, price, txt, color = color.new(color.white, 100), textcolor = col, style = label.style_label_left, size = size.small))

if barstate.islast and showKeyLevels
    while keyLines.size() > 0
        line.delete(keyLines.pop())
    while keyLabels.size() > 0
        label.delete(keyLabels.pop())
    f_drawKey(pdh, "PDH", color.black)
    f_drawKey(pdl, "PDL", color.black)
    if includePw
        f_drawKey(pwh, "PWH", color.new(color.gray, 0))
        f_drawKey(pwl, "PWL", color.new(color.gray, 0))
    if not inAsiaSession
        f_drawKey(asiaHigh, "Asia High", color.new(#f23645, 0))
        f_drawKey(asiaLow, "Asia Low", color.new(#f23645, 0))
    if not inLondonSession
        f_drawKey(londonHigh, "London High", color.new(#2962ff, 0))
        f_drawKey(londonLow, "London Low", color.new(#2962ff, 0))

// ============================================================
//                     VWAPS
// ============================================================
// TDO: anchors 18:00 EST, runs continuously until the next anchor.
// NY session: anchors 09:30 EST, plot goes na (disappears) outside the
// session rather than persisting — the isNySession gate on the plot() call
// is what makes it vanish, not the VWAP calculation itself.
get_anchored_vwap(cond) =>
    var float sumSrcVol = 0.0
    var float sumVol = 0.0
    if cond
        sumSrcVol := hlc3 * volume
        sumVol := volume
    else
        sumSrcVol += hlc3 * volume
        sumVol += volume
    sumVol > 0 ? sumSrcVol / sumVol : na

isTdoStart = hour(time, "America/New_York") >= 18 and hour(time[1], "America/New_York") < 18
isNyStart  = hour(time, "America/New_York") == 9 and minute(time, "America/New_York") == 30
isNySession = not na(time(timeframe.period, "0930-1600", "America/New_York"))

tdoVwap = get_anchored_vwap(isTdoStart or barstate.isfirst)
nyVwap  = get_anchored_vwap(isNyStart or barstate.isfirst)

plot(showVwaps ? tdoVwap : na, title = "TDO VWAP", color = tdoColor, linewidth = 2)
plot(showVwaps and isNySession ? nyVwap : na, title = "NY Session VWAP", color = nyColor, linewidth = 2)

// ============================================================
//         MARKET STRUCTURE — SHORT & LONG TERM TREND
// ============================================================
// Rather than a fixed "look back N tags" rule, this tracks a live streak:
// how many consecutive structure confirmations (HH/HL for bull, LH/LL for
// bear) have agreed. A streak of 1 is a single, unconfirmed flip — low
// trust. A streak of 4+ is a real run. Two independent scales (different
// pivot lengths, not the same pivots read further back) give a genuine
// short-term vs long-term read rather than two views of identical noise.
type StructState
    int   dir    = 0
    int   streak = 0
    float lastHigh = na
    float lastLow  = na

var StructState shortStruct = StructState.new()
var StructState longStruct  = StructState.new()
var array<label> shortStructLabels = array.new<label>()

// pivotLen is passed in so the label can be placed at bar_index - pivotLen —
// the bar the extreme actually happened on, not the bar it confirmed on.
// That gap, visible directly on the chart, is the confirmation lag itself.
f_updateStruct(StructState st, float ph, float pl, int pivotLen, bool showTags, array<label> labelArr, int maxLabels, string lblSize) =>
    if not na(ph)
        bool isHH = not na(st.lastHigh) and ph > st.lastHigh
        bool isLH = not na(st.lastHigh) and ph < st.lastHigh
        if isHH or isLH
            int vote = isHH ? 1 : -1
            st.streak := st.dir == vote ? st.streak + 1 : 1
            st.dir := vote
            if showTags
                labelArr.push(label.new(bar_index - pivotLen, ph, isHH ? "HH" : "LH", xloc = xloc.bar_index, color = isHH ? structBullColor : structBearColor, textcolor = color.white, style = label.style_label_down, size = lblSize))
                while labelArr.size() > maxLabels
                    label old = labelArr.shift()
                    if not na(old)
                        label.delete(old)
        st.lastHigh := ph
    if not na(pl)
        bool isHL = not na(st.lastLow) and pl > st.lastLow
        bool isLL = not na(st.lastLow) and pl < st.lastLow
        if isHL or isLL
            int vote = isHL ? 1 : -1
            st.streak := st.dir == vote ? st.streak + 1 : 1
            st.dir := vote
            if showTags
                labelArr.push(label.new(bar_index - pivotLen, pl, isHL ? "HL" : "LL", xloc = xloc.bar_index, color = isHL ? structBullColor : structBearColor, textcolor = color.white, style = label.style_label_up, size = lblSize))
                while labelArr.size() > maxLabels
                    label old = labelArr.shift()
                    if not na(old)
                        label.delete(old)
        st.lastLow := pl
    0

f_updateStruct(shortStruct, ta.pivothigh(high, shortStructLen, shortStructLen), ta.pivotlow(low, shortStructLen, shortStructLen), shortStructLen, showShortTags, shortStructLabels, structTagMaxLabels, size.tiny)
// Long-term never draws tags (showTags hardcoded false) — at any reasonable
// pivot length they cluttered the chart badly, and the trend table already
// surfaces this scale's state. shortStructLabels/size.tiny below are unused
// filler: the function never touches them when showTags is false, and Pine
// requires all parameters passed regardless.
f_updateStruct(longStruct,  ta.pivothigh(high, longStructLen, longStructLen),   ta.pivotlow(low, longStructLen, longStructLen),   longStructLen,  false, shortStructLabels, structTagMaxLabels, size.tiny)

f_trendLabel(StructState st) =>
    st.dir == 1 ? "Bullish (" + str.tostring(st.streak) + ")" : st.dir == -1 ? "Bearish (" + str.tostring(st.streak) + ")" : "Undefined"

f_trendColor(StructState st) =>
    st.dir == 1 ? structBullColor : st.dir == -1 ? structBearColor : color.gray

var table trendTable = table.new(position.top_right, 2, 3, bgcolor = color.new(color.black, 15), border_width = 1)

if showTrendTable and barstate.islast
    table.cell(trendTable, 0, 0, "Trend", bgcolor = color.new(#D4AF37, 0), text_color = color.black, text_size = size.small)
    table.cell(trendTable, 1, 0, "", bgcolor = color.new(#D4AF37, 0), text_size = size.small)
    table.cell(trendTable, 0, 1, "Short-Term", text_color = color.white, text_size = size.small)
    table.cell(trendTable, 1, 1, f_trendLabel(shortStruct), text_color = f_trendColor(shortStruct), text_size = size.small)
    table.cell(trendTable, 0, 2, "Long-Term", text_color = color.white, text_size = size.small)
    table.cell(trendTable, 1, 2, f_trendLabel(longStruct), text_color = f_trendColor(longStruct), text_size = size.small)

method slope(line ln) =>
    x = ln.get_x2() - ln.get_x1()
    y = ln.get_y2() - ln.get_y1()
    y / x

// Hoisted: this was recalculated on every call site (up to 4 per validation).
// Depends only on current-bar `atr` and `close`, so one evaluation per bar is
// numerically identical to the original.
volNow = math.min(atr * 0.1, close * (0.1/100))

// Broken trendlines were previously orphaned — cleared from the tracking array
// without being deleted, so they accumulated against the 500-line budget with
// no upper bound. They are now retained in a capped FIFO instead.
var line[] histLines = array.new<line>()

f_retire(line a, line c) =>
    if keepHist > 0
        histLines.push(a)
        histLines.push(c)
        while histLines.size() > keepHist * 2
            line.delete(histLines.shift())
    else
        line.delete(a)
        line.delete(c)
    0

var bool broken  = false
bool plup = false
bool pldn = false

// The exact price the trendline broke at, captured at the break bar before
// the line gets retired — used as the SL reference below. Not read from the
// line object later, since by the time BOS may confirm (up to bosWait bars
// later) that object could already be deleted or moved into history.
var float upBreakLevel = na
var float dnBreakLevel = na

// Tap count: how many pivots have contributed to the currently-active line.
// A line rebuilt from the bare minimum two pivots is materially weaker
// information than one that was respected four or five times before
// breaking — practitioner convention treats a 2-touch break as early
// information and a 3+ touch break as carrying real weight. Captured at the
// break bar so the alert can report what actually broke.
var int upTapCount = 0
var int dnTapCount = 0
var int upBreakTaps = 0
var int dnBreakTaps = 0

if not na(ph)
    bool   remove = false
    var bool valid = false

    upbin.unshift(store.new(high[len], bar_index[len]))
    if upbin.size() > 1
        current = upbin.get(0)
        before  = upbin.get(1)
        if current.src < before.src
            if broken
                valid := true

            else
                valid := false
                if upbin.size() > 3
                    pastold = upbin.get(3)
                    pastcur = upbin.get(2)
                    now     = upbin.get(1)
                    late    = upbin.get(0)
                    if now.src < pastcur.src and now.src < pastold.src and late.src < pastcur.src and late.src < pastold.src
                        valid := true

                    else
                        valid := false

                else 
                    valid := false

            if valid

                d.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src                , y2 = current.src                , color = cdn))
                d.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src - volNow * space, y2 = current.src - volNow * space, color = cdn))

                ln = d.upln.get(1)
                for i = 0 to (bar_index - before.n)
                    slope = ln.slope()
                    ln.set_x2(bar_index[i])
                    ln.set_y2(ln.get_y2() - slope)
                    if low[i] > ln.get_y2()
                        remove := true
                        break

                if remove
                    d.upln.get(0).delete()
                    d.upln.get(1).delete()
                    d.upln       .clear()
                    upbin        .clear()
                    broken := true

                else
                    d.upln.get(0).delete()
                    d.upln.get(1).delete()   
                    d.upln       .clear ()

                    d.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src                , y2 = current.src                , color = cdn))
                    d.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src - volNow * space, y2 = current.src - volNow * space, color = cdn))

                    linefill.new(d.upln.get(0), d.upln.get(1), color = color.new(cdn, 75))
                    upbin.clear()
                    // A fresh line starts at 2 (the two pivots that define
                    // it); extending a still-alive line adds one more touch.
                    upTapCount := broken ? 2 : upTapCount + 1
                    broken := false


if d.upln.size() > 1

    btm = d.upln.get(0)
    top = d.upln.get(1)
    
    if low > top.get_y2()
        upBreakLevel := btm.get_y2()
        upBreakTaps  := upTapCount
        f_retire(btm, top)
        d.upln.clear()
        broken := true
        upbin.clear()
        plup   := true

    if d.upln.size() > 1

        slup = top.slope()
        sldn = btm.slope()

        top.set_x2(bar_index)
        top.set_y2(top.get_y2() + slup)

        btm.set_x2(bar_index)
        btm.set_y2(btm.get_y2() + sldn)
 


if not na(pl)
    bool    remove = false
    var bool valid = false

    dnbin.unshift(store.new(low[len], bar_index[len]))
    if dnbin.size() > 1
        current = dnbin.get(0)
        before  = dnbin.get(1)
        if current.src > before.src
            if broken
                valid := true

            else
                valid := false
                if dnbin.size() > 3
                    pastold = dnbin.get(3)
                    pastcur = dnbin.get(2)
                    now     = dnbin.get(1)
                    late    = dnbin.get(0)

                    if now.src > pastcur.src and now.src > pastold.src and late.src > pastcur.src and late.src > pastold.src
                        valid := true

                    else
                        valid := false

                else 
                    valid := false

            if valid
                d.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src                , y2 = current.src                , color = cup))
                d.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src + volNow * space, y2 = current.src + volNow * space, color = cup))

                ln = d.dnln.get(1)

                for i = 0 to (bar_index - before.n)
                    slope = ln.slope()
                    ln.set_x2(bar_index[i])
                    ln.set_y2(ln.get_y2() - slope)
                    if high[i] < ln.get_y2()
                        remove := true
                        break

                if remove
                    d.dnln.get(0).delete()
                    d.dnln.get(1).delete()
                    d.dnln       .clear ()
                    dnbin        .clear ()
                    broken := true

                else
                    d.dnln.get(0).delete()
                    d.dnln.get(1).delete()   
                    d.dnln       .clear ()

                    d.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src, y2 = current.src, color = cup))
                    d.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src + volNow * space, y2 = current.src + volNow * space, color = cup))

                    linefill.new(d.dnln.get(0), d.dnln.get(1), color = color.new(cup, 75))
                    dnbin.clear()
                    dnTapCount := broken ? 2 : dnTapCount + 1
                    broken := false

if d.dnln.size() > 1

    btm = d.dnln.get(0)
    top = d.dnln.get(1)
    
    if high < btm.get_y2()
        dnBreakLevel := btm.get_y2()
        dnBreakTaps  := dnTapCount
        f_retire(btm, top)
        d.dnln.clear()
        broken := true
        dnbin.clear()
        pldn   := true

    if d.dnln.size() > 1

        slup = top.slope()
        sldn = btm.slope()

        top.set_x2(bar_index)
        top.set_y2(top.get_y2() + slup)

        btm.set_x2(bar_index)
        btm.set_y2(btm.get_y2() + sldn)

// ---------------------------------------------------------------------------
// SESSION GATE
// ---------------------------------------------------------------------------
// Sessions gate ALERTS ONLY — trendlines and breakout markers still draw 24h so
// chart structure stays intact and historical context isn't lost.
bool inSess1   = not na(time(timeframe.period, sess1, sessTz))
bool inSess2   = not na(time(timeframe.period, sess2, sessTz))
bool inSession = not useSess or inSess1 or inSess2

// ---------------------------------------------------------------------------
// BOS CONFIRMATION
// ---------------------------------------------------------------------------
// Track the most recent CONFIRMED swing points. Because the trendlines slope
// away from price, the line level sits inside the last swing — so taking out
// that swing is a strictly later and stricter event than the line break itself.
var float lastSwingHigh = na
var float lastSwingLow  = na
var int   lastSwingHighBar = na
var int   lastSwingLowBar  = na
if not na(ph)
    lastSwingHigh    := ph
    // ta.pivothigh confirms `len` bars late, so the actual pivot bar is offset back.
    lastSwingHighBar := bar_index - len
if not na(pl)
    lastSwingLow    := pl
    lastSwingLowBar := bar_index - len

// Pending state: armed by a trendline break, resolved by a BOS or by timeout.
var bool pendUp   = false
var bool pendDn   = false
var int  pendUpBar = 0
var int  pendDnBar = 0

if plup
    pendUp    := true
    pendUpBar := bar_index
if pldn
    pendDn    := true
    pendDnBar := bar_index

// Expire stale pending states.
if pendUp and (bar_index - pendUpBar) > bosWait
    pendUp := false
if pendDn and (bar_index - pendDnBar) > bosWait
    pendDn := false

// ---------------------------------------------------------------------------
// SELECTIVITY FILTERS — real-price conviction, independent of BOS/raw mode
// ---------------------------------------------------------------------------
// Applied to whichever candle actually triggers the signal: the BOS candle
// if useBOS is on, the break candle itself if off.
float dispRange = high - low
float dispBody = math.abs(close - open)
float dispBodyPct = dispRange > 0 ? dispBody / dispRange : 0.0
bool dispRangeOk = not na(atr14) and atr14 > 0 and dispRange >= atr14 * dispRangeAtr
bool dispBodyOk = dispBodyPct >= dispBodyRatio
bool dispBullOk = not dispRequireDirectionalClose or close > open
bool dispBearOk = not dispRequireDirectionalClose or close < open
bool longDispOk  = not useDisp or (dispRangeOk and dispBodyOk and dispBullOk)
bool shortDispOk = not useDisp or (dispRangeOk and dispBodyOk and dispBearOk)

// Synthetic orderflow inference from OHLCV (not true bid/ask data, which Pine
// cannot access). ta.sma() and math.sum() are both history-dependent — same
// class of function as the ta.lowest()/ta.highest() bug fixed earlier — so
// both sit here at the top level, called unconditionally every bar, never
// nested inside f_calcTrade or an if-block that only runs on fire bars.
float barRange = high - low
float closePosition = barRange > 0 ? (close - low) / barRange : 0.5
float barDelta = volume * closePosition - volume * (1.0 - closePosition)
float barDeltaRatio = volume > 0 ? barDelta / volume : 0.0
float avgVolume = ta.sma(volume, deltaVolLen)
bool deltaVolumeOk = not deltaRequireVolume or (not na(avgVolume) and avgVolume > 0 and volume >= avgVolume * deltaVolMult)
bool longBarDeltaOk  = barDeltaRatio >= deltaBarMinRatio
bool shortBarDeltaOk = barDeltaRatio <= -deltaBarMinRatio

int longCumLookback  = math.min(math.max(bar_index - pendUpBar, 1), cumDeltaMaxBars)
int shortCumLookback = math.min(math.max(bar_index - pendDnBar, 1), cumDeltaMaxBars)
float longCumDelta  = math.sum(barDelta, longCumLookback)
float shortCumDelta = math.sum(barDelta, shortCumLookback)
bool longCumDeltaOk  = not requireCumDelta or longCumDelta > 0
bool shortCumDeltaOk = not requireCumDelta or shortCumDelta < 0

bool longDeltaOk  = not useDelta or (longBarDeltaOk  and deltaVolumeOk and longCumDeltaOk)
bool shortDeltaOk = not useDelta or (shortBarDeltaOk and deltaVolumeOk and shortCumDeltaOk)

// BOS fires when price closes beyond the last confirmed swing AND the
// confirm candle passes displacement and delta. bosRaw kept separate (no
// filters) so the diagnostic table can report block rate rather than just
// pass/fail.
bool bosRawUp = pendUp and not na(lastSwingHigh) and close > lastSwingHigh
bool bosRawDn = pendDn and not na(lastSwingLow)  and close < lastSwingLow
bool bosUp = bosRawUp and longDispOk and longDeltaOk
bool bosDn = bosRawDn and shortDispOk and shortDeltaOk

if bosUp
    pendUp := false
if bosDn
    pendDn := false

// ---------------------------------------------------------------------------
// MARKERS
// ---------------------------------------------------------------------------
// Markers are label objects rather than plotshape() because plots cannot be
// removed once drawn — deletable objects are what make "only most recent" work.
// Only one tier shows at a time: BOS on marks the confirmation candle, BOS off
// marks the raw break. Either way the marker sits on the bar the alert fired.
bool sigUp = useBOS ? bosUp : (plup and longDispOk and longDeltaOk)
bool sigDn = useBOS ? bosDn : (pldn and shortDispOk and shortDeltaOk)

var label lblUp   = na
var label lblDn   = na
var line  bosLnUp = na
var line  bosLnDn = na

// label.style_none hides the label box so only the glyph renders — noticeably
// smaller and cleaner than a filled triangle label at the same size constant.
if sigUp and shs
    if recent and not na(lblUp)
        label.delete(lblUp)
    lblUp := label.new(bar_index, low, "▲", yloc = yloc.belowbar, style = label.style_none, textcolor = cup, size = mkSize)

if sigDn and shs
    if recent and not na(lblDn)
        label.delete(lblDn)
    lblDn := label.new(bar_index, high, "▼", yloc = yloc.abovebar, style = label.style_none, textcolor = cdn, size = mkSize)

// BOS level line — dotted horizontal from the swing that was taken out across to
// the candle that broke it, so the structural reference is visible at a glance.
if useBOS and bosLine and bosUp and not na(lastSwingHighBar)
    if recent and not na(bosLnUp)
        line.delete(bosLnUp)
    bosLnUp := line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh, color = cup, style = line.style_dotted, width = 1)

if useBOS and bosLine and bosDn and not na(lastSwingLowBar)
    if recent and not na(bosLnDn)
        line.delete(bosLnDn)
    bosLnDn := line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow, color = cdn, style = line.style_dotted, width = 1)

// ---------------------------------------------------------------------------
// ALERTS
// ---------------------------------------------------------------------------
// TIER 1 — raw trendline break (no BOS requirement)
alertcondition(plup, title = "BarrettFVG Trendline — Breaking Up",   message = "{{ticker}} BarrettFVG Trendline: Breaking UP (long liquidity swept, uptrend line broken)")
alertcondition(pldn, title = "BarrettFVG Trendline — Breaking Down", message = "{{ticker}} BarrettFVG Trendline: Breaking DOWN (short liquidity swept, downtrend line broken)")

// TIER 2 — BOS confirmed
alertcondition(bosUp, title = "BarrettFVG Trendline — BOS Confirmed Up",   message = "{{ticker}} BarrettFVG Trendline: BULLISH break + BOS confirmed")
alertcondition(bosDn, title = "BarrettFVG Trendline — BOS Confirmed Down", message = "{{ticker}} BarrettFVG Trendline: BEARISH break + BOS confirmed")

// COMBINED DYNAMIC — direction-labelled, session-gated, honours the BOS toggle.
// Add Alert → Condition dropdown → "Alert() function calls only"
var int lastLongBar  = na
var int lastShortBar = na
bool longCooldownOk  = na(lastLongBar)  or bar_index - lastLongBar  >= cooldownBars
bool shortCooldownOk = na(lastShortBar) or bar_index - lastShortBar >= cooldownBars

bool fireUp = (useBOS ? bosUp : (plup and longDispOk and longDeltaOk)) and inSession and longCooldownOk
bool fireDn = (useBOS ? bosDn : (pldn and shortDispOk and shortDeltaOk)) and inSession and shortCooldownOk

// ---------------------------------------------------------------------------
// RISK / TRADE TRACKER
// ---------------------------------------------------------------------------
float slBuffer = slBufferTicks * syminfo.mintick

var float tradeEntry = na
var float tradeSL = na
var float tradeTP = na
var int   tradeDir = 0
var int   tradeEntryBar = na
var line  lineSL = na
var line  lineTP = na
var label lblSL = na
var label lblTP = na

// ta.lowest()/ta.highest() must be called unconditionally, every bar, for
// Pine's internal history tracking to work — that's why these live here at
// the top level rather than inside the ternary/function below. Putting them
// inside a conditional (the old version had them inside f_calcTrade, only
// invoked on the rare bars a signal fires) silently returns na, which is
// why Structure lookback extreme was producing no visible SL/TP at all.
float longStructExtreme  = ta.lowest(low[1], slLookbackBars)
float shortStructExtreme = ta.highest(high[1], slLookbackBars)

// Pure calculation only — no global mutation inside a function (CE10088).
// breakLevel falls back to the structure extreme if somehow na, so a trade
// never opens with an undefined stop.
f_calcTrade(bool isLong, float breakLevel, float structExtreme) =>
    float entry = close
    float rawSL = (slMethod == "Trendline break level" and not na(breakLevel)) ? breakLevel : structExtreme
    float sl = isLong ? rawSL - slBuffer : rawSL + slBuffer
    sl := isLong and sl >= entry ? entry - syminfo.mintick : sl
    sl := not isLong and sl <= entry ? entry + syminfo.mintick : sl
    float risk = math.abs(entry - sl)
    float rr = slMethod == "Trendline break level" ? rrRatioBreak : rrRatioStruct
    float tp = isLong ? entry + risk * rr : entry - risk * rr
    [entry, sl, tp]

if fireUp
    lastLongBar := bar_index
    [newEntry, newSL, newTP] = f_calcTrade(true, upBreakLevel, longStructExtreme)
    tradeEntry := newEntry
    tradeSL := newSL
    tradeTP := newTP
    tradeDir := 1
    tradeEntryBar := bar_index
    if showTradeTracker
        line.delete(lineSL), line.delete(lineTP)
        label.delete(lblSL), label.delete(lblTP)
        lineSL := line.new(bar_index, tradeSL, bar_index + 5, tradeSL, color = color.orange, style = line.style_solid, width = 2)
        lineTP := line.new(bar_index, tradeTP, bar_index + 5, tradeTP, color = color.blue, style = line.style_solid, width = 2)
        lblSL := label.new(bar_index + 5, tradeSL, text = "SL " + str.tostring(tradeSL, format.mintick), color = color.new(color.orange, 0), textcolor = color.white, style = label.style_label_left, size = size.small)
        lblTP := label.new(bar_index + 5, tradeTP, text = "TP " + str.tostring(tradeTP, format.mintick) + " (" + str.tostring(slMethod == "Trendline break level" ? rrRatioBreak : rrRatioStruct) + "R)", color = color.new(color.blue, 0), textcolor = color.white, style = label.style_label_left, size = size.small)

if fireDn
    lastShortBar := bar_index
    [newEntry, newSL, newTP] = f_calcTrade(false, dnBreakLevel, shortStructExtreme)
    tradeEntry := newEntry
    tradeSL := newSL
    tradeTP := newTP
    tradeDir := -1
    tradeEntryBar := bar_index
    if showTradeTracker
        line.delete(lineSL), line.delete(lineTP)
        label.delete(lblSL), label.delete(lblTP)
        lineSL := line.new(bar_index, tradeSL, bar_index + 5, tradeSL, color = color.orange, style = line.style_solid, width = 2)
        lineTP := line.new(bar_index, tradeTP, bar_index + 5, tradeTP, color = color.blue, style = line.style_solid, width = 2)
        lblSL := label.new(bar_index + 5, tradeSL, text = "SL " + str.tostring(tradeSL, format.mintick), color = color.new(color.orange, 0), textcolor = color.white, style = label.style_label_left, size = size.small)
        lblTP := label.new(bar_index + 5, tradeTP, text = "TP " + str.tostring(tradeTP, format.mintick) + " (" + str.tostring(slMethod == "Trendline break level" ? rrRatioBreak : rrRatioStruct) + "R)", color = color.new(color.blue, 0), textcolor = color.white, style = label.style_label_left, size = size.small)

// Trade completion cleanup
if not na(tradeEntry)
    if showTradeTracker
        line.set_x2(lineSL, bar_index + 5)
        line.set_x2(lineTP, bar_index + 5)
        label.set_x(lblSL, bar_index + 5)
        label.set_x(lblTP, bar_index + 5)
    bool tradeClosed = false
    if bar_index > tradeEntryBar
        if tradeDir == 1
            tradeClosed := low <= tradeSL or high >= tradeTP
        else if tradeDir == -1
            tradeClosed := high >= tradeSL or low <= tradeTP
    if tradeClosed
        if showTradeTracker
            line.delete(lineSL), line.delete(lineTP)
            label.delete(lblSL), label.delete(lblTP)
        tradeEntry := na
        tradeDir := 0
        tradeEntryBar := na

if fireUp
    alert(syminfo.ticker + " — BULLISH break | " + str.tostring(upBreakTaps) + " taps", alert.freq_once_per_bar_close)

if fireDn
    alert(syminfo.ticker + " — BEARISH break | " + str.tostring(dnBreakTaps) + " taps", alert.freq_once_per_bar_close)

// Notes:
// - The tier-1 and tier-2 alertcondition() entries are NOT session-gated, since
//   alertcondition() messages are static and can't evaluate the session flag.
//   Use the "Alert() function calls only" option for session-gated alerts.
// - Sessions are evaluated in America/New_York, so EST/EDT is handled for you.
//   1800-0000 covers the Globex evening block; 0700-1600 covers premarket
//   through the RTH close.
````
