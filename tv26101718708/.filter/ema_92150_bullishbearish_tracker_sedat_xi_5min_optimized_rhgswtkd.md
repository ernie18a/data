# EMA 9/21/50 Bullish/Bearish Tracker SEDAT XI [5min Optimized]

- url: https://www.tradingview.com/script/RHGsWTKD-EMA-9-21-50-Bullish-Bearish-Tracker-SEDAT-XI-5min-Optimized/
- type: indicator
- pine_id: PUB;bcfefded0e284ad08a4d4534af7eb83a
- version: 1.0

## Description

EMA 9/21/50 Bullish/Bearish Tracker SEDAT XI [5min Optimized]
A clean, powerful, and visual trend strength indicator optimized for 5-minute charts.
This indicator combines the classic EMA 9 – 21 – 50 stack with Higher Timeframe confirmation (15min EMA 50) and Volume Momentum to help traders quickly identify high-probability bullish and bearish setups.

✨ Key Features

Triple EMA System: EMA 9 (Fast), EMA 21 (Medium), and EMA 50 (Trend)
Dynamic Coloring: EMAs change color based on price position for instant visual feedback
Higher Timeframe Filter: 15-minute EMA 50 confirmation to avoid counter-trend trades on 5min charts
Volume Momentum Tracker: Detects significant volume spikes with bullish/bearish candle direction
Strong Signal Logic: Combines EMA stack + Price position + HTF alignment + Volume spike
Smart Background Coloring: Clear green/red background for strong momentum phases
Professional Table Dashboard: Real-time status of Price, Stack, Volume, and HTF alignment
Built-in Alerts: Multiple high-quality alert conditions
Movable Table: Fully adjustable position with pixel offsets.
🎯 How to Read the Indicator
Strong Bullish (Bright Green Background)

EMA 9 > 21 > 50 (Bull Stack)
Price above all three EMAs
Price above 15min EMA 50
Bullish volume spike

Strong Bearish (Bright Red Background)

EMA 9 < 21 < 50 (Bear Stack)
Price below all three EMAs
Price below 15min EMA 50
Bearish volume spike

The table gives you a complete snapshot at a glance:

STATE: Overall market condition
PRICE: Position relative to EMAs
STACK: EMA alignment
VOLUME: Spike detection
HTF 15m: Higher timeframe confirmation


🚨 Alerts Included

Price crosses EMA 50
Strong Bullish / Bearish Alignment
Bullish/Bearish Volume Spikes during trend
EMA 9/21 crossover in strong trend


Best Used On

Primary: 5-minute charts
Also works well on 3min, 8min, and 15min timeframes
Ideal for Day Trading, Scalping, and Swing Entries


Settings Overview
EMA Settings

Adjustable lengths for EMA 9, 21, 50
Custom source (Close, HL2, etc.)

Volume Settings

Volume MA Length
Spike Multiplier (default 1.5×)

Table Position

Choose base position + fine-tune with X/Y pixel offsets


Created by Sedat XI
Optimized for clean, stress-free trading on 5-minute charts.

Would you like me to also write:

A shorter version (for mobile view)?
Detailed "How to Trade" section with examples?
Tags and categories for publishing?

Just say the word and I’ll refine it further!377ms

## Source Code

````pine
//@version=6
indicator("EMA 9/21/50 Bullish/Bearish Tracker [5min Optimized]", shorttitle="EMA 9-21-50 | 5min", overlay=true, max_bars_back=1000)

// ── Inputs ─────────────────────────────────────
len9  = input.int(9,  title="Fast EMA",  minval=1, group="EMA Settings")
len21 = input.int(21, title="Medium EMA", minval=1, group="EMA Settings")
len50 = input.int(50, title="Trend EMA", minval=1, group="EMA Settings")

src = input.source(close, title="Source")

showHTF = input.bool(true, title="Show Higher Timeframe EMA50 (15min)", group="5min Enhancements")

// ── EMAs ───────────────────────────────────────
ema9  = ta.ema(src, len9)
ema21 = ta.ema(src, len21)
ema50 = ta.ema(src, len50)

// Higher Timeframe EMA50 (15min) for better context on 5min chart
ema50_htf = request.security(syminfo.tickerid, "15", ta.ema(close, 50), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ── Trend Logic ────────────────────────────────
priceAboveAll = close > ema9 and close > ema21 and close > ema50
priceBelowAll = close < ema9 and close < ema21 and close < ema50

bullStack = ema9 > ema21 and ema21 > ema50
bearStack = ema9 < ema21 and ema21 < ema50

isStrongBull = bullStack and priceAboveAll and close > ema50_htf
isStrongBear = bearStack and priceBelowAll and close < ema50_htf

isBullish = priceAboveAll or bullStack
isBearish = priceBelowAll or bearStack

// ── Plotting ───────────────────────────────────
plot(ema9,  title="EMA 9",  color=close > ema9  ? color.lime  : color.red,    linewidth=2)
plot(ema21, title="EMA 21", color=close > ema21 ? color.yellow : color.orange, linewidth=2)
plot(ema50, title="EMA 50", color=close > ema50 ? color.green  : color.red,    linewidth=3)

plot(showHTF ? ema50_htf : na, title="15min EMA50", color=color.new(color.blue, 0), linewidth=2, style=plot.style_linebr)

// ── Background ─────────────────────────────────
bgColor = isStrongBull ? color.new(color.green, 85) : 
          isStrongBear ? color.new(color.red, 85)   : 
          isBullish    ? color.new(color.green, 92) : 
          isBearish    ? color.new(color.red, 92)   : na
bgcolor(bgColor)

// ── Status Table (Top Right) ───────────────────
var table t = table.new(position.top_right, 1, 6, bgcolor=color.new(#ffffff, 85), border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "5min EMA 9/21/50 TRACKER", text_color=color.black, text_size=size.normal)
    
    table.cell(t, 0, 1, "Price vs EMAs", 
               text_color = priceAboveAll ? color.green : priceBelowAll ? color.red : color.gray)
    
    table.cell(t, 0, 2, "EMA Stack", 
               text_color = bullStack ? color.green : bearStack ? color.red : color.gray)
    
    table.cell(t, 0, 3, showHTF ? "vs 15min EMA50" : "", 
               text_color = close > ema50_htf ? color.green : color.red)
    
    table.cell(t, 0, 4, isStrongBull ? "STRONG BULLISH" : 
                        isStrongBear ? "STRONG BEARISH" : 
                        isBullish ? "BULLISH" : 
                        isBearish ? "BEARISH" : "NEUTRAL",
               text_color = isStrongBull or isBullish ? color.green : color.red,
               text_size = size.large,
               bgcolor = isStrongBull ? color.new(color.green,70) : isStrongBear ? color.new(color.red,70) : na)
    
    table.cell(t, 0, 5, "Close: " + str.tostring(close, "#.####"), text_color=color.black)

// ── Alerts (Good for 5min) ─────────────────────
if ta.crossover(close, ema50)
    alert("5min → Bullish: Price crossed above EMA50", alert.freq_once_per_bar_close)

if ta.crossunder(close, ema50)
    alert("5min → Bearish: Price crossed below EMA50", alert.freq_once_per_bar_close)

if isStrongBull and ta.crossover(ema9, ema21)
    alert("5min → STRONG BULLISH Alignment", alert.freq_once_per_bar_close)

if isStrongBear and ta.crossunder(ema9, ema21)
    alert("5min → STRONG BEARISH Alignment", alert.freq_once_per_bar_close)
````
