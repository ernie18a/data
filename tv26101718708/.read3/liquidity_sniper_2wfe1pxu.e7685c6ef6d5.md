Calculation: upper touch = high if wick mode is on, else max(open, close)
Calculation: lower touch = low if wick mode is on, else min(open, close)
Calculation: walls = liquidity walls, each with a side (short-liquidation above price or long-liquidation below price), a price and an intensity; updated on each bar in this order: (1) a short-liquidation wall is removed when upper touch >= its price, and a long-liquidation wall is removed when lower touch <= its price; (2) each remaining wall's intensity is multiplied by 0.5^(1 / half-life), and the wall is removed if the result is below removal fraction * SMA(volume, baseline length); (3) for each leverage tier L with weight w_L, a long-liquidation wall is added at ((high + low + close) / 3) * (1 - 1 / L + maintenance margin / 100) and a short-liquidation wall at ((high + low + close) / 3) * (1 + 1 / L - maintenance margin / 100), each with intensity volume * (base-volume floor + MIN(volume / SMA(volume, baseline length), relative-volume cap) * base-volume slope) * w_L; (4) if PivotHigh(pivot length, pivot length) exists on this bar, a short-liquidation wall is added at that pivot high, and if PivotLow(pivot length, pivot length) exists, a long-liquidation wall is added at that pivot low, each with intensity volume[pivot length] * stop weight; (5) an added wall whose price is within ATR(ATR length) * merge multiple of an existing wall on the same side instead adds its intensity to the first such existing wall
Calculation: sweep level = sweep threshold * MAX(intensity over walls[1])
Calculation: signed volume = volume of a bar if close > open, -volume if close < open, else 0
Calculation: bar delta = sum of signed volume over T1 bars inside the current chart bar, including the T1 bar still forming, if the lower-timeframe switch is on and such bars exist; otherwise signed volume of the current chart bar
Calculation: cumulative delta = sum of bar delta over completed chart bars within the current T2 bar, reset at the first chart bar of each new T2 bar
Calculation: pool down share = 100 * SUM(intensity of long-liquidation walls below close and within magnet distance % of close) / (SUM(intensity of short-liquidation walls above close and within magnet distance % of close) + SUM(intensity of long-liquidation walls below close and within magnet distance % of close))
Long: walls[1] contains a long-liquidation wall with lower touch <= its price AND its intensity >= sweep level
Short: walls[1] contains a short-liquidation wall with upper touch >= its price AND its intensity >= sweep level
Long: pool down share <= lower share threshold
Short: pool down share >= upper share threshold
Long: bar delta >= 0
Short: bar delta < 0
Long: cumulative delta >= 0
Short: cumulative delta < 0