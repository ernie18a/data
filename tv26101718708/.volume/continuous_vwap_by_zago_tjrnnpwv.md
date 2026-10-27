# Continuous VWAP by Zago

- url: https://www.tradingview.com/script/TJrNnPWV-Continuous-VWAP-by-Zago/
- type: indicator
- pine_id: PUB;32d227e31430448c83123c801133c5cc
- version: 1.0

## Description

Vwap that doesn't reset when the year changes. Basically, an anchored Vwap since inception of the chart

## Source Code

````pine
//@version=6
indicator(title="Continuous VWAP", shorttitle="Continuous VWAP", overlay=true, timeframe="", timeframe_gaps=true)

hideonDWM = input(false, title="Hide VWAP on 1D or Above", group="VWAP Settings", display=display.none)
src = input(title="Source", defval=hlc3, group="VWAP Settings", display=display.none)
offset = input.int(0, title="Offset", group="VWAP Settings", display=display.none)

BANDS_GROUP = "Bands Settings"
calcModeInput = input.string("Standard Deviation", "Bands Calculation Mode", options=["Standard Deviation", "Percentage"], group=BANDS_GROUP, display=display.none)

showBand_1 = input(true, title="", group=BANDS_GROUP, inline="band_1", display=display.none)
bandMult_1 = input.float(1.0, title="Bands Multiplier #1", group=BANDS_GROUP, inline="band_1", step=0.5, minval=0, display=display.none, active=showBand_1)

showBand_2 = input(false, title="", group=BANDS_GROUP, inline="band_2", display=display.none)
bandMult_2 = input.float(2.0, title="Bands Multiplier #2", group=BANDS_GROUP, inline="band_2", step=0.5, minval=0, display=display.none, active=showBand_2)

showBand_3 = input(false, title="", group=BANDS_GROUP, inline="band_3", display=display.none)
bandMult_3 = input.float(3.0, title="Bands Multiplier #3", group=BANDS_GROUP, inline="band_3", step=0.5, minval=0, display=display.none, active=showBand_3)

cumVolume = ta.cum(volume)

if barstate.islast and cumVolume == 0
    runtime.error("No volume is provided by the data vendor.")

// Continuous VWAP calculation
cumPV = ta.cum(src * volume)
cumV = ta.cum(volume)
vwapValue = cumPV / cumV

// Continuous volume-weighted standard deviation
cumPV2 = ta.cum(volume * src * src)
variance = cumPV2 / cumV - vwapValue * vwapValue
stdevAbs = math.sqrt(math.max(variance, 0))

bandBasis = calcModeInput == "Standard Deviation" ? stdevAbs : vwapValue * 0.01

upperBandValue1 = vwapValue + bandBasis * bandMult_1
lowerBandValue1 = vwapValue - bandBasis * bandMult_1

upperBandValue2 = vwapValue + bandBasis * bandMult_2
lowerBandValue2 = vwapValue - bandBasis * bandMult_2

upperBandValue3 = vwapValue + bandBasis * bandMult_3
lowerBandValue3 = vwapValue - bandBasis * bandMult_3

plot(hideonDWM and timeframe.isdwm ? na : vwapValue, title="Continuous VWAP", color=#2962FF, offset=offset)

displayBand1 = showBand_1 ? display.all : display.none
upperBand_1 = plot(hideonDWM and timeframe.isdwm ? na : upperBandValue1, title="Upper Band #1", color=color.green, offset=offset, display=displayBand1, editable=showBand_1)
lowerBand_1 = plot(hideonDWM and timeframe.isdwm ? na : lowerBandValue1, title="Lower Band #1", color=color.green, offset=offset, display=displayBand1, editable=showBand_1)
fill(upperBand_1, lowerBand_1, title="Bands Fill #1", color=color.new(color.green, 95), display=displayBand1, editable=showBand_1)

displayBand2 = showBand_2 ? display.all : display.none
upperBand_2 = plot(hideonDWM and timeframe.isdwm ? na : upperBandValue2, title="Upper Band #2", color=color.olive, offset=offset, display=displayBand2, editable=showBand_2)
lowerBand_2 = plot(hideonDWM and timeframe.isdwm ? na : lowerBandValue2, title="Lower Band #2", color=color.olive, offset=offset, display=displayBand2, editable=showBand_2)
fill(upperBand_2, lowerBand_2, title="Bands Fill #2", color=color.new(color.olive, 95), display=displayBand2, editable=showBand_2)

displayBand3 = showBand_3 ? display.all : display.none
upperBand_3 = plot(hideonDWM and timeframe.isdwm ? na : upperBandValue3, title="Upper Band #3", color=color.teal, offset=offset, display=displayBand3, editable=showBand_3)
lowerBand_3 = plot(hideonDWM and timeframe.isdwm ? na : lowerBandValue3, title="Lower Band #3", color=color.teal, offset=offset, display=displayBand3, editable=showBand_3)
fill(upperBand_3, lowerBand_3, title="Bands Fill #3", color=color.new(color.teal, 95), display=displayBand3, editable=showBand_3)
````
