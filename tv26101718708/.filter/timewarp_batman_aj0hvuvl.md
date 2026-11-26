# TimeWarp Batman

- url: https://www.tradingview.com/script/AJ0hVUVl-TimeWarp-Batman/
- type: indicator
- pine_id: PUB;632d7929c46d4e9a9762be122d5bb747
- version: 2.0

## Description

[b]SPX Batman 1DTE — Strike Signal & Alert Tool
[/b]
This indicator identifies end-of-day entry conditions for the SPX Batman spread, a two-legged options structure consisting of a long call butterfly placed out of the money above spot and a long put butterfly placed out of the money below spot. Neither fly shares legs. Both are sized and positioned independently.

[b]What the Batman spread is
[/b]
The Batman is a defined-risk, direction-neutral options trade designed to profit from a pin near expiry. It is not a straddle or strangle. Each leg is a long butterfly. The long call fly is entered OTM above spot at the close, targeting next-day expiry or Monday for Friday entries. The long put fly is entered OTM below spot on the same terms. The structure earns maximum profit if the underlying pins near either body at expiry. Max loss on each fly is limited to the debit paid.

[b]How this indicator works
[/b]
At 3:55 PM ET each session the indicator calculates proposed strike levels for both flies based on three inputs. Wing width is derived from VIX in dynamic mode or set manually, widening at elevated volatility. Body offset starts at 65 points plus the wing width from spot, rounded to the nearest 5-point SPX strike. Target debit range is calculated from your reward-to-risk inputs. A 1:15 to 1:20 target corresponds to a debit of approximately 4.8% to 6.25% of wing width per fly.

A label fires on the chart at signal time showing all six strike levels, the target debit range in points, and the expiry type. Strike lines remain visible through the next session. If the underlying trades through an outer wing a background highlight fires and a separate alert is available.

[b]How to use it
[/b]
Add the indicator to a 1-minute or 5-minute SPX chart. At the signal, open your broker's options chain for the next-day expiry. Locate the proposed call fly and put fly strikes. Walk the body strikes up or down in 5-point increments until the actual debit falls within the displayed target range. Enter both flies and manage through expiry.

Set alerts on Batman 1DTE Entry and Batman 3DTE Entry to be notified at signal time without watching the chart.

[b]Inputs
[/b]
[list]
[*]VIX Symbol sets the data source for volatility-based width calculation. 
[*]Wing Width Mode switches between dynamic 
[*]VIX-scaled sizing and fixed widths of 20, 25, or 30 points. 
[*]Fixed Width sets the manual width when not using dynamic mode. 
[*]Min Reward to Risk and Max Reward to Risk define the acceptable debit range for each fly, defaulting to 1:15 and 1:20.
[*]
[/list]
[b]Important
[/b]
This is a signal and visualization tool. It does not model options P&L, implied volatility, or time decay. TradingView cannot accurately backtest multi-leg options structures and this indicator makes no attempt to do so. All fills, debit verification, and risk management occur in your broker. Past signal frequency is not indicative of future profitability.

## Source Code

````pine
//@version=6
indicator("SPX Batman 1DTE ", overlay=true)

// ── Inputs ─────────────────────────────────────
minutesBeforeClose = input.int(15, "Minutes Before Close", minval=5, maxval=30)

vixSymbol  = input.symbol("VIX",     "VIX Symbol")
widthMode  = input.string("Dynamic", "Wing Width Mode", options=["Dynamic", "Fixed 20", "Fixed 25", "Fixed 30"])
fixedWidth = input.int(25,           "Fixed Width (pts)", minval=10, maxval=50)
minRR      = input.int(15,           "Min Reward : Risk (1 : X)", minval=10, maxval=50)
maxRR      = input.int(20,           "Max Reward : Risk (1 : X)", minval=10, maxval=50)

// ── VIX & Derived Parameters ──────────────────
vix = request.security(vixSymbol, timeframe.period, close)

getWidth() =>
    widthMode == "Dynamic" ? (vix < 17 ? 30 : vix <= 25 ? 25 : 30) : fixedWidth

wingWidth = getWidth()
minDebit  = wingWidth / (maxRR + 1)
maxDebit  = wingWidth / (minRR + 1)

// ── Timing ────────────────────────────────────
nyHour        = hour(time,       "America/New_York")
nyMinute      = minute(time,     "America/New_York")
nyDate        = dayofmonth(time, "America/New_York")
isFriday      = dayofweek == dayofweek.friday

isLastXMin    = nyHour == 15 and nyMinute >= (60 - minutesBeforeClose)
isEntryBar    = isLastXMin and barstate.isconfirmed

// ── Persistent State ──────────────────────────
var float entrySpot = na
var float callLow   = na
var float callBody  = na
var float callHigh  = na
var float putHigh   = na
var float putBody   = na
var float putLow    = na
var bool  inBatman  = false
var int   entryDate = na

// ── Reset at next session ─────────────────────
if inBatman and not na(entryDate) and nyDate != entryDate and isLastXMin
    inBatman  := false
    entryDate := na

// ── Wing breach visual ────────────────────────
isWingBreach = inBatman and (high >= callHigh or low <= putLow)

bgcolor(isWingBreach ? color.new(color.red, 80) : na, title="Wing Breach")

// ── Signal Logic ──────────────────────────────
if isEntryBar and not inBatman
    s         = math.round(close / 5) * 5
    otmOffset = 65 + wingWidth
    cBody     = math.round((s + otmOffset) / 5) * 5
    pBody     = math.round((s - otmOffset) / 5) * 5

    entrySpot := s
    callLow   := cBody - wingWidth
    callBody  := cBody
    callHigh  := cBody + wingWidth
    putHigh   := pBody + wingWidth
    putBody   := pBody
    putLow    := pBody - wingWidth
    inBatman  := true
    entryDate := nyDate

    expiry    = isFriday ? "3DTE — Monday expiry" : "1DTE — tomorrow expiry"
    labelText = "BATMAN  |  " + expiry +
         "\n─────────────────────────────" +
         "\nWidth:        " + str.tostring(wingWidth) + " pts" +
         "\nTarget debit: " + str.tostring(minDebit, "#.00") +
              " – "         + str.tostring(maxDebit, "#.00") + " pts per fly" +
         "\nR:R target:   1:" + str.tostring(minRR) + " to 1:" + str.tostring(maxRR) +
         "\n─────────────────────────────" +
         "\nCall Fly:  " + str.tostring(callLow)  + " / " + str.tostring(callBody) + " / " + str.tostring(callHigh) +
         "\nPut Fly:   " + str.tostring(putLow)   + " / " + str.tostring(putBody)  + " / " + str.tostring(putHigh)

    label.new(bar_index, low, labelText,
         color=color.purple, textcolor=color.white,
         style=label.style_label_up, size=size.normal)

// ── Plots ─────────────────────────────────────
plot(inBatman ? entrySpot : na, title="Spot Reference",        color=color.gray,   style=plot.style_linebr, linewidth=1)
plot(inBatman ? callHigh  : na, title="Call Fly Upper Wing",   color=color.orange, style=plot.style_linebr, linewidth=1)
plot(inBatman ? callBody  : na, title="Call Fly Body (short)", color=color.red,    style=plot.style_linebr, linewidth=2)
plot(inBatman ? callLow   : na, title="Call Fly Lower Wing",   color=color.orange, style=plot.style_linebr, linewidth=1)
plot(inBatman ? putHigh   : na, title="Put Fly Upper Wing",    color=color.aqua,   style=plot.style_linebr, linewidth=1)
plot(inBatman ? putBody   : na, title="Put Fly Body (short)",  color=color.green,  style=plot.style_linebr, linewidth=2)
plot(inBatman ? putLow    : na, title="Put Fly Lower Wing",    color=color.aqua,   style=plot.style_linebr, linewidth=1)

// ── Visual Signals ─────────────────────────────
plotshape(isEntryBar and isFriday,     title="Batman 3DTE", location=location.belowbar,
     color=color.purple, style=shape.labelup, text="BATMAN 3DTE",
     textcolor=color.white, size=size.normal)

plotshape(isEntryBar and not isFriday, title="Batman 1DTE", location=location.belowbar,
     color=color.purple, style=shape.labelup, text="BATMAN 1DTE",
     textcolor=color.white, size=size.normal)

// ── Alerts ────────────────────────────────────
alertcondition(isEntryBar and not inBatman and isFriday,
     title="Batman 3DTE Entry",
     message="SPX Batman 3DTE (Monday expiry): Enter Long Call Fly OTM above spot + Long Put Fly OTM below spot. Adjust strikes until each fly debit achieves 1:15 to 1:20 R:R.")

alertcondition(isEntryBar and not inBatman and not isFriday,
     title="Batman 1DTE Entry",
     message="SPX Batman 1DTE (tomorrow expiry): Enter Long Call Fly OTM above spot + Long Put Fly OTM below spot. Adjust strikes until each fly debit achieves 1:15 to 1:20 R:R.")

alertcondition(isWingBreach,
     title="Batman Wing Breach",
     message="SPX Batman: underlying has traded through an outer wing. Structure is compromised — review your position.")
````
