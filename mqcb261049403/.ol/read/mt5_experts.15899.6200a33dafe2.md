Calculation: Volume-weighted open = rolling sum of bar open × configured volume divided by rolling sum of configured volume, on the configured signal timeframe
Calculation: Volume-weighted close = rolling sum of bar close × configured volume divided by rolling sum of configured volume, on the configured signal timeframe
Long: Volume-weighted close > Volume-weighted open on the selected completed signal bar AND Volume-weighted close <= Volume-weighted open on the preceding completed signal bar
Short: Volume-weighted close < Volume-weighted open on the selected completed signal bar AND Volume-weighted close >= Volume-weighted open on the preceding completed signal bar
Exit: long, Volume-weighted close < Volume-weighted open on the selected completed signal bar
Exit: short, Volume-weighted close > Volume-weighted open on the selected completed signal bar