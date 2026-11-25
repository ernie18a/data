Long: SMA((high + low) / 2, lookback, T1, bar still forming) < close OR SMA((high + low) / 2, lookback, T1, bar still forming) >= close AND random integer modulo range parameter = 1
Short: SMA((high + low) / 2, lookback, T1, bar still forming) > close AND random integer modulo range parameter != 1 OR SMA((high + low) / 2, lookback, T1, bar still forming) = close AND random integer modulo range parameter = 0
Exit: long, entry price >= close + stop-loss distance
Exit: short, close >= entry price + stop-loss distance