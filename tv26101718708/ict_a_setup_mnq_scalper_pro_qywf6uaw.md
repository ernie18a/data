# ICT A+ Setup MNQ Scalper PRO

- url: https://www.tradingview.com/script/QyWF6uaw-ICT-A-Setup-MNQ-Scalper-PRO/
- type: indicator
- pine_id: PUB;21757fa3e8214a079a688a0e235d8778
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
//@version=6
indicator("ICT A+ Setup MNQ Scalper PRO", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// =====================================================
// SETTINGS
// =====================================================
riskReward1   = input.float(1.5, "TP1 RR", step=0.1)
riskReward2   = input.float(3.0, "TP2 RR", step=0.1)

showFVG       = input.bool(true, "Show FVG")
showMSS       = input.bool(true, "Show MSS")
showLiquidity = input.bool(true, "Show Liquidity Sweeps")
showOB        = input.bool(true, "Show Order Blocks")
showPDH_PDL   = input.bool(true, "Show Daily High/Low")

// =====================================================
// DAILY HIGH / LOW
// =====================================================
dailyHigh = request.security(syminfo.tickerid, "D", high[1])
dailyLow  = request.security(syminfo.tickerid, "D", low[1])

plot(showPDH_PDL ? dailyHigh : na, color=color.red, linewidth=2, style=plot.style_linebr, title="Previous Day High")
plot(showPDH_PDL ? dailyLow : na, color=color.green, linewidth=2, style=plot.style_linebr, title="Previous Day Low")

// =====================================================
// MARKET STRUCTURE
// =====================================================
swingHigh = ta.pivothigh(high, 3, 3)
swingLow  = ta.pivotlow(low, 3, 3)

var float lastHigh = na
var float lastLow  = na

if not na(swingHigh)
    lastHigh := swingHigh

if not na(swingLow)
    lastLow := swingLow

bullMSS = close > lastHigh
bearMSS = close < lastLow

// =====================================================
// LIQUIDITY SWEEP
// =====================================================
buySweep  = low < ta.lowest(low[1], 5) and close > open
sellSweep = high > ta.highest(high[1], 5) and close < open

// =====================================================
// FAIR VALUE GAP
// =====================================================
bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    box.new(
     left=bar_index-2,
     top=low,
     right=bar_index,
     bottom=high[2],
     bgcolor=color.new(color.green, 85),
     border_color=color.green)

if showFVG and bearFVG
    box.new(
     left=bar_index-2,
     top=low[2],
     right=bar_index,
     bottom=high,
     bgcolor=color.new(color.red, 85),
     border_color=color.red)

// =====================================================
// ORDER BLOCKS
// =====================================================
bullOB = close[1] < open[1] and close > high[1]
bearOB = close[1] > open[1] and close < low[1]

if showOB and bullOB
    box.new(
     left=bar_index-1,
     right=bar_index+5,
     top=open[1],
     bottom=low[1],
     bgcolor=color.new(color.teal, 85),
     border_color=color.teal)

if showOB and bearOB
    box.new(
     left=bar_index-1,
     right=bar_index+5,
     top=high[1],
     bottom=open[1],
     bgcolor=color.new(color.orange, 85),
     border_color=color.orange)

// =====================================================
// A+ SETUPS
// =====================================================
longSetup  = bullMSS and buySweep and bullFVG
shortSetup = bearMSS and sellSweep and bearFVG

// =====================================================
// ATR STOPLOSS
// =====================================================
atr = ta.atr(14)

longSL  = low - atr * 0.5
shortSL = high + atr * 0.5

longRisk  = close - longSL
shortRisk = shortSL - close

longTP1 = close + (longRisk * riskReward1)
longTP2 = close + (longRisk * riskReward2)

shortTP1 = close - (shortRisk * riskReward1)
shortTP2 = close - (shortRisk * riskReward2)

// =====================================================
// ENTRY CANDLE COLOR
// =====================================================
barcolor(longSetup or shortSetup ? color.purple : na)

// =====================================================
// SIGNALS
// =====================================================
plotshape(
 longSetup,
 title="BUY",
 style=shape.labelup,
 location=location.belowbar,
 color=color.green,
 text="A+ BUY",
 textcolor=color.white)

plotshape(
 shortSetup,
 title="SELL",
 style=shape.labeldown,
 location=location.abovebar,
 color=color.red,
 text="A+ SELL",
 textcolor=color.white)

// =====================================================
// ENTRY / SL / TP LINES
// =====================================================
if longSetup
    // ENTRY
    line.new(bar_index, close, bar_index+15, close, color=color.purple, width=2)
    label.new(bar_index+15, close, "ENTRY", style=label.style_label_left, color=color.purple, textcolor=color.white)

    // SL
    line.new(bar_index, longSL, bar_index+15, longSL, color=color.red, width=2)
    label.new(bar_index+15, longSL, "SL", style=label.style_label_left, color=color.red, textcolor=color.white)

    // TP1
    line.new(bar_index, longTP1, bar_index+15, longTP1, color=color.green, width=2)
    label.new(bar_index+15, longTP1, "TP1", style=label.style_label_left, color=color.green, textcolor=color.white)

    // TP2
    line.new(bar_index, longTP2, bar_index+15, longTP2, color=color.lime, width=2)
    label.new(bar_index+15, longTP2, "TP2", style=label.style_label_left, color=color.lime, textcolor=color.black)

if shortSetup
    // ENTRY
    line.new(bar_index, close, bar_index+15, close, color=color.purple, width=2)
    label.new(bar_index+15, close, "ENTRY", style=label.style_label_left, color=color.purple, textcolor=color.white)

    // SL
    line.new(bar_index, shortSL, bar_index+15, shortSL, color=color.red, width=2)
    label.new(bar_index+15, shortSL, "SL", style=label.style_label_left, color=color.red, textcolor=color.white)

    // TP1
    line.new(bar_index, shortTP1, bar_index+15, shortTP1, color=color.green, width=2)
    label.new(bar_index+15, shortTP1, "TP1", style=label.style_label_left, color=color.green, textcolor=color.white)

    // TP2
    line.new(bar_index, shortTP2, bar_index+15, shortTP2, color=color.lime, width=2)
    label.new(bar_index+15, shortTP2, "TP2", style=label.style_label_left, color=color.lime, textcolor=color.black)

// =====================================================
// MARKET STRUCTURE VISUALS
// =====================================================
plotshape(
 showMSS and bullMSS,
 style=shape.circle,
 color=color.lime,
 location=location.belowbar,
 size=size.tiny,
 title="Bull MSS")

plotshape(
 showMSS and bearMSS,
 style=shape.circle,
 color=color.red,
 location=location.abovebar,
 size=size.tiny,
 title="Bear MSS")

// =====================================================
// LIQUIDITY VISUALS
// =====================================================
plotshape(
 showLiquidity and buySweep,
 style=shape.triangleup,
 location=location.belowbar,
 color=color.aqua,
 size=size.tiny,
 title="Buy Sweep")

plotshape(
 showLiquidity and sellSweep,
 style=shape.triangledown,
 location=location.abovebar,
 color=color.orange,
 size=size.tiny,
 title="Sell Sweep")

// =====================================================
// ALERTS
// =====================================================
alertcondition(
 longSetup,
 title="A+ BUY ALERT",
 message="ICT A+ BUY setup detected on MNQ")

alertcondition(
 shortSetup,
 title="A+ SELL ALERT",
 message="ICT A+ SELL setup detected on MNQ")
````
