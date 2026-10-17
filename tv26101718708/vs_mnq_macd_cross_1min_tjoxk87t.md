# V's MNQ MACD Cross 1Min

- url: https://www.tradingview.com/script/tjoXK87t-V-s-MNQ-MACD-Cross-1Min/
- type: indicator
- pine_id: PUB;7bab99994af04b9d8f57da166cf7dbaf
- version: 1.0

## Description

MACD Crossover Strategy — Quick Reference
Backtested Defaults: May 2026 | Status: Profitable

Signal Setup (Adjustable Settings)
Parameter Value Indicator MACD (6, 11, 3)
Entry Trigger MACD line: Crossover
Confirmation: 2-bar close after Cross

Stop Loss/Target Profit (Adjustable Settings/Toggle)
Parameter Value Default: Stop Loss 13 Ticks/Target Profit 11 Ticks
Purpose: Targets Stop Loss/Target Profit
Use Case: Adds Stop Loss/Target Profit Indicator Chart

Session Filter (Adjustable Settings/Toggle)
Parameter Value Default: 09:30 – 10:00 ET
Purpose: Trading Time
Use Case: Highlights your preferred session to limit trading to those hours. Useful for maintaining consistency and avoiding low-probability set-ups outside your optimal window.

Max Trades Filter (Adjustable Settings/Toggle)
Parameter Value Default: 1
Purpose: Cap the number of trades taken per day
Use Case: Prevent overtrading

* Tip* Create and reference your Trading Journal to determine a personal daily limit that suits your style and performance history with the various parameters.

All parameters should be validated against your own risk tolerance before live trading.

## Source Code

````pine
// =============================================================================
// MNQ_MACD_Cross_1Min  –  TradingView Pine Script v6
//
// Ported from NinjaTrader 8 strategy: MNQ_MACD_Cross_1Min.cs
//
// Logic summary:
//   • MACD(Fast, Slow, Smooth) cross of MACD line vs Signal line
//   • Entry confirmed on the CLOSE of the 2nd bar AFTER the cross bar:
//       Long  → MACD still rising  (macdLine > macdLine[1])
//       Short → MACD still falling (macdLine < macdLine[1])
//   • Time filter: 09:30–10:00 ET  (set chart timezone → America/New_York)
//   • Max N signals per day (configurable, default 1)
//   • Stale setups expire if not triggered by bar 2 after cross
//   • Visual SL/TP dashed lines drawn from each signal bar
//
// Usage:
//   1. Open TradingView on a 1-minute MNQ (or NQ) chart.
//   2. Set chart timezone to "America/New_York".
//   3. Pine Script Editor → paste → Add to chart.
//   4. Green ▲ BUY  |  Red ▼ SELL
//   5. Dashed red = Stop Loss  |  Dashed green = Profit Target
// =============================================================================

//@version=6
indicator(
     title            = "MNQ MACD Cross 1Min",
     shorttitle       = "MACD X 1M",
     overlay          = true,
     max_lines_count  = 300,
     max_labels_count = 500
 )

// ─── INPUTS ───────────────────────────────────────────────────────────────────
const string GRP_MACD = "MACD Settings"
int   i_fast   = input.int  (6,    "Fast Length",   minval = 1, group = GRP_MACD)
int   i_slow   = input.int  (11,   "Slow Length",   minval = 1, group = GRP_MACD)
int   i_smooth = input.int  (3,    "Signal Smooth", minval = 1, group = GRP_MACD)

const string GRP_RISK = "Risk Management"
float  i_sl       = input.float(13.0, "Stop Loss (points)",     minval = 0.01, group = GRP_RISK)
float  i_tp       = input.float(12.0, "Profit Target (points)", minval = 0.01, group = GRP_RISK)
bool   i_showSL   = input.bool (true, "Show Stop Loss Level",                   group = GRP_RISK)
bool   i_showTP   = input.bool (true, "Show Profit Target Level",               group = GRP_RISK)

const string GRP_TIME = "Session Filter  (chart timezone → America/New_York)"
bool i_useSession = input.bool (true, "Enable Session Filter",                        group = GRP_TIME)
int  i_startHHMM  = input.int (930,  "Start Time HHMM (ET)", minval = 0, maxval = 2359, group = GRP_TIME)
int  i_endHHMM    = input.int (1000, "End Time HHMM (ET)",   minval = 0, maxval = 2359, group = GRP_TIME)

const string GRP_FILT = "Trade Filters"
string i_dir          = input.string("Both", "Trade Direction",
                          options = ["Both", "LongOnly", "ShortOnly"], group = GRP_FILT)
bool   i_useMaxTrades = input.bool(true, "Enable Max Signals Per Day",                group = GRP_FILT)
int    i_maxTrades    = input.int (1,    "Max Signals Per Day", minval = 1,            group = GRP_FILT)

// ─── MACD ─────────────────────────────────────────────────────────────────────
[macdLine, signalLine, _hist] = ta.macd(close, i_fast, i_slow, i_smooth)

// ─── TIME FILTER ──────────────────────────────────────────────────────────────
// hour() / minute() accept a timezone string; America/New_York handles EST/EDT.
int  _etHour  = hour(time,   "America/New_York")
int  _etMin   = minute(time, "America/New_York")
int  barHHMM  = _etHour * 100 + _etMin
bool inWindow = not i_useSession or (barHHMM >= i_startHHMM and barHHMM < i_endHHMM)

// ─── CROSS DETECTION ──────────────────────────────────────────────────────────
bool bullCross = ta.crossover (macdLine, signalLine)
bool bearCross = ta.crossunder(macdLine, signalLine)

// ─── STATE MACHINE  (mirrors C# barsSinceCross / crossDirection) ──────────────
//
//   crossDir        +1 = bullish setup pending
//                   -1 = bearish setup pending
//                    0 = no active setup
//   barsSinceCross  -1 = inactive
//                    0 = cross bar
//                    1 = bar after cross
//                    2 = confirmation bar  ← entry evaluated here
//
var int crossDir       = 0
var int barsSinceCross = -1

if bullCross
    crossDir       := 1
    barsSinceCross := 0
else if bearCross
    crossDir       := -1
    barsSinceCross := 0
else if barsSinceCross >= 0
    barsSinceCross += 1

// ─── DAILY SIGNAL COUNTER ─────────────────────────────────────────────────────
var int tradesToday = 0
int _etDay = dayofmonth(time, "America/New_York")
if na(time[1]) or _etDay != dayofmonth(time[1], "America/New_York")
    tradesToday := 0

// ─── DIRECTION FILTER ─────────────────────────────────────────────────────────
bool longsOK  = i_dir != "ShortOnly"
bool shortsOK = i_dir != "LongOnly"

// ─── CONFIRMATION CHECK (bar 2 after the cross) ───────────────────────────────
bool macdMovingUp   = macdLine > macdLine[1]
bool macdMovingDown = macdLine < macdLine[1]

bool longSignal  = false
bool shortSignal = false

bool tradeAllowed = not i_useMaxTrades or tradesToday < i_maxTrades
if barsSinceCross == 2 and crossDir != 0 and inWindow and tradeAllowed
    if crossDir == 1 and macdMovingUp and longsOK
        longSignal   := true
        tradesToday  += 1
    else if crossDir == -1 and macdMovingDown and shortsOK
        shortSignal  := true
        tradesToday  += 1
    // Consume setup regardless of entry (matches NinjaTrader behavior)
    crossDir       := 0
    barsSinceCross := -1

// ─── EXPIRE STALE SETUPS (bar > 2 with no entry) ─────────────────────────────
if barsSinceCross > 2
    crossDir       := 0
    barsSinceCross := -1

// ─── SIGNAL MARKERS ───────────────────────────────────────────────────────────
plotshape(
     longSignal,
     title     = "Long Signal",
     style     = shape.triangleup,
     location  = location.belowbar,
     color     = color.new(#00e676, 0),
     size      = size.normal,
     text      = "BUY",
     textcolor = color.new(#00e676, 0)
 )

plotshape(
     shortSignal,
     title     = "Short Signal",
     style     = shape.triangledown,
     location  = location.abovebar,
     color     = color.new(#ff1744, 0),
     size      = size.normal,
     text      = "SELL",
     textcolor = color.new(#ff1744, 0)
 )

// ─── ENTRY PRICE LABELS ───────────────────────────────────────────────────────
// Shown on every signal regardless of the SL/TP toggle.
if longSignal
    label.new(
         chart.point.from_index(bar_index, close),
         text      = "@ " + str.tostring(close, "#.##"),
         color     = color.new(#00e676, 15),
         textcolor = color.white,
         style     = label.style_label_up,   // arrow points up toward the bar
         size      = size.small
     )

if shortSignal
    label.new(
         chart.point.from_index(bar_index, close),
         text      = "@ " + str.tostring(close, "#.##"),
         color     = color.new(#ff1744, 15),
         textcolor = color.white,
         style     = label.style_label_down, // arrow points down toward the bar
         size      = size.small
     )

// ─── SESSION WINDOW BACKGROUND ────────────────────────────────────────────────
bgcolor(inWindow ? color.new(color.blue, 92) : na, title = "Session Window")

// ─── SL / TP VISUAL LEVELS (v6: chart.point API) ─────────────────────────────
// chart.point.from_index() is the v6-native way to anchor lines and labels.
if longSignal
    float slPrice = close - i_sl
    float tpPrice = close + i_tp

    if i_showSL
        line.new(
             chart.point.from_index(bar_index,      slPrice),
             chart.point.from_index(bar_index + 15, slPrice),
             color = color.new(color.red, 20),
             width = 1,
             style = line.style_dashed
         )
        label.new(
             chart.point.from_index(bar_index + 15, slPrice),
             text      = "SL  " + str.tostring(slPrice, "#.##"),
             color     = color.new(color.red, 15),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = size.small
         )
    if i_showTP
        line.new(
             chart.point.from_index(bar_index,      tpPrice),
             chart.point.from_index(bar_index + 15, tpPrice),
             color = color.new(color.green, 20),
             width = 1,
             style = line.style_dashed
         )
        label.new(
             chart.point.from_index(bar_index + 15, tpPrice),
             text      = "TP  " + str.tostring(tpPrice, "#.##"),
             color     = color.new(color.green, 15),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = size.small
         )

if shortSignal
    float slPrice = close + i_sl
    float tpPrice = close - i_tp

    if i_showSL
        line.new(
             chart.point.from_index(bar_index,      slPrice),
             chart.point.from_index(bar_index + 15, slPrice),
             color = color.new(color.red, 20),
             width = 1,
             style = line.style_dashed
         )
        label.new(
             chart.point.from_index(bar_index + 15, slPrice),
             text      = "SL  " + str.tostring(slPrice, "#.##"),
             color     = color.new(color.red, 15),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = size.small
         )
    if i_showTP
        line.new(
             chart.point.from_index(bar_index,      tpPrice),
             chart.point.from_index(bar_index + 15, tpPrice),
             color = color.new(color.green, 20),
             width = 1,
             style = line.style_dashed
         )
        label.new(
             chart.point.from_index(bar_index + 15, tpPrice),
             text      = "TP  " + str.tostring(tpPrice, "#.##"),
             color     = color.new(color.green, 15),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = size.small
         )

// ─── STATUS TABLE ─────────────────────────────────────────────────────────────
var table tbl = table.new(
     position.top_right, 2, 4,
     bgcolor      = color.new(color.black, 55),
     border_width = 1,
     border_color = color.new(color.gray, 60)
 )

if barstate.islast
    // Header
    table.cell(tbl, 0, 0, "MACD Cross 1Min",
               text_color  = color.white,
               text_size   = size.small,
               bgcolor     = color.new(#1565c0, 30),
               text_halign = text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    // Session window
    table.cell(tbl, 0, 1, "Session Window",
               text_color = color.new(color.gray, 20), text_size = size.small)
    table.cell(tbl, 1, 1,
               not i_useSession ? "OFF" : inWindow ? "OPEN ✓" : "CLOSED",
               text_color = not i_useSession ? color.gray : inWindow ? color.lime : color.red,
               text_size  = size.small)

    // Signals today
    table.cell(tbl, 0, 2, "Signals Today",
               text_color = color.new(color.gray, 20), text_size = size.small)
    table.cell(tbl, 1, 2,
               not i_useMaxTrades ? "OFF" : str.tostring(tradesToday) + " / " + str.tostring(i_maxTrades),
               text_color = not i_useMaxTrades ? color.gray : tradesToday < i_maxTrades ? color.white : color.orange,
               text_size  = size.small)

    // Pending setup
    string _setupStr = switch crossDir
        1  => "LONG (bar "  + str.tostring(barsSinceCross) + "/2)"
        -1 => "SHORT (bar " + str.tostring(barsSinceCross) + "/2)"
        => "None"
    table.cell(tbl, 0, 3, "Pending Setup",
               text_color = color.new(color.gray, 20), text_size = size.small)
    table.cell(tbl, 1, 3, _setupStr,
               text_color = crossDir == 1 ? color.lime : crossDir == -1 ? color.red : color.gray,
               text_size  = size.small)
````
