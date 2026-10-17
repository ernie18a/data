# PRO SMC Zones + TP System [MNQ & XAUUSD]

- url: https://www.tradingview.com/script/huZwpQ40-PRO-SMC-Zones-TP-System-MNQ-XAUUSD/
- type: indicator
- pine_id: PUB;53e0fb0f374442a09c4b804ac0b3270c
- version: 1.0

## Description

PRO SMC Zones + TP System [MNQ & XAUUSD]

A professional Smart Money Concept (SMC) TradingView indicator designed for institutional-style trading on:

MNQ
NQ
XAUUSD

This indicator combines:

Trend filtering
Market Structure Shift (MSS)
Fair Value Gaps (FVG)
Buy/Sell zones
Automatic TP & SL projection
Institutional-style visual mapping

Built specifically for:

Scalping
Intraday trading
Momentum continuation setups
SMC-style execution
Core Features
Smart Trend Filter

The indicator uses a dual EMA trend engine:

Fast EMA → Market momentum
Slow EMA → Higher timeframe bias
Bullish Trend

A bullish environment exists when:

Fast EMA > Slow EMA
Bearish Trend

A bearish environment exists when:

Fast EMA < Slow EMA

This filters out weak countertrend trades.

Market Structure Shift (MSS)

One of the main institutional concepts included.

The indicator detects:

Swing highs
Swing lows
Structure breaks

Using pivot-based logic.

Bullish MSS

Triggered when:

Price breaks above previous swing highs
Trend remains bullish

This signals:

Institutional momentum continuation
Possible displacement move
Bullish structure expansion
Bearish MSS

Triggered when:

Price breaks below previous swing lows
Trend remains bearish

This indicates:

Market weakness
Bearish continuation
Institutional selling pressure
Fair Value Gap Detection (FVG)

The script identifies imbalance zones using 3-candle gap logic.

Bullish FVG

Occurs when:

Current Low > High 2 candles ago

This suggests:

Aggressive bullish displacement
Institutional buying imbalance
Potential retracement entry zone
Bearish FVG

Occurs when:

Current High < Low 2 candles ago

This indicates:

Strong bearish momentum
Institutional sell imbalance
Potential continuation setup
Buy & Sell Zones (Order Block Style)

The indicator automatically creates:

BUY ZONES
SELL ZONES

These zones are drawn using ATR-based dynamic sizing.

BUY Zone

Displayed when:

Bull trend exists
Bullish MSS confirmed
Bullish FVG detected

Green transparent boxes highlight potential institutional demand areas.

SELL Zone

Displayed when:

Bear trend exists
Bearish MSS confirmed
Bearish FVG detected

Red transparent boxes mark possible institutional supply zones.

Institutional Entry Signals

The indicator prints:

BUY labels
SELL labels

Only when multiple confirmations align:
✔ Trend
✔ Structure shift
✔ Fair value gap

This reduces low-quality signals.

Automatic Stop Loss System

The indicator uses ATR-based dynamic stop losses.

Formula:

SL=Entry±(ATR×Multiplier)

Benefits:

Adapts to volatility
Better for Gold & Nasdaq movement
Prevents overly tight stops
Automatic TP1 & TP2 Targets

Targets are calculated using Risk:Reward logic.

Default settings:

TP1 → 1.5RR
TP2 → 3RR

Formula:

TP=Entry±(Risk×RR)

This allows:

Partial profit taking
Structured trade management
Professional execution planning
Visual Features

Designed to look:

Clean
Professional
Institutional
Mobile-friendly
Chart Includes

✔ EMA trend lines
✔ BUY/SELL labels
✔ BUY ZONES
✔ SELL ZONES
✔ Fair Value Gap logic
✔ TP1 / TP2 levels
✔ Stop Loss projection
✔ Transparent institutional zones

Best Use Cases

Excellent for:

SMC scalping
Trend continuation
Nasdaq momentum trading
Gold intraday trading
London & New York sessions
Recommended Timeframes
Scalping
1 Minute
3 Minute
5 Minute
Intraday Trading
15 Minute
1 Hour
Best Markets

Optimized especially for:

MNQ
NQ
XAUUSD

Also works on:

BTCUSD
EURUSD
GBPUSD
Strengths

✔ Includes real SMC concepts
✔ Market Structure Shift detection
✔ Fair Value Gap logic
✔ Institutional-style zones
✔ Automatic TP & SL
✔ Trend filtering
✔ Clean visual design
✔ Excellent for scalping
✔ Beginner-friendly SMC system

Limitations

While advanced, this is still a simplified SMC implementation.

It does NOT yet include:

Liquidity sweeps
CHoCH confirmation
Volume profile
Session kill zones
Premium/discount arrays
Multi-timeframe bias confirmation

Adding those features would make it closer to full ICT institutional logic.

Ideal For Traders Who Want
Institutional-style charting
Clean SMC setups
Automated TP & SL
Buy/Sell zones
FVG detection
Trend-confirmed entries
Scalping-friendly tools
Overall Summary

PRO SMC Zones + TP System is a professional TradingView indicator that combines:

Trend analysis
Market Structure Shift (MSS)
Fair Value Gap detection
Institutional-style zones
Automated risk management

Designed for traders who want practical Smart Money Concept tools without overwhelming chart clutter.

## Source Code

````pine
//@version=5
indicator("PRO SMC Zones + TP System [MNQ & XAUUSD]", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// SETTINGS
//====================================================
showEMA      = input.bool(true, "Show Trend EMA")
emaFastLen   = input.int(20, "Fast EMA")
emaSlowLen   = input.int(50, "Slow EMA")

rr1           = input.float(1.5, "TP1 Risk Reward", step=0.1)
rr2           = input.float(3.0, "TP2 Risk Reward", step=0.1)

atrLen        = input.int(14, "ATR Length")
atrMult       = input.float(1.5, "Stop Loss ATR", step=0.1)

showFVG       = input.bool(true, "Show Fair Value Gap")
showOB        = input.bool(true, "Show Buy/Sell Zone")
showSignals   = input.bool(true, "Show Entry Signals")

zoneTransparency = input.int(85, "Zone Transparency", minval=0, maxval=100)

//====================================================
// TREND FILTER
//====================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

bullTrend = emaFast > emaSlow
bearTrend = emaFast < emaSlow

plot(showEMA ? emaFast : na, color=color.aqua, linewidth=2)
plot(showEMA ? emaSlow : na, color=color.orange, linewidth=2)

//====================================================
// MARKET STRUCTURE SHIFT
//====================================================
swingHigh = ta.pivothigh(high, 3, 3)
swingLow  = ta.pivotlow(low, 3, 3)

var float lastHigh = na
var float lastLow  = na

if not na(swingHigh)
    lastHigh := swingHigh

if not na(swingLow)
    lastLow := swingLow

bullMSS = close > lastHigh and bullTrend
bearMSS = close < lastLow and bearTrend

//====================================================
// FAIR VALUE GAP
//====================================================
bullFVG = low > high[2]
bearFVG = high < low[2]

//====================================================
// ORDER BLOCK / ZONES
//====================================================
bullZoneTop    = low
bullZoneBottom = low - (ta.atr(atrLen) * 0.4)

bearZoneTop    = high + (ta.atr(atrLen) * 0.4)
bearZoneBottom = high

//====================================================
// ENTRY CONDITIONS
//====================================================
buySignal =
     bullTrend and
     bullMSS and
     bullFVG

sellSignal =
     bearTrend and
     bearMSS and
     bearFVG

//====================================================
// RISK MANAGEMENT
//====================================================
atr = ta.atr(atrLen)

buyEntry = close
buySL    = buyEntry - (atr * atrMult)
buyTP1   = buyEntry + ((buyEntry - buySL) * rr1)
buyTP2   = buyEntry + ((buyEntry - buySL) * rr2)

sellEntry = close
sellSL    = sellEntry + (atr * atrMult)
sellTP1   = sellEntry - ((sellSL - sellEntry) * rr1)
sellTP2   = sellEntry - ((sellSL - sellEntry) * rr2)

//====================================================
// BUY ZONE
//====================================================
if buySignal and showOB

    box.new(
         left=bar_index-2,
         top=bullZoneTop,
         right=bar_index+10,
         bottom=bullZoneBottom,
         bgcolor=color.new(color.green, zoneTransparency),
         border_color=color.new(color.green, 0)
     )

    label.new(
         bar_index,
         bullZoneBottom,
         "BUY ZONE",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.normal
     )

//====================================================
// SELL ZONE
//====================================================
if sellSignal and showOB

    box.new(
         left=bar_index-2,
         top=bearZoneTop,
         right=bar_index+10,
         bottom=bearZoneBottom,
         bgcolor=color.new(color.red, zoneTransparency),
         border_color=color.new(color.red, 0)
     )

    label.new(
         bar_index,
         bearZoneTop,
         "SELL ZONE",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.normal
     )

//====================================================
// BUY SIGNAL + TP/SL
//====================================================
if buySignal and showSignals

    // Entry
    label.new(
         bar_index,
         low,
         "BUY",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black,
         size=size.large
     )

    // SL
    line.new(
         bar_index,
         buySL,
         bar_index + 20,
         buySL,
         color=color.red,
         width=2,
         style=line.style_dotted
     )

    label.new(
         bar_index + 20,
         buySL,
         "SL",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white
     )

    // TP1
    line.new(
         bar_index,
         buyTP1,
         bar_index + 20,
         buyTP1,
         color=color.yellow,
         width=2,
         style=line.style_dotted
     )

    label.new(
         bar_index + 20,
         buyTP1,
         "TP1",
         style=label.style_label_left,
         color=color.yellow,
         textcolor=color.black
     )

    // TP2
    line.new(
         bar_index,
         buyTP2,
         bar_index + 20,
         buyTP2,
         color=color.green,
         width=2,
         style=line.style_dotted
     )

    label.new(
         bar_index + 20,
         buyTP2,
         "TP2",
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white
     )

//====================================================
// SELL SIGNAL + TP/SL
//====================================================
if sellSignal and showSignals

    // Entry
    label.new(
         bar_index,
         high,
         "SELL",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.large
     )

    // SL
    line.new(
         bar_index,
         sellSL,
         bar_index + 20,
         sellSL,
         color=color.red,
         width=2,
         style=line.style_dotted
     )

    label.new(
         bar_index + 20,
         sellSL,
         "SL",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white
     )

    // TP1
    line.new(
         bar_index,
         sellTP1,
         bar_index + 20,
         sellTP1,
         color=color.yellow,
         width=2,
         style=line.style_dotted
     )

    label.new(
         bar_index + 20,
         sellTP1,
         "TP1",
         style=label.style_label_left,
         color=color.yellow,
         textcolor=color.black
     )

    // TP2
    line.new(
         bar_index,
         sellTP2,
         bar_index + 20,
         sellTP2,
         color=color.green,
         width=2,
         style=line.style_dotted
     )

    label.new(
         bar_index + 20,
         sellTP2,
         "TP2",
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white
     )

//====================================================
// ALERTS
//====================================================
alertcondition(buySignal, title="BUY SIGNAL", message="BUY SIGNAL DETECTED")
alertcondition(sellSignal, title="SELL SIGNAL", message="SELL SIGNAL DETECTED")
````
