Calculation: Spike = confirmed chart bar AND ATR(ATR lookback) != 0 AND SMA(volume, volume lookback) != 0 AND selected range (true range or high − low) / ATR(ATR lookback) >= range expansion threshold AND volume / SMA(volume, volume lookback) >= volume threshold AND (no prior Spike OR at least cooldown bars since the most recent Spike)
Long: Spike AND close > open
Short: Spike AND close < open
Long: confirmed chart bar AND a prior Spike bar 1 through fade-window bars ago remains among the most recent tracking-limit Spike bars AND its close <= its open AND close > its open
Short: confirmed chart bar AND a prior Spike bar 1 through fade-window bars ago remains among the most recent tracking-limit Spike bars AND its close > its open AND close < its open