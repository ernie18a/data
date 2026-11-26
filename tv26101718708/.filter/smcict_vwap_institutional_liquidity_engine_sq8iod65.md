# SMC/ICT VWAP Institutional Liquidity Engine

- url: https://www.tradingview.com/script/sQ8iOD65-SMC-ICT-VWAP-Institutional-Liquidity-Engine/
- type: indicator
- pine_id: PUB;f5651d9a3e4c4aca9942b01382c3f01f
- version: 1.0

## Description

This is a high-probability Smart Money Concepts (SMC) & ICT-based Volume Weighted Average Price (VWAP) Institutional Liquidity Engine designed for version 6 (v6). Unlike standard VWAP indicators that plot generic standard deviation bands and generate excessive noise, this indicator filters out retail traps and focuses strictly on major institutional liquidity pools and stop hunts.Key Features & Logic
Major Structural Liquidity Sweep: The indicator continuously tracks major swing highs and lows over a custom lookback period (default 20 bars). Signals are only generated when these significant structural levels are raided (Stop Loss Hunting / Judas Swing).

SMC Premium & Discount Liquidity Pools: It incorporates an extreme dynamic outer band (Band 3 set at a 3.0 multiplier). High-probability reversals are verified only when the price penetrates these deep premium/discount zones and rejects strongly back into the value area.

Institutional Volume Filter: Retail volume is completely ignored. A signal is validated only when the sweeping bar exhibits institutional volume volume that is significantly higher (1.5x default) than the 20-period moving average of volume.

How to Trade This Script
SMC BUY Signal: Look for this label when the market sweeps a major old low, hits the green discount liquidity pool, and snaps back with high institutional volume. This indicates a potential bullish reversal or a successful stop run.

SMC SELL Signal: Look for this label when the market sweeps a major old high, hits the red premium liquidity pool, and rejects aggressively with high institutional volume.

Works best on intraday timeframes (1m, 3m, 5m for scalping with a lower lookback, or 15m/1h for intraday structure).

## Source Code

````pine
//@version=6
indicator(title="SMC/ICT VWAP Institutional Liquidity Engine", shorttitle="SMC/ICT VWAP", overlay=true)

// --- INPUTS ---
hideonDWM = input.bool(false, title="Hide VWAP on 1D or Above", group="VWAP Settings")
var anchor = input.string(defval = "Session", title="Anchor Period", options=["Session", "Week", "Month", "Quarter", "Year", "Earnings", "Dividends", "Splits"], group="VWAP Settings")
src = input.source(title = "Source", defval = hlc3, group="VWAP Settings")
offset = input.int(0, title="Offset", group="VWAP Settings")

BANDS_GROUP = "Bands Settings"
calcModeInput = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = BANDS_GROUP)

showBand_1 = input.bool(false, title = "Show Inner Band #1 (Filter Out)", group = BANDS_GROUP)
bandMult_1 = input.float(1.5, title = "Multiplier #1", group = BANDS_GROUP, step = 0.5, minval=0)

showBand_3 = input.bool(true, title = "Show SMC Liquidity Pool (Band #3)", group = BANDS_GROUP)
bandMult_3 = input.float(3.0, title = "SMC Liquidity Multiplier (Extreme Zone)", group = BANDS_GROUP, step = 0.1, minval=0, tooltip="Ise 3.0 se 3.5 ke beech rakhein high accuracy ke liye")

SMC_GROUP = "SMC/ICT Liquidity Settings"
showSignals = input.bool(true, title="Show High-Probability Signals", group=SMC_GROUP)
lookbackPeriod = input.int(20, title="Major Structure Swing Lookback", minval=10, group=SMC_GROUP, tooltip="Noise hatane ke liye is lookback ko bada (20-30) rakha gaya hai")
volMultiplier = input.float(1.5, title="Institutional Volume Multiplier", minval=1.0, step=0.1, group=SMC_GROUP, tooltip="Normal volume se kitna guna zyada volume chahiye big banks ki entry confirm karne ke liye")

// --- VOLUME CHECK ---
cumVolume = ta.cum(volume)
if barstate.islast and cumVolume == 0
    runtime.error("No volume is provided by the data vendor.")

// --- ANCHOR LOGIC ---
isNewPeriod = false
if anchor == "Earnings"
    new_earnings_actual = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
    new_earnings_standardized = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
    isNewPeriod := not na(new_earnings_actual) or not na(new_earnings_standardized)
else if anchor == "Dividends"
    new_dividends = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
    isNewPeriod := not na(new_dividends)
else if anchor == "Splits"
    new_split = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
    isNewPeriod := not na(new_split)
else if anchor == "Session"
    isNewPeriod := timeframe.change("D")
else if anchor == "Week"
    isNewPeriod := timeframe.change("W")
else if anchor == "Month"
    isNewPeriod := timeframe.change("M")
else if anchor == "Quarter"
    isNewPeriod := timeframe.change("3M")
else if anchor == "Year"
    isNewPeriod := timeframe.change("12M")

isEsdAnchor = anchor == "Earnings" or anchor == "Dividends" or anchor == "Splits"
if na(src[1]) and not isEsdAnchor
    isNewPeriod := true

// --- VARIABLES ---
float vwapValue = float(na)
float upperBandValue1 = float(na), lowerBandValue1 = float(na)
float upperBandValue3 = float(na), lowerBandValue3 = float(na)

// --- CALCULATIONS ---
if not (hideonDWM and timeframe.isdwm)
    [_vwap, _stdevUpper, _] = ta.vwap(src, isNewPeriod, 1)
    vwapValue := _vwap
    stdevAbs = _stdevUpper - _vwap
    bandBasis = calcModeInput == "Standard Deviation" ? stdevAbs : _vwap * 0.01
    
    upperBandValue1 := _vwap + bandBasis * bandMult_1
    lowerBandValue1 := _vwap - bandBasis * bandMult_1
    upperBandValue3 := _vwap + bandBasis * bandMult_3
    lowerBandValue3 := _vwap - bandBasis * bandMult_3

// --- SMC/ICT INSTITUTIONAL ENGINE ---
majorHigh = ta.highest(high[1], lookbackPeriod)
majorLow = ta.lowest(low[1], lookbackPeriod)

avgVol = ta.sma(volume, 20)
isInstitutionalVolume = volume > (avgVol * volMultiplier)

bslRaid = low < majorLow and close > majorLow
smcBuyZone = low <= lowerBandValue3 or low[1] <= lowerBandValue3[1]
smcBuySignal = bslRaid and close > open and smcBuyZone and isInstitutionalVolume

sslRaid = high > majorHigh and close < majorHigh
smcSellZone = high >= upperBandValue3 or high[1] >= upperBandValue3[1]
smcSellSignal = sslRaid and close < open and smcSellZone and isInstitutionalVolume

// --- PLOTS ---
vwapColor = close > vwapValue ? color.new(color.blue, 30) : color.new(color.purple, 30)
plot(vwapValue, title = "Institutional VWAP", color = vwapColor, linewidth = 2, offset = offset)

displayBand1 = showBand_1 ? display.all : display.none
plot(upperBandValue1, title="Inner Upper Band", color = color.new(color.gray, 60), offset = offset, display = displayBand1)
plot(lowerBandValue1, title="Inner Lower Band", color = color.new(color.gray, 60), offset = offset, display = displayBand1)

displayBand3 = showBand_3 ? display.all : display.none
upperPool = plot(upperBandValue3, title="SMC Premium Liquidity Pool", color = color.new(color.red, 20), linewidth = 2, offset = offset, display = displayBand3)
lowerPool = plot(lowerBandValue3, title="SMC Discount Liquidity Pool", color = color.new(color.green, 20), linewidth = 2, offset = offset, display = displayBand3)
fill(upperPool, lowerPool, title="SMC Equilibrium Zone", color = color.new(color.blue, 98), display = displayBand3)

// --- SIGNALS SHAPES (COLOR FIXED) ---
plotshape(showSignals and smcBuySignal, title="SMC Institutional BUY", style=shape.labelup, location=location.belowbar, color=color.green, size=size.normal, text="SMC BUY", textcolor=color.white)
plotshape(showSignals and smcSellSignal, title="SMC Institutional SELL", style=shape.labeldown, location=location.abovebar, color=color.red, size=size.normal, text="SMC SELL", textcolor=color.white)

// --- V6 ALERTS TRIGGER ---
if smcBuySignal
    alert("SMC Institutional Liquidity Swept: High Probability BUY Entry!", alert.freq_once_per_bar_close)
if smcSellSignal
    alert("SMC Institutional Liquidity Swept: High Probability SELL Entry!", alert.freq_once_per_bar_close)
````
