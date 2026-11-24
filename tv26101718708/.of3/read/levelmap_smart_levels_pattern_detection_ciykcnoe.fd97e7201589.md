Calculation: Candle body = ABS(close - open)
Calculation: Upper wick = high - MAX(close, open)
Calculation: Lower wick = MIN(close, open) - low
Calculation: Pivot high = PivotHigh(high, pivot length, pivot length)
Calculation: Pivot low = PivotLow(low, pivot length, pivot length)
Calculation: Previous pivot high = Pivot high at the most recent bar before the current bar where Pivot high is not NA
Calculation: Previous pivot low = Pivot low at the most recent bar before the current bar where Pivot low is not NA
Calculation: Higher high = Pivot high > Previous pivot high
Calculation: Lower high = Pivot high < Previous pivot high
Calculation: Higher low = Pivot low > Previous pivot low
Calculation: Lower low = Pivot low < Previous pivot low
Calculation: Bullish structure = on the most recent bar where Higher high, Higher low, Lower high, or Lower low is true, Higher high or Higher low is true and Lower high and Lower low are both false
Calculation: Bearish structure = on the most recent bar where Higher high, Higher low, Lower high, or Lower low is true, Lower high or Lower low is true
Calculation: T1 VWAP = VWAP(typical price, volume, reset at start of each T1 period)
Calculation: Bull trend alignment = close > EMA(close, shorter lookback) AND EMA(close, shorter lookback) > EMA(close, longer lookback) AND close > T1 VWAP AND Bullish structure
Calculation: Bear trend alignment = close < EMA(close, shorter lookback) AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND close < T1 VWAP AND Bearish structure
Calculation: Bearish sweep = high > Highest(high, sweep lookback)[1] AND close < Highest(high, sweep lookback)[1]
Calculation: Bullish sweep = low < Lowest(low, sweep lookback)[1] AND close > Lowest(low, sweep lookback)[1]
Calculation: Near key low = ABS(low - X) <= low * pin level tolerance for any X in {low of the last completed T1 bar, lowest low of chart bars inside the last completed session 1 window, lowest low of chart bars inside the last completed session 2 window, low of the last completed T3 bar, lowest low of chart bars from the start of the current T2 period through the current bar}
Calculation: Near key high = ABS(high - X) <= high * pin level tolerance for any X in {high of the last completed T1 bar, highest high of chart bars inside the last completed session 1 window, highest high of chart bars inside the last completed session 2 window, high of the last completed T3 bar, highest high of chart bars from the start of the current T2 period through the current bar}
Long: Bull trend alignment
Long: Bull trend alignment AND Higher low
Short: Bear trend alignment
Short: Bear trend alignment AND Lower high
Long: Higher high
Long: Higher low
Short: Lower high
Short: Lower low
Long: Bullish sweep
Short: Bearish sweep
Long: ABS(Pivot low - Previous pivot low) / Previous pivot low < double tolerance
Short: ABS(Pivot high - Previous pivot high) / Previous pivot high < double tolerance
Long: close > open AND Lower wick >= Candle body * pin wick ratio AND Upper wick <= Candle body AND Near key low AND RSI(close, RSI length) < hammer max RSI AND (Pivot low[pivot length] is not NA OR Bullish sweep OR Bullish sweep[1] OR Bullish sweep[2])
Short: close < open AND Upper wick >= Candle body * pin wick ratio AND Lower wick <= Candle body AND Near key high AND RSI(close, RSI length) > shooting star min RSI AND (Pivot high[pivot length] is not NA OR Bearish sweep OR Bearish sweep[1] OR Bearish sweep[2])
Long: close[1] < open[1] AND close > open[1] AND open < close[1]
Short: close[1] > open[1] AND close < open[1] AND open > close[1]
Long: Lower low AND RSI(close, RSI length)[pivot length] > RSI(close, RSI length)[2 * pivot length + bars back to the most recent earlier bar where Pivot low is not NA]
Short: Higher high AND RSI(close, RSI length)[pivot length] < RSI(close, RSI length)[2 * pivot length + bars back to the most recent earlier bar where Pivot high is not NA]