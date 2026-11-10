Calculation: Trend bands = Let basis be the SMA of an EMA of a selected price source, using the same length for both. Deviation is a multiplier times the EMA of abs(close - basis), using a longer length equal to three times the basis length. Upper band = basis + deviation; lower band = basis - deviation.
Calculation: Trend = Initially zero; set to 1 when close > upper band, set to -1 when close < lower band, and otherwise retain its previous value.
Calculation: Normalized volume = 100 * (volume - lowest volume) / (highest volume - lowest volume), over a lookback equal to the integer part of the basis length times the deviation multiplier.
Calculation: Swept low volume and normalized volume = Maintain a collection of low levels. When trend > 0, low[1] > current lower band, low[1] < low, and low[1] < low[2], add low[1] with volume[1] and normalized volume[1]. On each bar, including the creation bar, remove every level for which low < level or lower band > level; sum the stored volumes and normalized volumes separately for removed levels where low < level. If more than 500 levels remain, remove the oldest. Both sums reset to zero each bar.
Calculation: Swept high volume and normalized volume = Maintain a collection of high levels. When trend < 0, high[1] < current upper band, high[1] > high, and high[1] > high[2], add high[1] with volume[1] and normalized volume[1]. On each bar, including the creation bar, remove every level for which high > level or upper band < level; sum the stored volumes and normalized volumes separately for removed levels where high > level. If more than 500 levels remain, remove the oldest. Both sums reset to zero each bar.
Long: trend > 0 AND previous trend <= 0
Long: swept low volume > 0 AND (swept low normalized volume < major sweep threshold OR swept low normalized volume > major sweep threshold)
Long: swept low volume != 0 AND swept low normalized volume > 0
Short: trend < 0 AND previous trend >= 0
Short: swept high volume > 0 AND (swept high normalized volume < major sweep threshold OR swept high normalized volume > major sweep threshold)
Short: swept high volume != 0 AND swept high normalized volume > 0
Exit: long, trend < 0 AND previous trend >= 0
Exit: short, trend > 0 AND previous trend <= 0