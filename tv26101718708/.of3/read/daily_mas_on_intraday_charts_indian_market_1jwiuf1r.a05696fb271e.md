Calculation: NSE chart-bar lookback(days) = days on T1; max(1, round(days / sessions-per-week)) on T2; otherwise max(1, round(days * NSE-session-minutes / chart-interval-minutes))
Calculation: MCX chart-bar lookback(days) = days on T1; max(1, round(days / sessions-per-week)) on T2; otherwise max(1, round(days * MCX-session-minutes / chart-interval-minutes))
Calculation: percent distance(level) = (close - level) / level * 100
Long: NSE chart-bar lookback(NSE shortest day-lookback parameter) <= history-cap AND percent distance(SMA(close, NSE chart-bar lookback(NSE shortest day-lookback parameter), chart bars)) >= 0
Short: NSE chart-bar lookback(NSE shortest day-lookback parameter) <= history-cap AND percent distance(SMA(close, NSE chart-bar lookback(NSE shortest day-lookback parameter), chart bars)) < 0
Long: NSE chart-bar lookback(NSE next-shortest day-lookback parameter) <= history-cap AND percent distance(EMA(close, NSE chart-bar lookback(NSE next-shortest day-lookback parameter), chart bars)) >= 0
Short: NSE chart-bar lookback(NSE next-shortest day-lookback parameter) <= history-cap AND percent distance(EMA(close, NSE chart-bar lookback(NSE next-shortest day-lookback parameter), chart bars)) < 0
Long: NSE chart-bar lookback(NSE next-longest day-lookback parameter) <= history-cap AND percent distance(EMA(close, NSE chart-bar lookback(NSE next-longest day-lookback parameter), chart bars)) >= 0
Short: NSE chart-bar lookback(NSE next-longest day-lookback parameter) <= history-cap AND percent distance(EMA(close, NSE chart-bar lookback(NSE next-longest day-lookback parameter), chart bars)) < 0
Long: NSE chart-bar lookback(NSE longest day-lookback parameter) <= history-cap AND percent distance(EMA(close, NSE chart-bar lookback(NSE longest day-lookback parameter), chart bars)) >= 0
Short: NSE chart-bar lookback(NSE longest day-lookback parameter) <= history-cap AND percent distance(EMA(close, NSE chart-bar lookback(NSE longest day-lookback parameter), chart bars)) < 0
Long: MCX chart-bar lookback(MCX day-lookback parameter) <= history-cap AND percent distance(SMA(close, MCX chart-bar lookback(MCX day-lookback parameter), chart bars)) >= 0
Short: MCX chart-bar lookback(MCX day-lookback parameter) <= history-cap AND percent distance(SMA(close, MCX chart-bar lookback(MCX day-lookback parameter), chart bars)) < 0
Long: percent distance(session VWAP(hlc3, volume, chart bars)) >= 0
Short: percent distance(session VWAP(hlc3, volume, chart bars)) < 0