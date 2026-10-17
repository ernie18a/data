# Market Breadth Composite

- url: https://www.tradingview.com/script/IwPgufji-Market-Breadth-Composite/
- type: indicator
- pine_id: PUB;ce7395824e2f41f3a0d9acd6ae7d221f
- version: 1.0

## Description

## Market Breadth Composite

Market Breadth Composite is a market breadth indicator designed to measure the internal health of the broader U.S. equity market.

The indicator tracks the percentage of stocks trading above their 200-day moving average across three breadth universes:

1. S&P 500 breadth
2. NYSE breadth
3. Nasdaq breadth

It then calculates a composite average from the enabled and available feeds. This helps users view broad market participation through one cleaner composite reading instead of relying on a single market index.

This script is not a standalone buy or sell signal. It is intended to be used as a market regime and risk-environment filter.

---

## How It Works

The script requests breadth data from the selected symbols and calculates the current value for each enabled universe.

The default feeds are:

* S5TH: S&P 500 percentage of stocks above the 200-day moving average
* MMTH: NYSE percentage of stocks above the 200-day moving average
* NDTH: Nasdaq percentage of stocks above the 200-day moving average

The composite value is calculated by averaging the active and available feeds.

If one of the selected feeds is unavailable, the script continues to calculate the composite using the remaining available feeds.

An optional EMA smoothing setting is included to reduce short-term noise in the composite line.

---

## Market Regime Logic

The indicator uses configurable regime levels:

* Risk-Off Level: default 40
* Healthy Level: default 60
* Strong Level: default 80

The current market state is classified as follows:

* Risk-Off: composite is below the Risk-Off Level
* Neutral: composite is between the Risk-Off Level and the Healthy Level
* Healthy: composite is above the Healthy Level but below the Strong Level
* Strong: composite is above the Strong Level

These levels are not trading guarantees. They are reference zones designed to help users evaluate broad market participation.

---

## Visual Output

The script displays:

* A composite breadth line
* Optional component lines for S&P 500, NYSE, and Nasdaq breadth
* Configurable regime reference levels
* Optional risk-regime background shading
* A status table showing the component values, composite value, market state, and active feed count

The table is designed to provide a quick summary of market conditions while keeping the chart clean and easy to read.

---

## How To Use

This indicator is best used as a market environment filter.

Users may use it to understand whether broad market participation is weak, mixed, improving, or strong.

General interpretation:

* Below 40: breadth is weak and market risk may be elevated
* Between 40 and 60: breadth is mixed or neutral
* Above 60: breadth participation is healthier
* Above 80: breadth participation is broadly strong

The indicator should be interpreted together with price action, trend structure, support and resistance, volume, and risk management.

It is not designed to replace a complete trading plan.

---

## Alerts

The script includes the following alert conditions:

1. Composite Breadth -> Risk-Off
   Triggered when the composite crosses below the Risk-Off Level.

2. Composite Breadth -> Recovery Above Risk-Off
   Triggered when the composite crosses back above the Risk-Off Level.

3. Composite Breadth -> Healthy
   Triggered when the composite crosses above the Healthy Level.

4. Composite Breadth -> Strong
   Triggered when the composite crosses above the Strong Level.

5. Composite Breadth -> Back To Neutral
   Triggered when the composite crosses below the Healthy Level after being in a healthier breadth zone.

6. Composite Breadth -> Lost Strong Status
   Triggered when the composite crosses below the Strong Level after being in the Strong zone.

These alerts are intended to help users monitor changes in broad market breadth conditions without treating them as direct trade signals.

---

## Important Notes

This script does not predict future market direction.

It does not guarantee entries, exits, tops, bottoms, crashes, recessions, or recoveries.

It does not provide financial advice.

It is an analytical tool for studying market breadth and market regime.

Users are responsible for their own analysis, decisions, and risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6

indicator("Market Breadth Composite", shorttitle="Breadth Composite", overlay=false, precision=1)

// =====================================================================
// Market Breadth Composite
//
// Measures broad market health using the percentage of stocks trading
// above their 200-day moving average across three market universes:
//
//   S5TH = S&P 500 % above 200DMA
//   MMTH = NYSE % above 200DMA
//   NDTH = Nasdaq % above 200DMA
//
// The composite is the average of the enabled and available feeds.
// This is a market regime / risk filter, not a direct buy or sell signal.
// =====================================================================


// ---------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------

sym1 = input.symbol("S5TH", "Universe 1 - S&P 500 % Above 200DMA", group="Breadth Feeds")
sym2 = input.symbol("MMTH", "Universe 2 - NYSE % Above 200DMA", group="Breadth Feeds")
sym3 = input.symbol("NDTH", "Universe 3 - Nasdaq % Above 200DMA", group="Breadth Feeds")

use1 = input.bool(true, "Use S&P 500", group="Breadth Feeds")
use2 = input.bool(true, "Use NYSE", group="Breadth Feeds")
use3 = input.bool(true, "Use Nasdaq", group="Breadth Feeds")

riskOffLevel = input.float(40.0, "Risk-Off Level", minval=0, maxval=100, step=0.5, group="Regime Levels")
healthyLevel = input.float(60.0, "Healthy Level", minval=0, maxval=100, step=0.5, group="Regime Levels")
strongLevel  = input.float(80.0, "Strong Level", minval=0, maxval=100, step=0.5, group="Regime Levels")

smoothLength = input.int(3, "Composite Smoothing EMA", minval=1, group="Logic")

showComposite  = input.bool(true, "Show Composite Line", group="Display")
showComponents = input.bool(false, "Show Component Lines", group="Display")

showRiskOffLine = input.bool(true, "Show Risk-Off Level", group="Display Levels")
showHealthyLine = input.bool(true, "Show Healthy Level", group="Display Levels")
showStrongLine  = input.bool(false, "Show Strong Level", group="Display Levels")
showMidLine     = input.bool(false, "Show Neutral 50 Line", group="Display Levels")
showExtraZones  = input.bool(false, "Show 20 / 80 Reference Lines", group="Display Levels")

levelLineWidth = input.int(2, "Level Line Width", minval=1, maxval=4, group="Display Levels")
compositeWidth = input.int(4, "Composite Line Width", minval=2, maxval=6, group="Display")

backgroundMode = input.string("Risk-Off Only", "Background Mode", options=["Off", "Risk-Off Only", "All Regimes"], group="Display")

showTable = input.bool(true, "Show Status Table", group="Table")
tableSizeInput = input.string("Small", "Table Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Table")

// Clean white table defaults
tableRowBgColor    = input.color(color.rgb(255, 255, 255), "Table Row Background", group="Table")
tableHeaderBgColor = input.color(color.rgb(255, 255, 255), "Table Summary Background", group="Table")
tableTextColor     = input.color(color.rgb(45, 45, 45), "Table Text Color", group="Table")
tableFrameColor    = input.color(color.rgb(210, 198, 176), "Table Frame Color", group="Table")
tableBorderColor   = input.color(color.rgb(226, 216, 198), "Table Border Color", group="Table")


// ---------------------------------------------------------------------
// Functions
// ---------------------------------------------------------------------

f_breadth(simple string symbolName, simple bool enabled) =>
    enabled ? request.security(symbolName, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true) : na

f_table_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small

f_state_text(float value) =>
    na(value) ? "NO DATA" : value < riskOffLevel ? "RISK-OFF" : value < healthyLevel ? "NEUTRAL" : value < strongLevel ? "HEALTHY" : "STRONG"

f_state_color(float value) =>
    na(value) ? color.gray : value < riskOffLevel ? color.red : value < healthyLevel ? color.orange : value < strongLevel ? color.teal : color.green

f_line_color(float value) =>
    na(value) ? color.new(color.gray, 100) :
     value < riskOffLevel ? color.new(color.red, 0) :
     value < healthyLevel ? color.new(color.orange, 0) :
     value < strongLevel ? color.new(color.teal, 0) :
     color.new(color.green, 0)

f_bg_color(float value) =>
    na(value) ? na :
     backgroundMode == "Off" ? na :
     backgroundMode == "Risk-Off Only" ? (value < riskOffLevel ? color.new(color.red, 88) : na) :
     value < riskOffLevel ? color.new(color.red, 88) :
     value < healthyLevel ? color.new(color.orange, 95) :
     value < strongLevel ? color.new(color.teal, 96) :
     color.new(color.green, 96)

f_format_value(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + "%"

f_cell(table t, int row, string name, float value, bool enabled, txtSize) =>
    txt = not enabled ? "off" : f_format_value(value)
    valColor = not enabled or na(value) ? color.gray : f_state_color(value)
    table.cell(t, 0, row, name, bgcolor=tableRowBgColor, text_color=tableTextColor, text_size=txtSize, text_halign=text.align_left)
    table.cell(t, 1, row, txt, bgcolor=tableRowBgColor, text_color=valColor, text_size=txtSize, text_halign=text.align_right)


// ---------------------------------------------------------------------
// Breadth Data
// ---------------------------------------------------------------------

b1 = f_breadth(sym1, use1)
b2 = f_breadth(sym2, use2)
b3 = f_breadth(sym3, use3)

sumBreadth = nz(b1) + nz(b2) + nz(b3)
countBreadth = (na(b1) ? 0 : 1) + (na(b2) ? 0 : 1) + (na(b3) ? 0 : 1)

compositeRaw = countBreadth > 0 ? sumBreadth / countBreadth : na
composite = smoothLength > 1 ? ta.ema(compositeRaw, smoothLength) : compositeRaw


// ---------------------------------------------------------------------
// Regime Conditions
// ---------------------------------------------------------------------

riskOff = not na(composite) and composite < riskOffLevel
neutral = not na(composite) and composite >= riskOffLevel and composite < healthyLevel
healthy = not na(composite) and composite >= healthyLevel and composite < strongLevel
strong = not na(composite) and composite >= strongLevel

stateText = f_state_text(composite)
stateColor = f_state_color(composite)


// ---------------------------------------------------------------------
// Plots
// ---------------------------------------------------------------------

plot(showComponents ? b1 : na, "S&P 500", color=color.new(color.blue, 72), linewidth=1)
plot(showComponents ? b2 : na, "NYSE", color=color.new(color.orange, 74), linewidth=1)
plot(showComponents ? b3 : na, "Nasdaq", color=color.new(color.fuchsia, 74), linewidth=1)

plot(showComposite ? composite : na, "Composite %", color=f_line_color(composite), linewidth=compositeWidth)

// Important levels
plot(showRiskOffLine ? riskOffLevel : na, "Risk-Off Level", color=color.new(color.red, 0), linewidth=levelLineWidth, style=plot.style_line)
plot(showHealthyLine ? healthyLevel : na, "Healthy Level", color=color.new(color.teal, 0), linewidth=levelLineWidth, style=plot.style_line)
plot(showStrongLine ? strongLevel : na, "Strong Level", color=color.new(color.green, 0), linewidth=levelLineWidth, style=plot.style_line)

// Optional reference levels
plot(showMidLine ? 50 : na, "Neutral 50 Line", color=color.new(color.gray, 25), linewidth=1, style=plot.style_line)
plot(showExtraZones ? 20 : na, "Washed-Out 20 Line", color=color.new(color.gray, 50), linewidth=1, style=plot.style_line)
plot(showExtraZones ? 80 : na, "Strong 80 Line", color=color.new(color.gray, 50), linewidth=1, style=plot.style_line)

bgcolor(f_bg_color(composite), title="Regime Background")


// ---------------------------------------------------------------------
// Table
// ---------------------------------------------------------------------

txtSize = f_table_size(tableSizeInput)

var table tbl = table.new(position.bottom_right, 2, 6, frame_color=tableFrameColor, frame_width=1, border_color=tableBorderColor, border_width=1)

if barstate.islast
    table.clear(tbl, 0, 0, 1, 5)

if showTable and barstate.islast
    f_cell(tbl, 0, "S&P 500", b1, use1, txtSize)
    f_cell(tbl, 1, "NYSE", b2, use2, txtSize)
    f_cell(tbl, 2, "Nasdaq", b3, use3, txtSize)

    table.cell(tbl, 0, 3, "COMPOSITE", bgcolor=tableHeaderBgColor, text_color=tableTextColor, text_size=txtSize, text_halign=text.align_left)
    table.cell(tbl, 1, 3, f_format_value(composite), bgcolor=tableHeaderBgColor, text_color=stateColor, text_size=txtSize, text_halign=text.align_right)

    table.cell(tbl, 0, 4, "STATE", bgcolor=tableHeaderBgColor, text_color=tableTextColor, text_size=txtSize, text_halign=text.align_left)
    table.cell(tbl, 1, 4, stateText, bgcolor=tableHeaderBgColor, text_color=stateColor, text_size=txtSize, text_halign=text.align_right)

    table.cell(tbl, 0, 5, "ACTIVE FEEDS", bgcolor=tableHeaderBgColor, text_color=tableTextColor, text_size=txtSize, text_halign=text.align_left)
    table.cell(tbl, 1, 5, str.tostring(countBreadth), bgcolor=tableHeaderBgColor, text_color=countBreadth > 0 ? color.teal : color.red, text_size=txtSize, text_halign=text.align_right)


// ---------------------------------------------------------------------
// Alerts
// ---------------------------------------------------------------------

alertcondition(ta.crossunder(composite, riskOffLevel), "Composite Breadth -> Risk-Off", "Market Breadth Composite dropped below the Risk-Off level.")
alertcondition(ta.crossover(composite, riskOffLevel), "Composite Breadth -> Recovery Above Risk-Off", "Market Breadth Composite recovered above the Risk-Off level.")
alertcondition(ta.crossover(composite, healthyLevel), "Composite Breadth -> Healthy", "Market Breadth Composite moved into the Healthy zone.")
alertcondition(ta.crossover(composite, strongLevel), "Composite Breadth -> Strong", "Market Breadth Composite moved into the Strong breadth zone.")
alertcondition(ta.crossunder(composite, healthyLevel), "Composite Breadth -> Back To Neutral", "Market Breadth Composite dropped from Healthy back into Neutral.")
alertcondition(ta.crossunder(composite, strongLevel), "Composite Breadth -> Lost Strong Status", "Market Breadth Composite dropped below the Strong breadth level.")
````
