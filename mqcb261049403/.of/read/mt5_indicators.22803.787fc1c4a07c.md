Calculation: Weighted price for an OHLC field = sum over lookback index i from 0 (current bar) to lookback length minus 1 of normalized weight[i] × field[i]; normalized weight[i] = raw weight[i] divided by the sum of raw weights over the lookback; raw weight[i] = (shift1 + x^rank1 × (1 − shift1)) × (shift2 + (1 − x)^rank2 × (1 − shift2)) × (shift3 + |2x − 1|^rank3 × (1 − shift3)), where x = i / (lookback length − 1).
Calculation: Comparison open = previous bar's weighted close plus the vertical price shift if abs(open − close) is at most the gap threshold in price units; otherwise, current bar's weighted open.
Long: Weighted close > comparison open on the chart timeframe.
Short: Weighted close < comparison open on the chart timeframe.
Long: Weighted close > comparison open on the higher timeframe using its bar still forming.
Short: Weighted close < comparison open on the higher timeframe using its bar still forming.