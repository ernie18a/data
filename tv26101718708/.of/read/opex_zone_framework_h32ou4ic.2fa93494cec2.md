Calculation: higher-timeframe close = close of the still-forming bar on a timeframe higher than the chart timeframe
Long: time <= expiry date AND (higher-timeframe close >= gamma flip AND (higher-timeframe close < pin OR (higher-timeframe close >= pin AND high <= call resistance 3)))
Short: time <= expiry date AND higher-timeframe close < put floor
Exit: long, higher-timeframe close < gamma flip