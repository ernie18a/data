#  Session ATR Risk Tool

- url: https://www.tradingview.com/script/DQMoBBKV-Session-ATR-Risk-Tool/
- type: indicator
- pine_id: PUB;0bd5e0e458bb419184db9e91141c125d
- version: 4.0

## Description

Session ATR Risk Tool

## Overview
The Session ATR Risk Tool is a discretionary **risk-management and trade-planning overlay**. It sizes a stop loss from market volatility, projects fixed reward-to-risk targets (1:1, 1:2, 1:3), and draws a standard-deviation ladder so you can see your full trade geometry on the chart before you enter. It also estimates a contract count from a fixed dollar risk, and prints a context table of intraday, daily and weekly volatility.

It is built and tuned for Micro E-mini Nasdaq-100 (MNQ) intraday trading, but every parameter is exposed as an input, so it works on any symbol once you set the correct point value.

This tool does **not** generate buy/sell signals and makes no claim about win rate or profitability. It is a visualization and planning aid only.

## What makes it different
Most reward-to-risk tools place lines a fixed number of ticks or a single ATR away. This tool adds three things in one package:

1. **Two selectable stop engines.** The stop distance can be derived from either the chart-timeframe ATR (small, realistic intraday stops) or from a rolling average of completed *session* ranges (swing-sized stops). You choose which volatility regime sizes your risk.
2. **A standard-deviation ladder denominated in your own stop distance.** Instead of arbitrary fib or price-percent levels, each rung is a multiple (−0.5, 1, 2, 3, 4 by default, all editable) of the exact ATR-based stop distance, projected from entry. One "sd" on the chart always equals one unit of the risk you are actually taking.
3. **A volatility context table.** Intraday ATR, averaged session range, daily ATR(14) and weekly ATR(14) are shown side by side so the chosen stop can be judged against higher-timeframe volatility at a glance.

## How it works
- **Session range capture.** The script tracks the high and low of each completed session window (default 09:30–16:00 exchange time) and stores the high-low range. It keeps a rolling buffer of the most recent N sessions (default 10) and averages them to produce a "session ATR" in points.
- **Intraday ATR.** A standard ATR of configurable length is calculated on the chart timeframe for scalp-sized stops.
- **Stop distance.** `Stop distance = chosen basis × ATR multiplier`, where the basis is either the intraday ATR or the averaged session range. The multiplier lets you tighten or widen the stop.
- **Trade geometry.** From the entry price (live price by default, or a fixed price you type in) and the trade direction, the tool places the stop one stop-distance against you, then projects targets at 1×, 2× and 3× the stop distance for clean 1:1 / 1:2 / 1:3 reward-to-risk.
- **Standard-deviation ladder.** Each ladder rung is plotted at `entry + direction × stop distance × deviation`, giving an evenly scaled map of where price sits relative to your risk unit.
- **Position-size estimate.** Dollar risk per contract = stop distance × point value. Estimated contracts = floor(risk per trade ÷ dollar risk per contract). This is an arithmetic estimate for planning, not an order-routing instruction.
- **Higher-timeframe context.** Daily and weekly ATR(14) are pulled from confirmed higher-timeframe bars (non-repainting) for the context table.

All levels are drawn as faded horizontal rays anchored to the bar grid, so they stay locked to the candles when you pan or zoom. Drawings rebuild on the most recent bar to keep the chart clean.

## How to use it
1. Add the tool to an intraday chart of the instrument you trade.
2. Set **$ per Point** for your instrument (MNQ = 2.0, NQ = 20.0, MES = 5.0, etc.) and your **Risk per Trade ($)**.
3. Choose your **Stop Basis** — "Intraday ATR" for scalps and intraday entries, "Session Range" for wider, swing-style stops.
4. Adjust the **ATR Multiplier** to set how far the stop sits from entry. As a starting guide, roughly 1.0–2.0× with Intraday ATR on a 1–5 minute chart; if using Session Range, scale the multiplier down (around 0.10–0.20×) because the session range is much larger.
5. Set **Trade Direction** (Long or Short). Leave **Entry Price** at 0 to anchor the levels to live price, or type your actual fill price to lock the geometry in place after entry.
6. Read your plan off the chart: the Stop, the 1:1 / 1:2 / 1:3 targets, the standard-deviation ladder, and the info table showing the stop in points and dollars plus an estimated contract count.

## Inputs
- **Session Window / Sessions to Average** — defines the session and how many completed sessions feed the averaged session range.
- **Stop Basis / Intraday ATR Length / ATR Multiplier** — select and tune the volatility source for the stop.
- **Trade Direction / Entry Price** — direction toggle and optional fixed entry.
- **$ per Point / Risk per Trade ($)** — instrument tick value and account risk used for the size estimate.
- **SDev Ladder deviations** — the five editable ladder multiples.
- **Visual controls** — ray length back/forward, table toggle, and colors for up, down and entry levels.

## Notes and limitations
- The contract-count figure is an arithmetic estimate from your inputs. It is not connected to a broker and places no orders. Always confirm size and risk in your own platform.
- "Session ATR" here means the averaged high-low **range** of recent sessions, not a true-range calculation; it is intentionally a wider, regime-level measure.
- Higher-timeframe ATR values use confirmed bars to avoid repainting.
- Reward-to-risk targets are fixed geometric projections; they are not predictions of price reaching those levels.
- This script is a planning and visualization tool only. It is not financial advice and does not guarantee any outcome.

## Source Code

````pine
//@version=6
// =============================================================================
//  NQ Session ATR Risk Tool
//  Sizes a stop loss from the CURRENT SESSION'S average true range, projects
//  1:1 / 1:2 / 1:3 targets, and overlays a standard-deviation ladder
//  (-0.5 / 1 / 2 / 3 / 4) measured in units of the ATR-based stop distance.
//  Faded minimal horizontal rays mark Entry / Stop / TP. Long & Short toggle.
// =============================================================================
indicator("NQ Session ATR Risk Tool", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// == INPUTS — SESSION ATR ENGINE ==============================================
string  sessionStr      = input.session("0930-1600", "Session Window (exchange time)", group = "Session ATR")
int     sessionLookback = input.int(10, "Sessions to Average", minval = 1, maxval = 60, group = "Session ATR", tooltip = "How many completed sessions to average for the session ATR.")

// == INPUTS — RISK MODEL ======================================================
string  stopBasis       = input.string("Intraday ATR (chart TF)", "Stop Basis", options = ["Intraday ATR (chart TF)", "Session Range"], group = "Risk Model", tooltip = "Intraday ATR = ta.atr on your chart timeframe — use this for scalps/intraday (small, realistic stops). Session Range = full session high-low — swing-sized, much normalr.")
int     atrLength       = input.int(14, "Intraday ATR Length", minval = 1, maxval = 200, group = "Risk Model")
float   atrMultiplier   = input.float(1.5, "ATR Multiplier (Stop = mult x basis)", minval = 0.1, maxval = 5.0, step = 0.1, group = "Risk Model", tooltip = "Scalp guide: ~1.0-2.0x on a 1-5m chart with Intraday ATR. If using Session Range, drop to ~0.10-0.20x.")
string  tradeDirection  = input.string("Long", "Trade Direction", options = ["Long", "Short"], group = "Risk Model")
float   entryInput      = input.float(0.0, "Entry Price (0 = use current price)", group = "Risk Model", tooltip = "Type your fill price to lock the levels there, or leave 0 to anchor to live price so the ladder stays glued to the candles.")
float   pointValue      = input.float(2.0, "$ per Point (MNQ = 2.0)", minval = 0.01, step = 0.5, group = "Risk Model", tooltip = "MNQ = $2.00 per index point. NQ = $20.00.")
float   riskDollars     = input.float(200.0, "Risk per Trade ($)", minval = 1.0, step = 10.0, group = "Risk Model", tooltip = "Used to estimate contract count for the ATR stop.")

// == INPUTS — STANDARD DEVIATION LADDER =======================================
bool    showDevLadder   = input.bool(true, "Show SDev Ladder", group = "SDev Ladder", tooltip = "Deviations are multiples of the ATR stop distance, projected from entry.")
float   dev0            = input.float(-0.5, "Deviation 0", group = "SDev Ladder")
float   dev1            = input.float(1.0,  "Deviation 1", group = "SDev Ladder")
float   dev2            = input.float(2.0,  "Deviation 2", group = "SDev Ladder")
float   dev3            = input.float(3.0,  "Deviation 3", group = "SDev Ladder")
float   dev4            = input.float(4.0,  "Deviation 4", group = "SDev Ladder")

// == INPUTS — VISUALS =========================================================
int     rayBackBars     = input.int(40, "Ray Length Back (bars)", minval = 5, maxval = 200, group = "Visuals")
int     rayFwdBars      = input.int(15, "Ray Length Forward (bars)", minval = 0, maxval = 200, group = "Visuals")
bool    showTable       = input.bool(true, "Show Info Table", group = "Visuals")
string  tablePosInput   = input.string("Top Right", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = "Visuals")
string  tableSizeInput  = input.string("small", "Table Text Size", options = ["small", "tiny", "normal"], group = "Visuals")
color   upColor         = input.color(color.new(#003ec4, 0),  "Up Color (targets / long / +sd)",   group = "Visuals")
color   downColor       = input.color(color.new(#ee0101, 0),  "Down Color (stop / short / -sd)",   group = "Visuals")
color   entryColor      = input.color(color.new(#000000, 20), "Entry Color (neutral)",             group = "Visuals")

// == SESSION ATR CALCULATION ==================================================
//@variable Rolling store of completed session ranges (points)
var array<float> sessionRanges = array.new<float>(0)
//@variable Running session extremes for the in-progress session
var float sessHigh = na
var float sessLow  = na

bool inSession  = not na(time(timeframe.period, sessionStr))
bool newSession = inSession and not inSession[1]
bool endSession = not inSession and inSession[1]

if newSession
    sessHigh := high
    sessLow  := low
else if inSession
    sessHigh := math.max(sessHigh, high)
    sessLow  := math.min(sessLow, low)

// On session close, store the completed range and keep the buffer rolling
if endSession and not na(sessHigh) and not na(sessLow)
    sessionRanges.unshift(sessHigh - sessLow)
    if sessionRanges.size() > sessionLookback
        sessionRanges.pop()

//@function Mean of a float array; returns na on empty
//@param src (array<float>) The values to average
//@returns (float) The arithmetic mean, or na if empty
arrayMean(array<float> src) =>
    int n = src.size()
    float result = na
    if n > 0
        float sum = 0.0
        for i = 0 to n - 1
            sum += src.get(i)
        result := sum / n
    result

float sessionATR  = arrayMean(sessionRanges)
float intradayATR = ta.atr(atrLength)              // chart-timeframe ATR (scalp basis)

// == HTF CONTEXT (Daily / Weekly ATR) — top-level scope only ==================
float dailyATR  = request.security(syminfo.tickerid, "D", ta.atr(14)[1], lookahead = barmerge.lookahead_on)
float weeklyATR = request.security(syminfo.tickerid, "W", ta.atr(14)[1], lookahead = barmerge.lookahead_on)

// == RISK MODEL ===============================================================
bool  isLong     = tradeDirection == "Long"
int   dirSign    = isLong ? 1 : -1
float entryPrice = entryInput == 0.0 ? close : entryInput
float baseVol    = stopBasis == "Session Range" ? sessionATR : intradayATR
float slDistance = na(baseVol) ? na : baseVol * atrMultiplier            // points

float stopPrice  = na(slDistance) ? na : entryPrice - dirSign * slDistance
float tp1Price   = na(slDistance) ? na : entryPrice + dirSign * slDistance * 1.0
float tp2Price   = na(slDistance) ? na : entryPrice + dirSign * slDistance * 2.0
float tp3Price   = na(slDistance) ? na : entryPrice + dirSign * slDistance * 3.0

float dollarRisk    = na(slDistance) ? na : slDistance * pointValue       // $ per contract
int   contractCount = na
if not na(slDistance) and dollarRisk > 0
    contractCount := int(math.floor(riskDollars / dollarRisk))

// == DRAWING — REBUILT ON LAST BAR ============================================
var array<line>  lineStore  = array.new<line>(0)
var array<label> labelStore = array.new<label>(0)

//@function Clears all stored lines and labels before a redraw
clearDrawings() =>
    while lineStore.size() > 0
        line.delete(lineStore.shift())
    while labelStore.size() > 0
        label.delete(labelStore.shift())

//@function Draws one faded horizontal ray (time-anchored) with a side label
//@param price     (float)  The y-level for the ray
//@param col       (color)  Line and text color
//@param txt       (string) Label text
//@param styl      (string) Line style constant
//@param labelLeft (bool)   True = label at left end (SDev), false = right end (trade levels)
//@param x1        (int)    Left x in bar_time (ms)
//@param x2        (int)    Right x in bar_time (ms)
//@param txtCol    (color)  Label text color (contrasts with the chip background)
drawRay(float price, color col, string txt, string styl, bool labelLeft, int x1, int x2, color txtCol) =>
    if not na(price)
        line ln = line.new(x1, price, x2, price, xloc = xloc.bar_time, color = col, width = 1, style = styl)
        lineStore.push(ln)
        int    labelX = labelLeft ? x1 : x2
        string lStyle = labelLeft ? label.style_label_right : label.style_label_left
        label lb = label.new(labelX, price, text = txt, style = lStyle, color = col, textcolor = txtCol, size = size.tiny, xloc = xloc.bar_time)
        labelStore.push(lb)

if barstate.islast
    clearDrawings()

    // Lock x-axis: anchor left at the chosen entry bar (or auto window), project right
    int periodMs = timeframe.in_seconds() * 1000
    int rightT   = time + rayFwdBars * periodMs
    int leftT    = time - rayBackBars * periodMs

    // SDev ladder first (so trade levels sit visually on top)
    if showDevLadder and not na(slDistance)
        float[] devs = array.from(dev0, dev1, dev2, dev3, dev4)
        for i = 0 to devs.size() - 1
            float d   = devs.get(i)
            float lvl = entryPrice + dirSign * slDistance * d
            string dTxt = (d >= 0 ? "+" : "") + str.tostring(d, "#.##") + " sd"
            color  dCol = d >= 0 ? upColor : downColor
            color  dTxtCol = d >= 0 ? color.rgb(255, 255, 255) : color.white
            drawRay(lvl, dCol, dTxt, line.style_dotted, true, leftT, rightT, dTxtCol)

    // Core trade geometry (chip text contrasts: black on white/grey, white on black)
    drawRay(entryPrice, entryColor, "Entry", line.style_dotted, false, leftT, rightT, color.white)
    drawRay(stopPrice,  downColor,  "Stop", line.style_dotted, false, leftT, rightT, color.white)
    drawRay(tp1Price,   upColor,    "TP 1:1", line.style_dotted, false, leftT, rightT, color.rgb(255, 255, 255))
    drawRay(tp2Price,   upColor,    "TP 1:2", line.style_dotted, false, leftT, rightT, color.rgb(255, 255, 255))
    drawRay(tp3Price,   upColor,    "TP 1:3", line.style_dotted, false, leftT, rightT, color.rgb(255, 255, 255))

// == INFO TABLE ===============================================================
//@function Resolves a table position name.
//@param p (string) The position name.
//@returns (string) The position constant.
tablePos(string p) =>
    switch p
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        =>                position.top_right

//@function Resolves a table text size name.
//@param s (string) "small", "tiny" or "normal".
//@returns (string) The size constant.
tableSize(string s) =>
    switch s
        "tiny" => size.tiny
        "normal" => size.normal
        =>         size.small

const color TBL_INK = #000000
const color TBL_BG  = #FFFFFF
string TBL_SZ = tableSize(tableSizeInput)

var table infoTable = table.new(tablePos(tablePosInput), 2, 9, bgcolor = TBL_BG, frame_color = TBL_INK, frame_width = 1, border_color = TBL_INK, border_width = 1)

//@function Writes a labeled row into the info table: name italic, reading bold, full black on white
//@param row  (int)    Row index
//@param k    (string) Key text
//@param v    (string) Value text
//@param vCol (color)  Value text color
tblRow(int row, string k, string v, color vCol) =>
    table.cell(infoTable, 0, row, k, text_color = TBL_INK, text_size = TBL_SZ, text_halign = text.align_left,  bgcolor = TBL_BG, text_font_family = font.family_monospace, text_formatting = text.format_bold + text.format_italic)
    table.cell(infoTable, 1, row, v, text_color = vCol,    text_size = TBL_SZ, text_halign = text.align_right, bgcolor = TBL_BG, text_font_family = font.family_monospace, text_formatting = text.format_bold)

if barstate.islast and showTable
    string basisTxt   = stopBasis == "Session Range" ? (na(sessionATR) ? "—" : str.tostring(sessionATR, "#.##") + " pts") : (na(intradayATR) ? "—" : str.tostring(intradayATR, "#.##") + " pts")
    string basisLbl   = stopBasis == "Session Range" ? "Session Range (" + str.tostring(sessionLookback) + " sess)" : "Intraday ATR(" + str.tostring(atrLength) + ") " + timeframe.period
    string slTxt      = na(slDistance) ? "—" : str.tostring(slDistance, "#.##") + " pts ($" + str.tostring(slDistance * pointValue, "#.##") + ")"
    string ctTxt      = na(contractCount) ? "—" : str.tostring(contractCount) + " @ $" + str.tostring(riskDollars, "#") + " risk"

    tblRow(0, "ATR Risk", isLong ? "LONG" : "SHORT", isLong ? color.rgb(8, 52, 196) : color.rgb(206, 8, 8))
    tblRow(1, basisLbl, basisTxt, TBL_INK)
    tblRow(2, "Daily ATR(14)",  na(dailyATR)  ? "—" : str.tostring(dailyATR,  "#.##") + " pts", TBL_INK)
    tblRow(3, "Weekly ATR(14)", na(weeklyATR) ? "—" : str.tostring(weeklyATR, "#.##") + " pts", TBL_INK)
    tblRow(4, "Stop (" + str.tostring(atrMultiplier, "#.##") + "x)", slTxt, TBL_INK)
    tblRow(5, "TP 1:1 / 1:2 / 1:3", na(slDistance) ? "—" : str.tostring(slDistance, "#.#") + " / " + str.tostring(slDistance * 2, "#.#") + " / " + str.tostring(slDistance * 3, "#.#") + " pts", TBL_INK)
    tblRow(6, "Entry", str.tostring(entryPrice, format.mintick), TBL_INK)
    tblRow(7, "Est. Size", ctTxt, TBL_INK)
    tblRow(8, "1 sd =", na(slDistance) ? "—" : str.tostring(slDistance, "#.##") + " pts", TBL_INK)

// == ALERTS ===================================================================
alertcondition(not na(stopPrice) and low <= stopPrice and isLong,  "Long Stop Hit",  "NQ Long stop level reached")
alertcondition(not na(stopPrice) and high >= stopPrice and not isLong, "Short Stop Hit", "NQ Short stop level reached")
alertcondition(not na(tp1Price) and ((isLong and high >= tp1Price) or (not isLong and low <= tp1Price)), "TP 1:1 Hit", "NQ 1:1 target reached")
````
