# Risk Manager + ADR by artem4pf

- url: https://www.tradingview.com/script/gHgVcwJQ-Risk-Manager-ADR-by-artem4pf/
- type: indicator
- pine_id: PUB;7908dc1ed2144226ae436768dd83ad21
- version: 1.0

## Description

Calculate your risk, total cost, auto low of day stop loss and adr

## Source Code

````pine
//@version=5
indicator("Risk Manager", overlay=true)

// ===== INPUTS =====
accountSize = input.float(10000, "Account Size ($)")
riskPercent = input.float(1.0, "Risk % per Trade", step=0.1)
useFixedRisk = input.bool(false, "Use Fixed Risk")
fixedRisk = input.float(100, "Fixed Risk ($)")
adrLength = input.int(20, "ADR Length")

// ===== REGULAR SESSION =====
rth = not na(time(timeframe.period, "0930-1600"))
newSession = rth and not rth[1]

// ===== LOW OF DAY (REGULAR HOURS ONLY) =====
entryPrice = close
var float lowOfDay = na

if newSession
    lowOfDay := low
else if rth
    lowOfDay := math.min(lowOfDay, low)

// ===== RISK CALC =====
riskAmount = useFixedRisk ? fixedRisk : accountSize * riskPercent / 100
riskPerShare = entryPrice - lowOfDay
sharesRaw = riskPerShare > 0 ? riskAmount / riskPerShare : 0
shares = math.round(sharesRaw * 100) / 100
totalCost = shares * entryPrice

// ===== ADR CALC =====
dHigh = request.security(syminfo.tickerid, "D", high)
dLow  = request.security(syminfo.tickerid, "D", low)
adrPercent = 100 * (ta.sma(dHigh / dLow, adrLength) - 1)

// ===== TABLE (top right) =====
var table infoTable = table.new(position.top_right, 1, 5, bgcolor=color.black, border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "Risk $: " + str.tostring(riskAmount, "#.##"), text_color=color.white, text_size=size.normal)
    table.cell(infoTable, 0, 1, "Stop: " + str.tostring(lowOfDay, "#.##"), text_color=color.white, text_size=size.normal)
    table.cell(infoTable, 0, 2, "Shares: " + str.tostring(shares, "#.##"), text_color=color.white, text_size=size.normal)
    table.cell(infoTable, 0, 3, "Total Cost: $" + str.tostring(totalCost, "#.##"), text_color=color.green, text_size=size.normal)
    table.cell(infoTable, 0, 4, "ADR%: " + str.tostring(adrPercent, "#.##") + "%", text_color=color.orange, text_size=size.normal)
````
