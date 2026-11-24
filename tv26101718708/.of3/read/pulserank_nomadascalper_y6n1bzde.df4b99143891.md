Calculation: member score = impulse weight × clip((close − close[impulse lookback]) / ATR(close, ATR lookback), −score cap, score cap) + VWAP weight × clip((close − VWAP(hlc3)) / ATR(close, ATR lookback), −score cap, score cap) + EMA weight × clip((close − EMA(close, EMA lookback)) / ATR(close, ATR lookback), −score cap, score cap), calculated on T1 bars using the bar still forming and sampled on chart bars
Calculation: member day change = (current close on T1 bar still forming / close of the last completed T2 bar − 1) × 100, sampled on chart bars
Calculation: basket score = weighted average of eligible member scores, using reported shares outstanding × current member price as weights when cap weighting is configured and all eligible weights are positive and in the same currency; otherwise use equal weights
Long: an eligible basket member score > score threshold
Short: an eligible basket member score < −score threshold
Long: an eligible basket member day change > 0
Short: an eligible basket member day change < 0
Long: an eligible basket member close > VWAP(hlc3, T1 bar still forming)
Short: an eligible basket member close < VWAP(hlc3, T1 bar still forming)
Long: an eligible basket member close > EMA(close, EMA lookback, T1 bar still forming)
Short: an eligible basket member close < EMA(close, EMA lookback, T1 bar still forming)
Long: EMA(close, EMA lookback, T1 bar still forming) > EMA(close, EMA lookback, T1)[slope lookback]
Short: EMA(close, EMA lookback, T1 bar still forming) < EMA(close, EMA lookback, T1)[slope lookback]
Long: fast SMA(close) >= slow SMA(close)
Short: fast SMA(close) < slow SMA(close)
Long: basket score > score threshold
Short: basket score < −score threshold
Long: volatility-index day change transitions from not below every basket member day change to below every basket member day change, with complete basket coverage and matching source closes on a confirmed chart close, and (trend filter disabled OR chart close > both fast SMA(close) and slow SMA(close))
Short: volatility-index day change transitions from not above every basket member day change to above every basket member day change, with complete basket coverage and matching source closes on a confirmed chart close, and (trend filter disabled OR chart close < both fast SMA(close) and slow SMA(close))
Long: basket score crosses above score threshold from at or below it since the previous qualifying observation, with complete unique member coverage, valid member scores and day changes, matching member and volatility-index source closes at the confirmed standard intraday chart close, and the previous qualifying observation on the same T2 date within the larger of one T1 duration and one chart-bar duration
Short: basket score crosses below −score threshold from at or above it since the previous qualifying observation, with complete unique member coverage, valid member scores and day changes, matching member and volatility-index source closes at the confirmed standard intraday chart close, and the previous qualifying observation on the same T2 date within the larger of one T1 duration and one chart-bar duration