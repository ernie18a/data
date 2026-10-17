# TP/SL

- url: https://www.tradingview.com/script/CJirSxvw-TP-SL/
- type: indicator
- pine_id: PUB;88fabc1a30384e878cef3cb77413ccb8
- version: 1.0

## Description

Show's take profit and stop loss based on where price is. Allows the user to change the amount of contracts they would enter with and how much money they're risking in order to gauge their entry.

## Source Code

````pine
//@version=5
indicator("TP/SL", overlay=true)

// === Inputs ===
totalDollarRisk = input.float(500.0, title="Total Dollar Risk ($)", minval=0.01)
contracts       = input.int(1, title="Number of Contracts", minval=1)
rewardRR        = input.float(2.0, title="Reward-to-Risk Ratio (e.g. 2 = 2:1)")
isLong          = input.bool(true, title="Long Trade?")

// === Optional Point Value Override ===
overridePoint    = input.bool(false, title="Override Point Value?")
manualPointValue = input.float(1.0, title="Manual Point Value ($)", minval=0.01)

// === Auto-detect Point Value Based on Symbol Root ===
pointValue = switch syminfo.root
    "ES"  => 50.0
    "MES" => 5.0
    "NQ"  => 20.0
    "MNQ" => 2.0
    "GC"  => 100.0
    "MGC" => 10.0
    => 1.0  // fallback

finalPointValue = overridePoint ? manualPointValue : pointValue

// === Risk in Points ===
riskPoints   = totalDollarRisk / (contracts * finalPointValue)
rewardPoints = riskPoints * rewardRR

// === Entry, SL, TP Price Levels ===
entry = close
sl = isLong ? entry - riskPoints : entry + riskPoints
tp = isLong ? entry + rewardPoints : entry - rewardPoints

// === Line Style Inputs ===
showEntry = input.bool(true, "Show Entry Line")
showSL    = input.bool(true, "Show Stop Loss Line")
showTP    = input.bool(true, "Show Take Profit Line")

entryColor = input.color(color.gray, title="Entry Line Color")
slColor    = input.color(color.red, title="Stop Loss Line Color")
tpColor    = input.color(color.green, title="Take Profit Line Color")

entryWidth = input.int(1, minval=1, maxval=4, title="Entry Line Width")
slWidth    = input.int(2, minval=1, maxval=4, title="Stop Loss Line Width")
tpWidth    = input.int(2, minval=1, maxval=4, title="Take Profit Line Width")

// === Label Size Input ===
labelSizeInput = input.string("Small", title="Label Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
labelSize = switch labelSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge

// === Clean Old Lines ===
var line entryLine = na
var line slLine    = na
var line tpLine    = na

if not na(entryLine)
    line.delete(entryLine)
if not na(slLine)
    line.delete(slLine)
if not na(tpLine)
    line.delete(tpLine)

// === Draw Lines ===
extendBars = 100
if showEntry
    entryLine := line.new(bar_index, entry, bar_index + extendBars, entry, extend=extend.right, color=entryColor, width=entryWidth)
if showSL
    slLine := line.new(bar_index, sl, bar_index + extendBars, sl, extend=extend.right, color=slColor, width=slWidth)
if showTP
    tpLine := line.new(bar_index, tp, bar_index + extendBars, tp, extend=extend.right, color=tpColor, width=tpWidth)

// === Clean Old Labels ===
var label entryLabel = na
var label slLabel    = na
var label tpLabel    = na

if not na(entryLabel)
    label.delete(entryLabel)
if not na(slLabel)
    label.delete(slLabel)
if not na(tpLabel)
    label.delete(tpLabel)

// === Create Labels ===
entryLabel := label.new(bar_index, entry, text="Entry\n" + str.tostring(entry, format.mintick), style=label.style_label_left, color=entryColor, textcolor=color.white, size=labelSize)

slText = "Stop Loss\n" + str.tostring(sl, format.mintick) + "\nRisk: $" + str.tostring(totalDollarRisk, "#.##")
slLabel := label.new(bar_index, sl, text=slText, style=label.style_label_left, color=slColor, textcolor=color.white, size=labelSize)

rewardDollars = contracts * rewardPoints * finalPointValue
tpText = "Take Profit\n" + str.tostring(tp, format.mintick) + "\nReward: $" + str.tostring(rewardDollars, "#.##")
tpLabel := label.new(bar_index, tp, text=tpText, style=label.style_label_left, color=tpColor, textcolor=color.white, size=labelSize)
````
