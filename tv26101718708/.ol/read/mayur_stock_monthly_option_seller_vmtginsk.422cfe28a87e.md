Calculation: Composite trend score = clamp to [-1,1] of the weighted average of four components: clamp((short-lookback EMA − long-lookback EMA)/ATR), clamp((RSI − 50)/20), clamp((close − VWAP)/ATR), and +1 for bullish Supertrend or −1 for bearish Supertrend. Use the same indicator parameters on each timeframe; VWAP contributes zero when unavailable.
Calculation: Overall trend score = average of the chart-timeframe composite score and scores from two higher timeframes; use the last completed higher-timeframe bar.
Calculation: Expected move = close × annualized standard deviation of log returns over a lookback × square root of time to expiry in years.
Calculation: Put strike = close − safety multiple × expected move; call strike = close + safety multiple × expected move.
Calculation: Put exit level = put strike + management buffer × expected move; call exit level = call strike − management buffer × expected move.
Calculation: Prior swing low/high = lowest low/high over the lookback, excluding the current bar.
Long: Overall trend score ≥ −range threshold
Short: Overall trend score ≤ range threshold
Exit: Long, close ≤ put exit level OR (overall trend score > range threshold AND close < prior swing low)
Exit: Short, close ≥ call exit level OR (overall trend score < −range threshold AND close > prior swing high)