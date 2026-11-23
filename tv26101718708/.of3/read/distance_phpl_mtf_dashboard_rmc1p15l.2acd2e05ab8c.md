Calculation: PctAboveLow(n) = round(100 * (upper price / Lowest(low, n) - 1), decimals)
Calculation: PctBelowHigh(n) = -round(100 * (1 - lower price / Highest(high, n)), decimals)
Calculation: Pullback(n) = 1 - round(Stochastic(high, low, close, n) / 100, decimals)
Long: PctAboveLow(lookback, T1, last completed bar) > buy threshold
Long: Pullback(lookback, T1, last completed bar) < buy-zone pullback threshold
Long: Pullback(lookback, T1, last completed bar) < watch-bottom pullback threshold
Long: PctAboveLow(lookback, T1, last completed bar) > 0
Long: Pullback(lookback, T1, last completed bar) > high pullback threshold
Short: PctBelowHigh(lookback, T1, last completed bar) < 0
Short: PctBelowHigh(lookback, T1, last completed bar) > sell threshold
Short: Pullback(lookback, T1, last completed bar) > sell-zone pullback threshold AND PctAboveLow(lookback, T1, last completed bar) <= buy threshold
Short: Pullback(lookback, T1, last completed bar) > watch-top pullback threshold AND PctAboveLow(lookback, T1, last completed bar) <= buy threshold
Short: Pullback(lookback, T1, last completed bar) < low pullback threshold
Long: PctAboveLow(chart lookback, chart bars) crosses PL alert threshold
Short: PctBelowHigh(chart lookback, chart bars) crosses PH alert threshold
Long: PctBelowHigh(chart lookback, chart bars) = 0
Short: PctAboveLow(chart lookback, chart bars) = 0
Long: PctAboveLow(chart lookback, chart bars)[1] > PL alert threshold AND PctAboveLow(chart lookback, chart bars) <= PL alert threshold
Long: count over Ti, i = 1 to 10, of (PctAboveLow(lookback, Ti, last completed bar) > MTF extreme threshold) >= confluence count