# ALREMI - Anchored Vol VWAP & Price VWAP

- url: https://www.tradingview.com/script/LMQOnaE2-ALREMI-Anchored-Vol-VWAP-Price-VWAP/
- type: indicator
- pine_id: PUB;3ab3dabffec94a9d86e43ce599dd0570
- version: 1.0

## Description

volume x vwap, volume is divided by vwap on time measuremt so you vćen get what is the big volume now

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("ALREMI - Anchored Vol VWAP & Price VWAP", shorttitle="ALREMI Vol & VWAP", overlay=false, format=format.volume)

// ==========================================
// 1. VWAP ANCHOR SETUP (Shared for both)
// ==========================================
var anchor = input.string(defval = "Session", title="Anchor Period", 
 options=["Session", "Week", "Month", "Quarter", "Year", "Decade", "Century", "Earnings", "Dividends", "Splits"], group="VWAP Settings")

isNewPeriod = switch anchor
    "Earnings" => 
        new_earnings_actual = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        new_earnings_standardized = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_earnings_actual) or not na(new_earnings_standardized)
    "Dividends" => 
        new_dividends = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_dividends)
    "Splits"    => 
        new_split = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_split)
    "Session"   => timeframe.change("D")
    "Week"      => timeframe.change("W")
    "Month"     => timeframe.change("M")
    "Quarter"   => timeframe.change("3M")
    "Year"      => timeframe.change("12M")
    "Decade"    => timeframe.change("12M") and year % 10 == 0
    "Century"   => timeframe.change("12M") and year % 100 == 0
    => false

isEsdAnchor = anchor == "Earnings" or anchor == "Dividends" or anchor == "Splits"
if na(close[1]) and not isEsdAnchor
    isNewPeriod := true

// ==========================================
// 2. VOLUME COLORS
// ==========================================
bullishHigh   = input.color(color.rgb(10,153,134), "Bullish - High Vol (Above VWAP)", group="Volume Colors")
bullishLow    = input.color(color.new(color.rgb(10,153,134), 70), "Bullish - Low Vol (Below VWAP)", group="Volume Colors")

bearishHigh   = input.color(color.rgb(242,54,69), "Bearish - High Vol (Above VWAP)", group="Volume Colors")
bearishLow    = input.color(color.new(color.rgb(242,54,69), 70), "Bearish - Low Vol (Below VWAP)", group="Volume Colors")

// ==========================================
// 3. CALCULATE & PLOT AGGRESSIVE VOLUME VWAP (Lower Pane)
// ==========================================
// Applying VWAP logic directly to volume with time anchor reset
[vol_vwap, _, _] = ta.vwap(volume, isNewPeriod, 1)

// Determine candle direction and volume size compared to anchored Vol VWAP
isBull = close >= open
isHighVol = volume > vol_vwap

// Final colors
volColor = isBull ? (isHighVol ? bullishHigh : bullishLow) : (isHighVol ? bearishHigh : bearishLow)

// Plotting Volume and Threshold
plot(volume, title="Volume", style=plot.style_columns, color=volColor)
plot(vol_vwap, title="Anchored Vol VWAP (Threshold)", color=color.orange, linewidth=2)

// ==========================================
// 4. CALCULATE & PLOT PRICE VWAP (Overlayed on Chart)
// ==========================================
hideonDWM = input(false, title="Hide VWAP on 1D or Above", group="Price VWAP Settings", display = display.none)
src = input(title = "VWAP Source", defval = hlc3, group="Price VWAP Settings", display = display.none)
offset = input.int(0, title="Offset", group="Price VWAP Settings", display = display.none)

BANDS_GROUP = "VWAP Bands Settings"
calcModeInput = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = BANDS_GROUP, display = display.none)

showBand_1 = input(true, title = "Show Band 1", group = BANDS_GROUP, inline = "band_1", display = display.none)
bandMult_1 = input.float(1.0, title = "Multiplier 1", group = BANDS_GROUP, inline = "band_1", step = 0.5, minval=0, display = display.none)

float vwapValue = na
float upperBandValue1 = na
float lowerBandValue1 = na

if not (hideonDWM and timeframe.isdwm)
    [_price_vwap, _stdevUpper, _] = ta.vwap(src, isNewPeriod, 1)
    vwapValue := _price_vwap
    stdevAbs = _stdevUpper - _price_vwap
    bandBasis = calcModeInput == "Standard Deviation" ? stdevAbs : _price_vwap * 0.01
    upperBandValue1 := _price_vwap + bandBasis * bandMult_1
    lowerBandValue1 := _price_vwap - bandBasis * bandMult_1

// Forcing Price VWAP lines to project onto the main price chart
plot(vwapValue, title = "Price VWAP", color = #2962FF, offset = offset, force_overlay = true)

displayBand1 = showBand_1 ? display.all : display.none
upperBand_1 = plot(upperBandValue1, title="Upper Band 1", color = color.green, offset = offset, display = displayBand1, force_overlay = true)
lowerBand_1 = plot(lowerBandValue1, title="Lower Band 1", color = color.green, offset = offset, display = displayBand1, force_overlay = true)
fill(upperBand_1, lowerBand_1, title="Bands Fill 1", color = color.new(color.green, 95), display = displayBand1)
````
