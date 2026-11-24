Calculation: Chart fast EMA = EMA(close, shorter chart lookback)
Calculation: Chart middle EMA = EMA(close, intermediate chart lookback)
Calculation: Chart slow EMA = EMA(close, longer chart lookback)
Calculation: HTF fast EMA = EMA(close, shorter HTF lookback, T1, last completed bar), sampled on chart bars
Calculation: HTF middle EMA = EMA(close, intermediate HTF lookback, T1, last completed bar), sampled on chart bars
Calculation: HTF slow EMA = EMA(close, longer HTF lookback, T1, last completed bar), sampled on chart bars
Calculation: HTF bullish trend = HTF fast EMA > HTF middle EMA AND HTF middle EMA > HTF slow EMA
Calculation: HTF bearish trend = HTF fast EMA < HTF middle EMA AND HTF middle EMA < HTF slow EMA
Calculation: Bullish MSB active = the latest MSB break was upward
Calculation: Prior-volume average = SMA(volume, volume lookback)[1]
Calculation: Demand POI = midpoint of [confirmed PivotLow(low, POI lookback, POI lookback), confirmed PivotLow(low, POI lookback, POI lookback) + ATR(ATR lookback) * zone-width parameter / zone-scale parameter]
Calculation: Supply POI = midpoint of [confirmed PivotHigh(high, POI lookback, POI lookback) - ATR(ATR lookback) * zone-width parameter / zone-scale parameter, confirmed PivotHigh(high, POI lookback, POI lookback)]
Long: Chart fast EMA > Chart middle EMA AND Chart middle EMA > Chart slow EMA
Short: Chart fast EMA < Chart middle EMA AND Chart middle EMA < Chart slow EMA
Long: HTF bullish trend
Short: HTF bearish trend
Long: close crosses above the latest confirmed PivotHigh(high, MSB lookback, MSB lookback)
Short: close crosses below the latest confirmed PivotLow(low, MSB lookback, MSB lookback)
Long: confirmed chart bar AND Bullish MSB active AND (HTF filter disabled OR HTF bullish trend) AND (Chart fast EMA crosses above Chart middle EMA OR Chart middle EMA crosses above WMA(close, separate lookback))
Short: confirmed chart bar AND the latest MSB break was downward AND (HTF filter disabled OR HTF bearish trend) AND (Chart fast EMA crosses below Chart middle EMA OR Chart middle EMA crosses below WMA(close, separate lookback))
Long: confirmed PivotLow(low, POI lookback, POI lookback) AND the Demand POI is farther than overlap ATR multiplier * ATR(ATR lookback) from every retained demand POI midpoint
Short: confirmed PivotHigh(high, POI lookback, POI lookback) AND the Supply POI is farther than overlap ATR multiplier * ATR(ATR lookback) from every retained supply POI midpoint
Long: low > high[gap lookback]
Short: high < low[gap lookback]
Long: close > open AND volume >= volume-multiple * Prior-volume average
Short: close < open AND volume >= volume-multiple * Prior-volume average