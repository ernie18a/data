Calculation: Applied price = a selectable bar price: open, high, low, close, (high + low) / 2, (high + low + close) / 3, or (high + low + 2 * close) / 4.
Calculation: Channel levels = for the highest high H and lowest low L over the same lookback including the evaluated bar, upper entry = H - (33 - entry factor) * (H - L) / 100, lower entry = L + (33 - entry factor) * (H - L) / 100, upper exit = H - (33 - exit factor) * (H - L) / 100, and lower exit = L + (33 - exit factor) * (H - L) / 100; the exit factor is greater than the entry factor.
Calculation: Trend = initially neutral; set to positive when applied price > upper entry, then set to negative when applied price < lower entry; otherwise retain the previous trend. All channel calculations use the chart timeframe or a selectable higher working timeframe, using either its last completed bar or its still-forming bar.
Long: Trend > 0 AND (previous trend < 0 OR (previous trend > 0 AND applied price > upper entry AND previous applied price <= previous upper entry)).
Short: Trend < 0 AND (previous trend > 0 OR (previous trend < 0 AND applied price < lower entry AND previous applied price >= previous lower entry)).
Exit: long, trend < 0 AND (previous trend > 0 OR (previous trend < 0 AND applied price < lower entry AND previous applied price >= previous lower entry)).
Exit: short, trend > 0 AND (previous trend < 0 OR (previous trend > 0 AND applied price > upper entry AND previous applied price <= previous upper entry)).
Exit: long, trend > 0 AND applied price < upper exit AND previous applied price >= previous upper exit.
Exit: short, trend < 0 AND applied price > lower exit AND previous applied price <= previous lower exit.
Exit: long, trend > 0 AND applied price < upper entry AND previous applied price >= previous upper entry.
Exit: short, trend < 0 AND applied price > lower entry AND previous applied price <= previous lower entry.