Calculation: MF = 100 × positive volume-weighted HLC3 change sum / (positive volume-weighted HLC3 change sum + negative volume-weighted HLC3 change sum), each summed over the common lookback
Calculation: K = SMA of stochastic RSI, where RSI uses HLC3 and the common lookback; K uses its smoothing lookback
Calculation: D = SMA of K using its smoothing lookback
Long: RSI of HLC3 > 50 AND MF > 50 AND CCI of HLC3 > 50 AND (K > 50 OR D > 50)
Exit: long, RSI of HLC3 < 49 AND MF < 49 AND CCI of HLC3 < 0 AND (K < 50 OR D < 50)