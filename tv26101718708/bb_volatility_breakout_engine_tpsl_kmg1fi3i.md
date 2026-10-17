# BB Volatility Breakout Engine + TP/SL

- url: https://www.tradingview.com/script/KMg1FI3i-BB-Volatility-Breakout-Engine-TP-SL/
- type: indicator
- pine_id: PUB;47dc6fbf05eb47a19e8457fed7aceb96
- version: 2.0

## Description

█ OVERVIEW
BB Volatility Breakout Engine + TP/SL is a momentum indicator based on Bollinger Bands expansion, designed to identify moments when the market transitions from decreasing volatility to increasing volatility.

The tool generates BUY/SELL signals only during real volatility expansion, additionally filtering them by trend direction and optionally by a histogram moving average.

Each signal automatically creates a complete trade setup:
• entry level,
• Stop Loss (ATR-based or percentage),
• three Take Profit levels based on Risk-Reward ratios.

█ CONCEPTS
The indicator is designed as a volatility breakout engine — instead of relying on classic price levels, it analyzes the dynamics of Bollinger Bands expansion.

Bollinger Bands Expansion (Delta)
The core of the logic is the change in Bollinger Bands width:
• increasing width → rising volatility (expansion),
• decreasing width → falling volatility (compression).
The histogram represents the delta of BB width, i.e. the rate of change in volatility.

Momentum + Direction (Slope)
Volatility alone is not enough — therefore a directional filter is applied:
• positive slope → bullish dominance,
• negative slope → bearish dominance.
This ensures signals are aligned with the current market momentum.

MA of Expansion (optional filter)
The histogram can be additionally filtered with a moving average:
• signal only when delta > MA → stronger expansion,
• filters out weak and random moves.

Candle Confirmation
Signals are additionally filtered by candle direction:
• BUY → bullish candle,
• SELL → bearish candle.
This reduces false signals during noisy price action.

Volatility Breakout
A signal is generated only when all conditions are met:
• active volatility expansion,
• alignment with direction (slope),
• no prior signal within the same expansion phase,
• (optional) confirmation by MA.
This means the indicator captures the beginning of a move driven by increasing volatility, not random price fluctuations.

TP/SL with Risk-Reward
After each signal, the indicator automatically calculates:
• entry (close of the signal candle),
• Stop Loss:
– ATR × multiplier
or
– percentage from entry
• TP1 / TP2 / TP3:
– based on selected RR ratios (e.g. 1:1, 1:2, 1:3)

Additionally:
• visual risk/reward zones (fills),
• automatic setup closure after TP or SL is hit.

█ FEATURES
1. Bollinger Bands Settings
* BB Length – length of the BB basis
* BB Multiplier – band width (standard deviation)
* Slope Smoothing – smoothing of trend direction

2. Histogram MA
* Histogram MA Length – length of the MA applied to expansion
* MA Type – SMA or EMA
* Show MA Lines – displays MA lines for expansion and contraction

3. Filters
* Filter: Delta Above MA – signals only when expansion is strong (delta > MA)

4. Visual Signals
* Show Green BUY Triangles – BUY signals
* Show Red SELL Triangles – SELL signals
Signals are displayed:
• on the histogram (precise timing),
• on the price chart (readability).

5. Colors
* Bullish Color – controls:
– histogram (expansion),
– MA,
– BUY signals,
– TP levels
* Bearish Color – controls:
– histogram (contraction),
– MA,
– SELL signals,
– SL levels
The histogram gradient reflects the strength of the move.

6. TP/SL Settings
* SL = ATR × or %
* ATR Period + Multiplier
* SL % from entry
* RR for:
– TP1
– TP2
– TP3

7. Display
* Option to show/hide:
– SL
– TP1 / TP2 / TP3
* Automatic:
– level plotting,
– label tracking,
– setup closure after TP/SL,
– deletion of previous objects

█ APPLICATIONS
1. Volatility breakout
Best used at the moment of transition from decreasing volatility to increasing volatility.
The indicator detects the phase where the market shifts from “quiet” (BB compression) to active movement (BB expansion).
This does not always mean classic consolidation — it can also occur as a slowdown within a trend before the next impulse.

2. Momentum trading
Signals are naturally aligned with market direction:
• long during increasing volatility + uptrend
• short during increasing volatility + downtrend

3. Strategy confirmation filter
Works very well as confirmation for:
• price action / market structure
→ confirms entries after price reaction at support/resistance (e.g. rejection or bounce + start of volatility expansion)
• RSI / momentum
→ entry when there is alignment between:
– rising RSI (e.g. break above 50)
– increasing volatility (BB expansion)

4. Position management
Immediately after entry you get:
• clearly defined risk,
• realistic targets,
• visual risk-to-reward structure.

█ NOTES
The indicator performs best in trending markets, where volatility expansion leads to continuation moves.
In sideways / ranging conditions, it may produce more false signals, as volatility expansion does not translate into sustained directional movement.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("BB Volatility Breakout Engine + TP/SL", overlay = false, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000)

// INPUTS
length = input.int(20, "BB Length")
mult = input.float(2.0, "BB Multiplier")
smooth = input.int(1, "Slope Smooth")
showBuy = input.bool(false, "Show Green BUY Triangles")
showSell = input.bool(false, "Show Red SELL Triangles")
show_buy_sell_labels = input.bool(true, "Show BUY/SELL Labels", group = "Signals")

// HISTOGRAM MA
maLength = input.int(10, "Histogram MA Length", minval = 1, group = "Histogram MA")
maType = input.string("EMA", "MA Type", options = ["SMA", "EMA"], group = "Histogram MA")
showMA = input.bool(true, "Show MA Lines", group = "Histogram MA")

// FILTER
useMAFilter = input.bool(true, "Filter: Delta Above MA", group = "Filters")

// COLOR SETTINGS
int lookback = 10
float gradientMin = 50.0
float gradientMax = 100.0
bullColorInput = input.color(#26a69a, "Bullish Color (controls histogram + MA + BUY signals)", group = "Color Settings")
bearColorInput = input.color(#ef5350, "Bearish Color (controls histogram + MA + SELL signals)", group = "Color Settings")

// TP/SL SETTINGS
showTargets = input.bool(true, "Show TP/SL", group = "TP/SL")
useAtrForSl = input.bool(true, "SL = ATR × instead of %", group = "TP/SL")
atrPeriod = input.int(14, "ATR Period", minval=1, group = "TP/SL")
slAtrMult = input.float(1.5, "SL ATR Multiplier", step=0.1, group = "TP/SL")
slPercent = input.float(1.0, "SL % from Entry", step=0.1, group = "TP/SL")
rrTp1 = input.float(1.0, "TP1 RR", step=0.1, group = "TP/SL")
rrTp2 = input.float(2.0, "TP2 RR", step=0.1, group = "TP/SL")
rrTp3 = input.float(3.0, "TP3 RR", step=0.1, group = "TP/SL")
showSlLevel = input.bool(true, "SL", group = "TP/SL Display")
showTp1Level = input.bool(true, "TP1", group = "TP/SL Display")
showTp2Level = input.bool(true, "TP2", group = "TP/SL Display")
showTp3Level = input.bool(true, "TP3", group = "TP/SL Display")

// TP/SL COLORS
buyLabelColor = bullColorInput
sellLabelColor = bearColorInput
buyColorLight = color.new(buyLabelColor, 40)
sellColorLight = color.new(sellLabelColor, 40)
buyFill = color.new(buyLabelColor, 85)
sellFill = color.new(sellLabelColor, 85)

// BB
basis = ta.sma(close, length)
dev = mult * ta.stdev(close, length)
upper = basis + dev
lower = basis - dev
bb_width = (upper - lower) / basis
delta = bb_width - bb_width[1]
slope_raw = (basis - basis[1]) / basis
slope = ta.ema(slope_raw, smooth)

// DYNAMIC OFFSET FOR SIGNALS ON HISTOGRAM
dynOffset = ta.highest(math.abs(delta), lookback) * 0.09

// MA
ma_src_exp = delta > 0 ? delta : na
ma_src_con = delta < 0 ? delta : na
maExpansion = maType == "EMA" ? ta.ema(ma_src_exp, maLength) : ta.sma(ma_src_exp, maLength)
maContraction = maType == "EMA" ? ta.ema(ma_src_con, maLength) : ta.sma(ma_src_con, maLength)

// ATR
atr_val = ta.atr(atrPeriod)

// GRADIENT ONLY FOR HISTOGRAM BARS
absDelta = math.abs(delta)
maxDelta = ta.highest(absDelta, lookback)
minDelta = ta.lowest(absDelta, lookback)
rangeDelta = maxDelta - minDelta > 0 ? maxDelta - minDelta : 1
normDelta = (absDelta - minDelta) / rangeDelta * 100
bullBase = color.new(bullColorInput, 35)
bullIntense = color.new(bullColorInput, 0)
bearBase = color.new(bearColorInput, 35)
bearIntense = color.new(bearColorInput, 0)
histColor = delta > 0 ?
     color.from_gradient(normDelta, gradientMin, gradientMax, bullBase, bullIntense) :
     color.from_gradient(normDelta, gradientMin, gradientMax, bearBase, bearIntense)

// PLOTS
plot(delta,
     style = plot.style_columns,
     color = histColor,
     title = "BB Expansion",
     linewidth = 3)
plot(showMA ? maExpansion : na,
     color = color.new(bullColorInput, 0),
     title = "MA Expansion",
     linewidth = 2)
plot(showMA ? maContraction : na,
     color = color.new(bearColorInput, 0),
     title = "MA Contraction",
     linewidth = 2)
hline(0, color = color.gray, title = "Zero Line")

// BACKGROUND
bgcolor(slope > 0 ? color.new(bullColorInput, 85) :
       slope < 0 ? color.new(bearColorInput, 85) : na,
       title = "Trend Background")

// TP/SL VARIABLES
var int trade_dir = 0
var int entry_bar = na
var float sl_level = na
var float extreme_level = na
var line entry_line = na
var label entry_label = na
var line sl_line = na
var label sl_label = na
var line tp1_line = na
var label tp1_label = na
var line tp2_line = na
var label tp2_label = na
var line tp3_line = na
var label tp3_label = na
var line extreme_line = na
var linefill risk_fill = na
var linefill reward_fill = na

// SIGNAL LOGIC
var bool signalFired = false
expansionActive = delta > 0
validCondition = useMAFilter ? (delta > maExpansion) : expansionActive
if not expansionActive
    signalFired := false
canSignal = validCondition and not signalFired
isGreenCandle = close > open
isRedCandle = close < open


buyCondition = slope > 0 and canSignal and isGreenCandle
sellCondition = slope < 0 and canSignal and isRedCandle

// Visual triangle signals 
buySignal = showBuy and buyCondition
sellSignal = showSell and sellCondition

if buyCondition or sellCondition
    signalFired := true

// SIGNALS ON HISTOGRAM
buyY = buySignal ? -dynOffset : na
sellY = sellSignal ? delta + dynOffset : na
plotshape(buyY,
     title = "BUY Signal Histogram",
     location = location.absolute,
     style = shape.triangleup,
     size = size.small,
     color = color.new(bullColorInput, 0))
plotshape(sellY,
     title = "SELL Signal Histogram",
     location = location.absolute,
     style = shape.triangledown,
     size = size.small,
     color = color.new(bearColorInput, 0))

// SIGNALS ON PRICE CHART
plotshape(buySignal,
     title = "BUY Signal Overlay",
     location = location.belowbar,
     style = shape.triangleup,
     size = size.small,
     color = bullColorInput,
     force_overlay = true)
plotshape(sellSignal,
     title = "SELL Signal Overlay",
     location = location.abovebar,
     style = shape.triangledown,
     size = size.small,
     color = bearColorInput,
     force_overlay = true)

// === INDEPENDENT BUY/SELL LABELS ===
if buyCondition and show_buy_sell_labels
    label.new(bar_index, low, 'BUY', style = label.style_label_up, color = color.new(buyLabelColor, 40), textcolor = color.white, size = size.small, force_overlay = true)
if sellCondition and show_buy_sell_labels
    label.new(bar_index, high, 'SELL', style = label.style_label_down, color = color.new(sellLabelColor, 40), textcolor = color.white, size = size.small, force_overlay = true)

// TP/SL – draw on signal (uses core condition, independent of triangles)
if (buyCondition or sellCondition) and showTargets
   
    line.delete(entry_line)
    label.delete(entry_label)
    line.delete(sl_line)
    label.delete(sl_label)
    line.delete(tp1_line)
    label.delete(tp1_label)
    line.delete(tp2_line)
    label.delete(tp2_label)
    line.delete(tp3_line)
    label.delete(tp3_label)
    line.delete(extreme_line)
    linefill.delete(risk_fill)
    linefill.delete(reward_fill)
    int dir = buyCondition ? 1 : -1
    trade_dir := dir
    entry_bar := bar_index
    float entry_price = close
    float risk_dist = useAtrForSl ? atr_val * slAtrMult : entry_price * (slPercent / 100)
    float sl_level_local = dir == 1 ? entry_price - risk_dist : entry_price + risk_dist
    float tp1_p = dir == 1 ? entry_price + risk_dist * rrTp1 : entry_price - risk_dist * rrTp1
    float tp2_p = dir == 1 ? entry_price + risk_dist * rrTp2 : entry_price - risk_dist * rrTp2
    float tp3_p = dir == 1 ? entry_price + risk_dist * rrTp3 : entry_price - risk_dist * rrTp3
    float extreme_level_local = na
    if showTp3Level
        extreme_level_local := tp3_p
    if showTp2Level
        extreme_level_local := na(extreme_level_local) ? tp2_p : dir == 1 ? math.max(extreme_level_local, tp2_p) : math.min(extreme_level_local, tp2_p)
    if showTp1Level
        extreme_level_local := na(extreme_level_local) ? tp1_p : dir == 1 ? math.max(extreme_level_local, tp1_p) : math.min(extreme_level_local, tp1_p)
    // entry
    entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color = dir == 1 ? buyLabelColor : sellLabelColor, width = 2, extend = extend.right, force_overlay = true)
    entry_label := label.new(bar_index, entry_price, (dir == 1 ? "BUY " : "SELL ") + str.tostring(entry_price, format.mintick), style = label.style_label_left, color = dir == 1 ? buyLabelColor : sellLabelColor, textcolor = color.white, size = size.small, force_overlay = true)
    // SL
    if showSlLevel
        sl_line := line.new(bar_index, sl_level_local, bar_index + 1, sl_level_local, color = sellColorLight, width = 1, style = line.style_dashed, extend = extend.right, force_overlay = true)
        sl_label := label.new(bar_index, sl_level_local, "SL " + str.tostring(sl_level_local, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small, force_overlay = true)
    // TP
    if showTp1Level
        tp1_line := line.new(bar_index, tp1_p, bar_index + 1, tp1_p, color = buyColorLight, width = 1, extend = extend.right, force_overlay = true)
        tp1_label := label.new(bar_index, tp1_p, "TP1 " + str.tostring(tp1_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small, force_overlay = true)
    if showTp2Level
        tp2_line := line.new(bar_index, tp2_p, bar_index + 1, tp2_p, color = buyColorLight, width = 1, extend = extend.right, force_overlay = true)
        tp2_label := label.new(bar_index, tp2_p, "TP2 " + str.tostring(tp2_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small, force_overlay = true)
    if showTp3Level
        tp3_line := line.new(bar_index, tp3_p, bar_index + 1, tp3_p, color = buyColorLight, width = 1, style = line.style_dotted, extend = extend.right, force_overlay = true)
        tp3_label := label.new(bar_index, tp3_p, "TP3 " + str.tostring(tp3_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small, force_overlay = true)
    
// fill risk / reward
    if showSlLevel
        risk_fill := linefill.new(entry_line, sl_line, sellFill)
    float extreme_for_fill = entry_price
    if showTp1Level
        extreme_for_fill := dir == 1 ? math.max(extreme_for_fill, tp1_p) : math.min(extreme_for_fill, tp1_p)
    if showTp2Level
        extreme_for_fill := dir == 1 ? math.max(extreme_for_fill, tp2_p) : math.min(extreme_for_fill, tp2_p)
    if showTp3Level
        extreme_for_fill := dir == 1 ? math.max(extreme_for_fill, tp3_p) : math.min(extreme_for_fill, tp3_p)
    if (dir == 1 and extreme_for_fill > entry_price) or (dir == -1 and extreme_for_fill < entry_price)
        extreme_line := line.new(bar_index, extreme_for_fill, bar_index + 1, extreme_for_fill, color = na, extend = extend.right, force_overlay = true)
        reward_fill := linefill.new(entry_line, extreme_line, buyFill)
    sl_level := sl_level_local
    extreme_level := extreme_level_local

// MOVE LABELS + CLOSE ON SL/TP
if trade_dir != 0
    label.set_x(entry_label, bar_index)
    if not na(sl_label)
        label.set_x(sl_label, bar_index)
    if not na(tp1_label)
        label.set_x(tp1_label, bar_index)
    if not na(tp2_label)
        label.set_x(tp2_label, bar_index)
    if not na(tp3_label)
        label.set_x(tp3_label, bar_index)
    bool sl_hit = trade_dir == 1 ? low <= sl_level : high >= sl_level
    bool tp_hit = not na(extreme_level) and (trade_dir == 1 ? high >= extreme_level : low <= extreme_level)
    if bar_index > entry_bar and (sl_hit or tp_hit)
        line.set_extend(entry_line, extend.none)
        line.set_x2(entry_line, bar_index)
        if not na(sl_line)
            line.set_extend(sl_line, extend.none)
            line.set_x2(sl_line, bar_index)
        if not na(tp1_line)
            line.set_extend(tp1_line, extend.none)
            line.set_x2(tp1_line, bar_index)
        if not na(tp2_line)
            line.set_extend(tp2_line, extend.none)
            line.set_x2(tp2_line, bar_index)
        if not na(tp3_line)
            line.set_extend(tp3_line, extend.none)
            line.set_x2(tp3_line, bar_index)
        if not na(extreme_line)
            line.set_extend(extreme_line, extend.none)
            line.set_x2(extreme_line, bar_index)
        trade_dir := 0

// ALERTS
alertcondition(buyCondition, title = "Buy Signal", message = "BB Volatility Breakout Engine: BUY Signal on {{ticker}} @ {{close}}")
alertcondition(sellCondition, title = "Sell Signal", message = "BB Volatility Breakout Engine: SELL Signal on {{ticker}} @ {{close}}")
````
