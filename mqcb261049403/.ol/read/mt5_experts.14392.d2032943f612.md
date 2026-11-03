Calculation: Anchored momentum = 100 × (EMA of price / SMA of price − 1), using the same lookback for both averages.
Calculation: Momentum candle color = blue if anchored momentum of open < anchored momentum of close, pink if anchored momentum of open > anchored momentum of close, and gray if equal; use completed bars aggregated on the indicator timeframe, which may be higher, equal to, or lower than the chart timeframe.
Long: Last completed indicator-timeframe candle is blue AND the preceding completed candle is not blue.
Short: Last completed indicator-timeframe candle is pink AND the preceding completed candle is not pink.
Exit: short, last completed indicator-timeframe candle is blue AND the preceding completed candle is not blue.
Exit: long, last completed indicator-timeframe candle is pink AND the preceding completed candle is not pink.