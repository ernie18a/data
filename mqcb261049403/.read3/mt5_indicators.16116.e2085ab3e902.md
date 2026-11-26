Calculation: PPO = PPO(selected price, shorter lookback, longer lookback, separate fast and slow smoothing methods), calculated on T1 bars; chart bars use the still-forming T1 bar
Calculation: PPO signal = MA(PPO, separate signal lookback, separate signal smoothing method), calculated on T1 bars; chart bars use the still-forming T1 bar
Calculation: PPO trend = up when PPO > PPO signal, down when PPO < PPO signal, otherwise the prior chart bar's PPO trend
Long: PPO trend is up
Short: PPO trend is down