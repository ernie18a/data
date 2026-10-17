# Order Block Strategy

- url: https://www.tradingview.com/script/WTvOUjFA-Order-Block-Strategy/
- type: strategy
- pine_id: PUB;94dfed3d5a21403291948fc2fbeb77ee
- version: 1.0

## Description

Order Block Strategy

🎯 [b]Overview[/b]
This strategy automates the detection of Order Blocks (Institutional Supply & Demand Zones) using swing pivot highs and lows. It provides clear visual zone plotting and executes trades when price mitigates these zones, protecting your capital via adaptive risk management tools.Unlike static strategies, this system includes dual risk management logic (ATR-based and Percentage-based), allowing you to trade safely across highly volatile crypto assets, forex pairs, or traditional equities.

🛠️ [b]Key Features[/b]
[list]
[*]Automated Order Block Detection: Uses lookback swing pivots to isolate institutional footprint zones.
[*]Real-time On-Chart Boxes: Dynamically draws and fills bullish (green) and bearish (red) order blocks.
[*]Dual-Mode Stop Loss Engine: Toggle instantly between structural volatility tracking (ATR) or portfolio-based tracking (Percentage).
[*]Automated Trade Execution: Auto-calculates mathematically precise entries, stop losses, and take profit targets with fixed Risk-to-Reward (R:R) ratios.
[*]HUD Performance Dashboard: An integrated on-screen data table displaying your current active configuration for effortless tracking.
[/list]

🚦 [b]How the Logic Works[/b]
1. Zone Identification (Order Blocks)
The script constantly monitors swing high and low points over a customizable lookback period.
[list]
[*]Bullish OB: Plotted when a key swing low forms, identifying the last down-close candle high/low range before an upward impulse.
[*]Bearish OB: Plotted when a key swing high forms, identifying the last up-close candle high/low range before a downward impulse.
[/list]
2. Trade Entry Conditions
[list]
[*]Long Entry: Triggered when the current price drops into a valid Bullish Order Block zone, closes above its floor, and confirms momentum with a bullish close (close > open).
[*]Short Entry: Triggered when the current price rallies into a valid Bearish Order Block zone, closes below its ceiling, and confirms momentum with a bearish close (close < open).
[/list]
3. Execution & Risk Engine
Upon entry validation, the strategy maps out an exact risk envelope:
[list]
[*]ATR Mode: Multiplies the Average True Range (ta.atr) by your multiplier to clear market noise.
[*]Percentage Mode: Sets a strict fixed-percentage risk buffer below or above your execution price.
[*]Take Profit: Automatically set using your custom Risk-to-Reward (R:R) ratio multiplier.
[/list]

⚙️ [b]Configuration & Inputs Explained[/b]
[list]
[*]Lookback Period: Change this to adjust pivot detection sensitivity. Higher values locate macro structural blocks; lower values locate micro intra-day blocks.
[*]ATR Length / Multiplier: Controls volatility filtering. The default 7.5x multiplier acts as a swing-trading buffer to prevent false-breakout stops.
[*]Risk:Reward Ratio: Dictates target sizing. A value of 1.5 means your profit target is exactly 1.5x larger than your capital risk.
[*]Stop Loss Mode: Dropdown to select your preferred risk methodology (ATR vs Percentage).
[/list]

⚠️ [b]Disclaimer[/b]
Past performance does not guarantee future results. This script is designed as an automated trading framework and should be thoroughly backtested on your preferred assets and timeframes before deployment with live capital.

## Source Code

````pine
//@version=5
strategy("Order Block Strategy", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
lookback     = input.int(10,    title="Lookback Period",        minval=1)
atrLen       = input.int(14,    title="ATR Length")
atrMult      = input.float(7.5, title="ATR Multiplier (SL)",   minval=0.1)
rr           = input.float(1.5, title="Risk:Reward Ratio",      minval=0.1)

// ─── SL MODE SELECTION ────────────────────────────────────────────────────────
slMode       = input.string("ATR", title="Stop Loss Mode", options=["ATR", "Percentage"])
slPercent    = input.float(1.0,  title="SL % (if Percentage mode)", minval=0.01, step=0.1)

// ─── ATR ──────────────────────────────────────────────────────────────────────
atr = ta.atr(atrLen)

// ─── STOP LOSS CALCULATION ────────────────────────────────────────────────────
slDistance(entryPrice) =>
    slMode == "Percentage" ? entryPrice * (slPercent / 100) : atr * atrMult

// ─── SWING HIGH / LOW DETECTION ───────────────────────────────────────────────
swingHigh = ta.pivothigh(high, lookback, lookback)
swingLow  = ta.pivotlow(low,  lookback, lookback)

// ─── ORDER BLOCK DETECTION ────────────────────────────────────────────────────
var float bullOB_High = na
var float bullOB_Low  = na
var float bearOB_High = na
var float bearOB_Low  = na

// Bullish Order Block
if not na(swingLow)
    bullOB_High := high[lookback]
    bullOB_Low  := low[lookback]

// Bearish Order Block
if not na(swingHigh)
    bearOB_High := high[lookback]
    bearOB_Low  := low[lookback]

// ─── PLOT ORDER BLOCKS ────────────────────────────────────────────────────────
var box bullBox = na
if not na(bullOB_High) and not na(swingLow)
    bullBox := box.new(bar_index[lookback], bullOB_High, bar_index, bullOB_Low,
                       border_color=color.green, bgcolor=color.new(color.green, 85),
                       border_width=1)

var box bearBox = na
if not na(bearOB_High) and not na(swingHigh)
    bearBox := box.new(bar_index[lookback], bearOB_High, bar_index, bearOB_Low,
                       border_color=color.red, bgcolor=color.new(color.red, 85),
                       border_width=1)

// ─── ENTRY CONDITIONS ─────────────────────────────────────────────────────────
longCondition  = not na(bullOB_High) and
                 close <= bullOB_High and
                 close >= bullOB_Low and
                 close > open

shortCondition = not na(bearOB_High) and
                 close >= bearOB_Low and
                 close <= bearOB_High and
                 close < open

// ─── STOP LOSS & TAKE PROFIT ──────────────────────────────────────────────────
longSL  = close - slDistance(close)
longTP  = close + slDistance(close) * rr

shortSL = close + slDistance(close)
shortTP = close - slDistance(close) * rr

// ─── STRATEGY EXECUTION ───────────────────────────────────────────────────────
if longCondition and strategy.position_size == 0
    strategy.entry("Long", strategy.long)
    strategy.exit("Long Exit", "Long", stop=longSL, limit=longTP)

if shortCondition and strategy.position_size == 0
    strategy.entry("Short", strategy.short)
    strategy.exit("Short Exit", "Short", stop=shortSL, limit=shortTP)

// ─── INFO TABLE ───────────────────────────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 3, border_width=1)
table.cell(infoTable, 0, 0, "SL Mode",    text_color=color.white, bgcolor=color.gray)
table.cell(infoTable, 1, 0, slMode,       text_color=color.white, bgcolor=color.gray)
table.cell(infoTable, 0, 1, "SL Value",   text_color=color.white, bgcolor=color.gray)
table.cell(infoTable, 1, 1, slMode == "Percentage" ? str.tostring(slPercent) + "%" : "ATR x " + str.tostring(atrMult),
           text_color=color.yellow, bgcolor=color.gray)
table.cell(infoTable, 0, 2, "R:R Ratio",  text_color=color.white, bgcolor=color.gray)
table.cell(infoTable, 1, 2, str.tostring(rr) + "x", text_color=color.yellow, bgcolor=color.gray)
````
