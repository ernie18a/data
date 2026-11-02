Calculation: Highest down-close volume = maximum volume over the preceding lookback bars whose close is below the close of the bar immediately before them.
Long: Shorter-lookback moving average of close crosses above longer-lookback moving average of close AND RSI of close >= buy threshold. Both moving averages use the same selectable type, EMA or SMA.
Short: Shorter-lookback moving average of close crosses below longer-lookback moving average of close AND RSI of close <= sell threshold. Both moving averages use the same selectable type, EMA or SMA.
Exit: Long, shorter-lookback moving average of close crosses below longer-lookback moving average of close AND RSI of close <= sell threshold. Both moving averages use the same selectable type, EMA or SMA.
Long: Volume >= minimum volume AND (close - previous close) / previous close >= minimum price increase fraction.
Long: Close > open AND volume > EMA of volume multiplied by the volume factor.
Short: Close < open AND volume > EMA of volume multiplied by the volume factor.
Long: Highest down-close volume > 0 AND close >= previous close AND volume > highest down-close volume.