Calculation: ATR Renko open and close = open and close of the last completed ATR-based Renko bar at the chart timeframe resolution
Calculation: Prior lookback high/low = highest high/lowest low over the configured lookback, excluding the current bar
Calculation: Stop loss = entry price minus/plus configured ATR multiple for long/short positions, or the nearest qualifying prior order-block boundary when structure-based stops are enabled
Long: ATR Renko close > ATR Renko open
Long: ATR Renko close > ATR Renko open for the first consecutive bullish bar AND (MTF filter disabled OR at least 2 of 3 higher-timeframe 50-period SMAs from their last completed bars are below the chart close) AND (session filter disabled OR current time is within a configured session)
Long: low < prior lookback low AND close > prior lookback low AND close > open
Long: lower wick present on at least 3 consecutive bars, with each wick low within a configured ATR fraction of the previous clustered wick low
Long: Long entry condition AND Renko volume <= its 20-period moving average
Short: ATR Renko close < ATR Renko open
Short: ATR Renko close < ATR Renko open for the first consecutive bearish bar AND (MTF filter disabled OR at least 2 of 3 higher-timeframe 50-period SMAs from their last completed bars are above the chart close) AND (session filter disabled OR current time is within a configured session)
Short: high > prior lookback high AND close < prior lookback high AND close < open
Short: upper wick present on at least 3 consecutive bars, with each wick high within a configured ATR fraction of the previous clustered wick high
Short: Short entry condition AND Renko volume <= its 20-period moving average
Exit: long, confirmed bar close < stop loss
Exit: short, confirmed bar close > stop loss