Calculation: Trend = 100 × (smoothed Heikin-Ashi close − smoothed Heikin-Ashi open) / (smoothed Heikin-Ashi high − smoothed Heikin-Ashi low), using the same moving-average type and lookback for all four values on the chart timeframe
Calculation: Higher-timeframe bullish = smoothed Heikin-Ashi close > smoothed Heikin-Ashi open on the last completed bar of a timeframe higher than the chart timeframe, using the same moving-average type and lookback
Calculation: Long stop price = entry price − chart-timeframe ATR × multiplier
Long: Higher-timeframe bullish AND Trend > 0 AND previous Trend ≤ 0 AND flat
Exit: long, chart low ≤ Long stop price OR Trend < 0 AND previous Trend ≥ 0