# Daily MAs on Intraday Charts (Indian Market)

- url: https://www.tradingview.com/script/1jwIuf1R-Daily-MAs-on-Intraday-Charts-Indian-Market/
- type: indicator
- pine_id: PUB;0dc1b07fac264ec6aba21f882b6de9ab
- version: 2.0

## Description

Daily Moving Averages + VWAP — Indian Market (NSE/BSE)

A comprehensive intraday analysis tool built exclusively for the **Indian stock markets (NSE & BSE)**. This indicator combines key Daily Moving Averages with a session-aware VWAP, all plotted directly on intraday charts — giving you a complete picture of where price stands relative to the most important daily levels without ever having to switch timeframes.

---

**⚙️ How It Works**

The Indian cash market trades for exactly **375 minutes per day** (9:15 AM – 3:30 PM IST). This indicator uses that fixed session length to dynamically back-calculate the exact number of intraday bars required to replicate each Daily Moving Average on any lower timeframe. Whether you are on a 1-minute or a 125-minute chart, every MA will always reflect its true daily value — no manual input or reconfiguration required when switching timeframes.

---

**📈 Moving Averages Plotted**

| MA | Type | Colour |
|---|---|---|
| 5 Day | SMA | White |
| 10 Day | EMA | Sky Blue |
| 21 Day | EMA | Green |
| 50 Day | EMA | Orange |

The **5 SMA** acts as a short-term trend filter and is widely tracked by momentum traders. The **10 and 21 EMAs** are key levels for swing and positional traders, offering dynamic near-term support and resistance. The **50 EMA** represents the medium-term trend and is one of the most watched levels by institutional traders in the Indian markets.

---

**🕐 Supported Timeframes**

The indicator automatically calculates the correct bar period for all intraday timeframes, including **1 min, 3 min, 5 min, 15 min, 25 min, 75 min, 125 min**, and any other intraday interval. It also works natively on the **Daily** and **Weekly** timeframes.

> ⚠️ TradingView imposes a **5,000 bar limit** on historical data. As a result, MAs that require more bars than this limit on lower timeframes will display **"Insuf. Data"** in the table and will not plot on the chart. The affected MAs vary by timeframe as follows:
> - **1 min** — only 5 SMA and 10 EMA are available
> - **3 min** — 5 SMA, 10 EMA and 21 EMA are available
> - **5 min and above** — all four MAs plot fully

---

**📊 VWAP**

The indicator includes a fully session-aware **Volume Weighted Average Price (VWAP)** plotted in purple. VWAP is one of the most widely used intraday benchmarks by institutional desks, prop traders, and retail participants alike, offering a real-time view of the average price weighted by volume traded during the session.

Two modes are available via the settings:

- **Historical VWAP on** — Plots TradingView's built-in VWAP continuously across all visible sessions, allowing you to study how price behaved relative to VWAP on previous days
- **Historical VWAP off** — Acts as a true **Anchored VWAP**, anchored strictly to the **9:15 AM first candle of the current trading day**. All previous session VWAP lines are completely hidden, keeping the chart clean and focused on today's session only

---

**🧮 Distance Table**

An on-chart table displays the **live percentage distance of the current price from each MA and VWAP** in real time. This tells you at a glance how extended or compressed the price is relative to each key level.

- 🟢 **Green** — price is trading above the level
- 🔴 **Red** — price is trading below the level
- ⚫ **Grey / "Insuf. Data"** — insufficient historical bars to calculate the MA on the current timeframe

The table can be toggled on or off and repositioned to any of **9 positions** on the chart — top, middle, or bottom, aligned left, center, or right — so it never interferes with your price action.

---

**🛠️ Settings**

| Setting | Description |
|---|---|
| Show Distance Table | Toggle the MA and VWAP distance table on or off |
| Label Position | Place the table in any of 9 positions on the chart |
| Show VWAP | Toggle the VWAP line and its table row on or off |
| Show Historical VWAP | When on, shows VWAP across all sessions. When off, anchors VWAP to today's 9:15 AM candle only |

---

**⚠️ Important — Indian Markets Only**

This indicator is **specifically calibrated for the Indian stock markets (NSE/BSE)** and is **not suitable for use on any other global market**. The period calculation is hardcoded to **375 minutes per trading day**, which is unique to the Indian cash market session. Applying this indicator to markets with different session lengths — such as US markets (390 minutes), European markets, or 24-hour crypto markets — will cause all Moving Averages to drift significantly from their true daily values and produce incorrect readings.

---

*Built for Indian intraday, swing, and positional traders who trade with full awareness of key daily levels and session VWAP dynamics.*

## Source Code

````pine
//@version=6
indicator("Daily MAs on Intraday Charts (Indian Market)", shorttitle="Daily MAs on Intraday Charts", overlay=true)

// ═══════════════════════════════════════════
//  INPUTS — TABLE
// ═══════════════════════════════════════════
showTable     = input.bool(true, "Show Distance Table")
labelPosition = input.string("bottom_right", "Label Position",
     options=["top_left",    "top_center",    "top_right",
              "middle_left", "middle_center", "middle_right",
              "bottom_left", "bottom_center", "bottom_right"])

// ═══════════════════════════════════════════
//  INPUTS — VWAP
// ═══════════════════════════════════════════
showVWAP           = input.bool(true, "Show VWAP")
showHistoricalVWAP = input.bool(true, "Show Historical VWAP")

// ═══════════════════════════════════════════
//  INPUTS — NSE/BSE EQUITIES
// ═══════════════════════════════════════════
showNSE = input.bool(true, "━━━━━━ NSE/BSE Equities ━━━━━━")

// ═══════════════════════════════════════════
//  INPUTS — MCX COMMODITIES
// ═══════════════════════════════════════════
showMCX       = input.bool(false, "━━━━━━ MCX Commodities ━━━━━━")
mcxSeason     = input.string("Summer (870 min)", "MCX Market Session",
     options=["Summer (870 min)", "Winter (895 min)", "Custom"])
mcxCustomMins = input.int(870, "Custom MCX Session (minutes)",
     minval=1, maxval=1440,
     tooltip="Only used when 'Custom' is selected above.\nSummer = 870 min (9:00 AM – 11:30 PM)\nWinter = 895 min (9:00 AM – 11:55 PM)")

// ═══════════════════════════════════════════
//  CONSTANTS
// ═══════════════════════════════════════════
MAX_BARS = 5000
NSE_MINS = 375   // 9:15 AM – 3:30 PM

// ═══════════════════════════════════════════
//  MCX SESSION LENGTH RESOLVER
// ═══════════════════════════════════════════
mcxMins = mcxSeason == "Summer (870 min)" ? 870 :
          mcxSeason == "Winter (895 min)" ? 895 :
          mcxCustomMins

// ═══════════════════════════════════════════
//  DYNAMIC PERIOD CALCULATOR — NSE/BSE
// ═══════════════════════════════════════════
calc_nse_period(days) =>
    if timeframe.isdaily
        days
    else if timeframe.isweekly
        int(math.max(1, math.round(days / 5)))
    else
        total_minutes = days * NSE_MINS
        tf_minutes    = timeframe.multiplier
        tf_minutes != 0 ? int(math.max(1, math.round(total_minutes / tf_minutes))) : 1

// ═══════════════════════════════════════════
//  DYNAMIC PERIOD CALCULATOR — MCX
// ═══════════════════════════════════════════
calc_mcx_period(days) =>
    if timeframe.isdaily
        days
    else if timeframe.isweekly
        int(math.max(1, math.round(days / 5)))
    else
        total_minutes = days * mcxMins
        tf_minutes    = timeframe.multiplier
        tf_minutes != 0 ? int(math.max(1, math.round(total_minutes / tf_minutes))) : 1

// ═══════════════════════════════════════════
//  NSE PERIODS
// ═══════════════════════════════════════════
p5  = calc_nse_period(5)
p10 = calc_nse_period(10)
p21 = calc_nse_period(21)
p50 = calc_nse_period(50)

// ═══════════════════════════════════════════
//  MCX PERIOD
// ═══════════════════════════════════════════
pMCX5 = calc_mcx_period(5)

// ═══════════════════════════════════════════
//  NSE MA CALCULATIONS
// ═══════════════════════════════════════════
sma5  = showNSE and p5  <= MAX_BARS ? ta.sma(close, p5)  : na
ema10 = showNSE and p10 <= MAX_BARS ? ta.ema(close, p10) : na
ema21 = showNSE and p21 <= MAX_BARS ? ta.ema(close, p21) : na
ema50 = showNSE and p50 <= MAX_BARS ? ta.ema(close, p50) : na

// ═══════════════════════════════════════════
//  MCX MA CALCULATION
// ═══════════════════════════════════════════
mcxSma5 = showMCX and pMCX5 <= MAX_BARS ? ta.sma(close, pMCX5) : na

// ═══════════════════════════════════════════
//  MARKET-AWARE SESSION VWAP
//  All times explicitly anchored in IST
//  MCX → resets at 9:00 AM IST
//  NSE → resets at 9:15 AM IST
// ═══════════════════════════════════════════

// Current bar's date in IST
barYear  = year(time,  "Asia/Kolkata")
barMonth = month(time, "Asia/Kolkata")
barDay   = dayofmonth(time, "Asia/Kolkata")

// Exact session open timestamps in IST for this bar's date
mcxOpenTS = timestamp("Asia/Kolkata", barYear, barMonth, barDay,  9,  0, 0)
nseOpenTS = timestamp("Asia/Kolkata", barYear, barMonth, barDay,  9, 15, 0)

// First bar at or after session open
// Works on all timeframes — no dependence on bar aligning exactly to open time
isMCXSessionStart = time >= mcxOpenTS and (na(time[1]) or time[1] < mcxOpenTS)
isNSESessionStart = time >= nseOpenTS and (na(time[1]) or time[1] < nseOpenTS)

// Reset trigger — MCX takes priority if both are on
isSessionReset = showMCX ? isMCXSessionStart :
                 showNSE ? isNSESessionStart  :
                 timeframe.change("D")         // fallback if both markets off

// Cumulative sums — hard reset at each session open
var float cumTPV = 0.0
var float cumVol = 0.0

if isSessionReset
    cumTPV := 0.0
    cumVol := 0.0

typicalPrice = (high + low + close) / 3
cumTPV      += typicalPrice * volume
cumVol      += volume

sessionVWAP = cumVol != 0 ? cumTPV / cumVol : na

// ═══════════════════════════════════════════
//  TODAY CHECK — fully IST-aware
// ═══════════════════════════════════════════
nowYear  = year(timenow,  "Asia/Kolkata")
nowMonth = month(timenow, "Asia/Kolkata")
nowDay   = dayofmonth(timenow, "Asia/Kolkata")

isToday = barYear == nowYear and barMonth == nowMonth and barDay == nowDay

// Also confirm bar is at or past today's session open
isTodaySession = isToday and (showMCX ? time >= mcxOpenTS : time >= nseOpenTS)

// ═══════════════════════════════════════════
//  VWAP PLOT LOGIC
//  Historical on  → ta.vwap across all days
//  Historical off → sessionVWAP today only,
//                   from exact market open
// ═══════════════════════════════════════════
vwapPlot = showVWAP
     ? (showHistoricalVWAP ? ta.vwap : (isTodaySession ? sessionVWAP : na))
     : na

// ═══════════════════════════════════════════
//  PLOTS — NSE MAs
// ═══════════════════════════════════════════
plot(sma5,  title="5 SMA",  color=color.new(#ffffff, 0), linewidth=1)
plot(ema10, title="10 EMA", color=color.new(#38bdf8, 0), linewidth=1)
plot(ema21, title="21 EMA", color=color.new(#4ade80, 0), linewidth=2)
plot(ema50, title="50 EMA", color=color.new(#fb923c, 0), linewidth=2)

// ═══════════════════════════════════════════
//  PLOT — MCX 5 SMA
// ═══════════════════════════════════════════
plot(mcxSma5, title="MCX 5 SMA", color=color.new(#facc15, 0), linewidth=2)

// ═══════════════════════════════════════════
//  PLOT — VWAP
// ═══════════════════════════════════════════
plot(vwapPlot, title="VWAP", color=color.new(#e879f9, 0), linewidth=2)

// ═══════════════════════════════════════════
//  DISTANCE CALCULATIONS
// ═══════════════════════════════════════════
dist5    = not na(sma5)        ? (close - sma5)        / sma5        * 100 : na
dist10   = not na(ema10)       ? (close - ema10)       / ema10       * 100 : na
dist21   = not na(ema21)       ? (close - ema21)       / ema21       * 100 : na
dist50   = not na(ema50)       ? (close - ema50)       / ema50       * 100 : na
distMCX5 = not na(mcxSma5)     ? (close - mcxSma5)     / mcxSma5     * 100 : na
distVWAP = not na(sessionVWAP) ? (close - sessionVWAP) / sessionVWAP * 100 : na

distColor(d) => d >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)

// ═══════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════
distText(d) =>
    na(d) ? "Insuf. Data" : str.tostring(d, format.percent)

distTextColor(d) =>
    na(d) ? color.new(color.gray, 0) : distColor(d)

clearCell(t, col, row) =>
    table.cell(t, col, row, "",
         text_color=color.new(color.black, 100),
         text_size=size.small)

// ═══════════════════════════════════════════
//  TABLE  (2 cols × 6 rows)
// ═══════════════════════════════════════════
var table infoTable = table.new(
     position     = labelPosition,
     columns      = 2,
     rows         = 6,
     bgcolor      = color.new(color.black, 20),
     border_width = 1)

if barstate.islast and showTable
    // ── NSE ROWS ──────────────────────────
    if showNSE
        table.cell(infoTable, 0, 0, "5 SMA",
             text_color=color.new(#ffffff, 0),
             text_size=size.small, text_halign=text.align_left)
        table.cell(infoTable, 1, 0, distText(dist5),
             text_color=distTextColor(dist5), text_size=size.small)

        table.cell(infoTable, 0, 1, "10 EMA",
             text_color=color.new(#38bdf8, 0),
             text_size=size.small, text_halign=text.align_left)
        table.cell(infoTable, 1, 1, distText(dist10),
             text_color=distTextColor(dist10), text_size=size.small)

        table.cell(infoTable, 0, 2, "21 EMA",
             text_color=color.new(#4ade80, 0),
             text_size=size.small, text_halign=text.align_left)
        table.cell(infoTable, 1, 2, distText(dist21),
             text_color=distTextColor(dist21), text_size=size.small)

        table.cell(infoTable, 0, 3, "50 EMA",
             text_color=color.new(#fb923c, 0),
             text_size=size.small, text_halign=text.align_left)
        table.cell(infoTable, 1, 3, distText(dist50),
             text_color=distTextColor(dist50), text_size=size.small)
    else
        clearCell(infoTable, 0, 0)
        clearCell(infoTable, 1, 0)
        clearCell(infoTable, 0, 1)
        clearCell(infoTable, 1, 1)
        clearCell(infoTable, 0, 2)
        clearCell(infoTable, 1, 2)
        clearCell(infoTable, 0, 3)
        clearCell(infoTable, 1, 3)

    // ── VWAP ROW ──────────────────────────
    table.cell(infoTable, 0, 4, "VWAP",
         text_color=color.new(#e879f9, 0),
         text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 4, distText(distVWAP),
         text_color=distTextColor(distVWAP), text_size=size.small)

    // ── MCX ROW ───────────────────────────
    if showMCX
        mcxLabel = "MCX 5 SMA (" + str.tostring(mcxMins) + "m)"
        table.cell(infoTable, 0, 5, mcxLabel,
             text_color=color.new(#facc15, 0),
             text_size=size.small, text_halign=text.align_left)
        table.cell(infoTable, 1, 5, distText(distMCX5),
             text_color=distTextColor(distMCX5), text_size=size.small)
    else
        clearCell(infoTable, 0, 5)
        clearCell(infoTable, 1, 5)
````
