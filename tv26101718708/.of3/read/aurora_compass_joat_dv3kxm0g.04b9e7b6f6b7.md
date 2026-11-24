Calculation: NEW_T1 = T1 interval of this bar differs from T1 interval of previous bar
Calculation: WINDOW = chart bars from the later of the first bar of the current T1 interval (still forming) and the bar MAX_LOOKBACK bars ago, through this bar
Calculation: BIN_BOTTOM(h) = lowest low of WINDOW + h * (highest high of WINDOW - lowest low of WINDOW) / N_BINS, for h = 0 to N_BINS
Calculation: BIN_TOP(h) = BIN_BOTTOM(h + 1)
Calculation: SW = 1 + SMART_W * (NVI(close, volume) - NVI(close, volume)[1]) / max(abs(NVI(close, volume)[1]), SMART_FLOOR)
Calculation: BIN_VOL(h) = sum of volume of WINDOW bars with low <= BIN_TOP(h) AND high >= BIN_BOTTOM(h)
Calculation: BIN_SIGNED(h) = sum of volume * SW * d over WINDOW bars with low <= BIN_TOP(h) AND high >= BIN_BOTTOM(h), where d = 1 if close > open, else -1
Calculation: UP = sum of BIN_VOL(h) over h with BIN_SIGNED(h) >= 0
Calculation: DN = sum of BIN_VOL(h) over h with BIN_SIGNED(h) < 0
Calculation: IMB = abs(UP - DN) / (UP + DN)
Calculation: POC_BIN = lowest h with BIN_VOL(h) equal to the maximum BIN_VOL over all h
Calculation: POC = (BIN_BOTTOM(POC_BIN) + BIN_TOP(POC_BIN)) / 2
Calculation: VA = [lo, hi] found from lo = hi = POC_BIN by repeatedly, while the sum of BIN_VOL over lo to hi is below VA_FRAC * the sum of BIN_VOL over all h, extending the range to lo - 1 if BIN_VOL(lo - 1) > BIN_VOL(hi + 1) and otherwise to hi + 1, where BIN_VOL of a bin outside 0 to N_BINS - 1 is -1
Calculation: VAH = BIN_TOP(hi of VA)
Calculation: VAL = BIN_BOTTOM(lo of VA)
Calculation: HVN = up to K_HVN indices h with BIN_VOL(h) > 0, in decreasing BIN_VOL order with lowest h first on ties, set when NEW_T1 is true and held until NEW_T1 is next true
Calculation: BIAS = (close - POC) / ATR(ATR_LEN)
Long: bar is closed AND (for some h in HVN: low < BIN_BOTTOM(h) AND close > BIN_TOP(h))
Short: bar is closed AND (for some h in HVN: high > BIN_TOP(h) AND close < BIN_BOTTOM(h))
Long: bar is closed AND POC > POC[1]
Short: bar is closed AND POC < POC[1]
Long: bar is closed AND UP > DN AND IMB >= IMB_T AND IMB[1] < IMB_T
Short: bar is closed AND DN > UP AND IMB >= IMB_T AND IMB[1] < IMB_T
Long: bar is closed AND close crosses above VAH
Short: bar is closed AND close crosses below VAL
Long: BIAS > BIAS_T
Short: BIAS < -BIAS_T
Long: NEW_T1 AND BIAS[1] > BIAS_T
Short: NEW_T1 AND BIAS[1] < -BIAS_T
Long: NEW_T1 AND POC > POC[1]
Short: NEW_T1 AND POC < POC[1]