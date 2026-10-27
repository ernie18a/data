# Daily Bollinger Bands + Stretch - Boring Money Concepts

- url: https://www.tradingview.com/script/2ti6Jnaz-Daily-Bollinger-Bands-Stretch-Boring-Money-Concepts/
- type: indicator
- pine_id: PUB;7cc05d81f45c4397a926d0f7a1a2f861
- version: 1.0

## Description

Daily Bollinger Bands + Stretch (Z-Score & ATR)

OVERVIEW

This is for spotting high-probability reversals and capitulations from a ticker being stretched outside the Bollinger Bands on a Daily chart.

There are 2 statistical "stretch factors" that must be hit before the alert puts a signal on your chart. a Z-score based on standard deviation and a score based on ATR. This should filter out a lot of noise alerts. You can change the settings if you want more alerts and potentially more noise.

HOW THE STRETCH MEASURES WORK

The Z-score is the distance from the Daily BB Basis divided by the daily standard deviation used to build the bands. The standard 2.0 band edges correspond to Z values of +2 and -2. Because the ruler comes from the most recent 20 days (adjustable), the Z-score always measures stretch relative to recent behavior, not to a fixed historical level.

The ATR stretch is the same distance from the basis divided by the daily Average True Range. Where the Z-score reflects how widely daily closes have scattered, the ATR stretch reflects how far price actually travels in a typical day, including gaps. The two usually agree. When they disagree, most often after a quiet squeeze where closes cluster tightly, a high Z-score may overstate how extended price really is.

Each measure is calculated for the bar's close, high and low, so you can distinguish a bar that closed extended from one that only wicked there.

ALERTS
Two alert conditions are available: Daily Stretch Up and Daily Stretch Down. Alerts are designed for strength over frequency.

Trigger On: Close requires the bar to close beyond the threshold, filtering out wicks that snap back immediately.

Require Z AND ATR Agreement: when enabled, both measures must exceed their thresholds, which filters out weaker stretches.

For best results, set the alert frequency to "Once Per Bar Close" when creating the alert. Triangles on the chart mark each signal. I like Daily alerts for possible swing entries but timeframes above 60 minutes might work, also.

DEFAULT SETTINGS
Band Timeframe: D. BB Length: 20. Basis MA Type: SMA. StdDev: 2.0. ATR Length: 14. Z Alert Threshold: 2.5. ATR Stretch Alert Threshold: 2.0. Trigger On: Close. Require Z AND ATR Agreement: on.

## Source Code

````pine
//@version=6
indicator(shorttitle="Daily BB - Boring Money", title="Daily Bollinger Bands + Stretch - Boring Money Concepts", overlay=true)

TT_CONF = "ON = use last COMPLETED daily bar (non-repainting). OFF = developing daily bar (repaints)."
TT_TRIG = "Close = bar must CLOSE beyond threshold (fewer false triggers, one bar later). Wick = high/low excursion (faster, noisier)."
TT_BOTH = "ON = alert only when Z AND ATR stretch both exceed thresholds. Filters squeeze false-triggers."

tf           = input.timeframe("D", "Band Timeframe")
useConfirmed = input.bool(true, "Use Completed Daily Bar (No Repaint)", tooltip = TT_CONF)
length       = input.int(20, "BB Length (Recent Window)", minval = 1)
maType       = input.string("SMA", "Basis MA Type", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
src          = input(close, "Source")
mult         = input.float(2.0, "StdDev", minval = 0.001, maxval = 50)
atrLen       = input.int(14, "ATR Length", minval = 1)
offset       = input.int(0, "Offset", minval = -500, maxval = 500, display = display.none)

zAlert       = input.float(2.5, "Z Alert Threshold",           minval = 0.1, group = "Alerts")
atrAlert     = input.float(2.0, "ATR Stretch Alert Threshold", minval = 0.1, group = "Alerts")
trigOn       = input.string("Close", "Trigger On", options = ["Close", "Wick"], tooltip = TT_TRIG, group = "Alerts")
requireBoth  = input.bool(true, "Require Z AND ATR Agreement", tooltip = TT_BOTH, group = "Alerts")

ma(source, len, _type) =>
    switch _type
        "SMA"        => ta.sma(source, len)
        "EMA"        => ta.ema(source, len)
        "SMMA (RMA)" => ta.rma(source, len)
        "WMA"        => ta.wma(source, len)
        "VWMA"       => ta.vwma(source, len)

dailyCalc(int shift) =>
    b = ma(src, length, maType)
    d = mult * ta.stdev(src, length)
    u = b + d
    l = b - d
    a = ta.atr(atrLen)
    [b[shift], u[shift], l[shift], a[shift]]

shift = useConfirmed ? 1 : 0
look  = useConfirmed ? barmerge.lookahead_on : barmerge.lookahead_off

[dBasis, dUpper, dLower, dATR] = request.security(syminfo.tickerid, tf, dailyCalc(shift), gaps = barmerge.gaps_off, lookahead = look)

// Z-score stretch (sigma units, recent window)
sigma  = (dUpper - dBasis) / mult
zClose = sigma > 0 ? (close - dBasis) / sigma : na
zHigh  = sigma > 0 ? (high  - dBasis) / sigma : na
zLow   = sigma > 0 ? (low   - dBasis) / sigma : na

// ATR stretch (daily ATR units from Daily BB Basis)
aClose = dATR > 0 ? (close - dBasis) / dATR : na
aHigh  = dATR > 0 ? (high  - dBasis) / dATR : na
aLow   = dATR > 0 ? (low   - dBasis) / dATR : na

// Trigger values
useClose = trigOn == "Close"
zUpVal = useClose ? zClose : zHigh
zDnVal = useClose ? zClose : zLow
aUpVal = useClose ? aClose : aHigh
aDnVal = useClose ? aClose : aLow

upCond = requireBoth ? (zUpVal >=  zAlert and aUpVal >=  atrAlert) : (zUpVal >=  zAlert or aUpVal >=  atrAlert)
dnCond = requireBoth ? (zDnVal <= -zAlert and aDnVal <= -atrAlert) : (zDnVal <= -zAlert or aDnVal <= -atrAlert)

// Once per day per direction
newDay = ta.change(time("D")) != 0
var bool upFired = false
var bool dnFired = false
if newDay
    upFired := false
    dnFired := false

upSignal = upCond and not upFired
dnSignal = dnCond and not dnFired
if upSignal
    upFired := true
if dnSignal
    dnFired := true

// Chart plots
plot(dBasis, "Daily BB Basis", color = #1A237E, offset = offset)
p1 = plot(dUpper, "Daily BB Upper", color = #F23645, offset = offset)
p2 = plot(dLower, "Daily BB Lower", color = #089981, offset = offset)
fill(p1, p2, title = "Daily BB Fill", color = color.rgb(33, 150, 243, 95))
plotshape(upSignal, "Stretch Up Signal",   shape.triangledown, location.abovebar, color = #F23645, size = size.small)
plotshape(dnSignal, "Stretch Down Signal", shape.triangleup,   location.belowbar, color = #089981, size = size.small)

// Data columns (off-chart)
plot(dATR,   "Daily ATR",               display = display.data_window)
plot(zClose, "Daily BB Z Close",        display = display.data_window)
plot(zHigh,  "Daily BB Z High",         display = display.data_window)
plot(zLow,   "Daily BB Z Low",          display = display.data_window)
plot(aClose, "Daily ATR Stretch Close", display = display.data_window)
plot(aHigh,  "Daily ATR Stretch High",  display = display.data_window)
plot(aLow,   "Daily ATR Stretch Low",   display = display.data_window)
plot(upSignal ? 1 : 0, "Daily Stretch Signal Up",   display = display.data_window)
plot(dnSignal ? 1 : 0, "Daily Stretch Signal Down", display = display.data_window)

// Alerts
alertcondition(upSignal, "Daily Stretch Up",   "{{ticker}} Daily stretch UP - review chart")
alertcondition(dnSignal, "Daily Stretch Down", "{{ticker}} Daily stretch DOWN - review chart")
````
