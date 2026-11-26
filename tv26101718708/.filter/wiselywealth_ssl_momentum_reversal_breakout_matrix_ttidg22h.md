# WiselyWealth ; SSL Momentum Reversal & Breakout Matrix

- url: https://www.tradingview.com/script/TTidg22h-WiselyWealth-SSL-Momentum-Reversal-Breakout-Matrix/
- type: indicator
- pine_id: PUB;8d6419ad76674aa28726443240a7d523
- version: 1.0

## Description

**General Information and Purpose**
* The "SSL Momentum Reversal & Breakout Matrix" script was developed using Pine Script version 6 for use on the TradingView platform as a comprehensive trading decision support system.
* The system is specifically designed to detect trend reversals (Momentum Reversals) and price breakouts.
* Its primary objective is to minimize false signals in sideways markets through a 0 to 100 intelligent scoring system, which displays results as percentages and letter grades (A+ to D) to indicate the probability and quality of the trade signal.

**Operating Mechanism and Signal Filters**
* **SSL Channel Core Engine**: The system identifies trends using two moving averages: a High MA and a Low MA. An uptrend is established when the closing price stays above the High MA, while a downtrend is established when it falls below the Low MA.
* **RSI Filter (14)**: A buy signal requires an RSI value greater than 50, and a sell signal requires an RSI value below 50.
* **DMI / ADX Filter (14, 14)**: This is used to measure trend strength, requiring the ADX value to exceed a specified threshold to generate a valid signal.
* **Channel Expansion Filter**: The system compares the width of the SSL channel against Average True Range (ATR) volatility to prevent signals from triggering in markets lacking momentum.
* **Higher Timeframe (HTF) Filter**: This optional feature pulls trend data from a larger timeframe to ensure trades align with the macro trend while strictly preventing repainting.

**Scoring Engine (Out of 100 Points)**
* The signal score calculation is divided into five factors: Price Action (25 points), ADX Dominance (25 points), RSI Momentum (20 points), Relative Volume (15 points), and Channel Expansion (15 points).
* **Penalty Deductions**: The system deducts points if a candlestick leaves an opposing wick longer than 30% of its size, or if the price extends too far from the SSL line (Overextension).
* Signals only appear on the chart once the candlestick is fully closed, ensuring there are no repainting issues or shifting signals.

**Settings and Practical Application**
* **Signal Profile Settings**: Users can choose from three strictness modes: Responsive (fast entries for short-term trading), Balanced (the default, offering a mix of frequency and accuracy), and Selective (maximum safety for highly clear, strong trends).
* **Using HTF**: When trading on lower timeframes, the HTF should be set 4 to 6 times larger than the current chart to help filter out false signals caused by short-term price rebounds.
* **Suitable Markets**: The indicator performs best in clearly trending markets, such as cryptocurrencies (Bitcoin, Ethereum), major Forex pairs during high liquidity periods, stock indices, and gold (XAUUSD).

* It is highly advised not to use this indicator in narrow, sideways, or range-bound markets with low trading volume.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView Community / Antigravity AI
//@version=6

indicator("WiselyWealth ; SSL Momentum Reversal & Breakout Matrix", shorttitle="SSL Reversal &  Breakout Matrix", overlay=true, max_labels_count=500)

// =============================================================================
// 1. INPUT PARAMETERS
// =============================================================================

// --- Group: SSL Parameters ---
maType    = input.string("EMA", "MA Type", options=["SMA", "EMA", "WMA", "HMA", "RMA", "VWMA"], group="SSL Parameters", tooltip="Selects the moving average type used to calculate the High and Low SSL channels (SMA, EMA, WMA, HMA, RMA, VWMA).")
sslLength = input.int(10, "SSL Length", minval=1, group="SSL Parameters", tooltip="Sets the lookback period for the SSL Channel boundary moving averages. Smaller values react faster, while larger values smooth out market noise.")

// --- Group: Signal & Filter Settings ---
signalProfile = input.string("Balanced", "Signal Profile", options=["Responsive", "Balanced", "Selective"], group="Signal & Filter Settings", tooltip="Selects filter strictness. Responsive triggers faster signals, Balanced offers optimal frequency and reliability, while Selective applies strict thresholds for high-probability setups.")
useHTF        = input.bool(false, "Enable HTF Confirmation", group="Signal & Filter Settings", inline="htf", tooltip="Enables Higher Timeframe (HTF) trend alignment to ensure entry signals agree with the larger market direction.")
htfTimeframe  = input.timeframe("60", "HTF Timeframe", group="Signal & Filter Settings", inline="htf", tooltip="Specifies the higher timeframe resolution used to determine the macro SSL trend state.")
showSignals   = input.bool(true, "Show Signals & Labels", group="Signal & Filter Settings", tooltip="Toggles on-chart visibility of buy/sell marker shapes and their corresponding quality score labels.")

// =============================================================================
// 2. HELPER FUNCTIONS & PROFILES CONFIGURATION
// =============================================================================

// คำนวณ Moving Average ตามประเภทที่เลือก
f_ma(float src, int len, string ma_type) =>
    switch ma_type
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "HMA"  => ta.hma(src, len)
        "RMA"  => ta.rma(src, len)
        "VWMA" => ta.vwma(src, len)
        => ta.ema(src, len)

// ปรับค่าให้อยู่ในช่วง min - max
f_clamp(float val, float minVal, float maxVal) =>
    math.min(math.max(val, minVal), maxVal)

// ปรับสเกลให้อยู่ในช่วง 0.0 - 1.0 (Linear Normalization)
f_scale01(float val, float minVal, float maxVal) =>
    maxVal > minVal ? f_clamp((val - minVal) / (maxVal - minVal), 0.0, 1.0) : 0.0

// กำหนดเกรดตามคะแนน (Grade Rating)
f_grade(int score) =>
    if score >= 90
        "A+"
    else if score >= 80
        "A"
    else if score >= 70
        "B"
    else if score >= 60
        "C"
    else
        "D"

// กำหนดค่า Threshold ตาม Signal Profile ที่เลือก
float adxThreshold = switch signalProfile
    "Responsive" => 18.0
    "Selective"  => 25.0
    => 20.0

float widthThreshold = switch signalProfile
    "Responsive" => 0.14
    "Selective"  => 0.28
    => 0.20

int minScoreThreshold = switch signalProfile
    "Responsive" => 65
    "Selective"  => 80
    => 70

// =============================================================================
// 3. SSL CHANNEL CORE ENGINE
// =============================================================================

highMA = f_ma(high, sslLength, maType)
lowMA  = f_ma(low, sslLength, maType)

// State Tracking: 1 = Uptrend, -1 = Downtrend
var int sslState = 1
sslState := close > highMA ? 1 : close < lowMA ? -1 : nz(sslState[1], 1)

// เส้น SSL Line อ้างอิงตามทิศทางแนวโน้ม
sslLine = sslState == 1 ? lowMA : highMA

// ตรวจจับจุดเปลี่ยนแนวโน้ม (Trend Reversal) เมื่อแท่งเทียนปิดยืนยันแล้ว
flipUp   = (sslState == 1 and sslState[1] == -1)
flipDown = (sslState == -1 and sslState[1] == 1)

// =============================================================================
// 4. CONFIRMATION FILTERS
// =============================================================================

// 4.1 RSI Filter (Period 14)
rsiVal  = ta.rsi(close, 14)
buyRSI  = rsiVal > 50.0
sellRSI = rsiVal < 50.0

// 4.2 DMI / ADX Filter (14, 14)
[diPlus, diMinus, adxVal] = ta.dmi(14, 14)
buyADX  = (diPlus > diMinus) and (adxVal > adxThreshold)
sellADX = (diMinus > diPlus) and (adxVal > adxThreshold)

// 4.3 Channel Expansion Filter (วัดความกว้างช่องเทียบกับ ATR)
atrVal          = ta.atr(14)
channelWidth    = math.abs(highMA - lowMA)
normalizedWidth = atrVal > 0.0 ? channelWidth / atrVal : 0.0
channelExpOk    = normalizedWidth >= widthThreshold

// 4.4 Higher Timeframe (HTF) Filter
// คำนวณฟังก์ชัน SSL State สำหรับ Request HTF
f_htfSslState(int len, string ma_t) =>
    hMA = f_ma(high, len, ma_t)
    lMA = f_ma(low, len, ma_t)
    var int st = 1
    st := close > hMA ? 1 : close < lMA ? -1 : nz(st[1], 1)
    st

// ดึงสถานะ HTF โดยใช้ bar ก่อนหน้า [1] และ lookahead_off เพื่อป้องกัน Lookahead Bias / Repainting
htfValid = timeframe.in_seconds(htfTimeframe) > timeframe.in_seconds()
int htfState = request.security(syminfo.tickerid, htfTimeframe, f_htfSslState(sslLength, maType)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

buyHTFConfirmed  = not useHTF or (htfValid and htfState == 1)
sellHTFConfirmed = not useHTF or (htfValid and htfState == -1)

// =============================================================================
// 5. COMPREHENSIVE SCORING ENGINE (0 - 100)
// =============================================================================

candleRange = math.max(high - low, syminfo.mintick)
bodyRatio   = math.abs(close - open) / candleRange

// 5.1 Price Action Score (น้ำหนักสูงสุด 25 คะแนน)
buyCloseLoc  = f_clamp((close - low) / candleRange, 0.0, 1.0)
sellCloseLoc = f_clamp((high - close) / candleRange, 0.0, 1.0)
buyBreakoutDist  = atrVal > 0.0 ? math.max(close - highMA, 0.0) / atrVal : 0.0
sellBreakoutDist = atrVal > 0.0 ? math.max(lowMA - close, 0.0) / atrVal : 0.0

buyPaScore  = (flipUp ? 10.0 : 4.0) + f_scale01(buyBreakoutDist, 0.0, 0.5) * 6.0 + bodyRatio * 5.0 + buyCloseLoc * 4.0
sellPaScore = (flipDown ? 10.0 : 4.0) + f_scale01(sellBreakoutDist, 0.0, 0.5) * 6.0 + bodyRatio * 5.0 + sellCloseLoc * 4.0

// 5.2 RSI Momentum Score (น้ำหนักสูงสุด 20 คะแนน)
buyRsiDelta  = rsiVal - 50.0
sellRsiDelta = 50.0 - rsiVal
buyRsiScore  = f_scale01(buyRsiDelta, 0.0, 20.0) * 15.0 + (rsiVal > rsiVal[1] ? 5.0 : 0.0)
sellRsiScore = f_scale01(sellRsiDelta, 0.0, 20.0) * 15.0 + (rsiVal < rsiVal[1] ? 5.0 : 0.0)

// 5.3 ADX Dominance & Trend Strength Score (น้ำหนักสูงสุด 25 คะแนน)
diSum = math.max(diPlus + diMinus, 0.0001)
buyDiDominance  = f_clamp((diPlus - diMinus) / diSum, 0.0, 1.0)
sellDiDominance = f_clamp((diMinus - diPlus) / diSum, 0.0, 1.0)
buyTrendScore   = (diPlus > diMinus ? 6.0 : 0.0) + f_scale01(adxVal, adxThreshold, adxThreshold + 25.0) * 10.0 + buyDiDominance * 5.0 + (adxVal > adxVal[1] ? 4.0 : 0.0)
sellTrendScore  = (diMinus > diPlus ? 6.0 : 0.0) + f_scale01(adxVal, adxThreshold, adxThreshold + 25.0) * 10.0 + sellDiDominance * 5.0 + (adxVal > adxVal[1] ? 4.0 : 0.0)

// 5.4 Relative Volume Score (น้ำหนักสูงสุด 15 คะแนน)
volumeMA = ta.sma(volume, 20)
relVol   = (not na(volume) and not na(volumeMA) and volumeMA > 0.0) ? volume / volumeMA : na
volScore = na(relVol) ? 7.5 : f_scale01(relVol, 0.8, 2.0) * 15.0

// 5.5 Channel Expansion Context (น้ำหนักสูงสุด 15 คะแนน)
regimeScore = f_scale01(normalizedWidth, widthThreshold * 0.7, widthThreshold * 2.0) * 10.0 + (normalizedWidth > normalizedWidth[1] ? 5.0 : 0.0)

// 5.6 Opposing Wick & Overextension Penalty (หักลบจุดอ่อน)
buyOpposingWick  = (high - math.max(open, close)) / candleRange
sellOpposingWick = (math.min(open, close) - low) / candleRange
sslExtension     = atrVal > 0.0 ? math.abs(close - sslLine) / atrVal : 0.0
buyWickPenalty   = (buyOpposingWick > 0.30 ? buyOpposingWick * 12.0 : 0.0) + f_scale01(sslExtension, 2.0, 3.5) * 8.0
sellWickPenalty  = (sellOpposingWick > 0.30 ? sellOpposingWick * 12.0 : 0.0) + f_scale01(sslExtension, 2.0, 3.5) * 8.0

// รวมคะแนนสุทธิ Buy & Sell (Clamp 0 - 100)
buyRawScore  = buyPaScore + buyRsiScore + buyTrendScore + volScore + regimeScore - buyWickPenalty
sellRawScore = sellPaScore + sellRsiScore + sellTrendScore + volScore + regimeScore - sellWickPenalty
buyScore     = int(math.round(f_clamp(buyRawScore, 0.0, 100.0)))
sellScore    = int(math.round(f_clamp(sellRawScore, 0.0, 100.0)))

// Live Confidence ของเทรนด์ปัจจุบัน
liveConfidence = sslState == 1 ? buyScore : sellScore

// =============================================================================
// 6. SIGNAL GENERATION (REPAINT-PROOF CONFIRMATION)
// =============================================================================

// เงื่อนไขสัญญาณต้องได้รับการยืนยันเมื่อแท่งเทียนปิดเรียบร้อยแล้วเท่านั้น
buySignal  = barstate.isconfirmed and flipUp and buyRSI and buyADX and channelExpOk and buyHTFConfirmed and (buyScore >= minScoreThreshold)
sellSignal = barstate.isconfirmed and flipDown and sellRSI and sellADX and channelExpOk and sellHTFConfirmed and (sellScore >= minScoreThreshold)

// สภาวะเทรนด์อ่อนแรง (Trend Weakening)
trendWeakening = barstate.isconfirmed and (ta.crossunder(normalizedWidth, widthThreshold) or ta.crossunder(adxVal, adxThreshold))

// =============================================================================
// 7. VISUALIZATION & PLOTS
// =============================================================================

// สีกำหนดทิศทางแนวโน้ม
bullishColor = #00E676  // สีเขียวนีออน
bearishColor = #FF1744  // สีแดงนีออน
accentColor  = #7C4DFF  // สีม่วงเสริมมิติ
stateColor   = sslState == 1 ? bullishColor : bearishColor

// Dynamic Gradient Boundary
boundaryColor = color.from_gradient(math.min(normalizedWidth, 1.0), 0.0, 1.0, color.new(accentColor, 60), color.new(stateColor, 15))

// ซ่อนรอยต่อเมื่อเกิดการเปลี่ยนแท่งเพื่อความเรียบเนียน
trendSwitched = not na(sslState[1]) and sslState != sslState[1]
visualSSL     = trendSwitched ? na : sslLine
visualHighMA  = trendSwitched ? na : highMA
visualLowMA   = trendSwitched ? na : lowMA

// พล็อตเส้น SSL Line และขอบ Channel
plot(visualSSL, "SSL Line", color=stateColor, linewidth=2, style=plot.style_linebr)
highGlowPlot = plot(visualHighMA, "High Boundary Glow", color=color.new(boundaryColor, 85), linewidth=4, style=plot.style_linebr)
lowGlowPlot  = plot(visualLowMA, "Low Boundary Glow", color=color.new(boundaryColor, 85), linewidth=4, style=plot.style_linebr)
highPlot     = plot(visualHighMA, "High MA", color=color.new(boundaryColor, 20), linewidth=1, style=plot.style_linebr)
lowPlot      = plot(visualLowMA, "Low MA", color=color.new(boundaryColor, 20), linewidth=1, style=plot.style_linebr)

// เติมสีพื้นหลังแบบไดนามิกตามความกว้างและทิศทางเทรนด์
fillColorTop    = sslState == 1 ? color.new(bullishColor, 80) : color.new(bearishColor, 88)
fillColorBottom = sslState == 1 ? color.new(bullishColor, 92) : color.new(bearishColor, 78)
fill(highPlot, lowPlot, color=sslState == 1 ? color.new(bullishColor, 82) : color.new(bearishColor, 82), title="SSL Channel Fill")

// สัญลักษณ์ลูกศร/สามเหลี่ยมเปิดคำสั่ง
buyMarkerY  = low - atrVal * 0.8
sellMarkerY = high + atrVal * 0.8

plotshape(showSignals and buySignal ? buyMarkerY : na, title="BUY Signal Arrow", style=shape.triangleup, location=location.absolute, color=bullishColor, size=size.small)
plotshape(showSignals and sellSignal ? sellMarkerY : na, title="SELL Signal Arrow", style=shape.triangledown, location=location.absolute, color=bearishColor, size=size.small)

// แสดง Labels ระบุเกรดและคะแนนคุณภาพ
if showSignals and buySignal
    string bText = "BUY  [" + f_grade(buyScore) + "] " + str.tostring(buyScore) + "%"
    label.new(bar_index, buyMarkerY - atrVal * 0.4, bText, yloc=yloc.price, style=label.style_label_up, color=color.new(bullishColor, 10), textcolor=color.black, size=size.small)

if showSignals and sellSignal
    string sText = "SELL  [" + f_grade(sellScore) + "] " + str.tostring(sellScore) + "%"
    label.new(bar_index, sellMarkerY + atrVal * 0.4, sText, yloc=yloc.price, style=label.style_label_down, color=color.new(bearishColor, 10), textcolor=color.white, size=size.small)

// Hidden plots เพื่อส่งต่อค่าให้กับ Alert Message Placeholders
plot(liveConfidence, "Trend Confidence", display=display.none)
plot(buyScore, "Buy Score", display=display.none)
plot(sellScore, "Sell Score", display=display.none)

// =============================================================================
// 8. ALERTS CONFIGURATION
// =============================================================================

alertcondition(buySignal, title="Confirmed BUY Signal", message="{{ticker}} [{{interval}}] | Confirmed BUY Signal | Score: {{plot(\"Buy Score\")}}% | SSL Breakout Matrix")
alertcondition(sellSignal, title="Confirmed SELL Signal", message="{{ticker}} [{{interval}}] | Confirmed SELL Signal | Score: {{plot(\"Sell Score\")}}% | SSL Breakout Matrix")
alertcondition(barstate.isconfirmed and flipUp, title="SSL Trend Flip Up", message="{{ticker}} [{{interval}}] | SSL Trend Flips Bullish | Confidence: {{plot(\"Trend Confidence\")}}%")
alertcondition(barstate.isconfirmed and flipDown, title="SSL Trend Flip Down", message="{{ticker}} [{{interval}}] | SSL Trend Flips Bearish | Confidence: {{plot(\"Trend Confidence\")}}%")
alertcondition(trendWeakening, title="Trend Weakening Warning", message="{{ticker}} [{{interval}}] | Warning: Trend is Weakening / Consolidating | Confidence: {{plot(\"Trend Confidence\")}}%")
````
