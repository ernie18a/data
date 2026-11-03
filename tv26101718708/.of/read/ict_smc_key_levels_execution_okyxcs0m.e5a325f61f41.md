Calculation: Confirmed pivot high or low = a bar whose high is at least every high in the preceding lookback and strictly above every high in the following lookback, or whose low is at most every low in the preceding lookback and strictly below every low in the following lookback; confirm after the following lookback bars have completed. Use separate lookbacks for order blocks, liquidity sweeps, and structure shifts, with the order-block lookback longer than the sweep lookback and the sweep lookback longer than the structure-shift lookback.
Calculation: Tracked sweep high or low = the latest confirmed sweep pivot high or low, replaced by each newly confirmed pivot of the same kind and cleared after its corresponding sweep decision.
Calculation: Tracked structure-shift high or low = the latest confirmed structure-shift pivot high or low, replaced by each newly confirmed pivot of the same kind and cleared after its corresponding structure-shift decision.
Long: low > high two bars ago
Short: high < low two bars ago
Long: an order-block pivot low is confirmed AND close >= the lower of that pivot bar's open and close
Short: an order-block pivot high is confirmed AND close <= the higher of that pivot bar's open and close
Long: low < tracked sweep low AND close > tracked sweep low
Short: high > tracked sweep high AND close < tracked sweep high
Long: close > tracked structure-shift high
Short: close < tracked structure-shift low