# Buy/Sell Signal (KenshinC)

- url: https://www.tradingview.com/script/JeLzjqCc-Buy-Sell-Signal-KenshinC/
- type: indicator
- pine_id: PUB;61aff5df690f4fa2936b701fe514f2e1
- version: 1.0

## Description

### Buy/Sell Signal (KenshinC) 

This custom indicator helps traders identify potential BUY and SELL opportunities by combining:
- Two independent RSI calculations (one from Low, one from High)
- 3-bar price action patterns
- Long-term and short-term Moving Average trend filters

---

### KEY FEATURES
- Dual Separate RSI System (Buy RSI on Low + Sell RSI on High)
- 3 Consecutive Bars Momentum Confirmation
- Dynamic MA Threshold Filters
- Clean visual plots (EMA 5/10/20, SMA 50/200, Long & Short MA)
- Real-time Information Table
- Built-in Alert Conditions

---

### HOW TO USE

**1. Adding the Indicator**
1. Open your chart on TradingView
2. Click "Indicators" → Search "Buy/Sell Signal (KenshinC)"
3. Add to chart

**2. Main Settings**

**RSI Buy Settings**
- RSI Buy Source: Low (default)
- RSI Buy Length: 14
- RSI Buy Level: 15.0 (Buy when below this)

**RSI Sell Settings**
- RSI Sell Source: High (default)
- RSI Sell Length: 14
- RSI Sell Level: 80.0 (Sell when above this)

**Trend Filter**
- MA Long-term (Buy Filter): 365 periods
- % Below MA Long-term for Buy: 10%
- MA Short-term (Sell Filter): 32 periods
- % Above MA Short-term for Sell: 70%

**Display Settings**
- Show Table: On/Off
- Table Position: Top Right, Top Left, etc.

---

### SIGNAL CONDITIONS

**BUY Signal** (Large Green Triangle)
All conditions must be true:
- 3 consecutive down bars
- RSI Buy < Buy Level
- Price < Long-term MA by at least X%
- Price < Short-term MA

**SELL Signal** (Large Red Triangle)
All conditions must be true:
- 3 consecutive up bars
- RSI Sell > Sell Level
- Price > Short-term MA by at least X%
- Price > Long-term MA

---

### RECOMMENDED USAGE
- Best performance on higher timeframes (1H, 4H, Daily, Weekly)
- Use together with support/resistance and volume
- Always wait for candle close before entering
- Enable alerts for real-time notification
- Monitor the information table to check signal readiness

---

### IMPORTANT DISCLAIMER

**This indicator is for educational and entertainment purposes only.**

It is **NOT** financial advice, investment recommendation, or trading advice. 
Past performance does not guarantee future results. 
Trading carries a high level of risk and you may lose all your capital. 

Always conduct your own research and consult a professional financial advisor before making any trading decisions.

---

**Created by KenshinC**

## Source Code

````pine
//@version=6
indicator("Buy/Sell Signal (KenshinC) - Separate RSI", overlay = true, max_labels_count = 500)

// ==================== USER INPUTS ====================

// === RSI Buy Settings ===
rsiBuySource   = input.source(low,     title = "RSI Buy Source",      group = "RSI Buy Settings")
rsiBuyLength   = input.int(14,         title = "RSI Buy Length",      minval = 1, group = "RSI Buy Settings")
rsiBuyLevel    = input.float(15.0,     title = "RSI Buy Level (<)",   minval = 0, step = 0.1, group = "RSI Buy Settings")

// === RSI Sell Settings ===
rsiSellSource  = input.source(high,    title = "RSI Sell Source",     group = "RSI Sell Settings")
rsiSellLength  = input.int(14,         title = "RSI Sell Length",     minval = 1, group = "RSI Sell Settings")
rsiSellLevel   = input.float(80.0,     title = "RSI Sell Level (>)",  minval = 0, step = 0.1, group = "RSI Sell Settings")

// Trend Filter
maBuyLength    = input.int(365,        title = "MA Length - Long-term (Buy Filter)", minval = 1, group = "Trend Filter")
maBuyPercent   = input.float(10.0,     title = "% Below MA Long-term for Buy", minval = 0.0, step = 0.1, group = "Trend Filter")

maSellLength   = input.int(32,         title = "MA Length - Short-term (Sell Filter)", minval = 1, group = "Trend Filter")
maSellPercent  = input.float(70.0,     title = "% Above MA Short-term for Sell", minval = 0.0, step = 0.1, group = "Trend Filter")

// ==================== CALCULATIONS ====================

// RSI Buy (separate)
upBuy   = ta.rma(math.max(ta.change(rsiBuySource), 0), rsiBuyLength)
downBuy = ta.rma(-math.min(ta.change(rsiBuySource), 0), rsiBuyLength)
rsiBuy  = downBuy == 0 ? 100 : upBuy == 0 ? 0 : 100 - (100 / (1 + upBuy / downBuy))

// RSI Sell (separate)
upSell   = ta.rma(math.max(ta.change(rsiSellSource), 0), rsiSellLength)
downSell = ta.rma(-math.min(ta.change(rsiSellSource), 0), rsiSellLength)
rsiSell  = downSell == 0 ? 100 : upSell == 0 ? 0 : 100 - (100 / (1 + upSell / downSell))

// Pattern
insideBar = high <= high[1] and low >= low[1]
threeDown = close < close[1] and close[1] < close[2]
threeUp   = close > close[1] and close[1] > close[2]

// Moving Averages
maLongTerm   = ta.sma(close, maBuyLength)
maShortTerm  = ta.sma(close, maSellLength)

buyThreshold  = maLongTerm  * (1 - maBuyPercent / 100)
sellThreshold = maShortTerm * (1 + maSellPercent / 100)

// Distance %
distLongPct  = (close - maLongTerm) / maLongTerm * 100
distShortPct = (close - maShortTerm) / maShortTerm * 100

// ==================== SIGNALS ====================

buySignal  = threeDown and rsiBuy < rsiBuyLevel and close < buyThreshold and close < maShortTerm
sellSignal = threeUp and rsiSell > rsiSellLevel and close > sellThreshold and close > maLongTerm

// ==================== PLOTTING ====================

plot(ta.ema(close, 5),   color = color.blue,  linewidth = 1, title = "EMA 5")
plot(ta.ema(close, 10),  color = color.blue,  linewidth = 1, title = "EMA 10")
plot(ta.ema(close, 20),  color = color.red,   linewidth = 1, title = "EMA 20")
plot(ta.sma(close, 50),  color = color.red,   linewidth = 1, title = "SMA 50")
plot(ta.sma(close, 200), color = color.red,   linewidth = 1, title = "SMA 200")

plot(maLongTerm,  color = color.new(color.green, 20), linewidth = 4, title = "MA Long-term (365)")
plot(maShortTerm, color = color.new(color.orange, 20), linewidth = 4, title = "MA Short-term (32)")

plot(buyThreshold,  color = color.new(color.lime, 50), style = plot.style_linebr, title = "Buy Threshold")
plot(sellThreshold, color = color.new(color.red, 50),  style = plot.style_linebr, title = "Sell Threshold")

plotshape(insideBar,  title = "Inside Bar", style = shape.diamond, location = location.bottom, color = color.blue, size = size.small)
plotshape(buySignal,  title = "BUY Signal",  style = shape.triangleup,   location = location.bottom, color = color.lime, size = size.large, text = "BUY", textcolor = color.white)
plotshape(sellSignal, title = "SELL Signal", style = shape.triangledown, location = location.top,    color = color.red,  size = size.large, text = "SELL", textcolor = color.white)

// ==================== ALERTS ====================

alertcondition(buySignal,  title = "BUY Alert",  message = "3 Bars Down + RSI Buy Low + Below MA365 10% AND Below MA32 → BUY")
alertcondition(sellSignal, title = "SELL Alert", message = "3 Bars Up + RSI Sell High + Above MA32 70% AND Above MA365 → SELL")
````
