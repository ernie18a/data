Calculation: bull_state = fast EMA of close > slow EMA of close (fast lookback shorter than slow lookback) AND Supertrend is bullish
Calculation: bear_state = fast EMA of close < slow EMA of close (same EMAs as bull_state) AND Supertrend is bearish (same Supertrend as bull_state)
Calculation: htf_bull = on the last completed bar of a higher timeframe than the chart, fast EMA of close > slow EMA of close (same lookbacks as the chart) AND Supertrend is bullish (same parameters as the chart)
Calculation: htf_bear = on the last completed bar of the same higher timeframe, fast EMA of close < slow EMA of close AND Supertrend is bearish
Long: bull_state is true on the current bar AND bull_state was false on the previous bar
Long: bull_state is true on the current bar AND bull_state was false on the previous bar AND RSI of close is above its midline (50) AND RSI is below an overbought level (above the midline) AND htf_bull is true
Short: bear_state is true on the current bar AND bear_state was false on the previous bar
Short: bear_state is true on the current bar AND bear_state was false on the previous bar AND RSI of close is below its midline (50) AND RSI is above an oversold level (below the midline) AND htf_bear is true