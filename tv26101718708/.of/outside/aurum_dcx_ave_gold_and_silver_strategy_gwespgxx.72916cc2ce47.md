Instrument: a metals-type instrument (the traded one), evaluated on bar closes, with one position at a time and no pyramiding. Outside data: the US Dollar Index (DXY), taken from a daily series with no lookahead.

Indicators on the traded instrument:
1. Directional strength (DCX, 0-100). Over a window N using Wilder smoothing:
 - Positive and negative directional movement: up-move of high and down-move of low, each smoothed and divided by smoothed true range, then scaled by 100. These are plusDI and minusDI.
 - DX = 100*|plusDI-minusDI|/(plusDI+minusDI).
 - Path efficiency = |close - close N bars ago| / sum of |bar-to-bar close changes| over N, clamped between a small floor and 1.
 - Convexity: take the second difference of close (acceleration). Smooth its positive part (pacc) and its negative part (nacc) with Wilder smoothing. conv=(pacc-nacc)/(pacc+nacc), mapped to 0..1 as 0.5*(conv+1).
 - Mix = (1-w)*efficiency + w*conv01.
 - DCX = 100*sqrt((DX/100)*Mix).
 - Direction lead: plusDI > minusDI means up, minusDI > plusDI means down.
 - DCX rising means it has increased consistently over the last K bars. Falling is the mirror.
2. Adaptive volatility envelope:
 - Midline is a moving average (ALMA, HMA or EMA) of hlc3 over window L.
 - Volatility V = w*P + (1-w)*ATR. P is a high percentile of true range over L. w = clamp(stdev(TR,L)/EMA(TR,L) divided by a reference level, 0, 1).
 - Heat = DCX/100 clamped to 0..1. Multiplier = base*(1 + adapt*(heat-0.5)*2).
 - Upper = midline + multiplier*V. Lower = midline - multiplier*V.
3. DXY bias, which can be switched off (when off, both biases are true): the daily DXY close is compared with an EMA of the daily DXY close. Long bias is true when DXY close < its EMA (USD weakening). Short bias is true when DXY close > its EMA (USD strengthening).
4. Weekly ATR: ATR over a number of weekly bars, taken from the weekly series with no lookahead.

Entry rules, all conditions required:
- Long: close > upper band, DCX > entry threshold, DCX rising, direction lead is up, and long bias true.
- Short: close < lower band, DCX > entry threshold, DCX falling, direction lead is down, and short bias true.

On a long signal, close any existing position and open a long. On a short signal, close any existing position and open a short, so an opposite signal reverses the position.

Exit rules, placed once a position opens as a bracket on the entry price:
- Stop distance d = stop multiplier * weekly ATR.
 - Long stop = the lower of (lower band, entry - d).
 - Short stop = the higher of (upper band, entry + d).
- Target = entry +/- R multiple * |entry - stop|, above entry for longs and below for shorts.
- Exit at whichever of stop or target is hit first, or on a reversing opposite signal.
- Optional trailing exit, off by default: while in a long, stop = the higher of (lower band, average entry price - weekly ATR). While in a short, stop = the lower of (upper band, average entry price + weekly ATR).