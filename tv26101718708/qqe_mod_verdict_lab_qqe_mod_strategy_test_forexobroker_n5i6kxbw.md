# QQE MOD Verdict Lab: QQE MOD Strategy Test [forexobroker]

- url: https://www.tradingview.com/script/n5I6KXBW-QQE-MOD-Verdict-Lab-QQE-MOD-Strategy-Test-forexobroker/
- type: indicator
- pine_id: PUB;e1a2ad4521c44cccb1930b5e690c49e7
- version: 1.0

## Description

QQE MOD Verdict Lab: QQE MOD Strategy Test [forexobroker]

🔶 OVERVIEW

QQE MOD Verdict Lab puts the most-copied QQE MOD strategy on trial on your own chart. It computes QQE MOD by Mihkel00, SuperTrend by KivancOzbilgic, Trend Indicator A-V2 by DZIV and the SSL Hybrid baseline by Mihkel00 with their own inputs and formulas, and logs six ways of trading them side by side: the classic SuperTrend + QQE MOD + Trend Indicator setup with the 2021 versions of the indicators, the same setup with the versions published today, two common changes to its exits, QQE MOD alone, and QQE MOD with the SSL Hybrid baseline and a 200 EMA. One table shows all six logs over the last N trades, so you can see which one holds up on your market and timeframe.

Credit: QQE MOD and SSL Hybrid are open-source scripts by Mihkel00, SuperTrend is the open-source script by KivancOzbilgic, and Trend Indicator A-V2 is the open-source script by DZIV (the 2021 version is MPL 2.0; today's version 2.3 is CC BY-NC-SA 4.0, and this script is free and non-commercial). All are reproduced with their own formulas. The six rule logs, the stops and the table are the original work described below.

🔶 THE INDICATORS

- QQE MOD: an RSI (6) smoothed by an EMA (5). Its bar-to-bar change is averaged with an EMA (11) and multiplied by the QQE factor (3 for the fast line, 1.61 for the slow one) to give a trailing band. A bar is blue when the slow line is more than 3 above 50 and the fast line is above a Bollinger band (50, 0.35) drawn around the fast QQE trend line; red is the mirror image.
- QQE MOD changed in December 2024: the 2020 version averaged the bar-to-bar change a second time, which makes its bands slower. Both versions are computed here.
- SuperTrend: bands of ATR(9) × 3.9 around hl2 that only move in the trend's direction; the trend flips when the close crosses the previous band.
- Trend Indicator A-V2: EMAs of the Heikin Ashi open and close (same timeframe, no lookahead), green when the averaged close is above the averaged open. The 2021 version averaged them twice (EMA Length 52, EMA Length (Smoothing) 10); version 2.3 of April 2024 uses one EMA (9). Both versions are computed here.
- SSL Hybrid baseline: an HMA (60) of the close with a channel of 0.2 × EMA (60) of the true range. A candle is blue above the channel and red below it.

🔶 THE SIX RULES

A. SuperTrend up + a blue QQE MOD bar + a green Trend Indicator A-V2, with the 2021 versions of QQE MOD and A-V2. Stop beyond the A-V2 ribbon. Target 2R. Shorts are the mirror image.

A today. The same rule with the versions of QQE MOD and A-V2 published today.

B. Rule A, and the stop moves to the entry once the price reaches 1R.

C. Rule A without a target: the trade closes when SuperTrend flips the other way.

D. QQE MOD alone (today's version): the first blue bar buys, the first red bar sells. Stop at the 10-candle swing. Target 2R.

E. The close on the right side of the 200 EMA + a blue (red) QQE MOD bar + a blue (red) SSL Hybrid candle. Stop at the 10-candle swing. Target 2R.

A trade opens at the close of the candle on which all of its rule's conditions first agree. Stops are never closer than 0.5 × ATR(14); that distance is 1R. One trade at a time per log. Every entry, stop and exit is evaluated on closed candles; when one candle touches both the stop and the target, the stop counts first.

NON-REPAINTING: everything is evaluated on barstate.isconfirmed. The Heikin Ashi values come from the same request Trend Indicator A-V2 makes (same timeframe, no lookahead).

🔶 THE TABLE

Six rows over the last N trades of each log (100 by default): trades, wins, win rate, total R and the number of days the log covers. The log you choose is highlighted in the table and drawn on the chart: the entry, stop, target and result of every trade it took.

🔶 SETTINGS

QQE MOD (Mihkel00)
- RSI Length (6), RSI Smoothing (5), Fast QQE Factor (3), Slow QQE Factor (1.61), Threshold (3), Bollinger Length (50), BB Multiplier (0.35).

SuperTrend (KivancOzbilgic)
- ATR Period (9), ATR Multiplier (3.9).

Trend Indicator A-V2 (DZIV)
- 2021: EMA Length (52), EMA Length (Smoothing) (10). Today (v2.3): MA Period (9).

Rule E
- Trend EMA (200), SSL Baseline Length (60), Channel Multiplier (0.2).

Rules
- Which log is drawn on the chart; take longs, take shorts.

Stop and target
- Swing lookback for rules D and E (10), minimum stop distance (0.5 × ATR 14), target (2R), rule B break-even point (1R), how far open trade boxes extend.

Log
- Log size (the last 100 trades per log), table on or off, position and text size.

Visual
- Trade colours, trades kept on the chart, box transparency.

🔶 ALERTS

Two alertcondition hooks (long entry, short entry) for the drawn log. With JSON alerts on, every entry and exit of the drawn log also fires an alert() once per bar close with a JSON body (action, log, ticker, timeframe, entry, stop or result).

🔶 LIMITATIONS

- Results depend on the market, the timeframe and the settings; the table shows them on your own chart, losses included.
- The table counts the script's own rules on closed candles: no spread, no commission, no slippage, and the stop is counted before the target on a candle that touches both.
- The last-N window covers different calendar spans on different timeframes and rules.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

🔶 RELEASE NOTES

v1.0 — Initial release. QQE MOD (2020 and today's versions), SuperTrend, Trend Indicator A-V2 (2021 and today's versions) and the SSL Hybrid baseline computed with their own formulas; six rule logs; a six-row comparison table; the drawn log's trades on the chart; two alert hooks and JSON alerts.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: QQE MOD Verdict Lab — the most-copied QQE MOD strategy (SuperTrend + QQE MOD + Trend Indicator A-V2,
// sold as "100 % profitable"), two of its published "optimisation tips", QQE MOD alone and the QQE MOD + SSL Hybrid +
// 200 EMA combination, each logged on the same chart with the same risk unit.
// THE INDICATORS (open source on TradingView, same inputs and formulas, credited by name):
//   QQE MOD (Mihkel00). An RSI (6) smoothed by an EMA (5); its bar-to-bar change is averaged with an EMA of 11 and,
//   in the 2020 version, averaged a second time; times the QQE factor (3 fast, 1.61 slow) it gives a trailing band.
//   Blue bar = the slow line is more than 3 above 50 AND the fast line is above a Bollinger band (50, 0.35) drawn
//   around the fast QQE line. Red bar = the mirror image. The December 2024 version (v6) dropped the second average.
//   SuperTrend (KivancOzbilgic). ATR (RMA) bands around hl2 that only ratchet in the trend's direction; the trend
//   flips when the close crosses the previous band.
//   Trend Indicator A-V2 (Dziwne). EMAs of the Heikin Ashi open and close (same timeframe, no lookahead). The 2021
//   version smoothed them twice (EMA Length, EMA Length (Smoothing)); version 2.3 of April 2024 uses one EMA. Green
//   when the averaged close is above the averaged open.
//   SSL Hybrid (Mihkel00), baseline only: an HMA (60) with a channel of 0.2 × EMA (60) of the true range. A candle is
//   blue above the channel and red below it.
// THE RULES (a trade opens at the close of the candle where all of its conditions first agree):
//   A        SuperTrend up + QQE MOD blue + A-V2 green (2021 versions of QQE MOD and A-V2). Stop beyond the A-V2
//            ribbon, never closer than 0.5 × ATR 14. Target 2R.
//   A today  the same with the versions published today (QQE MOD v6, A-V2 v2.3).
//   B        A + break-even: the stop moves to the entry once the price reaches 1R.
//   C        A, but no target: exit at the close when SuperTrend flips the other way.
//   D        QQE MOD alone (today's version): the first blue bar buys, the first red bar sells. Stop at the swing of
//            the last 10 candles (never closer than 0.5 × ATR 14). Target 2R.
//   E        Close on the right side of the 200 EMA + QQE MOD blue (red) + an SSL Hybrid blue (red) candle. Swing stop,
//            target 2R.
//   The stop is checked first when one candle touches the stop and the target. One trade at a time per log.
// Non-repainting: everything is evaluated on barstate.isconfirmed; the Heikin Ashi request is the one A-V2 makes.
indicator("QQE MOD Verdict Lab: QQE MOD Strategy Test [forexobroker]", shorttitle="QMVL [fob]", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_qqe    = "QQE MOD (Mihkel00)"
string g_st     = "SuperTrend (KivancOzbilgic)"
string g_av     = "Trend Indicator A-V2 (Dziwne)"
string g_e      = "Rule E: 200 EMA + SSL Hybrid baseline (Mihkel00)"
string g_rule   = "Rules"
string g_exit   = "Stop and target"
string g_ledger = "Log"
string g_vis    = "Visual"
string g_alert  = "Alerts"

// ─── INPUTS ────────────────────────────────────────────────────────────────────
int   i_qLen    = input.int(6, "RSI Length", minval=1, maxval=200, group=g_qqe, inline="q1")
int   i_qSf     = input.int(5, "RSI Smoothing", minval=1, maxval=200, group=g_qqe, inline="q1")
float i_qFac    = input.float(3.0, "Fast QQE Factor", minval=0.1, maxval=20.0, step=0.01, group=g_qqe, inline="q2")
float i_qFac2   = input.float(1.61, "Slow QQE Factor", minval=0.1, maxval=20.0, step=0.01, group=g_qqe, inline="q2")
float i_qThr    = input.float(3.0, "Threshold", minval=0.0, maxval=50.0, step=0.5, group=g_qqe)
int   i_bbLen   = input.int(50, "Bollinger Length", minval=1, maxval=500, group=g_qqe, inline="q3")
float i_bbMult  = input.float(0.35, "BB Multiplier", minval=0.001, maxval=5.0, step=0.05, group=g_qqe, inline="q3")
int   i_stLen   = input.int(9, "ATR Period", minval=1, maxval=200, group=g_st, inline="s")
float i_stMult  = input.float(3.9, "ATR Multiplier", minval=0.1, maxval=20.0, step=0.1, group=g_st, inline="s")
int   i_avLen   = input.int(52, "2021: EMA Length", minval=1, maxval=500, group=g_av, inline="a1")
int   i_avSm    = input.int(10, "EMA Length (Smoothing)", minval=1, maxval=500, group=g_av, inline="a1")
int   i_av3Len  = input.int(9, "Today (v2.3): MA Period", minval=1, maxval=500, group=g_av)
int   i_emaLen  = input.int(200, "Trend EMA", minval=1, maxval=1000, group=g_e)
int   i_sslLen  = input.int(60, "SSL Baseline Length (HMA)", minval=2, maxval=500, group=g_e, inline="b")
float i_sslMult = input.float(0.2, "Channel Multiplier", minval=0.0, maxval=5.0, step=0.05, group=g_e, inline="b")

string i_show   = input.string("A · 2021 indicators", "Log drawn on the chart", options=["A · 2021 indicators", "A · today's indicators", "B · break-even at 1R", "C · SuperTrend exit", "D · QQE MOD alone", "E · QQE + SSL + 200 EMA"], group=g_rule, tooltip="All six logs are in the table; this one draws its trades on the chart.")
bool   i_longs  = input.bool(true, "Take longs", group=g_rule)
bool   i_shorts = input.bool(true, "Take shorts", group=g_rule)

int   i_swingLen   = input.int(10, "Swing stop: lookback (candles), rules D and E", minval=2, maxval=200, group=g_exit, tooltip="Stop below the lowest low (long) or above the highest high (short) of this many candles, the signal candle included.")
float i_minAtr     = input.float(0.5, "Minimum stop distance (× ATR 14)", minval=0.0, maxval=5.0, step=0.1, group=g_exit, tooltip="Rules A to C put the stop beyond the A-V2 ribbon, rules D and E at the swing; it is never closer than this many ATR(14). That distance is 1R.")
float i_rr         = input.float(2.0, "Target (reward ratio), rules A, B, D, E", minval=0.5, maxval=10.0, step=0.5, group=g_exit)
float i_be         = input.float(1.0, "Rule B: stop to entry after (R)", minval=0.1, maxval=5.0, step=0.1, group=g_exit)
int   i_extendBars = input.int(30, "Extend open trade boxes (bars)", minval=5, maxval=200, group=g_exit)

int    i_ledgerN   = input.int(100, "Log size (last N trades per log)", minval=10, maxval=500, group=g_ledger)
bool   i_showTable = input.bool(true, "Show log table", group=g_ledger)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_ledger)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_ledger)

color i_bullCol    = input.color(#00E5A8, "Long colour", group=g_vis)
color i_bearCol    = input.color(#FF3B5C, "Short colour", group=g_vis)
bool  i_showTrades = input.bool(true, "Draw trades on the chart", group=g_vis)
int   i_keepTrades = input.int(120, "Trades kept on chart", minval=1, maxval=200, group=g_vis)
int   i_boxFill    = input.int(78, "Box fill transparency", minval=50, maxval=95, group=g_vis)

bool i_alertJson = input.bool(true, "Send JSON alert() messages", group=g_alert)

color c_white  = #FFFFFF
color c_dark   = #0B0F14
color c_purple = #A259FF
color c_grey   = #9AA4AE
bool  confirmed = barstate.isconfirmed

// ─── QQE MOD (Mihkel00) ────────────────────────────────────────────────────────
// one QQE line -> [trend line, smoothed RSI]; twice = the 2020 version (the band width averaged a second time)
f_qqe(float src, int len, int sf, float fac, bool twice) =>
    int   wl     = len * 2 - 1
    float rsiMa  = ta.ema(ta.rsi(src, len), sf)
    float atrRsi = math.abs(rsiMa[1] - rsiMa)
    float ma1    = ta.ema(atrRsi, wl)
    float ma2    = ta.ema(ma1, wl)                       // computed on every bar; used by the 2020 version only
    float dar    = (twice ? ma2 : ma1) * fac
    float longBand  = 0.0
    float shortBand = 0.0
    float newShort  = rsiMa + dar
    float newLong   = rsiMa - dar
    longBand  := rsiMa[1] > longBand[1] and rsiMa > longBand[1] ? math.max(longBand[1], newLong) : newLong
    shortBand := rsiMa[1] < shortBand[1] and rsiMa < shortBand[1] ? math.min(shortBand[1], newShort) : newShort
    bool upX = ta.cross(rsiMa, shortBand[1])
    bool dnX = ta.cross(longBand[1], rsiMa)
    int  trend = 0
    trend := upX ? 1 : dnX ? -1 : twice ? nz(trend[1], 1) : trend[1]
    [trend == 1 ? longBand : shortBand, rsiMa]

f_qqeMod(bool twice) =>
    [tl1, r1] = f_qqe(close, i_qLen, i_qSf, i_qFac, twice)
    [tl2, r2] = f_qqe(close, i_qLen, i_qSf, i_qFac2, twice)
    float basis = ta.sma(tl1 - 50, i_bbLen)
    float dev   = i_bbMult * ta.stdev(tl1 - 50, i_bbLen)
    bool blue = r2 - 50 > i_qThr and r1 - 50 > basis + dev
    bool red  = r2 - 50 < -i_qThr and r1 - 50 < basis - dev
    [blue, red, r1, r2, basis, dev]

[qBlueOld, qRedOld, q1Old, q2Old, qBasisOld, qDevOld] = f_qqeMod(true)
[qBlueNew, qRedNew, q1New, q2New, qBasisNew, qDevNew] = f_qqeMod(false)

// ─── SUPERTREND (KivancOzbilgic) ───────────────────────────────────────────────
float stAtr = ta.atr(i_stLen)
float stUp  = hl2 - i_stMult * stAtr
float stUp1 = nz(stUp[1], stUp)
stUp := close[1] > stUp1 ? math.max(stUp, stUp1) : stUp
float stDn  = hl2 + i_stMult * stAtr
float stDn1 = nz(stDn[1], stDn)
stDn := close[1] < stDn1 ? math.min(stDn, stDn1) : stDn
int stTrend = 1
stTrend := nz(stTrend[1], stTrend)
stTrend := stTrend == -1 and close > stDn1 ? 1 : stTrend == 1 and close < stUp1 ? -1 : stTrend

// ─── TREND INDICATOR A-V2 (Dziwne): the request it makes ───────────────────────
float haO = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, open, lookahead=barmerge.lookahead_off)
float haH = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, high, lookahead=barmerge.lookahead_off)
float haL = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, low, lookahead=barmerge.lookahead_off)
float haC = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close, lookahead=barmerge.lookahead_off)
// 2021 (A-V2): EMA, then EMA again (smoothing); green when close - open > 0
float avO  = ta.ema(ta.ema(haO, i_avLen), i_avSm)
float avC  = ta.ema(ta.ema(haC, i_avLen), i_avSm)
bool  avGreen = avC - avO > 0
// today (A v2.3): one EMA; green when 100 × (close - open) / (high - low) > 0
float av3O = ta.ema(haO, i_av3Len)
float av3C = ta.ema(haC, i_av3Len)
float av3H = ta.ema(haH, i_av3Len)
float av3L = ta.ema(haL, i_av3Len)
float av3T = 100 * (av3C - av3O) / (av3H - av3L)
bool  av3Green = av3T > 0

// ─── RULE E: 200 EMA AND THE SSL HYBRID BASELINE (Mihkel00) ────────────────────
float ema200 = ta.ema(close, i_emaLen)
float bbmc   = ta.wma(2 * ta.wma(close, int(i_sslLen / 2)) - ta.wma(close, i_sslLen), int(math.round(math.sqrt(i_sslLen))))
float rangeE = ta.ema(ta.tr, i_sslLen)
bool  sslBlue = close > bbmc + rangeE * i_sslMult
bool  sslRed  = close < bbmc - rangeE * i_sslMult

// ─── CONDITIONS (all computed on every candle) ─────────────────────────────────
bool aL  = stTrend == 1 and qBlueOld and avGreen
bool aS  = stTrend == -1 and qRedOld and not avGreen
bool atL = stTrend == 1 and qBlueNew and av3Green
bool atS = stTrend == -1 and qRedNew and not av3Green
bool eL  = close > ema200 and qBlueNew and sslBlue
bool eS  = close < ema200 and qRedNew and sslRed
bool aLn  = aL and not aL[1]
bool aSn  = aS and not aS[1]
bool atLn = atL and not atL[1]
bool atSn = atS and not atS[1]
bool dLn  = qBlueNew and not qBlueNew[1]
bool dSn  = qRedNew and not qRedNew[1]
bool eLn  = eL and not eL[1]
bool eSn  = eS and not eS[1]
bool stFlipDn = stTrend == -1 and stTrend[1] == 1
bool stFlipUp = stTrend == 1 and stTrend[1] == -1

// ─── TRADE LOGS ────────────────────────────────────────────────────────────────
// six logs: 0 A (2021), 1 A today, 2 B, 3 C, 4 D, 5 E
type Book
    int   dir = 0
    float entry
    float stop
    float target
    float risk
    bool  beDone = false
    int   bar
    array<float> res
    array<int>   tms

var array<Book> books = array.new<Book>()
if barstate.isfirst
    for i = 0 to 5
        array.push(books, Book.new(0, na, na, na, na, false, na, array.new<float>(), array.new<int>()))

int showIdx = switch i_show
    "A · 2021 indicators"    => 0
    "A · today's indicators" => 1
    "B · break-even at 1R"   => 2
    "C · SuperTrend exit"    => 3
    "D · QQE MOD alone"      => 4
    => 5

f_rr(int i) =>
    i == 3 ? 0.0 : i_rr

f_dir(bool b, bool s) =>
    b and not s and i_longs ? 1 : s and not b and i_shorts ? -1 : 0

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
// rr > 0: fixed target; rr == 0: exit at this close when xLong / xShort says so; be > 0: stop to entry after be × R
f_settle(Book b, float rr, bool xLong, bool xShort, float be) =>
    float r = na
    float x = na
    if b.dir != 0 and bar_index > b.bar
        bool stopHit = b.dir == 1 ? low <= b.stop : high >= b.stop
        if stopHit
            x := b.stop
            r := math.round(b.dir * (b.stop - b.entry) / b.risk, 2)
        else if rr > 0
            bool targetHit = b.dir == 1 ? high >= b.target : low <= b.target
            if targetHit
                r := rr
                x := b.target
        else if (b.dir == 1 and xLong) or (b.dir == -1 and xShort)
            x := close
            r := math.round(b.dir * (close - b.entry) / b.risk, 2)
        if na(r) and be > 0 and not b.beDone
            bool reached = b.dir == 1 ? high >= b.entry + be * b.risk : low <= b.entry - be * b.risk
            if reached
                b.stop := b.entry
                b.beDone := true
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
    b.risk := math.abs(e - s)
    b.beDone := false
    b.bar := bar_index

array<float> res = array.from(float(na), na, na, na, na, na)
if confirmed and array.size(books) == 6
    for i = 0 to 5
        Book b = array.get(books, i)
        int dPrev = b.dir
        [r, x] = f_settle(b, f_rr(i), i == 3 and stFlipDn, i == 3 and stFlipUp, i == 2 ? i_be : 0.0)
        array.set(res, i, r)
        if i == showIdx and i_showTrades and not na(r)
            bool win = r > 0
            if not na(dRisk)
                box.set_right(dRisk, bar_index)
            if not na(dTarget)
                box.set_right(dTarget, bar_index)
            label rl = label.new(bar_index, x, (win ? "+" : "") + str.tostring(r, "#.#") + "R", color=win ? i_bullCol : r == 0 ? c_grey : i_bearCol, textcolor=win ? c_dark : c_white, style=dPrev == 1 ? (win ? label.style_label_down : label.style_label_up) : (win ? label.style_label_up : label.style_label_down), size=size.small)
            array.push(dLabels, rl)
            dRisk := na
            dTarget := na
            f_trim()
            if i_alertJson
                alert('{"action":"EXIT","indicator":"QMVL","log":"' + i_show + '","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","r":' + str.tostring(r) + '}', alert.freq_once_per_bar_close)

// ─── STOPS ─────────────────────────────────────────────────────────────────────
float swingLo = ta.lowest(low, i_swingLen)
float swingHi = ta.highest(high, i_swingLen)
float atrV    = ta.atr(14)
bool  ready   = not na(swingLo) and not na(swingHi) and not na(atrV) and not na(avO) and not na(av3T) and not na(ema200)
float minD    = math.max(nz(atrV) * i_minAtr, syminfo.mintick * 5)
// rules A-C: beyond the A-V2 ribbon (the 2021 one, or today's for "A today")
float ribLo2021 = math.min(avO, avC)
float ribHi2021 = math.max(avO, avC)
float ribLoNow  = math.min(av3O, av3C)
float ribHiNow  = math.max(av3O, av3C)
float stopL2021 = math.min(ribLo2021, close - minD)
float stopS2021 = math.max(ribHi2021, close + minD)
float stopLNow  = math.min(ribLoNow, close - minD)
float stopSNow  = math.max(ribHiNow, close + minD)
float stopLSw   = math.min(swingLo, close - minD)
float stopSSw   = math.max(swingHi, close + minD)

// ─── SIGNALS ───────────────────────────────────────────────────────────────────
array<int> sig = array.from(0, 0, 0, 0, 0, 0)
if confirmed and ready
    int dA = f_dir(aLn, aSn)
    array.set(sig, 0, dA)
    array.set(sig, 1, f_dir(atLn, atSn))
    array.set(sig, 2, dA)
    array.set(sig, 3, dA)
    array.set(sig, 4, f_dir(dLn, dSn))
    array.set(sig, 5, f_dir(eLn, eSn))

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
            float s = i == 1 ? (d == 1 ? stopLNow : stopSNow) : i >= 4 ? (d == 1 ? stopLSw : stopSSw) : (d == 1 ? stopL2021 : stopS2021)
            float rr = f_rr(i)
            float e = close
            float t = rr > 0 ? e + d * math.abs(e - s) * rr : na
            f_open(b, d, e, s, t)
            openMask += int(math.pow(2, i))
            if i == showIdx
                showEntry := e
                showStop := s
                showTarget := t
                showOpened := true

int sigShow = array.get(sig, showIdx)
if i_showTrades and showOpened
    dRisk := box.new(bar_index, math.max(showEntry, showStop), bar_index + i_extendBars, math.min(showEntry, showStop), bgcolor=color.new(i_bearCol, i_boxFill + 6), border_color=color.new(i_bearCol, 45), border_width=1)
    array.push(dBoxes, dRisk)
    if not na(showTarget)
        dTarget := box.new(bar_index, math.max(showEntry, showTarget), bar_index + i_extendBars, math.min(showEntry, showTarget), bgcolor=color.new(i_bullCol, i_boxFill), border_color=color.new(i_bullCol, 35), border_width=1)
        array.push(dBoxes, dTarget)
    string exitTxt = showIdx == 3 ? "\nExit: SuperTrend flips the other way" : "\nTarget " + str.tostring(showTarget, format.mintick) + " (" + str.tostring(i_rr, "#.#") + "R)" + (showIdx == 2 ? ", stop to entry at " + str.tostring(i_be, "#.#") + "R" : "")
    string tip = (sigShow == 1 ? "LONG" : "SHORT") + " · " + i_show + "\nEntry " + str.tostring(showEntry, format.mintick) + "\nStop " + str.tostring(showStop, format.mintick) + exitTxt
    label el = label.new(bar_index, showStop, sigShow == 1 ? "LONG" : "SHORT", color=color.new(sigShow == 1 ? i_bullCol : i_bearCol, 20), textcolor=sigShow == 1 ? c_dark : c_white, style=sigShow == 1 ? label.style_label_up : label.style_label_down, size=size.small, tooltip=tip)
    array.push(dLabels, el)
    f_trim()
    if i_alertJson
        alert('{"action":"' + (sigShow == 1 ? "LONG" : "SHORT") + '","indicator":"QMVL","log":"' + i_show + '","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(showEntry) + ',"stop":' + str.tostring(showStop) + '}', alert.freq_once_per_bar_close)
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

array<string> names = array.from("A 2021 indicators", "A today's indicators", "B break-even at 1R", "C SuperTrend exit", "D QQE MOD alone", "E QQE + SSL + 200 EMA")
array<float>  totals = array.new<float>(6, 0.0)
array<int>    counts = array.new<int>(6, 0)
for i = 0 to 5
    [n, w, tot, days] = f_stats(i)
    array.set(totals, i, tot)
    array.set(counts, i, n)

if i_showTable and barstate.islast
    var table led = table.new(f_pos(i_tablePos), 6, 8, bgcolor=color.new(c_dark, 8), border_color=color.new(c_purple, 45), border_width=1, frame_color=color.new(c_purple, 15), frame_width=2)
    string ts  = i_tableSize == "Large" ? size.normal : i_tableSize == "Small" ? size.tiny : size.small
    string tsH = i_tableSize == "Large" ? size.large : i_tableSize == "Small" ? size.small : size.normal
    color lab = c_grey
    table.cell(led, 0, 0, "QQE MOD VERDICT LAB · last " + str.tostring(i_ledgerN) + " trades per log", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
    table.merge_cells(led, 0, 0, 5, 0)
    table.cell(led, 0, 1, "Log", text_color=lab, text_size=ts, text_halign=text.align_left)
    table.cell(led, 1, 1, "Trades", text_color=lab, text_size=ts)
    table.cell(led, 2, 1, "Wins", text_color=lab, text_size=ts)
    table.cell(led, 3, 1, "Win rate", text_color=lab, text_size=ts)
    table.cell(led, 4, 1, "Total R", text_color=lab, text_size=ts)
    table.cell(led, 5, 1, "Days", text_color=lab, text_size=ts)
    for i = 0 to 5
        [n, w, tot, days] = f_stats(i)
        table.cell(led, 0, 2 + i, array.get(names, i), text_color=c_white, text_size=ts, text_halign=text.align_left, bgcolor=i == showIdx ? color.new(c_purple, 80) : na)
        table.cell(led, 1, 2 + i, str.tostring(n), text_color=c_white, text_size=ts)
        table.cell(led, 2, 2 + i, str.tostring(w), text_color=i_bullCol, text_size=ts)
        table.cell(led, 3, 2 + i, n > 0 ? str.tostring(100.0 * w / n, "#.#") + " %" : "-", text_color=c_white, text_size=ts)
        table.cell(led, 4, 2 + i, f_r(tot), text_color=tot >= 0 ? i_bullCol : i_bearCol, text_size=ts)
        table.cell(led, 5, 2 + i, str.tostring(days), text_color=c_white, text_size=ts)

// ─── DATA-WINDOW PLOTS (read by tools, hidden) ─────────────────────────────────
plot(haO, "haO", display=display.data_window)
plot(haH, "haH", display=display.data_window)
plot(haL, "haL", display=display.data_window)
plot(haC, "haC", display=display.data_window)
plot(qDevOld, "qDevOld", display=display.data_window)
plot(qDevNew, "qDevNew", display=display.data_window)
plot(q1Old - 50, "q1Old", display=display.data_window)
plot(q2Old - 50, "q2Old", display=display.data_window)
plot(q1New - 50, "q1New", display=display.data_window)
plot(q2New - 50, "q2New", display=display.data_window)
plot(qBasisOld, "qBasisOld", display=display.data_window)
plot(qBasisNew, "qBasisNew", display=display.data_window)
plot(qBlueOld ? 1 : qRedOld ? -1 : 0, "qOld", display=display.data_window)
plot(qBlueNew ? 1 : qRedNew ? -1 : 0, "qNew", display=display.data_window)
plot(stTrend, "stTrend", display=display.data_window)
plot(avGreen ? 1 : -1, "av2021", display=display.data_window)
plot(av3Green ? 1 : -1, "avNow", display=display.data_window)
plot(sslBlue ? 1 : sslRed ? -1 : 0, "ssl", display=display.data_window)
plot(ema200, "ema200", display=display.data_window)
plot(array.get(sig, 0), "sig0", display=display.data_window)
plot(array.get(sig, 1), "sig1", display=display.data_window)
plot(array.get(sig, 2), "sig2", display=display.data_window)
plot(array.get(sig, 3), "sig3", display=display.data_window)
plot(array.get(sig, 4), "sig4", display=display.data_window)
plot(array.get(sig, 5), "sig5", display=display.data_window)
plot(array.get(res, 0), "res0", display=display.data_window)
plot(array.get(res, 1), "res1", display=display.data_window)
plot(array.get(res, 2), "res2", display=display.data_window)
plot(array.get(res, 3), "res3", display=display.data_window)
plot(array.get(res, 4), "res4", display=display.data_window)
plot(array.get(res, 5), "res5", display=display.data_window)
plot(array.get(totals, 0), "tot0", display=display.data_window)
plot(array.get(totals, 1), "tot1", display=display.data_window)
plot(array.get(totals, 2), "tot2", display=display.data_window)
plot(array.get(totals, 3), "tot3", display=display.data_window)
plot(array.get(totals, 4), "tot4", display=display.data_window)
plot(array.get(totals, 5), "tot5", display=display.data_window)
plot(array.get(counts, 0), "n0", display=display.data_window)
plot(openMask, "openMask", display=display.data_window)
plot(stopL2021, "stopL2021", display=display.data_window)
plot(stopS2021, "stopS2021", display=display.data_window)
plot(stopLNow, "stopLNow", display=display.data_window)
plot(stopSNow, "stopSNow", display=display.data_window)
plot(stopLSw, "stopLSw", display=display.data_window)
plot(stopSSw, "stopSSw", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(sigShow == 1,  "QMVL Long entry",  "QQE MOD Verdict Lab: LONG on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigShow == -1, "QMVL Short entry", "QQE MOD Verdict Lab: SHORT on {{ticker}} {{interval}} at {{close}}")
````
