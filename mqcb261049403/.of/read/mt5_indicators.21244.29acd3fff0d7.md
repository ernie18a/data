Calculation: Range moving average = for each of the most recent lookback bars, find the highest high and lowest low over the lookback bars ending at that bar; average all of those highs and lows, then round to the price precision.
Calculation: Higher-timeframe range moving average = range moving average calculated on higher-timeframe bars, using the higher-timeframe bar still forming; its value and direction are assigned to every chart bar within that higher-timeframe bar and update as it forms.
Long: Range moving average > its previous-bar value.
Short: Range moving average < its previous-bar value.
Long: Higher-timeframe range moving average > its preceding higher-timeframe-bar value.
Short: Higher-timeframe range moving average < its preceding higher-timeframe-bar value.
Long: Higher-timeframe range moving average equals its preceding higher-timeframe-bar value on the selected signal bar AND was unequal to its preceding higher-timeframe-bar value on the previous chart bar.
Short: Higher-timeframe range moving average > its preceding higher-timeframe-bar value on the selected signal bar AND was <= its preceding higher-timeframe-bar value on the previous chart bar.