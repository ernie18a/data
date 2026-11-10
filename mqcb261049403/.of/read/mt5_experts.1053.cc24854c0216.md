Calculation: Pivot = (high + low + close) / 3 of the last completed higher-timeframe bar.
Calculation: Resistance levels = first: 2 × pivot − higher-timeframe low; second: pivot + higher-timeframe high − higher-timeframe low; third: higher-timeframe high + 2 × (pivot − higher-timeframe low).
Calculation: Support levels = first: 2 × pivot − higher-timeframe high; second: pivot − higher-timeframe high + higher-timeframe low; third: higher-timeframe low − 2 × (higher-timeframe high − pivot). The support and resistance levels use the same last completed higher-timeframe bar as the pivot and are fixed at entry for exits.
Long: Previous chart-bar close > current pivot AND chart-bar close before that <= current pivot.
Short: Previous chart-bar close < current pivot AND chart-bar close before that >= current pivot.
Exit: long, low <= selected entry-time support level OR high >= corresponding entry-time resistance level.
Exit: long OR short, intraday closing enabled AND datetime hour = configured closing hour.