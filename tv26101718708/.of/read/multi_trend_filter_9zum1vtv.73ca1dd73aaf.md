Calculation: Daily trend line = the twice-smoothed midpoint of a Heikin-Ashi open and close, calculated from higher-timeframe bars and smoothed again twice; use the last completed higher-timeframe bar.
Calculation: 4H trend line = the same calculation on higher-timeframe bars; use the last completed higher-timeframe bar.
Calculation: 30m trend line = the same calculation on lower-timeframe bars; use the latest completed lower-timeframe bar within the chart bar.
Long: close > Daily trend line AND 4H trend line > Daily trend line AND (close > 30m trend line OR the previous bar was long)
Short: close < Daily trend line AND 4H trend line < Daily trend line AND (close < 30m trend line OR the previous bar was short)