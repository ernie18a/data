Calculation: Average candle body = mean of absolute close minus open over a lookback ending at the latest completed bar
Long: (close[3] - open[3] > Average candle body) AND (close[2] - open[2] > Average candle body) AND (close[1] - open[1] > Average candle body) AND (midpoint[2] > midpoint[3]) AND (midpoint[1] > midpoint[2]) AND (MFI[1] < 40)
Short: (open[3] - close[3] > Average candle body) AND (open[2] - close[2] > Average candle body) AND (open[1] - close[1] > Average candle body) AND (midpoint[2] < midpoint[3]) AND (midpoint[1] < midpoint[2]) AND (MFI[1] > 60)
Exit: short, (MFI[1] > 30 AND MFI[2] < 30) OR (MFI[1] > 70 AND MFI[2] < 70)
Exit: long, (MFI[1] > 70 AND MFI[2] < 70) OR (MFI[1] < 30 AND MFI[2] > 30)