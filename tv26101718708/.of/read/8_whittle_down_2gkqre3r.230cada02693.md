Calculation: Higher-timeframe long-term moving average = simple moving average of higher-timeframe closes, ending two higher-timeframe bars before the current bar and using completed bars
Calculation: Add-on short-entry trigger = average short entry price multiplied by a factor above 1
Calculation: First-trade profit target = average short entry price multiplied by a factor below 1
Calculation: Combined-position profit target = average short entry price multiplied by a factor below 1
Calculation: Stop-loss level = average short entry price multiplied by a factor above 1
Short: no open trades AND current close < higher-timeframe long-term moving average AND current time is within the late-afternoon entry window
Short: exactly one open trade AND current high >= add-on short-entry trigger
Exit: Short, current low <= first-trade profit target OR current low <= combined-position profit target OR current high >= stop-loss level