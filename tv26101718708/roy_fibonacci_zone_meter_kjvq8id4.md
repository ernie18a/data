# Roy Fibonacci Zone Meter

- url: https://www.tradingview.com/script/KJvQ8Id4/
- type: indicator
- pine_id: PUB;9f7fafc1d9c54572ae9792773bcbbba8
- version: 1.0

## Description

ROY FIBONACCI ZONE METER

Roy Fibonacci Zone Meter is an advanced Fibonacci-based market structure and zone strength indicator designed to help traders visualize market positioning, trend direction, support & resistance interaction, and real-time Fibonacci pressure zones in a clean and mobile-friendly dashboard.

Unlike traditional Fibonacci retracement tools that require manual drawing, this indicator automatically creates a dynamic Fibonacci channel using live market range detection and transforms it into a smart probability-based zone meter system.

This indicator is specially optimized for TradingView mobile users with a compact dashboard layout that minimizes chart clutter while still providing powerful market structure analysis.

━━━━━━━━━━━━━━━━━━

FEATURES

• Automatic Fibonacci Channel
• Smart Zone Strength Meter
• Uptrend / Downtrend / Sideway Detection
• Real-Time Price Position Analysis
• Dynamic Support & Resistance Zones
• Active Fibonacci Zone Detection
• Market Mode Analysis
• EMA Trend Filter
• Mobile-Friendly Compact Dashboard
• Dynamic Fibonacci Heatmap
• Zone Interaction Probability System

━━━━━━━━━━━━━━━━━━

FIBONACCI STRUCTURE

The indicator automatically calculates Fibonacci zones using the highest and lowest market range based on the selected lookback period.

Main Fibonacci Zones:

• 1.000 → Extreme Resistance
• 0.764 → Upper Resistance Zone
• 0.618 → Sell Pressure Zone
• 0.500 → Equilibrium / Golden Zone
• 0.382 → Mid Support Zone
• 0.236 → Lower Support Zone
• 0.000 → Extreme Support

━━━━━━━━━━━━━━━━━━

HOW TO READ THE INDICATOR

1. TREND

The Trend section automatically detects current market direction.

• UPTREND
→ Buyers are dominant.

• DOWNTREND
→ Sellers are dominant.

• SIDEWAY
→ Market is ranging without strong direction.

━━━━━━━━━━━━━━━━━━

2. ACTIVE ZONE

Shows the current Fibonacci area where price is trading.

Example:

0.382 ↔ 0.500

This means price is currently moving between the 0.382 and 0.500 Fibonacci zones.

━━━━━━━━━━━━━━━━━━

3. POWER

Displays the strongest Fibonacci interaction level currently affecting the market.

Example:

99% VERY STRONG

This means price is heavily interacting with an important Fibonacci zone and reaction probability is high.

━━━━━━━━━━━━━━━━━━

4. POSITION %

Shows where current price is located within the entire Fibonacci range.

Example:

• 80%+ → Near upper resistance
• 50% → Equilibrium zone
• Below 30% → Near support area

━━━━━━━━━━━━━━━━━━

5. MARKET MODE

The indicator detects current market behavior.

Possible readings:

• ACCUMULATION
→ Sideway / balance market.

• BULL FLOW
→ Healthy bullish continuation.

• BULL EXP
→ Strong bullish expansion.

• BEAR FLOW
→ Healthy bearish continuation.

• BEAR EXP
→ Strong bearish expansion.

━━━━━━━━━━━━━━━━━━

6. BIAS

Shows current market bias.

Possible readings:

• BUY AREA
• SELL AREA
• TAKE PROFIT AREA
• NEUTRAL
• WAIT

This helps traders identify possible market conditions without relying on traditional buy/sell signals.

━━━━━━━━━━━━━━━━━━

7. FIB ZONE METER

The Fibonacci Zone Meter displays the interaction strength between current price and each Fibonacci level.

Higher percentage means:

• Price is closer to that Fibonacci level
• Market interaction is stronger
• Higher probability of support/resistance reaction

Example:

0.382 → 99%

This means price is strongly interacting with the 0.382 support zone.

━━━━━━━━━━━━━━━━━━

HOW TO USE

BEST METHOD:

1. Identify overall trend direction
2. Observe Active Zone location
3. Watch which Fibonacci zone has highest strength
4. Combine with:
   • Price Action
   • Volume
   • EMA Trend
   • Market Structure
   • Liquidity Sweep
   • Higher Timeframe Confirmation

━━━━━━━━━━━━━━━━━━

EXAMPLE USAGE

UPTREND:

• Wait for retracement into:
• 0.382
• 0.500
• 0.618

• Look for bullish candle confirmation.

DOWNTREND:

• Wait for pullback into resistance zones.

• Watch for bearish rejection.

SIDEWAY MARKET:

• Trade inside support & resistance ranges carefully.

━━━━━━━━━━━━━━━━━━

BEST TIMEFRAMES

• Scalping → M1 / M5
• Intraday → M15 / M30
• Swing → H1 / H4
• Position → Daily

━━━━━━━━━━━━━━━━━━

DISCLAIMER

This indicator is designed for educational and analytical purposes only. Always use proper risk management before entering any trade.

## Source Code

````pine
//@version=6
indicator("Roy Fibonacci Zone Meter", shorttitle="RF Zone Meter", overlay=true)

// ================= INPUT =================
fibLen     = input.int(265, "Fibonacci Lookback", minval=20)
emaLen     = input.int(200, "EMA Trend Filter", minval=20)
sidewayPct = input.float(0.15, "Sideway Sensitivity %", step=0.05)

showEMA  = input.bool(true, "Show EMA")
showDash = input.bool(true, "Show Compact Mobile Panel")

// ================= CORE =================
swingHigh = ta.highest(high, fibLen)
swingLow  = ta.lowest(low, fibLen)
rangeFib  = swingHigh - swingLow

fib100 = swingHigh
fib764 = swingHigh - 0.236 * rangeFib
fib618 = swingHigh - 0.382 * rangeFib
fib500 = swingHigh - 0.500 * rangeFib
fib382 = swingLow + 0.382 * rangeFib
fib236 = swingLow + 0.236 * rangeFib
fib000 = swingLow

// ================= TREND =================
emaTrend = ta.ema(close, emaLen)
emaSlope = emaTrend - emaTrend[10]
sidewayLimit = close * sidewayPct / 100

uptrend   = close > emaTrend and emaSlope > sidewayLimit
downtrend = close < emaTrend and emaSlope < -sidewayLimit
sideway   = not uptrend and not downtrend

trendText = uptrend ? "UPTREND" : downtrend ? "DOWNTREND" : "SIDEWAY"
trendCol  = uptrend ? color.lime : downtrend ? color.red : color.yellow

// ================= POSITION =================
pricePosRaw = rangeFib > 0 ? ((close - swingLow) / rangeFib) * 100 : 0
pricePos = math.max(0, math.min(100, pricePosRaw))

activeZone =
     close >= fib764 ? "0.764↔1.000"
   : close >= fib618 ? "0.618↔0.764"
   : close >= fib500 ? "0.500↔0.618"
   : close >= fib382 ? "0.382↔0.500"
   : close >= fib236 ? "0.236↔0.382"
   : "0.000↔0.236"

// ================= STRENGTH =================
distToLevel(level) =>
    rangeFib > 0 ? math.abs(close - level) / rangeFib * 100 : 100

strength(level) =>
    d = distToLevel(level)
    math.round(math.max(0, math.min(100, 100 - d * 5)))

s100 = strength(fib100)
s764 = strength(fib764)
s618 = strength(fib618)
s500 = strength(fib500)
s382 = strength(fib382)
s236 = strength(fib236)
s000 = strength(fib000)

maxStrength = math.max(s100, math.max(s764, math.max(s618, math.max(s500, math.max(s382, math.max(s236, s000))))))

strongText =
     maxStrength >= 80 ? "VERY STRONG"
   : maxStrength >= 60 ? "STRONG"
   : maxStrength >= 40 ? "MEDIUM"
   : maxStrength >= 20 ? "WEAK"
   : "FAR"

marketMode =
     sideway ? "ACCUMULATION"
   : uptrend and pricePos > 70 ? "BULL EXP"
   : uptrend ? "BULL FLOW"
   : downtrend and pricePos < 30 ? "BEAR EXP"
   : downtrend ? "BEAR FLOW"
   : "BALANCE"

bias =
     uptrend and pricePos < 40 ? "BUY AREA"
   : uptrend and pricePos > 75 ? "TP AREA"
   : downtrend and pricePos > 60 ? "SELL AREA"
   : downtrend and pricePos < 25 ? "TP AREA"
   : "NEUTRAL"

// ================= MINI BAR =================
barTxt(val) =>
    val >= 90 ? "██████" :
     val >= 75 ? "█████░" :
     val >= 60 ? "████░░" :
     val >= 45 ? "███░░░" :
     val >= 30 ? "██░░░░" :
     val >= 15 ? "█░░░░░" : "░░░░░░"

reading(val) =>
    val >= 80 ? "Strongest" :
     val >= 60 ? "Strong" :
     val >= 40 ? "Medium" :
     val >= 20 ? "Weak" :
     "Far"

// ================= PLOT =================
p100 = plot(fib100, "1.000", color=color.white, linewidth=1)
p764 = plot(fib764, "0.764", color=color.blue, linewidth=1)
p618 = plot(fib618, "0.618", color=color.blue, linewidth=2)
p500 = plot(fib500, "0.500", color=color.lime, linewidth=2)
p382 = plot(fib382, "0.382", color=color.green, linewidth=2)
p236 = plot(fib236, "0.236", color=color.red, linewidth=1)
p000 = plot(fib000, "0.000", color=color.white, linewidth=1)

fill(p100, p764, color=color.new(color.red, 88))
fill(p764, p618, color=color.new(color.blue, 88))
fill(p618, p500, color=color.new(color.green, 85))
fill(p500, p382, color=color.new(color.green, 85))
fill(p382, p236, color=color.new(color.blue, 88))
fill(p236, p000, color=color.new(color.red, 88))

plot(showEMA ? emaTrend : na, "EMA Trend", color=color.orange, linewidth=2)

// ================= COMPACT DASHBOARD =================
var table dash = table.new(position.bottom_right, 4, 12, border_width=1)

if showDash and barstate.islast
    table.cell(dash, 0, 0, "RF", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 0, "ZONE", text_color=color.purple, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 0, "METER", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 0, "", bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 1, "Trend", text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=size.tiny)
    table.cell(dash, 1, 1, trendText, text_color=trendCol, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 1, "Zone", text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=size.tiny)
    table.cell(dash, 3, 1, activeZone, text_color=color.lime, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 2, "Power", text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=size.tiny)
    table.cell(dash, 1, 2, str.tostring(maxStrength) + "%", text_color=color.lime, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 2, strongText, text_color=color.lime, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 2, bias, text_color=color.yellow, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 3, "Pos", text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(pricePos, "#.##") + "%", text_color=color.lime, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 3, "Mode", text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=size.tiny)
    table.cell(dash, 3, 3, marketMode, text_color=color.aqua, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 4, "Fib", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 4, "Meter", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 4, "%", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 4, "Read", text_color=color.white, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 5, "1.000", text_color=color.red, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 5, barTxt(s100), text_color=color.red, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 5, str.tostring(s100) + "%", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 5, reading(s100), text_color=s100 >= 60 ? color.lime : color.red, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 6, "0.764", text_color=color.blue, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 6, barTxt(s764), text_color=color.blue, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 6, str.tostring(s764) + "%", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 6, reading(s764), text_color=s764 >= 60 ? color.lime : color.gray, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 7, "0.618", text_color=color.blue, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 7, barTxt(s618), text_color=color.blue, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 7, str.tostring(s618) + "%", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 7, reading(s618), text_color=s618 >= 60 ? color.lime : color.gray, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 8, "0.500", text_color=color.lime, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 8, barTxt(s500), text_color=color.lime, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 8, str.tostring(s500) + "%", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 8, reading(s500), text_color=s500 >= 60 ? color.lime : color.gray, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 9, "0.382", text_color=color.green, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 9, barTxt(s382), text_color=color.green, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 9, str.tostring(s382) + "%", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 9, reading(s382), text_color=s382 >= 60 ? color.lime : color.gray, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 10, "0.236", text_color=color.red, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 10, barTxt(s236), text_color=color.red, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 10, str.tostring(s236) + "%", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 10, reading(s236), text_color=s236 >= 60 ? color.lime : color.gray, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 11, "0.000", text_color=color.red, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 11, barTxt(s000), text_color=color.red, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 11, str.tostring(s000) + "%", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 11, reading(s000), text_color=s000 >= 60 ? color.lime : color.red, bgcolor=color.black, text_size=size.tiny)
````
