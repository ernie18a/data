# Domination PRO

- url: https://www.tradingview.com/script/ZRehLXT9-Domination-PRO/
- type: indicator
- pine_id: PUB;1335b2661c774da5a67189541b5e7d47
- version: 1.0

## Description

Domination PRO is a **dual-layer trend and volatility indicator** designed to identify market dominance conditions using a combination of **multi-timeframe moving averages** and an **ATR-based trend reversal system**.

It highlights when buyers or sellers are in control and provides clear visual shifts in momentum, helping traders align with the strongest side of the market.

---

### 🔍 Core Concept

This tool combines:

* Higher timeframe trend bias (Long-Term MA)
* Lower timeframe execution trend (Short-Term MA)
* ATR-based dynamic trend structure

Together, they define whether the market is in:

* Bullish dominance
* Bearish dominance
* Transitional / mixed conditions

---

### 📊 Key Features

• **Multi-Timeframe Moving Average System**

* Long-term MA (macro trend filter)
* Short-term MA (execution trend)
* Fully customisable MA types (SMA or EMA)
* Separate timeframe control for each MA

• **Market Regime Background**

* Green zones → bullish dominance
* Red zones → bearish dominance
* Mixed zones → transitional market structure

• **ATR-Based Trend Engine**

* Adaptive volatility-based trend detection
* Automatically adjusts to market conditions
* Identifies trend flips with precision

• **Clear Buy / Sell Signals**

* Buy: Trend reversal from bearish → bullish
* Sell: Trend reversal from bullish → bearish
* Visual arrows for immediate interpretation

• **Clean Visual Structure**

* Background highlighting for market bias
* Trend lines for directional clarity
* Optional signal labels for confirmation

---

### 📊 How to Use

**Bullish Market Condition**

* Price above both moving averages
→ Market is in buyer dominance phase

**Bearish Market Condition**

* Price below both moving averages
→ Market is in seller dominance phase

**Trend Reversal Signals**

* ATR trend flips direction
→ Potential shift in market structure

---

### ⚠️ Best Practice

For best results, combine with:

* Market structure (BOS / CHoCH)
* Liquidity zones
* Support & resistance levels
* Higher timeframe confirmation

This indicator performs best as a **trend filter + timing tool**, not a standalone entry system.

---

### 🚀 Ideal For

* Trend-following traders
* Crypto and forex markets
* Swing and intraday strategies
* Market structure-based trading
* Volatility breakout strategies

---

### 🧠 Trading Philosophy

**One timeframe shows noise.
Multiple timeframes show dominance.
This tool reveals who is in control.**

---

**Trade with structure. Follow dominance. Avoid uncertainty.**

## Source Code

````pine



//@version=6
indicator('Domination 1', overlay = true)

// Input for Moving Averages
longTermMAType = input.string('SMA', title = 'Long-Term MA Type', options = ['SMA', 'EMA'])
shortTermMAType = input.string('SMA', title = 'Short-Term MA Type', options = ['SMA', 'EMA'])
longTermLength = input.int(75, title = 'Long-Term MA Period')
shortTermLength = input.int(14, title = 'Short-Term MA Period')
longTermTimeframe = input.timeframe('', title = 'Long-Term Timeframe') // Input for choosing the long-term timeframe
shortTermTimeframe = input.timeframe('15', title = 'Short-Term Timeframe') // Input for choosing the short-term timeframe

// Get the moving averages for different timeframes
longTermMA = request.security(syminfo.tickerid, longTermTimeframe, longTermMAType == 'SMA' ? ta.sma(open, longTermLength) : ta.ema(open, longTermLength))
shortTermMA = request.security(syminfo.tickerid, shortTermTimeframe, shortTermMAType == 'SMA' ? ta.sma(open, shortTermLength) : ta.ema(open, shortTermLength))

// Logic for background color
bgcolor(open > longTermMA and open > shortTermMA ? color.rgb(39, 255, 6, 85) : open > longTermMA and open < shortTermMA ? color.rgb(39, 255, 6, 90) : open < longTermMA and open < shortTermMA ? color.rgb(255, 0, 0, 85) : open < longTermMA and open > shortTermMA ? color.rgb(255, 0, 0, 90) : na)

// Plot MAs for reference
//plot(longTermMA, color=#2efc00, title="Long-Term MA")
//plot(shortTermMA, color=color.rgb(51, 255, 10), title="Short-Term MA")




// wma crossing rules



//inputs
Periods = input(title = 'ATR Period', defval = 2)
src = input(open, title = 'Source')
Multiplier = input.float(title = 'ATR Multiplier', step = 0.1, defval = 2.3)
showsignals = input(title = 'Show Buy/Sell Signals ?', defval = false)
highlighting = input(title = 'Highlighter On/Off ?', defval = true)
barcoloring = input(title = 'Bar Coloring On/Off ?', defval = true)


atr = ta.atr(Periods)
up = src - Multiplier * atr
up1 = nz(up[1], up)
up := open[1] > up1 ? math.max(up, up1) : up
dn = src + Multiplier * atr
dn1 = nz(dn[1], dn)
dn := open[1] < dn1 ? math.min(dn, dn1) : dn
trend = 1
trend := nz(trend[1], trend)
trend := trend == -1 and open > dn1 ? 1 : trend == 1 and open < up1 ? -1 : trend
upPlot = plot(trend == 1 ? up : na, title = 'Up Trend', style = plot.style_linebr, linewidth = 2, color = color.new(color.green, 0))

buySignal = trend == 1 and trend[1] == -1

plotshape(buySignal ? up : na, title = 'UpTrend Begins', location = location.absolute, style = shape.arrowup, size = size.huge, color = color.rgb(242, 255, 4))
plotshape(buySignal and showsignals ? up : na, title = 'Buy', text = 'Bullish', location = location.absolute, style = shape.labelup, size = size.tiny, color = color.new(color.green, 0), textcolor = color.new(color.white, 0))

dnPlot = plot(trend == 1 ? na : dn, title = 'Down Trend', style = plot.style_linebr, linewidth = 2, color = color.new(color.red, 0))

sellSignal = trend == -1 and trend[1] == 1

plotshape(sellSignal ? dn : na, title = 'DownTrend Begins', location = location.absolute, style = shape.arrowdown, size = size.huge, color = color.rgb(242, 255, 4))
plotshape(sellSignal and showsignals ? dn : na, title = 'Sell', text = 'Bearish', location = location.absolute, style = shape.labeldown, size = size.tiny, color = color.new(color.red, 0), textcolor = color.new(color.white, 0))

mPlot = plot(ohlc4, title = '', style = plot.style_circles, linewidth = math.max(1, 0))

longFillColor = highlighting ? trend == 1 ? #4caf4f58 : color.white : color.white
shortFillColor = highlighting ? trend == -1 ? #ff52525e : color.white : color.white

fill(mPlot, upPlot, title = 'UpTrend Highligter', color = longFillColor)
fill(mPlot, dnPlot, title = 'DownTrend Highligter', color = shortFillColor)
````
