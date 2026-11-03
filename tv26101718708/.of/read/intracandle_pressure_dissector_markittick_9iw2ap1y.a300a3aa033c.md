Calculation: Selected candle = either the chart candle or the last completed higher-timeframe candle; selected ATR is ATR calculated on the same timeframe as the selected candle. All subsequent history references and rolling calculations operate on chart bars, including when selected higher-timeframe values repeat.
Calculation: Safe division D(a,b) = a/b if abs(b) exceeds a small numerical tolerance, otherwise 0. Rolling normalization N(x) = (x - rolling minimum of x)/(rolling maximum of x - rolling minimum of x), or 0.5 if the range is negligible; use the same normalization lookback for volume and acceleration.
Calculation: Let B = selected close - selected open, R = selected high - selected low, U = selected high - max(selected open, selected close), L = min(selected open, selected close) - selected low, V = N(selected volume), and A = selected ATR. Add a small numerical tolerance to each denominator shown below.
Calculation: Six pressure components = 50*D(B,R), 50*D(L-U,R), 50*D(B,R)*V, clamp(50*D(B*previous chart bar's B,A*A),-50,50), 50*(D(selected close-selected low,R)-D(selected high-selected close,R)), and -50*V*(1-min(1,D(abs(B),A))), respectively.
Calculation: FLOW = EMA of the weighted average of the six pressure components, min-max normalized to [-100,100] over a lookback twice the volume normalization lookback; use 0 when its rolling range is negligible. Normalize the weights by their sum.
Calculation: Normalized acceleration = 100*N(FLOW - 2*previous FLOW + FLOW two chart bars ago) - 50.
Calculation: Fake bullish move = selected close > selected close two chart bars ago AND selected close >= selected open AND FLOW > -fake threshold AND FLOW < fake threshold. Fake bearish move = selected close < selected close two chart bars ago AND selected close < selected open AND FLOW > -fake threshold AND FLOW < fake threshold.
Calculation: Ghost volume = 100*V*(1-min(1,D(abs(B),A))).
Long: FLOW > 0
Short: FLOW < 0
Long: Normalized acceleration > positive acceleration threshold
Short: Normalized acceleration < negative acceleration threshold
Short: Fake bullish move
Long: Fake bearish move
Short: Previous chart bar's fake bullish move is true AND bars since the most recent fake-move label confirmation > cooldown; initialize the last confirmation at chart bar index 0.
Long: Previous chart bar's fake bearish move is true AND bars since the most recent fake-move label confirmation > cooldown; initialize the last confirmation at chart bar index 0.
Long: Previous chart bar's FLOW >= strong bullish threshold AND previous chart bar's fake bullish move is false AND previous chart bar's fake bearish move is false AND previous chart bar's ghost volume < absorption threshold
Short: Previous chart bar's FLOW <= strong bearish threshold AND previous chart bar's fake bullish move is false AND previous chart bar's fake bearish move is false AND previous chart bar's ghost volume < absorption threshold
Long: First pressure component > positive dimension threshold
Short: First pressure component < negative dimension threshold
Long: Fourth pressure component > positive dimension threshold
Short: Fourth pressure component < negative dimension threshold