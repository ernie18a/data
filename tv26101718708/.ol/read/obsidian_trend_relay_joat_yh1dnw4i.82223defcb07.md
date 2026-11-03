Calculation: Zero-lag EMA = 2 × EMA(source, lookback) − EMA(EMA(source, lookback), lookback)
Calculation: EMA ribbon is bullish when fast EMA > mid EMA > slow EMA > base EMA; bearish when fast EMA < mid EMA < slow EMA < base EMA
Calculation: Local trend vote = +1 when close > SuperTrend, zero-lag EMA > slow EMA, the EMA ribbon is bullish, and both zero-lag EMA and fast EMA rose from the prior bar; −1 for the inverse conditions; otherwise 0
Calculation: Each higher-timeframe vote = +1 when zero-lag EMA > slow EMA, fast EMA > slow EMA, and zero-lag EMA > fast EMA; −1 when all three inequalities are reversed; otherwise 0. Use each higher timeframe’s still-forming bar with lookahead off.
Calculation: Vote total = local trend vote + three higher-timeframe votes + SuperTrend vote (+1 if close > SuperTrend, −1 if close < SuperTrend, otherwise 0) + ribbon vote (+1 if bullish, −1 if bearish, otherwise 0) + prediction vote (+1 if zero-lag EMA rose and close > zero-lag EMA, −1 if it fell and close < zero-lag EMA, otherwise 0)
Calculation: ATR-safe = maximum of ATR and minimum tick size
Calculation: Proximity score = maximum of clamp(1 − absolute(close − zero-lag EMA) / (ATR-safe × proximity threshold), 0, 1) and clamp(1 − absolute(close − SuperTrend) / (ATR-safe × proximity threshold), 0, 1)
Long: bar is confirmed AND ((vote total ≥ minimum confluence and vote total > 0) OR (close crosses above zero-lag EMA and vote total ≥ minimum confluence − 1) OR (proximity score > 0.70 and vote total > 0 and close ≥ zero-lag EMA))
Short: bar is confirmed AND ((vote total ≤ −minimum confluence and vote total < 0) OR (close crosses below zero-lag EMA and vote total ≤ −(minimum confluence − 1)) OR (proximity score > 0.70 and vote total < 0 and close ≤ zero-lag EMA))
Exit: long, confirmed bar AND (low ≤ ladder stop OR high ≥ third ladder target)
Exit: short, confirmed bar AND (high ≥ ladder stop OR low ≤ third ladder target)