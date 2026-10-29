Calculation: Session volume profile = divide the current session’s high-low range into equal price bins; assign each chart bar’s volume to the bin containing its close. POC is the highest-volume bin’s midpoint; VAH and VAL bound the smallest contiguous range around POC containing the configured share of volume. Count consecutive zero-volume bins inward from each range extreme, stopping at the first nonzero bin.
Calculation: Higher-timeframe volume profile = the same volume-profile calculation using bars of the mapped higher timeframe, including its still-forming bar.
Calculation: Daily volume profile = the same volume-profile calculation using daily bars, including the still-forming daily bar.
Calculation: Short and long moving averages = selected moving-average type of close, with the short lookback shorter than the long lookback.
Long: Current session high − high × 0 + tick tolerance ≥ high AND close < session high AND consecutive empty top bins ≥ required high-side count AND volatility gate open AND cooldown clear AND outside dead time
Long: low ≤ session low + tick tolerance AND close > session low AND consecutive empty bottom bins ≥ required low-side count AND volatility gate open AND cooldown clear AND outside dead time
Long: Short moving average crosses above long moving average
Long: Close crosses above higher-timeframe VAH
Long: Close > daily VAH OR (close > daily POC + 0.30 × (daily VAH − daily VAL))
Long: Session POC + one price-bin width < close ≤ session VAH AND (close > daily VAH OR close > daily POC + 0.30 × (daily VAH − daily VAL) OR close < daily VAL AND close ≥ daily POC − 0.30 × (daily VAH − daily VAL))
Long: After a qualifying session-edge buy, within the configured expiry, close ≥ previous-session close + ATR-based entry buffer
Long: After a qualifying session-edge buy, within the configured expiry, short moving average crosses above long moving average
Short: high ≥ session high − tick tolerance AND close < session high AND consecutive empty top bins ≥ required high-side count AND volatility gate open AND cooldown clear AND outside dead time
Short: Short moving average crosses below long moving average
Short: Close crosses below higher-timeframe VAL
Short: Close < daily VAL OR (close < daily POC − 0.30 × (daily VAH − daily VAL))
Short: Session VAL ≤ close < session POC − one price-bin width AND (close < daily VAL OR close < daily POC − 0.30 × (daily VAH − daily VAL) OR close > daily VAH AND close ≤ daily POC + 0.30 × (daily VAH − daily VAL))
Short: After a qualifying session-edge sell, within the configured expiry, close ≤ previous-session close − ATR-based entry buffer
Short: After a qualifying session-edge sell, within the configured expiry, short moving average crosses below long moving average