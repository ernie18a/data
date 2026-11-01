Calculation: Candle notation = O[i], H[i], L[i], C[i] are open, high, low, close of the i-th most recently completed candle on the candle timeframe, which may be the chart timeframe or a higher or lower timeframe; i=1 is the last completed candle.
Calculation: Body average A[i] = mean of abs(O[j] - C[j]) over the body-lookback candles starting at i and proceeding backward on the candle timeframe.
Calculation: Range midpoint M[i] = (H[i] + L[i]) / 2.
Calculation: Body midpoint B[i] = (O[i] + C[i]) / 2.
Calculation: Trend average S[i] = simple moving average of close ending at candle i on the candle timeframe; its lookback is independent of the body-average lookback.
Calculation: Initial-entry filter = last completed volume-bar volume > initial-volume threshold AND datetime weekday is enabled AND (month-boundary restriction is disabled OR day of month >= 1 + beginning exclusion AND day of month <= assumed month length - ending exclusion) AND (opening-hours restriction is disabled OR time >= opening time AND time < break start OR time >= break end AND time < closing time); the assumed February length excludes leap day. The volume timeframe may be the chart timeframe or a higher or lower timeframe.
Long: Initial-entry filter AND C[3] - O[3] > A[1] AND C[2] - O[2] > A[1] AND C[1] - O[1] > A[1] AND M[2] > M[3] AND M[1] > M[2].
Long: Initial-entry filter AND C[1] - O[1] > A[1] AND O[2] - C[2] > A[1] AND C[2] > C[1] AND C[1] < O[2] AND B[2] < S[2] AND O[1] < L[2].
Long: Initial-entry filter AND O[3] - C[3] > A[1] AND A[2] < A[1] * doji factor AND C[2] < C[3] AND O[2] < O[3] AND O[1] > C[2] AND C[1] > C[2].
Long: Initial-entry filter AND O[2] > C[2] AND C[1] - O[1] > A[1] AND C[1] > O[2] AND B[2] < S[2] AND O[1] < C[2].
Long: Initial-entry filter AND O[3] - C[3] > A[1] AND abs(C[2] - O[2]) < A[1] * star-body factor AND C[2] < C[3] AND O[2] < O[3] AND C[1] > B[3].
Long: Initial-entry filter AND C[1] > O[1] AND O[2] - C[2] > A[1] AND C[1] < O[2] AND O[1] > C[2] AND M[2] < S[2].
Long: Initial-entry filter AND O[2] - C[2] > A[1] AND C[1] - O[1] > A[1] AND abs(C[1] - C[2]) < meeting-line factor * A[1].
Short: Initial-entry filter AND O[3] - C[3] > A[1] AND O[2] - C[2] > A[1] AND O[1] - C[1] > A[1] AND M[2] < M[3] AND M[1] < M[2].
Short: Initial-entry filter AND C[2] - O[2] > A[1] AND C[1] < C[2] AND C[1] > O[2] AND B[2] > S[1] AND O[1] > H[2].
Short: Initial-entry filter AND C[3] - O[3] > A[1] AND A[2] < A[1] * doji factor AND C[2] > C[3] AND O[2] > O[3] AND O[1] < C[2] AND C[1] < C[2].
Short: Initial-entry filter AND O[2] < C[2] AND O[1] - C[1] > A[1] AND C[1] < O[2] AND B[2] > S[2] AND O[1] > C[2].
Short: Initial-entry filter AND C[3] - O[3] > A[1] AND abs(C[2] - O[2]) < A[1] * star-body factor AND C[2] > C[3] AND O[2] > O[3] AND C[1] < B[3].
Short: Initial-entry filter AND C[1] < O[1] AND C[2] - O[2] > A[1] AND C[1] > O[2] AND O[1] < C[2] AND M[2] > S[2].
Short: Initial-entry filter AND C[2] - O[2] > A[1] AND O[1] - C[1] > A[1] AND abs(C[1] - C[2]) < meeting-line factor * A[1].
Exit: long, stop loss enabled AND low <= entry price - stop-loss distance OR take profit enabled AND high >= entry price + take-profit distance.
Exit: short, stop loss enabled AND high >= entry price + stop-loss distance OR take profit enabled AND low <= entry price - take-profit distance.
Exit: long OR short, opening-hours restriction enabled AND end-of-session exit enabled AND time >= closing time OR opening-hours restriction enabled AND break exit enabled AND time >= break start AND time < break end.