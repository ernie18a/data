Calculation: RSI_x = RSI of close (same length for both) on timeframe x, x in {TF1, TF2}; TF1 is a lower timeframe than TF2; each is evaluated at the close of every chart bar using that timeframe's still-forming bar.
Calculation: Ext_x = 2 * abs(PercentRank_x - 50), where PercentRank_x = percent of the previous N values of RSI_x (counted in timeframe-x bars) that are <= the current RSI_x.
Long: (RSI_TF1 <= RSI_low AND Ext_TF1 >= K1) AND (RSI_TF2 <= RSI_low AND Ext_TF2 >= K2), where K1 > K2 (TF2 threshold lower than TF1 threshold) and RSI_low is the same for both
Long: (RSI_TF1 <= RSI_low AND Ext_TF1 >= K1) OR (RSI_TF2 <= RSI_low AND Ext_TF2 >= K2) (weaker partial signal, includes the line above)
Short: (RSI_TF1 >= RSI_high AND Ext_TF1 >= K1) AND (RSI_TF2 >= RSI_high AND Ext_TF2 >= K2), where RSI_high > RSI_low and is the same for both
Short: (RSI_TF1 >= RSI_high AND Ext_TF1 >= K1) OR (RSI_TF2 >= RSI_high AND Ext_TF2 >= K2) (weaker partial signal, includes the line above)