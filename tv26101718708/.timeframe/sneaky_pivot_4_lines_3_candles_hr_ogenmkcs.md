# Sneaky Pivot: 4 Lines + 3 Candles [HR]

- url: https://www.tradingview.com/script/Ogenmkcs-Sneaky-Pivot-4-Lines-3-Candles-HR/
- type: indicator
- pine_id: PUB;cf0c449dac5a49869ec738ba25115015
- version: 1.0

## Description

Sneaky Pivot is a rule-based version of the "sneaky pivot" day-trading method that a futures day trader named Doug presented for E-mini Dow futures (YM) on the 15-minute chart. It draws four daily levels and marks a three-candle reversal at those levels right after the New York open. A switch turns on a second rule set: a retelling by CryptoBosh that uses the same three candles at any time of day and was shown on Bitcoin. This is an independent formalization, not affiliated with either author.

ORIGINALITY AND USEFULNESS
This is not a mashup of existing indicators. Doug presented a discretionary routine ("strong, bold opening 15-minute candle", "go back to the left"); the script turns each vague step into an explicit rule with an input. The defaults are calibrated on his own YM trade of 12 May 2026 (index data plus that day's futures offset): entry 49,516 vs 49,521 he stated, stop 49,392 vs about 49,390, target 49,867 vs about 49,878. It does the error-prone manual work, gives each setup an exact entry, stop, target and reward-to-risk with an alert, and shows both rule sets on one chart.

HOW THE PARTS WORK TOGETHER
1. An NYSE calendar (holidays including Good Friday, Juneteenth from 2022 and special closures; early closes at 13:15 New York) decides which days trade and when each session ends.
2. That session defines yesterday as Doug draws it, 09:30-16:15 New York without overnight. This gives PDH and PDL.
3. A swing search over the whole loaded history (compact monotonic stack, no fixed lookback) finds LMAX / LMIN: the nearest swing high above PDH / swing low below PDL before yesterday (pivot, 3 bars on each side).
4. The three-candle rule runs only at these lines (shorts at PDH/LMAX, longs at PDL/LMIN), in Doug's version only at the open. A confirmed setup becomes a label and an alert.

THE THREE CANDLES (Doug's version, long; short is mirrored)
1. Candle 1: the first 15-minute candle after 09:30 New York; bearish; body at least 1.5 times the average of the last 20 bodies; low reaches PDL (0.05% tolerance; anchored at LMIN if it gets there). Circle "1".
2. Sneaky candle: the first bullish candle among the next two; it may make a lower low. On its close: triangle "2" and a label.
3. Entry: buy stop 1 tick above its high, valid for 2 candles. Stop: 0.01% below the pattern low. Target: PDH. Exit: 16:00 New York (13:15 on early closes).
Any-time variant (input "CryptoBosh version"): yesterday is the exchange daily candle; candle 1 is any 15-minute candle and closes back above the line; candle 2 is strictly the next one, makes no new low and closes above the line; the order lives 1 candle; stop 0.05% beyond the line; target 0.02% before PDH; no time exit or holiday filter.

INPUTS
Every rule above is an input; the values above are the defaults. Each version has its own settings block, so the switch changes everything at once. Also: Swing line (Swing pivot / First bar beyond the line), Target (Nearest opposite line / Far opposite line / Fixed R), Min reward/risk (0 = off).

HOW TO USE
1. Open CBOT_MINI:YM1!, 15 minutes, extended hours on (the tests used all bars). Any chart time zone works.
2. The top-right table shows the day's lines and where price is, and warns if the chart is not on 15 minutes. In Doug's version the day starts with the 09:30 candle, so before the open the table still shows the previous session's lines.
3. At 09:45 New York candle 1 closes; no "1" means no setup today.
4. If a "2" appears within two candles, its label gives entry, stop, target and R. The indicator does not track orders: if price hits the stop before the entry fills, skip the trade.

REPAINTING AND ALERTS
Confirmed signals do not repaint: lines use completed data, pivots are used only after confirmation, and a closed candle's markers and label never change. On the live, still-open candle a marker can appear and disappear, so act only on closed candles. Alerts with "Any alert() function call" fire once per bar close with side, line, entry, stop, target and R. For the fixed-text conditions "Sneaky Pivot: LONG" and "Sneaky Pivot: SHORT", choose "Once per bar close".

HONEST RESULTS (historical tests, not a promise)
Offline tests on 1-minute Dow Jones index data as a YM proxy, Sep 2013 - Sep 2026: 1-minute fills, $2.50 per side, 1-2 ticks of slippage; 15-minute moves correlate with real YM at 0.999. An independent re-implementation from the written rules matched all 549 trades of Doug's version (tick rounding off) and all 678 of the any-time variant.
- Doug's defaults: 549 trades (about 42 a year), +0.044 R per trade after costs; 95% interval -0.08 to +0.17 R, so not distinguishable from zero. Winners 39%, median -0.93 R. The five best trades made +31.5 R; without them, -7.4 R. Max drawdown -31 R, about -$11,400 per contract. With 4 ticks of entry slippage: -0.009 R.
- Random lines (200 runs): +0.047 R, the same as the real lines. 27,648 reasonable readings of the rules: half positive, median +0.0001 R.
- Any-time variant: 678 trades, -0.024 R. Bitcoin 2020-2026, after fees: Doug -0.11 R, any-time -0.28 R.
- Real futures, TradingView Deep Backtesting on CBOT_MINI:YM1!, strategy defaults (1 contract, $2.50 per side, 1 tick slippage). Doug since 2002: 880 trades, +$16,640 per contract, profit factor 1.10, 37% winners, max drawdown -$14,763; since 2013: 551 trades, +$19,130 (proxy, same costs: 549 trades, +$24,486). Any-time variant since 2002: 1,484 trades, -$49,645, profit factor 0.83; since 2013: 816 trades, -$34,740.
Simulations, not live trading. The indicator does not make the method profitable; it is a tool to watch and verify it.

LIMITATIONS
- Built and tested for YM on 15 minutes (plus Bitcoin, above); other timeframes may have no 09:30 candle.
- LMAX/LMIN come from loaded history only ("not in history" otherwise); loading older history can add lines to early days.
- On YM1! Doug's rules land close to the proxy, but the any-time variant is clearly worse: it trades around the clock, and the proxy lacks overnight quotes in 2015-2017.

Credit: the method was presented by a day trader named Doug; the any-time-of-day variant follows a retelling by CryptoBosh. The formalization, the calendar, the swing search and the tests are independent work.

For education and research only. Not financial advice. Historical results do not predict future results.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Eduard Keller

//@version=6
indicator("Sneaky Pivot: 4 Lines + 3 Candles [HR]", shorttitle="Sneaky Pivot", overlay=true, max_lines_count=500, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// SNEAKY PIVOT — v2.0
// An exact, rule-based formalization of the discretionary "4 lines + 3 candles" method.
// Original method: Doug's discretionary "sneaky pivot" routine: YM futures, 15 minutes, New York open.
// Any-time variant: a retelling by CryptoBosh: Bitcoin, any time of day.
//
// LINES (set at the start of the day, fixed for the whole day):
//   PDH / PDL — previous day's high and low (for Doug: the regular session 09:30-16:15 New York time)
//   LMAX      — nearest swing high above PDH, to the left of the previous day
//   LMIN      — nearest swing low below PDL, to the left of the previous day
//   Shorts only at the upper pair (PDH, LMAX), longs only at the lower pair (PDL, LMIN).
//
// DOUG'S ORIGINAL (default), long side; short is mirrored:
//   1) the first 15-minute candle after 09:30 New York is large, bearish and reaches a lower line;
//   2) the "sneaky" bullish candle is the next one or the one after (it may make a lower low, as in Doug's example);
//   3) entry when price trades above the sneaky candle's high (usually the 3rd-4th candle of the day).
//   Stop 0.01 % (~5 YM points) below the low of the pattern candles, target = previous day's high,
//   exit no later than 16:00. Defaults calibrated on Doug's trade of 12 May 2026 (entry 49,521, stop -$835).
// CRYPTOBOSH VERSION (toggle): the same three candles at any time of day, candles 1 and 2 close back across the line,
//   candle 2 makes no lower low, entry only on the next candle, stop beyond the line, no time exit.
//
// The signal is fixed at the close of the sneaky candle and does not repaint afterwards.
// This indicator does not promise profit: backtest results are in the publication description.
// ══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

grpVer = "Rule version"
kbMode = input.bool(false, "CryptoBosh version (instead of Doug's original)", group=grpVer,
     tooltip="Off: Doug's original. Candle 1 is the first 15-minute candle after the New York open, entry on the 3rd-4th candle, stop beyond the pattern low/high, exit at 16:00. On: CryptoBosh's retelling. The same three candles at any time of day, stop beyond the line, no time exit. Each version has its own settings block below.")

grpLines = "Lines"
levelMode = input.string("Swing pivot", "Swing line (beyond yesterday's range)", options=["Swing pivot", "First bar beyond the line"], group=grpLines,
     tooltip="Swing pivot: the nearest confirmed swing high/low beyond yesterday's high/low, searched to the left of the previous day. First bar beyond the line: the high/low of the nearest bar that went beyond yesterday's high/low.")
pivLen    = input.int(3, "Pivot strength (bars on each side)", minval=1, maxval=20, group=grpLines)
showZones = input.bool(true, "Shade the zones", group=grpLines)

grpSig = "Three candles - common"
bodyMult  = input.float(1.5, "Candle 1: body >= K x average", minval=0.0, maxval=5.0, step=0.1, group=grpSig)
bodyLen   = input.int(20, "Average body over N bars", minval=5, maxval=200, group=grpSig)
touchTol  = input.float(0.05, "Line touch tolerance, %", minval=0.0, maxval=1.0, step=0.01, group=grpSig)
showLong  = input.bool(true, "Longs (lower pair)", group=grpSig)
showShort = input.bool(true, "Shorts (upper pair)", group=grpSig)

grpDoug = "Doug's original (default)"
dDayDef   = input.string("Regular session (RTH)", "Previous day", options=["Regular session (RTH)", "Exchange daily candle", "UTC 00:00"], group=grpDoug,
     tooltip="In Doug's setup the previous day is the black-shaded area on YM1!: the regular session 09:30-16:15 New York time, overnight excluded.")
openH     = input.int(9, "Open: hour (New York)", minval=0, maxval=23, group=grpDoug, inline="op")
openM     = input.int(30, "min", minval=0, maxval=59, group=grpDoug, inline="op")
rthEndH   = input.int(16, "RTH end: hour (New York)", minval=0, maxval=23, group=grpDoug, inline="rth")
rthEndM   = input.int(15, "min", minval=0, maxval=59, group=grpDoug, inline="rth")
skipHol   = input.bool(true, "Skip NYSE holidays", group=grpDoug)
sneakyWin = input.int(2, "Sneaky candle: one of the next N candles", minval=1, maxval=6, group=grpDoug)
dC2Hold   = input.bool(false, "Sneaky candle holds candle 1's extreme", group=grpDoug)
dReclaim  = input.bool(false, "Candle 1 closed back across the line", group=grpDoug)
dValid    = input.int(2, "Entry order lifetime, bars", minval=1, maxval=10, group=grpDoug)
dCancel   = input.bool(true, "Cancel entry if price hits the stop first", group=grpDoug)
dStopMode = input.string("Beyond pattern candles", "Stop", options=["Beyond pattern candles", "Beyond candle 1", "Beyond the line"], group=grpDoug)
dStopBuf  = input.float(0.01, "Stop offset, %", minval=0.0, maxval=2.0, step=0.01, group=grpDoug)
dTpBuf    = input.float(0.0, "Target offset before the line, %", minval=0.0, maxval=1.0, step=0.01, group=grpDoug)
dTimeExit = input.bool(true, "Close position at end of day", group=grpDoug)
exitH     = input.int(16, "Exit: hour (New York)", minval=0, maxval=23, group=grpDoug, inline="ex")
exitM     = input.int(0, "min", minval=0, maxval=59, group=grpDoug, inline="ex")

grpKb = "CryptoBosh version"
kbDayDef  = input.string("Exchange daily candle", "Previous day", options=["Regular session (RTH)", "Exchange daily candle", "UTC 00:00"], group=grpKb,
     tooltip="On Bitcoin, the exchange daily candle is the UTC day.")
kbC2Hold  = input.bool(true, "Candle 2 holds candle 1's extreme", group=grpKb)
kbReclaim = input.bool(true, "Candle 1 closed back across the line", group=grpKb)
kbValid   = input.int(1, "Entry order lifetime, bars", minval=1, maxval=10, group=grpKb)
kbStopMode = input.string("Beyond the line", "Stop", options=["Beyond the line", "Beyond candle 1", "Beyond pattern candles"], group=grpKb)
kbStopBuf = input.float(0.05, "Stop offset, %", minval=0.0, maxval=2.0, step=0.01, group=grpKb)
kbTpBuf   = input.float(0.02, "Target offset before the line, %", minval=0.0, maxval=1.0, step=0.01, group=grpKb)

grpRisk = "Target - common"
tpMode   = input.string("Nearest opposite line", "Target", options=["Nearest opposite line", "Far opposite line", "Fixed R"], group=grpRisk)
tpRR     = input.float(2.0, "Fixed R (for the 'Fixed R' target)", minval=0.5, maxval=20, step=0.5, group=grpRisk)
minRR    = input.float(0.0, "Min reward/risk", minval=0.0, maxval=20, step=0.5, group=grpRisk)

grpVis = "Style"
colSell  = input.color(#EF5350, "Upper pair (shorts)", group=grpVis)
colBuy   = input.color(#26A69A, "Lower pair (longs)", group=grpVis)
colEntry = input.color(#2962FF, "Entry", group=grpVis)
colStop  = input.color(#FF9800, "Stop", group=grpVis)
showOpen = input.bool(true, "Mark the open candle at a line (Doug)", group=grpVis)
showTable = input.bool(true, "Table of today's lines", group=grpVis)

// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR: New York open and NYSE holidays
// ─────────────────────────────────────────────────────────────────────────────

string TZ = "America/New_York"

idiv(int a, int b) =>
    int(math.floor(a / b))

easterMD(int y) =>
    int a = y % 19
    int b = idiv(y, 100)
    int c = y % 100
    int d = idiv(b, 4)
    int e = b % 4
    int f = idiv(b + 8, 25)
    int g = idiv(b - f + 1, 3)
    int h = (19 * a + b - d - g + 15) % 30
    int i = idiv(c, 4)
    int k = c % 4
    int l = (32 + 2 * e + 2 * i - h - k) % 7
    int m = idiv(a + 11 * h + 22 * l, 451)
    int mon = idiv(h + l - 7 * m + 114, 31)
    int dd = (h + l - 7 * m + 114) % 31 + 1
    [mon, dd]

nyseHoliday(int t) =>
    int y  = year(t, TZ)
    int mo = month(t, TZ)
    int d  = dayofmonth(t, TZ)
    int w  = dayofweek(t, TZ)
    bool wk  = w != dayofweek.saturday and w != dayofweek.sunday
    bool mon = w == dayofweek.monday
    bool fri = w == dayofweek.friday
    bool thu = w == dayofweek.thursday
    [em, ed] = easterMD(y)
    int gf = timestamp("UTC", y, em, ed, 0, 0) - 2 * 86400000
    bool h = false
    h := h or (mo == 1 and ((d == 1 and wk) or (d == 2 and mon)))
    h := h or ((mo == 1 or mo == 2) and mon and d >= 15 and d <= 21)
    h := h or (mo == month(gf, "UTC") and d == dayofmonth(gf, "UTC"))
    h := h or (mo == 5 and mon and d >= 25)
    h := h or (y >= 2022 and mo == 6 and ((d == 19 and wk) or (d == 18 and fri) or (d == 20 and mon)))
    h := h or (mo == 7 and ((d == 4 and wk) or (d == 3 and fri) or (d == 5 and mon)))
    h := h or (mo == 9 and mon and d <= 7)
    h := h or (mo == 11 and thu and d >= 22 and d <= 28)
    h := h or (mo == 12 and ((d == 25 and wk) or (d == 24 and fri) or (d == 26 and mon)))
    h := h or (y == 2012 and mo == 10 and (d == 29 or d == 30)) or (y == 2018 and mo == 12 and d == 5) or (y == 2025 and mo == 1 and d == 9)
    h

// early-close days: July 3 and December 24 (Mon-Thu), the Friday after Thanksgiving; futures close at 13:15
nyseEarlyClose(int t) =>
    int mo = month(t, TZ)
    int d  = dayofmonth(t, TZ)
    int w  = dayofweek(t, TZ)
    bool mt = w == dayofweek.monday or w == dayofweek.tuesday or w == dayofweek.wednesday or w == dayofweek.thursday
    (mo == 7 and d == 3 and mt) or (mo == 12 and d == 24 and mt) or (mo == 11 and w == dayofweek.friday and d >= 23 and d <= 29)

// parameters of the selected version
string dayDef   = kbMode ? kbDayDef : dDayDef
string stopMode = kbMode ? kbStopMode : dStopMode
float  stopBuf  = kbMode ? kbStopBuf : dStopBuf
float  tpBuf    = kbMode ? kbTpBuf : dTpBuf
bool   c2Hold   = kbMode ? kbC2Hold : dC2Hold

int  nyW       = dayofweek(time, TZ)
bool nyWeekday = nyW != dayofweek.saturday and nyW != dayofweek.sunday
bool tradeDay  = nyWeekday and (not skipHol or not nyseHoliday(time))
int  nyMin     = hour(time, TZ) * 60 + minute(time, TZ)
int  openMin   = openH * 60 + openM
bool isOpenBar = tradeDay and nyMin == openMin
bool earlyDay  = nyseEarlyClose(time)
int  rthEndMin = earlyDay ? 13 * 60 + 15 : rthEndH * 60 + rthEndM
bool inRth     = tradeDay and nyMin >= openMin and nyMin < rthEndMin

// ─────────────────────────────────────────────────────────────────────────────
// DAILY LINES
// ─────────────────────────────────────────────────────────────────────────────

int  dayIdxUtc = int(math.floor(time / 86400000.0))
bool rthDay    = dayDef == "Regular session (RTH)"
bool dChange   = timeframe.change("D")
bool newDayRaw = dayDef == "UTC 00:00" ? dayIdxUtc != dayIdxUtc[1] : rthDay ? isOpenBar : dChange
bool newDay    = bar_index == 0 or newDayRaw
var int dayNo = 0
if newDay
    dayNo += 1
bool accBar = rthDay ? inRth : true

float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow(low, pivLen, pivLen)

// swing candidates: a buffer (pivots not yet to the left of the previous day) and monotonic stacks
// (an older pivot that is not above a newer one can never become the "nearest beyond the line", so it is dropped)
var array<float> bufHv = array.new<float>()
var array<int>   bufHb = array.new<int>()
var array<float> bufLv = array.new<float>()
var array<int>   bufLb = array.new<int>()
var array<float> stkH  = array.new<float>()
var array<float> stkL  = array.new<float>()
if levelMode == "Swing pivot"
    if not na(ph)
        array.push(bufHv, ph)
        array.push(bufHb, bar_index - pivLen)
    if not na(pl)
        array.push(bufLv, pl)
        array.push(bufLb, bar_index - pivLen)
else
    // "First bar": every bar is a candidate
    array.push(bufHv, high)
    array.push(bufHb, bar_index)
    array.push(bufLv, low)
    array.push(bufLb, bar_index)

var float curH = na
var float curL = na
var float pdh  = na
var float pdl  = na
var float lmax = na
var float lmin = na

var int dayStartBar = 0
if newDay
    int ps = dayStartBar   // start of the previous day: the swing is searched to the left of it
    while array.size(bufHb) > 0 and array.get(bufHb, 0) < ps
        float v = array.shift(bufHv)
        array.shift(bufHb)
        while array.size(stkH) > 0 and array.last(stkH) <= v
            array.pop(stkH)
        array.push(stkH, v)
    while array.size(bufLb) > 0 and array.get(bufLb, 0) < ps
        float v = array.shift(bufLv)
        array.shift(bufLb)
        while array.size(stkL) > 0 and array.last(stkL) >= v
            array.pop(stkL)
        array.push(stkL, v)
    if not na(curH)
        pdh := curH
        pdl := curL
        lmax := na
        lmin := na
        int nH = array.size(stkH)
        if nH > 0
            for i = nH - 1 to 0
                float v = array.get(stkH, i)
                if v > pdh
                    lmax := v
                    break
        int nL = array.size(stkL)
        if nL > 0
            for i = nL - 1 to 0
                float v = array.get(stkL, i)
                if v < pdl
                    lmin := v
                    break
    dayStartBar := bar_index
    curH := accBar ? high : na
    curL := accBar ? low : na
else if accBar
    curH := na(curH) ? high : math.max(curH, high)
    curL := na(curL) ? low : math.min(curL, low)

// ─────────────────────────────────────────────────────────────────────────────
// THREE CANDLES (signal at the close of the sneaky candle)
// ─────────────────────────────────────────────────────────────────────────────

float body    = math.abs(close - open)
float avgPrev = ta.sma(body, bodyLen)[1]
bool  bigCur  = bodyMult <= 0 or body >= bodyMult * avgPrev
bool  sameDay = dayNo == dayNo[1]
float tol  = touchTol / 100.0
float sBuf = stopBuf / 100.0
float tBuf = tpBuf / 100.0

targetFor(int dir, float e, float s) =>
    float t = na
    if dir == 1
        t := tpMode == "Nearest opposite line" ? pdh * (1 - tBuf) : tpMode == "Far opposite line" ? (na(lmax) ? pdh : lmax) * (1 - tBuf) : e + tpRR * (e - s)
    else
        t := tpMode == "Nearest opposite line" ? pdl * (1 + tBuf) : tpMode == "Far opposite line" ? (na(lmin) ? pdl : lmin) * (1 + tBuf) : e - tpRR * (s - e)
    t

// — CryptoBosh version: candle 1 = previous bar, candle 2 = current bar, any time of day —
bool  reachPdl  = low[1] <= pdl * (1 + tol)
bool  reachLmin = not na(lmin) and low[1] <= lmin * (1 + tol)
float anchorL   = reachLmin ? lmin : reachPdl ? pdl : na
bool  c2L       = close > open and close > anchorL and (not c2Hold or low >= low[1])
bool  rawLongKB = showLong and sameDay and not na(anchorL) and not na(pdh) and close[1] < open[1] and bigCur[1] and (not kbReclaim or close[1] > anchorL) and c2L
float stopLKB   = stopMode == "Beyond the line" ? anchorL * (1 - sBuf) : stopMode == "Beyond candle 1" ? low[1] * (1 - sBuf) : math.min(low, low[1]) * (1 - sBuf)

bool  reachPdh  = high[1] >= pdh * (1 - tol)
bool  reachLmax = not na(lmax) and high[1] >= lmax * (1 - tol)
float anchorS   = reachLmax ? lmax : reachPdh ? pdh : na
bool  c2S       = close < open and close < anchorS and (not c2Hold or high <= high[1])
bool  rawShortKB = showShort and sameDay and not na(anchorS) and not na(pdl) and close[1] > open[1] and bigCur[1] and (not kbReclaim or close[1] < anchorS) and c2S
float stopSKB   = stopMode == "Beyond the line" ? anchorS * (1 + sBuf) : stopMode == "Beyond candle 1" ? high[1] * (1 + sBuf) : math.max(high, high[1]) * (1 + sBuf)

// — Doug's original: candle 1 = the open candle, sneaky candle = one of the next sneakyWin candles —
var int    dState  = 0
var int    dDir    = 0
var float  dAnchor = na
var float  dExt    = na
var float  dStopV  = na
var int    dLeft   = 0
var int    dDayNo  = 0
var string dTag    = ""
bool dSig    = false
bool dOpenL  = false
bool dOpenS  = false

if not kbMode
    if isOpenBar
        dState := 0
        bool lvOk = not na(pdh) and not na(pdl)
        bool cL = showLong and lvOk and bigCur and close < open and low <= pdl * (1 + tol)
        bool cS = showShort and lvOk and bigCur and close > open and high >= pdh * (1 - tol)
        if cL
            bool far = not na(lmin) and low <= lmin * (1 + tol)
            float anc = far ? lmin : pdl
            if not dReclaim or close > anc
                dOpenL  := true
                dState  := 1
                dDir    := 1
                dAnchor := anc
                dTag    := far ? "LMIN" : "PDL"
                dExt    := low
                dStopV  := stopMode == "Beyond the line" ? anc * (1 - sBuf) : stopMode == "Beyond candle 1" ? low * (1 - sBuf) : na
                dLeft   := sneakyWin
                dDayNo  := dayNo
        else if cS
            bool far = not na(lmax) and high >= lmax * (1 - tol)
            float anc = far ? lmax : pdh
            if not dReclaim or close < anc
                dOpenS  := true
                dState  := 1
                dDir    := -1
                dAnchor := anc
                dTag    := far ? "LMAX" : "PDH"
                dExt    := high
                dStopV  := stopMode == "Beyond the line" ? anc * (1 + sBuf) : stopMode == "Beyond candle 1" ? high * (1 + sBuf) : na
                dLeft   := sneakyWin
                dDayNo  := dayNo
    else if dState == 1
        if dayNo != dDayNo
            dState := 0
        else
            dLeft -= 1
            bool stopHit = dCancel and not na(dStopV) and (dDir == 1 ? low <= dStopV : high >= dStopV)
            if stopHit
                dState := 0
            else
                bool colour = dDir == 1 ? close > open : close < open
                bool hold = not c2Hold or (dDir == 1 ? low >= dExt : high <= dExt)
                if colour and hold
                    dSig := true
                    dState := 0
                else
                    dExt := dDir == 1 ? math.min(dExt, low) : math.max(dExt, high)
                    if dLeft <= 0
                        dState := 0

// — unified signal —
int    sigDir = 0
float  sigE   = na
float  sigS   = na
float  sigT   = na
string sigTag = ""
if kbMode
    if rawLongKB
        sigDir := 1
        sigE   := high + syminfo.mintick
        sigS   := stopLKB
        sigTag := reachLmin ? "LMIN" : "PDL"
    else if rawShortKB
        sigDir := -1
        sigE   := low - syminfo.mintick
        sigS   := stopSKB
        sigTag := reachLmax ? "LMAX" : "PDH"
else if dSig
    sigDir := dDir
    sigE   := dDir == 1 ? high + syminfo.mintick : low - syminfo.mintick
    sigS   := not na(dStopV) ? dStopV : dDir == 1 ? math.min(dExt, low) * (1 - sBuf) : math.max(dExt, high) * (1 + sBuf)
    sigTag := dTag
if sigDir != 0
    sigT := targetFor(sigDir, sigE, sigS)
    if not kbMode   // in Doug's version stop and target are real order prices: round to the tick
        sigS := math.round_to_mintick(sigS)
        sigT := math.round_to_mintick(sigT)
float sigRR = sigDir != 0 ? sigDir * (sigT - sigE) / (sigDir * (sigE - sigS)) : na
bool longSig  = sigDir == 1 and sigE > sigS and sigT > sigE and sigRR >= minRR
bool shortSig = sigDir == -1 and sigS > sigE and sigE > sigT and sigRR >= minRR
int  validEff = kbMode ? kbValid : dValid

// ─────────────────────────────────────────────────────────────────────────────
// DRAWING
// ─────────────────────────────────────────────────────────────────────────────

pLmax = plot(newDay ? na : lmax, "LMAX - swing high", color=colSell, linewidth=2, style=plot.style_linebr)
pPdh  = plot(newDay ? na : pdh,  "PDH - previous day high", color=color.new(colSell, 30), linewidth=2, style=plot.style_linebr)
pPdl  = plot(newDay ? na : pdl,  "PDL - previous day low", color=color.new(colBuy, 30), linewidth=2, style=plot.style_linebr)
pLmin = plot(newDay ? na : lmin, "LMIN - swing low", color=colBuy, linewidth=2, style=plot.style_linebr)
fill(pLmax, pPdh, color=showZones ? color.new(colSell, 88) : na, title="Sellers' zone")
fill(pPdl, pLmin, color=showZones ? color.new(colBuy, 88) : na, title="Buyers' zone")

plotshape(showOpen and dOpenL, "Open candle at lower pair", shape.circle, location.belowbar, colBuy, text="1", textcolor=colBuy, size=size.tiny)
plotshape(showOpen and dOpenS, "Open candle at upper pair", shape.circle, location.abovebar, colSell, text="1", textcolor=colSell, size=size.tiny)
plotshape(longSig,  "LONG setup (sneaky candle closed)", shape.triangleup, location.belowbar, colBuy, text="2", textcolor=colBuy, size=size.small)
plotshape(shortSig, "SHORT setup (sneaky candle closed)", shape.triangledown, location.abovebar, colSell, text="2", textcolor=colSell, size=size.small)

fmt(float x) => str.tostring(x, format.mintick)

drawSetup(int dir, float e, float s, float t, float rr, string tag) =>
    int x2 = bar_index + validEff + 6
    line.new(bar_index, e, x2, e, color=colEntry, width=2)
    line.new(bar_index, s, x2, s, color=colStop, width=2, style=line.style_dashed)
    line.new(bar_index, t, x2, t, color=dir > 0 ? colBuy : colSell, width=2, style=line.style_dotted)
    string txt = (dir > 0 ? "LONG at " : "SHORT at ") + tag + "\nentry " + fmt(e) + "\nstop " + fmt(s) + "\ntarget " + fmt(t) + "  (" + str.tostring(rr, "#.#") + "R)" + (kbMode ? "" : "\nexit by " + str.tostring(exitH) + ":" + (exitM < 10 ? "0" : "") + str.tostring(exitM))
    label.new(bar_index, dir > 0 ? low : high, txt, style=dir > 0 ? label.style_label_up : label.style_label_down, yloc=dir > 0 ? yloc.belowbar : yloc.abovebar, color=color.new(dir > 0 ? colBuy : colSell, 15), textcolor=color.white, size=size.small)

if longSig
    drawSetup(1, sigE, sigS, sigT, sigRR, sigTag)
if shortSig
    drawSetup(-1, sigE, sigS, sigT, sigRR, sigTag)

// ─────────────────────────────────────────────────────────────────────────────
// TABLE AND ALERTS
// ─────────────────────────────────────────────────────────────────────────────

var table info = table.new(position.top_right, 2, 8, bgcolor=color.new(#131722, 10), border_width=1, border_color=#2A2E39)
if showTable and barstate.islast
    string zone = close >= pdh * (1 - tol) ? "at upper pair - look for a short" : close <= pdl * (1 + tol) ? "at lower pair - look for a long" : "middle - no trade"
    table.cell(info, 0, 0, "Sneaky Pivot", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, timeframe.period == "15" ? "15m ✓" : "needs 15m", text_color=timeframe.period == "15" ? colBuy : colStop, text_size=size.small)
    table.cell(info, 0, 1, "Version", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, kbMode ? "CryptoBosh: any time" : "Doug: open " + str.tostring(openH) + ":" + (openM < 10 ? "0" : "") + str.tostring(openM) + " NY", text_color=color.white, text_size=size.small)
    table.cell(info, 0, 2, "LMAX", text_color=colSell, text_size=size.small)
    table.cell(info, 1, 2, na(lmax) ? "not in history" : fmt(lmax), text_color=colSell, text_size=size.small)
    table.cell(info, 0, 3, "PDH", text_color=colSell, text_size=size.small)
    table.cell(info, 1, 3, fmt(pdh), text_color=colSell, text_size=size.small)
    table.cell(info, 0, 4, "PDL", text_color=colBuy, text_size=size.small)
    table.cell(info, 1, 4, fmt(pdl), text_color=colBuy, text_size=size.small)
    table.cell(info, 0, 5, "LMIN", text_color=colBuy, text_size=size.small)
    table.cell(info, 1, 5, na(lmin) ? "not in history" : fmt(lmin), text_color=colBuy, text_size=size.small)
    table.cell(info, 0, 6, "Price", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 6, zone, text_color=color.white, text_size=size.small)
    table.cell(info, 0, 7, "Day", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 7, dayDef, text_color=color.gray, text_size=size.tiny)

alertcondition(longSig, "Sneaky Pivot: LONG", "LONG {{ticker}}: 3 candles at the lower pair. Entry above the sneaky candle's high.")
alertcondition(shortSig, "Sneaky Pivot: SHORT", "SHORT {{ticker}}: 3 candles at the upper pair. Entry below the sneaky candle's low.")
if longSig
    alert("LONG " + syminfo.ticker + " at " + sigTag + ": entry " + fmt(sigE) + ", stop " + fmt(sigS) + ", target " + fmt(sigT) + " (" + str.tostring(sigRR, "#.#") + "R)", alert.freq_once_per_bar_close)
if shortSig
    alert("SHORT " + syminfo.ticker + " at " + sigTag + ": entry " + fmt(sigE) + ", stop " + fmt(sigS) + ", target " + fmt(sigT) + " (" + str.tostring(sigRR, "#.#") + "R)", alert.freq_once_per_bar_close)
````
