# VWAP+SVP Signalgeber

- url: https://www.tradingview.com/script/Ru35Jyj2/
- type: indicator
- pine_id: PUB;cce335e86e914c8392a14b8be2c8d31b
- version: 1.0

## Description

gibt signale aus bei vwap und svp und tdv um zu handeln

## Source Code

````pine
//@version=6
indicator(title="VWAP+SVP Signalgeber", shorttitle="VWAP+SVP", overlay=true)

// === Einstellungen ===
hideonDWM = input(false, title="VWAP auf Tageschart ausblenden")
var anchor = input.string("Session", "Anchor Period", options=["Session","Week","Month","Quarter","Year","Decade","Century","Earnings","Dividends","Splits"])
src = input(hlc3, "Source")
resetOnSessionOpen = input(true, "Reset bei Sessionsbeginn")
sessionTime = input.session("0930-1600", "Session Time")
sessionTimezone = input.string("America/New_York", "Session Timezone")
svp_dpoc = input.source(close, "SVP Developing POC")
svp_dvah = input.source(close, "SVP Developing VA High")
svp_dval = input.source(close, "SVP Developing VA Low")
riskPerTrade = input.float(100.0, "Risk per Trade ($)", step=10)

// === Volumen & Splits ===
if barstate.islast and ta.cum(volume) == 0
    runtime.error("Keine Volumendaten verfügbar.")
dollarVolume = volume * close
minDollarVolume = (100000 / 60) * timeframe.multiplier
volumeCheck = dollarVolume >= minDollarVolume

new_earnings  = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
new_dividends = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
new_split     = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)

// === VWAP Reset Logik ===
isNewPeriod = switch anchor
    "Earnings"  => not na(new_earnings)
    "Dividends" => not na(new_dividends)
    "Splits"    => not na(new_split)
    "Session"   => timeframe.change("D")
    "Week"      => timeframe.change("W")
    "Month"     => timeframe.change("M")
    "Quarter"   => timeframe.change("3M")
    "Year"      => timeframe.change("12M")
    "Decade"    => timeframe.change("12M") and year % 10 == 0
    "Century"   => timeframe.change("12M") and year % 100 == 0
    => false

isSessionOpen = not na(time(timeframe.period, sessionTime, sessionTimezone))
isNewSession = isSessionOpen and not isSessionOpen[1]
if resetOnSessionOpen
    isNewPeriod := isNewPeriod or isNewSession
if na(src[1]) and anchor != "Earnings" and anchor != "Dividends" and anchor != "Splits"
    isNewPeriod := true

// === VWAP & Bänder ===
var float vwapValue = na
var float upper1 = na
var float lower1 = na
var float u1p025 = na
var float u1m025 = na
var float l1p025 = na
var float l1m025 = na
var float u1p05 = na
var float u1m05 = na
var float l1p05 = na
var float l1m05 = na

if not (hideonDWM and timeframe.isdwm)
    [vw, stdevUp, _] = ta.vwap(src, isNewPeriod, 1)
    if not na(vw)
        vwapValue := vw
        float stdev = stdevUp - vw
        upper1 := vw + stdev
        lower1 := vw - stdev
        u1p025 := upper1 + stdev * 0.25
        u1m025 := upper1 - stdev * 0.25
        l1p025 := lower1 + stdev * 0.25
        l1m025 := lower1 - stdev * 0.25
        u1p05  := upper1 + stdev * 0.5
        u1m05  := upper1 - stdev * 0.5
        l1p05  := lower1 + stdev * 0.5
        l1m05  := lower1 - stdev * 0.5

// === Risiko & Positionsgröße ===
riskDiff = math.abs(upper1 - vwapValue)
slTicks = math.ceil(riskDiff / syminfo.mintick)
shares = math.floor(riskPerTrade / riskDiff)

// === Signallogik ===
inUpperZone = close[1] >= u1m025[1] and close[1] <= u1p025[1]
inLowerZone = close[1] >= l1m025[1] and close[1] <= l1p025[1]

longCond = not na(vwapValue) and inUpperZone and volumeCheck and
           svp_dpoc >= u1m025[1] and svp_dpoc <= u1p025[1] and
           svp_dvah >= upper1[1] and svp_dvah <= u1p05[1]
shortCond = not na(vwapValue) and inLowerZone and volumeCheck and svp_dpoc >= l1m025[1] and svp_dpoc <= l1p025[1] and svp_dval <= lower1[1] and svp_dval >= l1m05[1]

longSignal  = longCond and not longCond[1]
shortSignal = shortCond and not shortCond[1]

// === Visualisierung ===
plotshape(longSignal, style=shape.triangleup, location=location.belowbar, color=color.new(color.green,0), size=size.small)
plotshape(shortSignal, style=shape.triangledown, location=location.abovebar, color=color.new(color.red,0), size=size.small)

// === Alarme mit Popup (später Webhook) ===
if longSignal
    alert("Long," + syminfo.ticker + "," + str.tostring(shares) + "," + str.tostring(slTicks), alert.freq_once_per_bar)
if shortSignal
    alert("Short," + syminfo.ticker + "," + str.tostring(shares) + "," + str.tostring(slTicks), alert.freq_once_per_bar)
````
