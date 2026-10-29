Calculation: Linear-regression moving average = simple moving average of the current-bar least-squares linear regression value of close over a lookback; the regression and averaging lookbacks are separately parameterized.
Long: EMA < linear-regression moving average AND close > higher-timeframe SMA of close (last completed bar) AND datetime >= configured start datetime
Short: linear-regression moving average < EMA AND close <= higher-timeframe SMA of close (last completed bar) AND datetime >= configured start datetime
Exit: Long, linear-regression moving average < EMA OR low <= entry price × (1 − stop-loss percentage)
Exit: Short, EMA < linear-regression moving average