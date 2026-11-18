Calculation: FVE = FVE[1] + (IF close - HL2 + HLC3 - HLC3[1] > Factor * close / 100 THEN volume ELSE IF close - HL2 + HLC3 - HLC3[1] < -Factor * close / 100 THEN -volume ELSE 0) / SMA(volume, Period) * 100 / Period, with FVE[1] initialized to 0
Long: FVE > FVE[1] AND FVE > FVE[2]
Short: FVE < FVE[1] AND FVE < FVE[2]