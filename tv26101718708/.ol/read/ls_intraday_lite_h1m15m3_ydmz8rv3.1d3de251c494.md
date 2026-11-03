Calculation: External swing high/low = latest confirmed pivot high/low on a higher timeframe than the chart, using a longer lookback than the internal pivots; use completed bars.
Calculation: Internal swing high/low = latest confirmed pivot high/low on a higher timeframe than the chart, using a shorter lookback than the external pivots; use completed bars.
Calculation: Upper wick = high − max(open, close); lower wick = min(open, close) − low.
Calculation: Minimum sweep overshoot = max(close × 0.0005, ATR(14) × 0.3), calculated on the higher timeframe than the chart.
Calculation: Higher-timeframe bias = bullish after close exceeds the latest confirmed swing high, bearish after close falls below the latest confirmed swing low, otherwise retain the prior bias (initially neutral); swing pivots and close are from a higher timeframe than the chart, using completed bars.
Long: Higher-timeframe close > internal swing high AND that level has not been crossed before.
Short: Higher-timeframe close < internal swing low AND that level has not been crossed before.
Long: Higher-timeframe low < external swing low − minimum sweep overshoot AND higher-timeframe close > external swing low AND lower wick > (higher-timeframe high − higher-timeframe low) × 0.3.
Short: Higher-timeframe high > external swing high + minimum sweep overshoot AND higher-timeframe close < external swing high AND upper wick > (higher-timeframe high − higher-timeframe low) × 0.3.
Long: A pending low sweep exists AND a newly confirmed external swing low is above the lowest low of the pending sweep(s); the pivot uses higher-timeframe completed bars.
Short: A pending high sweep exists AND a newly confirmed external swing high is below the highest high of the pending sweep(s); the pivot uses higher-timeframe completed bars.
Long: A confirmed low sweep is within the sweep window counted in chart bars AND the higher-timeframe close > internal swing high with that level not previously crossed AND higher-timeframe bias is bullish or neutral.
Short: A confirmed high sweep is within the sweep window counted in chart bars AND the higher-timeframe close < internal swing low with that level not previously crossed AND higher-timeframe bias is bearish or neutral.