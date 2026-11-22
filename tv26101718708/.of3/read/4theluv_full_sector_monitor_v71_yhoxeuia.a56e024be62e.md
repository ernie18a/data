Calculation: sector change = (close(T1, current bar) - close(T1, prior bar)) / close(T1, prior bar) * 100; sampled on chart bars using the current, possibly still-forming T1 bar
Calculation: RVOL = volume(T1, current bar) / SMA(volume, lookback, T1, current bar); sampled on chart bars using the current, possibly still-forming T1 bar
Calculation: breadth = count of sector changes >= 0
Calculation: strength = sector change * min(RVOL, volume cap)
Long: sector change > 0 AND RVOL >= strong RVOL threshold
Short: sector change < 0 AND RVOL >= strong RVOL threshold
Long: breadth >= uptrend breadth threshold
Short: breadth <= downtrend breadth threshold
Long: strength > high-conviction threshold
Calculation: Sector breadth = count of sector ETFs with Rate of Change(close on T1, preceding bar) > 0
Calculation: Sector strength = Rate of Change(sector ETF close on T1, preceding bar) × min(Relative Volume(sector ETF volume on T1, RVOL lookback), RVOL cap)
Calculation: Sector leader = top-weighted holding with the greatest absolute Rate of Change(close on T1, preceding bar)
Long: offensive sectors lead AND sector breadth ≥ risk-on breadth threshold
Short: defensive sectors lead AND sector breadth ≤ risk-off breadth threshold
Long: sector breadth ≥ trend-up breadth threshold
Short: sector breadth ≤ trend-down breadth threshold
Long: sector ETF Rate of Change(close on T1, preceding bar) > 0 AND Relative Volume(sector ETF volume on T1, RVOL lookback) ≥ strong RVOL threshold AND (no sector leader OR sector leader Rate of Change(close on T1, preceding bar) ≥ 0)
Short: sector ETF Rate of Change(close on T1, preceding bar) < 0 AND Relative Volume(sector ETF volume on T1, RVOL lookback) ≥ strong RVOL threshold
Long: sector ETF Rate of Change(close on T1, preceding bar) < 0 AND Relative Volume(sector ETF volume on T1, RVOL lookback) < weak RVOL threshold
Short: sector ETF Rate of Change(close on T1, preceding bar) > 0 AND Relative Volume(sector ETF volume on T1, RVOL lookback) < weak RVOL threshold
Long: sector strength > strength trade threshold
Short: sector strength < −strength trade threshold
Long: sector leader Rate of Change(close on T1, preceding bar) > 0
Short: sector leader Rate of Change(close on T1, preceding bar) < 0