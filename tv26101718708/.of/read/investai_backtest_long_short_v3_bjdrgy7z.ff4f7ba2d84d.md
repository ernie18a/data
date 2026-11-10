Calculation: Long stop and target = close of the bar issuing the most recent long entry order minus a stop multiplier times ATR on that bar, and that close plus a target multiplier times ATR on that bar, respectively; retain these levels until replaced by another long entry order.
Calculation: Short stop and target = close of the bar issuing the most recent short entry order plus a stop multiplier times ATR on that bar, and that close minus a target multiplier times ATR on that bar, respectively; retain these levels until replaced by another short entry order.
Long: On the current bar, or on the preceding bar when confirmation is enabled, the shorter-period close EMA crosses above the longer-period close EMA AND RSI is above its lower threshold AND RSI is below its upper threshold AND the MACD line is above its signal line AND, if the volume filter is enabled, volume is above its SMA multiplied by a volume multiplier AND, if the trend filter is enabled, close is above a still longer-period close EMA.
Short: On the current bar, or on the preceding bar when confirmation is enabled, the shorter-period close EMA crosses below the longer-period close EMA AND RSI is above its lower threshold AND RSI is below its upper threshold AND the MACD line is below its signal line AND, if the volume filter is enabled, volume is above its SMA multiplied by a volume multiplier AND, if the trend filter is enabled, close is below a still longer-period close EMA.
Long: RSI is below its lower threshold.
Short: RSI is above its upper threshold.
Long: MACD line is above its signal line.
Short: MACD line is at or below its signal line.
Long: Shorter-period close EMA is above longer-period close EMA.
Short: Shorter-period close EMA is at or below longer-period close EMA.
Exit: long, low is at or below the long stop OR high is at or above the long target.
Exit: short, high is at or above the short stop OR low is at or below the short target.