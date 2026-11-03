Calculation: Smoothed Williams %R at lookback L = the selected smoothing of Williams %R, where Williams %R = −100 × (highest high over its lookback − close) / (highest high − lowest low); use an ascending set of smoothing lookbacks.
Calculation: Bull score = the selected smoothing of the count of lookbacks whose current smoothed Williams %R is greater than its value on the immediately preceding bar.
Calculation: Bear score = the selected smoothing of the count of lookbacks whose current smoothed Williams %R is less than or equal to its value on the immediately preceding bar.
Calculation: For the higher-timeframe variant, use the higher-timeframe bar containing the chart bar, including while that bar is forming; otherwise use chart-timeframe bars.
Long: Bull score > Bear score
Short: Bear score > Bull score