Calculation: MACD line = shorter-lookback EMA of close minus longer-lookback EMA of close
Calculation: Signal line = shorter-lookback EMA of the MACD line
Calculation: Take-profit price = entry price × (1 + configured take-profit percentage)
Calculation: Trailing stop = maximum of the prior trailing stop and current chart-bar low × (1 − configured trailing percentage) while in a long position; reset to 0 while flat
Long: ((weekly MACD line crosses above weekly signal line) OR (daily MACD line crosses above daily signal line AND weekly MACD line > weekly signal line)) AND flat position AND datetime >= configured start time AND datetime <= configured finish time; weekly and daily are higher timeframes than the chart timeframe, using bars still forming
Exit: long, (daily MACD line crosses below daily signal line on the higher timeframe bar still forming) OR (high >= take-profit price) OR (low <= trailing stop)