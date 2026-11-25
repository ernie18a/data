Long: SMA(close, shorter lookback, last completed chart bar) < SMA(close, longer lookback, last completed chart bar)
Short: SMA(close, shorter lookback, last completed chart bar) > SMA(close, longer lookback, last completed chart bar)
Long: the most recently closed losing trade was short
Short: the most recently closed losing trade was long
Exit: long, close[1] = upper Bollinger Band(close, lookback, deviation, last completed chart bar)
Exit: short, close[1] = lower Bollinger Band(close, lookback, deviation, last completed chart bar)
Exit: long, total open profit for this instrument, excluding commissions and swaps, >= money target parameter
Exit: short, total open profit for this instrument, excluding commissions and swaps, >= money target parameter
Exit: long, 0 < total open profit including commissions and swaps < profit threshold parameter AND running cumulative open profit including commissions and swaps <= total open profit including commissions and swaps - money drawdown parameter
Exit: short, 0 < total open profit including commissions and swaps < profit threshold parameter AND running cumulative open profit including commissions and swaps <= total open profit including commissions and swaps - money drawdown parameter