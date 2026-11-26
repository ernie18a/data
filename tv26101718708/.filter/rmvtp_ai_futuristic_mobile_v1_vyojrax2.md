# RMVTP AI Futuristic Mobile V1

- url: https://www.tradingview.com/script/vyOjRAX2-RMVTP-AI-Futuristic-Mobile-V1/
- type: indicator
- pine_id: PUB;1ce641f95a7a4e618a07561fec03cd0a
- version: 1.0

## Description

RMVTP AI Futuristic Mobile V1 is an advanced multi-timeframe trading dashboard designed specifically for traders who want a cleaner, smarter, and mobile-friendly market analysis system.

This indicator combines trend analysis, momentum calculation, candle pressure, and volume strength into a single AI-inspired mathematical scoring engine to help traders identify high-probability market direction with greater clarity.

Unlike traditional indicators that rely on a single signal source, RMVTP AI Futuristic Mobile V1 uses a weighted multi-timeframe model where higher timeframes carry stronger influence in determining the primary market trend while lower timeframes assist in optimizing trade entries.

This version is specially optimized for TradingView mobile users with a cleaner dashboard layout placed below the chart to reduce clutter and improve chart visibility.

FEATURES

• AI Final Trend Score
• AI Buy & Sell Signals
• Bullish vs Bearish Probability
• Multi-Timeframe Trend Dashboard
• EMA 20 / EMA 50 / EMA 200 System
• Volume Strength Analysis
• Candle Pressure Calculation
• Confidence Level Detection
• Market Phase Detection
• Mobile-Friendly Dashboard Layout

The indicator analyzes:

• Trend Direction
• Market Momentum
• Candle Buyer vs Seller Pressure
• Relative Volume Strength
• Multi-Timeframe Alignment
• Weighted Mathematical Probability

MARKET CONDITIONS

The system automatically classifies market conditions into:

• Strong Bullish
• Bullish
• Sideway / Neutral
• Bearish
• Strong Bearish

MARKET PHASE DETECTION

• Trending Market
• Building Trend
• Weak Trend
• Sideway Market

HOW TO USE

• Use higher timeframes to identify the main market direction
• Use lower timeframes to refine entries
• Use volume strength to confirm momentum
• Avoid trading during weak or sideways conditions
• Combine with support & resistance or market structure for better accuracy

BEST FOR

• Scalping
• Intraday Trading
• Swing Trading
• Trend Following
• Gold Trading
• Forex Trading
• Multi-Timeframe Analysis

This indicator does not guarantee future market movement and should not be considered financial advice. It is designed to assist traders by providing probability-based market analysis using mathematical calculations and trend behavior models.

Optimized for both desktop and mobile TradingView users.

Categories:
• Trend Analysis
• Volume
• Signals & Overlays

## Source Code

````pine
//@version=5
indicator("RMVTP AI Futuristic Mobile V1", overlay=true, max_labels_count=500)

// ================= INPUT =================
emaFastLen = input.int(20, "EMA Fast")
emaMidLen  = input.int(50, "EMA Main")
emaSlowLen = input.int(200, "EMA Slow")
volLen     = input.int(20, "Average Volume")
momLen     = input.int(5, "Momentum Length")

showMiniStatus = input.bool(true, "Show Small Status Box On Chart")
showDashboard  = input.bool(true, "Show Bottom Dashboard")

tf1 = input.timeframe("5", "TF 1")
tf2 = input.timeframe("15", "TF 2")
tf3 = input.timeframe("60", "TF 3")
tf4 = input.timeframe("240", "TF 4")
tf5 = input.timeframe("D", "TF 5")

// ================= FUNCTION =================
f_score() =>
    emaMain = ta.ema(close, emaMidLen)
    trendScore = close > emaMain ? 1 : close < emaMain ? -1 : 0

    momentum = close - close[momLen]
    momentumScore = momentum > 0 ? 1 : momentum < 0 ? -1 : 0

    candleRange = high - low
    candlePressure = candleRange != 0 ? (close - open) / candleRange : 0
    candleScore = candlePressure > 0.25 ? 1 : candlePressure < -0.25 ? -1 : 0

    volAvg = ta.sma(volume, volLen)
    volRatio = volAvg != 0 ? volume / volAvg : 0
    volScore = volRatio >= 1.5 ? 1 : volRatio >= 1.0 ? 0.5 : 0

    (trendScore * 0.35) + (momentumScore * 0.25) + (candleScore * 0.20) + ((trendScore * volScore) * 0.20)

f_status(score) =>
    score >= 0.70 ? "STRONG BULL" :
     score >= 0.40 ? "BULL" :
     score <= -0.70 ? "STRONG BEAR" :
     score <= -0.40 ? "BEAR" : "SIDEWAY"

f_bias(score) =>
    score > 0 ? "BULLISH" : score < 0 ? "BEARISH" : "NEUTRAL"

f_color(score) =>
    score >= 0.70 ? color.lime :
     score >= 0.40 ? color.new(color.lime, 20) :
     score <= -0.70 ? color.red :
     score <= -0.40 ? color.new(color.red, 20) :
     color.gray

f_tfName(tf) =>
    tf == "1" ? "M1" :
     tf == "5" ? "M5" :
     tf == "15" ? "M15" :
     tf == "30" ? "M30" :
     tf == "60" ? "H1" :
     tf == "240" ? "H4" :
     tf == "D" ? "D" :
     tf == "W" ? "W" : tf

// ================= MTF =================
s1 = request.security(syminfo.tickerid, tf1, f_score())
s2 = request.security(syminfo.tickerid, tf2, f_score())
s3 = request.security(syminfo.tickerid, tf3, f_score())
s4 = request.security(syminfo.tickerid, tf4, f_score())
s5 = request.security(syminfo.tickerid, tf5, f_score())

finalScore = (s1 * 0.10) + (s2 * 0.15) + (s3 * 0.25) + (s4 * 0.30) + (s5 * 0.20)
finalStatus = f_status(finalScore)
finalBias = f_bias(finalScore)

// ================= EMA =================
emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)

plot(emaFast, "EMA 20", color=color.aqua, linewidth=1)
plot(emaMid, "EMA 50", color=color.orange, linewidth=2)
plot(emaSlow, "EMA 200", color=color.white, linewidth=1)

// ================= EXTRA DATA =================
bullProb = math.round(((finalScore + 1) / 2) * 100)
bearProb = 100 - bullProb
confidence = math.round(math.abs(finalScore) * 100)

volAvgNow = ta.sma(volume, volLen)
volRatioNow = volAvgNow != 0 ? volume / volAvgNow : 0

volStatus = volRatioNow >= 2 ? "VERY STRONG" :
     volRatioNow >= 1.5 ? "STRONG" :
     volRatioNow >= 1 ? "NORMAL" : "LOW"

marketPhase =
     math.abs(finalScore) < 0.35 ? "SIDEWAY" :
     confidence >= 70 and volRatioNow >= 1.2 ? "TRENDING" :
     confidence >= 50 ? "BUILDING" : "WEAK"

trendStrength =
     confidence >= 80 ? "VERY STRONG" :
     confidence >= 60 ? "STRONG" :
     confidence >= 40 ? "MEDIUM" : "WEAK"

priceVsEma = close > emaMid ? "ABOVE" : "BELOW"

// ================= SIGNAL =================
buySignal  = finalScore >= 0.70 and close > emaMid and emaFast > emaMid
sellSignal = finalScore <= -0.70 and close < emaMid and emaFast < emaMid

plotshape(buySignal, title="AI Buy", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="AI BUY")
plotshape(sellSignal, title="AI Sell", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="AI SELL")

// ================= SMALL STATUS BOX =================
var table mini = table.new(position.top_right, 1, 3, border_width=1)

if barstate.islast and showMiniStatus
    table.cell(mini, 0, 0, "AI STATUS", bgcolor=color.black, text_color=color.aqua, text_size=size.small)
    table.cell(mini, 0, 1, finalScore > 0 ? "AI BUY" : finalScore < 0 ? "AI SELL" : "WAIT", bgcolor=f_color(finalScore), text_color=color.black, text_size=size.normal)
    table.cell(mini, 0, 2, finalStatus + "  " + str.tostring(confidence) + "%", bgcolor=color.black, text_color=f_color(finalScore), text_size=size.small)

// ================= BOTTOM DASHBOARD =================
var table dash = table.new(position.bottom_center, 6, 9, border_width=1)

if barstate.islast and showDashboard
    // Title
    table.cell(dash, 0, 0, "RMVTP AI V1", bgcolor=color.black, text_color=color.aqua, text_size=size.small)
    table.cell(dash, 1, 0, "SCORE", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 0, "BIAS", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 3, 0, "POWER", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 4, 0, "VOL", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 5, 0, "PHASE", bgcolor=color.black, text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 1, "FINAL", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(finalScore, "#.##"), bgcolor=color.black, text_color=f_color(finalScore), text_size=size.normal)
    table.cell(dash, 2, 1, finalBias, bgcolor=color.black, text_color=f_color(finalScore), text_size=size.small)
    table.cell(dash, 3, 1, str.tostring(confidence) + "%", bgcolor=color.black, text_color=color.lime, text_size=size.small)
    table.cell(dash, 4, 1, volStatus, bgcolor=color.black, text_color=color.lime, text_size=size.small)
    table.cell(dash, 5, 1, marketPhase, bgcolor=color.black, text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 2, "PROB", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, "BULL " + str.tostring(bullProb) + "%", bgcolor=color.black, text_color=color.lime, text_size=size.small)
    table.cell(dash, 2, 2, "BEAR " + str.tostring(bearProb) + "%", bgcolor=color.black, text_color=color.red, text_size=size.small)
    table.cell(dash, 3, 2, trendStrength, bgcolor=color.black, text_color=color.lime, text_size=size.small)
    table.cell(dash, 4, 2, str.tostring(volRatioNow, "#.##") + "x", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 5, 2, priceVsEma + " EMA50", bgcolor=color.black, text_color=close > emaMid ? color.lime : color.red, text_size=size.small)

    // MTF Header
    table.cell(dash, 0, 3, "TF", bgcolor=color.black, text_color=color.aqua, text_size=size.small)
    table.cell(dash, 1, 3, f_tfName(tf1), bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 3, f_tfName(tf2), bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 3, 3, f_tfName(tf3), bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 4, 3, f_tfName(tf4), bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 5, 3, f_tfName(tf5), bgcolor=color.black, text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 4, "SCORE", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(s1, "#.##"), bgcolor=color.black, text_color=f_color(s1), text_size=size.small)
    table.cell(dash, 2, 4, str.tostring(s2, "#.##"), bgcolor=color.black, text_color=f_color(s2), text_size=size.small)
    table.cell(dash, 3, 4, str.tostring(s3, "#.##"), bgcolor=color.black, text_color=f_color(s3), text_size=size.small)
    table.cell(dash, 4, 4, str.tostring(s4, "#.##"), bgcolor=color.black, text_color=f_color(s4), text_size=size.small)
    table.cell(dash, 5, 4, str.tostring(s5, "#.##"), bgcolor=color.black, text_color=f_color(s5), text_size=size.small)

    table.cell(dash, 0, 5, "STATUS", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 5, s1 > 0 ? "BULL" : s1 < 0 ? "BEAR" : "WAIT", bgcolor=color.black, text_color=f_color(s1), text_size=size.small)
    table.cell(dash, 2, 5, s2 > 0 ? "BULL" : s2 < 0 ? "BEAR" : "WAIT", bgcolor=color.black, text_color=f_color(s2), text_size=size.small)
    table.cell(dash, 3, 5, s3 > 0 ? "BULL" : s3 < 0 ? "BEAR" : "WAIT", bgcolor=color.black, text_color=f_color(s3), text_size=size.small)
    table.cell(dash, 4, 5, s4 > 0 ? "BULL" : s4 < 0 ? "BEAR" : "WAIT", bgcolor=color.black, text_color=f_color(s4), text_size=size.small)
    table.cell(dash, 5, 5, s5 > 0 ? "BULL" : s5 < 0 ? "BEAR" : "WAIT", bgcolor=color.black, text_color=f_color(s5), text_size=size.small)

    table.cell(dash, 0, 6, "WEIGHT", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 6, "10%", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 6, "15%", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 3, 6, "25%", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 4, 6, "30%", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 5, 6, "20%", bgcolor=color.black, text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 7, "STATUS", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 7, finalScore > 0 ? "BUY SIDE" : "SELL SIDE", bgcolor=color.black, text_color=f_color(finalScore), text_size=size.small)
    table.cell(dash, 2, 7, "VOL " + volStatus, bgcolor=color.black, text_color=color.lime, text_size=size.small)
    table.cell(dash, 3, 7, "BIAS " + finalBias, bgcolor=color.black, text_color=f_color(finalScore), text_size=size.small)
    table.cell(dash, 4, 7, "CONF " + str.tostring(confidence) + "%", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 5, 7, priceVsEma, bgcolor=color.black, text_color=close > emaMid ? color.lime : color.red, text_size=size.small)

    table.cell(dash, 0, 8, "GUIDE", bgcolor=color.black, text_color=color.aqua, text_size=size.small)
    table.cell(dash, 1, 8, "+0.70 BUY", bgcolor=color.black, text_color=color.lime, text_size=size.small)
    table.cell(dash, 2, 8, "+0.40 BULL", bgcolor=color.black, text_color=color.lime, text_size=size.small)
    table.cell(dash, 3, 8, "0 SIDEWAY", bgcolor=color.black, text_color=color.gray, text_size=size.small)
    table.cell(dash, 4, 8, "-0.40 BEAR", bgcolor=color.black, text_color=color.red, text_size=size.small)
    table.cell(dash, 5, 8, "-0.70 SELL", bgcolor=color.black, text_color=color.red, text_size=size.small)
````
