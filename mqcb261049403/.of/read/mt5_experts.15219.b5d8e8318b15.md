Calculation: For each indicator-timeframe bar t, H(t) and L(t) are the highest high and lowest low, respectively, over the same lookback of bars ending immediately before t. The indicator timeframe may be higher or lower than the chart timeframe; use its last completed bar.
Calculation: Bullish-only age = the number of indicator-timeframe bars since the most recent bar t where H(t-1) <= H(t-1-lookback) AND H(t) > H(t-lookback) AND (L(t-1) < L(t-1-lookback) OR L(t) >= L(t-lookback)); use infinity if none exists.
Calculation: Bearish-only age = the number of indicator-timeframe bars since the most recent bar t where L(t-1) >= L(t-1-lookback) AND L(t) < L(t-lookback) AND (H(t-1) > H(t-1-lookback) OR H(t) <= H(t-lookback)); use infinity if none exists.
Long: H(t-1) <= H(t-1-lookback) AND H(t) > H(t-lookback)
Short: L(t-1) >= L(t-1-lookback) AND L(t) < L(t-lookback)
Exit: long, bearish-only age < bullish-only age OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, bullish-only age < bearish-only age OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance