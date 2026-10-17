# Turtles Modified Alerts

- url: https://www.tradingview.com/script/jWyeeqYL-Turtles-Modified-Alerts/
- type: indicator
- pine_id: PUB;LwXyH9IoN2B2GOn5NqsiLQd8eGrBi12s
- version: 4.0

## Description

Alerts for famous Turtle Trading Rules. Based on work from [url=https://www.tradingview.com/script/Q1O23zJP-20-years-old-turtles-strategy-still-work/]tmr0[/url] and [url=https://www.tradingview.com/script/kSralCXQ-Turtles-Modified/]ossettia[/url]. It can be used with Autoview.

If you have any advice on how to further improve the script, please let me know by PM or comment below. Thanks!

Please hit on "Like" if you find this script useful so that others can find it easier. Thanks!

*** The information and script provided here are no recommendation to buy or sell. They are just an idea for educational and discussion purposes. ***

## Source Code

````pine
//@version=4
study("Turtles Alerts v3", shorttitle="Turtles Alerts v3", overlay=true)

// === BACKTEST RANGE ===
FromMonth = input(defval = 1, title = "From Month", minval = 1)
FromDay   = input(defval = 1, title = "From Day", minval = 1)
FromYear  = input(defval = 2019, title = "From Year", minval = 2019)
ToMonth   = input(defval = 1, title = "To Month", minval = 1)
ToDay     = input(defval = 1, title = "To Day", minval = 1)
ToYear    = input(defval = 9999, title = "To Year", minval = 9999)

enter_fast = input(20, minval=1)
exit_fast = input(10, minval=1)
enter_slow = input(55, minval=1)
exit_slow = input(20, minval=1)

fastL = highest(enter_fast)
fastLC = lowest(exit_fast)
fastS = lowest(enter_fast)
fastSC = highest(exit_fast)

slowL = highest(enter_slow)
slowLC = lowest(exit_slow)
slowS = lowest(enter_slow)
slowSC = highest(exit_slow)

enterL1 = high > fastL[1] and (time > timestamp(FromYear, FromMonth, FromDay, 00, 00)) and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59))
exitL1 = low <= fastLC[1] and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59))
enterL1_filt = enterL1 and not exitL1
exitL1_filt = exitL1 and not enterL1
prevL1 = 0
prevL1 := exitL1_filt ? 1 : enterL1_filt ? -1 : prevL1[1]
enterL1_final = enterL1_filt and prevL1[1] == 1
exitL1_final = exitL1_filt and prevL1[1] == -1


enterS1 = low < fastS[1] and (time > timestamp(FromYear, FromMonth, FromDay, 00, 00)) and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59))
exitS1 = high >= fastSC[1] and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59))
enterS1_filt = enterS1 and not exitS1
exitS1_filt = exitS1 and not enterS1
prevS1 = 0
prevS1 := exitS1_filt ? 1 : enterS1_filt ? -1 : prevS1[1]
enterS1_final = enterS1_filt and prevS1[1] == 1
exitS1_final = exitS1_filt and prevS1[1] == -1


enterL2 = high > slowL[1] and (time > timestamp(FromYear, FromMonth, FromDay, 00, 00)) and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59))
exitL2 = low <= slowLC[1] and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59))
enterL2_filt = enterL2 and not exitL2
exitL2_filt = exitL2 and not enterL2
prevL2 = 0
prevL2 := exitL2_filt ? 1 : enterL2_filt ? -1 : prevL2[1]
enterL2_final = enterL2_filt and prevL2[1] == 1
exitL2_final = exitL2_filt and prevL2[1] == -1


enterS2 = low < slowS[1] and (time > timestamp(FromYear, FromMonth, FromDay, 00, 00)) and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59))
exitS2 = high >= slowSC[1] and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59))
enterS2_filt = enterS2 and not exitS2
exitS2_filt = exitS2 and not enterS2
prevS2 = 0
prevS2 := exitS2_filt ? 1 : enterS2_filt ? -1 : prevS2[1]
enterS2_final = enterS2_filt and prevS2[1] == 1
exitS2_final = exitS2_filt and prevS2[1] == -1

//bgcolor(exitL1_final or enterS1_final or exitL2_final or enterS2_final? red: enterL1_final or exitS1_final or enterL2_final or exitS2_final? navy:white)

// Plotting
// fast L
plotshape(enterL1_final, color = #1e90ff, text = "OFL", style=shape.triangleup, location=location.belowbar, size=size.small)
plotshape(exitL1_final, color = #ff69b4, text = "CFL", style=shape.triangledown, location=location.abovebar, size=size.small)

// fast S
plotshape(enterS1_final, color = #ff69b4, text = "OFS", style=shape.triangledown, location=location.abovebar, size=size.small)
plotshape(exitS1_final, color = #1e90ff, text = "CFS", style=shape.triangleup, location=location.belowbar, size=size.small)

// slow L
plotshape(enterL2_final, color = #0000ff, text = "OSL", style=shape.triangleup, location=location.belowbar, size=size.small)
plotshape(exitL2_final, color = #ff0000, text = "CSL", style=shape.triangledown, location=location.abovebar, size=size.small)

// slow S
plotshape(enterS2_final, color = #ff0000, text = "OSS", style=shape.triangledown, location=location.abovebar, size=size.small)
plotshape(exitS2_final, color = #0000ff, text = "CSS", style=shape.triangleup, location=location.belowbar, size=size.small)


// Alerts
// fast L
alertcondition(enterL1_final, "Enter fast L", "Enter fast L")
alertcondition(exitL1_final, "Exit fast L", "Exit fast L")

// fast S
alertcondition(enterS1_final, "Enter fast S", "Enter fast S")
alertcondition(exitS1_final, "Exit fast S", "Exit fast S")

// slow L
alertcondition(enterL2_final, "Enter slow L", "Enter slow L")
alertcondition(exitL2_final, "Exit slow L", "Exit slow L")

// slow S
alertcondition(enterS2_final, "Enter slow S", "Enter slow S")
alertcondition(exitS2_final, "Exit slow S", "Exit slow S")

// Original code from strategy
//strategy.entry("fast L", strategy.long, when = enterL1 and (time > timestamp(FromYear, FromMonth, FromDay, 00, 00)) and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59)))
//strategy.entry("fast S", strategy.short, when = enterS1 and (time > timestamp(FromYear, FromMonth, FromDay, 00, 00)) and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59)))
//strategy.close("fast L", when = exitL1 and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59)))
//strategy.close("fast S", when = exitS1 and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59)))

//strategy.entry("slow L", strategy.long, when = enterL2 and (time > timestamp(FromYear, FromMonth, FromDay, 00, 00)) and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59)))
//strategy.entry("slow S", strategy.short, when = enterS2 and (time > timestamp(FromYear, FromMonth, FromDay, 00, 00)) and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59)))
//strategy.close("slow L", when = exitL2 and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59)))
//strategy.close("slow S", when = exitS2 and (time < timestamp(ToYear, ToMonth, ToDay, 23, 59)))
````
