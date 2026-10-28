Calculation: Bullish CISD = close > the latest pivot-high value sampled with a lag when a pivot high is confirmed
Calculation: Bearish CISD = close < the latest pivot-low value sampled with a lag when a pivot low is confirmed
Calculation: Volume spurt = volume > its rolling average volume × a configurable multiplier
Long: short-period EMA crosses above short-lookback VWMA OR (short-period EMA crosses above short-lookback VWMA AND Bullish CISD AND volume spurt AND close > open AND medium-period EMA > longer-lookback VWMA)
Short: short-period EMA crosses below short-lookback VWMA OR (short-period EMA crosses below short-lookback VWMA AND Bearish CISD AND volume spurt AND close < open AND medium-period EMA < longer-lookback VWMA)