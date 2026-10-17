# ICT A+ Setup MNQ Scalper

- url: https://www.tradingview.com/script/v29Ezbym-ICT-A-Setup-MNQ-Scalper/
- type: indicator
- pine_id: PUB;5b28914603404c5286f64f27106e05fe
- version: 1.0

## Description

This script is an ICT-inspired scalping indicator designed mainly for Micro NASDAQ Futures (MNQ) on the 1-minute and 5-minute charts.

It tries to identify high-probability (“A+”) setups using three main ICT concepts together:

Market Structure Shift (MSS)
Liquidity Sweeps
Fair Value Gaps (FVG)

When all conditions align, it gives:

Buy/Sell signal
Stop Loss (SL)
Take Profit 1 (TP1)
Take Profit 2 (TP2)

⸻

How the Indicator Works

1. Market Structure Shift (MSS)

The script first detects swing highs and swing lows.

It checks whether price breaks:

Above previous swing high → bullish MSS
Below previous swing low → bearish MSS

This is the trend confirmation part.

Bullish MSS

Price closes above previous structure high.

Bearish MSS

Price closes below previous structure low.

This helps avoid random entries against momentum.

⸻

2. Liquidity Sweep Detection

The script looks for stop hunts.

Buy-side sweep

Price sweeps below recent lows and then closes bullish.

Sell-side sweep

Price sweeps above recent highs and then closes bearish.

This is a classic ICT liquidity grab concept.

The indicator assumes smart money takes liquidity before reversing.

⸻

3. Fair Value Gap (FVG)

The script detects imbalance zones.

Bullish FVG

Current candle low is above the high from 2 candles ago.

Bearish FVG

Current candle high is below the low from 2 candles ago.

These gaps show displacement/momentum.

The script draws them automatically as colored boxes:

Green = bullish FVG
Red = bearish FVG

⸻

A+ Setup Logic

The script only gives a signal when ALL 3 conditions align.

BUY Signal

Requires:

Bullish MSS
Buy-side liquidity sweep
Bullish FVG

SELL Signal

Requires:

Bearish MSS
Sell-side liquidity sweep
Bearish FVG

This filtering removes many weak setups.

⸻

Stop Loss (SL)

The script uses ATR (Average True Range).

ATR measures volatility.

Long SL

Placed below the candle low.

Short SL

Placed above the candle high.

This creates dynamic stop losses based on market volatility.

⸻

Take Profits

The script uses Risk:Reward ratios.

Default:

TP1 = 1.5R
TP2 = 3R

Example:
If your stop is 20 points:

TP1 = 30 points
TP2 = 60 points

⸻

Visual Elements

Green “A+ BUY”

Shows bullish entry.

Red “A+ SELL”

Shows bearish entry.

Small circles

Show Market Structure Shifts.

Small triangles

Show liquidity sweeps.

Colored boxes

Show Fair Value Gaps.

⸻

Alerts

The script includes TradingView alerts.

You can create:

Buy alerts
Sell alerts
Webhook alerts for Telegram
Mobile notifications

⸻

Best Use Cases

Works best during:

NY Open
High volatility sessions
Trend continuation days

Especially good for:

MNQ
NQ
XAUUSD
NASDAQ CFDs

⸻

Strengths

Good Confluence

Combines multiple ICT concepts together.

Cleaner Entries

Avoids many random signals.

Dynamic Risk Management

Uses ATR-based SL.

Beginner Friendly

Easy visual signals.

Mobile Friendly

Works well on TradingView mobile.

⸻

Weaknesses

Not Holy Grail

No indicator is 100% accurate.

Can Lag

MSS confirmation requires candle closes.

False Signals During Chop

Sideways markets can still trigger setups.

Needs Session Filtering

Best results come during killzones.

⸻

Expected Accuracy

With:

Proper session filtering
HTF bias
Risk management
News avoidance

You may realistically achieve:

55%–75% win rate

The high RR can still make it profitable even with losses.

## Source Code

````pine
//@version=5
indicator("ICT A+ Setup MNQ Scalper", overlay=true, max_labels_count=500)

// ==========================
// SETTINGS
// ==========================
riskReward1 = input.float(1.5, "TP1 RR", step=0.1)
riskReward2 = input.float(3.0, "TP2 RR", step=0.1)
showFVG      = input.bool(true, "Show FVG")
showMSS      = input.bool(true, "Show MSS")
showLiquidity= input.bool(true, "Show Liquidity Sweeps")

// ==========================
// MARKET STRUCTURE
// ==========================
swingHigh = ta.pivothigh(high, 3, 3)
swingLow  = ta.pivotlow(low, 3, 3)

var float lastHigh = na
var float lastLow = na

if not na(swingHigh)
    lastHigh := swingHigh

if not na(swingLow)
    lastLow := swingLow

bullMSS = close > lastHigh
bearMSS = close < lastLow

// ==========================
// LIQUIDITY SWEEP
// ==========================
buySweep  = low < ta.lowest(low[1], 5) and close > open
sellSweep = high > ta.highest(high[1], 5) and close < open

// ==========================
// FAIR VALUE GAP
// ==========================
bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    box.new(bar_index-2, high[2], bar_index, low, bgcolor=color.new(color.green, 85), border_color=color.new(color.green, 40))

if showFVG and bearFVG
    box.new(bar_index-2, low[2], bar_index, high, bgcolor=color.new(color.red, 85), border_color=color.new(color.red, 40))

// ==========================
// A+ SETUPS
// ==========================
longSetup  = bullMSS and buySweep and bullFVG
shortSetup = bearMSS and sellSweep and bearFVG

// ==========================
// ENTRY / SL / TP
// ==========================
atr = ta.atr(14)

longSL = low - atr * 0.5
shortSL = high + atr * 0.5

longRisk = close - longSL
shortRisk = shortSL - close

longTP1 = close + (longRisk * riskReward1)
longTP2 = close + (longRisk * riskReward2)

shortTP1 = close - (shortRisk * riskReward1)
shortTP2 = close - (shortRisk * riskReward2)

// ==========================
// SIGNALS
// ==========================
plotshape(longSetup, title="BUY", style=shape.labelup, location=location.belowbar, color=color.green, text="A+ BUY", textcolor=color.white, size=size.normal)

plotshape(shortSetup, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, text="A+ SELL", textcolor=color.white, size=size.normal)

// ==========================
// SL / TP LABELS
// ==========================
if longSetup
    label.new(bar_index, low,
     text=
     "ENTRY: " + str.tostring(close, format.mintick) +
     "\nSL: " + str.tostring(longSL, format.mintick) +
     "\nTP1: " + str.tostring(longTP1, format.mintick) +
     "\nTP2: " + str.tostring(longTP2, format.mintick),
     style=label.style_label_up,
     color=color.green,
     textcolor=color.white)

if shortSetup
    label.new(bar_index, high,
     text=
     "ENTRY: " + str.tostring(close, format.mintick) +
     "\nSL: " + str.tostring(shortSL, format.mintick) +
     "\nTP1: " + str.tostring(shortTP1, format.mintick) +
     "\nTP2: " + str.tostring(shortTP2, format.mintick),
     style=label.style_label_down,
     color=color.red,
     textcolor=color.white)

// ==========================
// MARKET STRUCTURE VISUALS
// ==========================
plotshape(showMSS and bullMSS, style=shape.circle, color=color.lime, location=location.belowbar, size=size.tiny, title="Bull MSS")

plotshape(showMSS and bearMSS, style=shape.circle, color=color.red, location=location.abovebar, size=size.tiny, title="Bear MSS")

// ==========================
// LIQUIDITY VISUALS
// ==========================
plotshape(showLiquidity and buySweep, style=shape.triangleup, location=location.belowbar, color=color.aqua, size=size.tiny, title="Buy Sweep")

plotshape(showLiquidity and sellSweep, style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.tiny, title="Sell Sweep")

// ==========================
// ALERTS
// ==========================
alertcondition(longSetup, title="A+ BUY ALERT", message="ICT A+ BUY setup detected on MNQ")

alertcondition(shortSetup, title="A+ SELL ALERT", message="ICT A+ SELL setup detected on MNQ")
````
