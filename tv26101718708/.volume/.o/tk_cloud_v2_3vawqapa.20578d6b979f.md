Calculation: Tenkan-Sen = midpoint of the highest high and lowest low over a shorter lookback
Calculation: Kijun-Sen = midpoint of the highest high and lowest low over a longer lookback
Calculation: Anchor VWAP = cumulative sum of HLC3 × volume divided by cumulative volume since the start of the selected anchor period, including the forming period
Calculation: Moving average = configured moving average of close over its selected lookback
Long: Tenkan-Sen > Kijun-Sen AND close > open AND close > max(Tenkan-Sen, Kijun-Sen) AND low <= max(Tenkan-Sen, Kijun-Sen) AND high >= min(Tenkan-Sen, Kijun-Sen) AND close > Moving average AND close > Anchor VWAP
Short: Tenkan-Sen < Kijun-Sen