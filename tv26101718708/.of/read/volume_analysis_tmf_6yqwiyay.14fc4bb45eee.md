Calculation: Average volume = simple moving average of volume over a lookback
Calculation: High-volume candle = volume > average volume × a multiplier
Calculation: Active zone = the high-to-low range of the highest-volume candle in each consecutive streak of high-volume candles; replace it with a higher-volume candle in the same streak; end the streak on the first candle that is not high volume
Long: close[1] ≤ active zone high AND close > active zone high AND ((zone age < 10 bars AND no earlier breakout signal fired for this zone) OR zone age ≥ 10 bars)
Short: close[1] ≥ active zone low AND close < active zone low AND ((zone age < 10 bars AND no earlier breakout signal fired for this zone) OR zone age ≥ 10 bars)