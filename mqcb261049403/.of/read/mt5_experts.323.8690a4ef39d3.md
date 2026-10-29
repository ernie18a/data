Calculation: Average candle body = mean of |open − close| over a configurable lookback of chart bars ending at the last completed bar.
Long: Open[3] − Close[3] > Average candle body AND |Close[2] − Open[2]| < 0.5 × Average candle body AND Close[2] < Close[3] AND Open[2] < Open[3] AND Close[1] > (Open[3] + Close[3]) / 2 AND MFI[1] < 40
Short: Close[3] − Open[3] > Average candle body AND |Close[2] − Open[2]| < 0.5 × Average candle body AND Close[2] > Close[3] AND Open[2] > Open[3] AND Close[1] < (Open[3] + Close[3]) / 2 AND MFI[1] > 60
Exit: Short, (MFI[1] > 30 AND MFI[2] < 30) OR (MFI[1] > 70 AND MFI[2] < 70)
Exit: Long, (MFI[1] > 70 AND MFI[2] < 70) OR (MFI[1] < 30 AND MFI[2] > 30)