# 4H Range Scalper: First-Candle Range Reversal [forexobroker]

- url: https://www.tradingview.com/script/v6FGz8de-4H-Range-Scalper-First-Candle-Range-Reversal-forexobroker/
- type: indicator
- pine_id: PUB;38b135252b0f45b9a04e8a591aea097c
- version: 1.0

## Description

4H Range Scalper: First-Candle Range Reversal [forexobroker]

🔶 OVERVIEW

4H Range Scalper marks one candle a day and trades against everything that breaks out of it and fails. The candle is the first 4-hour candle that opens on the current calendar date in New York time. Once it has fully closed, its high and low become the range for the rest of that date. On the trading chart (5 minutes by default) a candle that CLOSES outside the range starts a breakout; the first candle that then CLOSES back inside the range is the signal, taken against the breakout. Wicks never count, only closes.

It is built for day traders who want a rule-based intraday strategy with a fixed checklist, and a log on the chart that counts every signal the same way, wins and losses alike.

🔶 HOW IT WORKS

Step 1, the range. The script reads the chart's own 4-hour grid (the same candles a 4-hour chart of the symbol shows) and waits for the first 4-hour candle whose open time falls on the current New York date to close. Its high and low are drawn as two lines from the candle's close to midnight New York time. The candle itself is boxed. The range is never set before the candle has closed.

Step 2, the setup. On the trading chart a candle that closes above the range high (or below the range low) starts a breakout. While price stays outside, the extreme of the move is tracked candle by candle. The first candle that closes back inside the range is the setup: a close back under the range high is a SHORT, a close back over the range low is a LONG. After midnight New York time no new setups are taken until the next day's range is set.

Step 3, the trade. Entry at the close of the signal candle. Stop at the breakout extreme (the exact high or low of the move outside the range) or, optionally, at the range edge. When the breakout was large and the stop would be far away, the stop is capped at a multiple of ATR (2.0 by default) and the label says "capped". Target at a fixed reward multiple of the stop distance (2.0 by default). The trade is drawn the way the Long / Short Position tool draws it: a red box from the entry to the stop and a green box from the entry to the target, from the signal candle to the candle that resolves the trade, with a "+2R" or "-1R" label at the end.

🔶 THE LEDGER

One trade at a time. A valid setup that appears while a trade is still open is drawn faded and is not counted (switch "Allow overlapping trades" on to count every setup). Every open trade is followed on closed candles to its stop or its target. When one candle touches both, the stop is counted first: that is the conservative reading, and it is the only fair way to count on closed candles.

The last N results (100 by default) feed the table on the chart: Signals, Wins, Losses, Win rate, Total R, Best win streak, Worst loss streak, Days covered, and today's wins / losses / R. A win adds the reward ratio in R, a loss subtracts 1R. The table changes only when a trade resolves on a closed candle.

NON-REPAINTING: the range is set only after its candle closed; every state change, every signal and every result happens on barstate.isconfirmed; there is no request.security and no lookahead. The 4-hour grid comes from the chart itself, so the range candle is exactly the candle the 4-hour chart shows.

🔶 SETTINGS

Range
- Day boundary timezone (default America/New_York): the calendar date and the midnight that ends the range are taken here.
- Range candle timeframe (default 240): the higher timeframe whose first candle of the date gives the range.
- Highlight the range candle; Days of range lines kept.

Setup
- Allow overlapping trades (default off): one trade at a time.
- Max setups per day (default 0 = no limit).

Trade
- Stop: Breakout extreme (default) or Range edge.
- Max stop, ATR × (default 2.0; 0 = off) and ATR length (14): the stop cap.
- Reward ratio (default 2.0): target = stop distance × this.
- Close open trade at day end (default off).
- Extend open trade boxes (bars).

Ledger
- Ledger size (default 100), Show ledger table, Table position, Table text size.

Visual
- Long and short colours, range line colour and width, BUY / SELL labels, +R / -R result labels, trades kept on chart, box fill transparency.

Alerts
- Send JSON alert() messages.

🔶 ALERTS

Five alertcondition hooks: 4HRS Long setup, 4HRS Short setup, 4HRS Any setup, 4HRS Range set (today's range is drawn), 4HRS Breakout (a candle closed outside the range, the re-entry is awaited). With "Send JSON alert() messages" on, every signal also fires an alert() once per bar close with a JSON body (action, ticker, timeframe, entry, stop, target, capped).

🔶 LIMITATIONS

- The strategy is intraday by design: the range is valid for one calendar date. On a chart timeframe above the range timeframe it draws nothing useful; use it on 1 to 15 minute charts with the 4-hour range.
- The first 4-hour candle of the date depends on the symbol's own 4-hour grid (crypto candles align to UTC, forex and CFD candles to the session open), so the range candle opens at different New York hours on different markets. The boxed candle on the chart is always the one the strategy uses.
- Results in the ledger are the strategy's own rules applied to closed candles: no spread, no commission, no slippage, and the stop is counted before the target on a candle that touches both.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: 4H Range Scalper — First-Candle Range Reversal. The whole strategy needs one candle:
// the first 4-hour candle that opens on the current calendar date in the chosen timezone (New York
// by default). Once that candle has fully closed, its high and low become "the range" for the rest
// of that date. On the trading chart (5 minutes by default) a candle that CLOSES outside the range
// starts a breakout; the extreme of that excursion is tracked bar by bar. The first candle that then
// CLOSES back inside the range is the signal, taken against the breakout: a close back under the
// range high is a SHORT, a close back over the range low is a LONG. Wicks never count, only closes.
// The stop sits at the breakout extreme (optionally capped at a multiple of ATR), the target at a
// fixed reward multiple of the stop distance. One trade at a time; every trade is followed to its
// stop or target on closed candles, stop first when a candle touches both, and the last N results
// feed the on-chart ledger (wins, losses, win rate, total R, streaks, days covered).
// The 4-hour grid is the chart's own `time("240")` grid, so the range candle is exactly the candle a
// 4-hour chart of the same symbol shows; nothing is re-derived from the epoch.
// Non-repainting: the range is set only after its candle closed, every state change and every
// trade result happens on barstate.isconfirmed, there is no request.security and no lookahead.
indicator("4H Range Scalper: First-Candle Range Reversal [forexobroker]", shorttitle="4HRS [fob]", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_range  = "Range"
string g_setup  = "Setup"
string g_trade  = "Trade"
string g_ledger = "Ledger"
string g_vis    = "Visual"
string g_alert  = "Alerts"

// ─── INPUTS: RANGE ─────────────────────────────────────────────────────────────
string i_tz       = input.string("America/New_York", "Day boundary timezone", options=["America/New_York", "Europe/London", "UTC", "Asia/Tokyo", "Australia/Sydney"], group=g_range, tooltip="The calendar date is taken in this timezone. The range candle is the first candle of the range timeframe whose OPEN time falls on the current date here, and the range stays valid until midnight of that date. Data Trader's rule uses New York time.")
string i_rangeTf  = input.timeframe("240", "Range candle timeframe", group=g_range, tooltip="The higher timeframe whose first candle of the day gives the range. 240 = 4 hours. The grid is the chart's own grid for that timeframe, identical to what a chart of that timeframe shows.")
bool   i_showCandleBox = input.bool(true, "Highlight the range candle", group=g_range)
int    i_keepDays = input.int(30, "Days of range lines kept", minval=1, maxval=200, group=g_range, tooltip="How many past days keep their range lines and candle box on the chart before the oldest are removed.")

// ─── INPUTS: SETUP ─────────────────────────────────────────────────────────────
bool i_allowOverlap = input.bool(false, "Allow overlapping trades", group=g_setup, tooltip="OFF (default): one trade at a time. A valid setup that appears while a trade is still open is drawn faded and is not counted in the ledger. ON: every valid setup opens its own trade.")
int  i_maxPerDay    = input.int(0, "Max setups per day (0 = no limit)", minval=0, maxval=50, group=g_setup, tooltip="Optional cap on the number of signals taken per date. 0 keeps every valid setup, which is the strategy as taught.")

// ─── INPUTS: TRADE ─────────────────────────────────────────────────────────────
string i_stopMode  = input.string("Breakout extreme", "Stop", options=["Breakout extreme", "Range edge"], group=g_trade, tooltip="Breakout extreme (default): the highest high (short) or lowest low (long) reached while price was outside the range, the 'exact high of the breakout move'. Range edge: the range high or low itself, a tighter stop.")
float  i_maxStopAtr = input.float(2.0, "Max stop, ATR × (0 = off)", minval=0.0, maxval=20.0, step=0.5, group=g_trade, tooltip="When the breakout was large, a stop at its extreme can be far away. If the stop distance exceeds this many ATR the stop is capped at that distance and the signal label says 'capped'. Data Trader moves such a stop to the nearest key level by hand; this is the mechanical version of that rule.")
int    i_atrLen     = input.int(14, "ATR length", minval=2, maxval=200, group=g_trade)
float  i_rr         = input.float(2.0, "Reward ratio (target = stop × this)", minval=0.5, maxval=10.0, step=0.5, group=g_trade, tooltip="The target distance as a multiple of the stop distance. A win adds this many R to the ledger, a loss subtracts 1R.")
bool   i_closeDayEnd = input.bool(false, "Close open trade at day end", group=g_trade, tooltip="OFF (default): a trade that is still open at midnight stays open until its stop or target. ON: it is closed at the last candle of the date and its result is the R at that close.")
int    i_extendBars = input.int(40, "Extend open trade boxes (bars)", minval=5, maxval=200, group=g_trade)

// ─── INPUTS: LEDGER ────────────────────────────────────────────────────────────
int    i_ledgerN   = input.int(100, "Ledger size (last N signals)", minval=10, maxval=500, group=g_ledger, tooltip="The rolling number of completed trades the table summarises. Data Trader's '100 trades' test is this table at 100.")
bool   i_showTable = input.bool(true, "Show ledger table", group=g_ledger)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_ledger)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_ledger)

// ─── INPUTS: VISUAL ────────────────────────────────────────────────────────────
color i_bullCol   = input.color(#00E5A8, "Long colour", group=g_vis)
color i_bearCol   = input.color(#FF3B5C, "Short colour", group=g_vis)
color i_rangeCol  = input.color(#FFFFFF, "Range line colour", group=g_vis)
int   i_rangeW    = input.int(2, "Range line width", minval=1, maxval=4, group=g_vis)
bool  i_showLabels = input.bool(true, "Show BUY / SELL labels", group=g_vis)
bool  i_showResult = input.bool(true, "Show +R / -R result labels", group=g_vis)
int   i_keepTrades = input.int(60, "Trades kept on chart", minval=1, maxval=200, group=g_vis, tooltip="How many past trades keep their boxes and labels before the oldest are removed.")
int   i_boxFill    = input.int(78, "Box fill transparency", minval=50, maxval=95, group=g_vis)

// ─── INPUTS: ALERTS ────────────────────────────────────────────────────────────
bool i_alertJson = input.bool(true, "Send JSON alert() messages", group=g_alert, tooltip="Besides the alertcondition hooks, fire an alert() with a JSON body on every signal (once per bar close). Useful for webhooks.")

color c_white = #FFFFFF
color c_dark  = #0B0F14
color c_purple = #A259FF
color c_grey  = #9AA4AE

// ─── DATE AND HIGHER-TIMEFRAME GRID ────────────────────────────────────────────
bool confirmed = barstate.isconfirmed
float atrV = ta.atr(i_atrLen)

// Calendar date of the current bar's open in the chosen timezone, as one integer key.
int dateKey = year(time, i_tz) * 10000 + month(time, i_tz) * 100 + dayofmonth(time, i_tz)
bool newDay = na(dateKey[1]) or dateKey != dateKey[1]

// Midnight that ends the current date, in the chosen timezone (timestamp normalises day + 1).
int dayEndT = timestamp(i_tz, year(time, i_tz), month(time, i_tz), dayofmonth(time, i_tz) + 1, 0, 0, 0)

// The chart's own grid for the range timeframe: open time of the HTF bar that contains this bar.
int htfOpen = time(i_rangeTf)
bool htfNew = na(htfOpen[1]) or htfOpen != htfOpen[1]

// Accumulate the running HTF candle from the chart bars; on the first bar of the next HTF candle the
// previous one is finished and its high / low / open time are final.
var float curH = na
var float curL = na
var int   curOpenT = na
var float finH = na
var float finL = na
var int   finOpenT = na
var int   finEndT = na
var bool  finFresh = false
finFresh := false
if htfNew
    if not na(curOpenT)
        finH := curH
        finL := curL
        finOpenT := curOpenT
        finEndT := time
        finFresh := true
    curH := high
    curL := low
    curOpenT := htfOpen
else
    curH := math.max(nz(curH, high), high)
    curL := math.min(nz(curL, low), low)

// Date key of the finished HTF candle's open.
int finDateKey = na(finOpenT) ? int(na) : year(finOpenT, i_tz) * 10000 + month(finOpenT, i_tz) * 100 + dayofmonth(finOpenT, i_tz)

// ─── THE RANGE ─────────────────────────────────────────────────────────────────
var float rH = na
var float rL = na
var int   rDate = na
var int   rSetBar = na
var int   state = 0          // 0 inside, 1 closed above the range, -1 closed below
var float ext = na           // extreme of the current excursion
var int   setupsToday = 0

var array<line> rLines = array.new<line>()
var array<box>  rBoxes = array.new<box>()

if newDay
    rH := na
    rL := na
    rDate := na
    state := 0
    ext := na
    setupsToday := 0

bool rangeSetNow = false
if confirmed and finFresh and na(rDate) and not na(finDateKey) and finDateKey == dateKey
    rH := finH
    rL := finL
    rDate := dateKey
    rSetBar := bar_index
    state := 0
    ext := na
    rangeSetNow := true
    line hiLn = line.new(finEndT, rH, dayEndT, rH, xloc=xloc.bar_time, color=i_rangeCol, width=i_rangeW)
    line loLn = line.new(finEndT, rL, dayEndT, rL, xloc=xloc.bar_time, color=i_rangeCol, width=i_rangeW)
    array.push(rLines, hiLn)
    array.push(rLines, loLn)
    if i_showCandleBox
        box cb = box.new(finOpenT, rH, finEndT, rL, xloc=xloc.bar_time, bgcolor=color.new(i_rangeCol, 88), border_color=color.new(i_rangeCol, 55), border_width=1)
        array.push(rBoxes, cb)
    if array.size(rLines) > 0
        while array.size(rLines) > i_keepDays * 2
            line.delete(array.shift(rLines))
    if array.size(rBoxes) > 0
        while array.size(rBoxes) > i_keepDays
            box.delete(array.shift(rBoxes))

bool rangeActive = not na(rH) and rDate == dateKey

// ─── OPEN TRADE AND LEDGER STATE ───────────────────────────────────────────────
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
var int   todaySignals = 0
var int   todayWins = 0
var int   todayLosses = 0
var float todayR = 0.0
var int   ledgerWins = 0
var int   ledgerLosses = 0
var float ledgerTotalR = 0.0

if newDay
    todaySignals := 0
    todayWins := 0
    todayLosses := 0
    todayR := 0.0

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
    bool dayClose = i_closeDayEnd and dateKey[1] != dateKey
    if stopHit
        resultR := -1.0
    else if targetHit
        resultR := i_rr
    else if dayClose
        float risk = math.abs(tEntry - tStop)
        resultR := tDir == 1 ? (close - tEntry) / risk : (tEntry - close) / risk
    if not na(resultR)
        f_pushResult(resultR, time)
        todayR += resultR
        if resultR > 0
            todayWins += 1
        else
            todayLosses += 1
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

// ─── THE SETUP: CLOSE OUTSIDE, THEN CLOSE BACK INSIDE ──────────────────────────
int  signal = 0            // +1 long, -1 short on the signal bar
bool skipped = false       // a valid setup not taken (trade open, or the daily cap)
float sEntry = na
float sStop = na
float sTarget = na
bool  sCapped = false

if confirmed and rangeActive and not rangeSetNow
    if state == 0
        if close > rH
            state := 1
            ext := high
        else if close < rL
            state := -1
            ext := low
    else if state == 1
        if close <= rH
            if close >= rL
                signal := -1
            else
                state := -1
                ext := low
        else
            ext := math.max(ext, high)
    else if state == -1
        if close >= rL
            if close <= rH
                signal := 1
            else
                state := 1
                ext := high
        else
            ext := math.min(ext, low)

if signal != 0
    state := 0
    float rawStop = i_stopMode == "Range edge" ? (signal == 1 ? rL : rH) : ext
    float dist = math.max(math.abs(close - rawStop), syminfo.mintick * 5)
    float capDist = i_maxStopAtr > 0 ? i_maxStopAtr * nz(atrV, dist) : na
    if not na(capDist) and dist > capDist
        dist := capDist
        sCapped := true
    sEntry := close
    sStop := signal == 1 ? close - dist : close + dist
    sTarget := signal == 1 ? close + dist * i_rr : close - dist * i_rr
    ext := na
    bool capOk = i_maxPerDay == 0 or setupsToday < i_maxPerDay
    bool flatOk = i_allowOverlap or tDir == 0
    if capOk and flatOk
        setupsToday += 1
        todaySignals += 1
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
            string tip = (signal == 1 ? "LONG" : "SHORT") + " · closed back inside the range\nEntry " + str.tostring(sEntry, format.mintick) + "\nStop " + str.tostring(sStop, format.mintick) + (sCapped ? " (capped at " + str.tostring(i_maxStopAtr, "#.#") + " ATR)" : " (breakout extreme)") + "\nTarget " + str.tostring(sTarget, format.mintick) + " (" + str.tostring(i_rr, "#.#") + "R)"
            label sl = label.new(bar_index, signal == 1 ? low : high, (signal == 1 ? "BUY" : "SELL") + cap, color=color.new(signal == 1 ? i_bullCol : i_bearCol, 0), textcolor=signal == 1 ? c_dark : c_white, style=signal == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=tip)
            array.push(tLabels, sl)
        f_trimDrawings()
    else
        skipped := true
        if i_showLabels
            label sk = label.new(bar_index, signal == 1 ? low : high, (signal == 1 ? "buy" : "sell") + " · not taken", color=color.new(signal == 1 ? i_bullCol : i_bearCol, 70), textcolor=color.new(c_white, 20), style=signal == 1 ? label.style_label_up : label.style_label_down, size=size.tiny, tooltip=flatOk ? "Daily cap reached" : "A trade is still open (one trade at a time)")
            array.push(tLabels, sk)
            f_trimDrawings()

bool longSignal  = signal == 1 and not skipped
bool shortSignal = signal == -1 and not skipped

// ─── LEDGER STATISTICS ─────────────────────────────────────────────────────────
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

// ─── LEDGER TABLE ──────────────────────────────────────────────────────────────
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
    table.cell(led, 0, 0, "4H RANGE SCALPER", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
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
    table.cell(led, 0, 9, "Today  W / L / R", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 9, str.tostring(todayWins) + " / " + str.tostring(todayLosses) + " / " + (todayR >= 0 ? "+" : "") + str.tostring(todayR, "#.#") + "R", text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 10, "Range today", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 10, rangeActive ? str.tostring(rH, format.mintick) + " / " + str.tostring(rL, format.mintick) : "waiting for the first candle", text_color=rangeActive ? c_white : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 11, "Price vs range", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 11, not rangeActive ? "-" : state == 1 ? "closed ABOVE · waiting for re-entry" : state == -1 ? "closed BELOW · waiting for re-entry" : "inside", text_color=state == 1 ? i_bearCol : state == -1 ? i_bullCol : c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 12, "Open trade", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 12, tDir == 1 ? "LONG · stop " + str.tostring(tStop, format.mintick) + " · target " + str.tostring(tTarget, format.mintick) : tDir == -1 ? "SHORT · stop " + str.tostring(tStop, format.mintick) + " · target " + str.tostring(tTarget, format.mintick) : "none", text_color=tDir == 1 ? i_bullCol : tDir == -1 ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)

// ─── DATA-WINDOW PLOTS (read by tools, hidden on the chart) ────────────────────
plot(rangeActive ? rH : na, "rangeHigh", display=display.data_window)
plot(rangeActive ? rL : na, "rangeLow", display=display.data_window)
plot(rangeActive ? finOpenT : na, "rangeCandleOpen", display=display.data_window)
plot(state, "state", display=display.data_window)
plot(signal, "signal", display=display.data_window)
plot(skipped ? 1 : 0, "skipped", display=display.data_window)
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
    alert('{"action":"LONG","indicator":"4HRS","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"stop":' + str.tostring(sStop) + ',"target":' + str.tostring(sTarget) + ',"capped":' + (sCapped ? "true" : "false") + '}', alert.freq_once_per_bar_close)
if i_alertJson and shortSignal
    alert('{"action":"SHORT","indicator":"4HRS","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"stop":' + str.tostring(sStop) + ',"target":' + str.tostring(sTarget) + ',"capped":' + (sCapped ? "true" : "false") + '}', alert.freq_once_per_bar_close)

alertcondition(longSignal,                "4HRS Long setup",  "4H Range Scalper: LONG on {{ticker}} {{interval}} at {{close}} (closed back inside the range)")
alertcondition(shortSignal,               "4HRS Short setup", "4H Range Scalper: SHORT on {{ticker}} {{interval}} at {{close}} (closed back inside the range)")
alertcondition(longSignal or shortSignal, "4HRS Any setup",   "4H Range Scalper: setup on {{ticker}} {{interval}} at {{close}}")
alertcondition(rangeSetNow,               "4HRS Range set",   "4H Range Scalper: today's range is set on {{ticker}} {{interval}}")
alertcondition(state != 0 and state[1] == 0, "4HRS Breakout",  "4H Range Scalper: a candle closed outside the range on {{ticker}} {{interval}}, waiting for the re-entry")
````
