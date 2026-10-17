# Raid & Reverse Liquidity Engine

- url: https://www.tradingview.com/script/No5vj5GE-Raid-Reverse-Liquidity-Engine/
- type: indicator
- pine_id: PUB;e9a49d9f79d94f53a2ea9f31f95d544f
- version: 1.0

## Description

# Raid & Reverse Liquidity Engine

A clean and advanced Smart Money Concepts (SMC) indicator built for traders who focus on liquidity sweeps, stop hunts, Fair Value Gaps (FVG), and market structure shifts.

This indicator automatically detects Buy-Side Liquidity (BSL) and Sell-Side Liquidity (SSL), identifies liquidity raids using wick-based sweeps, confirms reversals with Market Structure Shift (MSS), and highlights high-probability Fair Value Gap entry zones.

Unlike noisy SMC indicators, this script keeps the chart clean and focuses only on important institutional concepts.

━━━━━━━━━━━━━━━━━━

FEATURES

✔ Buy-Side & Sell-Side Liquidity Detection
✔ Liquidity Sweep / Stop Hunt Identification
✔ Wick-Based Raid Confirmation
✔ Market Structure Shift (MSS) Detection
✔ Automatic Fair Value Gap (FVG) Zones
✔ Smart Entry Signals
✔ Dynamic Stop Loss & Take Profit Levels
✔ Risk-to-Reward (RR) Calculation
✔ Clean Minimal Chart Design
✔ Real-Time Trading Alerts

━━━━━━━━━━━━━━━━━━

HOW IT WORKS

1. Detects liquidity resting above highs or below lows
2. Waits for price to sweep liquidity with a wick
3. Confirms reversal using Market Structure Shift
4. Marks Fair Value Gap for precision entry
5. Sets stop loss above/below sweep
6. Targets opposing liquidity pool

━━━━━━━━━━━━━━━━━━

BEST USED FOR

• Scalping
• Intraday Trading
• Smart Money Concepts (SMC)
• ICT Style Trading
• Liquidity Trading Strategies
• Futures & Forex
• Crypto Trading

━━━━━━━━━━━━━━━━━━

TIMEFRAMES

Works best on:
• 1M
• 3M
• 5M
• 15M

Use higher timeframe bias for stronger confirmations.

━━━━━━━━━━━━━━━━━━

DISCLAIMER

This indicator is for educational purposes only and does not guarantee profits. Always use proper risk management before taking any trade.

## Source Code

````pine
//@version=5
indicator("Raid & Reverse Liquidity Engine", overlay=true, max_labels_count=500, max_boxes_count=500)

//----------------------------------------------------
// INPUTS
//----------------------------------------------------
swingLen       = input.int(5, "Swing Length", minval=2)
showLiquidity  = input.bool(true, "Show Liquidity")
showFVG        = input.bool(true, "Show FVG")
showSignals    = input.bool(true, "Show Entry Signals")
extendBars     = input.int(20, "Liquidity Line Extension")

//----------------------------------------------------
// SWING HIGHS / LOWS
//----------------------------------------------------
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float bsl = na
var float ssl = na

if not na(ph)
    bsl := ph

if not na(pl)
    ssl := pl

//----------------------------------------------------
// DRAW LIQUIDITY
//----------------------------------------------------
if showLiquidity
    if not na(ph)
        line.new(
             bar_index - swingLen,
             ph,
             bar_index + extendBars,
             ph,
             color=color.red,
             width=1,
             style=line.style_dashed)

    if not na(pl)
        line.new(
             bar_index - swingLen,
             pl,
             bar_index + extendBars,
             pl,
             color=color.lime,
             width=1,
             style=line.style_dashed)

//----------------------------------------------------
// LIQUIDITY SWEEP DETECTION
//----------------------------------------------------

// Bearish sweep = wick above BSL but close below
bearSweep =
     not na(bsl) and
     high > bsl and
     close < bsl

// Bullish sweep = wick below SSL but close above
bullSweep =
     not na(ssl) and
     low < ssl and
     close > ssl

//----------------------------------------------------
// MARKET STRUCTURE SHIFT (MSS)
//----------------------------------------------------
bearMSS =
     bearSweep and
     low < low[1]

bullMSS =
     bullSweep and
     high > high[1]

//----------------------------------------------------
// FAIR VALUE GAP
//----------------------------------------------------

// Bullish FVG
bullFVG =
     low > high[2]

// Bearish FVG
bearFVG =
     high < low[2]

//----------------------------------------------------
// STORE FVG ZONES
//----------------------------------------------------
var box bullBox = na
var box bearBox = na

// Bullish FVG Box
if showFVG and bullFVG
    bullBox := box.new(
         left=bar_index-2,
         right=bar_index+8,
         top=low,
         bottom=high[2],
         bgcolor=color.new(color.lime, 85),
         border_color=color.new(color.lime, 30))

// Bearish FVG Box
if showFVG and bearFVG
    bearBox := box.new(
         left=bar_index-2,
         right=bar_index+8,
         top=low[2],
         bottom=high,
         bgcolor=color.new(color.red, 85),
         border_color=color.new(color.red, 30))

//----------------------------------------------------
// ENTRY CONDITIONS
//----------------------------------------------------
shortEntry =
     bearMSS and
     bearFVG

longEntry =
     bullMSS and
     bullFVG

//----------------------------------------------------
// STOP LOSS & TARGETS
//----------------------------------------------------
shortSL = high
longSL  = low

shortTP = ssl
longTP  = bsl

//----------------------------------------------------
// RR CALCULATION
//----------------------------------------------------
shortRisk   = math.abs(shortEntry ? close - shortSL : na)
shortReward = math.abs(shortEntry ? close - shortTP : na)
shortRR     = shortReward / shortRisk

longRisk    = math.abs(longEntry ? longSL - close : na)
longReward  = math.abs(longEntry ? longTP - close : na)
longRR      = longReward / longRisk

//----------------------------------------------------
// SIGNALS
//----------------------------------------------------
if showSignals and shortEntry
    label.new(
         bar_index,
         high,
         "SELL\nRR: " + str.tostring(shortRR, "#.##"),
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small)

if showSignals and longEntry
    label.new(
         bar_index,
         low,
         "BUY\nRR: " + str.tostring(longRR, "#.##"),
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black,
         size=size.small)

//----------------------------------------------------
// ENTRY / SL / TP LINES
//----------------------------------------------------
if shortEntry
    line.new(bar_index, close, bar_index+15, close, color=color.red, width=2)
    line.new(bar_index, shortSL, bar_index+15, shortSL, color=color.orange, style=line.style_dotted)
    line.new(bar_index, shortTP, bar_index+15, shortTP, color=color.lime, style=line.style_dotted)

if longEntry
    line.new(bar_index, close, bar_index+15, close, color=color.lime, width=2)
    line.new(bar_index, longSL, bar_index+15, longSL, color=color.orange, style=line.style_dotted)
    line.new(bar_index, longTP, bar_index+15, longTP, color=color.red, style=line.style_dotted)

//----------------------------------------------------
// ALERTS
//----------------------------------------------------
alertcondition(longEntry, title="BUY SIGNAL", message="Bullish Raid & Reverse Detected")
alertcondition(shortEntry, title="SELL SIGNAL", message="Bearish Raid & Reverse Detected")
````
