# Order Pressure Cloud [JOAT]

- url: https://www.tradingview.com/script/o3HCHoU2-Order-Pressure-Cloud-JOAT/
- type: indicator
- pine_id: PUB;55b5e19bb6e94ce78af6706d53b1caa3
- version: 1.0

## Description

Order Pressure Cloud is an open-source Pine Script v6 overlay that estimates directional pressure from close location value, candle body bias, and volume participation. It then projects that pressure around an ALMA/EMA blended basis as a volatility-adjusted cloud.

The script is designed for pressure context. It does not read real order book data. Instead, it creates a transparent price-and-volume proxy that can show whether bars are closing toward highs or lows, whether volume is participating, and whether price is holding above or below the adaptive basis.

[image]https://www.tradingview.com/x/zQwIWxHf/[/image]

[b]Core Concepts[/b]

[b]1. Close Location Value[/b]

The close location value measures where the candle closes inside its high-low range. A close near the high produces positive pressure, while a close near the low produces negative pressure.

[pine]
barRange = math.max(high - low, syminfo.mintick)
clv = ((close - low) - (high - close)) / barRange
[/pine]

[b]2. Volume-Weighted Pressure[/b]

The script smooths CLV multiplied by volume and divides it by smoothed volume. This produces a normalized pressure ratio.

[pine]
pressureNumerator = ta.ema(clv * volume, pressureLengthInput)
pressureDenominator = ta.ema(volume, pressureLengthInput)
pressureRatio = safeRatio(pressureNumerator, pressureDenominator)
[/pine]

[b]3. Body Bias Component[/b]

Body direction is also included. The body component is weighted by a capped volume pulse so unusually large bars do not dominate the reading indefinitely.

[b]4. Nonlinear Strength[/b]

The composite pressure is compressed with a nonlinear transform. This keeps extreme values readable and easier to display as a cloud strength score.

[b]5. ALMA/EMA Basis Cloud[/b]

The basis blends ALMA and EMA. ATR, pressure strength, and volume pulse expand or contract the cloud width.

[b]Features[/b]

[list]
[*][b]CLV pressure proxy:[/b] Measures where price closes inside each candle range
[*][b]Volume participation:[/b] Weights pressure by volume while normalizing by smoothed volume
[*][b]Body pressure component:[/b] Adds candle body direction to the pressure model
[*][b]Nonlinear strength scale:[/b] Converts pressure into a bounded -100 to +100 value
[*][b]Adaptive cloud:[/b] Cloud width adjusts with ATR, pressure strength, and volume pulse
[*][b]Basis blend:[/b] ALMA and EMA create a smoother central reference
[*][b]Pressure zones:[/b] Confirmed pressure shifts and holds create clean boxes with pressure percentage and volume pulse data
[*][b]Confirmed buy/sell labels:[/b] Compact labels mark pressure shifts and pressure-cloud holds after bar close
[*][b]Strength gauge:[/b] Top-right dashboard shows pressure, volume, basis side, and cloud scale
[*][b]Alerts:[/b] Pressure shifts, cloud holds, confirmed buy, and confirmed sell conditions
[/list]

[b]Input Parameters[/b]

[list]
[*]Source: Price source for the basis
[*]Pressure Length: Smoothing length for pressure calculations
[*]Basis Length: Length for ALMA and EMA basis
[*]ALMA Offset / ALMA Sigma: ALMA shape controls
[*]ALMA Share: Blend weight between ALMA and EMA
[*]ATR Length: Volatility length for cloud width
[*]Cloud Multiplier: Base cloud distance
[*]Signal Level: Strength threshold for pressure shifts
[*]Paint Bars: Enables pressure candle tint
[*]Strength Gauge: Shows dashboard
[*]Pressure Zones: Toggles pressure data boxes
[*]Buy/Sell Signals: Toggles compact confirmed labels
[*]Zone Width: Bars each pressure box extends
[*]Zone History: Maximum pressure boxes retained
[*]Palette: Selects color pair
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Gauge[/b]
The pressure row shows whether the current pressure score is above, below, or near neutral.

[b]Step 2: Watch Basis Holds[/b]
A cloud hold means price interacted with the inner cloud while pressure remained directional.

[b]Step 3: Compare Pressure With Price Location[/b]
Pressure is more meaningful when price is on the same side of the basis as the pressure reading.

[b]Indicator Limitations[/b]

[list]
[*]This is a price-and-volume proxy, not direct order book data
[*]Volume availability differs between markets and symbols
[*]Low-volume symbols can produce unstable pressure readings
[*]Pressure shifts are reactive and can reverse during choppy conditions
[/list]

[b]Originality Statement[/b]

Order Pressure Cloud is original in how it combines CLV, body bias, volume pulse, nonlinear strength compression, and an adaptive ALMA/EMA cloud. It is built as original Pine v6 code from public market data fields.

[b]Disclaimer[/b]

This script is provided for educational and informational use only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Pressure proxies can be inaccurate, especially where volume data is incomplete or irregular. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Order Pressure Cloud [JOAT]", shorttitle = "Pressure Cloud [JOAT]", overlay = true, max_labels_count = 80, max_boxes_count = 40)

sourceInput = input.source(hlc3, "Source")
pressureLengthInput = input.int(21, "Pressure Length", minval = 3)
basisLengthInput = input.int(34, "Basis Length", minval = 5)
almaOffsetInput = input.float(0.84, "ALMA Offset", minval = 0.05, maxval = 0.95, step = 0.01)
almaSigmaInput = input.float(6.0, "ALMA Sigma", minval = 1.0, step = 0.25)
basisBlendInput = input.float(0.58, "ALMA Share", minval = 0.0, maxval = 1.0, step = 0.05)
atrLengthInput = input.int(14, "ATR Length", minval = 2)
cloudMultInput = input.float(1.35, "Cloud Multiplier", minval = 0.25, step = 0.05)
signalLevelInput = input.float(42.0, "Signal Level", minval = 5.0, maxval = 95.0, step = 1.0)
paintBarsInput = input.bool(true, "Paint Bars")
gaugeInput = input.bool(true, "Strength Gauge")
pressureZonesInput = input.bool(true, "Pressure Zones")
signalLabelsInput = input.bool(true, "Buy/Sell Signals")
zoneBarsInput = input.int(10, "Zone Width", minval = 2, maxval = 50)
zoneHistoryInput = input.int(8, "Zone History", minval = 1, maxval = 20)
paletteInput = input.string("Aqua Rose", "Palette", options = ["Aqua Rose", "Neon Desk", "Mint Pulse", "VWAP Field"])

paletteBull(string preset) =>
    switch preset
        "Aqua Rose" => #00C8FF
        "Neon Desk" => #00ff00
        "Mint Pulse" => #00FFD5
        "VWAP Field" => #1ac200
        => #00C8FF

paletteBear(string preset) =>
    switch preset
        "Aqua Rose" => #FF005D
        "Neon Desk" => #ff0000
        "Mint Pulse" => #FF0066
        "VWAP Field" => #ff4040
        => #FF005D

clamp(float value, float floorValue, float ceilingValue) =>
    math.min(math.max(value, floorValue), ceilingValue)

safeRatio(float numerator, float denominator) =>
    denominator == 0.0 ? 0.0 : numerator / denominator

fade(color baseColor, float strength, int calmAlpha, int strongAlpha) =>
    int alpha = int(math.round(calmAlpha - (calmAlpha - strongAlpha) * clamp(strength, 0.0, 1.0)))
    color.new(baseColor, alpha)

bullColor = paletteBull(paletteInput)
bearColor = paletteBear(paletteInput)
neutralColor = color.rgb(128, 136, 146)

barRange = math.max(high - low, syminfo.mintick)
clv = ((close - low) - (high - close)) / barRange
bodyShare = safeRatio(close - open, barRange)
volumeBase = ta.ema(volume, pressureLengthInput)
volumePulse = safeRatio(volume, volumeBase)
pressureNumerator = ta.ema(clv * volume, pressureLengthInput)
pressureDenominator = ta.ema(volume, pressureLengthInput)
pressureRatio = safeRatio(pressureNumerator, pressureDenominator)
bodyPressure = ta.ema(bodyShare * math.min(volumePulse, 3.0), pressureLengthInput)
pressureComposite = pressureRatio * 0.72 + bodyPressure * 0.28
nonlinearPressure = pressureComposite / (1.0 + math.abs(pressureComposite))
strength = clamp(nonlinearPressure * 155.0, -100.0, 100.0)
absStrength = math.abs(strength) / 100.0

almaBasis = ta.alma(sourceInput, basisLengthInput, almaOffsetInput, almaSigmaInput)
emaBasis = ta.ema(sourceInput, basisLengthInput)
basis = almaBasis * basisBlendInput + emaBasis * (1.0 - basisBlendInput)
atrValue = ta.atr(atrLengthInput)
pressureTilt = safeRatio(ta.ema(close - basis, pressureLengthInput), atrValue)
cloudScale = 1.0 + absStrength * 0.70 + clamp(volumePulse - 1.0, 0.0, 2.0) * 0.12
cloudDistance = atrValue * cloudMultInput * cloudScale
upperCloud = basis + cloudDistance
lowerCloud = basis - cloudDistance
innerUpper = basis + cloudDistance * 0.38
innerLower = basis - cloudDistance * 0.38

strengthColor = color.from_gradient(strength, -100.0, 100.0, bearColor, bullColor)
cloudColor = strength >= 0.0 ? fade(bullColor, absStrength, 92, 73) : fade(bearColor, absStrength, 92, 73)
rimColor = color.from_gradient(pressureTilt * 60.0 + strength * 0.40, -100.0, 100.0, color.new(bearColor, 10), color.new(bullColor, 10))
barShade = fade(strengthColor, absStrength, 76, 20)
barcolor(paintBarsInput ? barShade : na)

bullCross = ta.crossover(strength, signalLevelInput)
bearCross = ta.crossunder(strength, -signalLevelInput)
bullPressure = bullCross and close > basis
bearPressure = bearCross and close < basis
cloudHoldBull = strength > signalLevelInput and low <= innerUpper and close > basis
cloudHoldBear = strength < -signalLevelInput and high >= innerLower and close < basis
bullHoldStart = cloudHoldBull and not cloudHoldBull[1]
bearHoldStart = cloudHoldBear and not cloudHoldBear[1]
confirmedBullZone = pressureZonesInput and barstate.isconfirmed and (bullPressure or bullHoldStart)
confirmedBearZone = pressureZonesInput and barstate.isconfirmed and (bearPressure or bearHoldStart)
buySignalRaw = bullPressure or bullHoldStart
sellSignalRaw = bearPressure or bearHoldStart
confirmedBuySignal = signalLabelsInput and barstate.isconfirmed and buySignalRaw
confirmedSellSignal = signalLabelsInput and barstate.isconfirmed and sellSignalRaw

upperPlot = plot(upperCloud, "Upper Pressure Cloud", color = color.new(rimColor, 26), linewidth = 1)
lowerPlot = plot(lowerCloud, "Lower Pressure Cloud", color = color.new(rimColor, 26), linewidth = 1)
innerUpperPlot = plot(innerUpper, "Upper Inner Pressure", color = color.new(rimColor, 48))
innerLowerPlot = plot(innerLower, "Lower Inner Pressure", color = color.new(rimColor, 48))
basisPlot = plot(basis, "ALMA EMA Basis", color = color.new(strengthColor, 0), linewidth = 2)

fill(upperPlot, lowerPlot, color = cloudColor, title = "Pressure Cloud")
fill(innerUpperPlot, innerLowerPlot, color = strength >= 0.0 ? color.new(bullColor, 88) : color.new(bearColor, 88), title = "Pressure Core")

zonePad = math.max(atrValue * 0.16, syminfo.mintick * 8.0)
pressureText = str.tostring(math.round(strength)) + "%"
pulseText = str.tostring(volumePulse, "#.##") + "x"

var array<box> pressureBoxes = array.new_box()
if confirmedBullZone
    bullZoneStateText = bullPressure ? "Bull Shift" : "Bull Hold"
    bullZoneTop = math.max(math.max(high, innerUpper), basis) + zonePad
    bullZoneBottom = math.min(math.min(low, innerLower), basis) - zonePad
    bullZoneText = bullZoneStateText + "\nP " + pressureText + "  V " + pulseText
    bullZoneBox = box.new(left = bar_index, top = bullZoneTop, right = bar_index + zoneBarsInput, bottom = bullZoneBottom, xloc = xloc.bar_index, bgcolor = fade(bullColor, absStrength, 90, 76), border_color = color.new(bullColor, 18), border_width = 1, text = bullZoneText, text_color = chart.fg_color, text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_center)
    array.push(pressureBoxes, bullZoneBox)
if confirmedBearZone
    bearZoneStateText = bearPressure ? "Bear Shift" : "Bear Hold"
    bearZoneTop = math.max(math.max(high, innerUpper), basis) + zonePad
    bearZoneBottom = math.min(math.min(low, innerLower), basis) - zonePad
    bearZoneText = bearZoneStateText + "\nP " + pressureText + "  V " + pulseText
    bearZoneBox = box.new(left = bar_index, top = bearZoneTop, right = bar_index + zoneBarsInput, bottom = bearZoneBottom, xloc = xloc.bar_index, bgcolor = fade(bearColor, absStrength, 90, 76), border_color = color.new(bearColor, 18), border_width = 1, text = bearZoneText, text_color = chart.fg_color, text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_center)
    array.push(pressureBoxes, bearZoneBox)
while array.size(pressureBoxes) > zoneHistoryInput
    oldPressureBox = array.shift(pressureBoxes)
    box.delete(oldPressureBox)

var array<label> signalLabels = array.new_label()
if confirmedBuySignal
    buyLabel = label.new(x = bar_index, y = low - zonePad, text = "BUY", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bullColor, 4), textcolor = chart.fg_color, size = size.tiny)
    array.push(signalLabels, buyLabel)
if confirmedSellSignal
    sellLabel = label.new(x = bar_index, y = high + zonePad, text = "SELL", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bearColor, 4), textcolor = chart.fg_color, size = size.tiny)
    array.push(signalLabels, sellLabel)
while array.size(signalLabels) > 24
    oldSignalLabel = array.shift(signalLabels)
    label.delete(oldSignalLabel)

bullPressureAlert = bullPressure and barstate.isconfirmed
bearPressureAlert = bearPressure and barstate.isconfirmed
bullHoldAlert = cloudHoldBull and barstate.isconfirmed
bearHoldAlert = cloudHoldBear and barstate.isconfirmed
confirmedBuyAlert = confirmedBuySignal
confirmedSellAlert = confirmedSellSignal
alertcondition(bullPressureAlert, "Bull Pressure Shift [JOAT]", "Bull pressure shift confirmed on {{ticker}} {{interval}}.")
alertcondition(bearPressureAlert, "Bear Pressure Shift [JOAT]", "Bear pressure shift confirmed on {{ticker}} {{interval}}.")
alertcondition(bullHoldAlert, "Bull Cloud Hold [JOAT]", "Bull cloud hold confirmed on {{ticker}} {{interval}}.")
alertcondition(bearHoldAlert, "Bear Cloud Hold [JOAT]", "Bear cloud hold confirmed on {{ticker}} {{interval}}.")
alertcondition(confirmedBuyAlert, "Pressure Buy [JOAT]", "Confirmed order pressure buy on {{ticker}} {{interval}}.")
alertcondition(confirmedSellAlert, "Pressure Sell [JOAT]", "Confirmed order pressure sell on {{ticker}} {{interval}}.")

var table gauge = table.new(position.top_right, 3, 3, frame_color = color.new(neutralColor, 45), border_color = color.new(neutralColor, 70), border_width = 1)
if gaugeInput and barstate.islast
    stateText = strength > signalLevelInput ? "Bull Pressure" : strength < -signalLevelInput ? "Bear Pressure" : "Balanced"
    biasText = close > basis ? "Above Basis" : close < basis ? "Below Basis" : "At Basis"
    table.cell(gauge, 0, 0, "Pressure", bgcolor = color.new(neutralColor, 80), text_color = chart.fg_color, text_size = size.small)
    table.cell(gauge, 1, 0, pressureText, bgcolor = fade(strengthColor, absStrength, 86, 54), text_color = chart.fg_color, text_size = size.small)
    table.cell(gauge, 2, 0, stateText, bgcolor = cloudColor, text_color = chart.fg_color, text_size = size.small)
    table.cell(gauge, 0, 1, "Volume", bgcolor = color.new(neutralColor, 80), text_color = chart.fg_color, text_size = size.small)
    table.cell(gauge, 1, 1, pulseText, bgcolor = color.new(neutralColor, 84), text_color = chart.fg_color, text_size = size.small)
    table.cell(gauge, 2, 1, biasText, bgcolor = color.new(neutralColor, 84), text_color = chart.fg_color, text_size = size.small)
    table.cell(gauge, 0, 2, "Cloud", bgcolor = color.new(neutralColor, 80), text_color = chart.fg_color, text_size = size.small)
    table.cell(gauge, 1, 2, str.tostring(cloudScale, "#.##") + "x", bgcolor = color.new(neutralColor, 84), text_color = chart.fg_color, text_size = size.small)
    table.cell(gauge, 2, 2, bullPressure ? "Bull Shift" : bearPressure ? "Bear Shift" : "Tracking", bgcolor = color.new(neutralColor, 84), text_color = chart.fg_color, text_size = size.small)
````
