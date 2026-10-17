# Walke Reversal Zone

- url: https://www.tradingview.com/script/Mc5oRKTK-Walke-Reversal-Zone/
- type: indicator
- pine_id: PUB;edce6f0e73044140bb08c67602fb72d4
- version: 1.0

## Description

WRZ - Walke Reversal Zone - For Scalper, Intraday 15m Ideal, BTST, Short Term | Trend Identification | Black 1.0 Strong Support

This is an experimental educational indicator under development. Purpose: scalper (5m), intraday trader (15m Ideal), BTST trader (75m/1h Gap Judge), short term trader (1D Blue Box).

Formula: Lookback 100, High=highest(100), Low=lowest(100), Range=High-Low
Zones: Red 0.14-0.236 Distribution/Top, Blue 0.703-0.786 Decision/Trend Filter - Blue Hold Rule, Black 1.0 Strong Support, Orange 1.11 Trap, Purple 2.0-2.22 Stop Loss/Exhaustion/Mirror.

6 Observed Behaviors: Reversal, Distribution, Consolidation & Breakout, Mirror Image, Trend Start/End (Blue Hold), Support & Stop Loss.

TREND IDENTIFICATION: Price above Blue = Uptrend, below Blue = Downtrend. Black = Support for continuation. Red = Top (2x rejection). Purple = Bottom.

LIVE EVIDENCE (28 Sep 2026, 15m):
- NIFTY 22,910: Blue 23,257 Break, Black 23,116 Break = 347pt Downtrend
- RALLIS 200.00: Blue 199.74 Hold = Uptrend, Black 198.14 Support, SL 197 Orange Trap
- TATA TECH 698.20: SL 687 Orange - Same logic as RALLIS 197
- RHIM 390.00: Blue Box 366-372 Breakout to 400 = +9.2% Uptrend Start

USE: Scalper 5m (0.5-4pt), Intraday 15m Ideal (Blue Hold = Trend), BTST 1h (Gap Filter), Short Term 1D (Blue Box Breakout).

Tested on: 【entity-NSE¦canonical_name=NSE】 (NIFTY, RALLIS, TATA TECH, RHIM), MCX, US. Educational only, no buy/sell advice, no profit guarantee.

Code: fib014=hi-rng*0.14, fib236=hi-rng*0.236, fib703=hi-rng*0.703, fib786=hi-rng*0.786, fib100=lo, fib111=lo-rng*0.11, fib200=lo-rng*1.0, fib222=lo-rng*1.22

## Source Code

````pine
// @version=6
indicator("Walke Reversal Zone", overlay=true, shorttitle="WRZ")
look = input.int(100, "Swing Lookback")
hi = ta.highest(high, look)
lo = ta.lowest(low, look)
rng = hi - lo

fib014 = hi - rng * 0.14
fib236 = hi - rng * 0.236
fib703 = hi - rng * 0.703
fib786 = hi - rng * 0.786
fib100 = lo
fib111 = lo - rng * 0.11
fib200 = lo - rng * 1.0
fib222 = lo - rng * 1.22

plot(fib014, "0.14", color=color.new(color.red, 0))
plot(fib236, "0.236", color=color.new(color.red, 0))
plot(fib703, "0.703", color=color.new(color.blue, 0))
plot(fib786, "0.786", color=color.new(color.blue, 0))
plot(fib100, "1.0", color=color.new(color.black, 0))
plot(fib111, "1.11", color=color.new(color.orange, 0))
plot(fib200, "2.0", color=color.new(color.purple, 0), linewidth=2)
plot(fib222, "2.22", color=color.new(color.purple, 0), linewidth=2)
````
