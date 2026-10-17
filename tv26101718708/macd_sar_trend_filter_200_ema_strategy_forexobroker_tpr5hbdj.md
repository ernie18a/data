# MACD SAR Trend Filter: 200 EMA Strategy [forexobroker]

- url: https://www.tradingview.com/script/TpR5hbdJ-MACD-SAR-Trend-Filter-200-EMA-Strategy-forexobroker/
- type: indicator
- pine_id: PUB;69007aa767c242afa061362da68b591c
- version: 1.0

## Description

MACD SAR Trend Filter: 200 EMA + MACD + Parabolic SAR [forexobroker]

🔶 OVERVIEW

MACD SAR Trend Filter is a three-indicator trend strategy with its own trade log. It takes the most common MACD entry, the line crossing its signal line, and only lets it through when two other things agree: price is on the right side of the 200 EMA, and the Parabolic SAR dot is on the right side of the candle. Every entry is drawn with its stop and its target, every trade is followed to its result, and the last 100 results are counted in a table on the chart.

It is built for traders who want to see, on their own symbol and timeframe, what a classic indicator combination really did over the last 100 trades, wins and losses alike, before they trust it.

🔶 HOW IT WORKS

1. Trend. The close is above the 200 EMA: longs only. The close is below it: shorts only. The background is tinted faintly green or red so the allowed side is always visible.

2. Momentum. The MACD line (12, 26, 9) must be above its signal line for a long, below it for a short.

3. Confirmation. The Parabolic SAR dot (0.02, 0.02, 0.2) must be below the candle for a long, above it for a short.

A LONG signal prints on the closed candle on which conditions 2 and 3 are both true for the first time while condition 1 holds. There are two ways to get there: the MACD line crosses up while the dot is already below the candle, or the MACD line has already crossed up and the dot then flips below the candle. A SHORT signal is the mirror. A candle that only closes across the 200 EMA while the other two were already aligned is not a signal.

🔶 TRADE MANAGEMENT

Entry at the close of the signal candle. Stop at the SAR dot of that candle. Target at a fixed reward multiple of the stop distance, 1R by default (a one-to-one target). The trade is drawn as a red box from the entry to the stop and a green box from the entry to the target, from the signal candle to the candle that resolves it, with a "+1R" or "-1R" label at the end.

Optional stop limit: when the dot is far from price the risk is large. "Max stop, % of price" caps the stop distance at a percentage of the entry price (0 = off, the default). A capped entry is labelled "stop capped".

🔶 THE LOG

One trade at a time. A valid setup that appears while a trade is still open is drawn faded and is not counted (switch "Allow overlapping trades" on to count every setup). Every open trade is followed on closed candles to its stop or its target. When one candle touches both, the stop is counted first: that is the conservative reading of an ambiguous candle.

The last N results (100 by default) feed the table: signals, wins, losses, win rate, total R, best win streak, worst loss streak and days covered, followed by the live state of the three conditions and the open trade. A win adds the reward ratio in R, a loss subtracts 1R.

NON-REPAINTING: every condition, every signal and every result is evaluated on barstate.isconfirmed; there is no request.security and no lookahead.

🔶 SETTINGS

Indicators
- Trend EMA length (default 200).
- MACD fast, slow and signal lengths (12, 26, 9).
- SAR start, increment and maximum (0.02, 0.02, 0.2).

Setup
- Allow overlapping trades (default off): one trade at a time.
- Entry type (default Both): Both, MACD cross only, or SAR flip only. The log counts only the entries the setting lets through, so the three variants can be compared.
- Take longs, Take shorts.

Trade
- Reward ratio (default 1.0): target = stop distance × this.
- Max stop, % of price (default 0 = off).
- Extend open trade boxes (bars).

Log
- Log size (default 100), Show log table, Table position, Table text size.

Visual
- Long and short colours, EMA colour, show the EMA, show the SAR dots, tint the background by trend, BUY / SELL labels, +R / -R result labels, trades kept on chart, box fill transparency.

Alerts
- Send JSON alert() messages.

🔶 ALERTS

Three alertcondition hooks: MSTF Long setup, MSTF Short setup, MSTF Any setup. With "Send JSON alert() messages" on, every taken signal also fires an alert() once per bar close with a JSON body (action, ticker, timeframe, entry, stop, target, capped).

🔶 LIMITATIONS

- The three indicators are trend tools. In a sideways market the MACD and the SAR flip often and the strategy takes losses in a row; the log's worst loss streak shows how long that has lasted on your symbol.
- With a one-to-one target the strategy needs to win more than half of its trades. Check the win rate in the table before anything else.
- Results in the log are the script's own rules applied to closed candles: no spread, no commission, no slippage, and the stop is counted before the target on a candle that touches both.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: MACD SAR Trend Filter — a three-indicator trend strategy with its own trade log.
// (1) Trend: the close is above the 200 EMA (longs only) or below it (shorts only).
// (2) Momentum: the MACD line (12, 26, 9) is above its signal line for longs, below it for shorts.
// (3) Confirmation: the Parabolic SAR dot (0.02, 0.02, 0.2) is below the candle for longs, above it
//     for shorts.
// A LONG signal prints on the closed candle on which conditions 2 and 3 are both true for the first
// time while 1 holds: either the MACD line crossed up with the dot already below, or the dot flipped
// below with the MACD line still above its signal line. SHORT is the mirror. A candle that only
// closes across the 200 EMA while the other two were already aligned is not a signal.
// The stop sits at the SAR dot of the signal candle (optionally capped at a percentage of price),
// the target at a fixed reward multiple of the stop distance (1R by default). One trade at a time;
// every trade is followed to its stop or target on closed candles, stop first when a candle touches
// both, and the last N results feed the on-chart log (wins, losses, win rate, total R, streaks,
// days covered).
// Non-repainting: every condition and every trade result is evaluated on barstate.isconfirmed,
// there is no request.security and no lookahead.
indicator("MACD SAR Trend Filter: 200 EMA + MACD + Parabolic SAR [forexobroker]", shorttitle="MSTF [fob]", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_ind    = "Indicators"
string g_setup  = "Setup"
string g_trade  = "Trade"
string g_ledger = "Log"
string g_vis    = "Visual"
string g_alert  = "Alerts"

// ─── INPUTS: INDICATORS ────────────────────────────────────────────────────────
int   i_emaLen   = input.int(200, "Trend EMA length", minval=10, maxval=1000, group=g_ind, tooltip="The long-term trend filter. Close above it: longs only. Close below it: shorts only.")
int   i_fast     = input.int(12, "MACD fast length", minval=2, maxval=200, group=g_ind)
int   i_slow     = input.int(26, "MACD slow length", minval=3, maxval=400, group=g_ind)
int   i_sigLen   = input.int(9, "MACD signal length", minval=2, maxval=100, group=g_ind, tooltip="The MACD line is the fast EMA minus the slow EMA of the close; the signal line is an EMA of the MACD line. These are TradingView's default MACD settings.")
float i_sarStart = input.float(0.02, "SAR start", minval=0.001, maxval=1.0, step=0.01, group=g_ind)
float i_sarInc   = input.float(0.02, "SAR increment", minval=0.001, maxval=1.0, step=0.01, group=g_ind)
float i_sarMax   = input.float(0.2, "SAR maximum", minval=0.01, maxval=1.0, step=0.01, group=g_ind, tooltip="TradingView's default Parabolic SAR settings: 0.02, 0.02, 0.2.")

// ─── INPUTS: SETUP ─────────────────────────────────────────────────────────────
bool i_allowOverlap = input.bool(false, "Allow overlapping trades", group=g_setup, tooltip="OFF (default): one trade at a time. A valid setup that appears while a trade is still open is drawn faded and is not counted in the log. ON: every valid setup opens its own trade.")
string i_entryMode = input.string("Both", "Entry type", options=["Both", "MACD cross only", "SAR flip only"], group=g_setup, tooltip="A setup is complete when the MACD condition and the SAR condition are both true. Both (default): either route counts. MACD cross only: the entry candle must be the one on which the MACD line crossed, with the dot already on the right side. SAR flip only: the entry candle must be the one on which the dot flipped, with the MACD line already on the right side. The log counts only the entries this setting lets through, so the three variants can be compared on any chart.")
bool i_longs  = input.bool(true, "Take longs", group=g_setup)
bool i_shorts = input.bool(true, "Take shorts", group=g_setup)

// ─── INPUTS: TRADE ─────────────────────────────────────────────────────────────
float i_rr         = input.float(1.0, "Reward ratio (target = stop × this)", minval=0.5, maxval=10.0, step=0.5, group=g_trade, tooltip="The target distance as a multiple of the stop distance. 1 = a one-to-one target. A win adds this many R to the log, a loss subtracts 1R.")
float i_maxStopPct = input.float(0.0, "Max stop, % of price (0 = off)", minval=0.0, maxval=10.0, step=0.1, group=g_trade, tooltip="The stop is the SAR dot. When the dot is far away the risk is large. If the stop distance exceeds this percentage of the entry price, the stop is capped at that distance and the label says 'capped'. 0 (default) keeps the dot as the stop in every case; 0.7 is the limit used in the video's tip.")
int   i_extendBars = input.int(30, "Extend open trade boxes (bars)", minval=5, maxval=200, group=g_trade)

// ─── INPUTS: LOG ───────────────────────────────────────────────────────────────
int    i_ledgerN   = input.int(100, "Log size (last N signals)", minval=10, maxval=500, group=g_ledger, tooltip="The rolling number of completed trades the table summarises. The '100 trades' test of the video is this table at 100.")
bool   i_showTable = input.bool(true, "Show log table", group=g_ledger)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_ledger)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_ledger)

// ─── INPUTS: VISUAL ────────────────────────────────────────────────────────────
color i_bullCol    = input.color(#00E5A8, "Long colour", group=g_vis)
color i_bearCol    = input.color(#FF3B5C, "Short colour", group=g_vis)
color i_emaCol     = input.color(#4DA3FF, "200 EMA colour", group=g_vis)
bool  i_showEma    = input.bool(true, "Show the trend EMA", group=g_vis)
bool  i_showSar    = input.bool(true, "Show the SAR dots", group=g_vis)
bool  i_showTint   = input.bool(true, "Tint the background by trend", group=g_vis, tooltip="A faint green tint while the close is above the trend EMA (longs only), a faint red tint while it is below (shorts only).")
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
float emaV = ta.ema(close, i_emaLen)
[macdV, sigV, histV] = ta.macd(close, i_fast, i_slow, i_sigLen)
float sarV = ta.sar(i_sarStart, i_sarInc, i_sarMax)

bool trendUp   = close > emaV
bool trendDn   = close < emaV
bool macdUp    = macdV > sigV
bool macdDn    = macdV < sigV
bool sarBelow  = sarV < close
bool sarAbove  = sarV > close

// Conditions 2 and 3 together; the signal is the first closed candle on which the pair is true.
bool pairUp = macdUp and sarBelow
bool pairDn = macdDn and sarAbove
bool ready  = not na(emaV) and not na(sigV) and not na(sarV)

// ─── OPEN TRADE AND LOG STATE ──────────────────────────────────────────────────
var int   tDir = 0            // 1 long, -1 short, 0 flat
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
        while array.size(tLabels) > i_keepTrades * 2
            label.delete(array.shift(tLabels))

// Result of the open trade on this confirmed bar. The stop is checked BEFORE the target: when one
// candle touches both, the loss is booked. This is the conservative reading of an ambiguous candle.
float resultR = na
if confirmed and tDir != 0 and bar_index > tBar
    bool stopHit = tDir == 1 ? low <= tStop : high >= tStop
    bool targetHit = tDir == 1 ? high >= tTarget : low <= tTarget
    if stopHit
        resultR := -1.0
    else if targetHit
        resultR := i_rr
    if not na(resultR)
        f_pushResult(resultR, time)
        if not na(tStopBox)
            box.set_right(tStopBox, bar_index)
            box.set_right(tTargetBox, bar_index)
        if i_showResult
            bool win = resultR > 0
            float yRes = win ? tTarget : tStop
            string txt = (resultR > 0 ? "+" : "") + str.tostring(resultR, "#.#") + "R"
            label rl = label.new(bar_index, yRes, txt, color=color.new(win ? i_bullCol : i_bearCol, 0), textcolor=win ? c_dark : c_white, style=tDir == 1 ? (win ? label.style_label_down : label.style_label_up) : (win ? label.style_label_up : label.style_label_down), size=size.small)
            array.push(tLabels, rl)
        tDir := 0
        tEntry := na
        tStop := na
        tTarget := na
        tBar := na
        tStopBox := na
        tTargetBox := na
        f_trimDrawings()

// Keep the open trade's boxes growing while it is open.
if tDir != 0 and not na(tStopBox)
    box.set_right(tStopBox, bar_index + i_extendBars)
    box.set_right(tTargetBox, bar_index + i_extendBars)

// ─── THE SIGNAL ────────────────────────────────────────────────────────────────
int   signal = 0            // +1 long, -1 short on the signal bar
bool  skipped = false       // a valid setup not taken (a trade is open)
int   trigger = 0           // 1 = the MACD cross completed the pair, 2 = the SAR flip completed it
float sEntry = na
float sStop = na
float sTarget = na
bool  sCapped = false

if confirmed and ready and not na(macdV[1]) and not na(sarV[1])
    if i_longs and trendUp and pairUp and not pairUp[1]
        signal := 1
        trigger := macdUp and not macdUp[1] ? 1 : 2
    else if i_shorts and trendDn and pairDn and not pairDn[1]
        signal := -1
        trigger := macdDn and not macdDn[1] ? 1 : 2

// The entry-type filter: a setup of the other route is ignored entirely (not drawn, not counted).
if signal != 0 and ((i_entryMode == "MACD cross only" and trigger != 1) or (i_entryMode == "SAR flip only" and trigger != 2))
    signal := 0
    trigger := 0

if signal != 0
    float dist = math.max(math.abs(close - sarV), syminfo.mintick * 5)
    float capDist = i_maxStopPct > 0 ? close * i_maxStopPct / 100.0 : na
    if not na(capDist) and dist > capDist
        dist := capDist
        sCapped := true
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
            string why = trigger == 1 ? "MACD cross with the SAR dot already " + (signal == 1 ? "below" : "above") : "SAR flip with the MACD line still " + (signal == 1 ? "above" : "below") + " its signal line"
            string tip = (signal == 1 ? "LONG" : "SHORT") + " · " + why + "\nEntry " + str.tostring(sEntry, format.mintick) + "\nStop " + str.tostring(sStop, format.mintick) + (sCapped ? " (capped at " + str.tostring(i_maxStopPct, "#.##") + " %)" : " (the SAR dot)") + "\nTarget " + str.tostring(sTarget, format.mintick) + " (" + str.tostring(i_rr, "#.#") + "R)"
            label sl = label.new(bar_index, signal == 1 ? low : high, (signal == 1 ? "BUY" : "SELL") + cap, color=color.new(signal == 1 ? i_bullCol : i_bearCol, 0), textcolor=signal == 1 ? c_dark : c_white, style=signal == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=tip)
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
    var table led = table.new(f_pos(i_tablePos), 2, 13, bgcolor=color.new(c_dark, 8), border_color=color.new(c_purple, 45), border_width=1, frame_color=color.new(c_purple, 15), frame_width=2)
    string ts  = i_tableSize == "Large" ? size.normal : i_tableSize == "Small" ? size.tiny : size.small
    string tsH = i_tableSize == "Large" ? size.large : i_tableSize == "Small" ? size.small : size.normal
    color lab = c_grey
    table.cell(led, 0, 0, "MACD SAR TREND FILTER", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
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
    table.cell(led, 0, 9, "Trend (EMA " + str.tostring(i_emaLen) + ")", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 9, trendUp ? "above · longs only" : trendDn ? "below · shorts only" : "-", text_color=trendUp ? i_bullCol : trendDn ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 10, "MACD line", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 10, macdUp ? "above its signal line" : macdDn ? "below its signal line" : "-", text_color=macdUp ? i_bullCol : macdDn ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 11, "SAR dot", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 11, sarBelow ? "below the candle" : sarAbove ? "above the candle" : "-", text_color=sarBelow ? i_bullCol : sarAbove ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 12, "Open trade", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 12, tDir == 1 ? "LONG · stop " + str.tostring(tStop, format.mintick) + " · target " + str.tostring(tTarget, format.mintick) : tDir == -1 ? "SHORT · stop " + str.tostring(tStop, format.mintick) + " · target " + str.tostring(tTarget, format.mintick) : "none", text_color=tDir == 1 ? i_bullCol : tDir == -1 ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)

// ─── CHART PLOTS ───────────────────────────────────────────────────────────────
plot(i_showEma ? emaV : na, "Trend EMA", color=i_emaCol, linewidth=2)
plot(i_showSar ? sarV : na, "SAR", color=sarBelow ? i_bullCol : i_bearCol, style=plot.style_circles, linewidth=1)
bgcolor(i_showTint and ready ? (trendUp ? color.new(i_bullCol, 94) : trendDn ? color.new(i_bearCol, 94) : na) : na, title="Trend tint")

// ─── DATA-WINDOW PLOTS (read by tools, hidden on the chart) ────────────────────
plot(emaV, "ema", display=display.data_window)
plot(sarV, "sar", display=display.data_window)
plot(macdV, "macd", display=display.data_window)
plot(sigV, "macdSignal", display=display.data_window)
plot(signal, "signal", display=display.data_window)
plot(skipped ? 1 : 0, "skipped", display=display.data_window)
plot(trigger, "trigger", display=display.data_window)
plot(signal != 0 ? sEntry : na, "entry", display=display.data_window)
plot(signal != 0 ? sStop : na, "stop", display=display.data_window)
plot(signal != 0 ? sTarget : na, "target", display=display.data_window)
plot(signal != 0 and sCapped ? 1 : 0, "stopCapped", display=display.data_window)
plot(resultR, "result", display=display.data_window)
plot(tDir, "openDir", display=display.data_window)
plot(lN, "ledgerN", display=display.data_window)
plot(ledgerWins, "ledgerWins", display=display.data_window)
plot(ledgerLosses, "ledgerLosses", display=display.data_window)
plot(ledgerTotalR, "ledgerTotalR", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
if i_alertJson and longSignal
    alert('{"action":"LONG","indicator":"MSTF","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"stop":' + str.tostring(sStop) + ',"target":' + str.tostring(sTarget) + ',"capped":' + (sCapped ? "true" : "false") + '}', alert.freq_once_per_bar_close)
if i_alertJson and shortSignal
    alert('{"action":"SHORT","indicator":"MSTF","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"stop":' + str.tostring(sStop) + ',"target":' + str.tostring(sTarget) + ',"capped":' + (sCapped ? "true" : "false") + '}', alert.freq_once_per_bar_close)

alertcondition(longSignal,                "MSTF Long setup",  "MACD SAR Trend Filter: LONG on {{ticker}} {{interval}} at {{close}}")
alertcondition(shortSignal,               "MSTF Short setup", "MACD SAR Trend Filter: SHORT on {{ticker}} {{interval}} at {{close}}")
alertcondition(longSignal or shortSignal, "MSTF Any setup",   "MACD SAR Trend Filter: setup on {{ticker}} {{interval}} at {{close}}")
````
