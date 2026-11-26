# Madrimov Ribbon Pullback 

- url: https://www.tradingview.com/script/SkYBgdvF-Madrimov-Ribbon-Pullback/
- type: indicator
- pine_id: PUB;14ffdf24b0ef4248a202c655e5a3edc8
- version: 2.0

## Description

Madrimov Ribbon Pullback 
A trend-continuation strategy indicator built for crypto futures trading. Combines the Madrid Moving Average Ribbon with Smart Money Concepts (internal structure) to identify high-quality pullback entries in clean trending markets.
How it works:
The indicator waits for 3 things to align before firing a signal:

Clean Ribbon Trend — The Madrid Ribbon (MA75–MA90) must be clearly sloping with visible band separation. Flat or compressed ribbons are ignored automatically.
Pullback to Ribbon — Price must pull back into the ribbon zone, not just trade near it.
Structure Confirmation — A CHoCH or BOS must form at the ribbon, confirming buyers (or sellers) are stepping in.

Only when all 3 conditions align does a BUY or SELL signal fire.
Features:

Auto HTF bias filter (higher timeframe trend must agree)
ATR-based TP1, TP2, and SL levels
Clean/Weak ribbon status shown in info table
Fully adjustable slope and separation sensitivity
Built-in alerts for BUY and SELL signals

Best used on: 15m, 30m, 1H timeframes on crypto perpetual contracts.
Built for: @Madrimov_trade (telegram)

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  Madrimov Ribbon Pullback Strategy v2                                       ║
// ║  Based on: Madrid Moving Average Ribbon + LuxAlgo SMC (Internal Only)      ║
// ║  Built for: @Madrimov_trade                                                 ║
// ║  FIX v2: Clean ribbon slope + separation filter added                       ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

//@version=6
indicator('Madrimov Ribbon Pullback v2', shorttitle='Madrimov RP', overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=200)

// ─────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────
color C_BULL   = color.new(#6b8f7a, 0)
color C_BEAR   = color.new(#2f2a25, 0)
color C_BULL_T = color.new(#6b8f7a, 80)
color C_BEAR_T = color.new(#2f2a25, 80)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────
grp_ribbon = 'Ribbon Settings'
grp_smc    = 'Structure Settings'
grp_entry  = 'Entry Settings'
grp_risk   = 'Risk Management'

i_exp      = input.bool(true,  'Exponential MA',                        group=grp_ribbon)
i_showRib  = input.bool(true,  'Show Ribbon',                           group=grp_ribbon)

i_slopeLen  = input.int(5,    'Slope Lookback (bars)',     group=grp_ribbon, minval=2, maxval=20)
i_slopeMult = input.float(0.05, 'Slope Sensitivity',       group=grp_ribbon, step=0.01, minval=0.01)
i_sepMult   = input.float(0.15, 'Separation Sensitivity',  group=grp_ribbon, step=0.01, minval=0.01)

i_showInt  = input.bool(true,  'Show Internal Structure (CHoCH / BOS)', group=grp_smc)
i_intSize  = input.string('tiny', 'Label Size',                         group=grp_smc, options=['tiny', 'small', 'normal'])
labelSize  = i_intSize == 'tiny' ? size.tiny : i_intSize == 'small' ? size.small : size.normal

i_confirm  = input.bool(true,  'Wait for candle confirmation (close)',  group=grp_entry)
i_showSig  = input.bool(true,  'Show Buy / Sell signals',               group=grp_entry)
i_showTP   = input.bool(true,  'Show TP / SL levels',                  group=grp_entry)
i_lineLen  = input.int(100,   'TP/SL Line Length (bars)',              group=grp_entry, minval=20, maxval=500)

i_atrLen   = input.int(14,    'ATR Length',          group=grp_risk, minval=1)
i_tp1Mult  = input.float(2.0, 'TP1 ATR Multiplier',  group=grp_risk, step=0.5)
i_tp2Mult  = input.float(4.0, 'TP2 ATR Multiplier',  group=grp_risk, step=0.5)
i_slMult   = input.float(1.5, 'SL ATR Multiplier',   group=grp_risk, step=0.5)

// ─────────────────────────────────────────────────────────────
// AUTO HTF
// ─────────────────────────────────────────────────────────────
tf_secs = timeframe.in_seconds()
htf = tf_secs <= 300   ? '60'  :
      tf_secs <= 1800  ? '240' :
      tf_secs <= 14400 ? '1D'  : '1W'

// ─────────────────────────────────────────────────────────────
// MADRID RIBBON
// ─────────────────────────────────────────────────────────────
ma(src, len) => i_exp ? ta.ema(src, len) : ta.sma(src, len)

ma75 = ma(close, 75)
ma80 = ma(close, 80)
ma85 = ma(close, 85)
ma90 = ma(close, 90)

ribbonTop = math.max(ma75, ma90)
ribbonBot = math.min(ma75, ma90)

htf_ma75 = request.security(syminfo.tickerid, htf, i_exp ? ta.ema(close, 75) : ta.sma(close, 75))
htf_ma90 = request.security(syminfo.tickerid, htf, i_exp ? ta.ema(close, 90) : ta.sma(close, 90))

htfBullish = htf_ma75 > htf_ma90
htfBearish = htf_ma75 < htf_ma90

ribbonBullish = ma75 > ma90
ribbonBearish = ma75 < ma90

// ─────────────────────────────────────────────────────────────
// CLEAN RIBBON FILTER — THE KEY FIX
// ─────────────────────────────────────────────────────────────
atr = ta.atr(i_atrLen)

ribbon_slope_up   = ma75 - ma75[i_slopeLen]
ribbon_slope_down = ma75[i_slopeLen] - ma75
ribbon_separation = math.abs(ma75 - ma90)

cleanBullRibbon = ribbonBullish and (ribbon_slope_up   > atr * i_slopeMult) and (ribbon_separation > atr * i_sepMult)
cleanBearRibbon = ribbonBearish and (ribbon_slope_down > atr * i_slopeMult) and (ribbon_separation > atr * i_sepMult)

color ribbonCol = cleanBullRibbon ? C_BULL_T : cleanBearRibbon ? C_BEAR_T : color.new(color.gray, 92)

p75 = plot(i_showRib ? ma75 : na, color=ribbonCol, linewidth=2, title='MA75')
p80 = plot(i_showRib ? ma80 : na, color=ribbonCol, linewidth=1, title='MA80')
p85 = plot(i_showRib ? ma85 : na, color=ribbonCol, linewidth=1, title='MA85')
p90 = plot(i_showRib ? ma90 : na, color=ribbonCol, linewidth=2, title='MA90')
fill(p75, p90, color=ribbonCol, title='Ribbon Fill')

// ─────────────────────────────────────────────────────────────
// INTERNAL STRUCTURE
// ─────────────────────────────────────────────────────────────
int BULLISH = 1
int BEARISH = -1

var float intHighLevel   = na
var float intLowLevel    = na
var bool  intHighCrossed = false
var bool  intLowCrossed  = false
var int   intHighTime    = na
var int   intLowTime     = na
var int   intHighIdx     = na
var int   intLowIdx      = na
var int   intTrend       = 0

highest5 = ta.highest(high, 5)
lowest5  = ta.lowest(low, 5)

var int iLeg = 0
if high[5] > highest5
    iLeg := 0
else if low[5] < lowest5
    iLeg := 1

newIntPivot  = ta.change(iLeg) != 0
intPivotLow  = ta.change(iLeg) ==  1
intPivotHigh = ta.change(iLeg) == -1

if newIntPivot
    if intPivotLow
        intLowLevel   := low[5]
        intLowCrossed := false
        intLowTime    := time[5]
        intLowIdx     := bar_index[5]
    if intPivotHigh
        intHighLevel   := high[5]
        intHighCrossed := false
        intHighTime    := time[5]
        intHighIdx     := bar_index[5]

bullStructure = not na(intHighLevel) and not intHighCrossed and ta.crossover(close, intHighLevel)
bearStructure = not na(intLowLevel)  and not intLowCrossed  and ta.crossunder(close, intLowLevel)

string bullTag = na
string bearTag = na

if bullStructure
    bullTag        := intTrend == BEARISH ? 'CHoCH' : 'BOS'
    intHighCrossed := true
    intTrend       := BULLISH

if bearStructure
    bearTag       := intTrend == BULLISH ? 'CHoCH' : 'BOS'
    intLowCrossed := true
    intTrend      := BEARISH

if i_showInt and bullStructure and not na(bullTag)
    line.new(chart.point.new(intHighTime, na, intHighLevel), chart.point.new(time, na, intHighLevel), xloc=xloc.bar_time, color=C_BULL, style=line.style_dashed)
    label.new(chart.point.new(na, math.round(0.5 * (intHighIdx + bar_index)), intHighLevel), bullTag, xloc=xloc.bar_index, color=color(na), textcolor=C_BULL, style=label.style_label_down, size=labelSize)

if i_showInt and bearStructure and not na(bearTag)
    line.new(chart.point.new(intLowTime, na, intLowLevel), chart.point.new(time, na, intLowLevel), xloc=xloc.bar_time, color=C_BEAR, style=line.style_dashed)
    label.new(chart.point.new(na, math.round(0.5 * (intLowIdx + bar_index)), intLowLevel), bearTag, xloc=xloc.bar_index, color=color(na), textcolor=C_BEAR, style=label.style_label_up, size=labelSize)

// ─────────────────────────────────────────────────────────────
// PULLBACK DETECTION
// ─────────────────────────────────────────────────────────────
inRibbon = low <= ribbonTop and high >= ribbonBot

var bool ribbonTouched = false
if inRibbon
    ribbonTouched := true
if bearStructure
    ribbonTouched := false
if bullStructure
    ribbonTouched := false

bullPullback = cleanBullRibbon and ribbonTouched[1] and bullStructure
bearPullback = cleanBearRibbon and ribbonTouched[1] and bearStructure

// ─────────────────────────────────────────────────────────────
// SIGNAL CONDITIONS
// ─────────────────────────────────────────────────────────────
rawBuy  = htfBullish and bullPullback and (not na(bullTag))
rawSell = htfBearish and bearPullback and (not na(bearTag)) and not cleanBullRibbon

buySignal  = i_confirm ? (rawBuy  and barstate.isconfirmed) : rawBuy
sellSignal = i_confirm ? (rawSell and barstate.isconfirmed) : rawSell

// ─────────────────────────────────────────────────────────────
// SCREENER OUTPUTS
// ─────────────────────────────────────────────────────────────
grp_screener   = 'Screener'
i_recentWindow = input.int(10, 'Recent Signal Window (bars)', group=grp_screener, minval=1)

barsSinceBuy  = ta.barssince(buySignal)
barsSinceSell = ta.barssince(sellSignal)

recentBuy  = not na(barsSinceBuy)  and barsSinceBuy  <= i_recentWindow
recentSell = not na(barsSinceSell) and barsSinceSell <= i_recentWindow

plot(buySignal  ? 1 : 0, title='BUY (this bar)')
plot(sellSignal ? 1 : 0, title='SELL (this bar)')
plot(recentBuy  ? 1 : 0, title='BUY (recent)')
plot(recentSell ? 1 : 0, title='SELL (recent)')
plot(barsSinceBuy,  title='Bars Since BUY')
plot(barsSinceSell, title='Bars Since SELL')

// ─────────────────────────────────────────────────────────────
// ATR & LEVELS
// ─────────────────────────────────────────────────────────────
var float entryPrice = na
var float tp1        = na
var float tp2        = na
var float sl         = na
var int   sigDir     = 0

if buySignal
    entryPrice := close
    tp1        := close + i_tp1Mult * atr
    tp2        := close + i_tp2Mult * atr
    sl         := close - i_slMult  * atr
    sigDir     := 1

if sellSignal
    entryPrice := close
    tp1        := close - i_tp1Mult * atr
    tp2        := close - i_tp2Mult * atr
    sl         := close + i_slMult  * atr
    sigDir     := -1

// ─────────────────────────────────────────────────────────────
// PLOT SIGNALS
// ─────────────────────────────────────────────────────────────
if i_showSig and buySignal
    label.new(bar_index, low - atr * 0.5, '▲ BUY\n' + str.tostring(close, '#.####'), color=C_BULL, textcolor=color.white, style=label.style_label_up, size=size.tiny)

if i_showSig and sellSignal
    label.new(bar_index, high + atr * 0.5, '▼ SELL\n' + str.tostring(close, '#.####'), color=C_BEAR, textcolor=color.white, style=label.style_label_down, size=size.tiny)

var line tp1Line = na
var line tp2Line = na
var line entLine = na
var line slLine  = na

if i_showTP and (buySignal or sellSignal)
    if not na(tp1Line)
        tp1Line.delete()
        tp2Line.delete()
        entLine.delete()
    if not na(slLine)
        slLine.delete()

    color tpCol   = sigDir == 1 ? C_BULL : C_BEAR
    int   lineEnd = bar_index + i_lineLen

    tp1Line := line.new(bar_index, tp1,        lineEnd, tp1,        color=tpCol,      style=line.style_dashed, width=1)
    tp2Line := line.new(bar_index, tp2,        lineEnd, tp2,        color=tpCol,      style=line.style_dashed, width=2)
    slLine  := line.new(bar_index, sl,         lineEnd, sl,         color=C_BEAR,     style=line.style_solid,  width=2)
    entLine := line.new(bar_index, entryPrice, lineEnd, entryPrice, color=color.gray, style=line.style_dotted, width=1)

    label.new(bar_index, tp1,        'TP1', color=color(na), textcolor=tpCol,      style=label.style_label_right, size=size.tiny)
    label.new(bar_index, tp2,        'TP2', color=color(na), textcolor=tpCol,      style=label.style_label_right, size=size.tiny)
    label.new(bar_index, sl,         'SL',  color=color(na), textcolor=C_BEAR,     style=label.style_label_right, size=size.tiny)
    label.new(bar_index, entryPrice, 'ENT', color=color(na), textcolor=color.gray, style=label.style_label_right, size=size.tiny)

// ─────────────────────────────────────────────────────────────
// INFO TABLE
// ─────────────────────────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 3, frame_width=1, frame_color=color.new(color.gray, 70))

if barstate.islast
    string htfLabel   = 'HTF (' + htf + ')'
    string htfTrend   = htfBullish ? '▲ BULL' : htfBearish ? '▼ BEAR' : '— NEUTRAL'
    color  htfColor   = htfBullish ? C_BULL : C_BEAR

    string localLabel = 'TF (' + timeframe.period + ')'
    string localTrend = cleanBullRibbon ? '▲ BULL' : cleanBearRibbon ? '▼ BEAR' : ribbonBullish ? '~ WEAK BULL' : ribbonBearish ? '~ WEAK BEAR' : '— NEUTRAL'
    color  localColor = cleanBullRibbon ? C_BULL : cleanBearRibbon ? C_BEAR : color.gray

    string sigText    = sigDir == 1 ? 'LONG' : sigDir == -1 ? 'SHORT' : 'WAIT'
    color  sigColor   = sigDir == 1 ? C_BULL : sigDir == -1 ? C_BEAR : color.gray

    color bg = color.new(color.black, 80)

    table.cell(infoTable, 0, 0, htfLabel,   text_color=color.gray, bgcolor=bg, text_size=size.tiny)
    table.cell(infoTable, 1, 0, htfTrend,   text_color=htfColor,   bgcolor=bg, text_size=size.tiny)
    table.cell(infoTable, 0, 1, localLabel, text_color=color.gray, bgcolor=bg, text_size=size.tiny)
    table.cell(infoTable, 1, 1, localTrend, text_color=localColor, bgcolor=bg, text_size=size.tiny)
    table.cell(infoTable, 0, 2, 'Signal',   text_color=color.gray, bgcolor=bg, text_size=size.tiny)
    table.cell(infoTable, 1, 2, sigText,    text_color=sigColor,   bgcolor=bg, text_size=size.tiny)

// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────
alertcondition(buySignal,  'Ribbon Pullback BUY',  'Madrimov Ribbon Pullback — BUY signal fired')
alertcondition(sellSignal, 'Ribbon Pullback SELL', 'Madrimov Ribbon Pullback — SELL signal fired')
````
