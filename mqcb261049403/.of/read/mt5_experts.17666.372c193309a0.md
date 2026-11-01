Calculation: Center-of-gravity oscillator C = (N + 1) / 2 - sum((i + 1) * midpoint[i], i = 0 to N - 1) / sum(midpoint[i], i = 0 to N - 1), where midpoint[i] = (high[i] + low[i]) / 2 and i = 0 is the bar being evaluated; C = 0 if the denominator is zero. Calculate C independently on the chart timeframe and on a higher timeframe; use the last completed higher-timeframe bar. The two lookbacks are independent.
Long: position is flat AND higher-timeframe C > its previous-bar C AND chart-timeframe C > its previous-bar C AND previous-bar C <= its bar-before-previous C
Short: position is flat AND higher-timeframe C < its previous-bar C AND chart-timeframe C < its previous-bar C AND previous-bar C >= its bar-before-previous C
Exit: long, higher-timeframe C < its previous-bar C OR chart-timeframe C < its previous-bar C
Exit: short, higher-timeframe C > its previous-bar C OR chart-timeframe C > its previous-bar C
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance