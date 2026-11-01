Calculation: Noise-suppressed stochastic M = for each of the slowing lookback bars, find the highest high and lowest low over a separate lookback ending at that bar, or optionally use the highest and lowest closes. Sum those highs as H, those lows as L, and the slowing bars' closes as C. If H−L is below the sensitivity expressed in price units, add half the sensitivity to H and subtract half from L. M = 100 × (C−L)/(H−L); if H−L is zero, M = 100.
Calculation: Signal S = either a simple or exponential moving average of M, using a separate signal lookback. Initialize S to 50; for the simple version, use the recursive update S = previous S + (current M − M one signal lookback ago)/signal lookback, with earlier M initialized to 50.
Calculation: Oscillator state O = 1 when M > 50 AND M > previous M; 2 when M > 50 AND M < previous M; 3 when M < 50 AND M < previous M; 4 when M < 50 AND M > previous M; otherwise 0.
Calculation: Signal state Q = 1 when M > S; 2 when M < S; otherwise 0.
Calculation: Decision-bar values = oscillator and signal values on the chart timeframe for indicator markings; for trading modes, use an independently selected timeframe that may be higher or lower than the chart timeframe, using either its still-forming bar or a selected completed bar and the preceding bars on that timeframe.
Long: M > 50 AND M > previous M OR M < 50 AND M > previous M OR M > S.
Short: M > 50 AND M < previous M OR M < 50 AND M < previous M OR M < S.
Long: M > 50.
Short: M < 50.
Long: S > previous S AND previous S < S two bars ago.
Short: S < previous S AND previous S > S two bars ago.
Long: O = 1 AND previous O > 1 OR O = 2 AND previous O > 2 OR O = 3 AND previous O = 4.
Short: O = 4 AND previous O > 0 AND previous O < 4 OR O = 3 AND previous O > 0 AND previous O < 3 OR O = 2 AND previous O <= 1.
Long: Q = 1 AND previous Q != 0.
Short: Q = 2 AND previous Q != 0.
Exit: short, M > 50 OR S > previous S OR Q = 1 OR O = 1 AND previous O > 1 OR O = 2 AND previous O > 2 OR O = 3 AND previous O = 4.
Exit: long, M < 50 OR S < previous S OR Q = 2 OR Q < 50 OR O = 4 AND previous O > 0 AND previous O < 4 OR O = 3 AND previous O > 0 AND previous O < 3 OR O = 2 AND previous O <= 1.
Exit: long, low <= entry price − enabled stop-loss distance OR high >= entry price + enabled take-profit distance.
Exit: short, high >= entry price + enabled stop-loss distance OR low <= entry price − enabled take-profit distance.