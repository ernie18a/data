Long: datetime is within the configured inclusive backtest range AND the fast moving average of the selected price source crosses above the slow moving average of the same source
Short: datetime is within the configured inclusive backtest range AND spot mode is off AND the fast moving average of the selected price source crosses below the slow moving average of the same source
Long: RSI of the selected price source crosses above its overbought threshold AND RSI markings are enabled
Short: RSI of the selected price source crosses below its oversold threshold AND RSI markings are enabled
Long: MACD of close crosses above its signal line AND MACD markings are enabled
Short: MACD of close crosses below its signal line AND MACD markings are enabled
Long: close crosses above its EMA AND surfing signals are enabled
Short: close crosses below its EMA AND surfing signals are enabled
Long: the fast moving average of the selected price source is above the slow moving average of the same source
Short: the fast moving average of the selected price source is below the slow moving average of the same source
Long: background mode is enabled AND the fast moving average of the selected price source is above the slow moving average of the same source
Short: background mode is enabled AND the fast moving average of the selected price source is at or below the slow moving average of the same source
Long: background mode is enabled AND middle MA mode is enabled AND the fast moving average of the selected price source is above the middle moving average of the same source
Short: background mode is enabled AND middle MA mode is enabled AND the fast moving average of the selected price source is at or below the middle moving average of the same source
Exit: short, datetime is within the configured inclusive backtest range AND the fast moving average of the selected price source crosses above the slow moving average of the same source
Exit: long, datetime is within the configured inclusive backtest range AND the fast moving average of the selected price source crosses below the slow moving average of the same source AND (spot mode is off OR middle MA mode is off)
Exit: long, datetime is within the configured inclusive backtest range AND middle MA mode is enabled AND the fast moving average of the selected price source crosses below the middle moving average of the same source
Exit: long, automatic TP/SL is enabled AND a positive long take-profit percentage is configured AND high is at or above entry price multiplied by one plus the long take-profit percentage
Exit: long, automatic TP/SL is enabled AND a positive stop-loss percentage is configured AND low is at or below entry price multiplied by one minus the stop-loss percentage
Exit: short, automatic TP/SL is enabled AND spot mode is off AND a positive short take-profit percentage is configured AND low is at or below entry price multiplied by one minus the short take-profit percentage
Exit: short, automatic TP/SL is enabled AND spot mode is off AND a positive stop-loss percentage is configured AND high is at or above entry price multiplied by one plus the stop-loss percentage
Exit: long, callback mode is enabled AND close is below the highest high over the callback lookback multiplied by one minus the callback percentage
Exit: short, callback mode is enabled AND spot mode is off AND close is above the lowest low over the callback lookback multiplied by one plus the callback percentage