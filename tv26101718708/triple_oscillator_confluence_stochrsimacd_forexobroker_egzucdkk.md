# Triple Oscillator Confluence: Stoch/RSI/MACD [forexobroker]

- url: https://www.tradingview.com/script/eGzucdKK-Triple-Oscillator-Confluence-Stoch-RSI-MACD-forexobroker/
- type: indicator
- pine_id: PUB;41d2cb18450b4918a4661d7a84d10d8f
- version: 1.0

## Description

Triple Oscillator Confluence: Stoch/RSI/MACD [forexobroker]

🔶 OVERVIEW

Triple Oscillator Confluence puts three of the most popular oscillators into one rule set: the Stochastic finds the setup, the RSI decides which side you may trade, and the MACD confirms the momentum. Every entry is drawn with its stop and its target, every trade is followed to its result, and the last 100 results are counted in a table on the chart.

It is built for traders who want to see, on their own symbol and timeframe, what the three-oscillator combination really did over the last 100 trades, wins and losses alike, before they trust it. Two switches turn the Stochastic and the RSI conditions off, so the plain MACD cross can be measured against the full rule set on the same chart.

🔶 HOW IT WORKS

1. The setup (Stochastic 14, 1, 3, TradingView's defaults). Both %K and %D close below 20: the market is armed long. Both close above 80: armed short. A small dot marks the candle on which the setup starts.

2. The trend filter (RSI 14). The RSI is used as a trend filter, not as overbought / oversold: above 50 longs only, below 50 shorts only.

3. The trigger (MACD 12, 26, 9). The MACD line crosses above its signal line for a long, below it for a short.

A LONG signal prints on the closed candle on which the MACD line crosses up while the market is armed long and the RSI is above 50. A long setup is cancelled as soon as either Stochastic line closes above 80, so an entry never comes after the move it was waiting for. SHORT is the mirror. One signal per setup: the arming clears at the signal.

🔶 TRADE MANAGEMENT

Entry at the close of the signal candle. Stop beyond the nearest swing: the most recent swing low below the entry (a low with two higher lows on each side) within the last 30 candles, or, when none qualifies, the lowest low of the last 10 candles. Shorts use the swing highs. The swing used is marked with a small red dot. Target at a fixed reward multiple of the stop distance, 1.5R by default. The trade is drawn as a red box from the entry to the stop and a green box from the entry to the target, from the signal candle to the candle that resolves it, with a "+1.5R" or "-1R" label at the end.

Optional stop limit: when the swing is far away the risk is large. "Max stop, % of price" caps the stop distance at a percentage of the entry price (0 = off, the default). A capped entry is labelled "stop capped".

🔶 THE LOG

One trade at a time. A valid entry that appears while a trade is still open is drawn faded and is not counted (switch "Allow overlapping trades" on to count every entry). Every open trade is followed on closed candles to its stop or its target. When one candle touches both, the stop is counted first: that is the conservative reading of an ambiguous candle.

The last N results (100 by default) feed the table: signals, wins, losses, win rate, total R, best win streak, worst loss streak and days covered, followed by the live state of the three conditions, the stop limit and the open trade.

NON-REPAINTING: every condition, every signal and every result is evaluated on barstate.isconfirmed; the swing used for a stop is a pivot confirmed on an earlier candle; there is no request.security and no lookahead.

🔶 SETTINGS

Oscillators
- Stochastic %K length, %K smoothing, %D smoothing (14, 1, 3); oversold and overbought levels (20, 80).
- RSI length (14) and the RSI trend level (50).
- MACD fast, slow and signal lengths (12, 26, 9).

Setup
- Require the stochastic setup (default on), Require the RSI side (default on). Both off = the plain MACD cross.
- Allow overlapping trades (default off): one trade at a time.
- Take longs, Take shorts.

Trade
- Swing strength (2 candles each side), Swing search (30 candles back), Fallback lookback (10 candles).
- Reward ratio (default 1.5): target = stop distance × this.
- Max stop, % of price (default 0 = off).
- Extend open trade boxes (bars).

Log
- Log size (default 100), Show log table, Table position, Table text size.

Visual
- Long and short colours, setup marker colour, mark the setup candle, mark the swing used for the stop, BUY / SELL labels, +R / -R result labels, trades kept on chart, box fill transparency.

Alerts
- Send JSON alert() messages.

🔶 ALERTS

Three alertcondition hooks: TOC Long entry, TOC Short entry, TOC Any entry. With "Send JSON alert() messages" on, every taken entry also fires an alert() once per bar close with a JSON body (action, ticker, timeframe, entry, stop, target, capped).

🔶 LIMITATIONS

- All three are momentum tools. In a sideways market the Stochastic swings between its levels and the MACD crosses often; the log's worst loss streak shows how long a bad stretch has lasted on your symbol.
- With a 1.5R target the strategy needs to win more than four trades in ten. Check the win rate in the table before anything else.
- Results in the log are the script's own rules applied to closed candles: no spread, no commission, no slippage, and the stop is counted before the target on a candle that touches both.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Triple Oscillator Confluence — Stochastic, RSI and MACD in one rule set, with its own trade log.
// (1) The setup (Stochastic): both %K and %D close below the oversold level: the market is armed long. Both close
//     above the overbought level: armed short. A long setup is cancelled as soon as either line closes above the
//     overbought level (a short setup: below oversold), so an entry never comes after the move it was waiting for.
// (2) The trend filter (RSI): the RSI above 50 allows longs only, below 50 shorts only.
// (3) The trigger (MACD): the MACD line crosses above its signal line (long) or below it (short).
// A LONG signal prints on the closed candle on which the MACD line crosses up while the market is armed long and the
// RSI is above 50. SHORT is the mirror. One signal per setup: the arming clears at the signal.
// The stop sits beyond the nearest swing (the most recent pivot low below the entry, else the lowest low of the last
// few candles), optionally capped at a percentage of price; the target is a fixed reward multiple of the stop
// distance (1.5R by default). One trade at a time; every trade is followed to its stop or target on closed candles,
// stop first when a candle touches both, and the last N results feed the on-chart log.
// Non-repainting: every condition and every trade result is evaluated on barstate.isconfirmed, there is no
// request.security and no lookahead; the swing used for a stop is a pivot already confirmed on an earlier candle.
indicator("Triple Oscillator Confluence: Stoch/RSI/MACD [forexobroker]", shorttitle="TOC [fob]", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_osc    = "Oscillators"
string g_setup  = "Setup"
string g_trade  = "Trade"
string g_ledger = "Log"
string g_vis    = "Visual"
string g_alert  = "Alerts"

// ─── INPUTS: OSCILLATORS ───────────────────────────────────────────────────────
int   i_kLen    = input.int(14, "Stochastic %K length", minval=2, maxval=200, group=g_osc)
int   i_kSmooth = input.int(1, "Stochastic %K smoothing", minval=1, maxval=20, group=g_osc)
int   i_dSmooth = input.int(3, "Stochastic %D smoothing", minval=1, maxval=20, group=g_osc, tooltip="14, 1, 3 are TradingView's default Stochastic settings, so the built-in Stochastic pane shows the same two lines.")
float i_os      = input.float(20, "Oversold level", minval=1, maxval=49, group=g_osc)
float i_ob      = input.float(80, "Overbought level", minval=51, maxval=99, group=g_osc)
int   i_rsiLen  = input.int(14, "RSI length", minval=2, maxval=200, group=g_osc)
float i_rsiMid  = input.float(50, "RSI trend level", minval=1, maxval=99, group=g_osc, tooltip="The RSI is used as a trend filter, not as overbought / oversold: above this level longs only, below it shorts only.")
int   i_fast    = input.int(12, "MACD fast length", minval=2, maxval=200, group=g_osc)
int   i_slow    = input.int(26, "MACD slow length", minval=3, maxval=400, group=g_osc)
int   i_sigLen  = input.int(9, "MACD signal length", minval=2, maxval=100, group=g_osc, tooltip="TradingView's default MACD settings.")

// ─── INPUTS: SETUP ─────────────────────────────────────────────────────────────
bool i_reqStoch = input.bool(true, "Require the stochastic setup", group=g_setup, tooltip="ON (default): a long needs the oversold setup described above (a short: the overbought setup). OFF: the stochastic is ignored. Switch both 'Require' settings off to test the plain MACD cross on its own; the log counts only the entries the settings let through.")
bool i_reqRsi   = input.bool(true, "Require the RSI side", group=g_setup, tooltip="ON (default): a long needs the RSI above the trend level, a short below it. OFF: the RSI is ignored.")
bool i_allowOverlap = input.bool(false, "Allow overlapping trades", group=g_setup, tooltip="OFF (default): one trade at a time. A valid entry that appears while a trade is still open is drawn faded and is not counted in the log. ON: every valid entry opens its own trade.")
bool i_longs  = input.bool(true, "Take longs", group=g_setup)
bool i_shorts = input.bool(true, "Take shorts", group=g_setup)

// ─── INPUTS: TRADE ─────────────────────────────────────────────────────────────
int   i_swStr      = input.int(2, "Swing strength (candles each side)", minval=1, maxval=10, group=g_trade, tooltip="A swing low is a low with this many higher lows on each side.")
int   i_swSearch   = input.int(30, "Swing search (candles back)", minval=5, maxval=200, group=g_trade, tooltip="The stop uses the most recent swing low below the entry (swing high above it, for shorts) within this many candles.")
int   i_fallback   = input.int(10, "Fallback lookback (candles)", minval=2, maxval=100, group=g_trade, tooltip="When no swing qualifies, the stop goes at the lowest low (highest high) of this many candles.")
float i_rr         = input.float(1.5, "Reward ratio (target = stop × this)", minval=0.5, maxval=10.0, step=0.5, group=g_trade, tooltip="1.5 = the target sits one and a half times the stop distance away. A win adds this many R to the log, a loss subtracts 1R.")
float i_maxStopPct = input.float(0.0, "Max stop, % of price (0 = off)", minval=0.0, maxval=10.0, step=0.05, group=g_trade, tooltip="When the swing is far away the risk is large. If the stop distance exceeds this percentage of the entry price, the stop is capped at that distance and the label says 'capped'. 0 (default) keeps the swing as the stop in every case.")
int   i_extendBars = input.int(30, "Extend open trade boxes (bars)", minval=5, maxval=200, group=g_trade)

// ─── INPUTS: LOG ───────────────────────────────────────────────────────────────
int    i_ledgerN   = input.int(100, "Log size (last N signals)", minval=10, maxval=500, group=g_ledger, tooltip="The rolling number of completed trades the table summarises. The '100 trades' test of the video is this table at 100.")
bool   i_showTable = input.bool(true, "Show log table", group=g_ledger)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_ledger)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_ledger)

// ─── INPUTS: VISUAL ────────────────────────────────────────────────────────────
color i_bullCol    = input.color(#00E5A8, "Long colour", group=g_vis)
color i_bearCol    = input.color(#FF3B5C, "Short colour", group=g_vis)
color i_armCol     = input.color(#F5C542, "Setup marker colour", group=g_vis)
bool  i_showArm    = input.bool(true, "Mark the stochastic setup candle", group=g_vis, tooltip="A small dot under the candle on which both stochastic lines became oversold (over it: overbought).")
bool  i_showSwing  = input.bool(true, "Mark the swing used for the stop", group=g_vis)
bool  i_showLabels = input.bool(true, "Show BUY / SELL labels", group=g_vis)
bool  i_showResult = input.bool(true, "Show +R / -R result labels", group=g_vis)
int   i_keepTrades = input.int(120, "Trades kept on chart", minval=1, maxval=200, group=g_vis, tooltip="How many past trades keep their boxes and labels before the oldest are removed.")
int   i_boxFill    = input.int(78, "Box fill transparency", minval=50, maxval=95, group=g_vis)

// ─── INPUTS: ALERTS ────────────────────────────────────────────────────────────
bool i_alertJson = input.bool(true, "Send JSON alert() messages", group=g_alert, tooltip="Besides the alertcondition hooks, fire an alert() with a JSON body on every signal (once per bar close). Useful for webhooks.")

color c_white  = #FFFFFF
color c_dark   = #0B0F14
color c_purple = #A259FF
color c_grey   = #9AA4AE

// ─── OSCILLATORS ───────────────────────────────────────────────────────────────
bool  confirmed = barstate.isconfirmed
float kV   = ta.sma(ta.stoch(close, high, low, i_kLen), i_kSmooth)
float dV   = ta.sma(kV, i_dSmooth)
float rsiV = ta.rsi(close, i_rsiLen)
[macdV, sigV, histV] = ta.macd(close, i_fast, i_slow, i_sigLen)
bool  ready = not na(kV) and not na(dV) and not na(rsiV) and not na(sigV) and not na(macdV[1]) and not na(sigV[1])

bool crossUp = ready and macdV > sigV and macdV[1] <= sigV[1]
bool crossDn = ready and macdV < sigV and macdV[1] >= sigV[1]
bool rsiUp   = rsiV > i_rsiMid
bool rsiDn   = rsiV < i_rsiMid

// ─── SWINGS (confirmed pivots, kept with the bar they formed on) ───────────────
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

// ─── STOCHASTIC SETUP STATE ────────────────────────────────────────────────────
var int armed = 0               // 1 armed long (oversold seen, no overbought since), -1 armed short, 0 none
var int armedBar = na
bool armMarkL = false
bool armMarkS = false
if confirmed and ready
    if kV < i_os and dV < i_os
        if armed != 1
            armMarkL := true
            armedBar := bar_index
        armed := 1
    else if kV > i_ob and dV > i_ob
        if armed != -1
            armMarkS := true
            armedBar := bar_index
        armed := -1
    else if armed == 1 and (kV > i_ob or dV > i_ob)
        armed := 0
    else if armed == -1 and (kV < i_os or dV < i_os)
        armed := 0

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
bool  sCapped = false
int   sSwingKind = 0
int   sSwingBar = na

if confirmed and ready
    bool okL = i_longs and crossUp and (not i_reqStoch or armed == 1) and (not i_reqRsi or rsiUp)
    bool okS = i_shorts and crossDn and (not i_reqStoch or armed == -1) and (not i_reqRsi or rsiDn)
    if okL
        signal := 1
    else if okS
        signal := -1
    if signal != 0 and i_reqStoch
        armed := 0                 // one signal per setup

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
    float capDist = i_maxStopPct > 0 ? close * i_maxStopPct / 100.0 : na
    if not na(capDist) and dist > capDist
        dist := capDist
        sCapped := true
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
            string cap = sCapped ? "  · stop capped" : ""
            string tip = (signal == 1 ? "LONG" : "SHORT") + " · MACD cross" + (i_reqStoch ? (signal == 1 ? " after an oversold stochastic" : " after an overbought stochastic") : "") + (i_reqRsi ? (signal == 1 ? ", RSI above " : ", RSI below ") + str.tostring(i_rsiMid, "#") : "") + "\nEntry " + str.tostring(sEntry, format.mintick) + "\nStop " + str.tostring(sStop, format.mintick) + (sCapped ? " (capped at " + str.tostring(i_maxStopPct, "#.##") + " %)" : kind == 1 ? " (the nearest swing)" : " (the " + str.tostring(i_fallback) + "-candle extreme)") + "\nTarget " + str.tostring(sTarget, format.mintick) + " (" + str.tostring(i_rr, "#.#") + "R)"
            label sl = label.new(bar_index, signal == 1 ? low : high, (signal == 1 ? "BUY" : "SELL") + cap, color=color.new(signal == 1 ? i_bullCol : i_bearCol, 0), textcolor=signal == 1 ? c_dark : c_white, style=signal == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=tip)
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
    var table led = table.new(f_pos(i_tablePos), 2, 14, bgcolor=color.new(c_dark, 8), border_color=color.new(c_purple, 45), border_width=1, frame_color=color.new(c_purple, 15), frame_width=2)
    string ts  = i_tableSize == "Large" ? size.normal : i_tableSize == "Small" ? size.tiny : size.small
    string tsH = i_tableSize == "Large" ? size.large : i_tableSize == "Small" ? size.small : size.normal
    color lab = c_grey
    table.cell(led, 0, 0, "TRIPLE OSCILLATOR CONFLUENCE", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
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
    table.cell(led, 0, 9, "Stochastic", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 9, not i_reqStoch ? "not required" : armed == 1 ? "oversold seen · armed long" : armed == -1 ? "overbought seen · armed short" : "waiting for a setup", text_color=armed == 1 and i_reqStoch ? i_bullCol : armed == -1 and i_reqStoch ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 10, "RSI vs " + str.tostring(i_rsiMid, "#"), text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 10, not i_reqRsi ? "not required" : rsiUp ? "above · longs" : rsiDn ? "below · shorts" : "-", text_color=rsiUp and i_reqRsi ? i_bullCol : rsiDn and i_reqRsi ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 11, "MACD line", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 11, macdV > sigV ? "above its signal line" : "below its signal line", text_color=macdV > sigV ? i_bullCol : i_bearCol, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 12, "Max stop", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 12, i_maxStopPct > 0 ? str.tostring(i_maxStopPct, "#.##") + " % of price" : "off · the swing", text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 13, "Open trade", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 13, tDir == 1 ? "LONG · stop " + str.tostring(tStop, format.mintick) + " · target " + str.tostring(tTarget, format.mintick) : tDir == -1 ? "SHORT · stop " + str.tostring(tStop, format.mintick) + " · target " + str.tostring(tTarget, format.mintick) : "none", text_color=tDir == 1 ? i_bullCol : tDir == -1 ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)

// ─── CHART PLOTS ───────────────────────────────────────────────────────────────
plotshape(i_showArm and i_reqStoch and armMarkL, "Stochastic oversold setup", style=shape.circle, location=location.belowbar, color=color.new(i_armCol, 0), size=size.tiny)
plotshape(i_showArm and i_reqStoch and armMarkS, "Stochastic overbought setup", style=shape.circle, location=location.abovebar, color=color.new(i_armCol, 0), size=size.tiny)

// ─── DATA-WINDOW PLOTS (read by tools, hidden on the chart) ────────────────────
plot(kV, "k", display=display.data_window)
plot(dV, "d", display=display.data_window)
plot(rsiV, "rsi", display=display.data_window)
plot(macdV, "macd", display=display.data_window)
plot(sigV, "macdSignal", display=display.data_window)
plot(armed, "armed", display=display.data_window)
plot(armMarkL ? 1 : armMarkS ? -1 : 0, "armMark", display=display.data_window)
plot(signal, "signal", display=display.data_window)
plot(skipped ? 1 : 0, "skipped", display=display.data_window)
plot(signal != 0 ? sEntry : na, "entry", display=display.data_window)
plot(signal != 0 ? sStop : na, "stop", display=display.data_window)
plot(signal != 0 ? sTarget : na, "target", display=display.data_window)
plot(signal != 0 and sCapped ? 1 : 0, "stopCapped", display=display.data_window)
plot(signal != 0 ? sSwingKind : na, "swingKind", display=display.data_window)
plot(signal != 0 ? sSwingBar : na, "swingBar", display=display.data_window)
plot(resultR, "result", display=display.data_window)
plot(exitLevel, "exitLevel", display=display.data_window)
plot(tDir, "openDir", display=display.data_window)
plot(lN, "ledgerN", display=display.data_window)
plot(ledgerWins, "ledgerWins", display=display.data_window)
plot(ledgerLosses, "ledgerLosses", display=display.data_window)
plot(ledgerTotalR, "ledgerTotalR", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
if i_alertJson and longSignal
    alert('{"action":"LONG","indicator":"TOC","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"stop":' + str.tostring(sStop) + ',"target":' + str.tostring(sTarget) + ',"capped":' + (sCapped ? "true" : "false") + '}', alert.freq_once_per_bar_close)
if i_alertJson and shortSignal
    alert('{"action":"SHORT","indicator":"TOC","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"stop":' + str.tostring(sStop) + ',"target":' + str.tostring(sTarget) + ',"capped":' + (sCapped ? "true" : "false") + '}', alert.freq_once_per_bar_close)

alertcondition(longSignal,                "TOC Long entry",  "Triple Oscillator Confluence: LONG on {{ticker}} {{interval}} at {{close}}")
alertcondition(shortSignal,               "TOC Short entry", "Triple Oscillator Confluence: SHORT on {{ticker}} {{interval}} at {{close}}")
alertcondition(longSignal or shortSignal, "TOC Any entry",   "Triple Oscillator Confluence: entry on {{ticker}} {{interval}} at {{close}}")
````
