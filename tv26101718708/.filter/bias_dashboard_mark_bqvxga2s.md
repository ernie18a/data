# Bias Dashboard (Mark)

- url: https://www.tradingview.com/script/bQVXgA2S-Bias-Dashboard-Mark/
- type: indicator
- pine_id: PUB;7aaed38083694f0187246a30528d818a
- version: 3.0

## Description

# Bias Dashboard — Documentation
### Developed for NQ Futures Trading | Version 1.0

---

## Overview

The Bias Dashboard is a TradingView Pine Script indicator designed to answer one simple question at any point during the trading day:

**Is the market breaking Long, Short, or is there no clear direction?**

It is designed for NQ futures traders but works on any instrument. It runs on the 1-minute chart and analyzes the last 90 bars of price action to determine trend direction, trend strength, momentum, volume, VWAP positioning, and EMA alignment — combining all of these into a single **Conviction** verdict.

The indicator operates in three modes and is intended to be used as a confirmation and confluence tool, not as a standalone entry signal.

---

## Modes

The indicator has three operating modes, selectable in the settings:

### ⚡ LIVE Mode
The dashboard updates in real time on every candle close. Use this mode throughout the trading day to monitor ongoing market bias. Ideal for continuously gauging whether conditions favor a long or short trade at any given moment.

### 🔔 MOC Mode (Market on Close — 3:50 PM ET)
The dashboard runs live until 3:50 PM ET, at which point it locks and freezes its readings. This gives you a snapshot of market conditions at the critical pre-close window. The snapshot holds until midnight ET, then resets automatically for the next session.

Use this mode to evaluate bias for the 3:50 PM MOC trade. The indicator looks back 90 one-minute bars from the anchor time to assess whether the trend has the strength and conviction to continue into the close.

### 🌏 ASIAN Mode (Asian Open — 8:00 PM ET)
Identical behavior to MOC mode, but anchors at 8:00 PM ET for the Asian session open. Locks at that time and resets at midnight.

Use this mode to evaluate whether the post-US-session trend has enough conviction to continue into the Asian open.

---

## What the Dashboard Shows

The dashboard displays six rows of information plus a verdict bar at the bottom.

### Direction
The overall market direction based on trend structure and momentum alignment.
- **▲ LONG** — conditions favor a long trade
- **▼ SHORT** — conditions favor a short trade
- **— FLAT** — no clear directional bias

### Conviction
How strongly all inputs agree on the stated direction. This is the most important output of the indicator. There are five levels:
- 🟢 **CONFIRMED** — All or nearly all inputs agree. High confidence trade.
- 🟡 **PROBABLE** — Most inputs agree. Good conditions, proceed normally.
- 🟠 **MARGINAL** — Mixed signals. Proceed with caution or reduce size.
- 🔴 **WEAK** — More inputs disagree than agree. Lean toward sitting out.
- ⬜ **NO TRADE** — No meaningful directional bias. Stay out.

### Trend
The strength of the prevailing trend over the last 90 one-minute bars.
- **Strong** — Price is making a clear, sustained directional move with significant slope
- **Moderate** — A trend exists but is less decisive
- **Weak** — Little or no trend structure present

This is measured using two methods simultaneously: pivot high/low structure (higher highs and higher lows for an uptrend, lower highs and lower lows for a downtrend) and a linear regression slope normalized against the Average True Range. Both must agree for a strong trend reading.

### Mom / Vol (Momentum and Volume)
Whether the current candles are showing genuine directional momentum backed by volume. Momentum and volume are treated as a single combined input because strong momentum without volume is a fake move, and strong volume without momentum is absorption — neither alone is sufficient.
- **Strong Long / Strong Short** — Large-bodied candles closing near their extremes, with volume above the 20-bar average
- **Moderate Long / Moderate Short** — Decent candle bodies with average volume
- **Weak / Mixed** — Small bodies, long wicks, or low volume — no conviction

### VWAP
Where price is relative to the Volume Weighted Average Price and which direction VWAP is sloping.
- **Above — Rising** — Price above VWAP and VWAP trending up. Institutional buying pressure. Bullish.
- **Above — Falling** — Price above VWAP but VWAP turning down. Weakening bullish condition.
- **Below — Falling** — Price below VWAP and VWAP trending down. Institutional selling pressure. Bearish.
- **Below — Rising** — Price below VWAP but VWAP turning up. Weakening bearish condition.
- **At VWAP** — Price is at the VWAP level. Decision point. Proceed with caution.

VWAP acts as a magnet — price tends to revert to it over time. This means a trade taken when price is already far from VWAP carries more mean-reversion risk than one taken when price is just breaking away from it cleanly.

### EMA Stack
The alignment of three Exponential Moving Averages — the 9, 20, and 50 EMA.
- **Bull 9>20>50** — All three EMAs in bullish order. Trend is confirmed across multiple timeframes.
- **Bear 9<20<50** — All three EMAs in bearish order. Trend is confirmed across multiple timeframes.
- **Mixed** — EMAs are not fully aligned. Short term and longer term momentum disagree.

A fully aligned EMA stack that agrees with the direction adds conviction. A stack that fights the direction reduces conviction.

### Verdict Bar
The bottom row of the dashboard combines Direction and Conviction into a single colored statement, for example:

**▲ LONG — CONFIRMED**

The background color of this bar matches the conviction level — green for confirmed/probable, orange for marginal, red for weak. This is designed to be readable at a glance without reading the individual rows above it.

---

## How Conviction is Calculated

The conviction engine works in two steps.

**Step 1 — Base Conviction Matrix**

Trend Strength and Momentum/Volume are multiplied together to produce a base conviction level:

| | Strong Trend | Moderate Trend | Weak Trend |
|---|---|---|---|
| **Strong Mom/Vol** | CONFIRMED | PROBABLE | MARGINAL |
| **Moderate Mom/Vol** | PROBABLE | MARGINAL | WEAK |
| **Weak Mom/Vol** | MARGINAL | WEAK | NO TRADE |

**Step 2 — Adjustments**

VWAP and EMA Stack each cast a vote:
- Agrees with direction = +1
- Neutral = 0
- Fights direction = -1

The two votes are combined. If both agree, conviction bumps up one level. If both fight the direction, conviction drops one level. Mixed votes leave base conviction unchanged.

This means the maximum possible conviction is CONFIRMED, and the minimum is NO TRADE, regardless of how extreme the adjustments are.

---

## How to Use It

**For MOC and Asian Open trades:**

Load the indicator in MOC or ASIAN mode. Watch the dashboard update live in the 90 minutes leading up to the event. At the anchor time it will lock. Use the frozen snapshot to decide whether conditions support a trade.

A CONFIRMED or PROBABLE verdict with a clear direction is your green light to look for an entry. MARGINAL means proceed carefully with reduced size. WEAK or NO TRADE means sit this one out.

**In LIVE mode:**

The dashboard updates continuously. Use it as a real-time bias check at any point during the session. It is particularly useful during low-volume or choppy periods when direction is unclear — a NO TRADE reading is a valid and valuable signal to stay out.

---

## Settings

| Setting | Default | Description |
|---|---|---|
| Mode | LIVE | LIVE, MOC, or ASIAN |
| Trend Lookback | 90 bars | Number of 1-minute bars for trend analysis |
| Momentum Bars | 4 bars | Number of recent candles for momentum read |
| Dashboard Position | Top Right | Top Right, Top Left, Bottom Right, Bottom Left |
| Background Color | Dark black | Dashboard background |
| Border Color | Soft white | Table border |
| Header Color | Navy | Mode header row |
| Text Color | White | Primary text |
| Label Color | Subtle white | Row label text |

---

## Important Notes

- This indicator is a **confluence tool**, not an entry signal. It tells you whether conditions are favorable. It does not tell you exactly when or where to enter. That judgment remains yours.
- On NQ futures, unexpected news events — economic data releases, policy announcements, geopolitical developments — can override any technical reading instantly. No indicator can account for surprise news.
- The indicator is designed primarily for NQ but is portable to ES, GC, CL, and other instruments without modification.
- Always trade within your risk management rules regardless of what the indicator shows. A CONFIRMED reading is not a guarantee.

---

*Bias Dashboard — Built for the trading group. Use it as one voice among several, not the only voice.*

## Source Code

````pine
//@version=6
indicator("Bias Dashboard (Mark)", overlay=true, max_labels_count=100)

//─────────────────────────────────────────────────────────────────────────────
// STOPLIGHT BIAS INDICATOR
// Four modes: LIVE / NY / MOC / ASIAN
// Single panel — configurable position
//─────────────────────────────────────────────────────────────────────────────

//─────────────────────────────────────────────
// INPUTS
//─────────────────────────────────────────────
modeIn    = input.string("LIVE", "Mode",               options=["LIVE", "NY", "MOC", "ASIAN"])
lookback  = input.int(90,   "Trend Lookback (bars)", minval=20, maxval=200)
momBars   = input.int(4,    "Momentum Bars",          minval=2,  maxval=10)
dashPosIn = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"])

// Color inputs
bgCol     = input.color(color.new(color.black, 15),  "Background Color")
borderCol = input.color(color.new(color.white, 60),  "Border Color")
hdrCol    = input.color(color.new(color.navy,  20),  "Header Color")
txtCol    = input.color(color.white,                 "Text Color")
subtleCol = input.color(color.new(color.white, 40),  "Label Color")

//─────────────────────────────────────────────
// TIME CONSTANTS  (all Eastern / New York)
//─────────────────────────────────────────────
TZ = "America/New_York"

// NY Open — live 9:00, lock 9:29:30, reset 10:00
nyWindow    = timestamp(TZ, year, month, dayofmonth,  9,  0)
nyLock      = timestamp(TZ, year, month, dayofmonth,  9, 29, 30)
nyReset     = timestamp(TZ, year, month, dayofmonth, 10,  0)

// MOC — live 3:30, lock 3:49:30, reset 4:30
mocWindow   = timestamp(TZ, year, month, dayofmonth, 15, 30)
mocLock     = timestamp(TZ, year, month, dayofmonth, 15, 49, 30)
mocReset    = timestamp(TZ, year, month, dayofmonth, 16, 30)

// ASIAN — live 7:30, lock 7:59:30, reset 8:00
asianWindow = timestamp(TZ, year, month, dayofmonth, 19, 30)
asianLock   = timestamp(TZ, year, month, dayofmonth, 19, 59, 30)
asianReset  = timestamp(TZ, year, month, dayofmonth, 20, 30)

// Per-bar booleans — resets are one-minute windows
isNYLive    = time >= nyWindow    and time <  nyLock
isNYBar     = time >= nyLock      and time <  nyLock     + 60000
isNYReset   = time >= nyReset     and time <  nyReset    + 60000

isMOCLive   = time >= mocWindow   and time <  mocLock
isMOCBar    = time >= mocLock     and time <  mocLock    + 60000
isMOCReset  = time >= mocReset    and time <  mocReset   + 60000

isAsianLive = time >= asianWindow and time <  asianLock
isAsianBar  = time >= asianLock   and time <  asianLock  + 60000
isAsianReset= time >= asianReset  and time <  asianReset + 60000

//─────────────────────────────────────────────
// VWAP  (10-bar slope avoids session boundary distortion)
//─────────────────────────────────────────────
vwapValue = ta.vwap(hlc3)
vwapSlope = not na(vwapValue[10]) ? vwapValue - vwapValue[10] : vwapValue - vwapValue[5]

//─────────────────────────────────────────────
// TREND DIRECTION + STRENGTH
//─────────────────────────────────────────────
ph = ta.pivothigh(high, 5, 5)
pl = ta.pivotlow(low,   5, 5)

var float lastPH = na
var float prevPH = na
var float lastPL = na
var float prevPL = na

if not na(ph)
    prevPH := lastPH
    lastPH := ph

if not na(pl)
    prevPL := lastPL
    lastPL := pl

hhhl = not na(lastPH) and not na(prevPH) and not na(lastPL) and not na(prevPL) and lastPH > prevPH and lastPL > prevPL
lhll = not na(lastPH) and not na(prevPH) and not na(lastPL) and not na(prevPL) and lastPH < prevPH and lastPL < prevPL

trendDirLong  = hhhl and not lhll
trendDirShort = lhll and not hhhl

lrSlope       = ta.linreg(close, lookback, 0) - ta.linreg(close, lookback, lookback - 1)
lrSlopeAbs    = math.abs(lrSlope)
atr14         = ta.atr(14)
strengthRatio = atr14 > 0 ? lrSlopeAbs / atr14 : 0

trendStrong   = strengthRatio >= 0.4  and (trendDirLong or trendDirShort)
trendModerate = strengthRatio >= 0.15 and strengthRatio < 0.4 and (trendDirLong or trendDirShort)
trendLevel    = trendStrong ? 2 : trendModerate ? 1 : 0

trendStr = trendStrong ? "Strong" : trendModerate ? "Moderate" : "Weak"

//─────────────────────────────────────────────
// MOMENTUM + VOLUME
//─────────────────────────────────────────────
bullCount    = 0
bearCount    = 0
avgBodyRatio = 0.0

for i = 0 to momBars - 1
    if close[i] > open[i]
        bullCount += 1
    if close[i] < open[i]
        bearCount += 1
    totalR        = high[i] - low[i]
    bodyR         = math.abs(close[i] - open[i])
    avgBodyRatio += totalR > 0 ? bodyR / totalR : 0.0

avgBodyRatio := avgBodyRatio / momBars

volMA    = ta.sma(volume, 20)
volRatio = volMA > 0 ? volume / volMA : 1.0

momBull = bullCount >= math.round(momBars * 0.6)
momBear = bearCount >= math.round(momBars * 0.6)

momVolStrong   = avgBodyRatio >= 0.55 and volRatio >= 1.1
momVolModerate = avgBodyRatio >= 0.40 and volRatio >= 0.85

momLevelBull = momBull ? (momVolStrong ? 2 : momVolModerate ? 1 : 0) : 0
momLevelBear = momBear ? (momVolStrong ? 2 : momVolModerate ? 1 : 0) : 0

momStr = momLevelBull == 2 ? "Strong Long" : momLevelBull == 1 ? "Moderate Long" : momLevelBear == 2 ? "Strong Short" : momLevelBear == 1 ? "Moderate Short" : "Weak / Mixed"

//─────────────────────────────────────────────
// EMA STACK  (9 / 20 / 50)
//─────────────────────────────────────────────
ema9  = ta.ema(close, 9)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)

emaBullStack = ema9 > ema20 and ema20 > ema50
emaBearStack = ema9 < ema20 and ema20 < ema50

emaVoteLong  = emaBullStack ? 1 : emaBearStack ? -1 : 0
emaVoteShort = emaBearStack ? 1 : emaBullStack ? -1 : 0

emaStr = emaBullStack ? "Bull  9>20>50" : emaBearStack ? "Bear  9<20<50" : "Mixed"

//─────────────────────────────────────────────
// VWAP VOTE
//─────────────────────────────────────────────
vwapVoteLong  = close > vwapValue and vwapSlope > 0 ? 1 : close < vwapValue or  vwapSlope < 0 ? -1 : 0
vwapVoteShort = close < vwapValue and vwapSlope < 0 ? 1 : close > vwapValue or  vwapSlope > 0 ? -1 : 0

vwapStr = close > vwapValue and vwapSlope > 0 ? "Above — Rising"  :
          close > vwapValue and vwapSlope < 0 ? "Above — Falling" :
          close < vwapValue and vwapSlope < 0 ? "Below — Falling" :
          close < vwapValue and vwapSlope > 0 ? "Below — Rising"  :
          "At VWAP"

//─────────────────────────────────────────────
// BASE CONVICTION MATRIX
//─────────────────────────────────────────────
f_baseConv(int trendLvl, int momLvl) =>
    int result = 0
    if trendLvl == 2
        if momLvl == 2
            result := 4
        else if momLvl == 1
            result := 3
        else
            result := 2
    else if trendLvl == 1
        if momLvl == 2
            result := 3
        else if momLvl == 1
            result := 2
        else
            result := 1
    else
        if momLvl == 2
            result := 2
        else if momLvl == 1
            result := 1
        else
            result := 0
    result

baseConvLong  = trendDirLong  ? f_baseConv(trendLevel, momLevelBull) : 0
baseConvShort = trendDirShort ? f_baseConv(trendLevel, momLevelBear) : 0

totalAdjLong  = math.max(-2, math.min(2, vwapVoteLong  + emaVoteLong))
totalAdjShort = math.max(-2, math.min(2, vwapVoteShort + emaVoteShort))

finalConvLong  = math.max(0, math.min(4, baseConvLong  + math.max(-1, math.min(1, totalAdjLong))))
finalConvShort = math.max(0, math.min(4, baseConvShort + math.max(-1, math.min(1, totalAdjShort))))

//─────────────────────────────────────────────
// DIRECTION + MASTER CONVICTION
//─────────────────────────────────────────────
dirLong  = finalConvLong  > finalConvShort and finalConvLong  > 0
dirShort = finalConvShort > finalConvLong  and finalConvShort > 0
dirFlat  = not dirLong and not dirShort

masterConv = dirLong ? finalConvLong : dirShort ? finalConvShort : 0

f_convText(int c) => c == 4 ? "CONFIRMED" : c == 3 ? "PROBABLE" : c == 2 ? "MARGINAL" : c == 1 ? "WEAK" : "NO TRADE"
f_dirText()       => dirLong ? "▲  LONG" : dirShort ? "▼  SHORT" : "—  FLAT"

//─────────────────────────────────────────────
// SNAPSHOT STATE
//─────────────────────────────────────────────
var bool   snapLocked    = false
var int    snapConv      = 0
var bool   snapDirLong   = false
var bool   snapDirShort  = false
var string snapDir       = "…"
var string snapConvStr   = "…"
var string snapVWAPStr   = "…"
var string snapMomStr    = "…"
var int    snapConvLevel = 0

//─────────────────────────────────────────────
// RESET  (one-minute windows, mode-scoped)
// NY → 10:00am  |  MOC → 4:30pm  |  ASIAN → 8:00pm
//─────────────────────────────────────────────
shouldReset =
     modeIn == "NY"    ? isNYReset    :
     modeIn == "MOC"   ? isMOCReset   :
     modeIn == "ASIAN" ? isAsianReset :
     false

if shouldReset
    snapLocked    := false
    snapConv      := 0
    snapDirLong   := false
    snapDirShort  := false
    snapDir       := "…"
    snapConvStr   := "…"
    snapVWAPStr   := "…"
    snapMomStr    := "…"
    snapConvLevel := 0

//─────────────────────────────────────────────
// LIVE UPDATE WINDOW (feeds snapshot before lock)
//─────────────────────────────────────────────
isLiveWindow =
     modeIn == "LIVE"  ? true        :
     modeIn == "NY"    ? isNYLive    :
     modeIn == "MOC"   ? isMOCLive   :
     modeIn == "ASIAN" ? isAsianLive :
     false

if isLiveWindow and not snapLocked
    snapDir       := f_dirText()
    snapConvLevel := masterConv
    snapConvStr   := f_convText(masterConv)
    snapVWAPStr   := vwapStr
    snapMomStr    := momStr
    snapDirLong   := dirLong
    snapDirShort  := dirShort
    snapConv      := masterConv

//─────────────────────────────────────────────
// LOCK BARS
//─────────────────────────────────────────────
if modeIn == "NY" and isNYBar and not snapLocked
    snapLocked    := true
    snapConv      := masterConv
    snapConvLevel := masterConv
    snapConvStr   := f_convText(masterConv)
    snapDir       := f_dirText()
    snapDirLong   := dirLong
    snapDirShort  := dirShort
    snapVWAPStr   := vwapStr
    snapMomStr    := momStr

if modeIn == "MOC" and isMOCBar and not snapLocked
    snapLocked    := true
    snapConv      := masterConv
    snapConvLevel := masterConv
    snapConvStr   := f_convText(masterConv)
    snapDir       := f_dirText()
    snapDirLong   := dirLong
    snapDirShort  := dirShort
    snapVWAPStr   := vwapStr
    snapMomStr    := momStr

if modeIn == "ASIAN" and isAsianBar and not snapLocked
    snapLocked    := true
    snapConv      := masterConv
    snapConvLevel := masterConv
    snapConvStr   := f_convText(masterConv)
    snapDir       := f_dirText()
    snapDirLong   := dirLong
    snapDirShort  := dirShort
    snapVWAPStr   := vwapStr
    snapMomStr    := momStr

//─────────────────────────────────────────────
// ACTIVE VALUES
//─────────────────────────────────────────────
activeConv     = modeIn == "LIVE" ? masterConv : snapConv
activeDirLong  = modeIn == "LIVE" ? dirLong    : snapDirLong
activeDirShort = modeIn == "LIVE" ? dirShort   : snapDirShort

//─────────────────────────────────────────────
// DISPLAY FILTER
// Show when: LIVE always | others: in live window OR locked and not in reset minute
//─────────────────────────────────────────────
// Hard time-of-day gates (minutes since midnight ET)
// Prevents stale snapLocked data showing outside valid windows
currentMins  = hour(time, TZ) * 60 + minute(time, TZ)
inNYGate     = currentMins >= 540  and currentMins < 600    //  9:00am - 10:00am
inMOCGate    = currentMins >= 930  and currentMins < 990    //  3:30pm -  4:30pm
inAsianGate  = currentMins >= 1170 and currentMins < 1230   //  7:30pm -  8:30pm

showData =
     modeIn == "LIVE"  ? true :
     modeIn == "NY"    ? (inNYGate    and (isNYLive    or (snapLocked and not shouldReset))) :
     modeIn == "MOC"   ? (inMOCGate   and (isMOCLive   or (snapLocked and not shouldReset))) :
     modeIn == "ASIAN" ? (inAsianGate and (isAsianLive or (snapLocked and not shouldReset))) :
     false

//─────────────────────────────────────────────
// DISPLAY STRINGS
//─────────────────────────────────────────────
dispDir       = showData ? snapDir       : "…"
dispConvStr   = showData ? snapConvStr   : "…"
dispTrend     = showData ? trendStr      : "…"
dispMom       = showData ? snapMomStr    : "…"
dispVWAP      = showData ? snapVWAPStr   : "…"
dispEMA       = showData ? emaStr        : "…"
dispConvLevel = showData ? snapConvLevel : 0

//─────────────────────────────────────────────
// COLOR HELPERS
//─────────────────────────────────────────────
f_sideColor(string val) =>
    bool _bull = str.contains(val, "Long") or str.contains(val, "Above") or str.contains(val, "Rising") or str.contains(val, "Bull")
    bool _bear = str.contains(val, "Short") or str.contains(val, "Below") or str.contains(val, "Falling") or str.contains(val, "Bear")
    _bull ? color.lime : _bear ? color.red : color.white

f_convColor(int c) =>
    c == 4 ? color.lime : c == 3 ? color.yellow : c == 2 ? color.orange : c == 1 ? color.red : color.gray

//─────────────────────────────────────────────
// TABLE LABELS
//─────────────────────────────────────────────
modeLabel =
     modeIn == "LIVE"  ? "⚡  LIVE BIAS"              :
     modeIn == "NY"    ? "🗽  NY OPEN  —  9:29:30 ET"  :
     modeIn == "MOC"   ? "🔔  MOC  —  3:49:30 ET"     :
                         "🌏  ASIAN  —  7:59:30 ET"

verdictTxt = showData ? (dispDir + "   " + dispConvStr) : "…"
verdictCol = showData ? (activeDirLong ? color.lime : activeDirShort ? color.red : color.yellow) : color.new(color.white, 40)

BG     = bgCol
BORDER = borderCol
HDR    = hdrCol
SUBTLE = subtleCol
TXT    = txtCol

f_getPos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

//─────────────────────────────────────────────
// BUILD TABLE  (8 rows — veto row removed)
// Row 0:  mode header
// Row 1:  Direction
// Row 2:  Conviction
// Row 3:  Trend
// Row 4:  Mom / Vol  (LIVE + NY: live data  |  MOC + ASIAN: "—" dimmed)
// Row 5:  VWAP
// Row 6:  EMA Stack
// Row 7:  Verdict
//─────────────────────────────────────────────
var table dash = na

if barstate.islast
    dash := table.new(f_getPos(dashPosIn), 2, 8, bgcolor=BG, border_width=1, border_color=BORDER, frame_width=2, frame_color=borderCol)

    // ROW 0 — mode header
    table.cell(dash, 0, 0, modeLabel, text_color=TXT, bgcolor=HDR, text_size=size.normal, text_halign=text.align_center)
    table.cell(dash, 1, 0, "",        text_color=TXT, bgcolor=HDR, text_size=size.normal)

    // ROW 1 — Direction
    dirCol = showData ? (activeDirLong ? color.lime : activeDirShort ? color.red : color.yellow) : SUBTLE
    table.cell(dash, 0, 1, "Direction", text_color=SUBTLE, bgcolor=BG, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 1, dispDir,     text_color=dirCol, bgcolor=BG, text_size=size.normal, text_halign=text.align_right)

    // ROW 2 — Conviction
    convCol = showData ? f_convColor(dispConvLevel) : SUBTLE
    convBG  = showData ? color.new(convCol, 75) : BG
    table.cell(dash, 0, 2, "Conviction", text_color=SUBTLE,  bgcolor=convBG, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 2, dispConvStr,  text_color=convCol, bgcolor=convBG, text_size=size.normal, text_halign=text.align_right)

    // ROW 3 — Trend
    trendCol = showData ? (trendDirLong ? color.lime : trendDirShort ? color.red : color.gray) : SUBTLE
    table.cell(dash, 0, 3, "Trend",   text_color=SUBTLE,   bgcolor=BG, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 3, dispTrend, text_color=trendCol, bgcolor=BG, text_size=size.normal, text_halign=text.align_right)

    // ROW 4 — Mom / Vol
    // LIVE + NY: shows live momentum data
    // MOC + ASIAN: shows "—" dimmed — momentum not relevant in those sessions
    showMom   = modeIn == "LIVE" or modeIn == "NY"
    momCol    = showMom and showData ? f_sideColor(dispMom) : SUBTLE
    momTxt    = showMom ? dispMom : "—"
    momLblCol = showMom ? SUBTLE : color.new(SUBTLE, 60)
    table.cell(dash, 0, 4, "Mom / Vol", text_color=momLblCol, bgcolor=BG, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 4, momTxt,      text_color=momCol,    bgcolor=BG, text_size=size.normal, text_halign=text.align_right)

    // ROW 5 — VWAP
    vwapCol = showData ? f_sideColor(dispVWAP) : SUBTLE
    table.cell(dash, 0, 5, "VWAP",   text_color=SUBTLE,  bgcolor=BG, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 5, dispVWAP, text_color=vwapCol, bgcolor=BG, text_size=size.normal, text_halign=text.align_right)

    // ROW 6 — EMA Stack
    emaCol = showData ? (emaBullStack ? color.lime : emaBearStack ? color.red : color.gray) : SUBTLE
    table.cell(dash, 0, 6, "EMA Stack", text_color=SUBTLE, bgcolor=BG, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 6, dispEMA,     text_color=emaCol, bgcolor=BG, text_size=size.normal, text_halign=text.align_right)

    // ROW 7 — Verdict (full width, colored background)
    verdictBG = color.new(verdictCol, 70)
    table.cell(dash, 0, 7, verdictTxt, text_color=verdictCol, bgcolor=verdictBG, text_size=size.normal, text_halign=text.align_center)
    table.cell(dash, 1, 7, "",         text_color=verdictCol, bgcolor=verdictBG, text_size=size.normal)

//─────────────────────────────────────────────
// INVISIBLE PLOT (keeps pane open)
//─────────────────────────────────────────────
plot(0, display=display.none)
````
