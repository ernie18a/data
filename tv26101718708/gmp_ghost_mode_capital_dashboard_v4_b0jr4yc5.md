# GMP Ghost Mode Capital Dashboard v4

- url: https://www.tradingview.com/script/b0jr4YC5-GMP-Ghost-Mode-Capital-Dashboard-v4/
- type: indicator
- pine_id: PUB;af1ca2343b5d4d16a6415168029d315b
- version: 1.0

## Description

A volatility-based futures positioning dashboard
designed around low leverage survival mechanics,
defense scaling, liquidation awareness,
and Ghost Mode capital deployment.

## Source Code

````pine
//@version=6
indicator("GMP Ghost Mode Capital Dashboard v4", overlay=true, max_labels_count=50)

// === INPUTS ===
totalCapital = input.float(1000, "Total Capital", minval=1)
deployedPct  = input.float(25, "Capital Deployed %", minval=1, maxval=100)
entryPrice   = input.float(60, "Entry Price")
leverage     = input.float(1.0, "Leverage", minval=1)
liqPrice     = input.float(31.90, "Actual Exchange Liquidation Price")

target1Pct   = input.float(10, "Target 1 % Above Entry")
target2Pct   = input.float(20, "Target 2 % Above Entry")

defense1Pct  = input.float(10, "Defense Add 1 % Below Entry")
defense2Pct  = input.float(15, "Defense Add 2 % Below Entry")
defense3Pct  = input.float(20, "Defense Add 3 % Below Entry")

// === CAPITAL MATH ===
capitalUsed   = totalCapital * (deployedPct / 100)
positionValue = capitalUsed * leverage
solAmount     = positionValue / entryPrice
dryPowder     = totalCapital - capitalUsed

// === LEVELS ===
target1  = entryPrice * (1 + target1Pct / 100)
target2  = entryPrice * (1 + target2Pct / 100)

defense1 = entryPrice * (1 - defense1Pct / 100)
defense2 = entryPrice * (1 - defense2Pct / 100)
defense3 = entryPrice * (1 - defense3Pct / 100)

liqDistancePct = ((close - liqPrice) / close) * 100

// === RISK STATE ===
riskText = close <= liqPrice ? "LIQ DANGER" :
     close <= defense3 ? "DANGER" :
     close <= defense2 ? "DEFENSE" :
     close <= defense1 ? "CAUTION" :
     "SAFE"

riskColor = close <= liqPrice ? color.red :
     close <= defense3 ? color.red :
     close <= defense2 ? color.orange :
     close <= defense1 ? color.yellow :
     color.green

// === PLOTS ===
plot(entryPrice, "ENTRY", color=color.white, linewidth=2)
plot(target1, "TARGET 1", color=color.aqua, linewidth=2)
plot(target2, "TARGET 2", color=color.blue, linewidth=2)
plot(defense1, "DEFENSE 1", color=color.lime, linewidth=2)
plot(defense2, "DEFENSE 2", color=color.yellow, linewidth=2)
plot(defense3, "DEFENSE 3", color=color.orange, linewidth=2)
plot(liqPrice, "EXCHANGE LIQ.", color=color.red, linewidth=3)

// === BACKGROUND ZONES ===
bgcolor(close >= entryPrice ? color.new(color.green, 92) : na)
bgcolor(close <= defense1 and close > defense2 ? color.new(color.yellow, 88) : na)
bgcolor(close <= defense2 and close > defense3 ? color.new(color.orange, 86) : na)
bgcolor(close <= defense3 ? color.new(color.red, 84) : na)

// === PRICE LABEL STORAGE ===
var label lEntry = na
var label lT1 = na
var label lT2 = na
var label lD1 = na
var label lD2 = na
var label lD3 = na
var label lLiq = na

// === PRICE LABELS ===
if barstate.islast
    label.delete(lEntry)
    label.delete(lT1)
    label.delete(lT2)
    label.delete(lD1)
    label.delete(lD2)
    label.delete(lD3)
    label.delete(lLiq)

    lEntry := label.new(bar_index, entryPrice, "👻 PHANTOM LONG\n$" + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=color.white, textcolor=color.black)

    lT1 := label.new(bar_index, target1, "🌊 VOLATILITY HARVEST\n$" + str.tostring(target1, format.mintick), style=label.style_label_left, color=color.aqua, textcolor=color.black)

    lT2 := label.new(bar_index, target2, "🚀 GHOST EXIT\n$" + str.tostring(target2, format.mintick), style=label.style_label_left, color=color.blue, textcolor=color.white)

    lD1 := label.new(bar_index, defense1, "🛡️ SHADOW ADD\n$" + str.tostring(defense1, format.mintick), style=label.style_label_left, color=color.lime, textcolor=color.black)

    lD2 := label.new(bar_index, defense2, "⚔️ HEDGE WATCH\n$" + str.tostring(defense2, format.mintick), style=label.style_label_left, color=color.yellow, textcolor=color.black)

    lD3 := label.new(bar_index, defense3, "🔥 PANIC FLOOR\n$" + str.tostring(defense3, format.mintick), style=label.style_label_left, color=color.orange, textcolor=color.black)

    lLiq := label.new(bar_index, liqPrice, "☠️ DEATH LINE\n$" + str.tostring(liqPrice, format.mintick), style=label.style_label_left, color=color.red, textcolor=color.white)

// === DASHBOARD TABLE ===
var table dashboard = table.new(position.top_right, 2, 8, bgcolor=color.black, frame_color=color.white, frame_width=1)

if barstate.islast
    table.cell(dashboard, 0, 0, "GMP GHOST MODE", text_color=color.white, bgcolor=color.black)
    table.cell(dashboard, 1, 0, riskText, text_color=color.white, bgcolor=riskColor)

    table.cell(dashboard, 0, 1, "Capital Used", text_color=color.white)
    table.cell(dashboard, 1, 1, "$" + str.tostring(capitalUsed, format.mintick), text_color=color.white)

    table.cell(dashboard, 0, 2, "Position Size", text_color=color.white)
    table.cell(dashboard, 1, 2, "$" + str.tostring(positionValue, format.mintick), text_color=color.white)

    table.cell(dashboard, 0, 3, "SOL Size", text_color=color.white)
    table.cell(dashboard, 1, 3, str.tostring(solAmount, format.mintick), text_color=color.white)

    table.cell(dashboard, 0, 4, "Dry Powder", text_color=color.white)
    table.cell(dashboard, 1, 4, "$" + str.tostring(dryPowder, format.mintick), text_color=color.white)

    table.cell(dashboard, 0, 5, "Liq Price", text_color=color.white)
    table.cell(dashboard, 1, 5, "$" + str.tostring(liqPrice, format.mintick), text_color=color.white)

    table.cell(dashboard, 0, 6, "Liq Distance", text_color=color.white)
    table.cell(dashboard, 1, 6, str.tostring(liqDistancePct, "#.##") + "%", text_color=color.white)

    table.cell(dashboard, 0, 7, "Leverage", text_color=color.white)
    table.cell(dashboard, 1, 7, str.tostring(leverage) + "x", text_color=color.white)

// === ALERTS ===
alertcondition(close <= defense1, "Defense 1 Hit", "Price entered Defense 1 zone")
alertcondition(close <= defense2, "Defense 2 Hit", "Price entered Defense 2 zone")
alertcondition(close <= defense3, "Defense 3 Hit", "Price entered Defense 3 zone")
alertcondition(close <= liqPrice, "Exchange Liquidation Danger", "Price is at or below your exchange liquidation price")
alertcondition(close >= target1, "Target 1 Hit", "Price reached Target 1")
alertcondition(close >= target2, "Target 2 Hit", "Price reached Target 2")
````
