# RSI Hidden Divergence: 200 EMA + Stochastic [forexobroker]

- url: https://www.tradingview.com/script/beEnSy62-RSI-Hidden-Divergence-200-EMA-Stochastic-forexobroker/
- type: indicator
- pine_id: PUB;540ae84b7eea40fd98156e0f940e7aa2
- version: 1.0

## Description

RSI Hidden Divergence: 200 EMA + Stochastic [forexobroker]

🔶 OVERVIEW

RSI Hidden Divergence turns a popular divergence strategy into exact, testable rules: the 200 EMA decides which side you may trade, a hidden divergence on the RSI finds the pullback inside the trend, and a Stochastic cross confirms the entry. Every entry is drawn with its stop and its target, every trade is followed to its result, and the last 100 results are counted in a table on the chart.

It is built for traders who want to see, on their own symbol and timeframe, what hidden divergence really did over the last 100 trades, wins and losses alike, before they trust it. A switch turns the Stochastic confirmation off, and a second setting swaps hidden divergence for the regular (reversal) kind, so both choices can be measured on the same chart.

🔶 HOW IT WORKS

1. The side (200 EMA). A close above the 200 EMA allows bullish hidden divergences only; below it, bearish only.

2. The RSI swing (RSI 14). The latest RSI swing low: an RSI value with 3 higher RSI values on each side, confirmed 3 candles later, at most 40 candles old. Two horizontal levels are kept: the RSI value at that swing, and the close on the same candle (the line-chart price of the swing). For sells, the latest RSI swing high.

3. The hidden divergence. A closed candle where the RSI is below its swing level while the close is still above its price level: price makes a higher low, the RSI makes a lower low. A small yellow dot marks the swing candle and a dashed line its close, up to the divergence candle. Bearish: the mirror on an RSI swing high.

4. The confirmation (Stochastic 14, 3, 3, TradingView's defaults). The first %K cross above %D (below, for a sell) within 10 candles of the divergence, while the close has not broken the price level. Entry at that candle's close. One trade per RSI swing.

🔶 TRADE MANAGEMENT

Stop beyond the nearest swing: the most recent swing low below the entry (a low with two higher lows on each side) within the last 30 candles, or, when none qualifies, the lowest low of the last 10 candles. Sells use the swing highs. The swing used is marked with a small red dot. Target at a fixed reward multiple of the stop distance, 1.5R by default. The trade is drawn as a red box from the entry to the stop and a green box from the entry to the target, with a "+1.5R" or "-1R" label at the end.

Optional "Regular" divergence type: a buy needs price making a lower low while the RSI makes a higher low (the reversal reading), with no EMA side; the Stochastic confirmation, the stop and the target stay the same.

🔶 THE LOG

One trade at a time. A valid entry that appears while a trade is still open is drawn faded and is not counted (switch "Allow overlapping trades" on to count every entry). Every open trade is followed on closed candles to its stop or its target. When one candle touches both, the stop is counted first: that is the conservative reading of an ambiguous candle.

The last N results (100 by default) feed the table: signals, wins, losses, win rate, total R, best win streak, worst loss streak and days covered, followed by the live state: the EMA side, the RSI swing being watched, a divergence waiting for its cross, the Stochastic, the divergence type and the open trade.

NON-REPAINTING: every condition, every signal and every result is evaluated on barstate.isconfirmed; the RSI swing and the price swing used for a stop are pivots confirmed on earlier candles; there is no request.security and no lookahead.

🔶 SETTINGS

Indicators
- EMA length (200), RSI length (14), Stochastic %K length, %K smoothing, %D smoothing (14, 3, 3).

Divergence
- Divergence type: Hidden (default) or Regular.
- RSI swing strength (3 candles each side), RSI swing at most (40 candles old).
- Require the Stochastic cross (default on), Stochastic cross within (10 candles).
- Allow overlapping trades (default off): one trade at a time.
- Take buys, Take sells.

Trade
- Swing strength (2 candles each side), Swing search (30 candles back), Fallback lookback (10 candles).
- Reward ratio (default 1.5): target = stop distance × this.
- Extend open trade boxes (bars).

Log
- Log size (default 100), Show log table, Table position, Table text size.

Visual
- Buy, sell, EMA and divergence colours; show the EMA; mark the RSI swing and the price line; mark the swing used for the stop; BUY / SELL labels; +R / -R result labels; trades kept on chart; box fill transparency.

Alerts
- Send JSON alert() messages.

🔶 ALERTS

Three alertcondition hooks: RHD Buy entry, RHD Sell entry, RHD Any entry. With "Send JSON alert() messages" on, every taken entry also fires an alert() once per bar close with a JSON body (action, ticker, timeframe, entry, stop, target).

🔶 LIMITATIONS

- A divergence is a warning, not a guarantee. Many divergences are followed by more of the same move; the log's win rate and worst loss streak show how often that happened on your symbol.
- With a 1.5R target the strategy needs to win more than four trades in ten. Check the win rate in the table before anything else.
- The RSI swing is confirmed 3 candles after it formed, so the levels appear a few candles late by design; nothing is redrawn.
- Results in the log are the script's own rules applied to closed candles: no spread, no commission, no slippage, and the stop is counted before the target on a candle that touches both.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: RSI Hidden Divergence — the 200 EMA, the RSI and the Stochastic in one rule set, with its own trade log.
// (1) The side (200 EMA): a close above the 200 EMA allows bullish hidden divergences only, below it bearish only.
// (2) The RSI swing: the latest RSI swing low (an RSI pivot low with N candles on each side, confirmed N candles later)
//     within the last few candles. Two horizontal lines are kept: the RSI value at that swing, and the close on the
//     same candle (the line-chart price of the swing).
// (3) The hidden divergence: a closed candle with the RSI below its line while the close is still above the price
//     line (price makes a higher low, the RSI a lower low). Bearish: the mirror on an RSI swing high.
// (4) The confirmation (Stochastic): the first %K cross above %D (below, for a sell) within a few candles of the
//     setup, while the price line is still unbroken. Entry at that candle's close. One trade per RSI swing.
// Optional "Regular" type: price lower low with an RSI higher low for a buy (the reversal reading), no EMA side.
// The stop sits beyond the nearest swing (the most recent pivot low below the entry, else the lowest low of the last
// few candles); the target is 1.5 times the stop distance by default. One trade at a time; every trade is followed to
// its stop or target on closed candles, stop first when a candle touches both, and the last N results feed the log.
// Non-repainting: every condition and every trade result is evaluated on barstate.isconfirmed, there is no
// request.security and no lookahead; the RSI swing and the price swing used for a stop are pivots confirmed earlier.
indicator("RSI Hidden Divergence: 200 EMA + Stochastic [forexobroker]", shorttitle="RHD [fob]", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_ind    = "Indicators"
string g_div    = "Divergence"
string g_trade  = "Trade"
string g_ledger = "Log"
string g_vis    = "Visual"
string g_alert  = "Alerts"

// ─── INPUTS: INDICATORS ────────────────────────────────────────────────────────
int i_emaLen   = input.int(200, "EMA length (the trend side)", minval=2, maxval=1000, group=g_ind)
int i_rsiLen   = input.int(14, "RSI length", minval=2, maxval=200, group=g_ind)
int i_kLen     = input.int(14, "Stochastic %K length", minval=2, maxval=200, group=g_ind)
int i_kSmooth  = input.int(3, "Stochastic %K smoothing", minval=1, maxval=20, group=g_ind)
int i_dSmooth  = input.int(3, "Stochastic %D smoothing", minval=1, maxval=20, group=g_ind, tooltip="14, 3, 3 are TradingView's default Stochastic settings (%K length, %K smoothing, %D smoothing), so the built-in Stochastic pane shows the same two lines.")

// ─── INPUTS: DIVERGENCE ────────────────────────────────────────────────────────
string i_type     = input.string("Hidden", "Divergence type", options=["Hidden", "Regular"], group=g_div, tooltip="Hidden (default): trend continuation. A buy needs price above the EMA, price making a higher low while the RSI makes a lower low. Regular: the reversal reading. A buy needs price making a lower low while the RSI makes a higher low, with no EMA side.")
int    i_pivLen   = input.int(3, "RSI swing strength (candles each side)", minval=1, maxval=10, group=g_div, tooltip="An RSI swing low is an RSI value with this many higher RSI values on each side. It is confirmed this many candles after it formed.")
int    i_pivAge   = input.int(40, "RSI swing: at most (candles old)", minval=5, maxval=300, group=g_div, tooltip="Only the latest RSI swing counts, and only while it is at most this many candles old.")
bool   i_reqStoch = input.bool(true, "Require the Stochastic cross", group=g_div, tooltip="ON (default): after the divergence, wait for the Stochastic %K to cross above %D (below, for a sell) and enter on that candle. OFF: enter on the divergence candle itself. The log counts only the entries the settings let through.")
int    i_window   = input.int(10, "Stochastic cross within (candles)", minval=1, maxval=50, group=g_div, tooltip="The cross must come within this many candles of the divergence, while the price line is still unbroken.")
bool   i_allowOverlap = input.bool(false, "Allow overlapping trades", group=g_div, tooltip="OFF (default): one trade at a time. A valid entry that appears while a trade is still open is drawn faded and is not counted in the log.")
bool   i_longs  = input.bool(true, "Take buys", group=g_div)
bool   i_shorts = input.bool(true, "Take sells", group=g_div)

// ─── INPUTS: TRADE ─────────────────────────────────────────────────────────────
int   i_swStr      = input.int(2, "Swing strength (candles each side)", minval=1, maxval=10, group=g_trade, tooltip="A price swing low is a low with this many higher lows on each side.")
int   i_swSearch   = input.int(30, "Swing search (candles back)", minval=5, maxval=200, group=g_trade, tooltip="The stop uses the most recent price swing low below the entry (swing high above it, for sells) within this many candles.")
int   i_fallback   = input.int(10, "Fallback lookback (candles)", minval=2, maxval=100, group=g_trade, tooltip="When no swing qualifies, the stop goes at the lowest low (highest high) of this many candles.")
float i_rr         = input.float(1.5, "Reward ratio (target = stop × this)", minval=0.5, maxval=10.0, step=0.5, group=g_trade, tooltip="1.5 = the target sits one and a half times the stop distance away. A win adds this many R to the log, a loss subtracts 1R.")
int   i_extendBars = input.int(30, "Extend open trade boxes (bars)", minval=5, maxval=200, group=g_trade)

// ─── INPUTS: LOG ───────────────────────────────────────────────────────────────
int    i_ledgerN   = input.int(100, "Log size (last N signals)", minval=10, maxval=500, group=g_ledger, tooltip="The rolling number of completed trades the table summarises. The '100 trades' test of the video is this table at 100.")
bool   i_showTable = input.bool(true, "Show log table", group=g_ledger)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_ledger)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_ledger)

// ─── INPUTS: VISUAL ────────────────────────────────────────────────────────────
color i_bullCol    = input.color(#00E5A8, "Buy colour", group=g_vis)
color i_bearCol    = input.color(#FF3B5C, "Sell colour", group=g_vis)
color i_emaCol     = input.color(#4DA3FF, "EMA colour", group=g_vis)
color i_divCol     = input.color(#F5C542, "Divergence colour", group=g_vis)
bool  i_showEma    = input.bool(true, "Show the EMA", group=g_vis)
bool  i_showDiv    = input.bool(true, "Mark the RSI swing and the price line", group=g_vis, tooltip="A small dot on the candle of the RSI swing used, and a dashed line at its close up to the divergence candle.")
bool  i_showSwing  = input.bool(true, "Mark the swing used for the stop", group=g_vis)
bool  i_showLabels = input.bool(true, "Show BUY / SELL labels", group=g_vis)
bool  i_showResult = input.bool(true, "Show +R / -R result labels", group=g_vis)
int   i_keepTrades = input.int(120, "Trades kept on chart", minval=1, maxval=200, group=g_vis, tooltip="How many past trades keep their boxes and labels before the oldest are removed.")
int   i_boxFill    = input.int(78, "Box fill transparency", minval=50, maxval=95, group=g_vis)

// ─── INPUTS: ALERTS ────────────────────────────────────────────────────────────
bool i_alertJson = input.bool(true, "Send JSON alert() messages", group=g_alert, tooltip="Besides the alertcondition hooks, fire an alert() with a JSON body on every entry (once per bar close). Useful for webhooks.")

color c_white  = #FFFFFF
color c_dark   = #0B0F14
color c_purple = #A259FF
color c_grey   = #9AA4AE

// ─── INDICATORS ────────────────────────────────────────────────────────────────
bool  confirmed = barstate.isconfirmed
bool  hidden = i_type == "Hidden"
float emaV = ta.ema(close, i_emaLen)
float rsiV = ta.rsi(close, i_rsiLen)
float kV   = ta.sma(ta.stoch(close, high, low, i_kLen), i_kSmooth)
float dV   = ta.sma(kV, i_dSmooth)
bool  ready = not na(emaV) and not na(rsiV) and not na(kV) and not na(dV) and not na(kV[1]) and not na(dV[1])
bool  crossUp = ready and kV > dV and kV[1] <= dV[1]
bool  crossDn = ready and kV < dV and kV[1] >= dV[1]

// ─── RSI SWINGS (pivots on the RSI, confirmed i_pivLen candles later) ──────────
float rPl = ta.pivotlow(rsiV, i_pivLen, i_pivLen)
float rPh = ta.pivothigh(rsiV, i_pivLen, i_pivLen)
var int   lowBar = na
var float lowRsi = na
var float lowPx  = na
var int   highBar = na
var float highRsi = na
var float highPx  = na
var int   usedLow = na
var int   usedHigh = na
if not na(rPl)
    lowBar := bar_index - i_pivLen
    lowRsi := rPl
    lowPx := close[i_pivLen]
if not na(rPh)
    highBar := bar_index - i_pivLen
    highRsi := rPh
    highPx := close[i_pivLen]

// ─── PRICE SWINGS FOR THE STOP (confirmed pivots, kept with the bar they formed on)
float plV = ta.pivotlow(low, i_swStr, i_swStr)
float phV = ta.pivothigh(high, i_swStr, i_swStr)
var array<float> plVal = array.new<float>()
var array<int>   plBar = array.new<int>()
var array<float> phVal = array.new<float>()
var array<int>   phBar = array.new<int>()
if not na(plV)
    array.push(plVal, plV)
    array.push(plBar, bar_index - i_swStr)
    if array.size(plVal) > 60
        array.shift(plVal)
        array.shift(plBar)
if not na(phV)
    array.push(phVal, phV)
    array.push(phBar, bar_index - i_swStr)
    if array.size(phVal) > 60
        array.shift(phVal)
        array.shift(phBar)

// ta.lowest / ta.highest must run on every bar: evaluate the fallbacks unconditionally
float fbLow  = ta.lowest(low, i_fallback)
int   fbLowB = bar_index + ta.lowestbars(low, i_fallback)
float fbHigh = ta.highest(high, i_fallback)
int   fbHighB = bar_index + ta.highestbars(high, i_fallback)

// ─── DIVERGENCE SETUP STATE ────────────────────────────────────────────────────
var int   setDir = 0          // 1 a bullish divergence waits for the cross, -1 bearish, 0 none
var int   setBar = na
var int   setPivBar = na
var float setPivRsi = na
var float setPivPx = na
bool setupNew = false
if confirmed and ready
    // an armed setup expires after the window, or when price breaks its line (hidden: the higher low is gone)
    if setDir != 0
        bool expired = bar_index - setBar > i_window
        bool broken = hidden and (setDir == 1 ? close < setPivPx : close > setPivPx)
        if expired or broken
            setDir := 0
    if setDir == 0
        bool lowFresh = not na(lowBar) and bar_index - lowBar <= i_pivAge and (na(usedLow) or lowBar != usedLow)
        bool highFresh = not na(highBar) and bar_index - highBar <= i_pivAge and (na(usedHigh) or highBar != usedHigh)
        bool bullDiv = hidden ? (close > emaV and rsiV < lowRsi and close > lowPx) : (rsiV > lowRsi and close < lowPx)
        bool bearDiv = hidden ? (close < emaV and rsiV > highRsi and close < highPx) : (rsiV < highRsi and close > highPx)
        if i_longs and lowFresh and bullDiv
            setDir := 1
            setBar := bar_index
            setPivBar := lowBar
            setPivRsi := lowRsi
            setPivPx := lowPx
            setupNew := true
        else if i_shorts and highFresh and bearDiv
            setDir := -1
            setBar := bar_index
            setPivBar := highBar
            setPivRsi := highRsi
            setPivPx := highPx
            setupNew := true
        if setupNew and i_showDiv
            label.new(setPivBar, setPivPx, "", color=color.new(i_divCol, 0), style=label.style_circle, size=size.tiny, tooltip="The RSI swing used: RSI " + str.tostring(setPivRsi, "#.#") + ", close " + str.tostring(setPivPx, format.mintick))
            line.new(setPivBar, setPivPx, bar_index, setPivPx, color=color.new(i_divCol, 10), style=line.style_dashed, width=1)

// ─── OPEN TRADE AND LOG STATE ──────────────────────────────────────────────────
var int   tDir = 0
var float tEntry = na
var float tStop = na
var float tTarget = na
var int   tBar = na
var box   tStopBox = na
var box   tTargetBox = na
var array<box>   tBoxes = array.new<box>()
var array<label> tLabels = array.new<label>()

var array<float> ledgerR = array.new<float>()
var array<int>   ledgerT = array.new<int>()
var int   ledgerWins = 0
var int   ledgerLosses = 0
var float ledgerTotalR = 0.0

f_pushResult(float _r, int _t) =>
    array.push(ledgerR, _r)
    array.push(ledgerT, _t)
    if array.size(ledgerR) > 0
        while array.size(ledgerR) > i_ledgerN
            array.shift(ledgerR)
            array.shift(ledgerT)

f_trimDrawings() =>
    if array.size(tBoxes) > 0
        while array.size(tBoxes) > i_keepTrades * 2
            box.delete(array.shift(tBoxes))
    if array.size(tLabels) > 0
        while array.size(tLabels) > i_keepTrades * 3
            label.delete(array.shift(tLabels))

// Result of the open trade on this confirmed bar. The stop is checked BEFORE the target: when one candle touches
// both, the loss is booked. This is the conservative reading of an ambiguous candle.
float resultR = na
float exitLevel = na
if confirmed and tDir != 0 and bar_index > tBar
    bool stopHit = tDir == 1 ? low <= tStop : high >= tStop
    bool targetHit = tDir == 1 ? high >= tTarget : low <= tTarget
    if stopHit
        resultR := -1.0
        exitLevel := tStop
    else if targetHit
        resultR := i_rr
        exitLevel := tTarget
    if not na(resultR)
        f_pushResult(resultR, time)
        if not na(tStopBox)
            box.set_right(tStopBox, bar_index)
            box.set_right(tTargetBox, bar_index)
        if i_showResult
            bool win = resultR > 0
            string txt = (resultR > 0 ? "+" : "") + str.tostring(resultR, "#.#") + "R"
            label rl = label.new(bar_index, exitLevel, txt, color=color.new(win ? i_bullCol : i_bearCol, 0), textcolor=win ? c_dark : c_white, style=tDir == 1 ? (win ? label.style_label_down : label.style_label_up) : (win ? label.style_label_up : label.style_label_down), size=size.small)
            array.push(tLabels, rl)
        tDir := 0
        tEntry := na
        tStop := na
        tTarget := na
        tBar := na
        tStopBox := na
        tTargetBox := na
        f_trimDrawings()

if tDir != 0 and not na(tStopBox)
    box.set_right(tStopBox, bar_index + i_extendBars)
    box.set_right(tTargetBox, bar_index + i_extendBars)

// ─── THE SIGNAL ────────────────────────────────────────────────────────────────
int   signal = 0
bool  skipped = false
float sEntry = na
float sStop = na
float sTarget = na
int   sSwingKind = 0
int   sSwingBar = na
int   sPivBar = na
float sPivRsi = na
float sPivPx = na
int   sSetBar = na

if confirmed and ready and setDir != 0
    bool cross = setDir == 1 ? crossUp : crossDn
    if cross or not i_reqStoch
        signal := setDir
        sPivBar := setPivBar
        sPivRsi := setPivRsi
        sPivPx := setPivPx
        sSetBar := setBar
        if setDir == 1
            usedLow := setPivBar
        else
            usedHigh := setPivBar
        setDir := 0                    // one trade per RSI swing

if signal != 0
    float lvl = na
    int   at = na
    int   kind = 0
    if signal == 1
        int n = array.size(plVal)
        if n > 0
            for i = n - 1 to 0
                int b = array.get(plBar, i)
                if bar_index - b > i_swSearch
                    break
                float v = array.get(plVal, i)
                if v < close
                    lvl := v
                    at := b
                    kind := 1
                    break
        if na(lvl)
            lvl := fbLow
            at := fbLowB
    else
        int n = array.size(phVal)
        if n > 0
            for i = n - 1 to 0
                int b = array.get(phBar, i)
                if bar_index - b > i_swSearch
                    break
                float v = array.get(phVal, i)
                if v > close
                    lvl := v
                    at := b
                    kind := 1
                    break
        if na(lvl)
            lvl := fbHigh
            at := fbHighB
    float dist = math.max(math.abs(close - lvl), syminfo.mintick * 5)
    sSwingKind := kind
    sSwingBar := at
    sEntry := close
    sStop := signal == 1 ? close - dist : close + dist
    sTarget := signal == 1 ? close + dist * i_rr : close - dist * i_rr
    if i_allowOverlap or tDir == 0
        tDir := signal
        tEntry := sEntry
        tStop := sStop
        tTarget := sTarget
        tBar := bar_index
        tStopBox := box.new(bar_index, math.max(sEntry, sStop), bar_index + i_extendBars, math.min(sEntry, sStop), bgcolor=color.new(i_bearCol, i_boxFill), border_color=color.new(i_bearCol, 35), border_width=1)
        tTargetBox := box.new(bar_index, math.max(sEntry, sTarget), bar_index + i_extendBars, math.min(sEntry, sTarget), bgcolor=color.new(i_bullCol, i_boxFill), border_color=color.new(i_bullCol, 35), border_width=1)
        array.push(tBoxes, tStopBox)
        array.push(tBoxes, tTargetBox)
        if i_showLabels
            string tip = (signal == 1 ? "BUY" : "SELL") + " · " + (hidden ? "hidden" : "regular") + (signal == 1 ? " bullish" : " bearish") + " divergence" + (i_reqStoch ? (signal == 1 ? ", Stochastic crossed up" : ", Stochastic crossed down") : "") + "\nRSI swing " + str.tostring(sPivRsi, "#.#") + " at close " + str.tostring(sPivPx, format.mintick) + "\nEntry " + str.tostring(sEntry, format.mintick) + "\nStop " + str.tostring(sStop, format.mintick) + (kind == 1 ? " (the nearest swing)" : " (the " + str.tostring(i_fallback) + "-candle extreme)") + "\nTarget " + str.tostring(sTarget, format.mintick) + " (" + str.tostring(i_rr, "#.#") + "R)"
            label sl = label.new(bar_index, signal == 1 ? low : high, signal == 1 ? "BUY" : "SELL", color=color.new(signal == 1 ? i_bullCol : i_bearCol, 0), textcolor=signal == 1 ? c_dark : c_white, style=signal == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=tip)
            array.push(tLabels, sl)
        if i_showSwing and not na(at)
            label sw = label.new(at, lvl, "", color=color.new(i_bearCol, 10), style=label.style_circle, size=size.tiny, tooltip="The swing used for the stop")
            array.push(tLabels, sw)
        f_trimDrawings()
    else
        skipped := true
        if i_showLabels
            label sk = label.new(bar_index, signal == 1 ? low : high, (signal == 1 ? "buy" : "sell") + " · not taken", color=color.new(signal == 1 ? i_bullCol : i_bearCol, 70), textcolor=color.new(c_white, 20), style=signal == 1 ? label.style_label_up : label.style_label_down, size=size.tiny, tooltip="A trade is still open (one trade at a time)")
            array.push(tLabels, sk)
            f_trimDrawings()

bool longSignal  = signal == 1 and not skipped
bool shortSignal = signal == -1 and not skipped

// ─── LOG STATISTICS ────────────────────────────────────────────────────────────
int   lN = array.size(ledgerR)
int   lWins = 0
int   lLosses = 0
float lTotal = 0.0
int   lBest = 0
int   lWorst = 0
int   runW = 0
int   runL = 0
if lN > 0
    for i = 0 to lN - 1
        float r = array.get(ledgerR, i)
        lTotal += r
        if r > 0
            lWins += 1
            runW += 1
            runL := 0
        else
            lLosses += 1
            runL += 1
            runW := 0
        lBest := math.max(lBest, runW)
        lWorst := math.max(lWorst, runL)
float lWinRate = lN > 0 ? 100.0 * lWins / lN : na
int   lDays = lN > 0 ? int((array.get(ledgerT, lN - 1) - array.get(ledgerT, 0)) / 86400000) + 1 : 0
ledgerWins := lWins
ledgerLosses := lLosses
ledgerTotalR := lTotal

// ─── LOG TABLE ─────────────────────────────────────────────────────────────────
f_pos(string _p) =>
    switch _p
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

if i_showTable and barstate.islast
    var table led = table.new(f_pos(i_tablePos), 2, 15, bgcolor=color.new(c_dark, 8), border_color=color.new(c_purple, 45), border_width=1, frame_color=color.new(c_purple, 15), frame_width=2)
    string ts  = i_tableSize == "Large" ? size.normal : i_tableSize == "Small" ? size.tiny : size.small
    string tsH = i_tableSize == "Large" ? size.large : i_tableSize == "Small" ? size.small : size.normal
    color lab = c_grey
    bool above = close > emaV
    table.cell(led, 0, 0, "RSI HIDDEN DIVERGENCE", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
    table.cell(led, 1, 0, "[fob]", text_color=color.new(c_white, 35), text_size=ts, text_halign=text.align_right, bgcolor=color.new(c_purple, 70))
    table.cell(led, 0, 1, "Last " + str.tostring(i_ledgerN) + " signals", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 1, str.tostring(lN), text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 2, "Wins", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 2, str.tostring(lWins), text_color=i_bullCol, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 3, "Losses", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 3, str.tostring(lLosses), text_color=i_bearCol, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 4, "Win rate", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 4, na(lWinRate) ? "-" : str.tostring(lWinRate, "#.#") + " %", text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 5, "Total R", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 5, (lTotal >= 0 ? "+" : "") + str.tostring(lTotal, "#.#") + "R", text_color=lTotal >= 0 ? i_bullCol : i_bearCol, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 6, "Best win streak", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 6, str.tostring(lBest), text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 7, "Worst loss streak", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 7, str.tostring(lWorst), text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 8, "Days covered", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 8, str.tostring(lDays), text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 9, "EMA " + str.tostring(i_emaLen), text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 9, not hidden ? "not used (regular)" : above ? "above · buys only" : "below · sells only", text_color=not hidden ? lab : above ? i_bullCol : i_bearCol, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 10, "RSI swing watched", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 10, hidden ? (above ? (na(lowRsi) ? "-" : "low " + str.tostring(lowRsi, "#.#")) : (na(highRsi) ? "-" : "high " + str.tostring(highRsi, "#.#"))) : "low " + str.tostring(lowRsi, "#.#") + " · high " + str.tostring(highRsi, "#.#"), text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 11, "Divergence", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 11, setDir == 1 ? "bullish · waiting for the cross" : setDir == -1 ? "bearish · waiting for the cross" : "none", text_color=setDir == 1 ? i_bullCol : setDir == -1 ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 12, "Stochastic", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 12, not i_reqStoch ? "not required" : kV > dV ? "%K above %D" : "%K below %D", text_color=not i_reqStoch ? lab : kV > dV ? i_bullCol : i_bearCol, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 13, "Type", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 13, hidden ? "hidden (continuation)" : "regular (reversal)", text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 14, "Open trade", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 14, tDir == 1 ? "BUY · stop " + str.tostring(tStop, format.mintick) + " · target " + str.tostring(tTarget, format.mintick) : tDir == -1 ? "SELL · stop " + str.tostring(tStop, format.mintick) + " · target " + str.tostring(tTarget, format.mintick) : "none", text_color=tDir == 1 ? i_bullCol : tDir == -1 ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)

// ─── CHART PLOTS ───────────────────────────────────────────────────────────────
plot(i_showEma ? emaV : na, "EMA", color=color.new(i_emaCol, 10), linewidth=2)

// ─── DATA-WINDOW PLOTS (read by tools, hidden on the chart) ────────────────────
plot(emaV, "ema", display=display.data_window)
plot(rsiV, "rsi", display=display.data_window)
plot(kV, "k", display=display.data_window)
plot(dV, "d", display=display.data_window)
plot(lowRsi, "lowRsi", display=display.data_window)
plot(lowPx, "lowPx", display=display.data_window)
plot(lowBar, "lowBar", display=display.data_window)
plot(highRsi, "highRsi", display=display.data_window)
plot(highPx, "highPx", display=display.data_window)
plot(highBar, "highBar", display=display.data_window)
plot(setupNew ? setDir : 0, "setupNew", display=display.data_window)
plot(setDir, "setDir", display=display.data_window)
plot(signal, "signal", display=display.data_window)
plot(skipped ? 1 : 0, "skipped", display=display.data_window)
plot(signal != 0 ? sEntry : na, "entry", display=display.data_window)
plot(signal != 0 ? sStop : na, "stop", display=display.data_window)
plot(signal != 0 ? sTarget : na, "target", display=display.data_window)
plot(signal != 0 ? sSwingKind : na, "swingKind", display=display.data_window)
plot(signal != 0 ? sSwingBar : na, "swingBar", display=display.data_window)
plot(signal != 0 ? sPivBar : na, "sigPivBar", display=display.data_window)
plot(signal != 0 ? sPivRsi : na, "sigPivRsi", display=display.data_window)
plot(signal != 0 ? sPivPx : na, "sigPivPx", display=display.data_window)
plot(signal != 0 ? sSetBar : na, "sigSetBar", display=display.data_window)
plot(resultR, "result", display=display.data_window)
plot(exitLevel, "exitLevel", display=display.data_window)
plot(tDir, "openDir", display=display.data_window)
plot(lN, "ledgerN", display=display.data_window)
plot(ledgerWins, "ledgerWins", display=display.data_window)
plot(ledgerLosses, "ledgerLosses", display=display.data_window)
plot(ledgerTotalR, "ledgerTotalR", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
if i_alertJson and longSignal
    alert('{"action":"BUY","indicator":"RHD","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"stop":' + str.tostring(sStop) + ',"target":' + str.tostring(sTarget) + '}', alert.freq_once_per_bar_close)
if i_alertJson and shortSignal
    alert('{"action":"SELL","indicator":"RHD","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"stop":' + str.tostring(sStop) + ',"target":' + str.tostring(sTarget) + '}', alert.freq_once_per_bar_close)

alertcondition(longSignal,                "RHD Buy entry",  "RSI Hidden Divergence: BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(shortSignal,               "RHD Sell entry", "RSI Hidden Divergence: SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(longSignal or shortSignal, "RHD Any entry",  "RSI Hidden Divergence: entry on {{ticker}} {{interval}} at {{close}}")
````
