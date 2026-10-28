Long: shorter-lookback EMA crosses above longer-lookback EMA
Short: shorter-lookback EMA crosses below longer-lookback EMA
Long: shorter-lookback EMA > longer-lookback EMA AND low <= shorter-lookback EMA AND close > shorter-lookback EMA AND previous-bar shorter-lookback EMA > previous-bar longer-lookback EMA
Short: shorter-lookback EMA < longer-lookback EMA AND high >= shorter-lookback EMA AND close < shorter-lookback EMA AND previous-bar shorter-lookback EMA < previous-bar longer-lookback EMA
Long: shorter-lookback EMA > longer-lookback EMA AND low <= longer-lookback EMA AND close > longer-lookback EMA
Short: shorter-lookback EMA < longer-lookback EMA AND high >= longer-lookback EMA AND close < longer-lookback EMA
Long: shorter-lookback EMA > longer-lookback EMA AND close > shorter-lookback EMA AND previous-bar close <= previous-bar shorter-lookback EMA
Short: shorter-lookback EMA < longer-lookback EMA AND close < shorter-lookback EMA AND previous-bar close >= previous-bar shorter-lookback EMA
Long: previous-2-bar close < previous-2-bar open AND previous-bar close > previous-bar open AND previous-bar low > previous-2-bar low AND previous-bar close < previous-2-bar open AND close > previous-bar high AND close > open
Short: previous-2-bar close > previous-2-bar open AND previous-bar close < previous-bar open AND previous-bar high < previous-2-bar high AND previous-bar close > previous-2-bar open AND close < previous-bar low AND close < open
Calculation: Buy-side liquidity levels = confirmed swing highs, requiring the same lookback on both sides; a level is active until a bar closes above it or sweeps it
Calculation: Sell-side liquidity levels = confirmed swing lows, requiring the same lookback on both sides; a level is active until a bar closes below it or sweeps it
Short: at least one active buy-side liquidity level has high > level AND close <= level
Long: at least one active sell-side liquidity level has low < level AND close >= level