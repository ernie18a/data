Calculation: Reference high/low = wick high/low, or body high/low if configured; set from the first bearish in-session chart bar each day when enabled, then replace with the chart bar beginning at 12:45 when that option is enabled.
Calculation: Opening-bar high/low = high/low of the first daily bar on the fixed source timeframe, which may be higher or lower than the chart timeframe; use the source bar's final values once completed.
Calculation: First bearish-bar midpoint = (high + low) / 2 of the first bearish daily bar on the fixed source timeframe, which may be higher or lower than the chart timeframe; use the last completed source bar.
Calculation: 12:45-bar midpoint = (high + low) / 2 of the source-timeframe bar beginning at 12:45, which may be higher or lower than the chart timeframe; use the last completed source bar.
Calculation: EMA = exponential moving average of chart close.
Long: Close crosses above reference high AND (trend filter disabled OR close > EMA) AND current bias is not long.
Short: Close crosses below reference low AND (trend filter disabled OR close < EMA) AND current bias is not short.
Long: Close crosses above opening-bar high.
Short: Close crosses below opening-bar low.
Long: Close > first bearish-bar midpoint.
Short: Close < first bearish-bar midpoint.
Long: Close > 12:45-bar midpoint.
Short: Close < 12:45-bar midpoint.