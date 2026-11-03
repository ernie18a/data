Calculation: Selected moving average = configured simple or exponential moving average of chart-timeframe close
Calculation: Average volume = simple moving average of chart-timeframe volume
Calculation: Higher-timeframe EMA = configured EMA of close on a timeframe higher than the chart timeframe, using the bar still forming
Calculation: Daily expected move = daily open × daily implied volatility ÷ square root of the annualization period
Calculation: Daily upper wall = daily open + daily expected move
Calculation: Daily lower wall = daily open − daily expected move
Calculation: Active stop distance = configured ATR multiple, capped at the configured maximum; when the ATR stop is disabled, use the configured maximum
Long: Previous close ≤ previous selected moving average AND current close > current selected moving average AND volume > average volume × configured volume multiplier AND (time filter disabled OR current time is within the configured trading session) AND (ADX filter disabled OR ADX > configured threshold) AND close > higher-timeframe EMA AND RSI < configured upper limit AND daily upper wall − close > configured clearance
Short: Previous close ≥ previous selected moving average AND current close < current selected moving average AND volume > average volume × configured volume multiplier AND (time filter disabled OR current time is within the configured trading session) AND (ADX filter disabled OR ADX > configured threshold) AND close < higher-timeframe EMA AND RSI > configured lower limit AND close − daily lower wall > configured clearance
Exit: long, high ≥ entry price + configured take-profit distance OR low ≤ entry price − active stop distance OR (time filter enabled AND current time is outside the configured trading session)
Exit: short, low ≤ entry price − configured take-profit distance OR high ≥ entry price + active stop distance OR (time filter enabled AND current time is outside the configured trading session)