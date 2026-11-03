Calculation: 61.8% retracement = latest completed higher-timeframe bar low + 0.618 × (bar high − bar low)
Calculation: 38.2% retracement = latest completed higher-timeframe bar low + 0.382 × (bar high − bar low)
Calculation: Hurst exponent = log((highest over lookback of the rolling sum of close deviations from their lookback SMA − lowest over lookback of that rolling sum) / close standard deviation over lookback) / log(lookback); calculate on the latest completed higher-timeframe bars
Calculation: Risk distance = entry price × risk percentage; profit distance = risk distance × reward-to-risk ratio
Long: close > 61.8% retracement AND previous close ≤ previous 61.8% retracement AND higher-timeframe Hurst exponent > 0.5 AND trades today < daily trade limit AND total trades < overall trade limit
Short: close < 38.2% retracement AND previous close ≥ previous 38.2% retracement AND higher-timeframe Hurst exponent < 0.5 AND trades today < daily trade limit AND total trades < overall trade limit
Exit: long, low ≤ entry price − risk distance OR high ≥ entry price + profit distance
Exit: short, high ≥ entry price + risk distance OR low ≤ entry price − profit distance