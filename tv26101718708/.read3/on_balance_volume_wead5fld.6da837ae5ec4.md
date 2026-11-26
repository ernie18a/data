Calculation: scaled OBV = 0 if highest(OBV, normalization lookback) = lowest(OBV, normalization lookback); otherwise ((OBV - lowest(OBV, normalization lookback)) / (highest(OBV, normalization lookback) - lowest(OBV, normalization lookback))) * highest(volume, normalization lookback)
Long: scaled OBV crosses above selected MA(scaled OBV, MA lookback)
Short: scaled OBV crosses below selected MA(scaled OBV, MA lookback)
Long: on confirmation of a current OBV pivot low, current OBV pivot low > previous confirmed OBV pivot low AND current price pivot low < previous confirmed price pivot low AND distance between confirmed pivots ≤ divergence window
Short: on confirmation of a current OBV pivot high, current OBV pivot high < previous confirmed OBV pivot high AND current price pivot high > previous confirmed price pivot high AND distance between confirmed pivots ≤ divergence window
Long: on confirmation of a current OBV pivot high, current OBV pivot high > previous confirmed OBV pivot high
Long: on confirmation of a current OBV pivot low, current OBV pivot low > previous confirmed OBV pivot low
Short: on confirmation of a current OBV pivot high, current OBV pivot high < previous confirmed OBV pivot high
Short: on confirmation of a current OBV pivot low, current OBV pivot low < previous confirmed OBV pivot low
Long: EMA(scaled OBV, shorter fast lookback) > EMA(scaled OBV, longer slow lookback)
Short: EMA(scaled OBV, shorter fast lookback) ≤ EMA(scaled OBV, longer slow lookback)