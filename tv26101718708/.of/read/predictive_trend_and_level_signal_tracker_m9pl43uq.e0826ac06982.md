Calculation: ZLEMA = EMA(length n) of (close + (close - close[lag])), where lag = floor((n-1)/2)
Calculation: TrendUp = ZLEMA > ZLEMA of the previous bar (TrendDown = not TrendUp)
Calculation: HighVol = volume > multiplier * SMA(volume, m)
Calculation: Levels = the high and the low of the last completed bar of each of three timeframes (short, medium, long), all higher than the chart timeframe; each level is checked independently and any one of them can trigger
Calculation: ATR = ATR on the chart timeframe
Long: HighVol AND TrendUp AND ((for any level L, high or low: close > L AND previous close <= L AND close - L > k * ATR) OR (for any level L that is a low: low <= L AND close > L AND min(open, close) - low > r * abs(close - open)))
Short: HighVol AND TrendDown AND ((for any level L, high or low: close < L AND previous close >= L AND L - close > k * ATR) OR (for any level L that is a high: high >= L AND close < L AND high - max(open, close) > r * abs(close - open)))