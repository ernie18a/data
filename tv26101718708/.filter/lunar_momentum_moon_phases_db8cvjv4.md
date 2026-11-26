# Lunar Momentum (Moon Phases)

- url: https://www.tradingview.com/script/Db8CVjv4-Lunar-Momentum-Moon-Phases/
- type: indicator
- pine_id: PUB;8651b8ac50c9463eabdfc4467deb9b16
- version: 1.0

## Description

Moon Phases Market Indicator 🌙📈

This indicator tracks the phases of the moon and compares them to market behavior to help traders spot potential bullish and bearish momentum shifts. It’s based on the idea that market psychology moves in cycles — just like the moon.

How It Works
New Moon 🌑
Often signals a market reset or fresh momentum. Traders commonly watch this phase for potential bullish reversals, trend beginnings, or accumulation zones.
Waxing Moon 🌒🌓🌔
As the moon grows brighter, market momentum can begin building. This phase is often associated with increasing strength, confidence, and bullish continuation.
Full Moon 🌕
The market tends to reach emotional extremes during full moons. This can lead to increased volatility, profit-taking, trend exhaustion, or bearish reversals.
Waning Moon 🌖🌗🌘
As the moon fades, momentum may weaken. Traders often associate this phase with slowing trends, pullbacks, consolidation, or bearish pressure.
Why Traders Use It

This indicator is not meant to predict the future like magic — it’s designed to help visualize market cycles, trader emotion, and momentum timing in a simple way. Many traders believe human psychology and market behavior naturally move in repeating patterns, and the lunar cycle can sometimes align surprisingly well with those shifts.

Bullish vs Bearish Interpretation
🌑 New Moon = Potential Bullish Energy
🌕 Full Moon = Potential Bearish or Reversal Energy
🌒 Waxing phases = Growing momentum
🌘 Waning phases = Weakening momentum
Simple Explanation

Think of the moon like a market mood tracker:

When the moon is growing → the market often gains energy.
When the moon is full → emotions peak and reversals can happen.
When the moon fades → momentum can slow down.

This gives traders another layer of confirmation alongside price action, volume, support/resistance, and trend analysis.

Best Used For
Swing Trading
Crypto Markets
Forex
Indexes
Market Cycle Analysis
Identifying possible reversal zones

⚠️ This indicator works best when combined with technical analysis and risk management — not as a standalone buy or sell signal.

## Source Code

````pine
//@version=6
// Lunar Momentum Confluence
// A moon-phase themed TradingView overlay that only acts when lunar bias and price momentum align.

indicator(
    title            = "Lunar Momentum Confluence",
    shorttitle       = "LunarMC",
    overlay          = true,
    max_labels_count = 500,
    max_lines_count  = 50,
    max_boxes_count  = 50,
    max_bars_back    = 5000)

GRP_MAIN   = "Main Settings"
GRP_LUNAR  = "Lunar Engine"
GRP_MOMO   = "Momentum Engine"
GRP_SIGNAL = "Signal Engine"
GRP_RISK   = "Risk Model"
GRP_VISUAL = "Visuals"
GRP_COLOR  = "Colors"

sourceInput = input.source(close, "Source", group = GRP_MAIN)
directionInput = input.string("Both", "Direction", options = ["Both", "Long Only", "Short Only"], group = GRP_MAIN)
useHtfFilterInput = input.bool(true, "Use Higher Timeframe Filter", group = GRP_MAIN)
htfInput = input.timeframe("240", "Higher Timeframe", group = GRP_MAIN)

lunarBiasThresholdInput = input.float(0.18, "Lunar Bias Threshold", minval = 0.0, maxval = 0.95, step = 0.01, group = GRP_LUNAR, tooltip = "Higher values demand stronger waxing or waning pressure before entries are allowed.")
moonLabelOffsetAtrInput = input.float(0.85, "Moon Label Offset ATR", minval = 0.1, maxval = 4.0, step = 0.05, group = GRP_LUNAR)
moonMarkerModeInput = input.string("All 8 Phases", "Moon Marker Mode", options = ["All 8 Phases", "Key Phases Only"], group = GRP_LUNAR)
showQuarterMoonLabelsInput = input.bool(true, "Show Quarter Moons", group = GRP_LUNAR, tooltip = "When off, only new and full moon markers are printed.")

fastLenInput = input.int(13, "Fast EMA Length", minval = 3, maxval = 100, group = GRP_MOMO)
slowLenInput = input.int(34, "Slow EMA Length", minval = 5, maxval = 200, group = GRP_MOMO)
trendLenInput = input.int(89, "Trend EMA Length", minval = 20, maxval = 300, group = GRP_MOMO)
rsiLenInput = input.int(14, "RSI Length", minval = 5, maxval = 50, group = GRP_MOMO)
atrLenInput = input.int(14, "ATR Length", minval = 5, maxval = 50, group = GRP_MOMO)
volumeLenInput = input.int(20, "Relative Volume Length", minval = 5, maxval = 100, group = GRP_MOMO)
relVolThresholdInput = input.float(1.05, "Relative Volume Threshold", minval = 0.5, maxval = 5.0, step = 0.05, group = GRP_MOMO)
bullRsiThresholdInput = input.int(56, "Bull RSI Threshold", minval = 45, maxval = 80, group = GRP_MOMO)
bearRsiThresholdInput = input.int(44, "Bear RSI Threshold", minval = 20, maxval = 55, group = GRP_MOMO)

breakoutLookbackInput = input.int(5, "Breakout Lookback", minval = 2, maxval = 50, group = GRP_SIGNAL)
pullbackLookbackInput = input.int(4, "Pullback Lookback", minval = 1, maxval = 20, group = GRP_SIGNAL)
minMomentumScoreInput = input.int(63, "Minimum Momentum Score", minval = 40, maxval = 95, group = GRP_SIGNAL)
minConfluenceScoreInput = input.int(70, "Minimum Confluence Score", minval = 45, maxval = 100, group = GRP_SIGNAL)
cooldownBarsInput = input.int(8, "Cooldown Bars", minval = 0, maxval = 100, group = GRP_SIGNAL)

swingLenInput = input.int(8, "Swing Length", minval = 3, maxval = 50, group = GRP_RISK)
atrBufferInput = input.float(0.6, "ATR Stop Buffer", minval = 0.1, maxval = 5.0, step = 0.05, group = GRP_RISK)
tp1RRInput = input.float(1.5, "Target 1 R-Multiple", minval = 0.5, maxval = 10.0, step = 0.1, group = GRP_RISK)
tp2RRInput = input.float(2.6, "Target 2 R-Multiple", minval = 1.0, maxval = 15.0, step = 0.1, group = GRP_RISK)

showSignalsInput = input.bool(true, "Show Long/Short Labels", group = GRP_VISUAL)
showMoonGraphicsInput = input.bool(true, "Show Moon Graphics", group = GRP_VISUAL)
showRibbonInput = input.bool(true, "Show EMA Ribbon", group = GRP_VISUAL)
showVwapInput = input.bool(true, "Show VWAP", group = GRP_VISUAL)
showBiasBgInput = input.bool(true, "Show Lunar Bias Background", group = GRP_VISUAL)
showDashboardInput = input.bool(true, "Show Dashboard", group = GRP_VISUAL)
showRiskLevelsInput = input.bool(true, "Show Active Entry / Stop / Targets", group = GRP_VISUAL)
signalSizeInput = input.string("Small", "Signal Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_VISUAL)

bullColorInput = input.color(#00C853, "Bull", inline = "c1", group = GRP_COLOR)
bearColorInput = input.color(#FF3D00, "Bear", inline = "c1", group = GRP_COLOR)
neutralColorInput = input.color(#FFD54F, "Neutral", inline = "c1", group = GRP_COLOR)

f_boolScore(_condition, _weight) =>
    _condition ? _weight : 0.0

f_clamp(_value, _low, _high) =>
    math.max(_low, math.min(_value, _high))

f_grade(_score) =>
    _score >= 88 ? "A" : _score >= 78 ? "B" : _score >= 68 ? "C" : "Watch"

f_phaseName(_phase) =>
    switch _phase
        0 => "New Moon"
        1 => "Waxing Crescent"
        2 => "First Quarter"
        3 => "Waxing Gibbous"
        4 => "Full Moon"
        5 => "Waning Gibbous"
        6 => "Last Quarter"
        => "Waning Crescent"

f_phaseEmoji(_phase) =>
    switch _phase
        0 => "🌑"
        1 => "🌒"
        2 => "🌓"
        3 => "🌔"
        4 => "🌕"
        5 => "🌖"
        6 => "🌗"
        => "🌘"

f_size(_name) =>
    switch _name
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        => size.normal

f_addRow(_table, _row, _name, _value, _nameBg, _valueBg, _valueColor, _size) =>
    table.cell(_table, 0, _row, _name, bgcolor = _nameBg, text_color = color.white, text_size = _size, text_halign = text.align_left)
    table.cell(_table, 1, _row, _value, bgcolor = _valueBg, text_color = _valueColor, text_size = _size, text_halign = text.align_right)

signalLabelSize = f_size(signalSizeInput)

fastEma = ta.ema(sourceInput, fastLenInput)
slowEma = ta.ema(sourceInput, slowLenInput)
trendEma = ta.ema(sourceInput, trendLenInput)
sessionVwap = ta.vwap(hlc3)
atr = ta.atr(atrLenInput)
rsi = ta.rsi(sourceInput, rsiLenInput)
macdLine = ta.ema(sourceInput, 12) - ta.ema(sourceInput, 26)
macdSignal = ta.ema(macdLine, 9)
macdHist = macdLine - macdSignal
relVol = volume / math.max(ta.sma(volume, volumeLenInput), 1.0)
barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
closeLocation = (close - low) / barRange
bearCloseLocation = (high - close) / barRange

htfClose = request.security(syminfo.tickerid, htfInput, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFast = request.security(syminfo.tickerid, htfInput, ta.ema(close, fastLenInput), barmerge.gaps_off, barmerge.lookahead_off)
htfSlow = request.security(syminfo.tickerid, htfInput, ta.ema(close, slowLenInput), barmerge.gaps_off, barmerge.lookahead_off)
htfTrend = request.security(syminfo.tickerid, htfInput, ta.ema(close, trendLenInput), barmerge.gaps_off, barmerge.lookahead_off)

htfBull = htfClose > htfTrend and htfFast > htfSlow
htfBear = htfClose < htfTrend and htfFast < htfSlow

MS_PER_DAY = 86400000.0
JULIAN_UNIX_EPOCH = 2440587.5
SYNODIC_MONTH = 29.530588853
KNOWN_NEW_MOON_JD = 2451550.1
TAU = math.pi * 2.0

julianDay = time / MS_PER_DAY + JULIAN_UNIX_EPOCH
moonAgeRaw = (julianDay - KNOWN_NEW_MOON_JD) % SYNODIC_MONTH
moonAge = moonAgeRaw < 0 ? moonAgeRaw + SYNODIC_MONTH : moonAgeRaw
phasePct = moonAge / SYNODIC_MONTH
illumination = 0.5 * (1.0 - math.cos(phasePct * TAU))
lunarMomentum = math.sin(phasePct * TAU)
lunarLongScore = math.max(lunarMomentum, 0.0) * 100.0
lunarShortScore = math.max(-lunarMomentum, 0.0) * 100.0
phaseBucket = int(math.floor((phasePct + 0.0625) * 8.0)) % 8
phaseChanged = phaseBucket != nz(phaseBucket[1], phaseBucket)
isNewMoon = phaseBucket == 0 and phaseChanged
isFirstQuarter = phaseBucket == 2 and phaseChanged
isFullMoon = phaseBucket == 4 and phaseChanged
isLastQuarter = phaseBucket == 6 and phaseChanged
isMajorMoon = isNewMoon or isFullMoon or (showQuarterMoonLabelsInput and (isFirstQuarter or isLastQuarter))
isMoonMarker = phaseChanged and (moonMarkerModeInput == "All 8 Phases" or isMajorMoon)

bullTrend = close > trendEma and fastEma > slowEma and fastEma > fastEma[1]
bearTrend = close < trendEma and fastEma < slowEma and fastEma < fastEma[1]
bullRsi = rsi >= bullRsiThresholdInput
bearRsi = rsi <= bearRsiThresholdInput
bullMacd = macdHist > 0 and macdHist >= macdHist[1]
bearMacd = macdHist < 0 and macdHist <= macdHist[1]
bullParticipation = relVol >= relVolThresholdInput and close > open and closeLocation >= 0.60 and bodySize >= atr * 0.22
bearParticipation = relVol >= relVolThresholdInput and close < open and bearCloseLocation >= 0.60 and bodySize >= atr * 0.22
bullVwap = close > sessionVwap
bearVwap = close < sessionVwap

float bullMomentumScore = 0.0
bullMomentumScore += f_boolScore(bullTrend, 24)
bullMomentumScore += f_boolScore(close > slowEma, 8)
bullMomentumScore += f_boolScore(bullRsi, 16)
bullMomentumScore += f_boolScore(rsi > bullRsiThresholdInput + 4, 5)
bullMomentumScore += f_boolScore(bullMacd, 16)
bullMomentumScore += f_boolScore(bullVwap, 10)
bullMomentumScore += f_boolScore(bullParticipation, 11)
bullMomentumScore += f_boolScore(not useHtfFilterInput or htfBull, 10)
bullMomentumScore := f_clamp(bullMomentumScore, 0.0, 100.0)

float bearMomentumScore = 0.0
bearMomentumScore += f_boolScore(bearTrend, 24)
bearMomentumScore += f_boolScore(close < slowEma, 8)
bearMomentumScore += f_boolScore(bearRsi, 16)
bearMomentumScore += f_boolScore(rsi < bearRsiThresholdInput - 4, 5)
bearMomentumScore += f_boolScore(bearMacd, 16)
bearMomentumScore += f_boolScore(bearVwap, 10)
bearMomentumScore += f_boolScore(bearParticipation, 11)
bearMomentumScore += f_boolScore(not useHtfFilterInput or htfBear, 10)
bearMomentumScore := f_clamp(bearMomentumScore, 0.0, 100.0)

longBreakout = close > ta.highest(high[1], breakoutLookbackInput) and close > open
shortBreakout = close < ta.lowest(low[1], breakoutLookbackInput) and close < open
longPullbackResume = ta.lowest(low, pullbackLookbackInput) <= fastEma and close > fastEma and close > open and close > close[1]
shortPullbackResume = ta.highest(high, pullbackLookbackInput) >= fastEma and close < fastEma and close < open and close < close[1]
longTrigger = longBreakout or longPullbackResume
shortTrigger = shortBreakout or shortPullbackResume

longPhaseBonus = (isNewMoon or isFirstQuarter) and lunarMomentum > 0 ? 5.0 : 0.0
shortPhaseBonus = (isFullMoon or isLastQuarter) and lunarMomentum < 0 ? 5.0 : 0.0
longConfluence = f_clamp(bullMomentumScore * 0.74 + lunarLongScore * 0.26 + longPhaseBonus, 0.0, 100.0)
shortConfluence = f_clamp(bearMomentumScore * 0.74 + lunarShortScore * 0.26 + shortPhaseBonus, 0.0, 100.0)

lunarLongReady = lunarMomentum > lunarBiasThresholdInput
lunarShortReady = lunarMomentum < -lunarBiasThresholdInput

var int lastLongBar = na
var int lastShortBar = na
canLong = na(lastLongBar) or bar_index - lastLongBar > cooldownBarsInput
canShort = na(lastShortBar) or bar_index - lastShortBar > cooldownBarsInput

longAllowed = directionInput != "Short Only"
shortAllowed = directionInput != "Long Only"

longSignal = barstate.isconfirmed and longAllowed and canLong and lunarLongReady and bullMomentumScore >= minMomentumScoreInput and longConfluence >= minConfluenceScoreInput and longTrigger and (not useHtfFilterInput or htfBull)
shortSignal = barstate.isconfirmed and shortAllowed and canShort and lunarShortReady and bearMomentumScore >= minMomentumScoreInput and shortConfluence >= minConfluenceScoreInput and shortTrigger and (not useHtfFilterInput or htfBear)

if longSignal
    lastLongBar := bar_index

if shortSignal
    lastShortBar := bar_index

longStop = ta.lowest(low, swingLenInput) - atr * atrBufferInput
shortStop = ta.highest(high, swingLenInput) + atr * atrBufferInput
longRisk = math.max(close - longStop, syminfo.mintick * 10)
shortRisk = math.max(shortStop - close, syminfo.mintick * 10)

var int activeDir = 0
var float activeEntry = na
var float activeStop = na
var float activeTp1 = na
var float activeTp2 = na

if longSignal
    activeDir := 1
    activeEntry := close
    activeStop := longStop
    activeTp1 := close + longRisk * tp1RRInput
    activeTp2 := close + longRisk * tp2RRInput

if shortSignal
    activeDir := -1
    activeEntry := close
    activeStop := shortStop
    activeTp1 := close - shortRisk * tp1RRInput
    activeTp2 := close - shortRisk * tp2RRInput

longExit = activeDir == 1 and (low <= activeStop or high >= activeTp2 or shortSignal)
shortExit = activeDir == -1 and (high >= activeStop or low <= activeTp2 or longSignal)

if longExit or shortExit
    activeDir := 0
    activeEntry := na
    activeStop := na
    activeTp1 := na
    activeTp2 := na

phaseName = f_phaseName(phaseBucket)
phaseEmoji = f_phaseEmoji(phaseBucket)
longGrade = f_grade(longConfluence)
shortGrade = f_grade(shortConfluence)

if showMoonGraphicsInput and isMoonMarker
    moonColor = isNewMoon ? color.new(#455A64, 0) : isFullMoon ? color.new(#FFF59D, 0) : lunarMomentum >= 0 ? color.new(#26A69A, 0) : color.new(#EF5350, 0)
    moonTextColor = isFullMoon ? color.black : color.white
    moonY = lunarMomentum >= 0 ? low - atr * moonLabelOffsetAtrInput : high + atr * moonLabelOffsetAtrInput
    moonStyle = lunarMomentum >= 0 ? label.style_label_up : label.style_label_down
    label.new(bar_index, moonY, phaseEmoji + "\n" + phaseName, style = moonStyle, color = moonColor, textcolor = moonTextColor, size = size.normal)

if showSignalsInput and longSignal
    label.new(
         bar_index,
         low - atr * 0.95,
         phaseEmoji + " LONG " + longGrade + "\nMoon " + str.tostring(lunarLongScore, "#") + " | Mom " + str.tostring(bullMomentumScore, "#"),
         style = label.style_label_up,
         color = color.new(bullColorInput, 0),
         textcolor = color.white,
         size = signalLabelSize)

if showSignalsInput and shortSignal
    label.new(
         bar_index,
         high + atr * 0.95,
         phaseEmoji + " SHORT " + shortGrade + "\nMoon " + str.tostring(lunarShortScore, "#") + " | Mom " + str.tostring(bearMomentumScore, "#"),
         style = label.style_label_down,
         color = color.new(bearColorInput, 0),
         textcolor = color.white,
         size = signalLabelSize)

plot(showRiskLevelsInput ? activeEntry : na, "Active Entry", color = color.new(#1E88E5, 0), linewidth = 2, style = plot.style_linebr)
plot(showRiskLevelsInput ? activeStop : na, "Active Stop", color = color.new(#E53935, 0), linewidth = 2, style = plot.style_linebr)
plot(showRiskLevelsInput ? activeTp1 : na, "Target 1", color = color.new(#00C853, 0), linewidth = 1, style = plot.style_linebr)
plot(showRiskLevelsInput ? activeTp2 : na, "Target 2", color = color.new(#26A69A, 0), linewidth = 2, style = plot.style_linebr)

emaFastPlot = plot(showRibbonInput ? fastEma : na, "Fast EMA", color = color.new(bullColorInput, 0), linewidth = 2)
emaSlowPlot = plot(showRibbonInput ? slowEma : na, "Slow EMA", color = color.new(bearColorInput, 0), linewidth = 2)
fill(emaFastPlot, emaSlowPlot, color = fastEma >= slowEma ? color.new(bullColorInput, 85) : color.new(bearColorInput, 85))
plot(trendEma, "Trend EMA", color = color.new(#90A4AE, 0), linewidth = 2)
plot(showVwapInput ? sessionVwap : na, "VWAP", color = close >= sessionVwap ? color.new(#29B6F6, 0) : color.new(#FFB300, 0), linewidth = 2)

bgcolor(showBiasBgInput ? lunarMomentum > lunarBiasThresholdInput ? color.new(bullColorInput, 92) : lunarMomentum < -lunarBiasThresholdInput ? color.new(bearColorInput, 92) : color.new(neutralColorInput, 94) : na)
barcolor(longSignal ? color.new(bullColorInput, 0) : shortSignal ? color.new(bearColorInput, 0) : na)

plotshape(longSignal, title = "Long Trigger", style = shape.triangleup, location = location.belowbar, color = color.new(bullColorInput, 0), size = size.small)
plotshape(shortSignal, title = "Short Trigger", style = shape.triangledown, location = location.abovebar, color = color.new(bearColorInput, 0), size = size.small)

var table dash = table.new(position.top_right, 2, 9, bgcolor = color.new(#111827, 8), border_width = 1, border_color = color.new(#374151, 0))
if showDashboardInput and barstate.islast
    table.cell(dash, 0, 0, "LUNAR MOMENTUM", bgcolor = color.new(#0F172A, 0), text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 0, phaseEmoji + " " + phaseName, bgcolor = color.new(#0F172A, 0), text_color = color.white, text_size = size.small, text_halign = text.align_right)
    f_addRow(dash, 1, "Illumination", str.tostring(illumination * 100.0, "#.0") + "%", color.new(#1F2937, 0), color.new(#111827, 0), color.white, size.small)
    f_addRow(dash, 2, "Lunar Bias", lunarMomentum > lunarBiasThresholdInput ? "Waxing Bull" : lunarMomentum < -lunarBiasThresholdInput ? "Waning Bear" : "Transition", color.new(#1F2937, 0), lunarMomentum > lunarBiasThresholdInput ? color.new(bullColorInput, 20) : lunarMomentum < -lunarBiasThresholdInput ? color.new(bearColorInput, 20) : color.new(neutralColorInput, 35), color.white, size.small)
    f_addRow(dash, 3, "Bull Momentum", str.tostring(bullMomentumScore, "#.0"), color.new(#1F2937, 0), color.new(#111827, 0), bullMomentumScore >= minMomentumScoreInput ? bullColorInput : neutralColorInput, size.small)
    f_addRow(dash, 4, "Bear Momentum", str.tostring(bearMomentumScore, "#.0"), color.new(#1F2937, 0), color.new(#111827, 0), bearMomentumScore >= minMomentumScoreInput ? bearColorInput : neutralColorInput, size.small)
    f_addRow(dash, 5, "Long Setup", str.tostring(longConfluence, "#.0") + " " + longGrade, color.new(#1F2937, 0), color.new(#111827, 0), longSignal ? bullColorInput : color.white, size.small)
    f_addRow(dash, 6, "Short Setup", str.tostring(shortConfluence, "#.0") + " " + shortGrade, color.new(#1F2937, 0), color.new(#111827, 0), shortSignal ? bearColorInput : color.white, size.small)
    f_addRow(dash, 7, "HTF Filter", useHtfFilterInput ? htfBull ? "Bull" : htfBear ? "Bear" : "Mixed" : "Off", color.new(#1F2937, 0), color.new(#111827, 0), htfBull ? bullColorInput : htfBear ? bearColorInput : neutralColorInput, size.small)
    f_addRow(dash, 8, "State", longSignal ? "LONG NOW" : shortSignal ? "SHORT NOW" : activeDir == 1 ? "MANAGE LONG" : activeDir == -1 ? "MANAGE SHORT" : "WAIT", color.new(#1F2937, 0), color.new(#111827, 0), longSignal ? bullColorInput : shortSignal ? bearColorInput : neutralColorInput, size.small)

plot(longConfluence, "longConfluence", color = color.new(bullColorInput, 0), display = display.none)
plot(shortConfluence, "shortConfluence", color = color.new(bearColorInput, 0), display = display.none)
plot(lunarMomentum * 100.0, "lunarMomentum", color = color.new(neutralColorInput, 0), display = display.none)
plot(bullMomentumScore, "bullMomentumScore", color = color.new(bullColorInput, 0), display = display.none)
plot(bearMomentumScore, "bearMomentumScore", color = color.new(bearColorInput, 0), display = display.none)

alertcondition(longSignal, "Lunar Long", "Lunar long signal on {{ticker}} {{interval}}. Confluence={{plot(\"longConfluence\")}}")
alertcondition(shortSignal, "Lunar Short", "Lunar short signal on {{ticker}} {{interval}}. Confluence={{plot(\"shortConfluence\")}}")
alertcondition(isNewMoon, "New Moon", "New moon has started on {{ticker}} {{interval}}.")
alertcondition(isFullMoon, "Full Moon", "Full moon has started on {{ticker}} {{interval}}.")
````
