<!-- tradingview-pine-id: PUB;2fa1f888338349acbc01cbb08c9e806a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CTT - Position Size Calculator V1.0

Source: https://www.tradingview.com/script/J3QzIVl6-CTT-Position-Size-Calculator-V1-0/

## Description

CTT - Position Size Calculator V1.0 | Risk-Based Position Sizing
Confluence Trading Tools LLC

A chart overlay that calculates exactly how many shares to buy or sell based on your account size, risk tolerance, and stop loss — then draws entry, stop, and R-multiple profit targets directly on the chart. No more mental math, no more spreadsheets, no more guessing.

---

WHAT IT DOES

Enter your account balance and risk percentage. Set a stop loss (manually or let ATR do it). The calculator tells you exactly how many shares to trade so that if you get stopped out, you lose only the amount you chose to risk — nothing more.

---

CORE FEATURES

ATR-BASED STOP LOSS
Toggle between a manual stop price and an automatic ATR-calculated stop. In ATR mode, the stop is placed at entry ± (ATR × multiplier). Configurable ATR length (default 14) and multiplier (default 1.5×). No more eyeballing stop placement.

R-MULTIPLE PROFIT TARGETS
Three configurable profit targets based on your risk distance:
- 1R Target: risk/reward 1:1
- 2R Target: twice your risk distance
- 3R Target: three times your risk distance

Each target shows both the price level and the dollar profit at that level based on your calculated position size.

MAX POSITION CAP
Prevents overconcentration by capping the maximum position size to a percentage of your account (default 25%). When the calculated position exceeds the cap, shares are reduced and the table flags it in orange with the effective risk after capping.

CHART LINES
Entry (solid blue), stop loss (dashed red), and R-multiple targets (dotted green) are drawn directly on the chart with price labels. See exactly where your levels sit relative to price action. Line length is configurable.

LONG / SHORT SUPPORT
Toggle between long and short trades. Stops and targets automatically adjust direction — stop below entry for longs, above for shorts.

INFO TABLE
Compact table showing:
- Risk amount and percentage
- Stop price (with ATR info when in ATR mode)
- Stop distance in dollars and percentage
- Share count (flagged if capped)
- Capital required and percentage of account
- Max cap status
- All three R-multiple target prices with dollar profit

---

HOW TO USE

1. Set your account balance and risk percentage
2. Choose Long or Short
3. Set your stop — either type a manual price or switch to ATR mode
4. Read the table: shares to buy, capital required, and all three profit targets
5. Use the chart lines to visualize your trade setup against price action

---

USAGE NOTES

- Works on any asset class: equities, futures, forex, crypto
- Entry price defaults to the current close — you can also link it to another indicator's output via the source input
- ATR stop mode is recommended for volatile instruments where a fixed stop price doesn't adapt to conditions
- The position cap protects against concentration risk but does NOT override your broker's margin limits
- All calculations update in real time as price moves

---

Confluence Trading Tools LLC

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
// CTT - Position Size Calculator V1.0 | Confluence Trading Tools LLC
// Risk-Based Position Sizing with ATR Stop, R-Targets, and Max Cap
// ═══════════════════════════════════════════════════════════════════════════════
indicator("CTT - Position Size Calculator V1.0", shorttitle="CTT Size Calc", overlay=true, max_lines_count=10, max_labels_count=10)

// ─────────────────────────────────────────────────────────────────────────────────
// 1. INPUTS
// ─────────────────────────────────────────────────────────────────────────────────

grp_risk = "Risk Settings"
accountBalance = input.float(12900, title="Total Account Balance", group=grp_risk, tooltip="Your total trading account balance in dollars. Used to calculate the dollar amount at risk per trade.")
riskPercent    = input.float(0.5, title="Risk Per Trade (%)", step=0.01, group=grp_risk, tooltip="Percentage of your account balance you are willing to risk on a single trade. 0.5% = conservative, 1% = standard, 2% = aggressive.")
entryPrice     = input.source(close, title="Entry Price", group=grp_risk, tooltip="Price you plan to enter the trade at. Defaults to the current close. You can also link this to another indicator's output.")
tradeSide      = input.string("Long", title="Trade Side", options=["Long", "Short"], group=grp_risk, tooltip="Direction of the trade. Long = buying, stop is below entry. Short = selling, stop is above entry.")

grp_stop = "Stop Loss"
stopMode      = input.string("Manual", title="Stop Mode", options=["Manual", "ATR"], group=grp_stop, tooltip="Manual: you enter a specific stop price. ATR: stop is automatically calculated as entry ± (ATR × multiplier).")
stopLossPrice = input.float(0.0, title="Manual Stop Price", group=grp_stop, tooltip="The price where you will exit if the trade goes against you. Only used when Stop Mode is Manual.")
atrLength     = input.int(14, title="ATR Length", minval=1, group=grp_stop, tooltip="Lookback period for ATR calculation. 14 is standard. Shorter = tighter stops, longer = wider stops.")
atrMult       = input.float(1.5, title="ATR Multiplier", step=0.1, minval=0.1, group=grp_stop, tooltip="How many ATRs away from entry to place the stop. 1.0 = tight, 1.5 = standard, 2.0-3.0 = wide.")

grp_cap = "Position Cap"
useCap     = input.bool(true, title="Enable Max Position Cap", group=grp_cap, tooltip="Limits the maximum position size to a percentage of your account. Prevents overconcentration in a single trade.")
maxCapPct  = input.float(25.0, title="Max Position (% of Account)", step=1.0, minval=1.0, maxval=100.0, group=grp_cap, tooltip="Maximum percentage of your account that can go into one position. 25% = conservative, 50% = moderate.")

grp_targets = "R-Multiple Targets"
showTargets = input.bool(true, title="Show R-Multiple Targets", group=grp_targets, tooltip="Display 1R, 2R, and 3R profit target prices in the table and on the chart.")
r1Mult      = input.float(1.0, title="Target 1 (R)", step=0.5, minval=0.5, group=grp_targets, tooltip="First profit target as a multiple of risk. 1R = risk/reward 1:1.")
r2Mult      = input.float(2.0, title="Target 2 (R)", step=0.5, minval=0.5, group=grp_targets, tooltip="Second profit target. 2R = twice your risk distance.")
r3Mult      = input.float(3.0, title="Target 3 (R)", step=0.5, minval=0.5, group=grp_targets, tooltip="Third profit target. 3R = three times your risk distance.")

grp_lines = "Chart Lines"
showLines    = input.bool(true, title="Show Entry/Stop/Target Lines", group=grp_lines, tooltip="Draw horizontal lines on the chart for entry, stop loss, and R-multiple targets.")
entryColor   = input.color(color.new(#2962FF, 0), title="Entry Line Color", group=grp_lines, tooltip="Color for the entry price line.")
stopColor    = input.color(color.new(#F23645, 0), title="Stop Line Color", group=grp_lines, tooltip="Color for the stop loss line.")
targetColor  = input.color(color.new(#089981, 0), title="Target Line Color", group=grp_lines, tooltip="Color for the R-multiple target lines.")
lineExtBars  = input.int(20, title="Line Length (bars forward)", minval=5, group=grp_lines, tooltip="How many bars forward the lines extend from the current bar.")

grp_display = "Display Settings"
tablePos     = input.string("bottom_right", title="Table Position", options=["top_left", "top_center", "top_right", "bottom_left", "bottom_center", "bottom_right"], group=grp_display, tooltip="Where to place the position size table on the chart.")
bottomOffset = input.int(4, title="Push Up From Bottom (Lines)", minval=0, group=grp_display, tooltip="Adds empty lines below the table to push it up from the bottom edge of the chart.")
bgColor      = input.color(color.new(#03243e, 90), title="Table Background Color", group=grp_display, tooltip="Background color for the position size table cells.")
textColor    = input.color(color.new(#d1d4dc, 0), title="Table Text Color", group=grp_display, tooltip="Text color for all labels and values in the position size table.")
headerColor  = input.color(color.new(#8B949E, 0), title="Header Text Color", group=grp_display, tooltip="Text color for section headers in the table.")
warnColor    = input.color(color.new(#FF9800, 0), title="Warning Text Color", group=grp_display, tooltip="Text color used when position size is capped or a warning condition is active.")

// ─────────────────────────────────────────────────────────────────────────────────
// 2. CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────────

bool isLong = tradeSide == "Long"
float atrVal = ta.atr(atrLength)

float effectiveStop = stopMode == "ATR" ? (isLong ? entryPrice - atrVal * atrMult : entryPrice + atrVal * atrMult) : stopLossPrice

float riskAmount       = accountBalance * (riskPercent / 100)
float stopLossDistance = math.abs(entryPrice - effectiveStop)
float rawShares        = stopLossDistance > 0 ? riskAmount / stopLossDistance : 0
float rawDollars       = rawShares * entryPrice

float maxCapDollars = accountBalance * (maxCapPct / 100)
bool isCapped       = useCap and rawDollars > maxCapDollars
float finalShares   = isCapped ? maxCapDollars / entryPrice : rawShares
float finalDollars  = finalShares * entryPrice
float finalRiskPct  = stopLossDistance > 0 and entryPrice > 0 ? (finalShares * stopLossDistance) / accountBalance * 100 : 0
float acctPct       = entryPrice > 0 ? finalDollars / accountBalance * 100 : 0

float t1Price = isLong ? entryPrice + stopLossDistance * r1Mult : entryPrice - stopLossDistance * r1Mult
float t2Price = isLong ? entryPrice + stopLossDistance * r2Mult : entryPrice - stopLossDistance * r2Mult
float t3Price = isLong ? entryPrice + stopLossDistance * r3Mult : entryPrice - stopLossDistance * r3Mult

// ─────────────────────────────────────────────────────────────────────────────────
// 3. CHART LINES
// ─────────────────────────────────────────────────────────────────────────────────

var line l_entry = na
var line l_stop  = na
var line l_t1    = na
var line l_t2    = na
var line l_t3    = na
var label lb_entry = na
var label lb_stop  = na
var label lb_t1    = na
var label lb_t2    = na
var label lb_t3    = na

if barstate.islast and showLines and stopLossDistance > 0
    line.delete(l_entry)
    line.delete(l_stop)
    line.delete(l_t1)
    line.delete(l_t2)
    line.delete(l_t3)
    label.delete(lb_entry)
    label.delete(lb_stop)
    label.delete(lb_t1)
    label.delete(lb_t2)
    label.delete(lb_t3)

    int x1 = bar_index
    int x2 = bar_index + lineExtBars

    l_entry := line.new(x1, entryPrice, x2, entryPrice, color=entryColor, style=line.style_solid, width=2)
    lb_entry := label.new(x2, entryPrice, "ENTRY " + str.tostring(entryPrice, "#.##"), style=label.style_label_left, color=color.new(color.white, 100), textcolor=entryColor, size=size.small)

    l_stop := line.new(x1, effectiveStop, x2, effectiveStop, color=stopColor, style=line.style_dashed, width=2)
    string stopLabel = "STOP " + str.tostring(effectiveStop, "#.##") + (stopMode == "ATR" ? " (" + str.tostring(atrMult, "#.#") + "× ATR)" : "")
    lb_stop := label.new(x2, effectiveStop, stopLabel, style=label.style_label_left, color=color.new(color.white, 100), textcolor=stopColor, size=size.small)

    if showTargets
        l_t1 := line.new(x1, t1Price, x2, t1Price, color=targetColor, style=line.style_dotted, width=1)
        lb_t1 := label.new(x2, t1Price, str.tostring(r1Mult, "#.#") + "R " + str.tostring(t1Price, "#.##"), style=label.style_label_left, color=color.new(color.white, 100), textcolor=targetColor, size=size.small)

        l_t2 := line.new(x1, t2Price, x2, t2Price, color=targetColor, style=line.style_dotted, width=1)
        lb_t2 := label.new(x2, t2Price, str.tostring(r2Mult, "#.#") + "R " + str.tostring(t2Price, "#.##"), style=label.style_label_left, color=color.new(color.white, 100), textcolor=targetColor, size=size.small)

        l_t3 := line.new(x1, t3Price, x2, t3Price, color=targetColor, style=line.style_dotted, width=1)
        lb_t3 := label.new(x2, t3Price, str.tostring(r3Mult, "#.#") + "R " + str.tostring(t3Price, "#.##"), style=label.style_label_left, color=color.new(color.white, 100), textcolor=targetColor, size=size.small)

// ─────────────────────────────────────────────────────────────────────────────────
// 4. DISPLAY TABLE
// ─────────────────────────────────────────────────────────────────────────────────

string spacer = "."
if bottomOffset > 0
    for i = 1 to bottomOffset
        spacer += "\n."

int totalRows = 9 + (showTargets ? 4 : 0) + 1
var table sizeTable = table.new(tablePos == "top_left" ? position.top_left : tablePos == "top_center" ? position.top_center : tablePos == "top_right" ? position.top_right : tablePos == "bottom_left" ? position.bottom_left : tablePos == "bottom_center" ? position.bottom_center : position.bottom_right, 2, totalRows, bgcolor=na, border_color=na, border_width=0)

if barstate.islast
    int row = 0

    // Header
    table.cell(sizeTable, 0, row, "── POSITION SIZE ──", text_color=headerColor, bgcolor=bgColor, text_halign=text.align_center)
    table.cell(sizeTable, 1, row, tradeSide, text_color=isLong ? color.new(#089981, 0) : color.new(#F23645, 0), bgcolor=bgColor, text_halign=text.align_center)
    row += 1

    // Risk Amount
    table.cell(sizeTable, 0, row, "Risk Amount:", text_color=textColor, bgcolor=bgColor)
    table.cell(sizeTable, 1, row, "$" + str.tostring(riskAmount, "#.##") + " (" + str.tostring(riskPercent, "#.##") + "%)", text_color=textColor, bgcolor=bgColor)
    row += 1

    // Stop
    string stopModeLabel = stopMode == "ATR" ? "ATR Stop (" + str.tostring(atrMult, "#.#") + "×):" : "Stop Price:"
    table.cell(sizeTable, 0, row, stopModeLabel, text_color=textColor, bgcolor=bgColor)
    table.cell(sizeTable, 1, row, "$" + str.tostring(effectiveStop, "#.##"), text_color=stopColor, bgcolor=bgColor)
    row += 1

    // Stop Distance
    float stopPct = entryPrice > 0 ? stopLossDistance / entryPrice * 100 : 0
    table.cell(sizeTable, 0, row, "Stop Distance:", text_color=textColor, bgcolor=bgColor)
    table.cell(sizeTable, 1, row, "$" + str.tostring(stopLossDistance, "#.##") + " (" + str.tostring(stopPct, "#.##") + "%)", text_color=textColor, bgcolor=bgColor)
    row += 1

    // Shares
    color sharesCol = isCapped ? warnColor : textColor
    table.cell(sizeTable, 0, row, "Shares:", text_color=textColor, bgcolor=bgColor)
    table.cell(sizeTable, 1, row, str.tostring(finalShares, "#.##") + (isCapped ? " (CAPPED)" : ""), text_color=sharesCol, bgcolor=bgColor)
    row += 1

    // Capital Required
    table.cell(sizeTable, 0, row, "Capital Required:", text_color=textColor, bgcolor=bgColor)
    table.cell(sizeTable, 1, row, "$" + str.tostring(finalDollars, "#.##") + " (" + str.tostring(acctPct, "#.#") + "%)", text_color=isCapped ? warnColor : textColor, bgcolor=bgColor)
    row += 1

    // Effective Risk (after cap)
    if isCapped
        table.cell(sizeTable, 0, row, "Effective Risk:", text_color=textColor, bgcolor=bgColor)
        table.cell(sizeTable, 1, row, str.tostring(finalRiskPct, "#.##") + "% (capped from " + str.tostring(riskPercent, "#.##") + "%)", text_color=warnColor, bgcolor=bgColor)
        row += 1
    else
        table.cell(sizeTable, 0, row, "", text_color=textColor, bgcolor=na)
        table.cell(sizeTable, 1, row, "", text_color=textColor, bgcolor=na)
        row += 1

    // ATR value
    if stopMode == "ATR"
        table.cell(sizeTable, 0, row, "ATR (" + str.tostring(atrLength) + "):", text_color=textColor, bgcolor=bgColor)
        table.cell(sizeTable, 1, row, "$" + str.tostring(atrVal, "#.##"), text_color=textColor, bgcolor=bgColor)
    else
        table.cell(sizeTable, 0, row, "", text_color=textColor, bgcolor=na)
        table.cell(sizeTable, 1, row, "", text_color=textColor, bgcolor=na)
    row += 1

    // Max Cap
    table.cell(sizeTable, 0, row, "Max Cap:", text_color=textColor, bgcolor=bgColor)
    table.cell(sizeTable, 1, row, useCap ? str.tostring(maxCapPct, "#") + "% ($" + str.tostring(maxCapDollars, "#.##") + ")" : "OFF", text_color=useCap ? textColor : color.new(#4A5568, 0), bgcolor=bgColor)
    row += 1

    // R-Targets
    if showTargets
        table.cell(sizeTable, 0, row, "── TARGETS ──", text_color=headerColor, bgcolor=bgColor, text_halign=text.align_center)
        table.cell(sizeTable, 1, row, "", text_color=headerColor, bgcolor=bgColor)
        row += 1

        float t1Profit = finalShares * stopLossDistance * r1Mult
        table.cell(sizeTable, 0, row, str.tostring(r1Mult, "#.#") + "R Target:", text_color=textColor, bgcolor=bgColor)
        table.cell(sizeTable, 1, row, "$" + str.tostring(t1Price, "#.##") + " (+$" + str.tostring(t1Profit, "#.##") + ")", text_color=targetColor, bgcolor=bgColor)
        row += 1

        float t2Profit = finalShares * stopLossDistance * r2Mult
        table.cell(sizeTable, 0, row, str.tostring(r2Mult, "#.#") + "R Target:", text_color=textColor, bgcolor=bgColor)
        table.cell(sizeTable, 1, row, "$" + str.tostring(t2Price, "#.##") + " (+$" + str.tostring(t2Profit, "#.##") + ")", text_color=targetColor, bgcolor=bgColor)
        row += 1

        float t3Profit = finalShares * stopLossDistance * r3Mult
        table.cell(sizeTable, 0, row, str.tostring(r3Mult, "#.#") + "R Target:", text_color=textColor, bgcolor=bgColor)
        table.cell(sizeTable, 1, row, "$" + str.tostring(t3Price, "#.##") + " (+$" + str.tostring(t3Profit, "#.##") + ")", text_color=targetColor, bgcolor=bgColor)
        row += 1

    // Spacer
    color transparentColor = color.new(color.white, 100)
    table.cell(sizeTable, 0, row, spacer, text_color=transparentColor, bgcolor=na)
    table.cell(sizeTable, 1, row, spacer, text_color=transparentColor, bgcolor=na)
````
