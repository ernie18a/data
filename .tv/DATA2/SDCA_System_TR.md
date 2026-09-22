<!-- tradingview-pine-id: PUB;2a845a14e4bc42ccac7482a15570abe5 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# SDCA System | TR

Source: https://www.tradingview.com/script/x6vEUyW9-SDCA-System-TR/

## Description

📊 OVERVIEW
The SDCA System | TR is an advanced trading indicator that combines three powerful technical metrics (RSI, ROC, and Sharpe Ratio) into a single weighted score, then applies a Symmetric Dollar-Cost Averaging (SDCA) strategy to manage entries and exits. This system provides both visual signals and automated position management based on extreme market conditions.

🎯 CORE CONCEPT
The indicator normalizes and smooths three independent indicators, combines them with user-defined weights, and generates buy/sell signals when the combined score crosses predefined thresholds. The SDCA logic then executes position adjustments using a percentage-based allocation model.

🔧 KEY COMPONENTS
1. RSI (Relative Strength Index)
Length: Adjustable (default 42)

Normalized and smoothed using a two-stage exponential smoothing process

Clipped to prevent extreme values

Range: -100 to +100

2. ROC (Rate of Change)
Length: Adjustable (default 14)

Normalized and smoothed with the same double-smoothing technique

Clipped to control sensitivity

Range: -100 to +100

3. Sharpe Ratio
Calculates risk-adjusted returns

Lookback period: Adjustable (default 42)

Includes risk-free rate adjustment

Normalized and smoothed similarly to RSI and ROC

Range: -100 to +100

4. Combined Weighted Score
Weighted average of all three indicators

User-adjustable weights (default: RSI 1.0, ROC 1.0, Sharpe 0.5)

Final score range: -100 to +100

5. SDCA Position Management
Buy Signal: Score ≤ Lower Threshold (default: -80)

Sell Signal: Score ≥ Upper Threshold (default: +80)

Percentage-based allocation per signal (default: 10% of capital)

Tracks capital, position size, average price, and total return

📈 HOW IT WORKS
Normalization Process:
Each raw indicator is calculated

Values are clipped to control outliers

First exponential smoothing applied

Normalized to 0-100 range

Second exponential smoothing applied

Final transformation: (smooth2 - 50) × 2 → Range: -100 to +100

Signal Generation:
BUY when: Weighted Score ≤ Lower Threshold AND not in a sell cycle

SELL when: Weighted Score ≥ Upper Threshold AND not in a buy cycle

Cycle states prevent conflicting signals

Position Management:
Each buy signal invests a fixed percentage of remaining capital

Each sell signal liquidates the same percentage of current position

Tracks:

Remaining capital

Position size (shares/units)

Average entry price

Total portfolio value

Total return percentage

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 01010100 01101001 01100001 01100111 01101111 00100000 01010010 01101111 01100011 01101000 01100001 00100000 1011001
//           ╔══════╗       ████████╗ ████████╗  ████████╗  ███████╗   ██████╗        ██████╗   ██████╗   ██████╗ ██╗   ██╗ ████████╗       ╔══════╗
//           ║ ████ ║       ╚══██╔══╝ ╚══██╔══╝  ██╔═══██║  ██╔════╝  ██╔═══██╗       ██╔══██╗ ██╔═══██╗ ██╔════╝ ██║   ██║ ██╔═══██║       ║ ████ ║
//          ╔╝██████╚╗         ██║       ██║     ████████║  ██║ ███║  ██║   ██║       ██████╔╝ ██║   ██║ ██║      ████████║ ████████║      ╔╝██████╚╗
//          ║║      ║║         ██║       ██║     ██╔═══██║  ██║  ██║  ██║   ██║       ██╔══██╗ ██║   ██║ ██║      ██║   ██║ ██╔═══██║      ║║      ║║
//           ╚╦════╦╝          ██║    ████████╗  ██║   ██║  ███████║  ╚██████╔╝       ██║  ██║ ╚██████╔╝ ╚██████╗ ██║   ██║ ██║   ██║       ╚╦════╦╝
//@version=6
indicator('SDCA System | TR', 'SDCA | TR →', false, precision=2)
import TradingView/ta/14

Color_Mode =    input.string('Classic', 'Color Choice', group = '🎨 Color', options = ['Classic', 'Modern', 'Heat', 'Robust', 'Accented', 'Monochrome', 'Moderate', 'Aqua', 'Cosmic'])
SawRSI =        input.bool(false,'RSI')
SawROC =        input.bool(false,'ROC')
SawSharpe =     input.bool(false,'Sharpe')
//╔═════════════════════════════════════════╗
//║          INPUTS - RSI                   ║
//╚═════════════════════════════════════════╝
RSI_Length =    input.int(42, 'RSI Length', minval=2, maxval=200, step=1, group='RSI Settings')
Source_MA_RSI = input.string('SMA', 'Moving Average', group='📊 RSI MA', inline='RSI MA', options=['EMA', 'SMA', 'RMA', 'WMA', 'VWMA', 'HMA', 'DEMA', 'TEMA', 'TRIMA', 'FRAMA', 'SWMA'])
RSI_MA_Length = input.int(34, 'RSI Smoothing', minval=1, maxval=100, step=1, group='RSI Settings')

//╔═════════════════════════════════════════╗
//║          INPUTS - ROC                   ║
//╚═════════════════════════════════════════╝
ROC_Length =    input.int(14, 'ROC Length', minval=1, maxval=200, step=1, group='ROC Settings')
Source_MA_ROC = input.string('SMA', 'Moving Average', group='📊 ROC MA', inline='ROC MA', options=['EMA', 'SMA', 'RMA', 'WMA', 'VWMA', 'HMA', 'DEMA', 'TEMA', 'TRIMA', 'FRAMA', 'SWMA'])
ROC_MA_Length = input.int(9, 'ROC Smoothing', minval=1, maxval=100, step=1, group='ROC Settings')

//╔═════════════════════════════════════════╗
//║          INPUTS - NORMALIZATION         ║
//╚═════════════════════════════════════════╝
Norm_Length =   input.int(42, 'Normalization Length', minval=5, maxval=200, step=1, group='Normalization')
smoothFact =    input.float(0.20, 'Smoothing Factor', minval=0.01, maxval=1.0, step=0.01, group='Normalization')
Clipping_RSI =  input.int(34, 'RSI Clipping', minval=1, maxval=40, group='Normalization')
Clipping_ROC =  input.float(50, 'ROC Clipping', minval=1, maxval=200, group='Normalization')

//╔═════════════════════════════════════════╗
//║          INPUTS - SHARPE RATIO          ║
//╚═════════════════════════════════════════╝
useSharpeFilter = input.bool(false, 'Enable Sharpe Ratio Filter', group='Sharpe Ratio Settings', tooltip='Filters extreme signals based on Sharpe Ratio')
sharpeLookback = input.int(42, 'Sharpe Lookback', minval=10, maxval=100, step=1, group='Sharpe Ratio Settings', tooltip='Period to calculate Sharpe Ratio')
sharpeRiskFree = input.float(0.02, 'Risk-Free Rate %', minval=0, maxval=10, step=0.1, group='Sharpe Ratio Settings', tooltip='Annualized risk-free rate')
sharpeClipping = input.float(2.0, 'Sharpe Clipping', minval=0.5, maxval=5.0, step=0.1, group='Sharpe Ratio Settings', tooltip='Limit for Sharpe normalization')

//╔═════════════════════════════════════════╗
//║          INPUTS - SDCA                  ║
//╚═════════════════════════════════════════╝
allocationPct = input.float(10, 'Allocation % per day', minval=1, maxval=100, step=1, group='SDCA Settings', tooltip='Percentage of capital to buy/sell per day')
Lower_Threshold = input.int(-80, 'Lower Threshold (BUY)', minval=-100, maxval=100, step=1, group='SDCA Settings', tooltip='Score below = BUY')
Upper_Threshold = input.int(80, 'Upper Threshold (SELL)', minval=-100, maxval=100, step=1, group='SDCA Settings', tooltip='Score above = SELL')
initialCapital = input.float(10000, 'Initial Capital', minval=100, step=100, group='SDCA Settings')

//╔═════════════════════════════════════════╗
//║          INPUTS - WEIGHTS               ║
//╚═════════════════════════════════════════╝
weightRSI = input.float(1.0, 'RSI Weight', minval=0.1, maxval=2.0, step=0.1, group='Indicator Weights', tooltip='RSI weight in the final combination')
weightROC = input.float(1.0, 'ROC Weight', minval=0.1, maxval=2.0, step=0.1, group='Indicator Weights', tooltip='ROC weight in the final combination')
weightSharpe = input.float(0.5, 'Sharpe Weight', minval=0.1, maxval=2.0, step=0.1, group='Indicator Weights', tooltip='Sharpe weight in the final combination')

//╔═════════════════╗
//║     Color       ║
//╚═════════════════╝
[UpC, DnC] = switch Color_Mode
    'Classic'       => [#008800, #ff0000]
    'Modern'        => [#ffffff, #b721ff]
    'Heat'          => [#ff0000, #87cefb]
    'Robust'        => [#ffbb00, #770737]
    'Accented'      => [#8c5cf7, #e83e8c]
    'Monochrome'    => [#e9ecef, #495057]
    'Moderate'      => [#43a047, #e53935]
    'Aqua'          => [#00a8e8, #f18f01]
    'Cosmic'        => [#e83e8c, #6f2da8]

//╔═════════════════════════════════════════╗
//║          MOVING AVERAGE ENGINE          ║
//╚═════════════════════════════════════════╝
ma(source, length, type) =>
     type == 'EMA'   ? ta.ema(source, length) :
     type == 'SMA'   ? ta.sma(source, length) :
     type == 'RMA'   ? ta.rma(source, length) :
     type == 'WMA'   ? ta.wma(source, length) :
     type == 'VWMA'  ? ta.vwma(source, length) :
     type == 'HMA'   ? ta.hma(source, length) :
     type == 'DEMA'  ? ta.dema(source, length) :
     type == 'TEMA'  ? ta.tema(source, length) :
     type == 'TRIMA' ? ta.trima(source, length) :
     type == 'FRAMA' ? ta.frama(source, length) :
     type == 'SWMA'  ? ta.swma(source) :
     na

//╔═════════════════════════════════════════╗
//║          SMOOTHING FUNCTION             ║
//╚═════════════════════════════════════════╝
smoothExp(src, factor) =>
    var float smoothed = na
    smoothed := na(smoothed[1]) ? src : smoothed[1] + factor * (src - smoothed[1])
    smoothed

normalize(src, length) =>
    lowVal  = ta.lowest(src, length)
    highVal = ta.highest(src, length)
    rangeVal = highVal - lowVal
    rangeVal > 0 ? (src - lowVal) / rangeVal * 100 : nz(src[1])

//╔═════════════════════════════════════════╗
//║          SHARPE RATIO ENGINE            ║
//╚═════════════════════════════════════════╝
calculateSharpe(returns, lookback, riskFreeRate) =>
    cumReturns = math.sum(returns, lookback)
    meanReturn = cumReturns / lookback
    
    variance = 0.0
    for i = 0 to lookback - 1
        diff = returns[i] - meanReturn
        variance := variance + diff * diff
    stdDev = math.sqrt(variance / lookback)
    
    riskFreeDaily = riskFreeRate / 252
    sharpe = (meanReturn - riskFreeDaily) / (stdDev + 0.0001)
    sharpe

dailyReturns = (close - close[1]) / close[1]

//╔═════════════════════════════════════════╗
//║          CALCULATE RSI                  ║
//╚═════════════════════════════════════════╝
Normalize_RSI = ta.rsi(close, RSI_Length) - 50
Normalize_RSI := ma(Normalize_RSI, RSI_MA_Length, Source_MA_RSI)
Normalize_RSI := math.max(Normalize_RSI, -Clipping_RSI)
Normalize_RSI := math.min(Normalize_RSI, Clipping_RSI)
normRSI = normalize(Normalize_RSI, Norm_Length)
smooth1 = smoothExp(normRSI, smoothFact)
norm2 = normalize(smooth1, Norm_Length)
smooth2 = smoothExp(norm2, smoothFact)
Final_RSI = (smooth2 - 50) * 2

//╔═════════════════════════════════════════╗
//║          CALCULATE ROC                  ║
//╚═════════════════════════════════════════╝
Normalize_ROC = ta.roc(close, ROC_Length)
Normalize_ROC := ma(Normalize_ROC, ROC_MA_Length, Source_MA_ROC)
Normalize_ROC := math.max(Normalize_ROC, -Clipping_ROC)
Normalize_ROC := math.min(Normalize_ROC, Clipping_ROC)
normROC = normalize(Normalize_ROC, Norm_Length)
smooth1_roc = smoothExp(normROC, smoothFact)
norm2_roc = normalize(smooth1_roc, Norm_Length)
smooth2_roc = smoothExp(norm2_roc, smoothFact)
Final_ROC = (smooth2_roc - 50) * 2

//╔═════════════════════════════════════════╗
//║          CALCULATE NORMALIZED SHARPE    ║
//╚═════════════════════════════════════════╝
rawSharpe = calculateSharpe(dailyReturns, sharpeLookback, sharpeRiskFree / 100)
clippedSharpe = math.max(rawSharpe, -sharpeClipping)
clippedSharpe := math.min(clippedSharpe, sharpeClipping)
normSharpe = normalize(clippedSharpe, Norm_Length)
smooth1_sharpe = smoothExp(normSharpe, smoothFact)
norm2_sharpe = normalize(smooth1_sharpe, Norm_Length)
smooth2_sharpe = smoothExp(norm2_sharpe, smoothFact)
Final_Sharpe = (smooth2_sharpe - 50) * 2

//╔═════════════════════════════════════════╗
//║          COMBINED INDICATOR             ║
//╚═════════════════════════════════════════╝
weightedScore = (Final_RSI * weightRSI + Final_ROC * weightROC + Final_Sharpe * weightSharpe) / (weightRSI + weightROC + weightSharpe)

// ╔══════════════════════════════════════════════════════════════╗
// ║  DEBUG: CHECK CONDITIONS                                     ║
// ╚══════════════════════════════════════════════════════════════╝

// BUY CONDITION: weightedScore <= Lower_Threshold
isExtremeNegative = weightedScore <= Lower_Threshold

// SELL CONDITION: weightedScore >= Upper_Threshold
isExtremePositive = weightedScore >= Upper_Threshold

// DEBUG PLOTS to check conditions
plot(weightedScore, 'Score', color.white, linewidth=2)
plot(Lower_Threshold, 'Lower Th', UpC, linewidth=1)
plot(Upper_Threshold, 'Upper Th', DnC, linewidth=1)

// Plot indicators for when conditions are true
plotshape(isExtremeNegative, title='Score <= Lower', location=location.belowbar, color=color.new(UpC, 70), style=shape.circle, size=size.tiny, force_overlay = true)
plotshape(isExtremePositive, title='Score >= Upper', location=location.abovebar, color=color.new(DnC, 70), style=shape.circle, size=size.tiny, force_overlay = true)

//╔═════════════════════════════════════════╗
//║          SDCA LOGIC                     ║
//╚═════════════════════════════════════════╝
var bool inBuyCycle = false
var bool inSellCycle = false
var bool buySignal = false
var bool sellSignal = false

buySignal := false
sellSignal := false

// BUY: Score <= Lower_Threshold
if isExtremeNegative and not inSellCycle
    buySignal := true
    inBuyCycle := true
    inSellCycle := false

// SELL: Score >= Upper_Threshold
if isExtremePositive and not inBuyCycle
    sellSignal := true
    inSellCycle := true
    inBuyCycle := false

// Exit cycles
if not isExtremeNegative and inBuyCycle
    inBuyCycle := false

if not isExtremePositive and inSellCycle
    inSellCycle := false

//╔═════════════════════════════════════════╗
//║          POSITION & CAPITAL TRACKING    ║
//╚═════════════════════════════════════════╝
var float capital = initialCapital
var float position = 0.0
var float avgPrice = 0.0

dailyAmount = capital * (allocationPct / 100)

if buySignal and inBuyCycle
    sharesToBuy = dailyAmount / close
    position := position + sharesToBuy
    avgPrice := position > 0 ? (avgPrice * (position - sharesToBuy) + close * sharesToBuy) / position : close
    capital := capital - dailyAmount
    
if sellSignal and inSellCycle
    sharesToSell = (position * allocationPct / 100)
    if sharesToSell > 0
        capital := capital + sharesToSell * close
        position := position - sharesToSell
        if position <= 0
            position := 0
            avgPrice := 0

currentValue = capital + position * close
totalReturn = (currentValue - initialCapital) / initialCapital * 100

//╔═════════════════════════════════════════╗
//║          PLOT INDICATORS                ║
//╚═════════════════════════════════════════╝
plotshape(buySignal, 'BUY', shape.triangleup, location.belowbar, UpC, 0, size=size.small, force_overlay=true)
plotshape(sellSignal, 'SELL', shape.triangledown, location.abovebar, DnC, 0, size=size.small, force_overlay=true)

plot(SawRSI ? Final_RSI : na, 'RSI', color.blue, linewidth=1, display=display.pane)
plot(SawROC ? Final_ROC : na, 'ROC', color.orange, linewidth=1, display=display.pane)
plot(SawSharpe ? Final_Sharpe : na, 'Sharpe', color.purple, linewidth=1, display=display.pane)

hline(0, 'Zero', color.gray, linestyle=hline.style_dotted)

//╔═════════════════════════════════════════╗
//║          INFO TABLE                     ║
//╚═════════════════════════════════════════╝
var table infoTable = table.new(position.top_right, 3, 10, border_width=1, border_color=color.gray, bgcolor=color.new(color.black, 85))

if barstate.islast
    table.merge_cells(infoTable, 0, 0, 1, 0)
    table.cell(infoTable, 0, 0, '📊 SDCA ', text_color=color.white, bgcolor=color.new(color.blue, 80), text_size=size.small)
    
    table.cell(infoTable, 0, 1, 'RSI', text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 1, 1, str.tostring(Final_RSI, '#.##'), text_color=color.blue)
    
    table.cell(infoTable, 0, 2, 'ROC', text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 1, 2, str.tostring(Final_ROC, '#.##'), text_color=color.orange)
    
    table.cell(infoTable, 0, 3, 'Sharpe', text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 1, 3, str.tostring(Final_Sharpe, '#.##'), text_color=color.purple)
    
    table.cell(infoTable, 0, 4, 'Score', text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 1, 4, str.tostring(weightedScore, '#.##'), text_color=color.white)
    
    table.cell(infoTable, 0, 5, 'Lower Th (BUY)', text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 1, 5, str.tostring(Lower_Threshold, '#.##'), text_color=color.red)
    
    table.cell(infoTable, 0, 6, 'Upper Th (SELL)', text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 1, 6, str.tostring(Upper_Threshold, '#.##'), text_color=color.green)
    
    table.cell(infoTable, 0, 7, 'Capital', text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 1, 7, '$' + str.tostring(capital, '#.##'), text_color=color.white)
    
    table.cell(infoTable, 0, 8, 'Position', text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 1, 8, str.tostring(position, '0.0000'), text_color=color.white)
    
    table.cell(infoTable, 0, 9, 'Return %', text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(infoTable, 1, 9, str.tostring(totalReturn, '#.##') + '%', text_color=totalReturn >= 0 ? color.green : color.red)

bgcolor(inBuyCycle ? color.new(color.green, 85) : inSellCycle ? color.new(color.red, 85) : na, title='Active Cycle')
````
