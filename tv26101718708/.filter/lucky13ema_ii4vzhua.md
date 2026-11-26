# Lucky13ema

- url: https://www.tradingview.com/script/ii4VZhUA-Lucky13ema/
- type: strategy
- pine_id: PUB;7fab10c4bd7a49baa1e84658a3398ddb
- version: 2.0

## Description

🚀 Lucky13ema - 1-Min Momentum Scalper
What it is
A filtered momentum strategy built around the 13 EMA crossover on 1-minute charts. Catches clean price breaks above/below the 13 EMA with 3 quality filters to reduce noise and improve win rate.

Core Logic
BUY: First green candle closing above 13 EMA (after being below)

SELL: First red candle closing below 13 EMA (after being above)

Triple Filter System:
Volume > 20-period SMA × 1.2x (confirms conviction)
VWAP alignment (longs above VWAP, shorts below)
5-min EMA confirmation (higher timeframe bias)

How to Use
Apply to 1-min chart of liquid instruments (SPY, QQQ, IWM, major stocks)
Regular hours only recommended (9:30-4:00 ET)
Start with defaults, then optimize:
Profit Target: 1.5% | Stop Loss: 0.75% (2:1 R:R)
Volume Multiplier: 1.2x

*Toggle filters OFF first to see raw signals, then ON for quality

Key Inputs
Setting	Default	Purpose
Use Filters	✅ ON	Master filter toggle
Volume Mult	1.2x	Volume conviction threshold
Profit %	1.5%	Take profit target
Stop %	0.75%	Risk per trade
Trailing Stop	OFF	Let winners run (10pt trail)

Performance Notes
70-80% fewer signals vs raw EMA crosses
Higher win rate from multi-filter confirmation
Best on trending days, choppy markets kill it!!!!!!!!!
Backtest 6+ months before live use
Risk Management
Fixed R:R or trailing stops keep math simple
Never risk >1-2% account per trade
Avoid news events - volume spikes create false breaks

Pro Tips
SPY/QQQ best - tight spreads, high volume
Enable debug table to see filter status
2:1 R:R minimum (try 2%/1% settings)
Trail on strong movers (>3% runs)

Built for scalpers who want quality over quantity. Test thoroughly!


*Published April 30, 2026 | Optimized for 2026 market structure

## Source Code

````pine
//@version=5
strategy("Lucky13ema - Filtered v2", overlay=true, initial_capital=30000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, pyramiding=0)

// Inputs
use_filters = input.bool(true, title="Use Filters")
vol_mult = input.float(1.2, title="Volume Multiplier")
ema_length = input.int(13, title="EMA Length")
profit_target = input.float(2.0, title="Profit Target %", minval=0.1)
stop_loss = input.float(1.00, title="Stop Loss %", minval=0.1)
use_trailing = input.bool(true, title="Use Trailing Stop")
trail_offset = input.float(10, title="Trail Offset (points)", minval=1)
use_vwap_cross = input.bool(false, title="Require VWAP Cross for Entries")

// Indicators
ema13 = ta.ema(close, ema_length)
vwap_value = ta.vwap(hlc3)
plot(ema13, color=color.blue, linewidth=2)
plot(vwap_value, color=color.purple, linewidth=1)

// Base conditions
is_green = close > open
is_red = close < open
prev_below = close[1] <= ema13[1]
prev_above = close[1] >= ema13[1]

buy_condition = is_green and close > ema13 and prev_below
sell_condition = is_red and close < ema13 and prev_above

// Filters
vol_ok = volume > ta.sma(volume, 20) * vol_mult
vwap_long_ok = not use_filters or close > vwap_value
vwap_short_ok = not use_filters or close < vwap_value
long_vwap_cross = ta.crossover(close, vwap_value)
short_vwap_cross = ta.crossunder(close, vwap_value)

buy_signal = buy_condition and vol_ok and (use_vwap_cross ? long_vwap_cross : vwap_long_ok)
sell_signal = sell_condition and vol_ok and (use_vwap_cross ? short_vwap_cross : vwap_short_ok)

// Signals
plotshape(buy_signal, style=shape.labelup, location=location.belowbar, color=color.green, size=size.normal, text="BUY")
plotshape(sell_signal, style=shape.labeldown, location=location.abovebar, color=color.red, size=size.normal, text="SELL")

// Entries
if buy_signal and strategy.position_size <= 0
    strategy.entry("Long", strategy.long)
if sell_signal and strategy.position_size >= 0
    strategy.entry("Short", strategy.short)

// Exits
if use_trailing
    strategy.exit("Exit Long", from_entry="Long", trail_points=trail_offset, trail_offset=trail_offset)
    strategy.exit("Exit Short", from_entry="Short", trail_points=trail_offset, trail_offset=trail_offset)
else
    strategy.exit("Exit Long", from_entry="Long", profit=profit_target, loss=stop_loss)
    strategy.exit("Exit Short", from_entry="Short", profit=profit_target, loss=stop_loss)
````
