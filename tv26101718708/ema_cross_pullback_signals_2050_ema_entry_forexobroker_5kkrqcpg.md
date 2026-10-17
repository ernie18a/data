# EMA Cross Pullback Signals: 20/50 EMA Entry [forexobroker]

- url: https://www.tradingview.com/script/5kKrqCPg-EMA-Cross-Pullback-Signals-20-50-EMA-Entry-forexobroker/
- type: indicator
- pine_id: PUB;9c7142db75744d5f9492149aec54cdae
- version: 1.0

## Description

EMA Cross Pullback Signals: 20/50 EMA Entry [forexobroker]

🔶 OVERVIEW

EMA Cross Pullback Signals trades the most famous moving-average signal, the 20/50 EMA crossover, the way it should be traded: not at the cross, but on the first pullback after it. Every entry is drawn with its stop and its target, every trade is followed to its result, and the last 100 results are counted in a table on the chart.

It is built for traders who want to see, on their own symbol and timeframe, what the crossover really did over the last 100 trades, wins and losses alike, before they trust it. Two popular additions, the 200 EMA trend filter and an ATR trailing exit, are inputs, so each one can be switched on and measured against the plain rules.

🔶 HOW IT WORKS

1. The cross. The fast EMA (20) closes above the slow EMA (50): the market is armed long. Below: armed short. Only these two lines form the cross; the 200 EMA never takes part in it.

2. The pullback. After the cross, the first candle whose low touches or crosses the fast EMA (armed long) is the pullback candle; it is marked with a small dot. The lowest low from that candle onwards is tracked. Short is the mirror: the first candle whose high touches the fast EMA, and the highest high from there.

3. The entry. The first candle AFTER the pullback candle that closes back above the fast EMA (below it for shorts) is the entry, at its close. A BUY or SELL label prints on that candle.

4. The trend filter (on by default). A long needs the entry candle to close above the 200 EMA, a short below it. Switch it off to take every first-pullback entry; the log then counts those, so the two variants can be compared on any chart.

One trade per cross: the first pullback is the only candidate. A cross that reverses before the entry resets the state. A pullback that never comes means no trade.

🔶 TRADE MANAGEMENT

Entry at the close of the confirming candle. Stop at the lowest low (highest high) of the pullback. Target at a fixed reward multiple of the stop distance, 2R by default. The trade is drawn as a red box from the entry to the stop and a green box from the entry to the target, from the entry candle to the candle that resolves it, with a "+2R" or "-1R" label at the end.

Optional exit: "ATR trailing stop". The initial stop is the same pullback low; from the next candle on, a trailing stop at close minus ATR × multiplier (plus for shorts) follows the trade and never moves back, drawn as a dashed line. The trade ends when a candle touches it, and the result is measured in R of the initial risk, so wins and losses still count the same way in the log.

🔶 THE LOG

One trade at a time. A valid entry that appears while a trade is still open is drawn faded and is not counted (switch "Allow overlapping trades" on to count every entry). Every open trade is followed on closed candles to its stop or its target. When one candle touches both, the stop is counted first: that is the conservative reading of an ambiguous candle.

The last N results (100 by default) feed the table: signals, wins, losses, win rate, total R, best win streak, worst loss streak and days covered, followed by the live state: which way the last cross armed the market, whether the first pullback has printed, which side of the 200 EMA price is on, the exit type and the open trade.

NON-REPAINTING: every condition, every signal and every result is evaluated on barstate.isconfirmed; there is no request.security and no lookahead.

🔶 SETTINGS

Moving averages
- Fast EMA length (20), Slow EMA length (50), Trend EMA length (200).
- 200 EMA filter (default on).

Setup
- Allow overlapping trades (default off): one trade at a time.
- Take longs, Take shorts.

Trade
- Exit (default Fixed target): Fixed target, or ATR trailing stop.
- Reward ratio (default 2.0): target = stop distance × this.
- ATR length (14) and ATR multiplier (3.0) for the trailing stop.
- Extend open trade boxes (bars).

Log
- Log size (default 100), Show log table, Table position, Table text size.

Visual
- Long and short colours, the three EMA colours, show the EMAs, mark the pullback candle, tint the background by the 200 EMA, BUY / SELL labels, +R / -R result labels, trades kept on chart, box fill transparency.

Alerts
- Send JSON alert() messages.

🔶 ALERTS

Three alertcondition hooks: ECPS Long entry, ECPS Short entry, ECPS Any entry. With "Send JSON alert() messages" on, every taken entry also fires an alert() once per bar close with a JSON body (action, ticker, timeframe, entry, stop, target, exit type).

🔶 LIMITATIONS

- A crossover is a trend tool. In a sideways market the lines cross again and again; the first-pullback rule skips the whipsaws that reverse before a pullback, but not the ones that pull back first. The log's worst loss streak shows how long a bad stretch has lasted on your symbol.
- With a two-to-one target the strategy needs to win more than one trade in three. Check the win rate in the table before anything else.
- Results in the log are the script's own rules applied to closed candles: no spread, no commission, no slippage, and the stop is counted before the target on a candle that touches both. The trailing exit is filled at the trail level.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: EMA Cross Pullback Signals — the 20/50 EMA crossover traded on its first pullback, with
// its own trade log.
// (1) The cross: the fast EMA (20) closes above the slow EMA (50): the market is armed long. Below:
//     armed short. Only two moving averages take part in the cross.
// (2) The pullback: after the cross, the first candle whose low touches or crosses the fast EMA
//     (armed long) is the pullback candle. The lowest low from that candle onwards is tracked.
// (3) The entry: the first candle AFTER the pullback candle that closes back above the fast EMA.
//     Entry at its close, stop at the lowest low of the pullback, target at a fixed reward multiple
//     of the stop distance (2R by default) or, optionally, an ATR trailing stop.
// (4) The trend filter (optional, on by default): a long needs the entry close above the 200 EMA,
//     a short below it. Short is the mirror of everything above.
// One trade per cross: the first pullback is the only candidate; a cross that reverses before the
// entry resets the state; a pullback that never comes means no trade. One trade at a time; every
// trade is followed to its stop or target on closed candles, stop first when a candle touches both,
// and the last N results feed the on-chart log (wins, losses, win rate, total R, streaks, days covered).
// Non-repainting: every condition and every trade result is evaluated on barstate.isconfirmed,
// there is no request.security and no lookahead.
indicator("EMA Cross Pullback Signals: 20/50 EMA Entry [forexobroker]", shorttitle="ECPS [fob]", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_ind    = "Moving averages"
string g_setup  = "Setup"
string g_trade  = "Trade"
string g_ledger = "Log"
string g_vis    = "Visual"
string g_alert  = "Alerts"

// ─── INPUTS: MOVING AVERAGES ───────────────────────────────────────────────────
int  i_fastLen  = input.int(20, "Fast EMA length", minval=2, maxval=400, group=g_ind, tooltip="The fast line of the crossover. The pullback is measured against this line.")
int  i_slowLen  = input.int(50, "Slow EMA length", minval=3, maxval=800, group=g_ind, tooltip="The slow line of the crossover. Only these two lines form the cross.")
int  i_trendLen = input.int(200, "Trend EMA length", minval=10, maxval=1000, group=g_ind, tooltip="The separate trend filter. It is never part of the cross.")
bool i_useTrend = input.bool(true, "200 EMA filter", group=g_ind, tooltip="ON (default): a long is taken only when the entry candle closes above the trend EMA, a short only below it. OFF: every first-pullback entry is taken. The log counts only the entries the setting lets through, so both variants can be compared on any chart.")

// ─── INPUTS: SETUP ─────────────────────────────────────────────────────────────
bool i_allowOverlap = input.bool(false, "Allow overlapping trades", group=g_setup, tooltip="OFF (default): one trade at a time. A valid entry that appears while a trade is still open is drawn faded and is not counted in the log. ON: every valid entry opens its own trade.")
bool i_longs  = input.bool(true, "Take longs", group=g_setup)
bool i_shorts = input.bool(true, "Take shorts", group=g_setup)

// ─── INPUTS: TRADE ─────────────────────────────────────────────────────────────
string i_exitMode = input.string("Fixed target", "Exit", options=["Fixed target", "ATR trailing stop"], group=g_trade, tooltip="Fixed target (default): the trade ends at the stop or at the target, target = stop distance × the reward ratio. ATR trailing stop: the initial stop is the same pullback low; from the next candle on, a trailing stop at close minus ATR × multiplier (plus for shorts) follows the trade and never moves back; the trade ends when a candle touches it. The result is then measured in R of the initial risk, so wins and losses still count the same way in the log.")
float i_rr      = input.float(2.0, "Reward ratio (target = stop × this)", minval=0.5, maxval=10.0, step=0.5, group=g_trade, tooltip="Fixed target only. 2 = a two-to-one target. A win adds this many R to the log, a loss subtracts 1R.")
int   i_atrLen  = input.int(14, "ATR length", minval=2, maxval=200, group=g_trade)
float i_atrMult = input.float(3.0, "ATR multiplier", minval=0.5, maxval=10.0, step=0.5, group=g_trade, tooltip="ATR trailing stop only: the trailing distance is ATR × this.")
int   i_extendBars = input.int(30, "Extend open trade boxes (bars)", minval=5, maxval=200, group=g_trade)

// ─── INPUTS: LOG ───────────────────────────────────────────────────────────────
int    i_ledgerN   = input.int(100, "Log size (last N signals)", minval=10, maxval=500, group=g_ledger, tooltip="The rolling number of completed trades the table summarises. The '100 trades' test of the video is this table at 100.")
bool   i_showTable = input.bool(true, "Show log table", group=g_ledger)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_ledger)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_ledger)

// ─── INPUTS: VISUAL ────────────────────────────────────────────────────────────
color i_bullCol    = input.color(#00E5A8, "Long colour", group=g_vis)
color i_bearCol    = input.color(#FF3B5C, "Short colour", group=g_vis)
color i_fastCol    = input.color(#F5C542, "Fast EMA colour", group=g_vis)
color i_slowCol    = input.color(#FF8A3D, "Slow EMA colour", group=g_vis)
color i_trendCol   = input.color(#4DA3FF, "Trend EMA colour", group=g_vis)
bool  i_showMAs    = input.bool(true, "Show the three EMAs", group=g_vis)
bool  i_showPull   = input.bool(true, "Mark the pullback candle", group=g_vis, tooltip="A small circle under (over) the first candle that touched the fast EMA after the cross.")
bool  i_showTint   = input.bool(true, "Tint the background by the 200 EMA", group=g_vis, tooltip="A faint green tint while the close is above the trend EMA, a faint red tint while it is below. Drawn even when the filter is off, so you can see what it would have done.")
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

// ─── INDICATORS ────────────────────────────────────────────────────────────────
bool  confirmed = barstate.isconfirmed
bool  trailMode = i_exitMode == "ATR trailing stop"
float emaF = ta.ema(close, i_fastLen)
float emaS = ta.ema(close, i_slowLen)
float emaT = ta.ema(close, i_trendLen)
float atrV = ta.atr(i_atrLen)
bool  ready = not na(emaF) and not na(emaS) and not na(emaT) and not na(atrV) and not na(emaF[1]) and not na(emaS[1])

bool crossUp = ready and emaF > emaS and emaF[1] <= emaS[1]
bool crossDn = ready and emaF < emaS and emaF[1] >= emaS[1]
bool trendUp = close > emaT
bool trendDn = close < emaT

// ─── CROSS STATE ───────────────────────────────────────────────────────────────
var int   armed = 0             // 1 after a cross up, -1 after a cross down, 0 before the first cross
var int   armedBar = na
var bool  pbSeen = false        // the pullback candle has printed for this cross
var int   pbBar = na
var float pbExtreme = na        // the lowest low (highest high) from the pullback candle onwards
var bool  crossDone = false     // this cross has had its one entry (taken or passed on)

// ─── OPEN TRADE AND LOG STATE ──────────────────────────────────────────────────
var int   tDir = 0            // 1 long, -1 short, 0 flat
var float tEntry = na
var float tStop = na
var float tTarget = na
var float tRisk = na
var float tTrail = na
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
        while array.size(tLabels) > i_keepTrades * 2
            label.delete(array.shift(tLabels))

// Result of the open trade on this confirmed bar. Fixed target: the stop is checked BEFORE the target,
// so a candle that touches both books the loss. Trailing: the bar is tested against the trail set by
// the previous bar; only then does the trail move.
float resultR = na
float exitLevel = na
if confirmed and tDir != 0 and bar_index > tBar
    if not trailMode
        bool stopHit = tDir == 1 ? low <= tStop : high >= tStop
        bool targetHit = tDir == 1 ? high >= tTarget : low <= tTarget
        if stopHit
            resultR := -1.0
            exitLevel := tStop
        else if targetHit
            resultR := i_rr
            exitLevel := tTarget
    else
        bool trailHit = tDir == 1 ? low <= tTrail : high >= tTrail
        if trailHit
            resultR := tDir == 1 ? (tTrail - tEntry) / tRisk : (tEntry - tTrail) / tRisk
            exitLevel := tTrail
        else
            float cand = tDir == 1 ? close - atrV * i_atrMult : close + atrV * i_atrMult
            tTrail := tDir == 1 ? math.max(tTrail, cand) : math.min(tTrail, cand)
    if not na(resultR)
        f_pushResult(resultR, time)
        if not na(tStopBox)
            box.set_right(tStopBox, bar_index)
        if not na(tTargetBox)
            box.set_right(tTargetBox, bar_index)
        if i_showResult
            bool win = resultR > 0
            string txt = (resultR > 0 ? "+" : "") + (trailMode ? str.tostring(resultR, "#.##") : str.tostring(resultR, "#.#")) + "R"
            label rl = label.new(bar_index, exitLevel, txt, color=color.new(win ? i_bullCol : i_bearCol, 0), textcolor=win ? c_dark : c_white, style=tDir == 1 ? (win ? label.style_label_down : label.style_label_up) : (win ? label.style_label_up : label.style_label_down), size=size.small)
            array.push(tLabels, rl)
        tDir := 0
        tEntry := na
        tStop := na
        tTarget := na
        tRisk := na
        tTrail := na
        tBar := na
        tStopBox := na
        tTargetBox := na
        f_trimDrawings()

// Keep the open trade's boxes growing while it is open.
if tDir != 0 and not na(tStopBox)
    box.set_right(tStopBox, bar_index + i_extendBars)
if tDir != 0 and not na(tTargetBox)
    box.set_right(tTargetBox, bar_index + i_extendBars)

// ─── THE SIGNAL ────────────────────────────────────────────────────────────────
int   signal = 0            // +1 long, -1 short on the entry bar
bool  skipped = false       // a valid entry not taken (a trade is open)
bool  pbMarkL = false       // the pullback candle (long side) printed on this bar
bool  pbMarkS = false
bool  filtered = false      // a first-pullback entry refused by the 200 EMA filter
float sEntry = na
float sStop = na
float sTarget = na

if confirmed and ready
    // a new cross resets the state; the cross candle itself is never the pullback
    if crossUp
        armed := 1
        armedBar := bar_index
        pbSeen := false
        pbBar := na
        pbExtreme := na
        crossDone := false
    else if crossDn
        armed := -1
        armedBar := bar_index
        pbSeen := false
        pbBar := na
        pbExtreme := na
        crossDone := false
    else if armed == 1 and not crossDone and bar_index > armedBar
        if low <= emaF and not pbSeen
            pbSeen := true
            pbBar := bar_index
            pbExtreme := low
            pbMarkL := true
        else if pbSeen
            pbExtreme := math.min(pbExtreme, low)
        if pbSeen and bar_index > pbBar and close > emaF
            crossDone := true
            if i_useTrend and not trendUp
                filtered := true
            else if i_longs
                signal := 1
    else if armed == -1 and not crossDone and bar_index > armedBar
        if high >= emaF and not pbSeen
            pbSeen := true
            pbBar := bar_index
            pbExtreme := high
            pbMarkS := true
        else if pbSeen
            pbExtreme := math.max(pbExtreme, high)
        if pbSeen and bar_index > pbBar and close < emaF
            crossDone := true
            if i_useTrend and not trendDn
                filtered := true
            else if i_shorts
                signal := -1

if signal != 0
    float dist = math.max(math.abs(close - pbExtreme), syminfo.mintick * 5)
    sEntry := close
    sStop := signal == 1 ? close - dist : close + dist
    sTarget := signal == 1 ? close + dist * i_rr : close - dist * i_rr
    if i_allowOverlap or tDir == 0
        tDir := signal
        tEntry := sEntry
        tStop := sStop
        tTarget := sTarget
        tRisk := dist
        tTrail := sStop
        tBar := bar_index
        tStopBox := box.new(bar_index, math.max(sEntry, sStop), bar_index + i_extendBars, math.min(sEntry, sStop), bgcolor=color.new(i_bearCol, i_boxFill), border_color=color.new(i_bearCol, 35), border_width=1)
        array.push(tBoxes, tStopBox)
        if not trailMode
            tTargetBox := box.new(bar_index, math.max(sEntry, sTarget), bar_index + i_extendBars, math.min(sEntry, sTarget), bgcolor=color.new(i_bullCol, i_boxFill), border_color=color.new(i_bullCol, 35), border_width=1)
            array.push(tBoxes, tTargetBox)
        if i_showLabels
            string tip = (signal == 1 ? "LONG" : "SHORT") + " · " + str.tostring(i_fastLen) + "/" + str.tostring(i_slowLen) + " cross, first pullback to the " + str.tostring(i_fastLen) + " EMA, confirming close" + "\nEntry " + str.tostring(sEntry, format.mintick) + "\nStop " + str.tostring(sStop, format.mintick) + " (the pullback " + (signal == 1 ? "low" : "high") + ")" + (trailMode ? "\nExit: ATR trailing stop" : "\nTarget " + str.tostring(sTarget, format.mintick) + " (" + str.tostring(i_rr, "#.#") + "R)")
            label sl = label.new(bar_index, signal == 1 ? low : high, signal == 1 ? "BUY" : "SELL", color=color.new(signal == 1 ? i_bullCol : i_bearCol, 0), textcolor=signal == 1 ? c_dark : c_white, style=signal == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=tip)
            array.push(tLabels, sl)
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
    table.cell(led, 0, 0, "EMA CROSS PULLBACK SIGNALS", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
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
    table.cell(led, 0, 9, str.tostring(i_fastLen) + "/" + str.tostring(i_slowLen) + " cross", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 9, armed == 1 ? "armed long" : armed == -1 ? "armed short" : "-", text_color=armed == 1 ? i_bullCol : armed == -1 ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 10, "First pullback", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 10, armed == 0 ? "-" : crossDone ? "done for this cross" : pbSeen ? "seen · waiting for the close" : "waiting for the touch", text_color=crossDone ? lab : pbSeen ? c_white : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 11, "EMA " + str.tostring(i_trendLen) + (i_useTrend ? " filter on" : " filter off"), text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 11, trendUp ? "price above · longs" : trendDn ? "price below · shorts" : "-", text_color=trendUp ? i_bullCol : trendDn ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 12, "Exit", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 12, trailMode ? "ATR " + str.tostring(i_atrLen) + " × " + str.tostring(i_atrMult, "#.#") + " trailing stop" : "fixed target " + str.tostring(i_rr, "#.#") + "R", text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 13, "Open trade", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 13, tDir == 1 ? "LONG · stop " + str.tostring(trailMode ? tTrail : tStop, format.mintick) + (trailMode ? " (trail)" : " · target " + str.tostring(tTarget, format.mintick)) : tDir == -1 ? "SHORT · stop " + str.tostring(trailMode ? tTrail : tStop, format.mintick) + (trailMode ? " (trail)" : " · target " + str.tostring(tTarget, format.mintick)) : "none", text_color=tDir == 1 ? i_bullCol : tDir == -1 ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)

// ─── CHART PLOTS ───────────────────────────────────────────────────────────────
plot(i_showMAs ? emaF : na, "Fast EMA", color=i_fastCol, linewidth=2)
plot(i_showMAs ? emaS : na, "Slow EMA", color=i_slowCol, linewidth=2)
plot(i_showMAs ? emaT : na, "Trend EMA", color=i_trendCol, linewidth=2)
float trailPlot = tDir != 0 and trailMode ? tTrail : na
plot(trailPlot, "ATR trail", color=color.new(i_bearCol, 0), style=plot.style_linebr, linewidth=2)
plotshape(i_showPull and pbMarkL, "Pullback (long)", style=shape.circle, location=location.belowbar, color=color.new(i_fastCol, 0), size=size.tiny)
plotshape(i_showPull and pbMarkS, "Pullback (short)", style=shape.circle, location=location.abovebar, color=color.new(i_fastCol, 0), size=size.tiny)
bgcolor(i_showTint and ready ? (trendUp ? color.new(i_bullCol, 94) : trendDn ? color.new(i_bearCol, 94) : na) : na, title="Trend tint")

// ─── DATA-WINDOW PLOTS (read by tools, hidden on the chart) ────────────────────
plot(emaF, "emaFast", display=display.data_window)
plot(emaS, "emaSlow", display=display.data_window)
plot(emaT, "emaTrend", display=display.data_window)
plot(atrV, "atr", display=display.data_window)
plot(armed, "armed", display=display.data_window)
plot(crossUp ? 1 : crossDn ? -1 : 0, "cross", display=display.data_window)
plot(pbMarkL ? 1 : pbMarkS ? -1 : 0, "pullback", display=display.data_window)
plot(signal, "signal", display=display.data_window)
plot(skipped ? 1 : 0, "skipped", display=display.data_window)
plot(filtered ? 1 : 0, "filtered", display=display.data_window)
plot(signal != 0 ? sEntry : na, "entry", display=display.data_window)
plot(signal != 0 ? sStop : na, "stop", display=display.data_window)
plot(signal != 0 ? sTarget : na, "target", display=display.data_window)
plot(resultR, "result", display=display.data_window)
plot(exitLevel, "exitLevel", display=display.data_window)
plot(tDir, "openDir", display=display.data_window)
plot(trailPlot, "trail", display=display.data_window)
plot(lN, "ledgerN", display=display.data_window)
plot(ledgerWins, "ledgerWins", display=display.data_window)
plot(ledgerLosses, "ledgerLosses", display=display.data_window)
plot(ledgerTotalR, "ledgerTotalR", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
if i_alertJson and longSignal
    alert('{"action":"LONG","indicator":"ECPS","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"stop":' + str.tostring(sStop) + ',"target":' + str.tostring(sTarget) + ',"exit":"' + (trailMode ? "atr-trail" : "fixed") + '"}', alert.freq_once_per_bar_close)
if i_alertJson and shortSignal
    alert('{"action":"SHORT","indicator":"ECPS","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"stop":' + str.tostring(sStop) + ',"target":' + str.tostring(sTarget) + ',"exit":"' + (trailMode ? "atr-trail" : "fixed") + '"}', alert.freq_once_per_bar_close)

alertcondition(longSignal,                "ECPS Long entry",  "EMA Cross Pullback Signals: LONG on {{ticker}} {{interval}} at {{close}}")
alertcondition(shortSignal,               "ECPS Short entry", "EMA Cross Pullback Signals: SHORT on {{ticker}} {{interval}} at {{close}}")
alertcondition(longSignal or shortSignal, "ECPS Any entry",   "EMA Cross Pullback Signals: entry on {{ticker}} {{interval}} at {{close}}")
````
