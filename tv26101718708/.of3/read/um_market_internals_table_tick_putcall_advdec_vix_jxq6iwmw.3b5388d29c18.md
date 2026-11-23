Calculation: implied volatility MA = SMA(implied volatility, MA length) or EMA(implied volatility, MA length) or WMA(implied volatility, MA length) or Nadaraya-Watson estimator(implied volatility, bandwidth, relative weight, kernel length), as selected by MA type
Long: NYSE net upticks(chart bars, T1, last completed bar) >= net upticks buying threshold
Short: NYSE net upticks(chart bars, T1, last completed bar) <= -(net upticks selling threshold)
Long: put/call ratio(chart bars, T1, last completed bar) >= put/call bullish threshold
Short: put/call ratio(chart bars, T1, last completed bar) <= put/call bearish threshold
Long: NYSE advance-decline(chart bars, T1, last completed bar) >= advance-decline bullish threshold AND NYSE advance-decline(chart bars, T1, last completed bar) < advance-decline breadth climax threshold
Short: NYSE advance-decline(chart bars, T1, last completed bar) <= -(advance-decline bearish threshold)
Long: implied volatility MA < implied volatility MA[1]
Short: implied volatility MA >= implied volatility MA[1]
Long: NYSE net upticks(chart bars, T1, last completed bar) crosses above net upticks buying threshold
Long: NYSE net upticks(chart bars, T1, last completed bar) crosses above net upticks extreme buying threshold
Short: NYSE net upticks(chart bars, T1, last completed bar) crosses below -(net upticks selling threshold)
Short: NYSE net upticks(chart bars, T1, last completed bar) crosses below -(net upticks extreme selling threshold)
Short: NYSE net upticks(chart bars, T1, last completed bar) crosses below -(net upticks capitulation threshold)
Long: put/call ratio(chart bars, T1, last completed bar) crosses above put/call bullish threshold
Long: put/call ratio(chart bars, T1, last completed bar) crosses above put/call extreme bullish threshold
Short: put/call ratio(chart bars, T1, last completed bar) crosses below put/call bearish threshold
Short: put/call ratio(chart bars, T1, last completed bar) crosses below put/call extreme bearish threshold
Long: NYSE advance-decline(chart bars, T1, last completed bar) crosses above advance-decline bullish threshold
Long: NYSE advance-decline(chart bars, T1, last completed bar) crosses above advance-decline strong bullish threshold
Short: NYSE advance-decline(chart bars, T1, last completed bar) crosses below -(advance-decline bearish threshold)
Short: NYSE advance-decline(chart bars, T1, last completed bar) crosses below -(advance-decline strong bearish threshold)
Short: NYSE advance-decline(chart bars, T1, last completed bar) crosses below -(advance-decline capitulation threshold)
Long: implied volatility MA < implied volatility MA[1] AND implied volatility MA[1] >= implied volatility MA[2]
Short: implied volatility MA >= implied volatility MA[1] AND implied volatility MA[1] < implied volatility MA[2]
Long: NYSE net upticks(chart bars, T1, last completed bar) >= net upticks buying threshold AND NYSE advance-decline(chart bars, T1, last completed bar) >= advance-decline bullish threshold AND NYSE advance-decline(chart bars, T1, last completed bar) < advance-decline breadth climax threshold AND implied volatility MA < implied volatility MA[1]
Short: NYSE net upticks(chart bars, T1, last completed bar) <= -(net upticks selling threshold) AND NYSE advance-decline(chart bars, T1, last completed bar) <= -(advance-decline bearish threshold) AND implied volatility MA >= implied volatility MA[1]
Short: NYSE net upticks(chart bars, T1, last completed bar) >= net upticks climax buying threshold AND put/call ratio(chart bars, T1, last completed bar) >= put/call extreme bullish threshold
Long: NYSE net upticks(chart bars, T1, last completed bar) <= -(net upticks capitulation threshold) AND put/call ratio(chart bars, T1, last completed bar) <= put/call extreme bearish threshold