# Dealer Gamma Pressure Map

- url: https://www.tradingview.com/script/OH5gyyxH-Dealer-Gamma-Pressure-Map/
- type: indicator
- pine_id: PUB;8151daa41a3b4f1e92b640442aa3c9b2
- version: 1.0

## Description

[b]Dealer Gamma Pressure Map [/b]
[b]The Philosophy[/b]
In modern markets, price action isn’t just driven by retail sentiment; it’s driven by the hedging requirements of options dealers. When price crosses certain thresholds, dealers must buy or sell the underlying asset to remain delta-neutral, creating a feedback loop known as a Gamma Squeeze.

The Dealer Gamma Pressure Map was designed to solve the primary challenge of trading these environments: distinguishing between a high-probability "Squeeze" and a "Fakeout" mean-reversion.

[b]Pine Script Challenges[/b]
Building this tool in Pine Script presented three significant technical hurdles that I had to architect around to ensure professional-grade stability:

[b]The Table "Out of Bounds" Trap:[/b] Many dashboard indicators crash when users change settings because Pine Script® tables don't always resize gracefully in real-time. I implemented a fixed-buffer initialization (50 columns) with a safe-access logic layer. This ensures that whether your lookback is 5 or 40, the dashboard remains stable and error-free.
[b]MTF Integrity:[/b] To provide institutional context, this script anchors to a Higher Timeframe (HTF) Flip. Handling MTF data in Pine is notoriously prone to "Repainting." I’ve used a strict [1] offset on security calls to ensure the data you see is historically accurate and never looks ahead into the future.
[b]The Noise Problem:[/b] Gamma data is inherently jittery. To solve this, I developed the "Goldilocks Engine"—a signal logic that balances RSI exhaustion, Gamma Velocity, and Volume Confluence. This filters out the "market noise" that often triggers false signals in lower-tier indicators.
[b]Mathematical Core:[/b]
For ease of reading and transparency, here is the logic driving your chart:

[b]1. Gamma Flip Level (The Gravity Center)[/b]
The Flip is the zero-point where dealer positioning shifts from Long to Short.

Formula: GF_Level = EMA(VWMA(Close, Length), Smoothing)

[b]2. Gamma Exposure Score (Normalized Distance)[/b]
We don't just measure distance; we normalize it by volatility (ATR or StDev) so the indicator works identically on a 1-minute chart or a Daily chart.

Formula: Gamma_Score = (Price - GF_Level) / Volatility

[b]3. Gamma Velocity (Acceleration)[/b]
This measures the rate of change in exposure to identify when a squeeze is building momentum.

Formula: Velocity = Gamma_Score - Gamma_Score[1]

[b]Understanding the Engine[/b]
[b]Breakout Signals (B / S):[/b] These require "The Perfect Storm." Price must be in the Negative Gamma zone, ADX must show a strong trend, and volume must be 1.2x the recent average.
[b]Reversal Signals (R):[/b] These are the strictest signals. Price must have overextended into extreme dealer "Acceleration" zones and then definitively crossed back while RSI shows momentum exhaustion (38/62).
[b]Fade Signals (F):[/b] These are Bollinger-style mean reversion plays. They identify "Failed Breakouts" where price tests the extreme dealer boundaries but lacks the institutional volume to sustain a squeeze.
[b]Visual Dashboard & Professional Themes[/b]
This script is built for the "Clean Chart" enthusiast. The dashboard is proportionally scaled—meaning if you change the text size from Tiny to Normal, the entire UI grows with it to maintain visual balance.

I have included 10 Hand-Crafted Visual Templates to ensure the map matches your personal trading workspace perfectly.

[b]How to Trade This[/b]
Positive Gamma (Blue Zone): Look for Fades (F) and mean-reversion back to the midline.
Negative Gamma (Red/Green Outer Zones): Look for high-velocity Breakouts (B/S).
Regime Shift: When price crosses the Flip Level (Midline), expect a transition in market volatility.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Dealer Gamma Pressure Map", shorttitle="Gamma Map", overlay = true, max_labels_count = 500)

groupMain = "Main Settings"
infoMain = input.bool(true, "Show Logic Info?", group = groupMain, tooltip = "Logic Summary: This indicator calculates the 'Gamma Flip' level using a Volatility-Adjusted VWMA. When price is near this level, Gamma is Positive (Mean Reverting). As price moves away, Gamma becomes Negative (Trend Accelerating). The Sniper Engine uses ADX and Volatility to identify Breakouts (B), Reversals (R), and Fades (F).")
lengthInput = input.int(50, "Lookback Length", minval = 5, group = groupMain, tooltip = "The period used for the Gamma Flip Level and volatility calculations. This defines the 'gravity' of the indicator.")
multInput   = input.float(2.0, "Volatility Multiplier", minval = 0.1, step = 0.1, group = groupMain, tooltip = "Determines the width of the Gamma Zones. Higher values create wider zones and more stringent breakout requirements.")
smoothInput = input.int(5, "Smoothing", minval = 1, group = groupMain, tooltip = "Smoothing applied to the Gamma Flip line to reduce noise.")

groupMTF = "MTF Settings"
infoMTF = input.bool(true, "Show MTF Info?", group = groupMTF, tooltip = "MTF Summary: Anchoring the Gamma Flip to a Higher Timeframe (HTF) helps identify institutional 'Gravity' levels. Traders use this to ensure they aren't fighting a larger structural trend.")
useMTF = input.bool(false, "Use Higher Timeframe Flip?", group = groupMTF, tooltip = "When enabled, the Gamma Flip Level is anchored to a higher timeframe for structural context.")
tfInput = input.timeframe("D", "Higher Timeframe", group = groupMTF, tooltip = "The timeframe to use for MTF calculations (e.g., 'D' for Daily structural levels).")

groupVol = "Volatility & Sniper Logic"
infoSniper = input.bool(true, "Show Sniper Info?", group = groupVol, tooltip = "Sniper Summary:\n- Buy/Sell (B/S): High-conviction momentum signals. Requires Trending ADX + Gamma Acceleration + Volume Confluence.\n- Reversal (R): Exhaustion Catching. Now in the 'Goldilocks' zone—requires price extreme + cross-back + RSI exhaustion.\n- Fade (F): Mean-reversion signals for range-bound markets. Triggered at Gamma Extremes when ADX is low.")
useATR = input.bool(true, "Use ATR for Zone Scaling", group = groupVol, tooltip = "Switches from Standard Deviation to Average True Range for zone calculations, making them more adaptive to recent price range.")
atrLength = input.int(14, "ATR Period", group = groupVol, tooltip = "The period used for the ATR calculation.")
adxThreshold = input.int(25, "ADX Filter (Trend Strength)", minval = 1, group = groupVol, tooltip = "Prevents B/S signals in low-trend/consolidation environments. Signals only appear when ADX is above this value.")
cooldownInput = input.int(10, "Signal Cooldown (Bars)", minval = 1, group = groupVol, tooltip = "Minimum bars that must pass before the same signal type can trigger again.")
rsiLength = input.int(14, "RSI Strictness Filter", minval = 1, group = groupVol, tooltip = "Used to add exhaustion filters to Reversal and Fade signals.")

groupDashboard = "Dashboard Customization"
infoDash = input.bool(true, "Show Dashboard Info?", group = groupDashboard, tooltip = "Dashboard Summary:\n- Box 1 (Exposure): Real-time distance from Flip. Positive = Mean Reversion, Negative = Acceleration.\n- Box 2 (Velocity): Rate of change in Gamma. High velocity = incoming volatility.\n- Box 3 (Trend): Cumulative Gamma Momentum. Shows if Gamma pressure is building or dissipating over time.")
dashLookback = input.int(20, "Visual Plot Lookback", minval = 5, maxval = 40, group = groupDashboard, tooltip = "Number of historical bars to display in the Gamma charts. Reducing this makes the dashboard narrower.")
dashPos = input.string(position.top_right, "Dashboard Position", options = [position.top_right, position.bottom_right, position.top_left, position.bottom_left], group = groupDashboard, tooltip = "Determines where the dashboard sits on your chart.")
dashScale = input.string(size.tiny, "Dashboard Text Size", options = [size.tiny, size.small, size.normal], group = groupDashboard, tooltip = "Adjusts the text size inside the dashboard cells.")
dashWidth = input.float(1.2, "Chart Column Width (%)", minval = 0.1, step = 0.1, group = groupDashboard, tooltip = "The width of each histogram column. Lower = narrower dashboard.")
dashHeight = input.float(0.8, "Chart Row Height (%)", minval = 0.1, step = 0.1, group = groupDashboard, tooltip = "The height of each histogram row. Lower = shorter dashboard.")
dashBgColor = input.color(color.new(#000000, 10), "Dashboard Background", group = groupDashboard, tooltip = "Background color for the entire dashboard table.")
dashBorderColor = input.color(color.new(#787b86, 80), "Dashboard Borders", group = groupDashboard, tooltip = "Color for cell borders.")
showZones     = input.bool(true, "Show Pressure Map Zones", group = groupDashboard, tooltip = "Toggles the colorful gradient fills on the chart.")
showSignals = input.bool(true, "Show B/S/R/F Signals", group = groupDashboard, tooltip = "Toggles the Sniper Signal labels (Buy, Sell, Reversal, Fade).")

groupStyle = "Visual Styles & Templates"
themeInput = input.string("Classic", "Color Template", options = ["Classic", "Cyberpunk", "Monochrome", "Sunset", "Ocean", "Forest", "Volcanic", "Midnight", "Minimalist", "Signature", "Custom"], group = groupStyle, tooltip = "Select a pre-defined color theme. Choose 'Custom' to use the manual colors below.")
c_pos = input.color(#089981, "Custom Pos. Gamma", group = groupStyle)
c_neg = input.color(#f23645, "Custom Neg. Gamma", group = groupStyle)
c_neu = input.color(#5b9cf6, "Custom Flip Color", group = groupStyle)
c_buy = input.color(#089981, "Custom Buy Color", group = groupStyle)
c_sel = input.color(#f23645, "Custom Sell Color", group = groupStyle)
c_rev = input.color(#5b9cf6, "Custom Rev. Color", group = groupStyle)
c_fad = input.color(#787b86, "Custom Fade Color", group = groupStyle)

color posGammaColor = switch themeInput
    "Cyberpunk"     => #ff00ff
    "Monochrome"    => #ffffff
    "Sunset"        => #ff9800
    "Ocean"         => #00bcd4
    "Forest"        => #4caf50
    "Volcanic"      => #ff5722
    "Midnight"      => #ffd700
    "Minimalist"    => #787b86
    "Signature" => #00e676
    "Custom"        => c_pos
    => #089981 

color negGammaColor = switch themeInput
    "Cyberpunk"     => #00ffff
    "Monochrome"    => #434651
    "Sunset"        => #9c27b0
    "Ocean"         => #3f51b5
    "Forest"        => #795548
    "Volcanic"      => #212121
    "Midnight"      => #000080
    "Minimalist"    => #787b86
    "Signature" => #ff5252
    "Custom"        => c_neg
    => #f23645

color neutralColor = switch themeInput
    "Cyberpunk"     => #ffffff
    "Monochrome"    => #787b86
    "Sunset"        => #f44336
    "Ocean"         => #009688
    "Forest"        => #8bc34a
    "Volcanic"      => #f44336
    "Midnight"      => #191970
    "Minimalist"    => #ffffff
    "Signature" => #2962ff
    "Custom"        => c_neu
    => #5b9cf6

color buyColor = switch themeInput
    "Custom" => c_buy
    => posGammaColor

color sellColor = switch themeInput
    "Custom" => c_sel
    => negGammaColor

color revColor = switch themeInput
    "Custom" => c_rev
    => neutralColor

color fadeColor = switch themeInput
    "Custom" => c_fad
    => #787b86

rsi = ta.rsi(close, rsiLength)
volumeAvg = ta.sma(volume, 20)
highVol = volume > volumeAvg * 1.2

[plusDI, minusDI, adx] = ta.dmi(14, 14)
isTrending = adx > adxThreshold
isChoppy   = adx < 20 

vwma_raw = ta.vwma(close, lengthInput)
mtfFlip  = request.security(syminfo.tickerid, tfInput, vwma_raw[1], lookahead = barmerge.lookahead_on)
flipLevelRaw = useMTF ? mtfFlip : vwma_raw
flipLevel    = ta.ema(flipLevelRaw, smoothInput)

atrVal = ta.atr(atrLength)
stdevVal = ta.stdev(close, lengthInput)
volBase = useATR ? atrVal : stdevVal
vol = nz(volBase) == 0 ? stdevVal : volBase

upperZone = flipLevel + vol * (multInput / 2)
lowerZone = flipLevel - vol * (multInput / 2)
upperAccel = flipLevel + vol * multInput
lowerAccel = flipLevel - vol * multInput

float gammaExposure = (close - flipLevel) / vol
gammaVel = ta.change(gammaExposure)
gammaTrend = ta.ema(gammaExposure, 10) 

high10 = ta.highest(high[1], 10)
low10  = ta.lowest(low[1], 10)
high8  = ta.highest(high, 8)
low8   = ta.lowest(low, 8)
high3  = ta.highest(high, 3)
low3   = ta.lowest(low, 3)

breakoutHigh = ta.crossover(close, high10)
breakoutLow  = ta.crossunder(close, low10)

isB_raw = isTrending and breakoutHigh and close > upperZone and gammaVel > 0 and highVol
isS_raw = isTrending and breakoutLow and close < lowerZone and gammaVel < 0 and highVol

rsiOS = rsi < 38
rsiOB = rsi > 62
crossBackBull = ta.crossover(close, lowerAccel)
crossBackBear = ta.crossunder(close, upperAccel)
isR_Bull_raw = low8 < lowerAccel and crossBackBull and gammaVel > 0 and rsiOS
isR_Bear_raw = high8 > upperAccel and crossBackBear and gammaVel < 0 and rsiOB

crossUnderUpper = ta.crossunder(close, upperZone)
crossOverLower = ta.crossover(close, lowerZone)
isF_Top_raw = isChoppy and high3 >= upperAccel and crossUnderUpper and gammaVel < 0
isF_Bot_raw = isChoppy and low3 <= lowerAccel and crossOverLower and gammaVel > 0

var int lastB = 0, var int lastS = 0, var int lastR = 0, var int lastF = 0
bool isB = false, bool isS = false, bool isR_Bull = false, bool isR_Bear = false, bool isF_Top = false, bool isF_Bot = false

if isB_raw and bar_index - lastB >= cooldownInput
    isB := true, lastB := bar_index
if isS_raw and bar_index - lastS >= cooldownInput
    isS := true, lastS := bar_index
if (isR_Bull_raw or isR_Bear_raw) and bar_index - lastR >= cooldownInput
    isR_Bull := isR_Bull_raw, isR_Bear := isR_Bear_raw, lastR := bar_index
if (isF_Top_raw or isF_Bot_raw) and bar_index - lastF >= cooldownInput
    isF_Top := isF_Top_raw, isF_Bot := isF_Bot_raw, lastF := bar_index

regime = math.abs(gammaExposure) < (multInput / 2) ? "Pos. Gamma" : math.abs(gammaExposure) > multInput ? "Neg. Gamma" : "Flip"
regimeColor = math.abs(gammaExposure) < (multInput / 2) ? posGammaColor : math.abs(gammaExposure) > multInput ? negGammaColor : neutralColor

plot(flipLevel, "Gamma Flip", color.new(regimeColor, 0), 2)

p1 = plot(upperAccel, "Upper Acceleration", color.new(negGammaColor, 100))
p2 = plot(upperZone, "Upper Flip Bound", color.new(neutralColor, 100))
p3 = plot(flipLevel, "Flip Center", color.new(neutralColor, 100))
p4 = plot(lowerZone, "Lower Flip Bound", color.new(neutralColor, 100))
p5 = plot(lowerAccel, "Lower Acceleration", color.new(negGammaColor, 100))

fill(p2, p3, top_value = upperZone, bottom_value = flipLevel, top_color = showZones ? color.new(posGammaColor, 90) : na, bottom_color = showZones ? color.new(posGammaColor, 70) : na, title = "Positive Gamma Upper")
fill(p3, p4, top_value = flipLevel, bottom_value = lowerZone, top_color = showZones ? color.new(posGammaColor, 70) : na, bottom_color = showZones ? color.new(posGammaColor, 90) : na, title = "Positive Gamma Lower")
fill(p1, p2, top_value = upperAccel, bottom_value = upperZone, top_color = showZones ? color.new(negGammaColor, 70) : na, bottom_color = showZones ? color.new(negGammaColor, 90) : na, title = "Negative Gamma Upper")
fill(p4, p5, top_value = lowerZone, bottom_value = lowerAccel, top_color = showZones ? color.new(negGammaColor, 90) : na, bottom_color = showZones ? color.new(negGammaColor, 70) : na, title = "Negative Gamma Lower")

plotshape(showSignals and isB, "Buy Signal", style = shape.labelup, location = location.belowbar, color = buyColor, text = "B", textcolor = color.white, size = size.tiny)
plotshape(showSignals and isS, "Sell Signal", style = shape.labeldown, location = location.abovebar, color = sellColor, text = "S", textcolor = color.white, size = size.tiny)
plotshape(showSignals and (isR_Bull or isR_Bear), "Reversal Signal", style = shape.labelup, location = location.belowbar, color = revColor, text = "R", textcolor = color.white, size = size.tiny)
plotshape(showSignals and (isF_Top or isF_Bot), "Fade Signal", style = shape.labeldown, location = location.abovebar, color = fadeColor, text = "F", textcolor = color.white, size = size.tiny)

var table dashTable = table.new(dashPos, 50, 26, bgcolor = dashBgColor, border_width = 1, border_color = dashBorderColor)

if barstate.islast
    float scaleMult = dashScale == size.tiny ? 1.0 : dashScale == size.small ? 1.3 : 1.6
    float fWidth = dashWidth * scaleMult
    float fHeight = dashHeight * scaleMult
    int mid = math.floor(dashLookback / 2)
    
    int safeLookback = math.min(dashLookback, 50)
    
    table.merge_cells(dashTable, 0, 5, safeLookback - 1, 5) 
    table.merge_cells(dashTable, 0, 11, safeLookback - 1, 11)
    table.merge_cells(dashTable, 0, 17, safeLookback - 1, 17)

    table.merge_cells(dashTable, 0, 0, mid - 1, 0), table.merge_cells(dashTable, mid, 0, safeLookback - 1, 0)
    table.cell(dashTable, 0, 0, "Regime", text_color = chart.fg_color, text_size = dashScale, bgcolor = color.new(chart.bg_color, 10), width = fWidth * mid, height = fHeight)
    table.cell(dashTable, mid, 0, regime, text_color = regimeColor, text_size = dashScale, bgcolor = color.new(chart.bg_color, 10), width = fWidth * mid, height = fHeight)
    
    table.merge_cells(dashTable, 0, 1, mid - 1, 1), table.merge_cells(dashTable, mid, 1, safeLookback - 1, 1)
    table.cell(dashTable, 0, 1, "Trend", text_color = chart.fg_color, text_size = dashScale, bgcolor = color.new(chart.bg_color, 10), width = fWidth * mid, height = fHeight)
    table.cell(dashTable, mid, 1, isTrending ? "Trending" : "Chop", text_color = isTrending ? posGammaColor : fadeColor, text_size = dashScale, bgcolor = color.new(chart.bg_color, 10), width = fWidth * mid, height = fHeight)

    table.merge_cells(dashTable, 0, 2, mid - 1, 2), table.merge_cells(dashTable, mid, 2, safeLookback - 1, 2)
    table.cell(dashTable, 0, 2, "Score", text_color = chart.fg_color, text_size = dashScale, bgcolor = color.new(chart.bg_color, 10), width = fWidth * mid, height = fHeight)
    table.cell(dashTable, mid, 2, str.tostring(gammaExposure, "#.##"), text_color = chart.fg_color, text_size = dashScale, bgcolor = color.new(chart.bg_color, 10), width = fWidth * mid, height = fHeight)

    table.merge_cells(dashTable, 0, 3, mid - 1, 3), table.merge_cells(dashTable, mid, 3, safeLookback - 1, 3)
    table.cell(dashTable, 0, 3, "Velocity", text_color = chart.fg_color, text_size = dashScale, bgcolor = color.new(chart.bg_color, 10), width = fWidth * mid, height = fHeight)
    table.cell(dashTable, mid, 3, gammaVel > 0 ? "Accel" : "Decel", text_color = gammaVel > 0 ? posGammaColor : negGammaColor, text_size = dashScale, bgcolor = color.new(chart.bg_color, 10), width = fWidth * mid, height = fHeight)

    table.merge_cells(dashTable, 0, 4, mid - 1, 4), table.merge_cells(dashTable, mid, 4, safeLookback - 1, 4)
    table.cell(dashTable, 0, 4, "MTF", text_color = chart.fg_color, text_size = dashScale, bgcolor = color.new(chart.bg_color, 10), width = fWidth * mid, height = fHeight)
    table.cell(dashTable, mid, 4, useMTF ? tfInput : "Off", text_color = neutralColor, text_size = dashScale, bgcolor = color.new(chart.bg_color, 10), width = fWidth * mid, height = fHeight)
    
    table.cell(dashTable, 0, 5, "Gamma Exposure Map", text_color = color.gray, text_size = size.tiny, bgcolor = color.new(chart.bg_color, 0))
    for i = 0 to safeLookback - 1
        float val = nz(gammaExposure[safeLookback - 1 - i])
        for r = 6 to 10
            color c = color.new(chart.bg_color, 100)
            int fCount = math.min(2, math.ceil(math.abs(val) * 2))
            if val >= 0 and r <= 8 and r >= (8 - fCount)
                c := color.new(posGammaColor, 30)
            else if val < 0 and r >= 8 and r <= (8 + fCount)
                c := color.new(negGammaColor, 30)
            if r == 8 and c == color.new(chart.bg_color, 100)
                c := color.new(neutralColor, 80)
            table.cell(dashTable, i, r, "", bgcolor = c, width = fWidth, height = fHeight)

    table.cell(dashTable, 0, 11, "Pressure Velocity", text_color = color.gray, text_size = size.tiny, bgcolor = color.new(chart.bg_color, 0))
    for i = 0 to safeLookback - 1
        float val = nz(gammaVel[safeLookback - 1 - i])
        for r = 12 to 16
            color c = color.new(chart.bg_color, 100)
            int fCount = math.min(2, math.ceil(math.abs(val) * 6))
            if val >= 0 and r <= 14 and r >= (14 - fCount)
                c := color.new(posGammaColor, 50)
            else if val < 0 and r >= 14 and r <= (14 + fCount)
                c := color.new(negGammaColor, 50)
            table.cell(dashTable, i, r, "", bgcolor = c, width = fWidth, height = fHeight)

    table.cell(dashTable, 0, 17, "Trend Momentum", text_color = color.gray, text_size = size.tiny, bgcolor = color.new(chart.bg_color, 0))
    for i = 0 to safeLookback - 1
        float val = nz(gammaTrend[safeLookback - 1 - i])
        for r = 18 to 22
            color c = color.new(chart.bg_color, 100)
            int fCount = math.min(2, math.ceil(math.abs(val) * 2.5))
            if val >= 0 and r <= 20 and r >= (20 - fCount)
                c := color.new(posGammaColor, 10)
            else if val < 0 and r >= 20 and r <= (20 + fCount)
                c := color.new(negGammaColor, 10)
            table.cell(dashTable, i, r, "", bgcolor = c, width = fWidth, height = fHeight)

bgcolor(math.abs(gammaExposure) > multInput ? color.new(negGammaColor, 95) : na, title = "Acceleration Background")

alertcondition(isB or isS, "Sniper: Continuation", "High-confidence gamma acceleration detected.")
alertcondition(isR_Bull or isR_Bear, "Sniper: Reversal", "Gamma exhaustion reversal detected.")
alertcondition(isF_Top or isF_Bot, "Sniper: Fade", "Range-bound gamma pinning fade detected.")
````
