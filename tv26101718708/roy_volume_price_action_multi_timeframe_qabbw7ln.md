# Roy Volume Price Action Multi Timeframe

- url: https://www.tradingview.com/script/QABbW7lN-Roy-Volume-Price-Action-Multi-Timeframe/
- type: indicator
- pine_id: PUB;c853c3a3cd444bddba7e69d312ea12e1
- version: 1.0

## Description

Roy VPA AI – Clean Mobile Version is an advanced Volume Price Analysis (VPA) indicator designed to help traders identify market pressure, trend direction, and high-probability buy/sell opportunities using candle behavior, volume strength, and smart money concepts.

This version is specially optimized for TradingView mobile users with a cleaner signal system, reduced chart clutter, and a compact dashboard designed for smaller screens.

Unlike traditional volume indicators that only display raw volume data, Roy VPA AI analyzes the relationship between:

• Candle spread
• Volume expansion
• Buyer vs seller pressure
• Market momentum
• Trend direction using EMA
• Smart money behavior

The indicator filters noisy signals and ensures that one candle only displays one dominant signal to avoid confusion during live trading.

━━━━━━━━━━━━━━━━━━

FEATURES

• Clean BUY & SELL Signal System
• One Candle = One Dominant Signal
• Volume Price Analysis Engine
• Smart Candle Pressure Detection
• EMA Trend Confirmation
• Buyer vs Seller Strength Analysis
• AI Market Bias Detection
• Power Score Percentage
• Mobile-Friendly Dashboard
• Reduced Signal Noise
• Optional VPA Event Markers

━━━━━━━━━━━━━━━━━━

VPA EVENTS INCLUDED

• No Demand (Weak Buyer Pressure)
• No Supply (Weak Seller Pressure)
• Stopping Volume
• Upthrust Detection
• Absorption Buy
• Absorption Sell

━━━━━━━━━━━━━━━━━━

HOW THE SIGNAL WORKS

BUY Signal appears when:

• Bullish candle structure detected
• Strong volume enters market
• Buyer pressure dominates
• EMA trend confirms bullish direction
• Buy score stronger than sell score

SELL Signal appears when:

• Bearish candle structure detected
• Strong selling pressure detected
• High volume confirms movement
• EMA trend confirms bearish direction
• Sell score stronger than buy score

━━━━━━━━━━━━━━━━━━

WHY THIS VERSION IS DIFFERENT

Most VPA indicators become cluttered with too many labels and overlapping signals.

Roy VPA AI – Clean Mobile Version focuses on:

• Cleaner chart visibility
• Better mobile experience
• Easier signal reading
• Less confusion during scalping and intraday trading
• Smarter filtering logic

━━━━━━━━━━━━━━━━━━

BEST USED FOR

• Scalping
• Intraday Trading
• Smart Money Trading
• Trend Following
• Volume Confirmation
• Gold (XAUUSD)
• Forex
• Crypto
• Indices

━━━━━━━━━━━━━━━━━━

RECOMMENDED SETTINGS

• Dashboard Position: Top Right
• Show VPA Event Markers: OFF
• EMA Length: 50
• Volume Average Length: 20

━━━━━━━━━━━━━━━━━━

DISCLAIMER

This indicator is designed as a trading assistance tool and should not be used as financial advice. Always combine proper risk management and market confirmation before entering trades.

## Source Code

````pine
//@version=6
indicator("Roy VPA AI MTF - Clean Mobile Version", overlay=true, max_labels_count=100)

// ================= INPUT =================
emaLen    = input.int(50, "EMA Trend Length")
volLen    = input.int(20, "Volume Average Length")
spreadLen = input.int(20, "Candle Spread Average")

showEMA     = input.bool(true, "Show EMA")
showSignals = input.bool(true, "Show Current TF Signal")
showDash    = input.bool(true, "Show MTF Dashboard")

tf1 = input.timeframe("5", "MTF 1")
tf2 = input.timeframe("15", "MTF 2")
tf3 = input.timeframe("30", "MTF 3")
tf4 = input.timeframe("60", "MTF 4")
tf5 = input.timeframe("240", "MTF 5")
tf6 = input.timeframe("D", "MTF 6")

dashPosInput = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Center", "Bottom Right"])
dashPos = dashPosInput == "Top Center" ? position.top_center : dashPosInput == "Bottom Right" ? position.bottom_right : position.top_right

// ================= VPA FUNCTION =================
f_vpa() =>
    emaTrend = ta.ema(close, emaLen)

    volAvg = ta.sma(volume, volLen)
    spread = high - low
    spreadAvg = ta.sma(spread, spreadLen)

    body = math.abs(close - open)
    upperWick = high - math.max(open, close)
    lowerWick = math.min(open, close) - low

    bullCandle = close > open
    bearCandle = close < open

    highVol  = volume > volAvg * 1.5
    ultraVol = volume > volAvg * 2.3
    lowVol   = volume < volAvg * 0.7

    wideSpread   = spread > spreadAvg * 1.2
    narrowSpread = spread < spreadAvg * 0.75

    trendBull = close > emaTrend
    trendBear = close < emaTrend

    noDemand = bullCandle and lowVol and narrowSpread
    noSupply = bearCandle and lowVol and narrowSpread

    buyPressure  = bullCandle and highVol and wideSpread and trendBull
    sellPressure = bearCandle and highVol and wideSpread and trendBear

    stoppingVolume = bearCandle and ultraVol and lowerWick > body and lowerWick > upperWick
    upthrust       = bullCandle and highVol and upperWick > body * 1.5 and close < high - spread * 0.35

    absorptionBuy  = highVol and bearCandle and lowerWick > body and close > low + spread * 0.5
    absorptionSell = highVol and bullCandle and upperWick > body and close < high - spread * 0.5

    buyerScore = 0.0
    sellerScore = 0.0

    buyerScore += bullCandle ? 20 : 0
    buyerScore += trendBull ? 25 : 0
    buyerScore += highVol ? 20 : 0
    buyerScore += wideSpread ? 10 : 0
    buyerScore += stoppingVolume ? 25 : 0
    buyerScore += noSupply ? 15 : 0
    buyerScore += absorptionBuy ? 20 : 0

    sellerScore += bearCandle ? 20 : 0
    sellerScore += trendBear ? 25 : 0
    sellerScore += highVol ? 20 : 0
    sellerScore += wideSpread ? 10 : 0
    sellerScore += upthrust ? 25 : 0
    sellerScore += noDemand ? 15 : 0
    sellerScore += absorptionSell ? 20 : 0

    totalScore = buyerScore + sellerScore
    buyPercent = totalScore > 0 ? buyerScore / totalScore * 100 : 50
    sellPercent = totalScore > 0 ? sellerScore / totalScore * 100 : 50
    power = math.max(buyPercent, sellPercent)

    biasNum = buyPercent > sellPercent ? 1 : sellPercent > buyPercent ? -1 : 0

    rawBuy  = buyPressure or stoppingVolume or noSupply or absorptionBuy
    rawSell = sellPressure or upthrust or noDemand or absorptionSell

    cleanBuy  = rawBuy and buyPercent > sellPercent and power >= 55
    cleanSell = rawSell and sellPercent > buyPercent and power >= 55

    finalBuy  = cleanBuy and not cleanSell
    finalSell = cleanSell and not cleanBuy

    finalBuy  := cleanBuy and cleanSell ? buyPercent > sellPercent : finalBuy
    finalSell := cleanBuy and cleanSell ? sellPercent > buyPercent : finalSell

    [biasNum, buyPercent, sellPercent, power, finalBuy, finalSell]

// ================= CURRENT TF =================
[biasNow, buyNow, sellNow, powerNow, finalBuy, finalSell] = f_vpa()

emaTrendNow = ta.ema(close, emaLen)
plot(showEMA ? emaTrendNow : na, "EMA Trend", color=color.orange, linewidth=2)

plotshape(showSignals and finalBuy, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY", textcolor=color.white)
plotshape(showSignals and finalSell, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL", textcolor=color.white)

// ================= MTF CALL =================
[b1, buy1, sell1, p1, sigB1, sigS1] = request.security(syminfo.tickerid, tf1, f_vpa())
[b2, buy2, sell2, p2, sigB2, sigS2] = request.security(syminfo.tickerid, tf2, f_vpa())
[b3, buy3, sell3, p3, sigB3, sigS3] = request.security(syminfo.tickerid, tf3, f_vpa())
[b4, buy4, sell4, p4, sigB4, sigS4] = request.security(syminfo.tickerid, tf4, f_vpa())
[b5, buy5, sell5, p5, sigB5, sigS5] = request.security(syminfo.tickerid, tf5, f_vpa())
[b6, buy6, sell6, p6, sigB6, sigS6] = request.security(syminfo.tickerid, tf6, f_vpa())

// ================= HELPER =================
f_tfName(tf) =>
    tf == "1" ? "M1" :
     tf == "5" ? "M5" :
     tf == "15" ? "M15" :
     tf == "30" ? "M30" :
     tf == "60" ? "H1" :
     tf == "240" ? "H4" :
     tf == "D" ? "D" :
     tf == "W" ? "W" : tf

f_biasText(b) =>
    b == 1 ? "BULL" : b == -1 ? "BEAR" : "NEUTRAL"

f_biasColor(b) =>
    b == 1 ? color.green : b == -1 ? color.red : color.gray

f_signalText(buySig, sellSig) =>
    buySig ? "BUY" : sellSig ? "SELL" : "-"

f_signalColor(buySig, sellSig) =>
    buySig ? color.green : sellSig ? color.red : color.gray

// ================= DASHBOARD =================
var table dash = table.new(dashPos, 5, 7, border_width=1)

if showDash and barstate.islast
    table.cell(dash, 0, 0, "TF", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 1, 0, "BIAS", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 2, 0, "BUY", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 3, 0, "SELL", text_color=color.white, bgcolor=color.black, text_size=size.tiny)
    table.cell(dash, 4, 0, "SIG", text_color=color.white, bgcolor=color.black, text_size=size.tiny)

    table.cell(dash, 0, 1, f_tfName(tf1), text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 1, f_biasText(b1), text_color=color.white, bgcolor=f_biasColor(b1), text_size=size.tiny)
    table.cell(dash, 2, 1, str.tostring(buy1, "#") + "%", text_color=color.white, bgcolor=color.green, text_size=size.tiny)
    table.cell(dash, 3, 1, str.tostring(sell1, "#") + "%", text_color=color.white, bgcolor=color.red, text_size=size.tiny)
    table.cell(dash, 4, 1, f_signalText(sigB1, sigS1), text_color=color.white, bgcolor=f_signalColor(sigB1, sigS1), text_size=size.tiny)

    table.cell(dash, 0, 2, f_tfName(tf2), text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 2, f_biasText(b2), text_color=color.white, bgcolor=f_biasColor(b2), text_size=size.tiny)
    table.cell(dash, 2, 2, str.tostring(buy2, "#") + "%", text_color=color.white, bgcolor=color.green, text_size=size.tiny)
    table.cell(dash, 3, 2, str.tostring(sell2, "#") + "%", text_color=color.white, bgcolor=color.red, text_size=size.tiny)
    table.cell(dash, 4, 2, f_signalText(sigB2, sigS2), text_color=color.white, bgcolor=f_signalColor(sigB2, sigS2), text_size=size.tiny)

    table.cell(dash, 0, 3, f_tfName(tf3), text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 3, f_biasText(b3), text_color=color.white, bgcolor=f_biasColor(b3), text_size=size.tiny)
    table.cell(dash, 2, 3, str.tostring(buy3, "#") + "%", text_color=color.white, bgcolor=color.green, text_size=size.tiny)
    table.cell(dash, 3, 3, str.tostring(sell3, "#") + "%", text_color=color.white, bgcolor=color.red, text_size=size.tiny)
    table.cell(dash, 4, 3, f_signalText(sigB3, sigS3), text_color=color.white, bgcolor=f_signalColor(sigB3, sigS3), text_size=size.tiny)

    table.cell(dash, 0, 4, f_tfName(tf4), text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 4, f_biasText(b4), text_color=color.white, bgcolor=f_biasColor(b4), text_size=size.tiny)
    table.cell(dash, 2, 4, str.tostring(buy4, "#") + "%", text_color=color.white, bgcolor=color.green, text_size=size.tiny)
    table.cell(dash, 3, 4, str.tostring(sell4, "#") + "%", text_color=color.white, bgcolor=color.red, text_size=size.tiny)
    table.cell(dash, 4, 4, f_signalText(sigB4, sigS4), text_color=color.white, bgcolor=f_signalColor(sigB4, sigS4), text_size=size.tiny)

    table.cell(dash, 0, 5, f_tfName(tf5), text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 5, f_biasText(b5), text_color=color.white, bgcolor=f_biasColor(b5), text_size=size.tiny)
    table.cell(dash, 2, 5, str.tostring(buy5, "#") + "%", text_color=color.white, bgcolor=color.green, text_size=size.tiny)
    table.cell(dash, 3, 5, str.tostring(sell5, "#") + "%", text_color=color.white, bgcolor=color.red, text_size=size.tiny)
    table.cell(dash, 4, 5, f_signalText(sigB5, sigS5), text_color=color.white, bgcolor=f_signalColor(sigB5, sigS5), text_size=size.tiny)

    table.cell(dash, 0, 6, f_tfName(tf6), text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 6, f_biasText(b6), text_color=color.white, bgcolor=f_biasColor(b6), text_size=size.tiny)
    table.cell(dash, 2, 6, str.tostring(buy6, "#") + "%", text_color=color.white, bgcolor=color.green, text_size=size.tiny)
    table.cell(dash, 3, 6, str.tostring(sell6, "#") + "%", text_color=color.white, bgcolor=color.red, text_size=size.tiny)
    table.cell(dash, 4, 6, f_signalText(sigB6, sigS6), text_color=color.white, bgcolor=f_signalColor(sigB6, sigS6), text_size=size.tiny)

// ================= ALERT =================
alertcondition(finalBuy, title="Roy VPA MTF BUY", message="Roy VPA AI MTF: BUY signal detected")
alertcondition(finalSell, title="Roy VPA MTF SELL", message="Roy VPA AI MTF: SELL signal detected")
````
