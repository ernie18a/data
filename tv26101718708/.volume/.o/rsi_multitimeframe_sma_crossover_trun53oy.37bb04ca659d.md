Calculation: timeframe RSI average = volume-weighted moving average of RSI(close) on each of the eight configured timeframes, using each timeframe’s last completed bar
Calculation: composite = arithmetic mean of the eight timeframe RSI averages
Calculation: fast line = EMA(composite, shorter of the two EMA lookbacks)
Calculation: slow line = EMA(composite, longer of the two EMA lookbacks)
Long: fast line crosses above slow line AND datetime is within the configured backtest window
Short: fast line crosses below slow line AND datetime is within the configured backtest window
Exit: Long, fast line crosses below slow line OR fast line crosses above slow line OR low <= entry price × (1 − configured long stop-loss fraction)
Exit: Short, fast line crosses above slow line OR high >= entry price × (1 + configured short stop-loss fraction)