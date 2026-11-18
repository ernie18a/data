Calculation: OBV = running sum from the first bar of signed volume, where signed volume is volume if close > previous close, -volume if close < previous close, and 0 otherwise
Calculation: OBV_EMA = exponential moving average of OBV with length Length
Long: OBV > OBV_EMA AND previous OBV <= previous OBV_EMA
Short: OBV < OBV_EMA AND previous OBV >= previous OBV_EMA