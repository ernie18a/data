# Swing Master  Long Only (India)

- url: https://www.tradingview.com/script/NQXQiGaa-Swing-Master-Long-Only-India/
- type: indicator
- pine_id: PUB;412d5036f06b47f5ade79c4a6871eca0
- version: 1.0

## Description

SWING MASTER · Long Only (India)

A long-only swing trading indicator for Indian equities. It combines three entry triggers behind one master filter, grades confluence as "A+", and tracks a simple exit based on relative strength. Designed for the daily timeframe on NSE stocks.


WHAT IT DOES

The indicator fires a long entry when any one of three triggers occurs, but only if the stock is outperforming its index (the MARS filter below). When two or more triggers line up within a short window, the entry is graded A+. Once in a trade, the position is closed (stop loss) when relative strength turns negative.


ENTRY TRIGGERS

1. SuperTrend Swing High Breakout
When SuperTrend flips bullish, the highest high of the preceding bearish phase becomes the swing high level (scanned back up to 20 bars by default). The trigger fires on the first close above that level while SuperTrend is bullish. It fires once per bullish phase.

2. EMA High/Low Crossover + SuperTrend Up
Two EMAs (length 50) are calculated, one on highs and one on lows. The trigger fires when price closes above the EMA of highs while SuperTrend is bullish. It re-arms after price closes below the EMA of lows, extends 2x the EMA band width above the EMA of highs, or a MARS exit occurs.

3. EMA 9/21 Crossover
Fires when the 9 EMA crosses above the 21 EMA.


MASTER FILTER: MARS (Moving Average Relative Strength)

MARS = (stock % distance from its MA) minus (index % distance from its MA).
Default: 55-period SMA, compared against NSE:CNX500.

Entries are only allowed when MARS is above the minimum value (default 0), meaning the stock is stronger than the index relative to their moving averages. The MA type (SMA/EMA/WMA), length, index and minimum value are all adjustable.


A+ ENTRIES

If two or more triggers fire within the confluence window (default 3 bars), the entry is marked A+. Set the window to 1 to require all triggers on the same bar.


EXIT / STOP LOSS

While a position is open, the indicator closes it when MARS closes below the minimum value. A stop-loss marker appears on that bar with the trade's P/L %. After an exit, Triggers 1 and 2 re-arm so a new entry can form once MARS recovers. Later triggers while a position is open still show on the chart but do not change the original entry price.

Note: the position tracking is a visual simulation inside an indicator. It is not a strategy backtest and does not account for slippage, brokerage or gaps.


ALERT

One alert condition: "Long Entry (Any Trigger)". Create the alert on the indicator, select that condition, and set it to Once Per Bar Close. The alert message includes the ticker, timeframe and price. Check the symbol on the chart to see which trigger fired.


CHART VISUALS

- SuperTrend line (green bullish / red bearish)
- Dashed swing high level for the active bullish phase
- Entry symbols per trigger, A+ symbol for confluence, and a stop-loss symbol
- Info panel showing MARS value, filter status, SuperTrend direction, swing high level, position with live P/L, and the last entry


SETTINGS HIGHLIGHTS

- MARS: on/off, MA type, length, index, minimum value
- SuperTrend: ATR length (10), multiplier (3.0), swing lookback (20)
- EMA High/Low length (50), EMA 9/21 lengths
- A+ confluence window, optional "require bullish SuperTrend for all entries"
- Signal timing: confirm on bar close (on by default)
- Entry symbols: shape, colour and size for each trigger and for A+
- Stop-loss symbol: shape, colour, size, P/L text on/off
- Display toggles for SuperTrend, EMA bands, EMA 9/21, swing level and the panel


NOTES ON SIGNAL TIMING

Signals are confirmed on bar close, so they do not repaint. On the latest daily bar, the script treats the candle as closed once the session end time has passed, so after-hours entries appear. You can turn confirmation off to see signals live on the current bar; if you do, keep alerts on Once Per Bar Close.


CREDITS

- SuperTrend Swing High entry concept: Shubham Agrawal (Upsurge Club)
- MARS (Moving Average Relative Strength): based on the work of finallynitin and dman103 (Mozilla Public License 2.0)


DISCLAIMER

This indicator is for educational and informational purposes only and is not financial advice. Past signals do not guarantee future results. Always do your own research and manage risk.

## Source Code

````pine
//@version=6
// ============================================================================
// SWING MASTER · Long Only · Indian Equities
// ----------------------------------------------------------------------------
// ENTRY TRIGGERS (any one fires a signal)
//   1. SuperTrend · Swing High Breakout
//   2. EMA High/Low (50) Crossover + SuperTrend Up
//   3. EMA 9/21 Crossover
// MASTER FILTER : MARS (MA 55 vs NSE:CNX500) must be > Min value (default 0)
// A+ ENTRY      : 2+ triggers inside the confluence window
// EXIT / SL     : MARS closes below Min value while in a trade
// ALERT         : one alertcondition -> any entry trigger
// ============================================================================
indicator("Swing Master · Long Only (India)", shorttitle="SWING MASTER", overlay=true,
     max_bars_back=500, max_labels_count=500, max_lines_count=100)

// ════════════════════════════════════════════════════════════
// PALETTE
// ════════════════════════════════════════════════════════════
c_bull = #26a69a
c_bear = #ef5350
c_t1 = #f0b429
c_t2 = #29b6f6
c_t3 = #ba68c8
c_aplus = #00c853
c_swing = #90a4ae
c_white = #eceff1

// ════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════
G_MARS = "● MARS Filter / Stop Loss"
useMars = input.bool(true, "Require MARS > Min value for entries", group=G_MARS)
marsType = input.string("SMA", "MA Type", options=["SMA", "EMA", "WMA"], group=G_MARS)
marsLen = input.int(55, "MA Length", minval=2, group=G_MARS)
marsIdx = input.symbol("NSE:CNX500", "Index to compare", group=G_MARS)
marsMin = input.float(0.0, "Min MARS value", step=0.5, group=G_MARS,
     tooltip="Entries need MARS above this value. The trade is exited (Stop Loss) when MARS closes below it.")

G_ST = "● SuperTrend (Triggers 1 & 2)"
stLen = input.int(10, "ATR Length", minval=1, group=G_ST)
stMult = input.float(3.0, "ATR Multiplier", minval=0.1, step=0.1, group=G_ST)
swingLB = input.int(20, "Bear Phase Lookback (bars)", minval=5, maxval=100, group=G_ST,
     tooltip="Trigger 1: how far back to scan inside the bearish SuperTrend phase for the highest high.")

G_EMAHL = "● EMA High/Low Crossover (Trigger 2)"
emaLen = input.int(50, "EMA Length", minval=1, group=G_EMAHL)
profitMult = input.float(2.0, "Re-arm when extension ≥ (x EMA range)", minval=1.0, step=0.1, group=G_EMAHL,
     tooltip="Trigger 2 re-arms after price closes below EMA Low, or extends this many EMA-band widths above EMA High, or after a MARS exit.")

G_X = "● EMA Crossover (Trigger 3)"
fastLen = input.int(9, "Fast EMA", minval=1, group=G_X)
slowLen = input.int(21, "Slow EMA", minval=1, group=G_X)

G_CONF = "● Confluence / A+"
confWin = input.int(3, "A+ Confluence Window (bars)", minval=1, maxval=10, group=G_CONF,
     tooltip="An entry is graded A+ when 2 or more triggers fired within this many bars (including the current bar). Set to 1 to require the same bar.")
reqBull = input.bool(false, "Require bullish SuperTrend for ALL entries", group=G_CONF)

G_TIME = "● Signal Timing"
confirmClose = input.bool(true, "Confirm signals on bar close (no repaint)", group=G_TIME,
     tooltip="ON: signals appear only once the bar has closed. The latest bar counts as closed after its session ends (so after-hours daily entries show). OFF: signals show live on the current bar and may disappear before the close; keep your alert on 'Once Per Bar Close'.")

G_SYM = "● Entry Symbols"
shpT1 = input.string("Triangle Up", "T1 · ST Swing High — Shape", options=["Triangle Up", "Arrow Up", "Circle", "Diamond", "Square", "Cross", "X Cross", "Flag", "Label Up"], inline="t1", group=G_SYM)
colT1 = input.color(c_t1, "", inline="t1", group=G_SYM)
shpT2 = input.string("Circle", "T2 · EMA 50 H/L — Shape", options=["Triangle Up", "Arrow Up", "Circle", "Diamond", "Square", "Cross", "X Cross", "Flag", "Label Up"], inline="t2", group=G_SYM)
colT2 = input.color(c_t2, "", inline="t2", group=G_SYM)
shpT3 = input.string("Diamond", "T3 · EMA 9/21 — Shape", options=["Triangle Up", "Arrow Up", "Circle", "Diamond", "Square", "Cross", "X Cross", "Flag", "Label Up"], inline="t3", group=G_SYM)
colT3 = input.color(c_t3, "", inline="t3", group=G_SYM)
shpAp = input.string("Label Up", "A+ Entry — Shape", options=["Triangle Up", "Arrow Up", "Circle", "Diamond", "Square", "Cross", "X Cross", "Flag", "Label Up"], inline="ap", group=G_SYM)
colAp = input.color(c_aplus, "", inline="ap", group=G_SYM)
symSizeIn = input.string("Large", "Entry symbol size (T1–T3)", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_SYM)
apSizeIn = input.string("Huge", "A+ symbol size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_SYM)

G_EXIT = "● MARS Stop-Loss Symbol"
slShape = input.string("Label Down", "SL — Shape", options=["Label Down", "Triangle Down", "Arrow Down", "Circle", "Diamond", "Square", "Cross", "X Cross", "Flag"], inline="sl", group=G_EXIT)
slCol = input.color(c_bear, "", inline="sl", group=G_EXIT)
slSizeIn = input.string("Normal", "SL — Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_EXIT)
slShowPL = input.bool(true, "Show P/L % on SL marker", group=G_EXIT)

G_DISP = "● Display"
showST = input.bool(true, "Plot SuperTrend", group=G_DISP)
showEmaHL = input.bool(false, "Plot EMA High / Low bands", group=G_DISP)
showEmaXO = input.bool(false, "Plot EMA 9/21", group=G_DISP)
showSwing = input.bool(true, "Plot active Swing High level", group=G_DISP)
showTable = input.bool(true, "Show info panel", group=G_DISP)

// ════════════════════════════════════════════════════════════
// SIZE MAPPING
// ════════════════════════════════════════════════════════════
symSz = switch symSizeIn
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.large

apSz = switch apSizeIn
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.huge

slSz = switch slSizeIn
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.normal

// ════════════════════════════════════════════════════════════
// HELPERS · markers drawn as labels (uses no plot slots)
// ════════════════════════════════════════════════════════════
f_sym(string name) =>
    switch name
        "Triangle Up"   => "▲"
        "Triangle Down" => "▼"
        "Arrow Up"      => "↑"
        "Arrow Down"    => "↓"
        "Circle"        => "●"
        "Diamond"       => "◆"
        "Square"        => "■"
        "Cross"         => "✚"
        "X Cross"       => "✖"
        "Flag"          => "⚑"
        => "▲"

// Single-trigger entry marker
f_single(string shp, color col, string tag, string sz) =>
    if shp == "Label Up"
        label.new(bar_index, low, tag, yloc=yloc.belowbar, style=label.style_label_up,
             color=col, textcolor=color.white, size=sz)
    else
        label.new(bar_index, low, f_sym(shp), yloc=yloc.belowbar, style=label.style_none,
             color=color.new(color.black, 100), textcolor=col, size=sz)

// A+ entry marker
f_aplus(string shp, color col, string sz) =>
    if shp == "Label Up"
        label.new(bar_index, low, "A+", yloc=yloc.belowbar, style=label.style_label_up,
             color=col, textcolor=color.white, size=sz)
    else
        label.new(bar_index, low, f_sym(shp) + "\nA+", yloc=yloc.belowbar, style=label.style_none,
             color=color.new(color.black, 100), textcolor=col, size=sz)

// ════════════════════════════════════════════════════════════
// SUPERTREND (shared by Triggers 1 & 2)
// ════════════════════════════════════════════════════════════
atrVal = ta.atr(stLen)
ubRaw = hl2 + stMult * atrVal
lbRaw = hl2 - stMult * atrVal

var float ub = na
var float lb = na
var int stDir = 1

ub := (ubRaw < nz(ub[1]) or close[1] > nz(ub[1])) ? ubRaw : nz(ub[1])
lb := (lbRaw > nz(lb[1]) or close[1] < nz(lb[1])) ? lbRaw : nz(lb[1])

if stDir == -1 and close > ub[1]
    stDir := 1
else if stDir == 1 and close < lb[1]
    stDir := -1

stLine = stDir == 1 ? lb : ub
isBull = stDir == 1
bullFlip = isBull and stDir[1] == -1

// ════════════════════════════════════════════════════════════
// MARS  (Moving Average Relative Strength vs Index)
// ════════════════════════════════════════════════════════════
idxClose = request.security(marsIdx, timeframe.period, close)

maS_sma = ta.sma(close, marsLen)
maS_ema = ta.ema(close, marsLen)
maS_wma = ta.wma(close, marsLen)
maI_sma = ta.sma(idxClose, marsLen)
maI_ema = ta.ema(idxClose, marsLen)
maI_wma = ta.wma(idxClose, marsLen)

maSym = marsType == "SMA" ? maS_sma : marsType == "EMA" ? maS_ema : maS_wma
maIdx = marsType == "SMA" ? maI_sma : marsType == "EMA" ? maI_ema : maI_wma

symPct = (close - maSym) / maSym * 100
idxPct = (idxClose - maIdx) / maIdx * 100
marsVal = symPct - idxPct

marsOk = not useMars or marsVal > marsMin

// ════════════════════════════════════════════════════════════
// BAR-CLOSE TIMING
// The latest daily bar stays "unconfirmed" after the NSE session ends, so it is
// also treated as closed once the current time has passed the bar's close time.
// ════════════════════════════════════════════════════════════
barDone = barstate.isconfirmed or (barstate.islast and timenow >= time_close)
timingOk = not confirmClose or barDone

// Master gate for every entry trigger
gate = marsOk and (not reqBull or isBull) and timingOk

// ════════════════════════════════════════════════════════════
// TRIGGER 1 · SuperTrend Swing High Breakout
// ════════════════════════════════════════════════════════════
float ph = high[1]
for i = 1 to swingLB
    if stDir[i] == 1
        break
    ph := math.max(ph, nz(high[i], ph))

var float shLevel = na
var bool stTaken = false

if bullFlip
    shLevel := ph
    stTaken := false

raw1 = isBull and not stTaken and not na(shLevel) and close > shLevel and close[1] <= shLevel
t1 = raw1 and gate
if t1
    stTaken := true

// ════════════════════════════════════════════════════════════
// TRIGGER 2 · EMA High/Low Crossover + SuperTrend Up
// ════════════════════════════════════════════════════════════
emaH = ta.ema(high, emaLen)
emaL = ta.ema(low, emaLen)
crossAboveH = ta.crossover(close, emaH)
crossBelowL = ta.crossunder(close, emaL)
emaRange = emaH - emaL
extRatio = emaRange > 0 ? (close - emaH) / emaRange : 0.0

var bool emaActive = false
raw2 = crossAboveH and isBull and not emaActive
t2 = raw2 and gate
if t2
    emaActive := true
else if emaActive and (crossBelowL or extRatio >= profitMult)
    emaActive := false

// ════════════════════════════════════════════════════════════
// TRIGGER 3 · EMA 9/21 Crossover
// ════════════════════════════════════════════════════════════
emaF = ta.ema(close, fastLen)
emaS = ta.ema(close, slowLen)
cross3 = ta.crossover(emaF, emaS)
t3 = cross3 and gate

// ════════════════════════════════════════════════════════════
// CONFLUENCE / GRADING
// ════════════════════════════════════════════════════════════
bs1 = ta.barssince(t1)
bs2 = ta.barssince(t2)
bs3 = ta.barssince(t3)
r1 = not na(bs1) and bs1 < confWin
r2 = not na(bs2) and bs2 < confWin
r3 = not na(bs3) and bs3 < confWin

confCount = (r1 ? 1 : 0) + (r2 ? 1 : 0) + (r3 ? 1 : 0)
anyEntry = t1 or t2 or t3
isAplus = anyEntry and confCount >= 2

// ════════════════════════════════════════════════════════════
// PLOTS  (5 total, well under the 64 limit)
// ════════════════════════════════════════════════════════════
plot(showST ? stLine : na, "SuperTrend",
     color = isBull ? color.new(c_bull, 0) : color.new(c_bear, 30),
     linewidth = 2, style = plot.style_linebr)
plot(showEmaHL ? emaH : na, "EMA High", color=color.new(color.green, 20), linewidth=1)
plot(showEmaHL ? emaL : na, "EMA Low", color=color.new(color.red, 20), linewidth=1)
plot(showEmaXO ? emaF : na, "Fast EMA", color=color.new(#00D9FF, 20), linewidth=1)
plot(showEmaXO ? emaS : na, "Slow EMA", color=color.new(#FF8C00, 20), linewidth=1)

// Active Swing High level (Trigger 1): drawn once per SuperTrend flip, then extended
var line shLine = na
if showSwing
    if bullFlip and not na(shLevel)
        if not na(shLine)
            line.delete(shLine)
        shLine := line.new(bar_index, shLevel, bar_index, shLevel,
             color=color.new(c_swing, 40), style=line.style_dashed, width=1)
    else if isBull and not na(shLine)
        line.set_x2(shLine, bar_index)
        line.set_color(shLine, color.new(c_swing, stTaken ? 75 : 40))

// ════════════════════════════════════════════════════════════
// ENTRY MARKERS  (shape, colour and size user-selectable in Inputs)
// A+ replaces the single-trigger marker on that bar.
// ════════════════════════════════════════════════════════════
if isAplus
    f_aplus(shpAp, colAp, apSz)
else
    if t1
        f_single(shpT1, colT1, "T1", symSz)
    if t2
        f_single(shpT2, colT2, "T2", symSz)
    if t3
        f_single(shpT3, colT3, "T3", symSz)

// ════════════════════════════════════════════════════════════
// POSITION TRACKING + MARS STOP LOSS
// ════════════════════════════════════════════════════════════
var bool inTrade = false
var float entryPx = na
var string lastEntry = "None"

slHit = inTrade and marsVal < marsMin and timingOk

if slHit
    float plPct = (close / entryPx - 1) * 100
    string plTxt = str.tostring(plPct, "#.##") + "%"
    if slShape == "Label Down"
        label.new(bar_index, high, "MARS SL" + (slShowPL ? "\n" + plTxt : ""),
             color=color.new(slCol, 10), textcolor=color.white,
             style=label.style_label_down, size=slSz)
    else
        label.new(bar_index, high, (slShowPL ? "SL " + plTxt + "\n" : "") + f_sym(slShape),
             yloc=yloc.abovebar, style=label.style_none,
             color=color.new(color.black, 100), textcolor=slCol, size=slSz)
    inTrade := false
    entryPx := na
    emaActive := false   // allow a fresh Trigger 2 entry after the exit
    stTaken := false     // allow a fresh Trigger 1 breakout after the exit
else if anyEntry and not inTrade
    inTrade := true
    entryPx := close

// Last entry description for the info panel
if anyEntry
    string names = (r1 ? "Swing High + " : "") + (r2 ? "EMA50 H/L + " : "") + (r3 ? "EMA 9/21 + " : "")
    names := str.length(names) > 3 ? str.substring(names, 0, str.length(names) - 3) : names
    lastEntry := (isAplus ? "A+ · " : "") + names

// ════════════════════════════════════════════════════════════
// SINGLE ALERT · fires when ANY entry trigger occurs
// ════════════════════════════════════════════════════════════
alertcondition(anyEntry, "Long Entry (Any Trigger)",
     "LONG ENTRY: {{ticker}} {{interval}} @ {{close}} | Trigger: ST Swing High / EMA50 H/L / EMA 9/21 | MARS filter passed. Exit rule: MARS closes below its minimum.")

// ════════════════════════════════════════════════════════════
// INFO PANEL
// ════════════════════════════════════════════════════════════
var table tbl = table.new(position.bottom_right, 2, 7,
     bgcolor=color.new(#0d1117, 15), border_color=color.new(#30363d, 60), border_width=1,
     frame_color=color.new(#30363d, 40), frame_width=1)

if showTable and barstate.islast
    openPL = inTrade and not na(entryPx) ? (close / entryPx - 1) * 100 : na

    table.cell(tbl, 0, 0, "SWING MASTER · Long Only", text_color=color.new(c_white, 30),
         text_size=size.small, text_halign=text.align_left, bgcolor=color.new(#161b22, 20))
    table.cell(tbl, 1, 0, "", bgcolor=color.new(#161b22, 20))

    table.cell(tbl, 0, 1, "MARS (" + str.tostring(marsLen) + ")", text_color=color.new(c_white, 50),
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 1, na(marsVal) ? "—" : str.tostring(marsVal, "#.##"),
         text_color = marsVal > marsMin ? c_bull : c_bear,
         text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 2, "MARS Filter", text_color=color.new(c_white, 50),
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 2, not useMars ? "OFF" : marsOk ? "PASS" : "BLOCKED",
         text_color = not useMars ? c_swing : marsOk ? c_bull : c_bear,
         text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 3, "SuperTrend", text_color=color.new(c_white, 50),
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 3, isBull ? "▲ Bullish" : "▼ Bearish",
         text_color = isBull ? c_bull : color.new(c_bear, 40),
         text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 4, "Swing High", text_color=color.new(c_white, 50),
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 4, na(shLevel) ? "—" : (stTaken ? "Taken" : str.tostring(shLevel, format.mintick)),
         text_color = stTaken ? color.new(c_swing, 60) : colT1,
         text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 5, "Position", text_color=color.new(c_white, 50),
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 5, inTrade ? "LONG  " + str.tostring(openPL, "#.##") + "%" : "FLAT",
         text_color = inTrade ? (openPL >= 0 ? c_bull : c_bear) : c_swing,
         text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 6, "Last Entry", text_color=color.new(c_white, 50),
         text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 6, lastEntry,
         text_color = str.startswith(lastEntry, "A+") ? colAp : color.new(c_white, 20),
         text_size=size.small, text_halign=text.align_right)
````
