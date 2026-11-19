Long: Supertrend direction is bullish (ATR lookback, ATR multiplier, source, and wick-selection parameters)
Short: Supertrend direction is bearish (ATR lookback, ATR multiplier, source, and wick-selection parameters)
Long: Supertrend direction changes from bearish to bullish (ATR lookback, ATR multiplier, source, and wick-selection parameters)
Short: Supertrend direction changes from bullish to bearish (ATR lookback, ATR multiplier, source, and wick-selection parameters)
Calculation: Trend SMA = SMA(source, trend lookback) on chart bars when chart-timeframe mode is selected, or on T1 bars using the current T1 bar, including its still-forming value in realtime, and mapped onto chart bars when other-timeframe mode is selected
Calculation: Trend regime = neutral when (chart open <= upper band OR chart close <= upper band) AND (chart open >= lower band OR chart close >= lower band), where upper band = Trend SMA + ATR(trend lookback, chart bars) × channel-width factor and lower band = Trend SMA - ATR(trend lookback, chart bars) × channel-width factor; otherwise bullish when source >= Trend SMA and bearish otherwise
Long: Trend regime is bullish
Short: Trend regime is bearish
Calculation: EMA signal state = long when prior state is not long and Trend regime is bullish and EMA(source, shorter EMA lookback) > EMA(source, longer EMA lookback); otherwise short when prior state is not short and Trend regime is bearish and EMA(source, shorter EMA lookback) < EMA(source, longer EMA lookback); otherwise flat when prior state is nonflat and ((Trend regime is bullish and EMA(source, shorter EMA lookback) < EMA(source, longer EMA lookback)) OR (Trend regime is bearish and EMA(source, shorter EMA lookback) > EMA(source, longer EMA lookback))); otherwise prior state, initialized flat
Long: EMA signal state changes to long
Short: EMA signal state changes to short
Exit: long, EMA signal state changes from nonflat to flat
Exit: short, EMA signal state changes from nonflat to flat
Long: EMA(source, longer EMA lookback) crosses above Trend SMA on chart bars
Short: EMA(source, longer EMA lookback) crosses below Trend SMA on chart bars