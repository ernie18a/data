Calculation: Regression momentum = For each of the most recent N bars, indexed x = 0 for newest through N-1 for oldest, calculate d[x] = close[x] - (((highest high and lowest low over N bars ending at x are averaged) + the N-period moving average of the selected price at x) / 2). Let S = sum(x), Q = sum(x*x), Y = sum(d[x]), and P = sum(x*d[x]). Set slope = (N*P - S*Y)/(S*S - N*Q), or zero if the denominator is zero. Regression momentum = (Y - slope*S)/N + slope*(N-1).
Long: Regression momentum on the chart timeframe >= 0
Short: Regression momentum on the chart timeframe < 0
Long: Regression momentum on the last completed higher-timeframe bar > 0 AND regression momentum on the preceding higher-timeframe bar < 0
Short: Regression momentum on the last completed higher-timeframe bar < 0 AND regression momentum on the preceding higher-timeframe bar > 0
Exit: long, regression momentum on the last completed higher-timeframe bar < 0
Exit: short, regression momentum on the last completed higher-timeframe bar > 0
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance