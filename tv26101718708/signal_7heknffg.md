# signal

- url: https://www.tradingview.com/script/7HEKnfFG/
- type: indicator
- pine_id: PUB;1706ab42c8b54c21901e37c4b86aa0c0
- version: 2.0

## Description

信号生成器

## Source Code

````pine

//@version=6
indicator("信号生成器", "信号生成器", overlay=true, max_labels_count=500, max_lines_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// Constants
//---------------------------------------------------------------------------------------------------------------------{
DATA                    = #DBDBDB
HEADERS                 = #808080
BACKGROUND              = #161616
BORDERS                 = #2E2E2E

TOP_RIGHT               = '右上'
BOTTOM_RIGHT            = '右下'
BOTTOM_LEFT             = '左下'

TINY                    = '极小'
SMALL                   = '小'
NORMAL                  = '标准'
LARGE                   = '大'
HUGE                    = '极大'

DASHBOARD_GROUP         = '仪表板'

dashboardTooltip        = '启用或禁用仪表板。'
dashboardSizeTooltip    = '选择仪表板大小。'

//---------------------------------------------------------------------------------------------------------------------}
// Inputs
//---------------------------------------------------------------------------------------------------------------------{
grpLogic = '信号逻辑'
requireAllInput = input.bool(true, '要求所有启用的指标一致', group = grpLogic, tooltip = '启用时，所有选中的指标必须一致才能产生信号。禁用时，任一选中的指标即可产生信号。')

grpRisk = '风险管理 (ATR)'
atrLenInput     = input.int(14, 'ATR 周期', group = grpRisk)

enableTpInput   = input.bool(true, '止盈', inline='tp', group = grpRisk)
tpMultInput     = input.float(3, '乘数', inline='tp', step=0.1, group = grpRisk)

enableSlInput   = input.bool(true, '止损', inline='sl', group = grpRisk)
slMultInput     = input.float(1, '乘数', inline='sl', step=0.1, group = grpRisk)

enableTsInput   = input.bool(true, '移动止损', inline='ts', group = grpRisk)
tsMultInput     = input.float(1.0, '乘数', inline='ts', step=0.1, group = grpRisk)

grpVisuals = '可视化'
orbDistInput    = input.float(1.5, '信号距离 (ATR)', group = grpVisuals, step=0.1)
orbSizeInput    = input.int(10, '信号点基础大小', group = grpVisuals, minval=3, maxval=20)

grpSma = 'SMA 交叉'
enableSmaInput      = input.bool(true, '启用 SMA 交叉', group = grpSma)
smaFastLenInput     = input.int(10, '快线周期', minval = 1, group = grpSma)
smaSlowLenInput     = input.int(20, '慢线周期', minval = 1, group = grpSma)

grpRsi = 'RSI 过滤'
enableRsiInput      = input.bool(true, '启用 RSI 过滤', group = grpRsi)
rsiLenInput         = input.int(14, 'RSI 周期', minval = 1, group = grpRsi)
rsiLongLevelInput   = input.float(50, '做多阈值 (高于)', group = grpRsi)
rsiShortLevelInput  = input.float(50, '做空阈值 (低于)', group = grpRsi)

grpMacd = 'MACD 交叉'
enableMacdInput     = input.bool(true, '启用 MACD 交叉', group = grpMacd)
macdFastLenInput    = input.int(12, '快线周期', minval = 1, group = grpMacd)
macdSlowLenInput    = input.int(26, '慢线周期', minval = 1, group = grpMacd)
macdSignalLenInput  = input.int(9, '信号线周期', minval = 1, group = grpMacd)

grpSt = '超级趋势'
enableStInput       = input.bool(true, '启用超级趋势', group = grpSt)
stFactorInput       = input.float(3.0, '因子', minval = 0.1, step = 0.1, group = grpSt)
stLenInput          = input.int(10, '周期', minval = 1, group = grpSt)

grpStoch = '随机指标'
enableStochInput    = input.bool(true, '启用随机指标', group = grpStoch)
stochKInput         = input.int(14, 'K 周期', minval = 1, group = grpStoch)
stochDInput         = input.int(3, 'D 周期', minval = 1, group = grpStoch)
stochSmoothInput    = input.int(3, '平滑', minval = 1, group = grpStoch)

grpBb = '布林带'
enableBbInput       = input.bool(true, '启用布林带趋势', group = grpBb, tooltip = '检测价格在布林带上半区或下半区运行。')
bbLenInput          = input.int(20, '周期', minval = 1, group = grpBb)
bbMultInput         = input.float(2.0, '乘数', minval = 0.1, step = 0.1, group = grpBb)

grpEma = 'EMA 交叉'
enableEmaInput      = input.bool(true, '启用 EMA 交叉', group = grpEma)
emaFastLenInput     = input.int(10, '快线周期', minval = 1, group = grpEma)
emaSlowLenInput     = input.int(20, '慢线周期', minval = 1, group = grpEma)

grpAo = 'AO 指标'
enableAoInput       = input.bool(true, '启用 AO', group = grpAo)

grpSar = '抛物线 SAR'
enableSarInput      = input.bool(true, '启用抛物线 SAR', group = grpSar)
sarStartInput       = input.float(0.02, '起始步长', step=0.01, group = grpSar)
sarIncInput         = input.float(0.02, '增量', step=0.01, group = grpSar)
sarMaxInput         = input.float(0.2, '最大值', step=0.1, group = grpSar)

grpCci = 'CCI 过滤'
enableCciInput      = input.bool(true, '启用 CCI 过滤', group = grpCci)
cciLenInput         = input.int(20, '周期', minval = 1, group = grpCci)
cciLongLevelInput   = input.float(0, '做多阈值 (高于)', group = grpCci)
cciShortLevelInput  = input.float(0, '做空阈值 (低于)', group = grpCci)

grpAdx = 'ADX 过滤'
enableAdxInput      = input.bool(true, '启用 ADX 过滤', group = grpAdx)
adxLenInput         = input.int(14, 'ADX 平滑', minval=1, group=grpAdx)
diLenInput          = input.int(14, 'DI 周期', minval=1, group=grpAdx)
adxThresholdInput   = input.float(20, 'ADX 阈值', group=grpAdx)

dashboardInput          = input.bool(   true,       '仪表板',   group = DASHBOARD_GROUP, tooltip = dashboardTooltip)
dashboardPositionInput  = input.string( TOP_RIGHT,  '指标仪表板位置', group = DASHBOARD_GROUP, options = [TOP_RIGHT,BOTTOM_RIGHT,BOTTOM_LEFT])
perfDashboardPositionIn = input.string( BOTTOM_RIGHT, '绩效仪表板位置', group = DASHBOARD_GROUP, options = [TOP_RIGHT,BOTTOM_RIGHT,BOTTOM_LEFT])
dashboardSizeInput      = input.string( NORMAL,     '大小',         group = DASHBOARD_GROUP, tooltip = dashboardSizeTooltip,      options = [TINY,SMALL,NORMAL,LARGE,HUGE])

//---------------------------------------------------------------------------------------------------------------------}
// Calculations
//---------------------------------------------------------------------------------------------------------------------{
// SMA
smaFast = ta.sma(close, smaFastLenInput)
smaSlow = ta.sma(close, smaSlowLenInput)
smaBullish = smaFast > smaSlow
smaBearish = smaFast < smaSlow

// RSI
rsi = ta.rsi(close, rsiLenInput)
rsiBullish = rsi > rsiLongLevelInput
rsiBearish = rsi < rsiShortLevelInput

// MACD
[macdLine, signalLine, _] = ta.macd(close, macdFastLenInput, macdSlowLenInput, macdSignalLenInput)
macdBullish = macdLine > signalLine
macdBearish = macdLine < signalLine

// Supertrend
[stLine, stDir] = ta.supertrend(stFactorInput, stLenInput)
stBullish = stDir == -1
stBearish = stDir == 1

// Stochastic
k = ta.sma(ta.stoch(close, high, low, stochKInput), stochSmoothInput)
d = ta.sma(k, stochDInput)
stochBullish = k > 50 // Bullish in upper half
stochBearish = k < 50 // Bearish in lower half

// Bollinger Bands (Trend)
[bbMiddle, bbUpper, bbLower] = ta.bb(close, bbLenInput, bbMultInput)
bbBullish = close > bbMiddle
bbBearish = close < bbMiddle

// EMA
emaFast = ta.ema(close, emaFastLenInput)
emaSlow = ta.ema(close, emaSlowLenInput)
emaBullish = emaFast > emaSlow
emaBearish = emaFast < emaSlow

// Awesome Oscillator
ao = ta.sma(hl2, 5) - ta.sma(hl2, 34)
aoBullish = ao > 0
aoBearish = ao < 0

// Parabolic SAR
sar = ta.sar(sarStartInput, sarIncInput, sarMaxInput)
sarBullish = close > sar
sarBearish = close < sar

// CCI
cci = ta.cci(close, cciLenInput)
cciBullish = cci > cciLongLevelInput
cciBearish = cci < cciShortLevelInput

// ADX
[diPlus, diMinus, adx] = ta.dmi(diLenInput, adxLenInput)
adxBullish = adx > adxThresholdInput and diPlus > diMinus
adxBearish = adx > adxThresholdInput and diMinus > diPlus

atr = ta.atr(atrLenInput)

//---------------------------------------------------------------------------------------------------------------------}
// Standalone Performance Tracking
//---------------------------------------------------------------------------------------------------------------------{
bool[] bullArr = array.from(smaBullish, rsiBullish, macdBullish, stBullish, stochBullish, bbBullish, emaBullish, aoBullish, sarBullish, cciBullish, adxBullish)
bool[] bearArr = array.from(smaBearish, rsiBearish, macdBearish, stBearish, stochBearish, bbBearish, emaBearish, aoBearish, sarBearish, cciBearish, adxBearish)

var int[] indStates = array.new_int(11, 0)
var float[] indEntries = array.new_float(11, na)
var float[] indSlLevels = array.new_float(11, na)
var float[] indTpLevels = array.new_float(11, na)
var float[] indTsLevels = array.new_float(11, na)
var int[] indTotalTrades = array.new_int(11, 0)
var int[] indWinTrades = array.new_int(11, 0)
var bool[] prevBullArr = array.new_bool(11, false)
var bool[] prevBearArr = array.new_bool(11, false)

for i = 0 to 10
    bull = bullArr.get(i)
    bear = bearArr.get(i)
    state = indStates.get(i)
    entry = indEntries.get(i)
    sl = indSlLevels.get(i)
    tp = indTpLevels.get(i)
    ts = indTsLevels.get(i)
    
    prevBull = prevBullArr.get(i)
    prevBear = prevBearArr.get(i)
    
    bool indExitLong = false
    bool indExitShort = false
    float indLongExitPrice = na
    float indShortExitPrice = na

    if state == 1
        if enableSlInput and low <= sl
            indExitLong := true
            indLongExitPrice := sl
        else if enableTpInput and high >= tp
            indExitLong := true
            indLongExitPrice := tp
        else if enableTsInput and low <= ts
            indExitLong := true
            indLongExitPrice := ts
        else if bear
            indExitLong := true
            indLongExitPrice := close

    if state == -1
        if enableSlInput and high >= sl
            indExitShort := true
            indShortExitPrice := sl
        else if enableTpInput and low <= tp
            indExitShort := true
            indShortExitPrice := tp
        else if enableTsInput and high >= ts
            indExitShort := true
            indShortExitPrice := ts
        else if bull
            indExitShort := true
            indShortExitPrice := close

    if indExitLong
        ret = ((indLongExitPrice - entry) / entry) * 100
        indTotalTrades.set(i, indTotalTrades.get(i) + 1)
        if ret > 0
            indWinTrades.set(i, indWinTrades.get(i) + 1)
        indStates.set(i, 0)
        indSlLevels.set(i, na)
        indTpLevels.set(i, na)
        indTsLevels.set(i, na)
        state := 0

    if indExitShort
        ret = ((entry - indShortExitPrice) / entry) * 100
        indTotalTrades.set(i, indTotalTrades.get(i) + 1)
        if ret > 0
            indWinTrades.set(i, indWinTrades.get(i) + 1)
        indStates.set(i, 0)
        indSlLevels.set(i, na)
        indTpLevels.set(i, na)
        indTsLevels.set(i, na)
        state := 0

    enterLong = bull and not prevBull and state != 1
    enterShort = bear and not prevBear and state != -1
    
    if enterLong
        indStates.set(i, 1)
        indEntries.set(i, close)
        if enableSlInput
            indSlLevels.set(i, close - (atr * slMultInput))
        if enableTpInput
            indTpLevels.set(i, close + (atr * tpMultInput))
        if enableTsInput
            indTsLevels.set(i, close - (atr * tsMultInput))
        
    if enterShort
        indStates.set(i, -1)
        indEntries.set(i, close)
        if enableSlInput
            indSlLevels.set(i, close + (atr * slMultInput))
        if enableTpInput
            indTpLevels.set(i, close - (atr * tpMultInput))
        if enableTsInput
            indTsLevels.set(i, close + (atr * tsMultInput))

    if state == 1 and not enterLong and enableTsInput
        indTsLevels.set(i, math.max(indTsLevels.get(i), close - (atr * tsMultInput)))
        
    if state == -1 and not enterShort and enableTsInput
        indTsLevels.set(i, math.min(indTsLevels.get(i), close + (atr * tsMultInput)))

    prevBullArr.set(i, bull)
    prevBearArr.set(i, bear)

//---------------------------------------------------------------------------------------------------------------------}
// Signal Logic
//---------------------------------------------------------------------------------------------------------------------{
bool longCond = requireAllInput ? true : false
bool shortCond = requireAllInput ? true : false
bool anyEnabled = false

if enableSmaInput
    longCond := requireAllInput ? (longCond and smaBullish) : (longCond or smaBullish)
    shortCond := requireAllInput ? (shortCond and smaBearish) : (shortCond or smaBearish)
    anyEnabled := true

if enableRsiInput
    longCond := requireAllInput ? (longCond and rsiBullish) : (longCond or rsiBullish)
    shortCond := requireAllInput ? (shortCond and rsiBearish) : (shortCond or rsiBearish)
    anyEnabled := true

if enableMacdInput
    longCond := requireAllInput ? (longCond and macdBullish) : (longCond or macdBullish)
    shortCond := requireAllInput ? (shortCond and macdBearish) : (shortCond or macdBearish)
    anyEnabled := true

if enableStInput
    longCond := requireAllInput ? (longCond and stBullish) : (longCond or stBullish)
    shortCond := requireAllInput ? (shortCond and stBearish) : (shortCond or stBearish)
    anyEnabled := true

if enableStochInput
    longCond := requireAllInput ? (longCond and stochBullish) : (longCond or stochBullish)
    shortCond := requireAllInput ? (shortCond and stochBearish) : (shortCond or stochBearish)
    anyEnabled := true

if enableBbInput
    longCond := requireAllInput ? (longCond and bbBullish) : (longCond or bbBullish)
    shortCond := requireAllInput ? (shortCond and bbBearish) : (shortCond or bbBearish)
    anyEnabled := true

if enableEmaInput
    longCond := requireAllInput ? (longCond and emaBullish) : (longCond or emaBullish)
    shortCond := requireAllInput ? (shortCond and emaBearish) : (shortCond or emaBearish)
    anyEnabled := true

if enableAoInput
    longCond := requireAllInput ? (longCond and aoBullish) : (longCond or aoBullish)
    shortCond := requireAllInput ? (shortCond and aoBearish) : (shortCond or aoBearish)
    anyEnabled := true

if enableSarInput
    longCond := requireAllInput ? (longCond and sarBullish) : (longCond or sarBullish)
    shortCond := requireAllInput ? (shortCond and sarBearish) : (shortCond or sarBearish)
    anyEnabled := true

if enableCciInput
    longCond := requireAllInput ? (longCond and cciBullish) : (longCond or cciBullish)
    shortCond := requireAllInput ? (shortCond and cciBearish) : (shortCond or cciBearish)
    anyEnabled := true

if enableAdxInput
    longCond := requireAllInput ? (longCond and adxBullish) : (longCond or adxBullish)
    shortCond := requireAllInput ? (shortCond and adxBearish) : (shortCond or adxBearish)
    anyEnabled := true

if not anyEnabled
    longCond := false
    shortCond := false

//---------------------------------------------------------------------------------------------------------------------}
// Internal Backtester with Risk Management
//---------------------------------------------------------------------------------------------------------------------{
var int tradeState = 0 // 1 for long, -1 for short
var float entryPrice = na
var float slLevel = na
var float tpLevel = na
var float tsLevel = na

var int totalTrades = 0
var int winTrades = 0
var float netProfitPct = 0.0
var float grossProfit = 0.0
var float grossLoss = 0.0

bool exitLong = false
bool exitShort = false
float longExitPrice = na
float shortExitPrice = na

// 1. Evaluate Exits (Only if currently in a trade)
if tradeState == 1
    if enableSlInput and low <= slLevel
        exitLong := true
        longExitPrice := slLevel
    else if enableTpInput and high >= tpLevel
        exitLong := true
        longExitPrice := tpLevel
    else if enableTsInput and low <= tsLevel
        exitLong := true
        longExitPrice := tsLevel
    else if shortCond
        exitLong := true
        longExitPrice := close

if tradeState == -1
    if enableSlInput and high >= slLevel
        exitShort := true
        shortExitPrice := slLevel
    else if enableTpInput and low <= tpLevel
        exitShort := true
        shortExitPrice := tpLevel
    else if enableTsInput and high >= tsLevel
        exitShort := true
        shortExitPrice := tsLevel
    else if longCond
        exitShort := true
        shortExitPrice := close

// 2. Process Exits & Update Metrics
if exitLong
    float tradeRet = ((longExitPrice - entryPrice) / entryPrice) * 100
    netProfitPct += tradeRet
    totalTrades += 1
    if tradeRet > 0
        winTrades += 1
        grossProfit += tradeRet
    else
        grossLoss += math.abs(tradeRet)
    tradeState := 0
    slLevel := na
    tpLevel := na
    tsLevel := na

if exitShort
    float tradeRet = ((entryPrice - shortExitPrice) / entryPrice) * 100
    netProfitPct += tradeRet
    totalTrades += 1
    if tradeRet > 0
        winTrades += 1
        grossProfit += tradeRet
    else
        grossLoss += math.abs(tradeRet)
    tradeState := 0
    slLevel := na
    tpLevel := na
    tsLevel := na

// 3. Evaluate New Entries
bool enterLong = longCond and not (longCond[1] == true) and tradeState != 1
bool enterShort = shortCond and not (shortCond[1] == true) and tradeState != -1

if enterLong
    tradeState := 1
    entryPrice := close
    if enableSlInput
        slLevel := close - (atr * slMultInput)
    if enableTpInput
        tpLevel := close + (atr * tpMultInput)
    if enableTsInput
        tsLevel := close - (atr * tsMultInput)

if enterShort
    tradeState := -1
    entryPrice := close
    if enableSlInput
        slLevel := close + (atr * slMultInput)
    if enableTpInput
        tpLevel := close - (atr * tpMultInput)
    if enableTsInput
        tsLevel := close + (atr * tsMultInput)

// 4. Update Trailing Stop for Ongoing Trades
if tradeState == 1 and not enterLong and enableTsInput
    tsLevel := math.max(tsLevel, close - (atr * tsMultInput))
    
if tradeState == -1 and not enterShort and enableTsInput
    tsLevel := math.min(tsLevel, close + (atr * tsMultInput))

// 5. Visuals
float longGlowY = enterLong ? low - (atr * orbDistInput) : na
float shortGlowY = enterShort ? high + (atr * orbDistInput) : na

float currentWR = totalTrades > 0 ? (winTrades / totalTrades * 100) : 0
string wrText = str.tostring(currentWR, '#.#') + '%'

if enterLong
    line.new(bar_index, low, bar_index, longGlowY, color=color.new(#089981, 80), width=2)
    line.new(bar_index, low, bar_index, longGlowY, color=color.new(#089981, 40), width=1)
    label.new(bar_index, longGlowY, text=wrText, color=color.new(#000000, 100), textcolor=chart.fg_color, style=label.style_label_up, size=size.tiny)

if enterShort
    line.new(bar_index, high, bar_index, shortGlowY, color=color.new(#f23645, 80), width=2)
    line.new(bar_index, high, bar_index, shortGlowY, color=color.new(#f23645, 40), width=1)
    label.new(bar_index, shortGlowY, text=wrText, color=color.new(#000000, 100), textcolor=chart.fg_color, style=label.style_label_down, size=size.tiny)

plot(longGlowY, title="做多光晕1", style=plot.style_circles, linewidth=orbSizeInput, color=color.new(#089981, 80))
plot(longGlowY, title="做多光晕2", style=plot.style_circles, linewidth=math.max(1, orbSizeInput - 3), color=color.new(#089981, 50))
plot(longGlowY, title="做多光晕3", style=plot.style_circles, linewidth=math.max(1, orbSizeInput - 6), color=color.new(#089981, 0))

plot(shortGlowY, title="做空光晕1", style=plot.style_circles, linewidth=orbSizeInput, color=color.new(#f23645, 80))
plot(shortGlowY, title="做空光晕2", style=plot.style_circles, linewidth=math.max(1, orbSizeInput - 3), color=color.new(#f23645, 50))
plot(shortGlowY, title="做空光晕3", style=plot.style_circles, linewidth=math.max(1, orbSizeInput - 6), color=color.new(#f23645, 0))

// Exit Labels (Only plot if closed by SL/TP/TS and not immediately reversed)
plotshape(exitLong and not enterShort, title="退出多头", style=shape.xcross, location=location.abovebar, color=#f23645, size=size.tiny)
plotshape(exitShort and not enterLong, title="退出空头", style=shape.xcross, location=location.belowbar, color=#089981, size=size.tiny)

// Active Trade Levels
colorSl = tradeState != 0 and enableSlInput ? ((enterLong or enterShort) ? na : color.new(#f23645, 0)) : na
colorTp = tradeState != 0 and enableTpInput ? ((enterLong or enterShort) ? na : color.new(#089981, 0)) : na

plot(tradeState != 0 and enableSlInput ? slLevel : na, title="止损", color=colorSl, style=plot.style_linebr, linewidth=1)
plot(tradeState != 0 and enableTpInput ? tpLevel : na, title="止盈", color=colorTp, style=plot.style_linebr, linewidth=1)

float tsPlotVal = tradeState != 0 and enableTsInput and not (enterLong or enterShort) ? tsLevel : na
p_ts = plot(tsPlotVal, title="移动止损", color=color.new(#2962ff, 0), style=plot.style_linebr, linewidth=2)

float tsTopVal = tradeState == 1 ? close : tradeState == -1 ? tsLevel : na
float tsBotVal = tradeState == 1 ? tsLevel : tradeState == -1 ? close : na
color tsTopCol = tradeState == 1 ? color.new(#2962ff, 70) : tradeState == -1 ? color.new(#2962ff, 100) : na
color tsBotCol = tradeState == 1 ? color.new(#2962ff, 100) : tradeState == -1 ? color.new(#2962ff, 70) : na

p_price = plot(tradeState != 0 and enableTsInput and not (enterLong or enterShort) ? close : na, title="Price for TS", display=display.none)
fill(p_ts, p_price, tsTopVal, tsBotVal, tsTopCol, tsBotCol)

//---------------------------------------------------------------------------------------------------------------------}
// Dashboard
//---------------------------------------------------------------------------------------------------------------------{
var parsedDashboardPosition = switch dashboardPositionInput
    TOP_RIGHT       => position.top_right
    BOTTOM_RIGHT    => position.bottom_right
    BOTTOM_LEFT     => position.bottom_left

var parsedPerfPosition = switch perfDashboardPositionIn
    TOP_RIGHT       => position.top_right
    BOTTOM_RIGHT    => position.bottom_right
    BOTTOM_LEFT     => position.bottom_left

var parsedDashboardSize     = switch dashboardSizeInput
    TINY            => size.tiny
    SMALL           => size.small
    NORMAL          => size.normal
    LARGE           => size.large
    HUGE            => size.huge

cell(table t, int column, int row, string data, color txt_color = #FFFFFF, string align = text.align_right, color bg_color = na, float height = 0) => 
    t.cell(column, row, data, text_color = txt_color, text_size = parsedDashboardSize, text_halign = align, bgcolor = bg_color, height = height)

divider(table t, int row, int lastColumn) =>    
    string rowDivider = '━━━━━━━━━━━━━━'
    t.merge_cells(0, row, lastColumn, row)
    cell(t, 0, row, rowDivider, align = text.align_center, height = 0.5, txt_color = BORDERS)

var table t_able = table.new(parsedDashboardPosition, 4, 30    
     , bgcolor          = BACKGROUND    
     , border_width     = 0    
     , frame_color      = BORDERS
     , frame_width      = 1
     , force_overlay    = true)

var table t_perf = table.new(parsedPerfPosition, 6, 10    
     , bgcolor          = BACKGROUND    
     , border_width     = 0    
     , frame_color      = BORDERS
     , frame_width      = 1
     , force_overlay    = true)

// Performance background gradient
c_gradStart = color.rgb(18, 20, 26)
c_gradEnd = color.rgb(32, 36, 48)

f_perf_bg(c, maxC, isHeader) => 
    baseCol = color.from_gradient(c, 0, maxC, c_gradStart, c_gradEnd)
    isHeader ? color.new(baseCol, 30) : baseCol

// Helper function for status strings and colors
f_status(bull, bear) =>
    statusStr = bull ? '看涨' : bear ? '看跌' : '中性'
    statusColor = bull ? #089981 : bear ? #f23645 : HEADERS
    [statusStr, statusColor]

// Histogram generator
f_hist(win, total) =>
    wr = total > 0 ? (win / total * 100) : 0
    blocks = math.max(0, math.min(10, int(math.round(wr / 10))))
    histStr = ''
    for i = 1 to 10
        if i <= blocks
            histStr += '█'
        else
            histStr += '░'
            
    colorHist = wr >= 50 ? #089981 : (total == 0 ? DATA : #f23645)
    [histStr + '  ' + str.tostring(wr, '#.#') + '%', colorHist]

// Row render helper
f_render_row(tbl, r, name, bullStr, bullCol, win, total, enabled) =>
    [hist, histCol] = f_hist(win, total)
    cell(tbl, 0, r, name, txt_color = DATA, align = text.align_left, bg_color = f_perf_bg(0, 3, false))
    cell(tbl, 1, r, bullStr, txt_color = bullCol, align = text.align_center, bg_color = f_perf_bg(1, 3, false))
    cell(tbl, 2, r, hist, txt_color = histCol, align = text.align_left, bg_color = f_perf_bg(2, 3, false))
    cell(tbl, 3, r, enabled ? '✓' : '✗', txt_color = enabled ? #089981 : #f23645, align = text.align_right, bg_color = f_perf_bg(3, 3, false))

if dashboardInput and barstate.islast
    // Calculate performance metrics
    winRate = totalTrades > 0 ? (winTrades / totalTrades * 100) : 0
    profitFactor = grossLoss > 0 ? (grossProfit / grossLoss) : (grossProfit > 0 ? 999 : 0)

    [smaStr, smaCol]        = f_status(smaBullish, smaBearish)
    [rsiStr, rsiCol]        = f_status(rsiBullish, rsiBearish)
    [macdStr, macdCol]      = f_status(macdBullish, macdBearish)
    [stStr, stCol]          = f_status(stBullish, stBearish)
    [stochStr, stochCol]    = f_status(stochBullish, stochBearish)
    [bbStr, bbCol]          = f_status(bbBullish, bbBearish)
    
    [emaStr, emaCol]        = f_status(emaBullish, emaBearish)
    [aoStr, aoCol]          = f_status(aoBullish, aoBearish)
    [sarStr, sarCol]        = f_status(sarBullish, sarBearish)
    [cciStr, cciCol]        = f_status(cciBullish, cciBearish)
    [adxStr, adxCol]        = f_status(adxBullish, adxBearish)

    signalStatusStr = longCond ? '做多' : shortCond ? '做空' : '中性'
    signalColor = longCond ? #089981 : shortCond ? #f23645 : HEADERS

    // ----------------- Indicator Dashboard ----------------- //
    int r = 0

    // Title
    t_able.merge_cells(0, r, 3, r)
    cell(t_able, 0, r, '指标仪表板', txt_color = DATA, align = text.align_center, bg_color = color.rgb(12, 14, 18))                  
    r += 1

    divider(t_able, r, 3)
    r += 1

    // Headers
    cell(t_able, 0, r, '指标', txt_color = HEADERS, align = text.align_left, bg_color = f_perf_bg(0, 3, true))            
    cell(t_able, 1, r, '状态',    txt_color = HEADERS, align = text.align_center, bg_color = f_perf_bg(1, 3, true))
    cell(t_able, 2, r, '独立胜率',  txt_color = HEADERS, align = text.align_left, bg_color = f_perf_bg(2, 3, true))
    cell(t_able, 3, r, '启用',   txt_color = HEADERS, align = text.align_right, bg_color = f_perf_bg(3, 3, true))
    r += 1

    divider(t_able, r, 3)
    r += 1

    // Indicators
    f_render_row(t_able, r, 'SMA 交叉', smaStr, smaCol, indWinTrades.get(0), indTotalTrades.get(0), enableSmaInput)
    r += 1
    divider(t_able, r, 3)
    r += 1

    f_render_row(t_able, r, 'RSI', rsiStr, rsiCol, indWinTrades.get(1), indTotalTrades.get(1), enableRsiInput)
    r += 1
    divider(t_able, r, 3)
    r += 1
    
    f_render_row(t_able, r, 'MACD', macdStr, macdCol, indWinTrades.get(2), indTotalTrades.get(2), enableMacdInput)
    r += 1
    divider(t_able, r, 3)
    r += 1

    f_render_row(t_able, r, '超级趋势', stStr, stCol, indWinTrades.get(3), indTotalTrades.get(3), enableStInput)
    r += 1
    divider(t_able, r, 3)
    r += 1

    f_render_row(t_able, r, '随机指标', stochStr, stochCol, indWinTrades.get(4), indTotalTrades.get(4), enableStochInput)
    r += 1
    divider(t_able, r, 3)
    r += 1

    f_render_row(t_able, r, '布林带', bbStr, bbCol, indWinTrades.get(5), indTotalTrades.get(5), enableBbInput)
    r += 1
    divider(t_able, r, 3)
    r += 1
    
    f_render_row(t_able, r, 'EMA 交叉', emaStr, emaCol, indWinTrades.get(6), indTotalTrades.get(6), enableEmaInput)
    r += 1
    divider(t_able, r, 3)
    r += 1
    
    f_render_row(t_able, r, 'AO', aoStr, aoCol, indWinTrades.get(7), indTotalTrades.get(7), enableAoInput)
    r += 1
    divider(t_able, r, 3)
    r += 1
    
    f_render_row(t_able, r, 'SAR', sarStr, sarCol, indWinTrades.get(8), indTotalTrades.get(8), enableSarInput)
    r += 1
    divider(t_able, r, 3)
    r += 1
    
    f_render_row(t_able, r, 'CCI', cciStr, cciCol, indWinTrades.get(9), indTotalTrades.get(9), enableCciInput)
    r += 1
    divider(t_able, r, 3)
    r += 1
    
    f_render_row(t_able, r, 'ADX 过滤', adxStr, adxCol, indWinTrades.get(10), indTotalTrades.get(10), enableAdxInput)
    r += 1
    divider(t_able, r, 3)
    r += 1

    // Current Combined Signal
    t_able.merge_cells(0, r, 2, r)
    cell(t_able, 0, r, '当前信号', txt_color = HEADERS, align = text.align_left, bg_color = f_perf_bg(0, 3, false))
    cell(t_able, 3, r, signalStatusStr, txt_color = signalColor, align = text.align_right, bg_color = f_perf_bg(3, 3, false))

    // ----------------- Performance Dashboard ----------------- //
    int pR = 0

    t_perf.merge_cells(0, pR, 5, pR)
    cell(t_perf, 0, pR, '回测结果', txt_color = DATA, align = text.align_center, bg_color = color.rgb(12, 14, 18))                  
    pR += 1

    divider(t_perf, pR, 5)
    pR += 1

    cell(t_perf, 0, pR, '总交易', txt_color = HEADERS, align = text.align_center, bg_color = f_perf_bg(0, 5, true))            
    cell(t_perf, 1, pR, '盈利笔数',         txt_color = HEADERS, align = text.align_center, bg_color = f_perf_bg(1, 5, true))
    cell(t_perf, 2, pR, '亏损笔数',       txt_color = HEADERS, align = text.align_center, bg_color = f_perf_bg(2, 5, true))
    cell(t_perf, 3, pR, '胜率',      txt_color = HEADERS, align = text.align_center, bg_color = f_perf_bg(3, 5, true))
    cell(t_perf, 4, pR, '盈亏比',           txt_color = HEADERS, align = text.align_center, bg_color = f_perf_bg(4, 5, true))
    cell(t_perf, 5, pR, '净利润 %',        txt_color = HEADERS, align = text.align_center, bg_color = f_perf_bg(5, 5, true))
    pR += 1

    divider(t_perf, pR, 5)
    pR += 1

    int lossTrades = totalTrades - winTrades

    cell(t_perf, 0, pR, str.tostring(totalTrades), txt_color = DATA, align = text.align_center, bg_color = f_perf_bg(0, 5, false))            
    cell(t_perf, 1, pR, str.tostring(winTrades),   txt_color = DATA, align = text.align_center, bg_color = f_perf_bg(1, 5, false))
    cell(t_perf, 2, pR, str.tostring(lossTrades),  txt_color = DATA, align = text.align_center, bg_color = f_perf_bg(2, 5, false))
    cell(t_perf, 3, pR, str.tostring(winRate, '#.##') + ' %', txt_color = winRate >= 50 ? #089981 : (totalTrades == 0 ? DATA : #f23645), align = text.align_center, bg_color = f_perf_bg(3, 5, false))
    cell(t_perf, 4, pR, profitFactor == 999 ? 'MAX' : str.tostring(profitFactor, '#.##'), txt_color = profitFactor > 1 ? #089981 : (profitFactor == 0 ? DATA : #f23645), align = text.align_center, bg_color = f_perf_bg(4, 5, false))
    cell(t_perf, 5, pR, str.tostring(netProfitPct, '#.##') + ' %', txt_color = netProfitPct > 0 ? #089981 : netProfitPct < 0 ? #f23645 : DATA, align = text.align_center, bg_color = f_perf_bg(5, 5, false))

//---------------------------------------------------------------------------------------------------------------------}
````
