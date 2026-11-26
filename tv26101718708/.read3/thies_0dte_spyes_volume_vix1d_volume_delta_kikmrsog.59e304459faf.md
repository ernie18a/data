Calculation: combined signed volume = sum of volume when close >= open, otherwise negative volume, across component series
Calculation: combined volume = sum of volume across component series
Long: EMA(combined signed volume, smoothing lookback) >= 0
Short: EMA(combined signed volume, smoothing lookback) < 0
Long: EMA(combined signed volume, smoothing lookback) >= 0 AND EMA(combined signed volume, smoothing lookback) > EMA(combined signed volume, smoothing lookback)[1] AND combined volume > MA(combined volume, volume lookback) AND volatility index close <= volatility index close[1]
Short: EMA(combined signed volume, smoothing lookback) < 0 AND EMA(combined signed volume, smoothing lookback) < EMA(combined signed volume, smoothing lookback)[1] AND combined volume > MA(combined volume, volume lookback) AND volatility index close > volatility index close[1]
Exit: long, close < MA(combined volume, volume lookback) OR datetime >= exit-time parameter
Exit: short, close > MA(combined volume, volume lookback) OR datetime >= exit-time parameter
Option: buy call, delta histogram > 0 AND delta histogram rising AND combined volume > moving average of combined volume AND VIX1D <= its previous value AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy put, delta histogram < 0 AND delta histogram falling AND combined volume > moving average of combined volume AND VIX1D > its previous value AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy call, delta histogram > 0 AND SPY price rising AND combined volume > moving average of combined volume AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy put, delta histogram < 0 AND SPY price falling AND combined volume > moving average of combined volume AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy call, opening T1 combined volume spikes AND delta histogram > 0 AND SPY price pulls back to the moving average of combined volume AND combined volume > moving average of combined volume AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy put, opening T1 combined volume spikes AND delta histogram < 0 AND SPY price pulls back to the moving average of combined volume AND combined volume > moving average of combined volume AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy call, delta histogram flips bullish against the opening move AND delta histogram confirms the reversal AND combined volume rising AND combined volume > moving average of combined volume AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy put, delta histogram flips bearish against the opening move AND delta histogram confirms the reversal AND combined volume rising AND combined volume > moving average of combined volume AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy call, scheduled release AND combined volume surges AND delta histogram > 0 AND combined volume > moving average of combined volume AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy put, scheduled release AND combined volume surges AND delta histogram < 0 AND combined volume > moving average of combined volume AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy call, scheduled release AND VIX1D spikes AND delta histogram flips bullish against the initial move AND combined volume > moving average of combined volume AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Option: buy put, scheduled release AND VIX1D spikes AND delta histogram flips bearish against the initial move AND combined volume > moving average of combined volume AND ((time >= P1 AND time <= P2) OR (time >= P3 AND time <= P4)) AND time < P5
Exit: Long, delta histogram turns bearish OR SPY price < moving average of combined volume OR time >= P5
Exit: Short, delta histogram turns bullish OR SPY price > moving average of combined volume OR time >= P5