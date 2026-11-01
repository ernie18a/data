Calculation: Bullish state = shorter-lookback Williams %R > longer-lookback Williams %R AND longer-lookback Williams %R > a signal level.
Calculation: Bearish state = shorter-lookback Williams %R < longer-lookback Williams %R AND longer-lookback Williams %R < (-100 - signal level).
Long: Bullish state on the chart timeframe.
Short: Bearish state on the chart timeframe.
Long: Bullish state on a configurable indicator timeframe, which may be higher or lower than the chart timeframe, AND the preceding indicator-timeframe bar is not in the bullish state; use the last completed indicator-timeframe bar by default or the still-forming bar if configured.
Short: Bearish state on a configurable indicator timeframe, which may be higher or lower than the chart timeframe, AND the preceding indicator-timeframe bar is not in the bearish state; use the last completed indicator-timeframe bar by default or the still-forming bar if configured.
Exit: long, bearish state on the configurable indicator timeframe, using the last completed bar by default or the still-forming bar if configured.
Exit: short, bullish state on the configurable indicator timeframe, using the last completed bar by default or the still-forming bar if configured.
Exit: long, low <= entry price - configured stop-loss distance OR high >= entry price + configured take-profit distance, when the corresponding stop is enabled.
Exit: short, high >= entry price + configured stop-loss distance OR low <= entry price - configured take-profit distance, when the corresponding stop is enabled.