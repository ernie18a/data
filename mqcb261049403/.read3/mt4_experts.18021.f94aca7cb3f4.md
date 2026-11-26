Long: Heiken Ashi close > Heiken Ashi open AND Heiken Ashi open = Heiken Ashi low on the still-forming chart bar AND Heiken Ashi close > Heiken Ashi open AND Heiken Ashi open != Heiken Ashi low on the previous completed chart bar AND the same comparisons hold on the still-forming and previous completed T1 bars, with T1 values sampled on chart bars
Short: Heiken Ashi close < Heiken Ashi open AND Heiken Ashi open = Heiken Ashi high on the still-forming chart bar AND Heiken Ashi close < Heiken Ashi open AND Heiken Ashi open != Heiken Ashi high on the previous completed chart bar AND the same comparisons hold on the still-forming and previous completed T1 bars, with T1 values sampled on chart bars
Exit: long, stop-loss distance > 0 AND low <= entry price - stop-loss distance
Exit: long, take-profit distance > 0 AND high >= entry price + take-profit distance
Exit: short, stop-loss distance > 0 AND high >= entry price + stop-loss distance
Exit: short, take-profit distance > 0 AND low <= entry price - take-profit distance
Exit: long, close-all enabled AND volume of the still-forming T2 bar <= volume threshold, with T2 values sampled on chart bars
Exit: short, close-all enabled AND volume of the still-forming T2 bar <= volume threshold, with T2 values sampled on chart bars