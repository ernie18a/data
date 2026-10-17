# Si Session High and Lows

- url: https://www.tradingview.com/script/X211NcjG-Si-Session-High-and-Lows/
- type: indicator
- pine_id: PUB;e0f8abaf0e1b4180bf9f3449fbf6ff48
- version: 1.0

## Description

Session Highs & Lows [NQ Toolkit]

Tracks the live highs and lows of the Asia, London, and New York trading sessions directly on the chart. Designed for intraday traders who focus on liquidity, session manipulation, breakouts, and market structure.

This indicator helps identify:

Key liquidity levels
Session sweeps and stop runs
Breakout zones
Expansion from consolidation
High-probability reaction areas

Features:

Automatic Asia session highs/lows
Automatic London session highs/lows
Automatic New York session highs/lows
Clean color-coded levels
Real-time updates during each session
Optimized for fast markets like NASDAQ-100 Index futures

Best used with:

Market structure
Fair value gaps
VWAP
Opening range setups
Smart Money Concepts (SMC)

## Source Code

````pine
//@version=5
indicator("Session Highs & Lows", overlay=true)

// ===== SESSION SETTINGS =====
asiaSession     = input.session("1800-0000", "Asia Session")
londonSession   = input.session("0200-0500", "London Session")
newYorkSession  = input.session("0830-1100", "New York Session")

// ===== SESSION DETECTION =====
inAsia     = not na(time(timeframe.period, asiaSession))
inLondon   = not na(time(timeframe.period, londonSession))
inNewYork  = not na(time(timeframe.period, newYorkSession))

// ===== VARIABLES =====
var float asiaHigh = na
var float asiaLow = na

var float londonHigh = na
var float londonLow = na

var float nyHigh = na
var float nyLow = na

// ===== ASIA SESSION =====
if inAsia and not inAsia[1]
    asiaHigh := high
    asiaLow := low

if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

// ===== LONDON SESSION =====
if inLondon and not inLondon[1]
    londonHigh := high
    londonLow := low

if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

// ===== NEW YORK SESSION =====
if inNewYork and not inNewYork[1]
    nyHigh := high
    nyLow := low

if inNewYork
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

// ===== PLOTS =====
plot(asiaHigh, color=color.purple, linewidth=2, title="Asia High")
plot(asiaLow, color=color.purple, linewidth=2, title="Asia Low")

plot(londonHigh, color=color.blue, linewidth=2, title="London High")
plot(londonLow, color=color.blue, linewidth=2, title="London Low")

plot(nyHigh, color=color.red, linewidth=2, title="NY High")
plot(nyLow, color=color.red, linewidth=2, title="NY Low")
````
