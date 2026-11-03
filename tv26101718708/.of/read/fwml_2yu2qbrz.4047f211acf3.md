Calculation: Premarket high/low = highest high and lowest low of chart bars in the configured premarket session in New York time, accumulated as the session progresses and retained until the next premarket session.
Calculation: Opening-range high/low = high and low of the completed opening-range bar beginning at the configured market-open time in New York time; reset at the start of each day and retain after that bar completes.
Calculation: Bullish score = count of these true comparisons: close > previous daily high, close > premarket high, close > previous weekly high, close > opening-range high, close > VWAP, close > lower-timeframe EMA of close.
Calculation: Bearish score = count of these true comparisons: close < previous daily low, close < premarket low, close < previous weekly low, close < opening-range low, close < VWAP, close < lower-timeframe EMA of close.
Calculation: Previous daily and weekly highs and lows = highs and lows of the last completed higher-timeframe daily and weekly bars, respectively; the weekly timeframe is longer than the daily timeframe.
Calculation: VWAP = cumulative volume-weighted average of (high + low + close) / 3 on chart bars, reset at each daily session.
Calculation: Lower-timeframe EMA of close = EMA of lower-timeframe closes using the last completed lower-timeframe bar within each chart bar.
Long: close > previous daily high
Long: close > premarket high
Long: close > previous weekly high
Long: close > opening-range high
Long: close > VWAP
Long: close > lower-timeframe EMA of close
Long: bullish score > bearish score
Short: close < previous daily low
Short: close < premarket low
Short: close < previous weekly low
Short: close < opening-range low
Short: close < VWAP
Short: close < lower-timeframe EMA of close
Short: bearish score > bullish score