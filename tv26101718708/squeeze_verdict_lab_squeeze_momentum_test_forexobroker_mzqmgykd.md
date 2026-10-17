# Squeeze Verdict Lab: Squeeze Momentum Test [forexobroker]

- url: https://www.tradingview.com/script/mzqmGyKd-Squeeze-Verdict-Lab-Squeeze-Momentum-Test-forexobroker/
- type: indicator
- pine_id: PUB;b1267821a1204671a6331ea10ec57f83
- version: 2.0

## Description

Squeeze Verdict Lab: Squeeze Momentum Test [forexobroker]

🔶 OVERVIEW

Squeeze Verdict Lab puts the Squeeze Momentum Indicator by LazyBear on trial on your own chart. It draws LazyBear's indicator with the same inputs and formulas, trades the three ways traders use it side by side, and logs every trade of each rule twice: once on the code as TradingView shows it, and once with the typo LazyBear flagged in 2014 fixed. One table shows all six logs over the last N trades, so you can see which rule, on which code, holds up on your market and timeframe.

Credit: the indicator part is the open-source "Squeeze Momentum Indicator [LazyBear]" (after John Carter's TTM Squeeze), reproduced with the same inputs and formulas. The rule logs, the two-code comparison, the stops and the table are the original work described below.

🔶 THE INDICATOR AND THE TYPO

- Squeeze ON (black cross on the zero line): the Bollinger Bands (20) are inside the Keltner Channel (20, 1.5 × true range). The market is coiling.
- Squeeze released (grey cross): the bands are back outside the channel. Neither: blue cross. (On a dark chart the script draws these two orange and white by default; see Cross colours.)
- The histogram is the momentum: a linear regression (20) of the close minus the average of the 20-candle midrange and the 20 SMA. Bright green: above zero and rising. Dark green: above zero and falling. Bright red: below zero and falling. Dark red: below zero and rising.
- The typo: the code TradingView shows builds the Bollinger width with the KC multiplier (1.5) instead of the BB multiplier, so the "BB MultFactor" input does nothing. LazyBear's note of 29 Sep 2014 says to use the updated source instead. This script computes the squeeze both ways: AS SHOWN (1.5) and FIXED (the BB MultFactor, 2.0 by default). The narrower bands of the typo put the market "in a squeeze" far more often.

🔶 THE THREE RULES

A. The creator's rule: the first grey cross after a black cross, in the direction of the momentum (histogram above zero = long, below = short). Exit at the close of the first candle whose histogram colour differs from the entry candle's.

B. The classic rule: the first grey cross after a black cross on a bright bar (bright green = long, bright red = short). Target 2R.

C. The improved rule: rule B, plus at least 6 black crosses in a row before the grey one, and the close above the 200 SMA for a long, below it for a short. Target 2R.

Every rule's stop sits at the 10-candle swing (the lowest low for a long, the highest high for a short, the signal candle included) and is never closer than 0.5 × ATR(14). That distance is 1R. One trade at a time per log. Every entry, stop and exit is evaluated on closed candles; when one candle touches both the stop and the target, the stop counts first.

NON-REPAINTING: everything is evaluated on barstate.isconfirmed; there is no request.security and no lookahead.

🔶 THE TABLE

Six rows (A, B and C, each as shown and fixed) over the last N trades of each log (100 by default): trades, wins, win rate, total R and the number of days the log covers. The log you choose is also drawn on the price chart: entry, stop, target and the result of every trade.

🔶 SETTINGS

Squeeze Momentum (LazyBear)
- BB length (20), BB MultFactor (2.0, used by the FIXED code only), KC length (20), KC MultFactor (1.5), use true range (on).
- Crosses drawn in the pane: as TradingView shows it, or the fixed code.

Rules
- Rule C: black crosses in a row before the grey one (6), trend SMA length (200).
- Which log is drawn on the chart; take longs, take shorts.

Stop and target
- Swing lookback (10), minimum stop distance (0.5 × ATR 14), target for rules B and C (2R), how far open trade boxes extend.

Log
- Log size (the last 100 trades per log), table on or off, position and text size.

Visual
- Cross colours: Auto (default), LazyBear (black / grey) or High contrast (orange / white). Auto reads the chart background: on a dark chart the squeeze-on crosses are drawn orange and the released ones white, because black crosses cannot be seen there; on a light chart they stay black and grey as in LazyBear's script.
- Histogram colours, trade colours, trades kept on the chart, box transparency.

🔶 ALERTS

Two alertcondition hooks (long entry, short entry) for the drawn log. With JSON alerts on, every entry and exit of the drawn log also fires an alert() once per bar close with a JSON body (action, log, ticker, timeframe, entry, stop or result).

🔶 LIMITATIONS

- Results depend on the market, the timeframe, the code version and the settings; the table shows them on your own chart, losses included.
- The table counts the script's own rules on closed candles: no spread, no commission, no slippage, and the stop is counted before the target on a candle that touches both.
- The last-N window covers different calendar spans on different timeframes (two weeks of 5-minute candles can hold as many trades as two years of 1-hour candles).
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

🔶 RELEASE NOTES

v1.0 — Initial release. LazyBear's Squeeze Momentum Indicator computed as TradingView shows it and with the 2014 typo fixed, three rules (the creator's, the classic, the improved) logged on both codes, a six-row comparison table, trades drawn on the chart, two alert hooks and JSON alerts.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Squeeze Verdict Lab — LazyBear's Squeeze Momentum Indicator (the most-liked community script on
// TradingView) and the three ways traders use it, each logged twice: on the code TradingView shows, and on the code
// with LazyBear's own 2014 typo fix.
// THE INDICATOR (LazyBear, "Squeeze Momentum Indicator [LazyBear]", open source, same inputs and formulas):
//   Bollinger Bands (20) inside the Keltner Channel (20, 1.5 × true range) = SQUEEZE ON (black cross on the zero line).
//   Bands outside the channel = SQUEEZE OFF, the squeeze released (grey cross). Neither = blue cross.
//   Momentum histogram = linear regression (20) of close minus the average of the 20-candle midrange and the 20 SMA.
//   Bright green: above zero and rising. Dark green: above zero, falling. Bright red: below zero and falling.
//   Dark red: below zero, rising.
//   THE TYPO: the code TradingView shows builds the Bollinger width with the KC multiplier (dev = multKC × stdev), so
//   the "BB MultFactor" input does nothing. LazyBear's note of 29 Sep 2014: "Fixed a typo in the code where BB
//   multiplier was stuck at 1.5 ... Use the updated source instead of what TV shows below." This script computes the
//   squeeze both ways: AS SHOWN (1.5) and FIXED (the BB MultFactor, 2.0).
// THE RULES:
//   A  Creator's rule (LazyBear's notes, after John Carter): the first grey cross after a black cross, in the direction
//      of the momentum (above zero = LONG, below = SHORT); exit at the close of the first candle whose histogram
//      colour differs from the entry candle's. A protective stop sits at the 10-candle swing and is the risk unit R.
//   B  The classic rule (as commonly taught): the first grey cross after a black cross with a BRIGHT bar (bright green = LONG,
//      bright red = SHORT); stop at the 10-candle swing, target 2R.
//   C  The "improved" rule (a popular tutorial variant): B + at least 6 black crosses in a row before the grey one + close
//      above the 200 SMA for a long, below it for a short.
//   The stop is never closer than 0.5 × ATR(14) (a stop a few ticks away cannot be filled and turns one trade into
//   20R or more). Stops are checked first when one candle touches the stop and the target. One trade at a time per log.
// Non-repainting: everything is evaluated on barstate.isconfirmed; no request.security, no lookahead.
indicator("Squeeze Verdict Lab: Squeeze Momentum Test [forexobroker]", shorttitle="SVL [fob]", overlay=false, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_ind    = "Squeeze Momentum (LazyBear)"
string g_rule   = "Rules"
string g_exit   = "Stop and target"
string g_ledger = "Log"
string g_vis    = "Visual"
string g_alert  = "Alerts"

// ─── INPUTS: INDICATOR ─────────────────────────────────────────────────────────
int   i_bbLen   = input.int(20, "BB Length", minval=2, maxval=500, group=g_ind)
float i_bbMult  = input.float(2.0, "BB MultFactor (used by the FIXED code)", minval=0.1, maxval=10.0, step=0.1, group=g_ind, tooltip="The code TradingView shows ignores this input (the typo); the FIXED code uses it, as in LazyBear's updated source.")
int   i_kcLen   = input.int(20, "KC Length", minval=2, maxval=500, group=g_ind)
float i_kcMult  = input.float(1.5, "KC MultFactor", minval=0.1, maxval=10.0, step=0.1, group=g_ind)
bool  i_useTR   = input.bool(true, "Use TrueRange (KC)", group=g_ind)
string i_dotsOf = input.string("As TradingView shows it", "Crosses drawn in the pane", options=["As TradingView shows it", "Fixed code"], group=g_ind)

// ─── INPUTS: RULES ─────────────────────────────────────────────────────────────
int    i_minDots = input.int(6, "Rule C: black crosses in a row before the grey one", minval=1, maxval=100, group=g_rule)
int    i_maLen   = input.int(200, "Rule C: trend SMA length", minval=2, maxval=1000, group=g_rule)
string i_show    = input.string("A Creator · as shown", "Log drawn on the chart", options=["A Creator · as shown", "A Creator · fixed", "B Classic · as shown", "B Classic · fixed", "C Improved · as shown", "C Improved · fixed"], group=g_rule, tooltip="All six logs are in the table; this one draws its trades on the price chart.")
bool   i_longs   = input.bool(true, "Take longs", group=g_rule)
bool   i_shorts  = input.bool(true, "Take shorts", group=g_rule)

// ─── INPUTS: EXIT ──────────────────────────────────────────────────────────────
int   i_swingLen   = input.int(10, "Swing stop: lookback (candles)", minval=2, maxval=200, group=g_exit, tooltip="Stop below the lowest low (long) or above the highest high (short) of this many candles, the signal candle included. It is the risk unit R of every rule.")
float i_minAtr     = input.float(0.5, "Minimum stop distance (× ATR 14)", minval=0.0, maxval=5.0, step=0.1, group=g_exit, tooltip="A swing a few ticks from the entry would give a stop no fill can respect and results of 20R or more from one trade. The stop is never closer than this many ATR(14).")
float i_rr         = input.float(2.0, "Rules B and C: target (reward ratio)", minval=0.5, maxval=10.0, step=0.5, group=g_exit)
int   i_extendBars = input.int(30, "Extend open trade boxes (bars)", minval=5, maxval=200, group=g_exit)

// ─── INPUTS: LOG ───────────────────────────────────────────────────────────────
int    i_ledgerN   = input.int(100, "Log size (last N trades per log)", minval=10, maxval=500, group=g_ledger)
bool   i_showTable = input.bool(true, "Show log table", group=g_ledger)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_ledger)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_ledger)

// ─── INPUTS: VISUAL ────────────────────────────────────────────────────────────
color i_lime    = input.color(color.lime, "Bright green", group=g_vis)
color i_green   = input.color(color.green, "Dark green", group=g_vis)
color i_red     = input.color(color.red, "Bright red", group=g_vis)
color i_maroon  = input.color(color.maroon, "Dark red", group=g_vis)
string i_crossCol = input.string("Auto", "Cross colours", options=["Auto", "LazyBear (black / grey)", "High contrast (orange / white)"], group=g_vis, tooltip="LazyBear's black squeeze crosses cannot be seen on a dark chart. Auto draws them orange (squeeze on) and white (fired) when the chart background is dark, and black / grey on a light chart.")
color i_bullCol = input.color(#00E5A8, "Long trade colour", group=g_vis)
color i_bearCol = input.color(#FF3B5C, "Short trade colour", group=g_vis)
bool  i_showTrades = input.bool(true, "Draw trades on the price chart", group=g_vis)
int   i_keepTrades = input.int(120, "Trades kept on chart", minval=1, maxval=200, group=g_vis)
int   i_boxFill    = input.int(78, "Box fill transparency", minval=50, maxval=95, group=g_vis)

// ─── INPUTS: ALERTS ────────────────────────────────────────────────────────────
bool i_alertJson = input.bool(true, "Send JSON alert() messages", group=g_alert)

color c_white  = #FFFFFF
color c_dark   = #0B0F14
color c_purple = #A259FF
color c_grey   = #9AA4AE

// ─── LAZYBEAR'S SQUEEZE MOMENTUM, BOTH WAYS ────────────────────────────────────
bool  confirmed = barstate.isconfirmed
float src     = close
float basis   = ta.sma(src, i_bbLen)
float sd      = ta.stdev(src, i_bbLen)
float ma      = ta.sma(src, i_kcLen)
float rng     = i_useTR ? ta.tr : (high - low)
float rangema = ta.sma(rng, i_kcLen)
float upperKC = ma + rangema * i_kcMult
float lowerKC = ma - rangema * i_kcMult
// as TradingView shows it (the typo): dev = multKC × stdev
float upP = basis + i_kcMult * sd
float loP = basis - i_kcMult * sd
// fixed: dev = BB MultFactor × stdev
float upF = basis + i_bbMult * sd
float loF = basis - i_bbMult * sd
bool  onP  = (loP > lowerKC) and (upP < upperKC)
bool  offP = (loP < lowerKC) and (upP > upperKC)
bool  onF  = (loF > lowerKC) and (upF < upperKC)
bool  offF = (loF < lowerKC) and (upF > upperKC)
float val     = ta.linreg(src - math.avg(math.avg(ta.highest(high, i_kcLen), ta.lowest(low, i_kcLen)), ta.sma(close, i_kcLen)), i_kcLen, 0)
float valPrev = nz(val[1])
// 0 bright green, 1 dark green, 2 bright red, 3 dark red (LazyBear's bcolor)
int   colIdx  = val > 0 ? (val > valPrev ? 0 : 1) : (val < valPrev ? 2 : 3)
color bcolor  = colIdx == 0 ? i_lime : colIdx == 1 ? i_green : colIdx == 2 ? i_red : i_maroon
bool  showFixed = i_dotsOf == "Fixed code"
bool  dOn  = showFixed ? onF : onP
bool  dOff = showFixed ? offF : offP
bool  darkBg  = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3.0 < 128
bool  hiCon   = i_crossCol == "High contrast (orange / white)" or (i_crossCol == "Auto" and darkBg)
color scolor  = (not dOn and not dOff) ? color.blue : dOn ? (hiCon ? #FF9800 : color.black) : (hiCon ? color.white : color.gray)
float sma200  = ta.sma(close, i_maLen)
bool  ready   = not na(val) and not na(val[1]) and not na(basis) and not na(rangema)

// black crosses in a row up to the PREVIOUS candle, per code
var int runP = 0
var int runF = 0
int runBeforeP = runP
int runBeforeF = runF
if confirmed
    runP := onP ? runP + 1 : 0
    runF := onF ? runF + 1 : 0
bool firedP = ready and offP and runBeforeP > 0          // the first grey cross right after a black cross
bool firedF = ready and offF and runBeforeF > 0

// ─── TRADE LOGS ────────────────────────────────────────────────────────────────
// six logs: index = rule * 2 + code  (rule 0 A Creator, 1 B Classic, 2 C Improved; code 0 as shown, 1 fixed)
type Book
    int   dir = 0
    float entry
    float stop
    float target
    int   bar
    int   col
    array<float> res
    array<int>   tms

var array<Book> books = array.new<Book>()
if barstate.isfirst
    for i = 0 to 5
        array.push(books, Book.new(0, na, na, na, na, na, array.new<float>(), array.new<int>()))

int showIdx = switch i_show
    "A Creator · as shown"  => 0
    "A Creator · fixed"     => 1
    "B Classic · as shown"  => 2
    "B Classic · fixed"     => 3
    "C Improved · as shown" => 4
    => 5

var box  dRisk = na
var box  dTarget = na
var array<box>   dBoxes = array.new<box>()
var array<label> dLabels = array.new<label>()

f_trim() =>
    if array.size(dBoxes) > 0
        while array.size(dBoxes) > i_keepTrades * 2
            box.delete(array.shift(dBoxes))
    if array.size(dLabels) > 0
        while array.size(dLabels) > i_keepTrades * 2
            label.delete(array.shift(dLabels))

// settle the open trade of a log on this confirmed bar -> [result R, exit price]
f_settle(Book b, int rule) =>
    float r = na
    float x = na
    if b.dir != 0 and bar_index > b.bar
        float risk = math.abs(b.entry - b.stop)
        bool stopHit = b.dir == 1 ? low <= b.stop : high >= b.stop
        if stopHit
            r := -1.0
            x := b.stop
        else if rule == 0
            if colIdx != b.col                          // the momentum colour changed: exit at this close
                x := close
                r := math.round(b.dir * (close - b.entry) / risk, 2)
        else
            bool targetHit = b.dir == 1 ? high >= b.target : low <= b.target
            if targetHit
                r := i_rr
                x := b.target
        if not na(r)
            array.push(b.res, r)
            array.push(b.tms, time)
            if array.size(b.res) > 0
                while array.size(b.res) > i_ledgerN
                    array.shift(b.res)
                    array.shift(b.tms)
            b.dir := 0
    [r, x]

f_open(Book b, int dir, float e, float s, float t) =>
    b.dir := dir
    b.entry := e
    b.stop := s
    b.target := t
    b.bar := bar_index
    b.col := colIdx

array<float> res = array.from(float(na), na, na, na, na, na)
if confirmed and array.size(books) == 6
    for i = 0 to 5
        Book b = array.get(books, i)
        int dPrev = b.dir
        [r, x] = f_settle(b, int(i / 2))
        array.set(res, i, r)
        if i == showIdx and i_showTrades and not na(r)
            bool win = r > 0
            if not na(dRisk)
                box.set_right(dRisk, bar_index)
                box.set_right(dTarget, bar_index)
            label rl = label.new(bar_index, x, (win ? "+" : "") + str.tostring(r, "#.#") + "R", color=win ? i_bullCol : i_bearCol, textcolor=win ? c_dark : c_white, style=dPrev == 1 ? (win ? label.style_label_down : label.style_label_up) : (win ? label.style_label_up : label.style_label_down), size=size.small, force_overlay=true)
            array.push(dLabels, rl)
            dRisk := na
            dTarget := na
            f_trim()
            if i_alertJson
                alert('{"action":"EXIT","indicator":"SVL","log":"' + i_show + '","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","r":' + str.tostring(r) + '}', alert.freq_once_per_bar_close)

// ─── SIGNALS ───────────────────────────────────────────────────────────────────
float swingLo = ta.lowest(low, i_swingLen)
float swingHi = ta.highest(high, i_swingLen)
float atrV    = ta.atr(14)

f_levels(int d, float rr) =>
    float e = close
    float risk = d == 1 ? e - swingLo : swingHi - e
    risk := math.max(risk, nz(atrV) * i_minAtr, syminfo.mintick * 5)
    float s = d == 1 ? e - risk : e + risk
    float t = d == 1 ? e + risk * rr : e - risk * rr
    [e, s, t]

// signals per log (0 none, 1 long, -1 short)
array<int> sig = array.from(0, 0, 0, 0, 0, 0)
if confirmed and ready
    for code = 0 to 1
        bool fired = code == 0 ? firedP : firedF
        int  runB  = code == 0 ? runBeforeP : runBeforeF
        if fired
            int dA = val > 0 and i_longs ? 1 : val < 0 and i_shorts ? -1 : 0
            int dB = colIdx == 0 and i_longs ? 1 : colIdx == 2 and i_shorts ? -1 : 0
            array.set(sig, code, dA)
            array.set(sig, 2 + code, dB)
            if dB != 0 and runB >= i_minDots and not na(sma200) and (dB == 1 ? close > sma200 : close < sma200)
                array.set(sig, 4 + code, dB)

float showEntry = na
float showStop = na
float showTarget = na
bool  showOpened = false
int   openMask = 0                                     // bit i set = log i opened a trade on this candle (read by tools)
for i = 0 to 5
    int d = array.get(sig, i)
    if d != 0 and array.size(books) == 6
        Book b = array.get(books, i)
        if b.dir == 0
            [e, s, t] = f_levels(d, int(i / 2) == 0 ? 0.0 : i_rr)
            f_open(b, d, e, s, int(i / 2) == 0 ? na : t)
            openMask += int(math.pow(2, i))
            if i == showIdx
                showEntry := e
                showStop := s
                showTarget := int(i / 2) == 0 ? na : t
                showOpened := true

int sigShow = array.get(sig, showIdx)
if i_showTrades and showOpened
    dRisk := box.new(bar_index, math.max(showEntry, showStop), bar_index + i_extendBars, math.min(showEntry, showStop), bgcolor=color.new(i_bearCol, i_boxFill + 6), border_color=color.new(i_bearCol, 45), border_width=1, force_overlay=true)
    array.push(dBoxes, dRisk)
    if not na(showTarget)
        dTarget := box.new(bar_index, math.max(showEntry, showTarget), bar_index + i_extendBars, math.min(showEntry, showTarget), bgcolor=color.new(i_bullCol, i_boxFill), border_color=color.new(i_bullCol, 35), border_width=1, force_overlay=true)
        array.push(dBoxes, dTarget)
    string tip = (sigShow == 1 ? "LONG" : "SHORT") + " · " + i_show + "\nEntry " + str.tostring(showEntry, format.mintick) + "\nStop " + str.tostring(showStop, format.mintick) + (na(showTarget) ? "\nExit: the momentum colour changes" : "\nTarget " + str.tostring(showTarget, format.mintick) + " (" + str.tostring(i_rr, "#.#") + "R)")
    label sl = label.new(bar_index, sigShow == 1 ? low : high, sigShow == 1 ? "BUY" : "SELL", color=sigShow == 1 ? i_bullCol : i_bearCol, textcolor=sigShow == 1 ? c_dark : c_white, style=sigShow == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=tip, force_overlay=true)
    array.push(dLabels, sl)
    f_trim()
    if i_alertJson
        alert('{"action":"' + (sigShow == 1 ? "LONG" : "SHORT") + '","indicator":"SVL","log":"' + i_show + '","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(showEntry) + ',"stop":' + str.tostring(showStop) + '}', alert.freq_once_per_bar_close)
if not na(dRisk)
    box.set_right(dRisk, bar_index + i_extendBars)
    if not na(dTarget)
        box.set_right(dTarget, bar_index + i_extendBars)

// ─── LOG STATISTICS ────────────────────────────────────────────────────────────
f_stats(int i) =>
    int n = 0
    int w = 0
    float tot = 0.0
    int days = 0
    if array.size(books) == 6
        Book b = array.get(books, i)
        n := array.size(b.res)
        if n > 0
            for j = 0 to n - 1
                float r = array.get(b.res, j)
                tot += r
                if r > 0
                    w += 1
            days := int((array.get(b.tms, n - 1) - array.get(b.tms, 0)) / 86400000) + 1
    [n, w, tot, days]

f_r(float _v) =>
    na(_v) ? "-" : (_v >= 0 ? "+" : "") + str.tostring(_v, "#.#") + "R"

f_pos(string _p) =>
    switch _p
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

array<string> names = array.from("A Creator's rule", "A · typo fixed", "B Classic rule", "B · typo fixed", "C Improved rule", "C · typo fixed")
array<float>  totals = array.new<float>(6, 0.0)
array<int>    counts = array.new<int>(6, 0)
for i = 0 to 5
    [n, w, tot, days] = f_stats(i)
    array.set(totals, i, tot)
    array.set(counts, i, n)

if i_showTable and barstate.islast
    var table led = table.new(f_pos(i_tablePos), 6, 8, bgcolor=color.new(c_dark, 8), border_color=color.new(c_purple, 45), border_width=1, frame_color=color.new(c_purple, 15), frame_width=2, force_overlay=true)
    string ts  = i_tableSize == "Large" ? size.normal : i_tableSize == "Small" ? size.tiny : size.small
    string tsH = i_tableSize == "Large" ? size.large : i_tableSize == "Small" ? size.small : size.normal
    color lab = c_grey
    table.cell(led, 0, 0, "SQUEEZE VERDICT LAB · last " + str.tostring(i_ledgerN) + " trades per log", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
    table.merge_cells(led, 0, 0, 5, 0)
    table.cell(led, 0, 1, "Log", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 1, "Trades", text_color=lab, text_size=ts)
    table.cell(led, 2, 1, "Wins", text_color=lab, text_size=ts)
    table.cell(led, 3, 1, "Win rate", text_color=lab, text_size=ts)
    table.cell(led, 4, 1, "Total R", text_color=lab, text_size=ts)
    table.cell(led, 5, 1, "Days", text_color=lab, text_size=ts)
    for i = 0 to 5
        [n, w, tot, days] = f_stats(i)
        bool fixedRow = i % 2 == 1
        table.cell(led, 0, 2 + i, array.get(names, i), text_color=fixedRow ? lab : c_white, text_size=ts, text_halign=text.align_left)
        table.cell(led, 1, 2 + i, str.tostring(n), text_color=c_white, text_size=ts)
        table.cell(led, 2, 2 + i, str.tostring(w), text_color=i_bullCol, text_size=ts)
        table.cell(led, 3, 2 + i, n > 0 ? str.tostring(100.0 * w / n, "#.#") + " %" : "-", text_color=c_white, text_size=ts)
        table.cell(led, 4, 2 + i, f_r(tot), text_color=tot >= 0 ? i_bullCol : i_bearCol, text_size=ts)
        table.cell(led, 5, 2 + i, str.tostring(days), text_color=c_white, text_size=ts)

// ─── THE INDICATOR PANE (LazyBear's look) ──────────────────────────────────────
plot(val, "Momentum", color=bcolor, style=plot.style_histogram, linewidth=4)
plot(0, "Squeeze", color=scolor, style=plot.style_cross, linewidth=2)

// ─── DATA-WINDOW PLOTS (read by tools, hidden) ─────────────────────────────────
plot(val, "val", display=display.data_window)
plot(colIdx, "colIdx", display=display.data_window)
plot(onP ? 1 : offP ? -1 : 0, "sqzP", display=display.data_window)
plot(onF ? 1 : offF ? -1 : 0, "sqzF", display=display.data_window)
plot(runBeforeP, "runP", display=display.data_window)
plot(runBeforeF, "runF", display=display.data_window)
plot(sma200, "sma200", display=display.data_window)
plot(swingLo, "swingLo", display=display.data_window)
plot(swingHi, "swingHi", display=display.data_window)
plot(array.get(sig, 0), "sigAP", display=display.data_window)
plot(array.get(sig, 1), "sigAF", display=display.data_window)
plot(array.get(sig, 2), "sigBP", display=display.data_window)
plot(array.get(sig, 3), "sigBF", display=display.data_window)
plot(array.get(sig, 4), "sigCP", display=display.data_window)
plot(array.get(sig, 5), "sigCF", display=display.data_window)
plot(array.get(res, 0), "resAP", display=display.data_window)
plot(array.get(res, 1), "resAF", display=display.data_window)
plot(array.get(res, 2), "resBP", display=display.data_window)
plot(array.get(res, 3), "resBF", display=display.data_window)
plot(array.get(res, 4), "resCP", display=display.data_window)
plot(array.get(res, 5), "resCF", display=display.data_window)
plot(array.get(totals, 0), "totAP", display=display.data_window)
plot(array.get(totals, 1), "totAF", display=display.data_window)
plot(array.get(totals, 2), "totBP", display=display.data_window)
plot(array.get(totals, 3), "totBF", display=display.data_window)
plot(array.get(totals, 4), "totCP", display=display.data_window)
plot(array.get(totals, 5), "totCF", display=display.data_window)
plot(array.get(counts, 0), "nAP", display=display.data_window)
plot(openMask, "openMask", display=display.data_window)
plot(close - math.max(close - swingLo, nz(atrV) * i_minAtr, syminfo.mintick * 5), "stopL", display=display.data_window)
plot(close + math.max(swingHi - close, nz(atrV) * i_minAtr, syminfo.mintick * 5), "stopS", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(sigShow == 1,  "SVL Long entry",  "Squeeze Verdict Lab: LONG on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigShow == -1, "SVL Short entry", "Squeeze Verdict Lab: SHORT on {{ticker}} {{interval}} at {{close}}")
````
