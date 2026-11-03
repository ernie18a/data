Calculation: Lower-wick percentage = 100 × (min(open, close) − low) / (high − low), or 0 when high = low
Calculation: Upper-wick percentage = 100 × (high − max(open, close)) / (high − low), or 0 when high = low
Calculation: Institutional volume = volume > SMA(volume, 20) × volume multiplier
Calculation: Flow = 100 × sum over the flow period of ((close − open) / (high − low) × volume) divided by the highest absolute value of that sum over the last 50 bars; use 0 for a zero range or zero denominator
Calculation: Zone score = min(100, min(round(pivot-bar volume / max(current SMA(volume, 20), 1) × 25), 40) + min(round(pivot-bar wick percentage × 0.4), 30) + trend points); trend points are 30 for a buy zone when current close > EMA(200), or a sell zone when current close < EMA(200), and 10 otherwise
Calculation: Buy-zone center = (high + low) / 2 of a confirmed pivot-low bar; sell-zone center = (high + low) / 2 of a confirmed pivot-high bar. Both pivots use equal left and right lookbacks. Zone half-height = current ATR(14) × zone-height multiplier / 2.
Long: Institutional volume AND lower-wick percentage ≥ minimum wick threshold AND close > open OR Flow > 10 OR a confirmed pivot low has zone score ≥ minimum score
Short: Institutional volume AND upper-wick percentage ≥ minimum wick threshold AND close < open OR Flow < −10 OR a confirmed pivot high has zone score ≥ minimum score