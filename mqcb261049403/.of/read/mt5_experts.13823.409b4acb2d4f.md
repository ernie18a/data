Calculation: Trend = on a higher timeframe, initialize the first four values to their corresponding closes; thereafter, Trend[t] = (a - a²/4) × close[t] + (a²/2) × close[t-1] - (a - 3a²/4) × close[t-2] + 2(1-a) × Trend[t-1] - (1-a)² × Trend[t-2], where a is a configurable coefficient. Use the last completed higher-timeframe bar as t, or the still-forming bar if configured; t-1 is the preceding higher-timeframe bar.
Calculation: Trigger[t] = 2 × Trend[t] - Trend[t-2].
Long: Trigger[t] > Trend[t] AND Trigger[t-1] < Trend[t-1].
Short: Trigger[t] < Trend[t] AND Trigger[t-1] > Trend[t-1].
Exit: long, Trigger[t] < Trend[t] OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, Trigger[t] > Trend[t] OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.