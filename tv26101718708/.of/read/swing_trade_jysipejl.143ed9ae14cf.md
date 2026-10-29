Calculation: Higher-timeframe pivot = (high + low + close) / 3, using the last completed bar
Calculation: Higher-timeframe R1 = 2 × pivot − low, using the last completed bar
Calculation: Higher-timeframe S1 = 2 × pivot − high, using the last completed bar
Calculation: Higher-timeframe R2 = pivot + (high − low), using the last completed bar
Calculation: Higher-timeframe S2 = pivot − (high − low), using the last completed bar
Calculation: Higher-timeframe BC = (high + low) / 2, using the last completed bar
Calculation: Higher-timeframe TC = 2 × pivot − BC, using the last completed bar
Long: (low < higher-timeframe pivot OR low < higher-timeframe S1) AND higher-timeframe pivot > its value on the previous bar OR previous bar close > previous bar higher-timeframe R2 AND (low < higher-timeframe TC OR low < higher-timeframe BC OR low < higher-timeframe S1)
Short: (high > higher-timeframe pivot OR high < higher-timeframe R1) AND higher-timeframe pivot < its value on the previous bar OR previous bar close < previous bar higher-timeframe S2 AND (high > higher-timeframe BC OR high > higher-timeframe TC OR high > higher-timeframe R1)