Calculation: Spread ratio(n) = (high[n] - low[n]) / (sum(high - low, bars [n+1] through [n+Spread lookback]) / (Spread lookback - 1))
Calculation: Average volume(n) = sum(volume, bars [n+1] through [n+Volume lookback]) / (Volume lookback - 1)
Calculation: Close category(n) = down if close[n] <= low[n] + (high[n] - low[n]) * Close-position threshold; else up if close[n] >= high[n] - (high[n] - low[n]) * Close-position threshold; else mid
Short: Spread ratio(1) >= Wide-spread ratio threshold AND volume[1] >= Average volume(1) AND Close category(1) = down AND close[2] > close[3] AND high[1] > high[2]
Short: Spread ratio(1) <= Narrow-spread ratio threshold AND (volume[1] < Average volume(1) OR volume[1] < volume[2]) AND Close category(1) != up AND close[1] > close[2]
Long: volume[1] >= Average volume(1) AND Close category(1) = up AND close[1] < close[2]
Long: Spread ratio(1) >= Wide-spread ratio threshold AND volume[1] >= Average volume(1) AND Close category(1) = up AND close[1] > close[2] AND low[1] < low[2]
Long: Spread ratio(1) <= Narrow-spread ratio threshold AND volume[1] < Average volume(1) AND Close category(1) = down AND close[1] < close[2]
Long: Spread ratio(1) >= Wide-spread ratio threshold AND close[1] > close[2] AND Close category(1) = up AND (volume[1] >= Average volume(1) OR volume[1] > volume[2])
Short: Spread ratio(1) >= Wide-spread ratio threshold AND close[1] < close[2] AND Close category(1) = down AND (volume[1] >= Average volume(1) OR volume[1] > volume[2])