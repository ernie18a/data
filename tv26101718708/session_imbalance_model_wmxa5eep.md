# Session Imbalance Model

- url: https://www.tradingview.com/script/WmXA5eEP-Session-Imbalance-Model/
- type: indicator
- pine_id: PUB;724ffb4b71c643dfa2ad8995e9b883ad
- version: 1.0

## Description

The Session Imbalance Model (SIM) is a smart-money-inspired trading indicator designed to identify high-probability reversal and continuation setups using Asian session liquidity, market structure shifts, and Fair Value Gaps (FVGs).

This indicator combines several institutional concepts into one clean execution model:

Asian Session Range
Liquidity Sweeps
Break of Structure (BOS)
Fair Value Gaps (Imbalances)
Session-based entry confirmations

SIM is built for traders looking to capture the move that often occurs after liquidity is taken from the Asian range during the London or New York sessions.

What the Indicator Does
1. Asian Session Range

The indicator tracks the:

Asian Session High
Asian Session Low

These levels act as major liquidity zones where price commonly reacts during later sessions.

2. Liquidity Sweeps

SIM detects when price:

Sweeps above the Asian High
Sweeps below the Asian Low

These sweeps often represent:

Stop hunts
Liquidity grabs
Smart money inducement

The indicator marks these events with directional triangles.

3. Break of Structure (BOS)

After a sweep occurs, SIM waits for confirmation through:

Bullish BOS
Bearish BOS

This helps confirm that market structure has shifted and momentum may reverse.

4. Fair Value Gaps (FVGs)

The indicator automatically plots:

Bullish imbalance zones
Bearish imbalance zones

These zones represent inefficient price delivery where price may later return for mitigation or continuation entries.

5. Buy & Sell Signals

A signal is generated only when:

Liquidity sweep occurs
AND
Market structure confirms direction
Buy Setup
Sweep below Asian Low
Bullish BOS confirmation
Sell Setup
Sweep above Asian High
Bearish BOS confirmation

This creates a high-quality confirmation-based entry model rather than random signal generation.

How to Use SIM
Long Setup
Price sweeps below the Asian session low
Market reverses upward
Bullish BOS appears
Buy signal prints
Enter on:
BOS candle close
FVG retracement
Pullback into imbalance zone
Stop Loss

Place below:

Liquidity sweep low
Session low
Recent swing low
Take Profit

Target:

Previous highs
Opposing liquidity
Risk-to-reward levels (1:2 or 1:3)
Short Setup
Price sweeps above the Asian session high
Market reverses downward
Bearish BOS appears
Sell signal prints
Enter on:
BOS candle close
Bearish FVG retest
Pullback into imbalance
Stop Loss

Place above:

Liquidity sweep high
Recent swing high
Take Profit

Target:

Equal lows
Opposing liquidity pools
Key session lows
Best Time Frames
Best Overall
5 Minute
15 Minute

These provide the cleanest session sweeps and structure shifts.

Scalping
1 Minute
3 Minute

Best for:

NQ
ES
NAS100
US30
Forex scalping

Use tighter risk management due to noise.

Swing Intraday
30 Minute
1 Hour

Best for:

Holding session continuation trades
Catching larger BOS moves
Best Markets to Trade

SIM performs best on markets with strong liquidity and session volatility:

Futures
NQ
ES
YM
Forex
GBPJPY
EURUSD
GBPUSD
USDJPY
Indices
NAS100
US30
GER40
Crypto

Can work on:

BTC
ETH

But is less reliable due to 24/7 market structure.

Best Trading Sessions
  London Open

The strongest setups usually occur during:

2:00 AM – 5:00 AM EST

Why?

London frequently raids Asian liquidity before expansion.
Second Best: New York Open

Strong continuation setups occur during:

8:30 AM – 11:00 AM EST

Especially effective on:

NQ
ES
NAS100
Recommended Trading Style

SIM works best for:

Smart money traders
ICT-style concepts
Liquidity sweep traders
Session traders
Intraday momentum traders
Core Strength of SIM

The indicator is designed to avoid weak entries by requiring:

Liquidity sweep
Structure confirmation
Directional imbalance

This creates a cleaner, more disciplined trading model focused on institutional price behavior rather than lagging indicators.

## Source Code

````pine
//@version=6
indicator("Session Imbalance Model", shorttitle="SIM", overlay=true, max_boxes_count=200, max_labels_count=200)

// ─────────────── INPUTS ───────────────
showAsianBox = input.bool(true, "Show Asian Range")
showFVG      = input.bool(true, "Show FVG Zones")
showSignals  = input.bool(true, "Show Entry Signals")

extendBars   = input.int(30, "Extend Zones", minval=5)

// ─────────────── SESSION (UTC) ───────────────
asianSession = "0000-0900"
inAsian = not na(time(timeframe.period, asianSession))

// ─────────────── ASIAN RANGE ───────────────
var float asianHigh = na
var float asianLow  = na

// Reset at new session start
newSession = inAsian and not inAsian[1]
if newSession
    asianHigh := high
    asianLow  := low

// Build range during session
if inAsian
    asianHigh := math.max(asianHigh, high)
    asianLow  := math.min(asianLow, low)

// ─────────────── PLOT RANGE ───────────────
plot(showAsianBox ? asianHigh : na, "Asian High", color=color.red, linewidth=2)
plot(showAsianBox ? asianLow  : na, "Asian Low",  color=color.green, linewidth=2)

// ─────────────── LIQUIDITY SWEEPS ───────────────
sweepHigh = not na(asianHigh) and high > asianHigh
sweepLow  = not na(asianLow)  and low  < asianLow

plotshape(sweepHigh, title="Sweep High", location=location.abovebar,
     color=color.red, style=shape.triangledown, size=size.tiny)

plotshape(sweepLow, title="Sweep Low", location=location.belowbar,
     color=color.green, style=shape.triangleup, size=size.tiny)

// ─────────────── STRUCTURE (BOS) ───────────────
lookback = 10
lastHigh = ta.highest(high, lookback)
lastLow  = ta.lowest(low, lookback)

bosBull = close > lastHigh[1]
bosBear = close < lastLow[1]

// ─────────────── FVG (3-CANDLE IMBALANCE) ───────────────
bullFVG = bar_index > 2 and low > high[2]
bearFVG = bar_index > 2 and high < low[2]

// ─────────────── FVG BOXES ───────────────
if showFVG and bullFVG
    box.new(
        left=bar_index[2],
        right=bar_index + extendBars,
        top=low,
        bottom=high[2],
        bgcolor=color.new(color.green, 85),
        border_color=color.green
    )

if showFVG and bearFVG
    box.new(
        left=bar_index[2],
        right=bar_index + extendBars,
        top=low[2],
        bottom=high,
        bgcolor=color.new(color.red, 85),
        border_color=color.red
    )

// ─────────────── ENTRY MODEL ───────────────
sellSetup = sweepHigh and bosBear
buySetup  = sweepLow  and bosBull

// ─────────────── SIGNALS ───────────────
plotshape(showSignals and sellSetup,
     title="SELL",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL")

plotshape(showSignals and buySetup,
     title="BUY",
     location=location.belowbar,
     color=color.green,
     style=shape.labelup,
     text="BUY")

// ─────────────── OPTIONAL LABELS ───────────────
if showSignals and sellSetup
    label.new(bar_index, high, "Sweep + BOS ↓",
        style=label.style_label_down,
        color=color.red, textcolor=color.white)

if showSignals and buySetup
    label.new(bar_index, low, "Sweep + BOS ↑",
        style=label.style_label_up,
        color=color.green, textcolor=color.white)
````
