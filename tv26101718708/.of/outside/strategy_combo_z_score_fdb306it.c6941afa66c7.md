Always-in-the-market long/short reversal system on the charted instrument (an equity index such as SPY). It uses outside volatility series, the instrument's own Bollinger %B, and optionally a trend filter.

Outside data, sampled at the chart timeframe close:
- MOVE (bond volatility index)
- VIX
- VVIX
- OVX (oil volatility index)
- spot crude oil price

Three z-score signals, each computed as (value - rolling mean) / rolling standard deviation over the same long lookback (roughly one trading year):
1. MOVE signal: value = MOVE divided by the reciprocal of VIX, which is MOVE * VIX.
2. VIX signal: value = VIX / VVIX.
3. Oil signal: value = crude oil price divided by the reciprocal of OVX, which is oil * OVX.

Instrument-own inputs:
- %B = (close - lower Bollinger band) / (upper band - lower band), using a short-period Bollinger band of the instrument's close with a standard-deviation multiplier.
- A long-period EMA of the instrument's close.

User toggles: each of the three z-signals can be switched active or inactive (default all active), and the EMA filter can be on or off (default on). The active set is whichever signals are switched on. If none is active, no trade is placed. Trade only on bars at or after a configured start date.

Short condition, evaluated each bar:
- Every active z-score is greater than 0, AND
- %B is below 0.5 (price in the lower half of the band), AND
- if the EMA filter is on, close is below the EMA.

If the short condition is false, the bar is in the long regime. There is no separate long-entry test. Long is the default state whenever the short condition fails.

Execution each bar, with fixed order size:
- If the short condition is true: enter short only when the current position is long (position size > 0). This reverses long into short. If flat or already short, do nothing.
- If the short condition is false: enter long only when the current position is flat or short (position size <= 0). This reverses short into long. If already long, do nothing.
- Consequently the first position is long once the start date is reached and the short condition is false. If the short condition is true while flat, stay flat until it turns false.
- After that the position flips between long and short only. It is never deliberately flat.

The explicit 'close long' and 'close short' calls are effectively no-ops. Their ids match no entry ids, and their conditions, which require all active z-scores < 0 (or > 0) with %B above (or below) 0.5, could never be true on the same bar as the opposite branch. Exits happen only through reversal. Do not implement stop-losses, targets, or option trades.