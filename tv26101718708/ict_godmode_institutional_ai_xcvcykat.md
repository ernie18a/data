# ICT GODMODE INSTITUTIONAL AI

- url: https://www.tradingview.com/script/XCvCYkAt-ICT-GODMODE-INSTITUTIONAL-AI/
- type: indicator
- pine_id: PUB;6ed48ae23e194b7dac3d30a697c953c9
- version: 2.0

## Description

# ICT GODMODE INSTITUTIONAL AI

ICT GODMODE INSTITUTIONAL AI is an advanced Smart Money Concepts (SMC) and ICT-based trading indicator designed for traders who want institutional-style confirmations and high-probability market entries.

This indicator combines multiple powerful trading concepts into one complete system to help identify liquidity grabs, market structure shifts, trend direction, momentum, and premium/discount zones.

Built especially for Futures, Nasdaq (NQ/MNQ), Forex, and Indices trading.

━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━

✓ Liquidity Sweep Detection  
Detects stop hunts and liquidity grabs above highs and below lows.

✓ Market Structure Shift (MSS/BOS)  
Identifies bullish and bearish structure breaks.

✓ Fair Value Gaps (FVG)  
Automatically highlights imbalance zones.

✓ Institutional Order Blocks  
Displays bullish and bearish order block zones.

✓ EMA Trend Filter  
Filters trades with higher probability trend direction.

✓ Higher Timeframe Bias  
Uses HTF confirmation for stronger confluence.

✓ RSI Momentum Confirmation  
Avoids weak momentum setups.

✓ Volume Confirmation  
Filters low-quality signals using volume expansion.

✓ ATR Volatility Filter  
Avoids low-volatility market conditions.

✓ Premium & Discount Zones  
Helps identify optimal buying and selling areas.

✓ SMT Divergence Detection  
Detects momentum divergence for smarter entries.

✓ London & New York Killzones  
Highlights high-liquidity institutional trading sessions.

✓ AI Score System  
Combines multiple confirmations into a probability score.

✓ Buy & Sell Signals  
Provides clean visual trade entries directly on chart.

✓ Smart Alerts  
Built-in TradingView alert support.

━━━━━━━━━━━━━━━━━━
BEST SETTINGS
━━━━━━━━━━━━━━━━━━

Recommended Timeframes:

• 15M → Bias  
• 5M → Setup  
• 1M → Entry

Best Sessions:

• London Open  
• New York Open

━━━━━━━━━━━━━━━━━━
BEST USED FOR
━━━━━━━━━━━━━━━━━━

• Nasdaq Futures (NQ / MNQ)  
• Forex  
• Indices  
• Gold (XAUUSD)  
• Prop Firm Trading

━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━

This indicator is intended for educational and informational purposes only. No indicator guarantees profits. Always use proper risk management and trade responsibly.

## Source Code

````pine
//@version=6
indicator("ICT GODMODE INSTITUTIONAL AI", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// SETTINGS
swingLength = input.int(5, "Swing Length")
emaLength = input.int(200, "EMA Length")
riskReward = input.float(3.0, "Risk Reward")
atrMult = input.float(1.5, "ATR Multiplier")

showFVG = input.bool(true, "Show FVG")
showOB = input.bool(true, "Show Order Blocks")
showSessions = input.bool(true, "Show Sessions")
showTargets = input.bool(true, "Show TP/SL")
showLiquidity = input.bool(true, "Show Liquidity")
showDashboard = input.bool(true, "Show Dashboard")

// EMA TREND
ema200 = ta.ema(close, emaLength)

bullTrend = close > ema200
bearTrend = close < ema200

plot(ema200, color=color.orange, linewidth=2)

// HTF BIAS
htfClose = request.security(syminfo.tickerid, "15", close)

htfEMA = request.security(
     syminfo.tickerid,
     "15",
     ta.ema(close, 50)
)

htfBull = htfClose > htfEMA
htfBear = htfClose < htfEMA

// RSI + VOLUME + ATR
rsi = ta.rsi(close, 14)

bullRSI = rsi > 55
bearRSI = rsi < 45

avgVol = ta.sma(volume, 20)
highVol = volume > avgVol * 1.5

atr = ta.atr(14)
highATR = atr > ta.sma(atr, 20)

// SWINGS
swingHigh = ta.pivothigh(high, swingLength, swingLength)
swingLow = ta.pivotlow(low, swingLength, swingLength)

var float lastHigh = na
var float lastLow = na

if not na(swingHigh)
    lastHigh := high[swingLength]

if not na(swingLow)
    lastLow := low[swingLength]

// LIQUIDITY SWEEPS
bullSweep =
     not na(lastLow) and
     low < lastLow and
     close > lastLow

bearSweep =
     not na(lastHigh) and
     high > lastHigh and
     close < lastHigh

// MSS / BOS
bullMSS = close > high[1]
bearMSS = close < low[1]

// DISPLACEMENT
bullDisplacement =
     close > open and
     (close - open) > atr * 0.5

bearDisplacement =
     close < open and
     (open - close) > atr * 0.5

// FAIR VALUE GAPS
bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    box.new(
         left=bar_index - 2,
         right=bar_index + 6,
         top=low,
         bottom=high[2],
         bgcolor=color.new(color.green, 88),
         border_color=color.green
    )

if showFVG and bearFVG
    box.new(
         left=bar_index - 2,
         right=bar_index + 6,
         top=low[2],
         bottom=high,
         bgcolor=color.new(color.red, 88),
         border_color=color.red
    )

// ORDER BLOCKS
bullOB =
     close[1] < open[1] and
     close > high[1]

bearOB =
     close[1] > open[1] and
     close < low[1]

if showOB and bullOB
    box.new(
         left=bar_index - 1,
         right=bar_index + 8,
         top=open[1],
         bottom=low[1],
         bgcolor=color.new(color.green, 90),
         border_color=color.green
    )

if showOB and bearOB
    box.new(
         left=bar_index - 1,
         right=bar_index + 8,
         top=high[1],
         bottom=open[1],
         bgcolor=color.new(color.red, 90),
         border_color=color.red
    )

// PREMIUM / DISCOUNT
rangeHigh = ta.highest(high, 50)
rangeLow = ta.lowest(low, 50)

equilibrium = (rangeHigh + rangeLow) / 2

discountZone = close < equilibrium
premiumZone = close > equilibrium

plot(equilibrium, color=color.yellow)

// SMT DIVERGENCE
smtBull =
     low < low[1] and
     rsi > rsi[1]

smtBear =
     high > high[1] and
     rsi < rsi[1]

// SESSION KILLZONES UTC
hourUTC = hour(time, "UTC")

london = hourUTC >= 7 and hourUTC <= 10
newyork = hourUTC >= 13 and hourUTC <= 16

killzone = london or newyork

bgcolor(
     showSessions and killzone
     ? color.new(color.blue, 92)
     : na
)

// AI SCORE SYSTEM
buyScore = 0

buyScore += bullTrend ? 1 : 0
buyScore += htfBull ? 1 : 0
buyScore += bullSweep ? 1 : 0
buyScore += bullMSS ? 1 : 0
buyScore += bullDisplacement ? 1 : 0
buyScore += bullRSI ? 1 : 0
buyScore += highVol ? 1 : 0
buyScore += highATR ? 1 : 0
buyScore += discountZone ? 1 : 0
buyScore += smtBull ? 1 : 0
buyScore += killzone ? 1 : 0

sellScore = 0

sellScore += bearTrend ? 1 : 0
sellScore += htfBear ? 1 : 0
sellScore += bearSweep ? 1 : 0
sellScore += bearMSS ? 1 : 0
sellScore += bearDisplacement ? 1 : 0
sellScore += bearRSI ? 1 : 0
sellScore += highVol ? 1 : 0
sellScore += highATR ? 1 : 0
sellScore += premiumZone ? 1 : 0
sellScore += smtBear ? 1 : 0
sellScore += killzone ? 1 : 0

// FINAL SIGNALS
buySignal = buyScore >= 8
sellSignal = sellScore >= 8

// SIGNALS
plotshape(
     buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="BUY",
     textcolor=color.black
)

plotshape(
     sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white
)

// ALERTS
alertcondition(
     buySignal,
     title="BUY ALERT",
     message="ICT GODMODE AI BUY"
)

alertcondition(
     sellSignal,
     title="SELL ALERT",
     message="ICT GODMODE AI SELL"
)
// TP / SL CALCULATIONS
buySL = low - atr * atrMult
buyTP1 = close + ((close - buySL) * 1.0)
buyTP2 = close + ((close - buySL) * 2.0)

sellSL = high + atr * atrMult
sellTP1 = close - ((sellSL - close) * 1.0)
sellTP2 = close - ((sellSL - close) * 2.0)

// DRAW BUY LEVELS
if buySignal
    line.new(
         bar_index,
         buySL,
         bar_index + 20,
         buySL,
         color=color.red,
         width=2
    )

    line.new(
         bar_index,
         buyTP1,
         bar_index + 20,
         buyTP1,
         color=color.green,
         width=2
    )

    line.new(
         bar_index,
         buyTP2,
         bar_index + 20,
         buyTP2,
         color=color.lime,
         width=2
    )

    label.new(
         bar_index + 20,
         buySL,
         "SL",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white
    )

    label.new(
         bar_index + 20,
         buyTP1,
         "TP1",
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white
    )

    label.new(
         bar_index + 20,
         buyTP2,
         "TP2",
         style=label.style_label_left,
         color=color.lime,
         textcolor=color.black
    )

// DRAW SELL LEVELS
if sellSignal
    line.new(
         bar_index,
         sellSL,
         bar_index + 20,
         sellSL,
         color=color.red,
         width=2
    )

    line.new(
         bar_index,
         sellTP1,
         bar_index + 20,
         sellTP1,
         color=color.green,
         width=2
    )

    line.new(
         bar_index,
         sellTP2,
         bar_index + 20,
         sellTP2,
         color=color.lime,
         width=2
    )

    label.new(
         bar_index + 20,
         sellSL,
         "SL",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white
    )

    label.new(
         bar_index + 20,
         sellTP1,
         "TP1",
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white
    )

    label.new(
         bar_index + 20,
         sellTP2,
         "TP2",
         style=label.style_label_left,
         color=color.lime,
         textcolor=color.black
    )
````
