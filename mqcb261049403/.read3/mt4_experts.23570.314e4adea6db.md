Calculation: MACD lines = MACD(close, shorter lookback, longer lookback, signal lookback, T3, last completed bar sampled on chart bars)
Calculation: Fractal signal = scan chart-bar shifts from scan-lookback down to zero; return up at the first shift where upper Fractal > 0 AND Ichimoku conversion line (shorter lookback, T2, last completed bar sampled on chart bars) > Ichimoku base line (longer lookback, T2, last completed bar sampled on chart bars) AND low[2] < upper Fractal AND open[1] > upper Fractal; otherwise return down at the first shift where lower Fractal > 0 AND Ichimoku conversion line < Ichimoku base line AND high[2] > lower Fractal AND open[1] < lower Fractal; otherwise return no signal if both upper and lower Fractals are positive; otherwise continue scanning
Long: MACD main != 0 AND MACD main > MACD signal AND Fractal signal = up
Short: MACD main > MACD signal AND MACD main < MACD signal
Exit: long, close[1] = Bollinger Bands(close, lookback, deviation, upper band, chart timeframe, last completed bar)
Exit: short, close[1] = Bollinger Bands(close, lookback, deviation, lower band, chart timeframe, last completed bar)
Calculation: Open-basket profit = sum of open trades' profit, swap, and commission
Exit: long or short, open-basket profit <= -(account balance × hard-stop percentage / 100)
Exit: long or short, open-basket profit <= -(account balance × loss-limit percentage / 100) AND open trade count >= minimum trade-count parameter