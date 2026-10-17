# Position Size Calculator

- url: https://www.tradingview.com/script/9l4udLqn-Position-Size-Calculator/
- type: indicator
- pine_id: PUB;f08c453336d34449a16a2724521805b8
- version: 1.0

## Description

On chart position size calculator based on dollar risk. Input how much you are willing to risk on a trade and drag the start stop points and it will give you a position size based on you risk amount. helps with consistent trading.

## Source Code

````pine
//@version=5
indicator("Position Size Calculator", overlay=true)

// === Risk inputs ===
dollarRisk = input.float(500, "Dollar Risk ($)", minval=0, step=50, group="Risk")
pvOverride = input.float(0, "Point Value Override", minval=0, group="Risk",
     tooltip="0 = use symbol's native point value (auto-detects MNQ=$2, NQ=$20, MES=$5, ES=$50)")

// === Draggable points ===
tA = input.time(0,  "Point A", inline="a", confirm=true)
pA = input.price(0, "",        inline="a", confirm=true)
tB = input.time(0,  "Point B", inline="b", confirm=true)
pB = input.price(0, "",        inline="b", confirm=true)

// === Calculations ===
pointValue      = pvOverride > 0 ? pvOverride : syminfo.pointvalue
dist            = math.abs(pA - pB)
distTicks       = dist / syminfo.mintick
riskPerContract = dist * pointValue
contracts       = riskPerContract > 0 ? math.round(dollarRisk / riskPerContract) : 0
actualRisk      = contracts * riskPerContract
riskDelta       = actualRisk - dollarRisk

// === Drawing ===
var line  ln      = na
var box   riskBox = na
var label infoLbl = na

if barstate.islast
    line.delete(ln)
    box.delete(riskBox)
    label.delete(infoLbl)

    ln := line.new(tA, pA, tB, pB, xloc=xloc.bar_time,
         color=color.yellow, width=2)
    riskBox := box.new(tA, pA, tB, pB, xloc=xloc.bar_time,
         bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 60))

    deltaSign = riskDelta >= 0 ? "+" : ""
    txt = str.format("Contracts: {0}\nDistance: {1,number,#.##} pts / {2,number,#} ticks\nRisk/contract: ${3,number,#.##}\nActual risk: ${4,number,#.##} ({5}${6,number,#.##} vs target)\nPoint value: ${7,number,#.##}",
         contracts, dist, distTicks, riskPerContract, actualRisk, deltaSign, riskDelta, pointValue)

    infoLbl := label.new(tB, pB, txt, xloc=xloc.bar_time,
         style=label.style_label_left,
         color=color.new(color.black, 10),
         textcolor=color.white,
         size=size.normal)
````
