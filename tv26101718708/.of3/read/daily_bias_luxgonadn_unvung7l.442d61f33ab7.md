Long: previous completed T1 close > previous completed T1 open
Short: previous completed T1 close < previous completed T1 open
Long: latest confirmed T1 Pivot High(high, pivot lookback, pivot lookback) > preceding confirmed T1 Pivot High(high, pivot lookback, pivot lookback) AND latest confirmed T1 Pivot Low(low, pivot lookback, pivot lookback) > preceding confirmed T1 Pivot Low(low, pivot lookback, pivot lookback)
Short: latest confirmed T1 Pivot High(high, pivot lookback, pivot lookback) < preceding confirmed T1 Pivot High(high, pivot lookback, pivot lookback) AND latest confirmed T1 Pivot Low(low, pivot lookback, pivot lookback) < preceding confirmed T1 Pivot Low(low, pivot lookback, pivot lookback)
Long: chart close > T1 open of the bar still forming
Short: chart close < T1 open of the bar still forming
Calculation: Combined vote score = number of true bullish conditions among (previous completed T1 close > previous completed T1 open), (latest confirmed T1 Pivot High(high, pivot lookback, pivot lookback) > preceding confirmed T1 Pivot High(high, pivot lookback, pivot lookback) AND latest confirmed T1 Pivot Low(low, pivot lookback, pivot lookback) > preceding confirmed T1 Pivot Low(low, pivot lookback, pivot lookback)), and (chart close > T1 open of the bar still forming) MINUS number of true bearish conditions among the corresponding conditions using < instead of >
Long: Combined vote score >= vote threshold
Short: Combined vote score <= -vote threshold