# Market Ranging FIlter

- url: https://www.tradingview.com/script/WymOl03k-Market-Ranging-FIlter/
- type: indicator
- pine_id: PUB;9611dd6fbc8448a3a7b5f15d5caa0ab6
- version: 1.0

## Description

[b]Market Ranging Filter[/b]

[b]Overview[/b]

Most trading strategies fail not because of poor entry logic, but because they fire during the wrong market conditions. A strategy tuned for trending markets will bleed equity when price is simply chopping sideways. The Market Ranging Filter solves this problem by combining two independent volatility and directional signals into a single binary read: is the market moving with enough energy to trade, or is it not?

The indicator plots ATR and its smoothed baseline side by side, then overlays a blue background highlight whenever the filter is active. When the background is lit, the market meets the minimum conditions for trending or expanding price action. When it is blank, the market is likely consolidating and discretionary entries should be avoided or filtered out.

[b]How it works[/b]

The filter evaluates two conditions independently and requires both to be true simultaneously.

The first condition is an ATR expansion check. Raw ATR must be above its SWMA-smoothed baseline, and at least one of the last four bars must also have shown rising ATR. This confirms that volatility is not only elevated but actively expanding.

[pine]
atr  = ta.atr(atrlength)
satr = ta.swma(atr)

atrExpanding = atr > satr and
     (atr > atr[1] or atr > atr[2] or atr > atr[3] or atr > atr[4])
[/pine]

The second condition is a directional strength check using ADX and the DI lines. The filter accepts either a strong ADX reading above 18, or a softer directional read where one DI dominates the other and leads ADX with ADX still above 12. This allows the filter to activate early in a trend, before ADX fully confirms direction.

[pine]
[diplus, diminus, adx] = ta.dmi(adxlen, adxlensig)

directionConfirmed = adx > 18
     or (diplus > diminus and diplus > adx and adx > 12)
     or (diminus > diplus and diminus > adx and adx > 12)
[/pine]

The filter activates only when both conditions are true at the same time.

Visual output:

[list]
[*][b]Red line (ATR)[/b] — raw ATR value. Rising means volatility is increasing.
[*][b]Yellow-green line (smoothed ATR)[/b] — SWMA baseline of ATR. When raw ATR crosses above this, the volatility leg of the filter begins qualifying.
[*][b]Blue background[/b] — both conditions are active. The market is exhibiting expansion and directional character simultaneously.
[*][b]No background[/b] — one or both conditions are failing. The market is ranging or lacks directional conviction.
[/list]

[b]Inputs[/b]

[list=1]
[*][b]ATR Length[/b] — sets the lookback period for ATR calculation. Lower values (e.g. 7) make the indicator more reactive to short bursts of volatility; higher values (e.g. 20) require sustained volatility expansion before qualifying. Default: 14.
[*][b]ATR Smoothing[/b] — present in the code but currently reserved for a future smoothing method. Does not affect output in this version. Default: 5.
[*][b]DI Length[/b] — controls the lookback period for the DMI calculation, affecting how quickly the DI lines respond to directional changes. Lower values (e.g. 7) produce faster, noisier signals; higher values (e.g. 21) produce slower, smoother readings. Default: 17.
[*][b]ADX Smoothing[/b] — sets the smoothing period applied to the ADX line. Lower values (e.g. 7) make ADX more sensitive to recent directional changes; higher values (e.g. 20) produce a more stable ADX that responds slowly to trend reversals. Default: 14.
[/list]

[b]Usage notes[/b]

[list]
[*]Use this indicator as a gate for other strategies. Only take signals from your primary setup when the blue background is active. Ignore signals when the background is blank.
[*]On higher timeframes (Daily, 4H), the filter stays active for longer stretches. On lower timeframes (15m and below), it will flicker more frequently due to intraday noise. Widen the ATR and DI lengths slightly for lower timeframes.
[*]The filter does not tell you the direction of the move. It only tells you a move is underway. Combine it with a trend-following indicator or price structure analysis to determine bias.
[*]The dual-DI condition (DI leading ADX) means the filter can light up at the early stages of a trend, before ADX crosses 25. This is intentional. Early activation trades off some false positives for catching moves before they are fully extended.
[*]If the background flickers rapidly on and off within a few bars, the market is likely in a transitional or indecisive state. Treat flickering as a no-trade condition.
[/list]

[b]Recommended pairings[/b]

This filter works well as a pre-condition layer for breakout, momentum, or trend-following strategies. Pair it with a directional bias indicator such as a moving average slope, EMA crossover, or higher timeframe trend filter to build a complete entry framework.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jabez4jc

//@version=6
indicator(title="Market Ranging FIlter", shorttitle="RF", overlay=false, timeframe="", timeframe_gaps=true)

GATR = "Market Ranging FIlter"
atrlength = input.int(title="ATR Length", defval=14, minval=1)
smoothatr = input.int(title="ATR Smoothing", defval=5, minval=1)
atr = ta.atr(atrlength)
satr = ta.swma(atr)//, smoothatr)
plot(atr, title = "ATR", color=color.new(#B71C1C, 0))
plot(satr, title = "ATR", color=color.new(#c6f73d, 0))

adxlen = input.int(17, minval=1, title="DI Length")
adxlensig = input.int(14, title="ADX Smoothing", minval=1)
[diplus, diminus, adx] = ta.dmi(adxlen, adxlensig)

ok = atr > satr and (atr > atr[1] or atr > atr[2] or atr > atr[3] or atr > atr[4]) and (adx > 18 or (diplus > diminus and diplus > adx and adx > 12) or (diminus > diplus and diminus > adx and adx > 12))// and isTrending
bgcolor(ok ? color.new(color.blue, 60) : na)
````
