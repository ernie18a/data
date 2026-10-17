# Volatility Expansion Strategy 30M [MNQ] 

- url: https://www.tradingview.com/script/57J0Kih3-Volatility-Expansion-Strategy-30M-MNQ/
- type: strategy
- pine_id: PUB;986c4b0be8c64aeb96219da1218b365c
- version: 1.0

## Description

This script is designed to exploit the cyclical nature of market volatility—specifically the transition from "coiling" phases [b][i](low volatility)[/i][/b] to "expansion" phases [b][i](high volatility)[/i][/b]. Here is the technical breakdown of how the engine handles the data:

[b]The Mathematical Core:[/b] The Volatility Ratio
Instead of looking at raw price, the script calculates a Volatility Ratio. 
This is the core engine:
volRatio = ta.atr(20) / ta.sma(ta.atr(20), 40)

We are comparing a short-term volatility window [b](20 periods[/b]) against a long-term baseline [b](40 periods)[/b].

[b]The Squeeze ($< 0.95$):[/b] When the ratio drops below 0.95, it mathematically proves that current price action is significantly more compressed than its own historical average. This is our "coiling" phase.
[b]The Expansion ($> 1.02$):[/b] We look for a 2% increase in relative volatility to confirm that the "spring" has been released.
Level Locking & Execution Logic
Most breakout strategies fail because they buy any high/low. This script uses Conditional Level Locking:

While isCompressed is true, the script continuously updates breakoutHigh and breakoutLow to the high/low of the current bar.
The moment the market leaves the squeeze phase, those levels "freeze."
[b]The Trigger:[/b] A trade is only executed if we have a volatility expansion (volRatio > 1.02) occurring simultaneously with a price crossover of those frozen levels. This ensures we aren't just buying a slow drift, but a high-velocity move.
[b]Risk & Precision[/b]
For a fast instrument like [b]MNQ[/b], fixed price stops often fail due to slippage. I’ve programmed this to use Tick-Based Offsets. The risk is calculated dynamically using [symbol="NYSE:ATR"]NYSE:ATR[/symbol] \times 1.5$, then converted into the smallest possible unit of movement (ticks). This ensures that the strategy.exit orders are hard-coded into the broker's matching engine the millisecond you enter, protecting you from "stuck" trades during high-volatility spikes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
strategy("Volatility Expansion Strategy [MNQ] V7", 
     overlay=true, 
     initial_capital=100000, 
     default_qty_type=strategy.fixed, 
     default_qty_value=1,
     commission_type=strategy.commission.cash_per_contract, 
     commission_value=0.5)

// --- Simple Inputs ---
volLength      = input.int(20, "Lookback Period")
compThreshold  = input.float(0.95, "Compression Threshold", step=0.01)
expTrigger     = input.float(1.02, "Expansion Trigger", step=0.01)
atrMult        = input.float(1.5, "Risk Mult (ATR)")
rrRatio        = input.float(2.0, "Reward-to-Risk")
useSession     = input.bool(false, "Restrict to Session")
tradeSession   = input.session("0930-1600:23456", "Trading Session")

// --- Calculations ---
atrValue = ta.atr(volLength)
avgAtr   = ta.sma(atrValue, volLength * 2)
volRatio = atrValue / nz(avgAtr, 1)

isCompressed = volRatio < compThreshold
isExpanding  = volRatio > expTrigger

// --- Capture Breakout Levels ---
var float breakoutHigh = na
var float breakoutLow  = na

if isCompressed
    breakoutHigh := high
    breakoutLow  := low

// --- Filters ---
isInSession = not useSession or not na(time(timeframe.period, tradeSession, "America/New_York"))

// --- Entry Logic ---
longSignal  = isInSession and isExpanding and ta.crossover(close, breakoutHigh) and strategy.position_size == 0
shortSignal = isInSession and isExpanding and ta.crossunder(close, breakoutLow) and strategy.position_size == 0

// --- Trade State ---
var float entryRisk = na

if longSignal
    entryRisk := math.max(atrValue * atrMult, syminfo.mintick * 10)
    strategy.entry("Long", strategy.long, comment="Long")
    // Reset breakout levels to prevent re-entry on same level
    breakoutHigh := na 

if shortSignal
    entryRisk := math.max(atrValue * atrMult, syminfo.mintick * 10)
    strategy.entry("Short", strategy.short, comment="Short")
    // Reset breakout levels to prevent re-entry on same level
    breakoutLow := na

// --- Global Exit Logic ---
// We use 'loss' and 'profit' in ticks which is the most robust way to ensure exits trigger
if strategy.position_size != 0
    float slTicks = nz(entryRisk, atrValue * atrMult) / syminfo.mintick
    float tpTicks = slTicks * rrRatio
    
    strategy.exit("Exit", "Long", loss = slTicks, profit = tpTicks, comment_loss = "SL", comment_profit = "TP")
    strategy.exit("Exit", "Short", loss = slTicks, profit = tpTicks, comment_loss = "SL", comment_profit = "TP")

// --- Visuals ---
plot(breakoutHigh, "Break High", color.new(color.teal, 50), 2, plot.style_linebr)
plot(breakoutLow, "Break Low", color.new(color.maroon, 50), 2, plot.style_linebr)
bgcolor(isCompressed ? color.new(color.gray, 90) : na)

// --- Dashboard ---
var table debugTable = table.new(position.top_right, 2, 4, color.new(color.black, 0), color.white, 1, color.gray, 1)
if barstate.islast
    table.cell(debugTable, 0, 0, "Vol Ratio:")
    table.cell(debugTable, 1, 0, str.tostring(volRatio, "#.##"))
    table.cell(debugTable, 0, 1, "Status:")
    table.cell(debugTable, 1, 1, isCompressed ? "Squeeze" : isExpanding ? "Expansion" : "Neutral")
    table.cell(debugTable, 0, 2, "Trades:")
    table.cell(debugTable, 1, 2, str.tostring(strategy.closedtrades))
    table.cell(debugTable, 0, 3, "Win Rate:")
    float wr = strategy.closedtrades > 0 ? (strategy.wintrades / strategy.closedtrades) * 100 : 0
    table.cell(debugTable, 1, 3, str.tostring(wr, "#.#") + "%")
````
