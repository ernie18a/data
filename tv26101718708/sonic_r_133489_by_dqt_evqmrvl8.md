# Sonic R (13-34-89) by DQT 

- url: https://www.tradingview.com/script/eVQmrvl8/
- type: indicator
- pine_id: PUB;cf1e09d1d1134b20bf3103124bc51c1b
- version: 1.0

## Description

Sonic R System - EMA 13-34-89-200

Description:
The Sonic R indicator is built upon a multi-layered Exponential Moving Average (EMA) system combined with a Price Action Channel (PAC), designed to identify market trends, dynamic support/resistance zones, and high-probability trade entries.
Core Components:
1. Price Action Channel (PAC) — EMA 34 Band
The PAC is calculated using EMA 34 applied to High, Low, and Close prices, forming a dynamic channel that represents the short-term equilibrium zone. Price above the channel signals bullish momentum; price below signals bearish pressure.
2. EMA Trend System:

🟡 EMA 13 — Fast-reacting short-term trend, captures immediate price momentum
🔴 EMA 34 — Core support/resistance zone displayed as a red band, acts as the market's heartbeat
🟣 EMA 89 — Medium-term trend filter, smooths out market noise
🟢 EMA 200 — Long-term trend anchor, defines the overall market direction

How to Use:

Price above all EMAs → strong uptrend, prioritize buy setups
Price below all EMAs → strong downtrend, prioritize sell setups
Price inside the red EMA 34 band → market consolidating, wait for breakout confirmation
EMAs stacked in order (13 > 34 > 89 > 200) → trend is clean and strong, highest confidence entries

Best Used On: All timeframes — most effective on H1, H4, and Daily charts.

## Source Code

````pine
//@version=6
//Sonic R
indicator("Sonic R", overlay=true)

HiLoLen = input.int(34, minval=2, title="High Low channel Length")
pacC    = ta.ema(close, HiLoLen)
pacL    = ta.ema(low,   HiLoLen)
pacH    = ta.ema(high,  HiLoLen)

DODGERBLUE = color.new(#ff1e1e, 50)

// Plot the Price Action Channel (PAC) based on EMA high, low and close
L = plot(pacL, color=DODGERBLUE, linewidth=1, title="Low PAC EMA")
H = plot(pacH, color=DODGERBLUE, linewidth=1, title="High PAC EMA")
C = plot(pacC, color=color.new(#4e1707, 0), linewidth=2, title="Close PAC EMA")
fill(L, H, color=color.new(color.aqua, 90), title="Fill HiLo PAC")

// Hệ EMA 13 - 34 - 89 - 200
ema13  = ta.ema(close, 13)
ema34L = ta.ema(low,   34)
ema34C = ta.ema(close, 34)
ema34H = ta.ema(high,  34)
ema89  = ta.ema(close, 89)
ema200 = ta.ema(close, 200)

plot(ema13,  title="EMA 13",       color=color.yellow, linewidth=1)
E34L = plot(ema34L, title="EMA 34 Low",  color=color.red, display=display.none)
E34H = plot(ema34H, title="EMA 34 High", color=color.red, display=display.none)
fill(E34L, E34H, color=color.new(color.red, 70), title="EMA 34 Zone")
plot(ema34C, title="EMA 34 Close", color=color.red,    linewidth=1)
plot(ema89,  title="EMA 89",       color=color.purple,  linewidth=2)
plot(ema200, title="EMA 200",      color=color.green,   linewidth=2)
````
