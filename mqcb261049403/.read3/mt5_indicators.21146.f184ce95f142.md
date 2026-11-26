Long: applied price > AbsolutelyNoLagLWMA(applied price, smoothing length)
Short: applied price < AbsolutelyNoLagLWMA(applied price, smoothing length)
Long: AbsolutelyNoLagLWMA(applied price, smoothing length) > AbsolutelyNoLagLWMA(applied price, smoothing length)[1]
Short: AbsolutelyNoLagLWMA(applied price, smoothing length) < AbsolutelyNoLagLWMA(applied price, smoothing length)[1]
Long: applied price(T1, forming bar) > AbsolutelyNoLagLWMA(applied price, smoothing length, T1, forming bar), calculated on T1 bars and sampled on chart bars
Short: applied price(T1, forming bar) < AbsolutelyNoLagLWMA(applied price, smoothing length, T1, forming bar), calculated on T1 bars and sampled on chart bars
Long: AbsolutelyNoLagLWMA(applied price, smoothing length, T1, forming bar) > AbsolutelyNoLagLWMA(applied price, smoothing length, T1, previous completed bar), calculated on T1 bars and sampled on chart bars
Short: AbsolutelyNoLagLWMA(applied price, smoothing length, T1, forming bar) < AbsolutelyNoLagLWMA(applied price, smoothing length, T1, previous completed bar), calculated on T1 bars and sampled on chart bars