# Bollinger Squeeze Breakout: BBW + MFI Signals [forexobroker]

- url: https://www.tradingview.com/script/lCMzRRZY-Bollinger-Squeeze-Breakout-BBW-MFI-Signals-forexobroker/
- type: indicator
- pine_id: PUB;b8707bff7d5c4cb0ab8419229f25d11e
- version: 1.0

## Description

Bollinger Squeeze Breakout: BBW + MFI Signals [forexobroker]

🔶 OVERVIEW

Bollinger Squeeze Breakout trades the Bollinger Bands squeeze on the breakout candle itself: a quiet market with a flat middle line and the bands pressed together, then the bands expanding again and a candle closing outside a band, confirmed by the Money Flow Index. Every trade runs until a candle closes back through the middle line, and the last 100 results are counted in a table on the chart.

It is built for traders who want to see, on their own symbol and timeframe, what the squeeze breakout really did over the last 100 trades, wins and losses alike, before they trust it. A switch turns the MFI condition off, and a second setting replaces the middle-line exit with a fixed target, so both choices can be measured on the same chart.

🔶 HOW IT WORKS

1. The range. The middle line (20 SMA) is relatively flat: it moved less than 1 ATR(14) over the last 10 candles. It does not have to be perfectly flat.

2. The squeeze. The bands are close together. The Bollinger BandWidth (BBW = (upper - lower) / middle × 100, the same formula and settings as TradingView's Bollinger BandWidth) is within 20 % of its lowest value of the last 125 candles. A candle that is both flat and squeezed is a squeeze candle and gets a small yellow dot.

3. The expansion. The BBW rises: higher than on the candle before.

4. The direction. A candle closes outside a band: above the upper band for a long, below the lower band for a short. The last squeeze candle must lie within the 20 candles before it; one signal per squeeze.

5. The confirmation (Money Flow Index 14, both levels at 50). The MFI above 50 for a long, below 50 for a short.

🔶 TRADE MANAGEMENT

Entry at the close of the breakout candle. Default exit: the trade runs until a candle closes back through the middle line (a long: the first close below it; a short: the first close above it) and closes at that candle's close. While a trade is open, the middle line is drawn brighter, because it is the exit.

There is no fixed stop in this exit, so the risk unit R is the distance from the entry close to the middle line at entry. A trade that comes straight back ends near -1R; a move that keeps running ends at many R. The trade is drawn as a dashed red box (the 1R risk) and a box from the entry to the exit, green or red, with the result in R at the exit candle ("+3.4R", "-0.9R").

Optional "Fixed target" exit: the stop at the middle line at entry, the target at a reward multiple of that risk (2R by default). The stop is checked first when one candle touches both.

🔶 THE LOG

One trade at a time. A valid breakout that appears while a trade is still open is drawn faded and is not counted (switch "Allow overlapping trades" on to count every breakout). Every open trade is followed on closed candles to its exit.

The last N results (100 by default) feed the table: signals, wins, losses, win rate, total R, average win, average loss, best win streak, worst loss streak and days covered, followed by the live state: squeeze, BBW rising or falling, MFI side, the exit in use and the open trade.

NON-REPAINTING: every condition, every signal and every result is evaluated on barstate.isconfirmed; a breakout only looks at squeeze candles that closed before it; there is no request.security and no lookahead.

🔶 SETTINGS

Bollinger Bands
- Length (20) and standard deviations (2), TradingView's defaults.

Squeeze
- Squeeze: BBW within % of its low (20), Lowest BBW lookback (125 candles).
- Flat middle line: max move (1.0 × ATR) over (10 candles).
- Breakout within (20 candles after the squeeze).

Confirmation
- Require the MFI (default on), MFI length (14), MFI level (50).
- Allow overlapping trades (default off): one trade at a time.
- Take longs, Take shorts.

Exit
- Exit: Middle line (default) or Fixed target.
- Fixed target: reward ratio (default 2.0).
- Extend open trade boxes (bars).

Log
- Log size (default 100), Show log table, Table position, Table text size.

Visual
- Long, short, band, middle line and squeeze dot colours; show the bands; mark squeeze candles; BUY / SELL labels; +R / -R result labels; trades kept on chart; box fill transparency.

Alerts
- Send JSON alert() messages.

🔶 ALERTS

Four alertcondition hooks: BSB Long entry, BSB Short entry, BSB Any entry, BSB Exit. With "Send JSON alert() messages" on, every taken entry and every exit also fires an alert() once per bar close with a JSON body (action, ticker, timeframe, entry and the middle line; for an exit the side, the exit price and the result in R).

🔶 LIMITATIONS

- A squeeze says that a move is likely, not which way it goes. Many breakouts fall straight back through the middle line; the log's win rate and worst loss streak show how often that happened on your symbol.
- The middle-line exit cuts the losses near 1R and lets the winners run, so the strategy lives on a few large wins. Look at the average win against the average loss, not only at the win rate.
- The MFI needs volume. On symbols without volume data the table shows "no volume data" and no trade is taken while the MFI is required; switch "Require the MFI" off there.
- Results in the log are the script's own rules applied to closed candles: no spread, no commission, no slippage.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Bollinger Squeeze Breakout — the Bollinger Bands squeeze traded on the breakout candle, with its own log.
// (1) The range: the middle line (20 SMA) is relatively flat: it moved less than a set number of ATRs over the last
//     few candles.
// (2) The squeeze: the bands are close together. The Bollinger BandWidth (BBW = (upper - lower) / middle × 100, the
//     same formula and settings as TradingView's Bollinger BandWidth) is within a set percentage of its lowest value
//     of the last 125 candles. A candle that is flat AND squeezed is a squeeze candle (a small dot under it).
// (3) The expansion: the BBW rises (higher than on the candle before).
// (4) The direction: a candle closes outside a band. Above the upper band = LONG, below the lower band = SHORT.
//     The squeeze must lie within the last N candles; one signal per squeeze.
// (5) The confirmation: the Money Flow Index (14) above 50 for a long, below 50 for a short.
// EXIT (default): the trade runs until a candle closes back through the middle line (a long: the first close below
// it; a short: the first close above it) and closes at that candle's close. The risk unit R is the distance from the
// entry close to the middle line at entry, so a trade that comes straight back ends near -1R and a trend that runs
// ends at many R. Optional "Fixed target" exit: stop at the middle line at entry, target at a reward multiple of that
// risk, stop first when one candle touches both. One trade at a time; the last N results feed the on-chart log.
// Non-repainting: every condition and every trade result is evaluated on barstate.isconfirmed, there is no
// request.security and no lookahead.
indicator("Bollinger Squeeze Breakout: BBW + MFI Signals [forexobroker]", shorttitle="BSB [fob]", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_bands  = "Bollinger Bands"
string g_sq     = "Squeeze"
string g_conf   = "Confirmation"
string g_exit   = "Exit"
string g_ledger = "Log"
string g_vis    = "Visual"
string g_alert  = "Alerts"

// ─── INPUTS: BANDS ─────────────────────────────────────────────────────────────
int   i_len  = input.int(20, "Length", minval=2, maxval=500, group=g_bands, tooltip="20 and 2 are TradingView's default Bollinger Bands settings. Use the same settings in the Bollinger BandWidth indicator so its line matches the squeeze rule.")
float i_mult = input.float(2.0, "Standard deviations", minval=0.5, maxval=5.0, step=0.1, group=g_bands)

// ─── INPUTS: SQUEEZE ───────────────────────────────────────────────────────────
float i_sqPct    = input.float(20.0, "Squeeze: BBW within % of its low", minval=0.0, maxval=200.0, step=5.0, group=g_sq, tooltip="The bands count as squeezed while the BandWidth is at most this many percent above its lowest value of the lookback below (TradingView's BBW draws that low as 'Lowest Contraction').")
int   i_sqLook   = input.int(125, "Lowest BBW lookback (candles)", minval=20, maxval=1000, group=g_sq, tooltip="125 is the 'Lowest Contraction' length of TradingView's Bollinger BandWidth.")
float i_flatAtr  = input.float(1.0, "Flat middle line: max move (× ATR)", minval=0.1, maxval=10.0, step=0.1, group=g_sq, tooltip="The middle line is 'relatively flat' when it moved less than this many ATR(14) over the candles below. It does not have to be perfectly flat.")
int   i_flatLen  = input.int(10, "Flat middle line: over (candles)", minval=2, maxval=100, group=g_sq)
int   i_sqWindow = input.int(20, "Breakout within (candles after the squeeze)", minval=1, maxval=200, group=g_sq, tooltip="The breakout candle must come within this many candles of the last squeeze candle. One signal per squeeze.")

// ─── INPUTS: CONFIRMATION ──────────────────────────────────────────────────────
bool  i_reqMfi = input.bool(true, "Require the MFI", group=g_conf, tooltip="ON (default): a long needs the Money Flow Index above the level below, a short below it. OFF: the MFI is ignored (the squeeze breakout on its own); the log counts only the entries the settings let through.")
int   i_mfiLen = input.int(14, "MFI length", minval=2, maxval=200, group=g_conf)
float i_mfiMid = input.float(50, "MFI level", minval=1, maxval=99, group=g_conf, tooltip="Both MFI levels moved to 50: above = bullish, below = bearish.")
bool  i_allowOverlap = input.bool(false, "Allow overlapping trades", group=g_conf, tooltip="OFF (default): one trade at a time. A valid breakout that appears while a trade is still open is drawn faded and is not counted in the log.")
bool  i_longs  = input.bool(true, "Take longs", group=g_conf)
bool  i_shorts = input.bool(true, "Take shorts", group=g_conf)

// ─── INPUTS: EXIT ──────────────────────────────────────────────────────────────
string i_exit = input.string("Middle line", "Exit", options=["Middle line", "Fixed target"], group=g_exit, tooltip="Middle line (default): close the trade on the first candle that closes back through the middle line. Fixed target: stop at the middle line at entry, target at the reward ratio below; the stop is checked first when one candle touches both.")
float i_rr    = input.float(2.0, "Fixed target: reward ratio", minval=0.5, maxval=10.0, step=0.5, group=g_exit, tooltip="Used only with the Fixed target exit.")
int   i_extendBars = input.int(30, "Extend open trade boxes (bars)", minval=5, maxval=200, group=g_exit)

// ─── INPUTS: LOG ───────────────────────────────────────────────────────────────
int    i_ledgerN   = input.int(100, "Log size (last N signals)", minval=10, maxval=500, group=g_ledger, tooltip="The rolling number of completed trades the table summarises. The '100 trades' test of the video is this table at 100.")
bool   i_showTable = input.bool(true, "Show log table", group=g_ledger)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_ledger)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_ledger)

// ─── INPUTS: VISUAL ────────────────────────────────────────────────────────────
color i_bullCol    = input.color(#00E5A8, "Long colour", group=g_vis)
color i_bearCol    = input.color(#FF3B5C, "Short colour", group=g_vis)
color i_bandCol    = input.color(#4DA3FF, "Band colour", group=g_vis)
color i_basisCol   = input.color(#FF9D2E, "Middle line colour", group=g_vis)
color i_sqCol      = input.color(#F5C542, "Squeeze dot colour", group=g_vis)
bool  i_showBands  = input.bool(true, "Show the Bollinger Bands", group=g_vis)
bool  i_showSq     = input.bool(true, "Mark squeeze candles", group=g_vis, tooltip="A small dot under every candle that is both flat and squeezed.")
bool  i_showLabels = input.bool(true, "Show BUY / SELL labels", group=g_vis)
bool  i_showResult = input.bool(true, "Show +R / -R result labels", group=g_vis)
int   i_keepTrades = input.int(120, "Trades kept on chart", minval=1, maxval=200, group=g_vis, tooltip="How many past trades keep their boxes and labels before the oldest are removed.")
int   i_boxFill    = input.int(78, "Box fill transparency", minval=50, maxval=95, group=g_vis)

// ─── INPUTS: ALERTS ────────────────────────────────────────────────────────────
bool i_alertJson = input.bool(true, "Send JSON alert() messages", group=g_alert, tooltip="Besides the alertcondition hooks, fire an alert() with a JSON body on every entry and every exit (once per bar close). Useful for webhooks.")

color c_white  = #FFFFFF
color c_dark   = #0B0F14
color c_purple = #A259FF
color c_grey   = #9AA4AE

// ─── BANDS, BANDWIDTH, MFI ─────────────────────────────────────────────────────
bool  confirmed = barstate.isconfirmed
float basis = ta.sma(close, i_len)
float dev   = i_mult * ta.stdev(close, i_len)
float upper = basis + dev
float lower = basis - dev
float bbw   = basis != 0 ? (upper - lower) / basis * 100 : na
float bbwLow = ta.lowest(bbw, i_sqLook)
float atrV  = ta.atr(14)
float mfiV  = ta.mfi(hlc3, i_mfiLen)
bool  ready = not na(basis) and not na(bbw[1]) and not na(bbwLow) and not na(atrV) and not na(basis[i_flatLen])

bool  flat     = ready and math.abs(basis - basis[i_flatLen]) <= i_flatAtr * atrV
bool  squeezed = ready and bbw <= bbwLow * (1 + i_sqPct / 100.0)
bool  sqBar    = flat and squeezed
bool  bbwUp    = ready and bbw > bbw[1]
bool  mfiNa    = na(mfiV)
bool  mfiUp    = not mfiNa and mfiV > i_mfiMid
bool  mfiDn    = not mfiNa and mfiV < i_mfiMid

// ─── SQUEEZE STATE ─────────────────────────────────────────────────────────────
var int lastSq = na            // bar of the last squeeze candle BEFORE this one
var int usedSq = na            // the squeeze already spent on a signal
int sqAge = na(lastSq) ? na : bar_index - lastSq
bool sqArmed = not na(lastSq) and sqAge <= i_sqWindow and (na(usedSq) or lastSq > usedSq)

// ─── OPEN TRADE AND LOG STATE ──────────────────────────────────────────────────
var int   tDir = 0
var float tEntry = na
var float tRiskLvl = na        // the middle line at entry: the R unit and the fixed-target stop
var float tTarget = na
var int   tBar = na
var box   tRiskBox = na
var box   tTargetBox = na
var line  tEntryLine = na
var array<box>   tBoxes = array.new<box>()
var array<label> tLabels = array.new<label>()
var array<line>  tLines = array.new<line>()

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
        while array.size(tBoxes) > i_keepTrades * 3
            box.delete(array.shift(tBoxes))
    if array.size(tLabels) > 0
        while array.size(tLabels) > i_keepTrades * 3
            label.delete(array.shift(tLabels))
    if array.size(tLines) > 0
        while array.size(tLines) > i_keepTrades
            line.delete(array.shift(tLines))

bool fixedExit = i_exit == "Fixed target"

// Result of the open trade on this confirmed bar.
float resultR = na
float exitLevel = na
if confirmed and tDir != 0 and bar_index > tBar
    float risk = math.abs(tEntry - tRiskLvl)
    if fixedExit
        // stop checked BEFORE the target: when one candle touches both, the loss is booked
        bool stopHit = tDir == 1 ? low <= tRiskLvl : high >= tRiskLvl
        bool targetHit = tDir == 1 ? high >= tTarget : low <= tTarget
        if stopHit
            resultR := -1.0
            exitLevel := tRiskLvl
        else if targetHit
            resultR := i_rr
            exitLevel := tTarget
    else
        bool back = tDir == 1 ? close < basis : close > basis
        if back
            exitLevel := close
            resultR := math.round(tDir * (close - tEntry) / risk, 2)
    if not na(resultR)
        f_pushResult(resultR, time)
        bool win = resultR > 0
        if fixedExit
            if not na(tRiskBox)
                box.set_right(tRiskBox, bar_index)
                box.set_right(tTargetBox, bar_index)
        else
            if not na(tRiskBox)
                box.set_right(tRiskBox, bar_index)
            box rb = box.new(tBar, math.max(tEntry, exitLevel), bar_index, math.min(tEntry, exitLevel), bgcolor=color.new(win ? i_bullCol : i_bearCol, i_boxFill), border_color=color.new(win ? i_bullCol : i_bearCol, 35), border_width=1)
            array.push(tBoxes, rb)
        if not na(tEntryLine)
            line.set_x2(tEntryLine, bar_index)
        if i_showResult
            string txt = (resultR > 0 ? "+" : "") + str.tostring(resultR, "#.#") + "R"
            label rl = label.new(bar_index, exitLevel, txt, color=color.new(win ? i_bullCol : i_bearCol, 0), textcolor=win ? c_dark : c_white, style=tDir == 1 ? (win ? label.style_label_down : label.style_label_up) : (win ? label.style_label_up : label.style_label_down), size=size.small)
            array.push(tLabels, rl)
        if i_alertJson
            alert('{"action":"EXIT","indicator":"BSB","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","side":"' + (tDir == 1 ? "LONG" : "SHORT") + '","exit":' + str.tostring(exitLevel) + ',"r":' + str.tostring(resultR) + '}', alert.freq_once_per_bar_close)
        tDir := 0
        tEntry := na
        tRiskLvl := na
        tTarget := na
        tBar := na
        tRiskBox := na
        tTargetBox := na
        tEntryLine := na
        f_trimDrawings()

if tDir != 0
    if not na(tRiskBox)
        box.set_right(tRiskBox, bar_index + (fixedExit ? i_extendBars : 0))
    if not na(tTargetBox)
        box.set_right(tTargetBox, bar_index + i_extendBars)
    if not na(tEntryLine)
        line.set_x2(tEntryLine, bar_index)

// ─── THE SIGNAL ────────────────────────────────────────────────────────────────
int   signal = 0
bool  skipped = false
float sEntry = na
float sRiskLvl = na
float sTarget = na

if confirmed and ready
    bool mfiPassL = not i_reqMfi or mfiUp
    bool mfiPassS = not i_reqMfi or mfiDn
    bool okL = i_longs and sqArmed and bbwUp and close > upper and mfiPassL
    bool okS = i_shorts and sqArmed and bbwUp and close < lower and mfiPassS
    if okL
        signal := 1
    else if okS
        signal := -1
    if signal != 0
        usedSq := lastSq               // one signal per squeeze

if signal != 0
    float risk = math.max(math.abs(close - basis), syminfo.mintick * 5)
    sEntry := close
    sRiskLvl := signal == 1 ? close - risk : close + risk
    sTarget := fixedExit ? (signal == 1 ? close + risk * i_rr : close - risk * i_rr) : na
    if i_allowOverlap or tDir == 0
        tDir := signal
        tEntry := sEntry
        tRiskLvl := sRiskLvl
        tTarget := sTarget
        tBar := bar_index
        tRiskBox := box.new(bar_index, math.max(sEntry, sRiskLvl), bar_index + (fixedExit ? i_extendBars : 1), math.min(sEntry, sRiskLvl), bgcolor=color.new(i_bearCol, i_boxFill + 6), border_color=color.new(i_bearCol, 45), border_width=1)
        array.push(tBoxes, tRiskBox)
        if fixedExit
            tTargetBox := box.new(bar_index, math.max(sEntry, sTarget), bar_index + i_extendBars, math.min(sEntry, sTarget), bgcolor=color.new(i_bullCol, i_boxFill), border_color=color.new(i_bullCol, 35), border_width=1)
            array.push(tBoxes, tTargetBox)
        tEntryLine := line.new(bar_index, sEntry, bar_index + 1, sEntry, color=color.new(c_white, 15), width=1)
        array.push(tLines, tEntryLine)
        if i_showLabels
            string tip = (signal == 1 ? "LONG" : "SHORT") + " · close " + (signal == 1 ? "above the upper" : "below the lower") + " band after a squeeze " + str.tostring(sqAge) + " candle(s) ago, BBW rising" + (i_reqMfi ? (signal == 1 ? ", MFI above " : ", MFI below ") + str.tostring(i_mfiMid, "#") : "") + "\nEntry " + str.tostring(sEntry, format.mintick) + "\nRisk (to the middle line) " + str.tostring(risk, format.mintick) + (fixedExit ? "\nStop " + str.tostring(sRiskLvl, format.mintick) + "\nTarget " + str.tostring(sTarget, format.mintick) + " (" + str.tostring(i_rr, "#.#") + "R)" : "\nExit: the first close back through the middle line")
            label sl = label.new(bar_index, signal == 1 ? low : high, signal == 1 ? "BUY" : "SELL", color=color.new(signal == 1 ? i_bullCol : i_bearCol, 0), textcolor=signal == 1 ? c_dark : c_white, style=signal == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=tip)
            array.push(tLabels, sl)
        f_trimDrawings()
    else
        skipped := true
        if i_showLabels
            label sk = label.new(bar_index, signal == 1 ? low : high, (signal == 1 ? "buy" : "sell") + " · not taken", color=color.new(signal == 1 ? i_bullCol : i_bearCol, 70), textcolor=color.new(c_white, 20), style=signal == 1 ? label.style_label_up : label.style_label_down, size=size.tiny, tooltip="A trade is still open (one trade at a time)")
            array.push(tLabels, sk)
            f_trimDrawings()

// the squeeze state moves on AFTER the signal check, so a breakout always looks at earlier squeeze candles
if confirmed and sqBar
    lastSq := bar_index

bool longSignal  = signal == 1 and not skipped
bool shortSignal = signal == -1 and not skipped

// ─── LOG STATISTICS ────────────────────────────────────────────────────────────
int   lN = array.size(ledgerR)
int   lWins = 0
int   lLosses = 0
float lTotal = 0.0
float lWinSum = 0.0
float lLossSum = 0.0
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
            lWinSum += r
            runW += 1
            runL := 0
        else
            lLosses += 1
            lLossSum += r
            runL += 1
            runW := 0
        lBest := math.max(lBest, runW)
        lWorst := math.max(lWorst, runL)
float lWinRate = lN > 0 ? 100.0 * lWins / lN : na
float lAvgWin  = lWins > 0 ? lWinSum / lWins : na
float lAvgLoss = lLosses > 0 ? lLossSum / lLosses : na
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

f_r(float _v) =>
    na(_v) ? "-" : (_v >= 0 ? "+" : "") + str.tostring(_v, "#.#") + "R"

if i_showTable and barstate.islast
    var table led = table.new(f_pos(i_tablePos), 2, 16, bgcolor=color.new(c_dark, 8), border_color=color.new(c_purple, 45), border_width=1, frame_color=color.new(c_purple, 15), frame_width=2)
    string ts  = i_tableSize == "Large" ? size.normal : i_tableSize == "Small" ? size.tiny : size.small
    string tsH = i_tableSize == "Large" ? size.large : i_tableSize == "Small" ? size.small : size.normal
    color lab = c_grey
    table.cell(led, 0, 0, "BOLLINGER SQUEEZE BREAKOUT", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
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
    table.cell(led, 1, 5, f_r(lTotal), text_color=lTotal >= 0 ? i_bullCol : i_bearCol, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 6, "Average win", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 6, f_r(lAvgWin), text_color=i_bullCol, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 7, "Average loss", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 7, f_r(lAvgLoss), text_color=i_bearCol, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 8, "Best win streak", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 8, str.tostring(lBest), text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 9, "Worst loss streak", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 9, str.tostring(lWorst), text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 10, "Days covered", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 10, str.tostring(lDays), text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 11, "Squeeze", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 11, sqBar ? "squeezed now" : sqArmed ? "last one " + str.tostring(sqAge) + " candle(s) ago" : "none", text_color=sqBar or sqArmed ? i_sqCol : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 12, "BBW", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 12, bbwUp ? "rising · bands expanding" : "falling · bands contracting", text_color=bbwUp ? c_white : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 13, "MFI vs " + str.tostring(i_mfiMid, "#"), text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 13, not i_reqMfi ? "not required" : mfiNa ? "no volume data" : mfiUp ? "above · longs" : mfiDn ? "below · shorts" : "-", text_color=mfiUp and i_reqMfi ? i_bullCol : mfiDn and i_reqMfi ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 14, "Exit", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 14, fixedExit ? "fixed " + str.tostring(i_rr, "#.#") + "R target" : "close back through the middle line", text_color=c_white, text_size=ts, text_halign=text.align_right)
    table.cell(led, 0, 15, "Open trade", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 15, tDir == 1 ? "LONG from " + str.tostring(tEntry, format.mintick) : tDir == -1 ? "SHORT from " + str.tostring(tEntry, format.mintick) : "none", text_color=tDir == 1 ? i_bullCol : tDir == -1 ? i_bearCol : lab, text_size=ts, text_halign=text.align_right)

// ─── CHART PLOTS ───────────────────────────────────────────────────────────────
pU = plot(i_showBands ? upper : na, "Upper band", color=color.new(i_bandCol, 20), linewidth=1)
pL = plot(i_showBands ? lower : na, "Lower band", color=color.new(i_bandCol, 20), linewidth=1)
plot(i_showBands ? basis : na, "Middle line", color=tDir != 0 ? i_basisCol : color.new(i_basisCol, 35), linewidth=2)
fill(pU, pL, color=color.new(i_bandCol, 93), title="Band fill")
plotshape(i_showSq and sqBar, "Squeeze candle", style=shape.circle, location=location.belowbar, color=color.new(i_sqCol, 0), size=size.tiny)

// ─── DATA-WINDOW PLOTS (read by tools, hidden on the chart) ────────────────────
plot(basis, "basis", display=display.data_window)
plot(upper, "upper", display=display.data_window)
plot(lower, "lower", display=display.data_window)
plot(bbw, "bbw", display=display.data_window)
plot(bbwLow, "bbwLow", display=display.data_window)
plot(flat ? 1 : 0, "flat", display=display.data_window)
plot(sqBar ? 1 : 0, "squeeze", display=display.data_window)
plot(mfiV, "mfi", display=display.data_window)
plot(signal, "signal", display=display.data_window)
plot(skipped ? 1 : 0, "skipped", display=display.data_window)
plot(signal != 0 ? sEntry : na, "entry", display=display.data_window)
plot(signal != 0 ? sRiskLvl : na, "riskLevel", display=display.data_window)
plot(signal != 0 ? sTarget : na, "target", display=display.data_window)
plot(signal != 0 ? sqAge : na, "sqAge", display=display.data_window)
plot(resultR, "result", display=display.data_window)
plot(exitLevel, "exitLevel", display=display.data_window)
plot(tDir, "openDir", display=display.data_window)
plot(lN, "ledgerN", display=display.data_window)
plot(ledgerWins, "ledgerWins", display=display.data_window)
plot(ledgerLosses, "ledgerLosses", display=display.data_window)
plot(ledgerTotalR, "ledgerTotalR", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
if i_alertJson and longSignal
    alert('{"action":"LONG","indicator":"BSB","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"middle":' + str.tostring(basis) + '}', alert.freq_once_per_bar_close)
if i_alertJson and shortSignal
    alert('{"action":"SHORT","indicator":"BSB","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sEntry) + ',"middle":' + str.tostring(basis) + '}', alert.freq_once_per_bar_close)

alertcondition(longSignal,                "BSB Long entry",  "Bollinger Squeeze Breakout: LONG on {{ticker}} {{interval}} at {{close}}")
alertcondition(shortSignal,               "BSB Short entry", "Bollinger Squeeze Breakout: SHORT on {{ticker}} {{interval}} at {{close}}")
alertcondition(longSignal or shortSignal, "BSB Any entry",   "Bollinger Squeeze Breakout: entry on {{ticker}} {{interval}} at {{close}}")
alertcondition(not na(resultR),           "BSB Exit",        "Bollinger Squeeze Breakout: trade closed on {{ticker}} {{interval}} at {{close}}")
````
