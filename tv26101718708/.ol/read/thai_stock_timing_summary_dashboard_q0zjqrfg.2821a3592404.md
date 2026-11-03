Calculation: Bucket return = percent change from prior close on daily bars; percent change from open to close on intraday bars.
Calculation: Bucket win rate = count of bars in the same weekday bucket (daily) or Thailand local time bucket (intraday) with positive bucket return, divided by the count of bars in that bucket, over the configured lookback.
Calculation: Bucket mean change = mean bucket return over the configured lookback.
Calculation: Selected bucket = bucket with the highest win rate among buckets with positive mean change; ties go to the first bucket in order Monday–Friday or 10:00, 11:00/12:00, 14:00, 15:00, 16:00 Thailand time.
Long: Current bar's bucket = selected bucket AND selected bucket's win rate ≥ 50%