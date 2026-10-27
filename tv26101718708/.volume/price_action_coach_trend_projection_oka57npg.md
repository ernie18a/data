# Price Action Coach + Trend Projection

- url: https://www.tradingview.com/script/oka57npg-Price-Action-Coach-Trend-Projection/
- type: indicator
- pine_id: PUB;7b2d34fb44224d3eb8326bfb70848deb
- version: 1.0

## Description

new to charting so this helps, pretty basic indicators, candle patterns, projected trend

## Source Code

````pine
//@version=5
indicator("Price Action Coach + Trend Projection", overlay=true, max_lines_count=50, max_labels_count=500, max_boxes_count=10)

// === INPUTS ===
trendLen = input.int(20, "Trend lookback bars", minval=5, group="Projection")
atrMult = input.float(1.5, "Target zone width (ATR x)", minval=0.5, group="Projection")
showPanel = input.bool(true, "Show thesis panel", group="Projection")

showT1 = input.bool(true, "1-day target", group="Time Targets")
showT2 = input.bool(true, "3-day target", group="Time Targets")
showT3 = input.bool(true, "1-week target", group="Time Targets")
showT4 = input.bool(true, "2-week target", group="Time Targets")
showT5 = input.bool(false, "1-month target", group="Time Targets")

showPatterns = input.bool(true, "Show pattern labels", group="Price Action")
cooldownBars = input.int(5, "Min bars between same pattern", minval=1, group="Price Action")
volAvgLen = input.int(20, "Volume avg length", group="Price Action")

// === TIME → BARS ===
secondsPerBar = timeframe.in_seconds(timeframe.period)
isCrypto = syminfo.type == "crypto"
secondsPerDay = isCrypto ? 86400 : 23400
bars1d = math.max(1, math.round(secondsPerDay / secondsPerBar))
bars3d = bars1d * 3
bars1w = bars1d * 5
bars2w = bars1d * 10
bars1m = bars1d * 21

// === CORE DATA ===
atr = ta.atr(14)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
rsi = ta.rsi(close, 14)
volAvg = ta.sma(volume, volAvgLen)
volRatio = volume / volAvg

// === TREND ===
slope = ta.linreg(close, trendLen, 0) - ta.linreg(close, trendLen, 1)
isUptrend = ema20 > ema50 and slope > 0
isDowntrend = ema20 < ema50 and slope < 0
trendLabel = isUptrend ? "UPTREND" : isDowntrend ? "DOWNTREND" : "RANGE/CHOP"
trendColor = isUptrend ? color.green : isDowntrend ? color.red : color.gray

recentHigh = ta.highest(high, trendLen)
recentLow = ta.lowest(low, trendLen)
projectPrice(barsAhead) => close + (slope * barsAhead)
bullKillLevel = recentLow
bearKillLevel = recentHigh

// === PATTERN DETECTION ===
ph = ta.pivothigh(high, 5, 5)
pl = ta.pivotlow(low, 5, 5)

var float lastHigh1 = na
var float lastHigh2 = na
var int lastHigh1Bar = na
var float lastLow1 = na
var float lastLow2 = na
var int lastLow1Bar = na

if not na(ph)
    lastHigh2 := lastHigh1
    lastHigh1 := ph
    lastHigh1Bar := bar_index[5]

if not na(pl)
    lastLow2 := lastLow1
    lastLow1 := pl
    lastLow1Bar := bar_index[5]

// Cooldowns
var int cdDoubleTop = -1000
var int cdDoubleBot = -1000
var int cdVolUp = -1000
var int cdVolDown = -1000
var int cdBearDiv = -1000
var int cdBullDiv = -1000
var int cdBreakout = -1000
var int cdBreakdown = -1000
var int cdBearEng = -1000
var int cdBullEng = -1000
var int cdHammer = -1000
var int cdShooting = -1000

canFire(b) => bar_index - b >= cooldownBars

// Pattern conditions
doubleTop = not na(lastHigh1) and not na(lastHigh2) and math.abs(lastHigh1 - lastHigh2) / lastHigh2 < 0.01 and not na(ph)
doubleBot = not na(lastLow1) and not na(lastLow2) and math.abs(lastLow1 - lastLow2) / lastLow2 < 0.01 and not na(pl)
bigVolUp = volRatio > 2 and close > open
bigVolDown = volRatio > 2 and close < open
bearDiv = high > high[5] and rsi < rsi[5] and rsi > 65
bullDiv = low < low[5] and rsi > rsi[5] and rsi < 35
resistance = ta.highest(high, 50)[1]
support = ta.lowest(low, 50)[1]
breakoutUp = close > resistance and close[1] <= resistance and volRatio > 1.5
breakdownDown = close < support and close[1] >= support and volRatio > 1.5

bodySize = math.abs(close - open)
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low
bullEngulf = close > open and close[1] < open[1] and close > open[1] and open < close[1]
bearEngulf = close < open and close[1] > open[1] and close < open[1] and open > close[1]
hammer = lowerWick > bodySize * 2 and upperWick < bodySize and close > open
shooting = upperWick > bodySize * 2 and lowerWick < bodySize and close < open

// === DRAW PATTERN LABELS (every bar, persistent) ===
if showPatterns and doubleTop and canFire(cdDoubleTop)
    tip = "DOUBLE TOP\n\nWHAT: Buyers tried to break " + str.tostring(lastHigh1, "#.##") + " twice and failed.\n\nEFFECT: Reversal pattern. Look for break of neckline (recent low between peaks).\n\nINVALID: Close above " + str.tostring(lastHigh1, "#.##") + " = trapped shorts cover, sharp move up."
    label.new(lastHigh1Bar, lastHigh1, "Double Top", color=color.new(color.red, 30), textcolor=color.white, style=label.style_label_down, size=size.small, yloc=yloc.price, tooltip=tip)
    cdDoubleTop := bar_index

if showPatterns and doubleBot and canFire(cdDoubleBot)
    tip = "DOUBLE BOTTOM\n\nWHAT: Sellers tried to break " + str.tostring(lastLow1, "#.##") + " twice and failed.\n\nEFFECT: Reversal pattern. Look for break above neckline.\n\nINVALID: Close below " + str.tostring(lastLow1, "#.##") + " = trapped longs sell, sharp move down."
    label.new(lastLow1Bar, lastLow1, "Double Bottom", color=color.new(color.green, 30), textcolor=color.white, style=label.style_label_up, size=size.small, yloc=yloc.price, tooltip=tip)
    cdDoubleBot := bar_index

if showPatterns and bigVolUp and canFire(cdVolUp)
    tip = "HIGH VOL GREEN (" + str.tostring(volRatio, "#.#") + "x avg)\n\nWHAT: Big buyers stepped in.\n\nEFFECT: At lows = accumulation (bullish). At highs = climax (bearish). Breaking R = confirms breakout.\n\nWATCH: Next bar holding above this bar's midpoint = real."
    label.new(bar_index, low, str.tostring(volRatio, "#.#") + "x ↑", color=color.new(color.green, 40), textcolor=color.white, style=label.style_label_up, size=size.small, yloc=yloc.price, tooltip=tip)
    cdVolUp := bar_index

if showPatterns and bigVolDown and canFire(cdVolDown)
    tip = "HIGH VOL RED (" + str.tostring(volRatio, "#.#") + "x avg)\n\nWHAT: Heavy selling.\n\nEFFECT: At highs = distribution (bearish). At lows = capitulation (bottom signal). Breaking S = confirms breakdown.\n\nWATCH: Next bar reclaiming this range = absorption, bullish reversal."
    label.new(bar_index, high, str.tostring(volRatio, "#.#") + "x ↓", color=color.new(color.red, 40), textcolor=color.white, style=label.style_label_down, size=size.small, yloc=yloc.price, tooltip=tip)
    cdVolDown := bar_index

if showPatterns and bearDiv and canFire(cdBearDiv)
    tip = "BEARISH DIVERGENCE\n\nWHAT: Price made higher high, RSI made lower high.\n\nEFFECT: Momentum fading. Reversal often near, but NOT a sell signal alone.\n\nWAIT FOR: Reversal candle + break of swing low. THEN short."
    label.new(bar_index, high, "Bear Div", color=color.new(color.orange, 30), textcolor=color.white, style=label.style_label_down, size=size.small, yloc=yloc.price, tooltip=tip)
    cdBearDiv := bar_index

if showPatterns and bullDiv and canFire(cdBullDiv)
    tip = "BULLISH DIVERGENCE\n\nWHAT: Price made lower low, RSI made higher low.\n\nEFFECT: Selling weakening. Often precedes bottom.\n\nWAIT FOR: Bullish candle + break of swing high. THEN long."
    label.new(bar_index, low, "Bull Div", color=color.new(color.aqua, 30), textcolor=color.black, style=label.style_label_up, size=size.small, yloc=yloc.price, tooltip=tip)
    cdBullDiv := bar_index

if showPatterns and breakoutUp and canFire(cdBreakout)
    tip = "BREAKOUT @ " + str.tostring(resistance, "#.##") + "\n\nWHAT: Above 50-bar high w/ " + str.tostring(volRatio, "#.#") + "x vol. Shorts trapped.\n\nEFFECT: Old R becomes new S. Likely continuation up.\n\nENTRY: Pullback to " + str.tostring(resistance, "#.##") + ". Stop: below it. Failure = bull trap."
    label.new(bar_index, low, "Breakout 🚀", color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_up, size=size.small, yloc=yloc.price, tooltip=tip)
    cdBreakout := bar_index

if showPatterns and breakdownDown and canFire(cdBreakdown)
    tip = "BREAKDOWN @ " + str.tostring(support, "#.##") + "\n\nWHAT: Below 50-bar low w/ " + str.tostring(volRatio, "#.#") + "x vol. Longs trapped.\n\nEFFECT: Old S becomes new R. Likely continuation down.\n\nENTRY: Bounce to " + str.tostring(support, "#.##") + ". Stop: above it. Failure = bear trap."
    label.new(bar_index, high, "Breakdown 💥", color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_down, size=size.small, yloc=yloc.price, tooltip=tip)
    cdBreakdown := bar_index

if showPatterns and bullEngulf and canFire(cdBullEng)
    tip = "BULL ENGULFING\n\nWHAT: Green candle swallowed prior red candle.\n\nEFFECT: Power shift to buyers. Strong reversal at support; weak mid-trend.\n\nCONFIRM: Next bar holds above midpoint."
    label.new(bar_index, low, "Bull Engulf", color=color.new(color.green, 40), textcolor=color.white, style=label.style_label_up, size=size.small, yloc=yloc.price, tooltip=tip)
    cdBullEng := bar_index

if showPatterns and bearEngulf and canFire(cdBearEng)
    tip = "BEAR ENGULFING\n\nWHAT: Red candle swallowed prior green candle.\n\nEFFECT: Power shift to sellers. Strong reversal at resistance.\n\nCONFIRM: Next bar stays below midpoint."
    label.new(bar_index, high, "Bear Engulf", color=color.new(color.red, 40), textcolor=color.white, style=label.style_label_down, size=size.small, yloc=yloc.price, tooltip=tip)
    cdBearEng := bar_index

if showPatterns and hammer and canFire(cdHammer)
    tip = "HAMMER\n\nWHAT: Long lower wick = sellers tried to push down, buyers rejected it.\n\nEFFECT: Bullish reversal at support. Random location = noise.\n\nCONFIRM: Next bar closes above hammer's high."
    label.new(bar_index, low, "Hammer", color=color.new(color.green, 40), textcolor=color.white, style=label.style_label_up, size=size.small, yloc=yloc.price, tooltip=tip)
    cdHammer := bar_index

if showPatterns and shooting and canFire(cdShooting)
    tip = "SHOOTING STAR\n\nWHAT: Long upper wick = buyers pushed up, sellers rejected.\n\nEFFECT: Bearish reversal at resistance.\n\nCONFIRM: Next bar closes below this candle's low."
    label.new(bar_index, high, "Shooting Star", color=color.new(color.red, 40), textcolor=color.white, style=label.style_label_down, size=size.small, yloc=yloc.price, tooltip=tip)
    cdShooting := bar_index

// === PROJECTION DRAWING (last bar only) ===
var array<line> projLines = array.new<line>()
var array<label> projLabels = array.new<label>()

cleanupProjection() =>
    if array.size(projLines) > 0
        for i = 0 to array.size(projLines) - 1
            line.delete(array.get(projLines, i))
        array.clear(projLines)
    if array.size(projLabels) > 0
        for i = 0 to array.size(projLabels) - 1
            label.delete(array.get(projLabels, i))
        array.clear(projLabels)

drawTarget(barsAhead, labelText, show) =>
    if show
        targetPrice = projectPrice(barsAhead)
        upperBound = targetPrice + (atr * atrMult)
        lowerBound = targetPrice - (atr * atrMult)
        pctMove = (targetPrice - close) / close * 100
        vLine = line.new(bar_index + barsAhead, lowerBound, bar_index + barsAhead, upperBound, color=color.new(trendColor, 40), width=2)
        array.push(projLines, vLine)
        tLabel = label.new(bar_index + barsAhead, targetPrice, labelText + "\n" + str.tostring(targetPrice, "#.##") + "\n(" + str.tostring(pctMove, "+#.##") + "%)", color=color.new(trendColor, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
        array.push(projLabels, tLabel)

if barstate.islast
    cleanupProjection()
    maxBars = showT5 ? bars1m : showT4 ? bars2w : showT3 ? bars1w : showT2 ? bars3d : bars1d
    finalPrice = projectPrice(maxBars)
    
    mainLine = line.new(bar_index, close, bar_index + maxBars, finalPrice, color=trendColor, width=3)
    array.push(projLines, mainLine)
    upperCone = line.new(bar_index, close, bar_index + maxBars, finalPrice + (atr * atrMult), color=color.new(trendColor, 70), width=1, style=line.style_dashed)
    lowerCone = line.new(bar_index, close, bar_index + maxBars, finalPrice - (atr * atrMult), color=color.new(trendColor, 70), width=1, style=line.style_dashed)
    array.push(projLines, upperCone)
    array.push(projLines, lowerCone)
    
    drawTarget(bars1d, "🎯 1 Day", showT1)
    drawTarget(bars3d, "🎯 3 Days", showT2)
    drawTarget(bars1w, "🎯 1 Week", showT3)
    drawTarget(bars2w, "🎯 2 Weeks", showT4)
    drawTarget(bars1m, "🎯 1 Month", showT5)
    
    killLevel = isUptrend ? bullKillLevel : isDowntrend ? bearKillLevel : na
    if not na(killLevel)
        kLine = line.new(bar_index - trendLen, killLevel, bar_index + maxBars, killLevel, color=color.red, width=2, style=line.style_dashed)
        array.push(projLines, kLine)
        kLabel = label.new(bar_index + maxBars, killLevel, "❌ THESIS DEAD\n" + (isUptrend ? "below " : "above ") + str.tostring(killLevel, "#.##"), color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
        array.push(projLabels, kLabel)

// === BULL/BEAR SIGNS (live evaluation) ===
// Build evidence lists by checking conditions
bullSigns = ""
bearSigns = ""

// Bull signs
if close > ema20
    bullSigns := bullSigns + "✓ Above 20 EMA\n"
if close > ema50
    bullSigns := bullSigns + "✓ Above 50 EMA\n"
if close > ema200
    bullSigns := bullSigns + "✓ Above 200 EMA (bull regime)\n"
if ema20 > ema50
    bullSigns := bullSigns + "✓ 20 EMA > 50 EMA\n"
if rsi > 50 and rsi < 70
    bullSigns := bullSigns + "✓ RSI bullish (" + str.tostring(rsi, "#") + ")\n"
if slope > 0
    bullSigns := bullSigns + "✓ Positive momentum\n"
if close > recentHigh[1]
    bullSigns := bullSigns + "✓ Higher high made\n"
if low > recentLow[1] and recentLow[1] > recentLow[trendLen]
    bullSigns := bullSigns + "✓ Higher lows pattern\n"
if bigVolUp
    bullSigns := bullSigns + "✓ High vol buying NOW\n"
if bullEngulf or hammer
    bullSigns := bullSigns + "✓ Bullish candle pattern\n"
if doubleBot
    bullSigns := bullSigns + "✓ Double bottom forming\n"
if bullDiv
    bullSigns := bullSigns + "✓ Bullish divergence\n"
if breakoutUp
    bullSigns := bullSigns + "✓ BREAKOUT confirmed\n"

// Bear signs
if close < ema20
    bearSigns := bearSigns + "✗ Below 20 EMA\n"
if close < ema50
    bearSigns := bearSigns + "✗ Below 50 EMA\n"
if close < ema200
    bearSigns := bearSigns + "✗ Below 200 EMA (bear regime)\n"
if ema20 < ema50
    bearSigns := bearSigns + "✗ 20 EMA < 50 EMA\n"
if rsi < 50 and rsi > 30
    bearSigns := bearSigns + "✗ RSI bearish (" + str.tostring(rsi, "#") + ")\n"
if rsi > 70
    bearSigns := bearSigns + "✗ RSI overbought (" + str.tostring(rsi, "#") + ")\n"
if slope < 0
    bearSigns := bearSigns + "✗ Negative momentum\n"
if close < recentLow[1]
    bearSigns := bearSigns + "✗ Lower low made\n"
if bigVolDown
    bearSigns := bearSigns + "✗ High vol selling NOW\n"
if bearEngulf or shooting
    bearSigns := bearSigns + "✗ Bearish candle pattern\n"
if doubleTop
    bearSigns := bearSigns + "✗ Double top forming\n"
if bearDiv
    bearSigns := bearSigns + "✗ Bearish divergence\n"
if breakdownDown
    bearSigns := bearSigns + "✗ BREAKDOWN confirmed\n"

bullSigns := bullSigns == "" ? "(none right now)" : bullSigns
bearSigns := bearSigns == "" ? "(none right now)" : bearSigns

// === STATUS PANEL ===
var table panel = table.new(position.top_right, 3, 12, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if showPanel and barstate.islast
    table.clear(panel, 0, 0, 2, 11)
    
    // Header spans 3 cols visually (use one big cell + filler)
    table.cell(panel, 0, 0, "TREND THESIS: " + trendLabel, text_color=color.white, bgcolor=trendColor, text_size=size.normal)
    table.cell(panel, 1, 0, "Price: " + str.tostring(close, "#.##"), text_color=color.white, bgcolor=trendColor, text_size=size.normal)
    table.cell(panel, 2, 0, "Conf: " + str.tostring(rsi, "#"), text_color=color.white, bgcolor=trendColor, text_size=size.normal)
    
    // Time targets (col 0 + 1)
    row = 1
    if showT1
        p = projectPrice(bars1d)
        table.cell(panel, 0, row, "1 Day", text_color=color.white, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(panel, 1, row, str.tostring(p, "#.##") + " (" + str.tostring((p - close) / close * 100, "+#.##") + "%)", text_color=trendColor, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(panel, 2, row, "", bgcolor=color.new(color.black, 50))
        row := row + 1
    if showT2
        p = projectPrice(bars3d)
        table.cell(panel, 0, row, "3 Days", text_color=color.white, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(panel, 1, row, str.tostring(p, "#.##") + " (" + str.tostring((p - close) / close * 100, "+#.##") + "%)", text_color=trendColor, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(panel, 2, row, "", bgcolor=color.new(color.black, 50))
        row := row + 1
    if showT3
        p = projectPrice(bars1w)
        table.cell(panel, 0, row, "1 Week", text_color=color.white, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(panel, 1, row, str.tostring(p, "#.##") + " (" + str.tostring((p - close) / close * 100, "+#.##") + "%)", text_color=trendColor, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(panel, 2, row, "", bgcolor=color.new(color.black, 50))
        row := row + 1
    if showT4
        p = projectPrice(bars2w)
        table.cell(panel, 0, row, "2 Weeks", text_color=color.white, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(panel, 1, row, str.tostring(p, "#.##") + " (" + str.tostring((p - close) / close * 100, "+#.##") + "%)", text_color=trendColor, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(panel, 2, row, "", bgcolor=color.new(color.black, 50))
        row := row + 1
    if showT5
        p = projectPrice(bars1m)
        table.cell(panel, 0, row, "1 Month", text_color=color.white, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(panel, 1, row, str.tostring(p, "#.##") + " (" + str.tostring((p - close) / close * 100, "+#.##") + "%)", text_color=trendColor, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(panel, 2, row, "", bgcolor=color.new(color.black, 50))
        row := row + 1
    
    // Invalidation
    killLevel = isUptrend ? bullKillLevel : isDowntrend ? bearKillLevel : na
    table.cell(panel, 0, row, "Invalidation", text_color=color.white, bgcolor=color.new(color.black, 50), text_size=size.small)
    table.cell(panel, 1, row, na(killLevel) ? "—" : str.tostring(killLevel, "#.##"), text_color=color.red, bgcolor=color.new(color.black, 50), text_size=size.small)
    table.cell(panel, 2, row, "", bgcolor=color.new(color.black, 50))
    row := row + 1
    
    // BULL vs BEAR signs side-by-side
    table.cell(panel, 0, row, "🟢 SIGNS BULLISH", text_color=color.white, bgcolor=color.new(color.green, 30), text_size=size.small)
    table.cell(panel, 1, row, "", bgcolor=color.new(color.black, 50))
    table.cell(panel, 2, row, "🔴 SIGNS BEARISH", text_color=color.white, bgcolor=color.new(color.red, 30), text_size=size.small)
    row := row + 1
    
    table.cell(panel, 0, row, bullSigns, text_color=color.lime, bgcolor=color.new(color.black, 70), text_size=size.tiny, text_halign=text.align_left)
    table.cell(panel, 1, row, "", bgcolor=color.new(color.black, 70))
    table.cell(panel, 2, row, bearSigns, text_color=color.red, bgcolor=color.new(color.black, 70), text_size=size.tiny, text_halign=text.align_left)

// === PLOT EMAs ===
plot(ema20, "EMA 20", color=color.blue, linewidth=1)
plot(ema50, "EMA 50", color=color.orange, linewidth=1)
plot(ema200, "EMA 200", color=color.purple, linewidth=1)
````
