# Market Pressure SuperTrend

- url: https://www.tradingview.com/script/0n6YiWxM-Market-Pressure-SuperTrend/
- type: indicator
- pine_id: PUB;2a4fdae5e28046098581c11c1f408a3b
- version: 1.0

## Description

█ OVERVIEW
Market Pressure SuperTrend is a trend-following indicator based on the classic SuperTrend, extended with dynamic adaptation driven by a market pressure oscillator (MPO – Market Pressure Oscillator).

Its main function is to combine trend direction with momentum context. When the market enters overbought or oversold conditions, the ATR multiplier is temporarily reduced, allowing the trend line to react faster to price changes.

The indicator maintains visual simplicity while adding an adaptive layer that improves timing compared to a standard SuperTrend approach.

█ CONCEPT
Trend-following indicators are often characterized by inherent lag. This delay comes from the way they smooth price data and react only after a move has already developed.
The classic SuperTrend uses ATR as a volatility buffer, which provides stability but can delay reaction to fast market shifts.
Market Pressure SuperTrend extends this model by incorporating momentum analysis through an internal oscillator (MPO).

Instead of treating the ATR multiplier as a fixed parameter, the indicator:
* detects overbought (OB) and oversold (OS) conditions,
* temporarily reduces the ATR multiplier in those zones,
* brings the trend line closer to price, increasing responsiveness.
The adaptive mode is active for a limited time — up to 200 bars — or until a trend change occurs. After either condition is met, the indicator returns to its base ATR configuration.

Additionally, adaptability depends not only on SuperTrend parameters but also on MPO settings:
* shorter MPO length → more frequent OB/OS conditions → more frequent adaptation
* longer MPO length → fewer signals → more stable trend behavior
* higher smoothing → reduced noise → fewer but cleaner adaptive triggers
This creates a hybrid model:
trend (SuperTrend) + momentum (MPO) → adaptive market response.

█ INPUTS
SuperTrend:
* ATR Length – period used for ATR calculation
* Base ATR Multiplier – baseline distance of the trend line from price
* OB/OS Sensitivity – strength of ATR reduction during adaptive mode

Market Pressure Oscillator (MPO):
* MPO Length – lookback period for pressure calculation
* MPO Smoothing – EMA smoothing applied to oscillator
* Overbought Level – upper threshold for momentum
* Oversold Level – lower threshold for momentum

Color Settings:
* Color bars by trend – colors candles according to trend direction
* Show SuperTrend Line – toggles trend line visibility
* Use Gradient Fill – fills area between price and trend line
* Show OB/OS Circles – marks OB/OS entries on chart
* Uptrend / Downtrend Color – trend colors

Overextension Signals:
* Deviation Threshold (x ATR) – defines when price is considered extended from trend

Info Table:
* Show MPO + ATR Distance Table – enables info panel
* Table Position – location of the table
* Text Size – table font size

TP/SL:
* Show TP/SL Targets – enables trade levels
* SL = ATR × instead of % – selects SL calculation method
* ATR Period for TP/SL – ATR length for risk model
* SL ATR Multiplier / SL % – stop loss size
* TP1 / TP2 / TP3 RR – risk-reward targets

TP/SL Display:
* controls visibility of SL, TP1, TP2, TP3 levels

█ TABLE
The table provides real-time market and system context:
Trend
* Current SuperTrend direction (Bullish / Bearish)
Momentum
* MPO value and its direction of change
Momentum Zone
Current oscillator state:
* Overbought
* Oversold
* Neutral — the range between OB and OS levels
Adaptive Mode
* Indicates whether ATR reduction is currently active due to MPO conditions
ATR Distance
* Distance between price and trend line expressed in ATR units
* High values may indicate potential overextension

█ APPLICATIONS
The indicator is primarily designed for trend-following strategies, but its strength lies in adding momentum context and trade management functionality.

The core application is directional trading based on trend confirmation.
For example, if price breaks a key level (such as a local resistance), and:
* the trend is bullish (SuperTrend confirms uptrend),
* MPO shows supportive momentum or recently recovered from oversold conditions,
* there is no major nearby resistance,
then a long position can be considered within a strong confluence setup.

Another key use case is dynamic trade management.
The SuperTrend line naturally acts as a trailing stop, adjusting with price movement and allowing traders to:
* protect profits,
* stay in trends without manual stop adjustments.
Adaptive behavior further enhances this by tightening the trend line during extreme momentum conditions (OB/OS), improving responsiveness to potential reversals or pullbacks.

Built-in TP/SL levels extend this into a complete trade planning tool.
Each signal provides immediate visual structure:
* stop loss level
* risk-based take profit targets (RR-based)
This allows quick evaluation of risk/reward before entering a trade.
In practice, the indicator works as:
* a trend filter (direction),
* a momentum context tool (MPO),
* and a trade management framework (trailing + TP/SL),
rather than a standalone buy/sell system.

█ NOTES
* Works across all markets and timeframes
* MPO is not a direct entry signal — it modifies trend behavior
* Adaptive ATR mode is limited to 200 bars or until trend change
* Higher sensitivity → faster reaction, more signals
* Lower sensitivity → smoother and more stable trend
* Overextension indicates increased pullback probability, not reversal certainty
* Best results when combined with:
* market structure
* support/resistance zones
* additional confirmation tools

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("Market Pressure SuperTrend", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// SuperTrend
atrLen = input.int(14, "ATR Length", minval=1, group="SuperTrend")
baseFactor = input.float(3.0, "Base ATR Multiplier", minval=0.1, step=0.1, group="SuperTrend")
sensitivity = input.float(0.25, "OB/OS Sensitivity", minval=0.0, maxval=1.0, step=0.01, group="SuperTrend", tooltip="0.0 = No momentum influence\n1.0 = Maximum ATR multiplier reduction when entering OB/OS")

// Market Pressure Oscillator
momLen = input.int(14, "MPO Length", group="Market Pressure Oscillator")
momSmooth = input.int(1, "MPO Smoothing", group="Market Pressure Oscillator")
obLevel = input.float(30.0, "Overbought Level", group="Market Pressure Oscillator")
osLevel = input.float(-30.0, "Oversold Level", group="Market Pressure Oscillator")

// COLOR SETTINGS
colorBarsEnabled = input.bool(true, "Color bars by trend", group="Color Settings")
showLine = input.bool(true, "Show SuperTrend Line", group="Color Settings")
fillShade = input.bool(true, "Use Gradient Fill", group="Color Settings")
showOBOSCircles = input.bool(false, "Show OB/OS Circles", group="Color Settings")
upColor = input.color(color.rgb(6, 162, 47), "Uptrend Color (Bullish)")
downColor = input.color(color.rgb(207, 23, 23), "Downtrend Color (Bearish)")

// TP/SL COLORS 
buyLabelColor = upColor
sellLabelColor = downColor
buyColorLight = color.new(buyLabelColor, 40)
sellColorLight = color.new(sellLabelColor, 40)
buyFill = color.new(buyLabelColor, 70)
sellFill = color.new(sellLabelColor, 70)

// OVEREXTENSION SETTINGS 
devThreshold = input.float(3.5, "Deviation Threshold (x ATR)", minval=0.5, step=0.1, group="Overextension Signals", tooltip="Deviation size (in ATR) that we consider 'large'")

// TABLE 
showInfoTable = input.bool(true, "Show MPO + ATR Distance Table", group="Info Table")
tablePosition  = input.string("Top Right", "Table Position", 
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Top Center", "Bottom Center", "Middle Left", "Middle Right"],
     group="Info Table")
tableTextSize  = input.string("Normal", "Text Size", 
     options = ["Tiny", "Small", "Normal", "Large"], 
     group="Info Table")

// SL/TP SECTION 
show_targets = input.bool(true, "Show TP/SL Targets", group = "TP/SL")
use_atr_sl = input.bool(true, "SL = ATR × instead of %", group = "TP/SL")
tp_atr_period = input.int(14, "ATR Period for TP/SL", minval=1, group = "TP/SL")
sl_atr_mult = input.float(1.5, "SL ATR Multiplier", step=0.1, group = "TP/SL")
sl_percent = input.float(1.0, "SL % from Entry", step=0.1, group = "TP/SL")
rr_tp1 = input.float(1.0, "TP1 Risk-Reward Ratio", step=0.1, group = "TP/SL")
rr_tp2 = input.float(2.0, "TP2 Risk-Reward Ratio", step=0.1, group = "TP/SL")
rr_tp3 = input.float(3.0, "TP3 Risk-Reward Ratio", step=0.1, group = "TP/SL")

// DISPLAY
show_sl_level = input.bool(true, "Show SL Level", group = "TP/SL Display")
show_tp1_level = input.bool(true, "Show TP1 Level", group = "TP/SL Display")
show_tp2_level = input.bool(true, "Show TP2 Level", group = "TP/SL Display")
show_tp3_level = input.bool(true, "Show TP3 Level", group = "TP/SL Display")

// FIXED PARAMETERS
confirmBars = 1
divBars = 200

// TABLE SETTINGS CONVERSION 
finalTablePos = 
     tablePosition == "Top Left"      ? position.top_left :
     tablePosition == "Top Right"     ? position.top_right :
     tablePosition == "Bottom Left"   ? position.bottom_left :
     tablePosition == "Bottom Right"  ? position.bottom_right :
     tablePosition == "Top Center"    ? position.top_center :
     tablePosition == "Bottom Center" ? position.bottom_center :
     tablePosition == "Middle Left"   ? position.middle_left :
     tablePosition == "Middle Right"  ? position.middle_right : position.top_right

tableSize = 
     tableTextSize == "Tiny"   ? size.tiny :
     tableTextSize == "Small"  ? size.small :
     tableTextSize == "Large"  ? size.large : size.normal

// MPO OSCILLATOR 
calcMPO(_len, _smooth) =>
    body = math.abs(close - open)
    avgBody = ta.sma(body, _len)
    dir = close > open ? 1.0 : close < open ? -1.0 : 0.0
    weight = avgBody != 0 ? body / avgBody : 1.0
    contrib = dir * weight
    rolling = 0.0
    for i = 0 to _len - 1
        rolling += contrib[i]
    norm = rolling / (_len * 2) * 100
    ta.ema(norm, _smooth)
osc = calcMPO(momLen, momSmooth)

// SUPERTREND BASE 
atr = ta.atr(atrLen)
tp_atr = ta.atr(tp_atr_period)          
var float trailLong = na
var float trailShort = na
var int regime = 0
trailLong := na(trailLong) ? hl2 : trailLong
trailShort := na(trailShort) ? hl2 : trailShort
var int bullCount = 0
var int bearCount = 0
bullCount := close > trailShort ? bullCount + 1 : 0
bearCount := close < trailLong ? bearCount + 1 : 0

// TREND FLIP LOGIC
nextRegime = regime
if regime == 0
    if bullCount >= confirmBars
        nextRegime := 1
    else if bearCount >= confirmBars
        nextRegime := -1
else if regime == 1 and bearCount >= confirmBars
    nextRegime := -1
else if regime == -1 and bullCount >= confirmBars
    nextRegime := 1
flipHappens = nextRegime != regime

// MOMENTUM OB/OS 
obEnter = ta.crossover(osc, obLevel)
osEnter = ta.crossunder(osc, osLevel)
var int momAge = 9999
var int momType = 0
if obEnter
    momAge := 0
    momType := 1
else if osEnter
    momAge := 0
    momType := -1
else if flipHappens
    momAge := 9999
    momType := 0
else
    momAge += 1
momActive = momAge <= divBars and momType == nextRegime

// ADJUSTMENT ATR 
factorAdjusted = baseFactor
if momActive and not flipHappens
    factorAdjusted := baseFactor * (1 - sensitivity)

// SUPERTREND BANDS 
bandTop = hl2 + factorAdjusted * atr
bandBot = hl2 - factorAdjusted * atr
if nextRegime == 1
    trailLong := math.max(bandBot, nz(trailLong[1], bandBot))
    trailShort := bandTop
else if nextRegime == -1
    trailShort := math.min(bandTop, nz(trailShort[1], bandTop))
    trailLong := bandBot
else
    trailLong := bandBot
    trailShort := bandTop
regime := nextRegime

var bool trailModifiedAfterFlip = false
var float initialTrailLevel = na
if flipHappens
    initialTrailLevel := regime == 1 ? trailLong : trailShort
    trailModifiedAfterFlip := false
else if (regime == 1 and trailLong > nz(initialTrailLevel)) or (regime == -1 and trailShort < nz(initialTrailLevel))
    trailModifiedAfterFlip := true

// VISUALIZATION 
plotLine = flipHappens ? na : (regime == 1 ? trailLong : trailShort)
pLine = plot(plotLine, color = showLine ? color.new(regime == 1 ? upColor : downColor, 40) : na, linewidth = 2, style = plot.style_linebr)
pCenter = plot(hl2, display = display.none)
fill(
    pLine,
    pCenter,
    plotLine,
    hl2,
    fillShade ? color.new(regime == 1 ? upColor : downColor, 75) : na,
    fillShade ? color.new(regime == 1 ? upColor : downColor, 95) : na
)

// BUY / SELL LABELS 
if flipHappens
    label.new(
        bar_index,
        regime == 1 ? low - atr * 0.5 : high + atr * 0.5,
        regime == 1 ? "Buy" : "Sell",
        color = color.new(regime == 1 ? upColor : downColor, 40),
        style = regime == 1 ? label.style_label_up : label.style_label_down,
        textcolor = color.white,
        size = size.small
    )

// TP/SL VARIABLES 
var int trade_dir = 0
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
var int entry_bar = na

// BUY / SELL + TP/SL LOGIC 
if flipHappens
    if show_targets
        // Delete previous objects
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
        
        trade_dir := regime
        entry_bar := bar_index
        float entry_price = close
        float risk_dist = use_atr_sl ? tp_atr * sl_atr_mult : entry_price * (sl_percent / 100)
        
        float tp1_p = na
        float tp2_p = na
        float tp3_p = na
        
        if regime == 1  // BUY
            sl_level := entry_price - risk_dist
            tp1_p := entry_price + risk_dist * rr_tp1
            tp2_p := entry_price + risk_dist * rr_tp2
            tp3_p := entry_price + risk_dist * rr_tp3
            extreme_level := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na
            
            entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color = buyLabelColor, width = 1, extend = extend.right)
            entry_label := label.new(bar_index, entry_price, "BUY " + str.tostring(entry_price, format.mintick), style = label.style_label_left, color = buyLabelColor, textcolor = color.white, size = size.small)
            
            if show_sl_level
                sl_line := line.new(bar_index, sl_level, bar_index + 1, sl_level, color = sellColorLight, width = 1, style = line.style_dashed, extend = extend.right)
                sl_label := label.new(bar_index, sl_level, "SL " + str.tostring(sl_level, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small)
            
            if show_tp1_level
                tp1_line := line.new(bar_index, tp1_p, bar_index + 1, tp1_p, color = buyColorLight, width = 1, extend = extend.right)
                tp1_label := label.new(bar_index, tp1_p, "TP1 " + str.tostring(tp1_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
            if show_tp2_level
                tp2_line := line.new(bar_index, tp2_p, bar_index + 1, tp2_p, color = buyColorLight, width = 1, extend = extend.right)
                tp2_label := label.new(bar_index, tp2_p, "TP2 " + str.tostring(tp2_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
            if show_tp3_level
                tp3_line := line.new(bar_index, tp3_p, bar_index + 1, tp3_p, color = buyColorLight, width = 1, style = line.style_dotted, extend = extend.right)
                tp3_label := label.new(bar_index, tp3_p, "TP3 " + str.tostring(tp3_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
            
            if show_sl_level
                risk_fill := linefill.new(entry_line, sl_line, sellFill)
            
            float max_tp_for_fill = entry_price
            if show_tp1_level
                max_tp_for_fill := math.max(max_tp_for_fill, tp1_p)
            if show_tp2_level
                max_tp_for_fill := math.max(max_tp_for_fill, tp2_p)
            if show_tp3_level
                max_tp_for_fill := math.max(max_tp_for_fill, tp3_p)
            if max_tp_for_fill > entry_price
                extreme_line := line.new(bar_index, max_tp_for_fill, bar_index + 1, max_tp_for_fill, color = na, extend = extend.right)
                reward_fill := linefill.new(entry_line, extreme_line, buyFill)
        
        else  // SELL (regime == -1)
            sl_level := entry_price + risk_dist
            tp1_p := entry_price - risk_dist * rr_tp1
            tp2_p := entry_price - risk_dist * rr_tp2
            tp3_p := entry_price - risk_dist * rr_tp3
            extreme_level := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na
            
            entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color = sellLabelColor, width = 1, extend = extend.right)
            entry_label := label.new(bar_index, entry_price, "SELL " + str.tostring(entry_price, format.mintick), style = label.style_label_left, color = sellLabelColor, textcolor = color.white, size = size.small)
            
            if show_sl_level
                sl_line := line.new(bar_index, sl_level, bar_index + 1, sl_level, color = sellColorLight, width = 1, style = line.style_dashed, extend = extend.right)
                sl_label := label.new(bar_index, sl_level, "SL " + str.tostring(sl_level, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small)
            
            if show_tp1_level
                tp1_line := line.new(bar_index, tp1_p, bar_index + 1, tp1_p, color = buyColorLight, width = 1, extend = extend.right)
                tp1_label := label.new(bar_index, tp1_p, "TP1 " + str.tostring(tp1_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
            if show_tp2_level
                tp2_line := line.new(bar_index, tp2_p, bar_index + 1, tp2_p, color = buyColorLight, width = 1, extend = extend.right)
                tp2_label := label.new(bar_index, tp2_p, "TP2 " + str.tostring(tp2_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
            if show_tp3_level
                tp3_line := line.new(bar_index, tp3_p, bar_index + 1, tp3_p, color = buyColorLight, width = 1, style = line.style_dotted, extend = extend.right)
                tp3_label := label.new(bar_index, tp3_p, "TP3 " + str.tostring(tp3_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
            
            if show_sl_level
                risk_fill := linefill.new(entry_line, sl_line, sellFill)
            
            float min_tp_for_fill = entry_price
            if show_tp1_level
                min_tp_for_fill := math.min(min_tp_for_fill, tp1_p)
            if show_tp2_level
                min_tp_for_fill := math.min(min_tp_for_fill, tp2_p)
            if show_tp3_level
                min_tp_for_fill := math.min(min_tp_for_fill, tp3_p)
            if min_tp_for_fill < entry_price
                extreme_line := line.new(bar_index, min_tp_for_fill, bar_index + 1, min_tp_for_fill, color = na, extend = extend.right)
                reward_fill := linefill.new(entry_line, extreme_line, buyFill)

// POSITION UPDATE + CLOSING ON SL/TP
if trade_dir != 0
    if not na(entry_label)
        label.set_x(entry_label, bar_index)
    if not na(sl_label)
        label.set_x(sl_label, bar_index)
    if not na(tp1_label)
        label.set_x(tp1_label, bar_index)
    if not na(tp2_label)
        label.set_x(tp2_label, bar_index)
    if not na(tp3_label)
        label.set_x(tp3_label, bar_index)
    
    bool sl_hit = false
    bool tp_hit = false
    if trade_dir == 1
        sl_hit := low <= sl_level
        tp_hit := not na(extreme_level) and high >= extreme_level
    else if trade_dir == -1
        sl_hit := high >= sl_level
        tp_hit := not na(extreme_level) and low <= extreme_level
    
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

// BAR COLORING
barcolor(colorBarsEnabled ? (regime == 1 ? upColor : downColor) : na)

// MARKERS OB/OS
obOsCircleColor = regime == 1 ? downColor : upColor
plotshape(showOBOSCircles and obEnter, title="OB Enter", location=location.abovebar, color=obOsCircleColor, style=shape.circle, size=size.tiny)
plotshape(showOBOSCircles and osEnter, title="OS Enter", location=location.belowbar, color=obOsCircleColor, style=shape.circle, size=size.tiny)

// OVEREXTENSION 
stLine = regime == 1 ? trailLong : trailShort
distATR = regime == 1 ? (close - stLine) / atr : (stLine - close) / atr
bearOverExt = regime == 1 and trailModifiedAfterFlip and not na(distATR) and distATR >= devThreshold
bullOverExt = regime == -1 and trailModifiedAfterFlip and not na(distATR) and distATR >= devThreshold

// INFO TABLE
var table mpoInfoTable = na

if showInfoTable and barstate.islast

    if not na(mpoInfoTable)
        table.delete(mpoInfoTable)
        mpoInfoTable := na
    
    mpoInfoTable := table.new(finalTablePos, columns = 2, rows = 6, bgcolor = color.new(#1e222d, 70), border_width = 1, frame_color = color.gray)
    
    color rowBg         = color.new(#676767, 15)
    color trendCol      = regime == 1 ? upColor : downColor
    color valueTrendBg  = color.new(trendCol, 75)                    
    color momentumValueBg = osc >= 0 ? color.new(upColor, 65) : color.new(downColor, 65)  
    
    // Table Header
    table.cell(mpoInfoTable, 0, 0, "Parameter", text_color = color.white, bgcolor = color.new(#84878f, 35), text_size = tableSize)
    table.cell(mpoInfoTable, 1, 0, "Value",     text_color = color.white, bgcolor = color.new(#84878f, 35), text_size = tableSize)
  
    // 1. Trend
    string trendText = regime == 1 ? "Bullish" : "Bearish"
    table.cell(mpoInfoTable, 0, 1, "Trend",           text_color = color.white, bgcolor = rowBg, text_size = tableSize)
    table.cell(mpoInfoTable, 1, 1, trendText,         text_color = color.white, bgcolor = valueTrendBg, text_size = tableSize)
  
    // 2. Momentum
    string mpoDir   = osc > osc[1] ? "↑" : osc < osc[1] ? "↓" : "→"
    table.cell(mpoInfoTable, 0, 2, "Momentum",        text_color = color.white, bgcolor = rowBg, text_size = tableSize)
    table.cell(mpoInfoTable, 1, 2, str.tostring(osc, "0.0") + " " + mpoDir, text_color = color.white, bgcolor = momentumValueBg, text_size = tableSize)
  
    // 3. Momentum Zone
    string zoneText = ""
    if osc >= obLevel
        zoneText := "Overbought"
    else if osc <= osLevel
        zoneText := "Oversold"
    else
        zoneText := "Neutral"
    table.cell(mpoInfoTable, 0, 3, "Momentum Zone",   text_color = color.white, bgcolor = rowBg, text_size = tableSize)
    table.cell(mpoInfoTable, 1, 3, zoneText,          text_color = color.white, bgcolor = momentumValueBg, text_size = tableSize)
  
    // 4. Adaptive Mode
    bool   adaptiveActive = momActive and not flipHappens
    string adaptiveText   = adaptiveActive ? "Active" : "Inactive"
    table.cell(mpoInfoTable, 0, 4, "Adaptive Mode",   text_color = color.white, bgcolor = rowBg, text_size = tableSize)
    table.cell(mpoInfoTable, 1, 4, adaptiveText,      text_color = color.white, bgcolor = rowBg, text_size = tableSize)
  
    // 5. ATR Distance
    float distVal = distATR
    string distText = not na(distVal) ? str.tostring(distVal, "0.00") + "x" : "—"
    color distValueBg = (not na(distVal) and distVal >= devThreshold) ? color.new(downColor, 75) : rowBg
    table.cell(mpoInfoTable, 0, 5, "ATR Distance",    text_color = color.white, bgcolor = rowBg, text_size = tableSize)
    table.cell(mpoInfoTable, 1, 5, distText,          text_color = color.white, bgcolor = distValueBg, text_size = tableSize)

// ALERTS
alertcondition(flipHappens and regime == 1, title="Buy Signal", message="SuperTrend Buy")
alertcondition(flipHappens and regime == -1, title="Sell Signal", message="SuperTrend Sell")
alertcondition(obEnter, title="MPO Overbought", message="Oscillator entered Overbought")
alertcondition(osEnter, title="MPO Oversold", message="Oscillator entered Oversold")
alertcondition(bearOverExt, title="Bearish Overextension", message="Large deviation in uptrend – possible pullback")
alertcondition(bullOverExt, title="Bullish Overextension", message="Large deviation in downtrend – possible bounce")
````
