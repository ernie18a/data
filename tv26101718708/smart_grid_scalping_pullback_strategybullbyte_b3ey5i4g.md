# Smart Grid Scalping (Pullback) Strategy[BullByte]

- url: https://www.tradingview.com/script/B3Ey5I4g-Smart-Grid-Scalping-Pullback-Strategy-BullByte/
- type: strategy
- pine_id: PUB;d828d3c5cea540869b9be0070e0ac8af
- version: 4.0

## Description

The [b]Smart Grid Scalping (Pullback) Strategy [BullByte][/b] is a high-frequency trading strategy designed for short-term traders who seek to capitalize on market pullbacks. This strategy utilizes a dynamic ATR-based grid system to define optimal entry points, ensuring precise trade execution. It integrates volatility filtering and an RSI-based confirmation mechanism to enhance signal accuracy and reduce false entries.

This strategy is specifically optimized for scalping by dynamically adjusting trade levels based on current market conditions. The grid-based system helps capture retracement opportunities while maintaining strict trade management through predefined profit targets and trailing stop-loss mechanisms.

 [b]Key Features[/b]:

1. [b]ATR-Based Grid System[/b]:
   - Uses a 10-period ATR to dynamically calculate grid levels for entry points.
   - Prevents chasing trades by ensuring price has reached key levels before executing entries.

2. [b]No Trade Zone Protection[/b]:
   - Avoids low-volatility zones where price action is indecisive.
   - Ensures only high-momentum trades are executed to improve success rate.

3. [b]RSI-Based Entry Confirmation[/b]:
   - Long trades are triggered when RSI is below 30 (oversold) and price is in the lower grid zone.
   - Short trades are triggered when RSI is above 70 (overbought) and price is in the upper grid zone.

4. [b]Automated Trade Execution[/b]:
   - Long Entry: Triggered when price drops below the first grid level with sufficient volatility.
   - Short Entry: Triggered when price exceeds the highest grid level with sufficient volatility.

5. [b]Take Profit & Trailing Stop[/b]:
   - Profit target set at a customizable percentage (default 0.2%).
   - Adaptive trailing stop mechanism using ATR to lock in profits while minimizing premature exits.

6. [b]Visual Trade Annotations[/b]:
   - Clearly labeled "LONG" and "SHORT" markers appear at trade entries for better visualization.
   - Grid levels are plotted dynamically to aid decision-making.

[b]Strategy Logic[/b]:
- The script first calculates the ATR-based grid levels and ensures price action has sufficient volatility before allowing trades.
- An additional RSI filter is used to ensure trades are taken at ideal market conditions.
- Once a trade is executed, the script implements a trailing stop and predefined take profit to maximize gains while reducing risks.

---

[b]Disclaimer[/b]:
[b]Risk Warning[/b]:
This strategy is provided for educational and informational purposes only. Trading involves significant risk, and past performance is not indicative of future results. Users are advised to conduct their own due diligence and risk management before using this strategy in live trading.

The developer and publisher of this script are not responsible for any financial losses incurred by the use of this strategy. Market conditions, slippage, and execution quality can affect real-world trading outcomes.

[i]Use this script at your own discretion and always trade responsibly.[/i]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BullByte

//@version=6
strategy("Smart Grid Scalping(Pullback) Strategy[BullByte]", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=30, commission_type=strategy.commission.percent, commission_value=0.04, slippage=1)

// === INPUTS ===
atrLen       = input.int(10, "ATR Length")
gridFactor   = input.float(0.35, "Grid Factor")  // Increased for more spacing
profitTarget = input.float(0.004, "Profit Target", step=0.0001)
noTradeZone  = input.float(0.003, "No-Trade Zone (%)", step=0.0001)
shortLevel   = input.int(5, "Short Trigger Level", minval=0, maxval=14)
longLevel    = input.int(5,  "Long Trigger Level", minval=0, maxval=14)
minRSIShort  = input.int(70, "Min RSI for Short")
maxRSILong   = input.int(30, "Max RSI for Long")

// === CALCULATIONS ===
atr = ta.atr(atrLen)
rsi = ta.rsi(close, 14)
basePrice = close[20]  // Use historical price to widen grid spacing

// === GRID ARRAYS ===
var float[] gridUp = array.new_float(15)
var float[] gridDown = array.new_float(15)

if bar_index > 20
    for i = 0 to 14
        array.set(gridUp, i, basePrice + (i + 1) * atr * gridFactor)
        array.set(gridDown, i, basePrice - (i + 1) * atr * gridFactor)

// === PLOT GRID LINES ===
for i = 0 to 14
    lineColorUp   = i == shortLevel ? color.red : color.new(color.red, 80)
    lineColorDown = i == longLevel  ? color.green : color.new(color.green, 80)
    line.new(bar_index - 1, array.get(gridUp, i), bar_index, array.get(gridUp, i), color=lineColorUp, width=i == shortLevel ? 2 : 1)
    line.new(bar_index - 1, array.get(gridDown, i), bar_index, array.get(gridDown, i), color=lineColorDown, width=i == longLevel ? 2 : 1)

// === ENTRY CONDITIONS ===
shortCond = close > array.get(gridUp, shortLevel) and (high - low) / high > noTradeZone and rsi > minRSIShort and close < open
longCond  = close < array.get(gridDown, longLevel) and (high - low) / low > noTradeZone and rsi < maxRSILong and close > open

if shortCond
    strategy.entry("Short", strategy.short)

if longCond
    strategy.entry("Long", strategy.long)

// === EXIT CONDITIONS ===
if strategy.position_size > 0
    strategy.exit("Exit Long", "Long", limit=close * (1 + profitTarget), trail_price=close * (1 + profitTarget * 0.5), trail_offset=atr)

if strategy.position_size < 0
    strategy.exit("Exit Short", "Short", limit=close * (1 - profitTarget), trail_price=close * (1 - profitTarget * 0.5), trail_offset=atr)

// === ENTRY LABELS ===
plotshape(strategy.position_size > 0 and strategy.position_size[1] <= 0, location=location.belowbar, style=shape.labelup, color=color.green, text="LONG", textcolor=color.white)
plotshape(strategy.position_size < 0 and strategy.position_size[1] >= 0, location=location.abovebar, style=shape.labeldown, color=color.red, text="SHORT", textcolor=color.white)
````
