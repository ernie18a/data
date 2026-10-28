# Execution Discipline 

- url: https://www.tradingview.com/script/jGqB9LOH-Execution-Discipline/
- type: indicator
- pine_id: PUB;e1cab863ffe94840887f629ae621559f
- version: 1.0

## Description

EXECUTION DISCIPLINE – HOW TO USE (Jeff Sun Inspired)

This indicator is a real-time execution filter, not a buy/sell signal system. It is designed to help you decide when NOT to trade and when conditions are aligned for high-quality setups.

The table shows three columns:
RULE – the condition being checked
VALUE – the live market value of that condition
STATUS – whether the rule is satisfied (OK) or violated (NO)

The FINAL row is the most important:
If FINAL = VALID → all conditions are satisfied and trading is allowed
If FINAL = NO TRADE → even one rule is broken and you should not enter a trade

RULES EXPLAINED:

LoD Distance (Low of Day risk)
Measures how far price is from the intraday low in ATR terms.
Prevents buying weak or unstable price action.
Rule: must be within 0.6 ATR from Low of Day.
Distance from 50 Moving Average
Prevents chasing extended moves.
Rule: price must be within 4 ATR of the 50 MA.
RVOL (Relative Volume)
Measures institutional participation.
Higher RVOL = stronger conviction and breakout strength.
Rule: must be above the set threshold (default 1.5).
200 MA Trend Filter
Ensures trades are taken only in supportive higher timeframe trend.
Rule: 200 MA must be flat or rising.
Time Filter
Avoids early market noise and unstable opening volatility.
Rule: no trades in first 30 minutes after market open.

HOW TO USE IT:

Step 1: Scan your watchlist during the trading session
Step 2: Wait for FINAL = VALID
Step 3: Only consider entries when all rules are OK
Step 4: If any rule is NO, skip the trade completely

IMPORTANT:
This indicator does not predict direction. It only enforces discipline and filters low-quality trades. It is meant to improve consistency, not increase trade frequency.

CORE PRINCIPLE:
If it is not VALID, it is not a trade.

## Source Code

````pine
//@version=6
indicator("Execution Discipline - Fully Custom Table", overlay=true)

// === INPUTS ===
atrLength   = input.int(14, "ATR Length")
rvolLength  = input.int(20, "RVOL Length")
rvolThreshold = input.float(1.5, "Min RVOL")
sessionHour = input.int(8, "Session Start Hour")

// === FONT COLOURS (NEW) ===
ruleColor   = input.color(color.white, "Rule Font Color")
valueColor  = input.color(color.silver, "Value Font Color")
statusOK    = input.color(color.green, "OK Color")
statusNO    = input.color(color.red, "NO Color")
finalOK     = input.color(color.lime, "Final OK Color")
finalNO     = input.color(color.red, "Final NO Color")

// Table position
tablePosInput = input.string("Top Right", "Table Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"])

tablePos = tablePosInput == "Top Right" ? position.top_right :
           tablePosInput == "Top Left" ? position.top_left :
           tablePosInput == "Bottom Right" ? position.bottom_right :
           position.bottom_left

// === DAILY RESET ===
isNewDay = ta.change(time("D")) != 0

var float lod = na
lod := isNewDay ? low : math.min(nz(lod, low), low)

// === CALCULATIONS ===
atr = ta.atr(atrLength)
lodDist = (close - lod) / atr

ma50 = ta.sma(close, 50)
ma200 = ta.sma(close, 200)

dist50 = math.abs(close - ma50) / atr

volMA = ta.sma(volume, rvolLength)
rvol = volume / nz(volMA)

// Time filter
sessionStart = timestamp(syminfo.timezone, year, month, dayofmonth, sessionHour, 0)
noTradeTime = time < sessionStart + 30 * 60 * 1000

// === RULES ===
rule_lod   = lodDist <= 0.6
rule_ma50  = dist50 <= 4
rule_rvol  = rvol >= rvolThreshold
rule_ma200 = ma200 >= ma200[1]
rule_time  = not noTradeTime

validSetup = rule_lod and rule_ma50 and rule_rvol and rule_ma200 and rule_time

// === FORMAT ===
f_fmt(x) => str.tostring(x, "#.##")

f_status(cond) =>
    cond ? "OK" : "NO"

f_statusColor(cond) =>
    cond ? statusOK : statusNO

// === TABLE ===
var table t = table.new(tablePos, 3, 7, border_width=1)

if barstate.islast

    // HEADER
    table.cell(t, 0, 0, "RULE", text_color=ruleColor, bgcolor=color.black)
    table.cell(t, 1, 0, "VALUE", text_color=valueColor, bgcolor=color.black)
    table.cell(t, 2, 0, "STATUS", text_color=color.white, bgcolor=color.black)

    // LoD
    table.cell(t, 0, 1, "LoD Dist", text_color=ruleColor)
    table.cell(t, 1, 1, f_fmt(lodDist), text_color=valueColor)
    table.cell(t, 2, 1, f_status(rule_lod), text_color=f_statusColor(rule_lod))

    // MA50
    table.cell(t, 0, 2, "Dist 50MA", text_color=ruleColor)
    table.cell(t, 1, 2, f_fmt(dist50), text_color=valueColor)
    table.cell(t, 2, 2, f_status(rule_ma50), text_color=f_statusColor(rule_ma50))

    // RVOL
    table.cell(t, 0, 3, "RVOL", text_color=ruleColor)
    table.cell(t, 1, 3, f_fmt(rvol), text_color=valueColor)
    table.cell(t, 2, 3, f_status(rule_rvol), text_color=f_statusColor(rule_rvol))

    // MA200
    table.cell(t, 0, 4, "200MA Trend", text_color=ruleColor)
    table.cell(t, 1, 4, ma200 >= ma200[1] ? "UP" : "DOWN", text_color=valueColor)
    table.cell(t, 2, 4, f_status(rule_ma200), text_color=f_statusColor(rule_ma200))

    // TIME
    table.cell(t, 0, 5, "Time Filter", text_color=ruleColor)
    table.cell(t, 1, 5, rule_time ? "OK" : "BLOCKED", text_color=valueColor)
    table.cell(t, 2, 5, f_status(rule_time), text_color=f_statusColor(rule_time))

    // FINAL
    table.cell(t, 0, 6, "FINAL", text_color=ruleColor)
    table.cell(t, 1, 6, "")
    table.cell(t, 2, 6,
         validSetup ? "✅ VALID" : "❌ NO TRADE",
         text_color = validSetup ? finalOK : finalNO)

// Background
````
