Calculation: RSI slope = current RSI − RSI from a shorter lookback
Calculation: Dynamic lower zone = max(10, base lower zone − 0.35 × standard deviation of RSI over the RSI lookback)
Calculation: Dynamic extreme lower zone = max(5, extreme lower zone − 0.175 × standard deviation of RSI over the RSI lookback)
Calculation: Dynamic upper zone = min(90, base upper zone + 0.35 × standard deviation of RSI over the RSI lookback)
Calculation: Dynamic extreme upper zone = min(95, extreme upper zone + 0.175 × standard deviation of RSI over the RSI lookback)
Long: ((RSI ≤ dynamic lower zone OR RSI ≤ dynamic extreme lower zone) AND RSI crosses above its shorter-lookback EMA AND RSI slope > 0 AND RSI > prior-bar RSI OR RSI > 50 AND RSI crosses above its shorter-lookback EMA AND RSI slope > 0 AND RSI > its EMA) AND close > long-lookback EMA(close) AND volume > longer-lookback average volume × threshold
Short: ((RSI ≥ dynamic upper zone OR RSI ≥ dynamic extreme upper zone) AND RSI crosses below its shorter-lookback EMA AND RSI slope < 0 AND RSI < prior-bar RSI OR RSI < 50 AND RSI crosses below its shorter-lookback EMA AND RSI slope < 0 AND RSI < its EMA) AND close < long-lookback EMA(close) AND volume > longer-lookback average volume × threshold
Exit: long, RSI > 50 AND RSI crosses below its EMA AND RSI slope < 0
Exit: short, RSI < 50 AND RSI crosses above its EMA AND RSI slope > 0