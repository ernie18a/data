# SHIVA LT + LS Blend

- url: https://www.tradingview.com/script/O8uejOV1-SHIVA-LT-LS-Blend/
- type: indicator
- pine_id: PUB;4203a813192044f3a7cbdcb6336647d6
- version: 15.0

## Description

**LT + LS Blend — All-in-One Scalping & Momentum Indicator**

A comprehensive indicator that combines key level analysis, liquidity sweep detection, opening range breakout strategy, advanced VWAP bands, multi-timeframe confluence, and a real-time dashboard — all in a single overlay. Built for intraday traders focused on scalping and momentum entries with clearly defined risk.

---

**WHAT IT DOES**

This indicator blends two trading methodologies into one clean overlay:
- **LT (Key Level Confluence)** — identifies the most significant price levels where institutional and retail orders cluster
- **LS (Liquidity Sweep)** — detects when price sweeps a swing level and reverses, signalling a high-probability entry

When both methodologies agree on the same bar, a **★ CONFLUENCE signal ★** fires — the highest-conviction entry the indicator produces.

---

**SIGNALS**

🔴 **OPEN SELL / 🟢 OPEN BUY** — fires within the first 4 bars of the session when a strong directional candle touches a key resistance or support level (PDH, PM High/Low, gap). Designed to catch the first meaningful move of the day before swing pivots are established.

**BUY / SELL (Liquidity Sweep)** — triggers when price wicks through a confirmed swing low/high, closes back inside, and is confirmed by elevated volume (default 1.5× average). Graded by volume multiplier: Watch → Confirmed → Grade A → High Conviction. Signals showing **✓δ** are additionally confirmed by Volume Delta agreeing with the direction.

**↑ VWAP BUY / ↓ VWAP SELL** — price touches the VWAP or ±1SD band and bounces with a confirmed reversal candle.

**▲ ORB BREAK / ▼ ORB BREAK** — first clean close above OR High or below OR Low after the opening range locks.

**↩ ORB RETEST BUY / SELL** — price returns to retest the broken ORB level after a confirmed breakout.

---

**KEY LEVELS**

Drawn automatically each session:
- **PDH / PDL** — previous day high and low (dashed)
- **PM High / PM Low** — pre-market high and low (dotted)
- **Opening Price** — first print of the market session
- **OR High / OR Low** — opening range (configurable 1–120 min)
- **Hourly Opens** — last 8 hourly candle opens (auto-cleanup, no accumulation)
- **Previous ATH** — rolling 252-day high

---

**PIVOT POINTS & CPR**

Standard daily pivot points drawn at the start of each session:
- PP, R1, R2, S1, S2
- CPR Top and CPR Bottom (Central Pivot Range)
Narrow CPR = trending day. Wide CPR = choppy/range day.

---

**VWAP + STANDARD DEVIATION BANDS**

Session VWAP with manually computed ±1SD and ±2SD bands (resets daily). Bands are the most reliable VWAP-based entries:
- +1SD / -1SD — first rejection zone, high probability bounce
- +2SD / -2SD — extended move, mean-reversion territory

---

**S/R ZONE BOXES**

Transparent green (support) and red (resistance) zones drawn at each key level. Each zone:
- Tracks how many times price has touched it during the session
- Shows buy/sell volume split at the zone (e.g. B:58% S:42%)
- Becomes more opaque as touch count increases, indicating a tested and respected level

Zones: PDH, PDL, OR High, OR Low, R1, S1, VWAP +1SD, VWAP -1SD

---

**SESSION AUTO-FIBONACCI**

Fibonacci retracement levels drawn from the running session high to session low — updating in real time as new highs and lows are made throughout the day. Shows 38.2%, 50%, 61.8% by default (23.6% and 78.6% optional). The 50% level is highlighted separately.

---

**ORB STRATEGY TOOLS**

- Visual ORB box drawn when the opening range locks
- Extension targets at +1R, +2R above OR High and -1R, -2R below OR Low
- Breakout signal fires on the first clean break
- Retest signal fires when price returns to the broken level

---

**MULTI-TIMEFRAME DASHBOARD**

Real-time table (top-right by default) showing for 5 configurable timeframes:

| TF | Trend | RSI | Strength | Signal |
|---|---|---|---|---|
| 2m | ▲ BULL | 62 | ███░ 71% | BULL ▲ |
| 5m | ▲ BULL | 55 | ██░░ 45% | BULL |
| 10m | ▼ BEAR | 48 | █░░░ 22% | NEUT |
| 1H | ▲ BULL | 61 | ████ 80% | BULL ▲ |
| 1D | ▲ BULL | 63 | ████ 82% | BULL ▲ |
| VIX | 18.4 🟡 | | | |
| Vol Δ | ▲ +12.4K  B:61% S:39% | | | |

- **Trend** — EMA8 vs EMA21 cross direction
- **RSI** — momentum reading (colour-coded: green overbought zone, red oversold)
- **Strength** — EMA separation as a % (bar chart visual)
- **Signal** — combined reading: BULL ▲ / BULL / OB ! / BEAR ▼ / BEAR / OS ! / NEUT
- **VIX** — current fear/volatility gauge with emoji indicator (😌 calm → 🔥 panic)
- **Vol Delta** — session cumulative buy/sell volume split

Dashboard is configurable: Top Right / Bottom Right / Top Left / Bottom Left and Small / Normal / Large.

---

**VOLUME DELTA**

Per-bar buy and sell volume estimated using candle position (close-low / high-low method). Bars where buyers dominate show a faint green background tint; seller-dominated bars show faint red. The running session cumulative delta and buy/sell percentage are shown in the dashboard.

---

**MOVING AVERAGES**

- Fast EMA (default 8) and Slow EMA (default 21) on the current timeframe
- 200 SMA on current timeframe (plotted as circles to reduce clutter)
- HTF1 EMA and SMA (default 1H)
- HTF2 SMA (default Daily)

---

**MARKET STRUCTURE**

Swing pivots labelled as HH (Higher High), HL (Higher Low), LH (Lower High), LL (Lower Low) — provides a clean visual of the current trend structure without cluttering the chart with lines.

---

**TRAIL STOP (ATR Chandelier)**

Dynamic trailing stop that ratchets with price — locks in profits as a trend develops and flips direction when price closes through the stop level. Colour-coded green (bull) and red (bear). Multiplier and width are fully adjustable.

---

**SETTINGS**

Every visual element is customisable:
- All colours (with colour pickers)
- All line widths (1–4px)
- EMA/SMA periods and timeframes
- Opening range duration (1–120 min)
- Fibonacci levels (individual toggles)
- ATR multipliers for sweep detection, trail stop, zone width
- Volume multiplier threshold
- Signal cooldown bars
- Dashboard position and size
- S/R zone width and volume display

---

**BEST USED ON:** 1m, 2m, 5m charts for scalping. Works on any liquid instrument — equities, futures (ES, NQ, MES), and Forex majors.

**RECOMMENDED CHART:** SPY, QQQ, ES1!, NQ1! on 5-minute.

## Source Code

````pine
//@version=6
indicator("SHIVA Pro", overlay=true,
          max_boxes_count=300, max_lines_count=500, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// GROUPS
// ══════════════════════════════════════════════════════════════════════════════
G_LVL   = "── Key Levels ──"
G_MA    = "── Moving Averages ──"
G_VWAP  = "── VWAP & Bands ──"
G_ORB   = "── Opening Range (ORB) ──"
G_FIB   = "── Session Fibonacci ──"
G_PIV   = "── Pivot Points ──"
G_DYN   = "── SPX Dynamite Levels ──"
G_RLS   = "── BSL / SSL Liquidity ──"
G_SIG   = "── Signals ──"
G_TRAIL = "── Trailing Stop ──"
G_SRBOX = "── S/R Zone Boxes ──"
G_DASH  = "── Dashboards ──"
G_ALERT = "── Alerts ──"

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — Key Levels
// ══════════════════════════════════════════════════════════════════════════════
showPDHL    = input.bool(true,  "Show PDH / PDL",          group=G_LVL)
colPDH      = input.color(color.red,  "PDH Colour",        group=G_LVL)
colPDL      = input.color(color.lime, "PDL Colour",        group=G_LVL)
showPMHL    = input.bool(true,  "Show PM High / PM Low",   group=G_LVL)
colPMH      = input.color(color.orange, "PM High Colour",  group=G_LVL)
colPML      = input.color(color.teal,   "PM Low Colour",   group=G_LVL)
showOpen    = input.bool(true,  "Show Open Price (9:30)",  group=G_LVL)
colOpen     = input.color(color.white,  "Open Price Colour",group=G_LVL)
showHourly  = input.bool(false, "Show Hourly Opens",        group=G_LVL)
colHourly   = input.color(color.new(color.gray, 40), "Hourly Open Colour", group=G_LVL)
lvlWidth    = input.int(1, "Key Level Line Width",          group=G_LVL, minval=1, maxval=4)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — Moving Averages
// ══════════════════════════════════════════════════════════════════════════════
showEMA8    = input.bool(true,  "EMA 8",                   group=G_MA)
colEMA8     = input.color(color.yellow, "EMA 8 Colour",    group=G_MA)
showEMA21   = input.bool(true,  "EMA 21",                  group=G_MA)
colEMA21    = input.color(color.orange, "EMA 21 Colour",   group=G_MA)
showSMA200  = input.bool(true,  "SMA 200",                 group=G_MA)
colSMA200   = input.color(color.new(color.orange, 20), "SMA 200 Colour", group=G_MA)
htf1        = input.timeframe("60", "HTF Timeframe (EMA21+SMA200)", group=G_MA)
showHTFMAs  = input.bool(true,  "Show HTF MAs",            group=G_MA)
colHTFEMA   = input.color(color.new(color.aqua, 20), "HTF EMA 21 Colour", group=G_MA)
colHTFSMA   = input.color(color.blue, "HTF SMA 200 Colour",group=G_MA)
showDailySMA= input.bool(true,  "Show Daily SMA 200",      group=G_MA)
colDailySMA = input.color(color.purple, "Daily SMA Colour",group=G_MA)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — VWAP
// ══════════════════════════════════════════════════════════════════════════════
showVWAP    = input.bool(true,  "Show VWAP",               group=G_VWAP)
colVWAP     = input.color(color.white, "VWAP Colour",      group=G_VWAP)
showVB1     = input.bool(true,  "Show ±1 SD Bands",        group=G_VWAP)
colVB1      = input.color(color.new(color.blue, 50), "±1 SD Colour", group=G_VWAP)
showVB2     = input.bool(true,  "Show ±2 SD Bands",        group=G_VWAP)
colVB2      = input.color(color.new(color.purple, 50), "±2 SD Colour", group=G_VWAP)
fillVBands  = input.bool(false, "Fill VWAP Bands",         group=G_VWAP)
showVRej    = input.bool(true,  "VWAP Rejection Signals",  group=G_VWAP)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — ORB
// ══════════════════════════════════════════════════════════════════════════════
orbDurOpt   = input.string("15 min", "ORB Duration", group=G_ORB,
              options=["15 min","30 min","60 min"])
orbTZ       = input.string("America/New_York", "Market Timezone", group=G_ORB,
              options=["America/New_York","America/Chicago","America/Denver",
                       "America/Los_Angeles","Europe/London","Asia/Tokyo"])
showORHL    = input.bool(true,  "Show OR High / Low Lines",group=G_ORB)
colORH      = input.color(color.lime, "OR High Colour",    group=G_ORB)
colORL      = input.color(color.red,  "OR Low Colour",     group=G_ORB)
orbLineW    = input.int(2, "ORB Line Width",                group=G_ORB, minval=1, maxval=4)
showORBRej  = input.bool(true,  "Show ORB Break + Retest", group=G_ORB)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — Fibonacci
// ══════════════════════════════════════════════════════════════════════════════
showFib     = input.bool(true,  "Show Session Fibonacci",  group=G_FIB)
colFib382   = input.color(color.new(color.yellow, 50), "38% Fib Colour", group=G_FIB)
colFib50    = input.color(color.new(color.white,  50), "50% Fib Colour", group=G_FIB)
colFib618   = input.color(color.new(color.aqua,   50), "62% Fib Colour", group=G_FIB)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — Pivot Points
// ══════════════════════════════════════════════════════════════════════════════
showPivots  = input.bool(true,  "Show Pivot Points",       group=G_PIV)
showCPR     = input.bool(true,  "Show R2 / S2",            group=G_PIV)
colPP       = input.color(color.new(color.white, 20),  "PP Colour", group=G_PIV)
colR        = input.color(color.new(color.red,   20),  "R1/R2 Colour", group=G_PIV)
colS        = input.color(color.new(color.lime,  20),  "S1/S2 Colour", group=G_PIV)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — SPX Dynamite Levels
// ══════════════════════════════════════════════════════════════════════════════
showDyn     = input.bool(true,  "Show SPX Dynamite Levels (every 50 pts)", group=G_DYN)
dynTickers  = input.string("SPY,SPX,SPX500USD,ES1!,MES1!", "Apply to Tickers (comma-separated)", group=G_DYN)
dynRange    = input.int(500,    "Range around price (SPX pts)", group=G_DYN, minval=100, maxval=2000, step=50)
dynStep     = input.int(50,     "Level Spacing (SPX pts)",      group=G_DYN, minval=10,  maxval=200,  step=10)
spyMulti    = input.float(10.0, "SPX→SPY Divisor (SPY = SPX / divisor)", group=G_DYN, minval=1.0, step=0.1)
colDyn      = input.color(color.new(color.gray, 55), "Dynamite Line Colour", group=G_DYN)
colDynLabel = input.color(color.new(color.gray, 30), "Dynamite Label Colour",group=G_DYN)
dynLineW    = input.int(1, "Dynamite Line Width",              group=G_DYN, minval=1, maxval=3)
dynLineStyle= input.string("Dotted","Dynamite Line Style",     group=G_DYN, options=["Solid","Dashed","Dotted"])

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — BSL / SSL
// ══════════════════════════════════════════════════════════════════════════════
pivotLen    = input.int(5,      "Pivot Lookback (bars)",    group=G_RLS, minval=2, maxval=20)
showBSL     = input.bool(true,  "Show BSL Lines (Resistance)", group=G_RLS)
colBSL      = input.color(color.red, "BSL Line Colour",     group=G_RLS)
bslLineW    = input.int(2, "BSL Line Width",                 group=G_RLS, minval=1, maxval=4)
showBSLBox  = input.bool(false, "BSL Zone Box (strong resistance)", group=G_RLS)
colBSLBox   = input.color(color.new(color.red, 85), "BSL Zone Box Fill", group=G_RLS)
showSSL     = input.bool(true,  "Show SSL Lines (Support)", group=G_RLS)
colSSL      = input.color(color.lime, "SSL Line Colour",    group=G_RLS)
sslLineW    = input.int(2, "SSL Line Width",                 group=G_RLS, minval=1, maxval=4)
showSSLBox  = input.bool(false, "SSL Zone Box (strong support)", group=G_RLS)
colSSLBox   = input.color(color.new(color.lime, 85), "SSL Zone Box Fill", group=G_RLS)
showSweeps  = input.bool(true,  "Show Sweep Signals",       group=G_RLS)
confirmBars = input.int(3,      "★ Confirm Bars After Sweep",group=G_RLS, minval=1, maxval=10)
confPct     = input.float(0.1,  "Confluence % Range",       group=G_RLS, minval=0.05, maxval=0.5, step=0.05)
sweepCooldown = input.int(5,   "Sweep Cooldown (bars)",    group=G_RLS, minval=1, maxval=20)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — Signals
// ══════════════════════════════════════════════════════════════════════════════
showSigs    = input.bool(true,  "Show BUY / SELL Signals", group=G_SIG)
showPB      = input.bool(true,  "Show Pullback Signals",   group=G_SIG)
sweepAtrMin = input.float(0.5,  "Min Sweep Size (ATR x)", group=G_SIG, minval=0.1, step=0.1)
showStruct  = input.bool(true,  "Show HH / HL / LH / LL", group=G_SIG)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — Trailing Stop
// ══════════════════════════════════════════════════════════════════════════════
showTrail   = input.bool(true,  "Show Step Trailing Stop", group=G_TRAIL)
trailLen    = input.int(5,      "Trail Pivot Lookback",    group=G_TRAIL, minval=2, maxval=20)
colTrailBull= input.color(color.new(color.lime, 30), "Bull Trail Colour", group=G_TRAIL)
colTrailBear= input.color(color.new(color.red,  30), "Bear Trail Colour", group=G_TRAIL)
trailLineW  = input.int(2, "Trail Line Width",             group=G_TRAIL, minval=1, maxval=4)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — S/R Boxes
// ══════════════════════════════════════════════════════════════════════════════
showSRBox   = input.bool(true,  "Show Session S/R Zone Boxes", group=G_SRBOX)
srLookback  = input.int(50,     "Lookback Bars",           group=G_SRBOX, minval=20, maxval=200)
srTol       = input.float(0.2,  "Zone Tolerance %",        group=G_SRBOX, minval=0.05, maxval=1.0, step=0.05)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — Dashboards
// ══════════════════════════════════════════════════════════════════════════════
showLeftDash  = input.bool(true, "Show Left Dashboard",    group=G_DASH)
showRightDash = input.bool(true, "Show Right Dashboard",   group=G_DASH)
dashPos       = input.string("Top Right", "Dashboard Position", group=G_DASH,
                options=["Top Right","Top Left","Bottom Right","Bottom Left"])
dashSize      = input.string("Normal", "Dashboard Text Size", group=G_DASH,
                options=["Small","Normal","Large"])

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — Alerts
// ══════════════════════════════════════════════════════════════════════════════
alertBuy    = input.bool(true,  "Alert: 🔥 BUY Signal",   group=G_ALERT)
alertSell   = input.bool(true,  "Alert: 🔥 SELL Signal",  group=G_ALERT)
alertSSSL   = input.bool(true,  "Alert: ⚡ SSSL Sweep",   group=G_ALERT)
alertSBSL   = input.bool(true,  "Alert: ⚡ SBSL Sweep",   group=G_ALERT)
alertConf   = input.bool(true,  "Alert: ★ Confirm",       group=G_ALERT)

// ══════════════════════════════════════════════════════════════════════════════
// SIGNAL COLOURS (fixed — not user inputs, keeps chart clean)
// ══════════════════════════════════════════════════════════════════════════════
colBuyFire  = color.new(color.orange, 5)
colSellFire = color.new(color.red,    5)
colBuyA     = color.lime
colSellA    = color.red
colPB       = color.yellow
colSSSL     = color.new(color.lime, 15)
colSBSL     = color.new(color.red,  15)

// ══════════════════════════════════════════════════════════════════════════════
// TIME / SESSION HELPERS
// ══════════════════════════════════════════════════════════════════════════════
newDay      = ta.change(time("D")) != 0
isMarket    = session.ismarket
orbMins     = orbDurOpt == "15 min" ? 15 : orbDurOpt == "30 min" ? 30 : 60
_sTot       = 9 * 60 + 30
_eTot       = _sTot + orbMins
orbStart    = timestamp(orbTZ, year, month, dayofmonth, _sTot / 60, _sTot % 60, 0)
orbEnd      = timestamp(orbTZ, year, month, dayofmonth, _eTot / 60, _eTot % 60, 0)
atr         = ta.atr(14)

// Trading session window: 4:00 AM – 5:00 PM EST for BSL/SSL display
_hEst       = hour(time, "America/New_York")
_mEst       = minute(time, "America/New_York")
inTradingHrs= _hEst >= 4 and (_hEst < 17 or (_hEst == 17 and _mEst == 0))

// ══════════════════════════════════════════════════════════════════════════════
// MOVING AVERAGES
// ══════════════════════════════════════════════════════════════════════════════
ema8    = ta.ema(close, 8)
ema21   = ta.ema(close, 21)
sma200  = ta.sma(close, 200)

htfEMA21  = request.security(syminfo.tickerid, htf1, ta.ema(close, 21),  barmerge.gaps_off, barmerge.lookahead_off)
htfSMA200 = request.security(syminfo.tickerid, htf1, ta.sma(close, 200), barmerge.gaps_off, barmerge.lookahead_off)
dailySMA  = request.security(syminfo.tickerid, "D",  ta.sma(close, 200), barmerge.gaps_off, barmerge.lookahead_off)

plot(showEMA8    ? ema8      : na, "EMA 8",        color=colEMA8,    linewidth=1)
plot(showEMA21   ? ema21     : na, "EMA 21",       color=colEMA21,   linewidth=2)
plot(showSMA200  ? sma200    : na, "SMA 200",      color=colSMA200,  linewidth=2)
plot(showHTFMAs  ? htfEMA21  : na, "HTF EMA 21",  color=colHTFEMA,  linewidth=1)
plot(showHTFMAs  ? htfSMA200 : na, "HTF SMA 200", color=colHTFSMA,  linewidth=2)
plot(showDailySMA? dailySMA  : na, "Daily SMA200", color=colDailySMA,linewidth=2)

// MA right-edge labels
if barstate.islast
    if showEMA8
        label.new(bar_index + 3, ema8, "EMA 8",
                  color=color.new(color.black, 15), textcolor=colEMA8,
                  style=label.style_label_left, size=size.small)
    if showEMA21
        label.new(bar_index + 3, ema21, "EMA 21",
                  color=color.new(color.black, 15), textcolor=colEMA21,
                  style=label.style_label_left, size=size.small)
    if showSMA200
        label.new(bar_index + 3, sma200, "SMA 200",
                  color=color.new(color.black, 15), textcolor=colSMA200,
                  style=label.style_label_left, size=size.small)
    if showHTFMAs
        label.new(bar_index + 3, htfEMA21,  "HTF EMA 21",
                  color=color.new(color.black, 15), textcolor=colHTFEMA,
                  style=label.style_label_left, size=size.small)
        label.new(bar_index + 3, htfSMA200, "HTF SMA 200",
                  color=color.new(color.black, 15), textcolor=colHTFSMA,
                  style=label.style_label_left, size=size.small)
    if showDailySMA
        label.new(bar_index + 3, dailySMA, "Daily SMA 200",
                  color=color.new(color.black, 15), textcolor=colDailySMA,
                  style=label.style_label_left, size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// VWAP + BANDS
// ══════════════════════════════════════════════════════════════════════════════
var float vwapSum  = na
var float vwapVol  = na
var float vwapSum2 = na

if newDay or na(vwapSum)
    vwapSum  := 0.0
    vwapVol  := 0.0
    vwapSum2 := 0.0

tp       = (high + low + close) / 3
vwapSum += tp * volume
vwapVol += volume
vwapSum2+= tp * tp * volume

vwapVal  = vwapVol > 0 ? vwapSum / vwapVol : na
vwapVar  = vwapVol > 0 ? math.max(vwapSum2 / vwapVol - vwapVal * vwapVal, 0) : na
vwapSD   = math.sqrt(vwapVar)
vwapU1   = vwapVal + vwapSD
vwapL1   = vwapVal - vwapSD
vwapU2   = vwapVal + 2 * vwapSD
vwapL2   = vwapVal - 2 * vwapSD

pVWAP = plot(showVWAP ? vwapVal : na, "VWAP",   color=colVWAP, linewidth=2)
pVU1  = plot(showVB1  ? vwapU1  : na, "VWAP+1", color=colVB1,  linewidth=1)
pVL1  = plot(showVB1  ? vwapL1  : na, "VWAP-1", color=colVB1,  linewidth=1)
pVU2  = plot(showVB2  ? vwapU2  : na, "VWAP+2", color=colVB2,  linewidth=1)
pVL2  = plot(showVB2  ? vwapL2  : na, "VWAP-2", color=colVB2,  linewidth=1)

fill(pVU1, pVU2, color=fillVBands ? color.new(colVB2, 90) : na)
fill(pVL1, pVL2, color=fillVBands ? color.new(colVB2, 90) : na)
fill(pVU1, pVL1, color=fillVBands ? color.new(colVB1, 93) : na)

// VWAP rejection signals — small, clean triangles only
// VWAP retest: candle low must touch VWAP (at or below), close back above — same logic as ORB retest
vRejBuy  = showVRej and low <= vwapVal and close > vwapVal
// VWAP retest sell: candle high must touch VWAP (at or above), close back below
vRejSell = showVRej and high >= vwapVal and close < vwapVal
plotshape(vRejBuy,  "V-Buy",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 50), size=size.tiny)
plotshape(vRejSell, "V-Sell", style=shape.triangledown, location=location.abovebar, color=color.new(color.red,  50), size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// KEY LEVELS — flat static lines with clear labels
// ══════════════════════════════════════════════════════════════════════════════
pdh = request.security(syminfo.tickerid, "D", high[1],  barmerge.gaps_off, barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],   barmerge.gaps_off, barmerge.lookahead_off)

var float pmHigh   = na
var float pmLow    = na
var float openPx   = na
var float hourlyPx = na

isPreMarket = not session.ismarket and _hEst >= 4 and _hEst < 9

if newDay
    pmHigh := na
    pmLow  := na
    openPx := na

if isPreMarket
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow,  low)

if session.ismarket and not session.ismarket[1]
    openPx := open

if isMarket and minute(time) == 0 and minute(time[1]) != 0
    hourlyPx := open

// f_lvl: draws one clean dashed line + right-side label at barstate.islast
// Solid dark background on label so nearby levels don't bleed into each other
f_lvl(px, lbl, col, lw) =>
    if not na(px) and barstate.islast
        line.new(bar_index - 300, px, bar_index, px,
                 color=color.new(col, 20), width=lw,
                 extend=extend.right, style=line.style_dashed)
        label.new(bar_index + 3, px, lbl,
                  color=color.new(color.black, 15), textcolor=col,
                  style=label.style_label_left, size=size.small)

if showPDHL
    f_lvl(pdh, "PDH  " + str.tostring(pdh, "#.##"),  colPDH, lvlWidth)
    f_lvl(pdl, "PDL  " + str.tostring(pdl, "#.##"),  colPDL, lvlWidth)

if showPMHL
    f_lvl(pmHigh, "PM High  " + str.tostring(pmHigh, "#.##"), colPMH, lvlWidth)
    f_lvl(pmLow,  "PM Low   " + str.tostring(pmLow,  "#.##"), colPML, lvlWidth)

if showOpen
    f_lvl(openPx, "Open Price  " + str.tostring(openPx, "#.##"), colOpen, lvlWidth)

if showHourly and not na(hourlyPx)
    f_lvl(hourlyPx, str.tostring(_hEst) + ":00 Open", colHourly, 1)

// ══════════════════════════════════════════════════════════════════════════════
// PIVOT POINTS
// ══════════════════════════════════════════════════════════════════════════════
dHigh  = request.security(syminfo.tickerid, "D", high[1],  barmerge.gaps_off, barmerge.lookahead_off)
dLow   = request.security(syminfo.tickerid, "D", low[1],   barmerge.gaps_off, barmerge.lookahead_off)
dClose = request.security(syminfo.tickerid, "D", close[1], barmerge.gaps_off, barmerge.lookahead_off)

pp  = (dHigh + dLow + dClose) / 3
r1  = 2 * pp - dLow
s1  = 2 * pp - dHigh
r2  = pp + (dHigh - dLow)
s2  = pp - (dHigh - dLow)

if showPivots and barstate.islast
    f_lvl(pp, "PP  "  + str.tostring(pp, "#.##"), colPP, 1)
    f_lvl(r1, "R1  "  + str.tostring(r1, "#.##"), colR,  1)
    f_lvl(s1, "S1  "  + str.tostring(s1, "#.##"), colS,  1)
    if showCPR
        f_lvl(r2, "R2  " + str.tostring(r2, "#.##"), colR, 1)
        f_lvl(s2, "S2  " + str.tostring(s2, "#.##"), colS, 1)

// ══════════════════════════════════════════════════════════════════════════════
// OPENING RANGE — GUARANTEED FLAT LINES
// ══════════════════════════════════════════════════════════════════════════════
var float orbH      = na
var float orbL      = na
var bool  orbLocked = false
var line  orbHLine  = na
var line  orbLLine  = na

if newDay
    orbH      := na
    orbL      := na
    orbLocked := false
    if not na(orbHLine)
        line.delete(orbHLine)
    if not na(orbLLine)
        line.delete(orbLLine)

if isMarket and not orbLocked
    if time >= orbStart and time < orbEnd
        if na(orbH)
            orbH := high
            orbL := low
        else
            orbH := math.max(orbH, high)
            orbL := math.min(orbL, low)
    if time >= orbEnd and not na(orbH)
        orbLocked := true

// Draw ONCE — both endpoints at same price → guaranteed flat
if showORHL and orbLocked and not orbLocked[1]
    orbHLine := line.new(bar_index, orbH, bar_index + 1, orbH,
                         color=colORH, width=orbLineW, extend=extend.right)
    orbLLine := line.new(bar_index, orbL, bar_index + 1, orbL,
                         color=colORL, width=orbLineW, extend=extend.right)
    label.new(bar_index + 3, orbH,
              "OR High  " + str.tostring(orbH, "#.##"),
              color=color.new(color.black, 15), textcolor=colORH,
              style=label.style_label_left, size=size.normal)
    label.new(bar_index + 3, orbL,
              "OR Low   " + str.tostring(orbL, "#.##"),
              color=color.new(color.black, 15), textcolor=colORL,
              style=label.style_label_left, size=size.normal)

// ORB break + retest — small clean shapes, no text clutter
orbBrkHigh = showORBRej and orbLocked and close > orbH and close[1] <= orbH
orbBrkLow  = showORBRej and orbLocked and close < orbL and close[1] >= orbL
// True retest: candle low must touch OR High (at or below it), close back above — no tolerance fudge
orbRetHigh = showORBRej and orbLocked and low <= orbH and close > orbH
// True retest of OR Low: candle high must touch OR Low (at or above it), close back below
orbRetLow  = showORBRej and orbLocked and high >= orbL and close < orbL

plotshape(orbBrkHigh, "ORB↑", style=shape.triangleup,   location=location.belowbar, color=color.lime, size=size.small, text="ORB↑", textcolor=color.lime)
plotshape(orbBrkLow,  "ORB↓", style=shape.triangledown, location=location.abovebar, color=color.red,  size=size.small, text="ORB↓", textcolor=color.red)
plotshape(orbRetHigh, "RT↑",  style=shape.circle,       location=location.belowbar, color=color.lime, size=size.tiny,  text="RT↑",  textcolor=color.lime)
plotshape(orbRetLow,  "RT↓",  style=shape.circle,       location=location.abovebar, color=color.red,  size=size.tiny,  text="RT↓",  textcolor=color.red)

// ══════════════════════════════════════════════════════════════════════════════
// SESSION FIBONACCI
// ══════════════════════════════════════════════════════════════════════════════
var float sessionHigh = na
var float sessionLow  = na

if newDay
    sessionHigh := na
    sessionLow  := na

if isMarket
    sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow  := na(sessionLow)  ? low  : math.min(sessionLow,  low)

fib382 = sessionLow + (sessionHigh - sessionLow) * 0.382
fib50  = sessionLow + (sessionHigh - sessionLow) * 0.500
fib618 = sessionLow + (sessionHigh - sessionLow) * 0.618
fib786 = sessionLow + (sessionHigh - sessionLow) * 0.786

if showFib and barstate.islast and not na(sessionHigh)
    f_lvl(fib382, "38% Fib  " + str.tostring(fib382, "#.##"), colFib382, 1)
    f_lvl(fib50,  "50% Fib  " + str.tostring(fib50,  "#.##"), colFib50,  1)
    f_lvl(fib618, "62% Fib  " + str.tostring(fib618, "#.##"), colFib618, 1)
    f_lvl(fib786, "79% Fib  " + str.tostring(fib786, "#.##"), color.new(color.white, 60), 1)

// ══════════════════════════════════════════════════════════════════════════════
// SPX DYNAMITE LEVELS  (every 50 SPX points, visible on SPY/SPX only)
// ══════════════════════════════════════════════════════════════════════════════
_ticker     = syminfo.ticker
_isSPXChart = str.contains(dynTickers, _ticker)

_dynStyle   = dynLineStyle == "Dashed" ? line.style_dashed : dynLineStyle == "Dotted" ? line.style_dotted : line.style_solid

// Convert price to SPX equivalent, then round to nearest step
_priceInSPX = str.contains(_ticker, "SPY") ? close * spyMulti : close
_baseLevel  = math.floor(_priceInSPX / dynStep) * dynStep

var line[] dynLines  = array.new_line()
var label[] dynLabels= array.new_label()

if showDyn and _isSPXChart and barstate.islast
    // Clear old dynamic lines safely
    while array.size(dynLines) > 0
        line.delete(array.pop(dynLines))
    while array.size(dynLabels) > 0
        label.delete(array.pop(dynLabels))

    _steps = dynRange / dynStep
    for _i = -_steps to _steps
        _spxLevel = _baseLevel + _i * dynStep
        _chartLvl = str.contains(_ticker, "SPY") ? _spxLevel / spyMulti : _spxLevel
        _isRound  = _spxLevel % 100 == 0  // highlight full 100-pt levels slightly bolder
        _lw       = _isRound ? math.min(dynLineW + 1, 3) : dynLineW
        _ln = line.new(bar_index - 100, _chartLvl, bar_index, _chartLvl,
                       color=colDyn, width=_lw, style=_dynStyle, extend=extend.right)
        _lb = label.new(bar_index + 3, _chartLvl,
                        "SPX " + str.tostring(int(_spxLevel)),
                        color=color.new(color.black, 100),
                        textcolor=colDynLabel,
                        style=label.style_label_left, size=size.small)
        array.push(dynLines, _ln)
        array.push(dynLabels, _lb)

// ══════════════════════════════════════════════════════════════════════════════
// BSL / SSL LIQUIDITY LINES  (session hours only: 4 AM – 5 PM EST)
// ══════════════════════════════════════════════════════════════════════════════
pivHi = ta.pivothigh(high, pivotLen, pivotLen)
pivLo = ta.pivotlow(low,  pivotLen, pivotLen)

var float   lastBSL   = na
var float   lastSSL   = na
var bool    bslSwept  = false
var bool    sslSwept  = false
var box     bslBox    = na   // single active BSL zone box
var box     sslBox    = na   // single active SSL zone box
var label   bslLbl    = na   // single active BSL label
var label   sslLbl    = na   // single active SSL label

// BSL — replace old box+label with new one each time a fresh pivot forms
if showBSL and not na(pivHi) and inTradingHrs
    lastBSL  := pivHi
    bslSwept := false
    _bslTol  = atr * 0.25
    if showBSLBox
        if not na(bslBox)
            box.delete(bslBox)
        bslBox := box.new(bar_index - pivotLen - 3, pivHi + _bslTol,
                          bar_index - pivotLen + 3, pivHi - _bslTol,
                          border_color=color.new(colBSL, 60),
                          bgcolor=colBSLBox)
    if not na(bslLbl)
        label.delete(bslLbl)
    bslLbl := label.new(bar_index - pivotLen, pivHi + atr * 0.12,
                        "BSL  " + str.tostring(pivHi, "#.##"),
                        color=color.new(color.black, 15), textcolor=colBSL,
                        style=label.style_label_down, size=size.small)

// SSL — replace old box+label with new one each time a fresh pivot forms
if showSSL and not na(pivLo) and inTradingHrs
    lastSSL  := pivLo
    sslSwept := false
    _sslTol  = atr * 0.25
    if showSSLBox
        if not na(sslBox)
            box.delete(sslBox)
        sslBox := box.new(bar_index - pivotLen - 3, pivLo + _sslTol,
                          bar_index - pivotLen + 3, pivLo - _sslTol,
                          border_color=color.new(colSSL, 60),
                          bgcolor=colSSLBox)
    if not na(sslLbl)
        label.delete(sslLbl)
    sslLbl := label.new(bar_index - pivotLen, pivLo - atr * 0.12,
                        "SSL  " + str.tostring(pivLo, "#.##"),
                        color=color.new(color.black, 15), textcolor=colSSL,
                        style=label.style_label_up, size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// T5 COMPOSITE SCORE (-100 to +100)
// ══════════════════════════════════════════════════════════════════════════════
rsiVal       = ta.rsi(close, 14)
[macdL, macdS, macdH] = ta.macd(close, 12, 26, 9)
emaBias5     = ema8 > ema21 ? 1 : -1

htfEMA8_60   = request.security(syminfo.tickerid, "60", ta.ema(close, 8),  barmerge.gaps_off, barmerge.lookahead_off)
htfEMA21_60  = request.security(syminfo.tickerid, "60", ta.ema(close, 21), barmerge.gaps_off, barmerge.lookahead_off)
emaBias60    = htfEMA8_60 > htfEMA21_60 ? 1 : -1

htfEMA8D     = request.security(syminfo.tickerid, "D", ta.ema(close, 8),  barmerge.gaps_off, barmerge.lookahead_off)
htfEMA21D    = request.security(syminfo.tickerid, "D", ta.ema(close, 21), barmerge.gaps_off, barmerge.lookahead_off)
emaBiasD     = htfEMA8D > htfEMA21D ? 1 : -1

emaBiasScore = (emaBias5 + emaBias60 + emaBiasD) / 3.0 * 40.0
rsiScore     = (rsiVal - 50) / 50.0 * 25.0
macdScore    = macdH > 0 ? 20.0 : -20.0
volSMA20     = ta.sma(volume, 20)
volScore     = volume > volSMA20 * 1.5 ? 15.0 : volume < volSMA20 * 0.5 ? -15.0 : 0.0

t5Score = math.round(math.max(-100, math.min(100, emaBiasScore + rsiScore + macdScore + volScore)))

// ══════════════════════════════════════════════════════════════════════════════
// VOLUME DELTA BACKGROUND
// ══════════════════════════════════════════════════════════════════════════════
volDelta = close > open ? volume : close < open ? -volume : 0
bgcolor(volDelta > 0 ? color.new(color.lime, 96) : color.new(color.red, 96), title="Vol Delta BG")

// ══════════════════════════════════════════════════════════════════════════════
// LIQUIDITY SWEEP DETECTION
// ══════════════════════════════════════════════════════════════════════════════
var float lastSSSLPrice = na
var float lastSBSLPrice = na
var int   sssLBuyBar    = na
var int   sbslSellBar   = na
var int   lastSSSLBar   = na
var int   lastSBSLBar   = na

// Cooldown: don't fire another sweep within N bars of the last one
_buyCooldownOK  = na(lastSSSLBar) or (bar_index - lastSSSLBar) >= sweepCooldown
_sellCooldownOK = na(lastSBSLBar) or (bar_index - lastSBSLBar) >= sweepCooldown

// Sweep must: cross the level, close back above/below, move >= minATR, level not already swept
sweepBuy  = showSweeps and (not na(lastSSL)) and not sslSwept and low < lastSSL and close > lastSSL and (close - low) >= atr * sweepAtrMin and isMarket and _buyCooldownOK
sweepSell = showSweeps and (not na(lastBSL)) and not bslSwept and high > lastBSL and close < lastBSL and (high - close) >= atr * sweepAtrMin and isMarket and _sellCooldownOK

if sweepBuy
    lastSSSLPrice := low
    lastSSSLBar   := bar_index
    sssLBuyBar    := bar_index
    sslSwept      := true   // mark SSL level consumed

if sweepSell
    lastSBSLPrice := high
    lastSBSLBar   := bar_index
    sbslSellBar   := bar_index
    bslSwept      := true   // mark BSL level consumed

// ══════════════════════════════════════════════════════════════════════════════
// CONFLUENCE COUNT
// ══════════════════════════════════════════════════════════════════════════════
f_conf(px) =>
    tol = px * confPct / 100.0
    n   = 0
    if math.abs(px - vwapVal) < tol
        n += 1
    if math.abs(px - vwapU1) < tol
        n += 1
    if math.abs(px - vwapL1) < tol
        n += 1
    if orbLocked and math.abs(px - orbH) < tol
        n += 1
    if orbLocked and math.abs(px - orbL) < tol
        n += 1
    if math.abs(px - pdh) < tol
        n += 1
    if math.abs(px - pdl) < tol
        n += 1
    if not na(openPx) and math.abs(px - openPx) < tol
        n += 1
    if math.abs(px - pp) < tol
        n += 1
    if math.abs(px - r1) < tol
        n += 1
    if math.abs(px - s1) < tol
        n += 1
    if not na(fib382) and math.abs(px - fib382) < tol
        n += 1
    if not na(fib50)  and math.abs(px - fib50)  < tol
        n += 1
    if not na(fib618) and math.abs(px - fib618) < tol
        n += 1
    if math.abs(px - ema21)  < tol
        n += 1
    if math.abs(px - sma200) < tol
        n += 1
    n

f_grade(n) => n >= 3 ? "A+" : n == 2 ? "A" : "B"

// ══════════════════════════════════════════════════════════════════════════════
// ⚡ SWEEP SIGNAL LABELS
// ══════════════════════════════════════════════════════════════════════════════
if sweepBuy
    label.new(bar_index, low - atr * 0.35,
              "⚡ SSSL BUY",
              color=colSSSL, textcolor=color.black,
              style=label.style_label_up, size=size.large)

if sweepSell
    label.new(bar_index, high + atr * 0.35,
              "⚡ SBSL SELL",
              color=colSBSL, textcolor=color.white,
              style=label.style_label_down, size=size.large)

// ══════════════════════════════════════════════════════════════════════════════
// ★ CONFIRM SIGNAL
// ══════════════════════════════════════════════════════════════════════════════
var string lastConfirmText = "—"
var int    lastConfirmBar  = na

// Confirm bar must be green (bullish) for BUY, red (bearish) for SELL
confirmBuy  = not na(sssLBuyBar)  and bar_index == sssLBuyBar  + confirmBars and close > lastSSSLPrice and close > open
confirmSell = not na(sbslSellBar) and bar_index == sbslSellBar + confirmBars and close < lastSBSLPrice and close < open

if confirmBuy
    lastConfirmText := "★ SSSL BUY"
    lastConfirmBar  := bar_index
    label.new(bar_index, low - atr * 0.55,
              "★ Confirm BUY",
              color=color.new(color.lime, 10), textcolor=color.black,
              style=label.style_label_up, size=size.large)

if confirmSell
    lastConfirmText := "★ SBSL SELL"
    lastConfirmBar  := bar_index
    label.new(bar_index, high + atr * 0.55,
              "★ Confirm SELL",
              color=color.new(color.red, 10), textcolor=color.white,
              style=label.style_label_down, size=size.large)

// ══════════════════════════════════════════════════════════════════════════════
// 🔥 MAIN BUY / SELL SIGNALS
// ══════════════════════════════════════════════════════════════════════════════
// 🔥 Fire = sweep + strong T5 alignment + 3+ confluences
fireBuy  = showSigs and sweepBuy  and t5Score > 20  and f_conf(low)  >= 3 and isMarket
fireSell = showSigs and sweepSell and t5Score < -20 and f_conf(high) >= 3 and isMarket
// ▲/▼ A-grade = sweep + moderate T5 + 2+ confluences
aBuy     = showSigs and sweepBuy  and not fireBuy  and t5Score > 0  and f_conf(low)  >= 2 and isMarket
aSell    = showSigs and sweepSell and not fireSell and t5Score < 0  and f_conf(high) >= 2 and isMarket
// VWAP rejection signals — fires when candle touches VWAP and closes back through with T5 alignment
vwapSigBuy  = showSigs and vRejBuy  and not fireBuy  and not aBuy  and t5Score > -20 and close > open and isMarket
vwapSigSell = showSigs and vRejSell and not fireSell and not aSell and t5Score <  20 and close < open and isMarket

if fireBuy
    n = f_conf(low)
    label.new(bar_index, low - atr * 0.7,
              "🔥 BUY  " + f_grade(n) + "  (" + str.tostring(n) + " conf)",
              color=colBuyFire, textcolor=color.white,
              style=label.style_label_up, size=size.huge)

if fireSell
    n = f_conf(high)
    label.new(bar_index, high + atr * 0.7,
              "🔥 SELL  " + f_grade(n) + "  (" + str.tostring(n) + " conf)",
              color=colSellFire, textcolor=color.white,
              style=label.style_label_down, size=size.huge)

if aBuy
    label.new(bar_index, low - atr * 0.45,
              "▲ BUY",
              color=colBuyA, textcolor=color.black,
              style=label.style_label_up, size=size.large)

if aSell
    label.new(bar_index, high + atr * 0.45,
              "▼ SELL",
              color=colSellA, textcolor=color.white,
              style=label.style_label_down, size=size.large)

if vwapSigBuy
    label.new(bar_index, low - atr * 0.45,
              "V-BUY",
              color=color.new(color.teal, 10), textcolor=color.white,
              style=label.style_label_up, size=size.large)

if vwapSigSell
    label.new(bar_index, high + atr * 0.45,
              "V-SELL",
              color=color.new(color.orange, 10), textcolor=color.white,
              style=label.style_label_down, size=size.large)

// ══════════════════════════════════════════════════════════════════════════════
// PB▲ / PB▼ PULLBACK SIGNALS
// ══════════════════════════════════════════════════════════════════════════════
inUptrend    = ema8 > ema21 and close > vwapVal
inDowntrend  = ema8 < ema21 and close < vwapVal

_pbNearLevel = math.abs(close - ema21) < atr * 0.5 or math.abs(close - vwapVal) < atr * 0.5 or (orbLocked and (math.abs(close - orbH) < atr * 0.5 or math.abs(close - orbL) < atr * 0.5))
pbBuy  = showPB and inUptrend   and _pbNearLevel and close > open and isMarket
pbSell = showPB and inDowntrend and _pbNearLevel and close < open and isMarket

plotshape(pbBuy  and not fireBuy  and not aBuy,  "PB▲", style=shape.labelup,   location=location.belowbar, color=colPB, textcolor=color.black, text="PB▲", size=size.normal)
plotshape(pbSell and not fireSell and not aSell, "PB▼", style=shape.labeldown, location=location.abovebar, color=colPB, textcolor=color.black, text="PB▼", size=size.normal)

// ══════════════════════════════════════════════════════════════════════════════
// STRUCTURE — HH / HL / LH / LL
// ══════════════════════════════════════════════════════════════════════════════
var float prevSwingH = na
var float prevSwingL = na

if not na(pivHi) and showStruct
    structTxt = na(prevSwingH) ? "HH" : pivHi > prevSwingH ? "HH" : "LH"
    label.new(bar_index - pivotLen, pivHi + atr * 0.2,
              structTxt, color=color.new(color.black, 100),
              textcolor=color.red, style=label.style_none, size=size.small)
    prevSwingH := pivHi

if not na(pivLo) and showStruct
    structTxt = na(prevSwingL) ? "LL" : pivLo > prevSwingL ? "HL" : "LL"
    label.new(bar_index - pivotLen, pivLo - atr * 0.2,
              structTxt, color=color.new(color.black, 100),
              textcolor=color.lime, style=label.style_none, size=size.small)
    prevSwingL := pivLo

// ══════════════════════════════════════════════════════════════════════════════
// STEP TRAILING STOP
// ══════════════════════════════════════════════════════════════════════════════
var float trailLevel  = na
var bool  trailIsBull = false
var line  trailLine   = na

swingH_trail = ta.pivothigh(high, trailLen, trailLen)
swingL_trail = ta.pivotlow(low,  trailLen, trailLen)

if showTrail
    if inUptrend and not na(swingL_trail)
        if na(trailLevel) or swingL_trail > trailLevel
            trailLevel  := swingL_trail
            trailIsBull := true
    if inDowntrend and not na(swingH_trail)
        if na(trailLevel) or swingH_trail < trailLevel
            trailLevel  := swingH_trail
            trailIsBull := false
    if not na(trailLevel)
        _tc = trailIsBull ? colTrailBull : colTrailBear
        if not na(trailLine)
            line.delete(trailLine)
        trailLine := line.new(bar_index - 1, trailLevel, bar_index, trailLevel,
                              color=_tc, width=trailLineW, extend=extend.right)

// ══════════════════════════════════════════════════════════════════════════════
// SESSION S/R ZONE BOXES
// ══════════════════════════════════════════════════════════════════════════════
srH_val = ta.highest(high, srLookback)
srL_val = ta.lowest(low,   srLookback)

if showSRBox and barstate.islast
    _tol = srH_val * srTol / 100.0
    box.new(bar_index - srLookback, srH_val + _tol, bar_index, srH_val - _tol,
            border_color=color.new(color.red,  50), border_width=1,
            bgcolor=color.new(color.red,  91))
    box.new(bar_index - srLookback, srL_val + _tol, bar_index, srL_val - _tol,
            border_color=color.new(color.lime, 50), border_width=1,
            bgcolor=color.new(color.lime, 91))

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD DATA
// ══════════════════════════════════════════════════════════════════════════════
vixVal   = request.security("VIX", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
vixStr   = na(vixVal) ? "N/A" : str.tostring(vixVal, "#.#")
vixCol   = na(vixVal) ? color.gray : vixVal > 25 ? color.red : vixVal > 18 ? color.orange : color.lime
vixLbl   = na(vixVal) ? "N/A" : vixVal > 25 ? "HIGH" : vixVal > 18 ? "Elevated" : "Low"

spyChg   = request.security("SPY", timeframe.period, ta.roc(close, 5), barmerge.gaps_off, barmerge.lookahead_off)
qqqChg   = request.security("QQQ", timeframe.period, ta.roc(close, 5), barmerge.gaps_off, barmerge.lookahead_off)
cdDiff   = not na(spyChg) and not na(qqqChg) ? spyChg - qqqChg : na
cdStr    = na(cdDiff) ? "N/A" : math.abs(cdDiff) < 0.5 ? "Convergence" : spyChg > qqqChg ? "SPY Leading" : "QQQ Leading"
cdCol    = na(cdDiff) ? color.gray : math.abs(cdDiff) < 0.5 ? color.lime : color.orange

rangeSize = not na(orbH) and not na(orbL) ? orbH - orbL : na
swingSize = not na(sessionHigh) and not na(sessionLow) ? sessionHigh - sessionLow : na
rswStr   = na(rangeSize) or na(swingSize) ? "N/A" : swingSize > rangeSize * 2.0 ? "Strong Swing" : swingSize > rangeSize * 1.2 ? "Moderate" : "Relatively Even"
rswCol   = na(rangeSize) or na(swingSize) ? color.gray : swingSize > rangeSize * 2.0 ? color.lime : swingSize > rangeSize * 1.2 ? color.yellow : color.gray

var int wdBars = 0
if emaBias5 != emaBias5[1]
    wdBars := 0
else
    wdBars += 1
wdDays  = math.round(wdBars / math.max(60 / timeframe.multiplier, 1))
wdStr   = str.tostring(wdDays) + " day" + (wdDays == 1 ? "" : "s") + " ago"

rMultBSL = not na(lastBSL) and atr > 0 ? math.abs(close - lastBSL) / atr : na
rMultSSL = not na(lastSSL) and atr > 0 ? math.abs(close - lastSSL) / atr : na
rBSLStr  = na(rMultBSL) ? "—" : str.tostring(rMultBSL, "#.1") + "R"
rSSLStr  = na(rMultSSL) ? "—" : str.tostring(rMultSSL, "#.1") + "R"

bslBarsAgo  = not na(lastSBSLBar) ? bar_index - lastSBSLBar : na
sslBarsAgo  = not na(lastSSSLBar) ? bar_index - lastSSSLBar : na
bslBarsStr  = na(bslBarsAgo) ? "—" : str.tostring(bslBarsAgo) + " bars ago"
sslBarsStr  = na(sslBarsAgo) ? "—" : str.tostring(sslBarsAgo) + " bars ago"
bslPriceStr = not na(lastSBSLPrice) ? str.tostring(lastSBSLPrice, "#.##") : "—"
sslPriceStr = not na(lastSSSLPrice) ? str.tostring(lastSSSLPrice, "#.##") : "—"

t5Str   = str.tostring(t5Score)
t5Col   = t5Score >= 30 ? color.lime : t5Score <= -30 ? color.red : color.yellow
zoneStr = t5Score >= 30 ? "Trend Up ▲" : t5Score <= -30 ? "Trend Dn ▼" : "In Range ◆"
zoneCol = t5Score >= 30 ? color.lime   : t5Score <= -30 ? color.red    : color.gray

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARDS
// ══════════════════════════════════════════════════════════════════════════════
var table leftDash  = na
var table rightDash = na

_pos(s) =>
    s == "Top Right"    ? position.top_right    :
     s == "Top Left"    ? position.top_left     :
     s == "Bottom Right"? position.bottom_right :
                          position.bottom_left

leftPos  = _pos(dashPos)
rightPos = dashPos == "Top Right"    ? position.top_left    :
           dashPos == "Top Left"     ? position.top_right   :
           dashPos == "Bottom Right" ? position.bottom_left :
                                       position.bottom_right

_hdr  = color.new(#1a1f2e, 10)
_row1 = color.new(#12151f, 30)
_row2 = color.new(#0d1018, 40)
_sz   = dashSize == "Small" ? size.small : dashSize == "Large" ? size.large : size.normal

if barstate.islast
    // ── LEFT DASHBOARD ──────────────────────────────────────────────────────
    if showLeftDash
        if na(leftDash)
            leftDash := table.new(leftPos, 2, 5, border_color=color.new(color.gray, 60), border_width=1)

        table.cell(leftDash, 0, 0, "SHIVA PRO",  text_color=color.white,  text_size=_sz, bgcolor=_hdr, text_halign=text.align_center)
        table.cell(leftDash, 1, 0, "Status",      text_color=color.silver, text_size=_sz, bgcolor=_hdr, text_halign=text.align_center)

        table.cell(leftDash, 0, 1, " WD ",  text_color=color.silver, text_size=_sz, bgcolor=_row1)
        table.cell(leftDash, 1, 1, wdStr,   text_color=color.new(color.blue, 10), text_size=_sz, bgcolor=_row1)

        table.cell(leftDash, 0, 2, " VIX ", text_color=color.silver, text_size=_sz, bgcolor=_row2)
        table.cell(leftDash, 1, 2, vixStr + "  " + vixLbl, text_color=vixCol, text_size=_sz, bgcolor=_row2)

        table.cell(leftDash, 0, 3, " C/D ", text_color=color.silver, text_size=_sz, bgcolor=_row1)
        table.cell(leftDash, 1, 3, cdStr,   text_color=cdCol,         text_size=_sz, bgcolor=_row1)

        table.cell(leftDash, 0, 4, " R/SW", text_color=color.silver, text_size=_sz, bgcolor=_row2)
        table.cell(leftDash, 1, 4, rswStr,  text_color=rswCol,         text_size=_sz, bgcolor=_row2)

    // ── RIGHT DASHBOARD ─────────────────────────────────────────────────────
    if showRightDash
        if na(rightDash)
            rightDash := table.new(rightPos, 2, 10, border_color=color.new(color.gray, 60), border_width=1)

        table.cell(rightDash, 0, 0, "RLS DASHBOARD", text_color=color.white,  text_size=_sz, bgcolor=_hdr, text_halign=text.align_center)
        table.cell(rightDash, 1, 0, "Value",          text_color=color.silver, text_size=_sz, bgcolor=_hdr, text_halign=text.align_center)

        table.cell(rightDash, 0, 1, " BSL Swept ",   text_color=color.silver, text_size=_sz, bgcolor=_row1)
        table.cell(rightDash, 1, 1, bslPriceStr + "  (" + bslBarsStr + ")", text_color=na(bslBarsAgo) ? color.gray : color.red, text_size=_sz, bgcolor=_row1)

        table.cell(rightDash, 0, 2, " SSL Swept ",   text_color=color.silver, text_size=_sz, bgcolor=_row2)
        table.cell(rightDash, 1, 2, "⚡ " + sslPriceStr + "  (" + sslBarsStr + ")", text_color=na(sslBarsAgo) ? color.gray : color.lime, text_size=_sz, bgcolor=_row2)

        table.cell(rightDash, 0, 3, " T5 Score ",    text_color=color.silver, text_size=_sz, bgcolor=_row1)
        table.cell(rightDash, 1, 3, t5Str,            text_color=t5Col,         text_size=_sz, bgcolor=_row1)

        table.cell(rightDash, 0, 4, " Zone ",         text_color=color.silver, text_size=_sz, bgcolor=_row2)
        table.cell(rightDash, 1, 4, zoneStr,           text_color=zoneCol,       text_size=_sz, bgcolor=_row2)

        table.cell(rightDash, 0, 5, " BSL ↑ ",        text_color=colBSL, text_size=_sz, bgcolor=_row1)
        table.cell(rightDash, 1, 5, not na(lastBSL) ? str.tostring(lastBSL, "#.##") + "  (" + rBSLStr + ")" : "—", text_color=colBSL, text_size=_sz, bgcolor=_row1)

        table.cell(rightDash, 0, 6, " SSL ↓ ",        text_color=colSSL, text_size=_sz, bgcolor=_row2)
        table.cell(rightDash, 1, 6, not na(lastSSL) ? str.tostring(lastSSL, "#.##") + "  (" + rSSLStr + ")" : "—", text_color=colSSL, text_size=_sz, bgcolor=_row2)

        table.cell(rightDash, 0, 7, " Range ",         text_color=color.silver, text_size=_sz, bgcolor=_row1)
        table.cell(rightDash, 1, 7, rswStr,             text_color=rswCol,         text_size=_sz, bgcolor=_row1)

        _confAgoStr = na(lastConfirmBar) ? "—" : str.tostring(bar_index - lastConfirmBar) + " bars ago"
        table.cell(rightDash, 0, 8, " ★ Confirm ",    text_color=color.yellow, text_size=_sz, bgcolor=_row2)
        table.cell(rightDash, 1, 8, lastConfirmText + "  " + _confAgoStr, text_color=color.yellow, text_size=_sz, bgcolor=_row2)

        _orbStr = orbLocked and not na(orbH) ? str.tostring(orbH, "#.##") + " / " + str.tostring(orbL, "#.##") : "Pending…"
        table.cell(rightDash, 0, 9, " ORB H/L ",      text_color=color.silver, text_size=_sz, bgcolor=_row1)
        table.cell(rightDash, 1, 9, _orbStr,            text_color=color.white,   text_size=_sz, bgcolor=_row1)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(fireBuy   and alertBuy,  "SHIVA Pro: 🔥 BUY",          "Fire BUY signal")
alertcondition(fireSell  and alertSell, "SHIVA Pro: 🔥 SELL",         "Fire SELL signal")
alertcondition(sweepBuy  and alertSSSL, "SHIVA Pro: ⚡ SSSL Sweep",   "SSSL BUY sweep")
alertcondition(sweepSell and alertSBSL, "SHIVA Pro: ⚡ SBSL Sweep",   "SBSL SELL sweep")
alertcondition(confirmBuy  and alertConf, "SHIVA Pro: ★ Confirm BUY", "Confirm BUY")
alertcondition(confirmSell and alertConf, "SHIVA Pro: ★ Confirm SELL","Confirm SELL")
alertcondition(orbBrkHigh, "SHIVA Pro: ORB Break High", "ORB breakout above OR High")
alertcondition(orbBrkLow,  "SHIVA Pro: ORB Break Low",  "ORB breakdown below OR Low")
````
