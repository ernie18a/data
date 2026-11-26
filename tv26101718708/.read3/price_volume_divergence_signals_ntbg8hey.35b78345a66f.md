Calculation: pivot volume = volume[confirmation bars] if pivot candle volume mode, else SMA(volume, volume average length)[confirmation bars]
Calculation: pivot high = PivotHigh(high, pivot left bars, confirmation bars)
Calculation: pivot low = PivotLow(low, pivot left bars, confirmation bars)
Calculation: high pivot distance = bars back to latest earlier bar where pivot high and pivot volume are both available
Calculation: low pivot distance = bars back to latest earlier bar where pivot low and pivot volume are both available
Calculation: high price increase % = (pivot high - pivot high[high pivot distance]) / pivot high[high pivot distance] * 100
Calculation: high volume decrease % = (pivot volume[high pivot distance] - pivot volume) / pivot volume[high pivot distance] * 100
Calculation: low price decrease % = (pivot low[low pivot distance] - pivot low) / pivot low[low pivot distance] * 100
Calculation: low volume decrease % = (pivot volume[low pivot distance] - pivot volume) / pivot volume[low pivot distance] * 100
Calculation: phase volume = SMA(volume, volume smoothing)
Calculation: phase ready = close[phase price lookback] and phase volume[phase volume lookback] are both available
Calculation: phase price up = close >= close[phase price lookback] if phase ready, else close >= open
Calculation: phase volume up = phase volume >= phase volume[phase volume lookback] if phase ready, else volume >= volume[1] or volume[1] is unavailable
Long: low price decrease % > 0 AND low price decrease % >= min price difference % AND low volume decrease % > 0 AND low volume decrease % >= min volume difference % AND low pivot distance <= max pivot distance
Long: (phase price up AND phase volume up) OR (NOT phase price up AND NOT phase volume up)
Long: close >= EMA(close, trend EMA length)
Short: high price increase % > 0 AND high price increase % >= min price difference % AND high volume decrease % > 0 AND high volume decrease % >= min volume difference % AND high pivot distance <= max pivot distance
Short: (phase price up AND NOT phase volume up) OR (NOT phase price up AND phase volume up)
Short: close < EMA(close, trend EMA length)