Calculation: candle body ratio = if high - low > 0 then abs(close - open) / (high - low) else 0
Calculation: Elephant bar = Elephant enabled AND high - low > ATR(ATR lookback) * range multiplier AND candle body ratio > body-strength threshold
Long: close > SMA(close, SMA lookback)
Short: close < SMA(close, SMA lookback)
Long: Elephant bar AND close > open
Short: Elephant bar AND close < open
Long: FVG enabled AND low > high[n bars ago]
Short: FVG enabled AND high < low[n bars ago]
Long: EMA MTF enabled AND chart-bar close crosses above EMA(close, EMA lookback, T1 bars, still-forming bar mapped to chart bars)
Short: EMA MTF enabled AND chart-bar close crosses below EMA(close, EMA lookback, T1 bars, still-forming bar mapped to chart bars)