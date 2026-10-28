Calculation: Higher-timeframe short and long EMAs = EMAs of the higher-timeframe close series, using shorter and longer lookbacks respectively; compare values from the last completed higher-timeframe bar
Calculation: Smoothed RSI = a moving average of RSI over a longer lookback
Long: flat position AND long-entry cooldown inactive AND short-lookback EMA > long-lookback EMA AND higher-timeframe short EMA > higher-timeframe long EMA AND smoothed RSI below its threshold
Long: position is flat or short AND long pin-bar entry is enabled AND high = open AND close − low ≥ 3 × (open − close) AND open ≥ close AND (high − low) / high ≥ the configured target fraction
Short: flat position AND short-entry cooldown inactive AND short-lookback EMA < long-lookback EMA AND higher-timeframe short EMA < higher-timeframe long EMA AND smoothed RSI above its session-dependent threshold
Short: position is flat or long AND short pin-bar entry is enabled AND close = low AND high − close ≥ 3 × (close − open) AND open ≤ close AND (high − low) / high ≥ the configured target fraction
Exit: long, close < the stop price set below entry by the configured stop fraction
Exit: short, close > the stop price set above entry by the configured stop fraction
Exit: long, close ≥ twice the configured target distance above entry AND (ADX ≤ its threshold OR close < close from a longer lookback)
Exit: short, close ≤ twice the configured target distance below entry AND (ADX ≤ its threshold OR close > close from a longer lookback)
Exit: long, higher-timeframe close < its longer-lookback EMA AND elapsed session bars since entry > a threshold AND (ADX ≤ its threshold OR close < close from a longer lookback)
Exit: short, higher-timeframe close > its longer-lookback EMA AND elapsed session bars since entry > a threshold AND (ADX ≤ its threshold OR close > close from a longer lookback)
Exit: long or short, session closing time reached