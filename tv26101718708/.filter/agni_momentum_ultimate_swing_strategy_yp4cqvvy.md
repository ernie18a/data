# AGNI MOMENTUM - Ultimate Swing Strategy

- url: https://www.tradingview.com/script/yp4CqVVY-AGNI-MOMENTUM-Ultimate-Swing-Strategy/
- type: strategy
- pine_id: PUB;aa006dc60bb24018a55f0d139133a794
- version: 1.0

## Description

The AGNI MOMENTUM is a high-performance swing trading system developed by The Stock Yogi. Designed specifically for the 1-Hour, 4-Hour, and Daily timeframes, this strategy is built to identify and ride major market waves while maintaining professional-grade risk controls.

Why "AGNI" Momentum?
In the Indian markets, catching a trend at the right moment is like capturing fire. This strategy uses a triple-layered approach to ensure you only enter when the "spark" is confirmed and the trend has the fuel to continue.

Technical Pillars:

The Institutional Anchor (VWAP): We only look for Long opportunities when the price is trading above the Volume Weighted Average Price, ensuring we are on the side of institutional money.

The Momentum Trigger (Stochastic RSI): A precision-tuned oscillator that identifies overextended markets and triggers entries exactly as momentum shifts in our favor.

The Volatility Shield (ATR): Instead of fixed-point stops, we use Average True Range. This allows your stop loss to adjust automatically based on market "Garam-Hawa" (volatility), preventing unnecessary stop-outs.

The Trailing Sentinel: A built-in trailing stop follows the price, protecting your "Kamai" (earnings) as the trade progresses.

Key Features:

Optimized for Indian Markets: Defaulted to IST (GMT+5:30) with customizable session windows.

Aggressive Reward: Set to a default 1:3 Risk-to-Reward ratio to ensure long-term profitability.

Clean Visuals: Thick Target/SL lines and "AGNI Stickers" ($) make the trade status clear at a glance.

Toggle Flexibility: Easily switch off Sell trades to focus on a "Buy Only" trending market.

How to Use:

Preferred Timeframes: 1H, 4H for aggressive swings, 1D for structural wealth building.

Assets: Optimized for Nifty, BankNifty, and high-volume Blue-chip stocks.

## Source Code

````pine
//@version=6
strategy("AGNI MOMENTUM - Ultimate Swing Strategy", 
     overlay=true, 
     initial_capital=100000, 
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=100,
     calc_on_every_tick=true)

// ==========================
// ⚙️ DIRECTION TOGGLES
// ==========================
enableBuy  = input.bool(true, "Allow BUY Trades?", group="Trade Direction")
enableSell = input.bool(false, "Allow SELL Trades?", group="Trade Direction")

// ==========================
// ⚙️ INPUTS & FILTERS
// ==========================
tzOffset      = input.string("GMT+530", "Timezone Offset (IST)", group="Session")
entrySession  = input.session("0015-0000", "Entry Window", group="Session")
exitTime      = input.int(1529, "Forced Exit Time (HHMM)", group="Session")

// Risk Management
rrRatio       = input.float(3.0, "Risk/Reward Ratio", minval=1.0, group="Risk")
atrMultiplier = input.float(1.5, "ATR SL Multiplier", group="Risk")
useTrailing   = input.bool(true, "Enable Trailing Stop?", group="Risk")

// Indicators Settings
stochLen      = input.int(14, "Stoch RSI Length", group="Indicators")
smoothK       = input.int(3, "K Smoothing", group="Indicators")
smoothD       = input.int(3, "D Smoothing", group="Indicators")

// ==========================
// 📊 INDICATORS
// ==========================
// VWAP (Now has a style toggle to hide/show)
vwapVal = ta.vwap(hlc3)
plot(vwapVal, "VWAP Line", color.new(color.orange, 0), 2, display=display.none) // Set to hidden by default

rsiVal = ta.rsi(close, stochLen)
stochK = ta.sma(ta.stoch(rsiVal, rsiVal, rsiVal, stochLen), smoothK)
stochD = ta.sma(stochK, smoothD)
atrVal = ta.atr(14)

// ==========================
// 📌 CONDITION LOGIC
// ==========================
in_session = not na(time(timeframe.period, entrySession, tzOffset))
curr_time  = hour(time, tzOffset) * 100 + minute(time, tzOffset)

long_trigger  = ta.crossover(stochK, stochD) and close > vwapVal and in_session and enableBuy
short_trigger = ta.crossunder(stochK, stochD) and close < vwapVal and in_session and enableSell

// ==========================
// 🎯 EXECUTION LOGIC
// ==========================
var float entry_sl = na
var float entry_tp = na

if long_trigger and strategy.position_size == 0
    entry_sl := close - (atrVal * atrMultiplier)
    float risk = close - entry_sl
    entry_tp := close + (risk * rrRatio)
    strategy.entry("Long", strategy.long, comment="Sentinel BUY")

if short_trigger and strategy.position_size == 0
    entry_sl := close + (atrVal * atrMultiplier)
    float risk = entry_sl - close
    entry_tp := close - (risk * rrRatio)
    strategy.entry("Short", strategy.short, comment="Sentinel SELL")

// Trailing logic remains active in background
if useTrailing and strategy.position_size > 0
    entry_sl := math.max(entry_sl, low[1]) 

if useTrailing and strategy.position_size < 0
    entry_sl := math.min(entry_sl, high[1])

// Exit management
if strategy.position_size > 0
    strategy.exit("L Exit", "Long", stop=entry_sl, limit=entry_tp, comment_loss="SL/Trail", comment_profit="TP")

if strategy.position_size < 0
    strategy.exit("S Exit", "Short", stop=entry_sl, limit=entry_tp, comment_loss="SL/Trail", comment_profit="TP")

if curr_time >= exitTime
    strategy.close_all("EOD Exit")

// ==========================
// 📈 VISUALS (MINIMALIST)
// ==========================
// Removed bgcolor and barcolor logic

// Bold Target and Stop lines (Linetype set for visibility during trades)
plot(strategy.position_size != 0 ? entry_tp : na, "Target Line", color.new(color.lime, 0), linewidth=4, style=plot.style_linebr)
plot(strategy.position_size != 0 ? entry_sl : na, "Stop/Trail Line", color.new(color.red, 0), linewidth=4, style=plot.style_linebr)
````
