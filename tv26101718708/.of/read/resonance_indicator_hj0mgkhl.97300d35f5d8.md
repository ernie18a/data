Calculation: Momentum oscillator = the average of Hull-smoothed RSI of close and EMA-smoothed stochastic of close, high, and low. The RSI and its Hull smoothing use the same lookback; the stochastic lookback is longer than its EMA smoothing lookback, which is longer than the RSI lookback. Replace unavailable RSI smoothing and raw stochastic values with the oscillator midpoint, and replace unavailable stochastic EMA with the midpoint.
Calculation: Trend score = the sum of directional states from an ordered set of increasingly long timeframes, weighted inversely by timeframe duration. For each timeframe, use the Hull moving average of close from the last completed bar; when the timeframe is lower than the chart timeframe, use the last available lower-timeframe sample in the chart bar. Compare its latest change with the previous change between distinct values: an upward or downward turn or an intact move has directional state +1 or -1; a move in the same direction with smaller magnitude has state +0.5 or -0.5; an unchanged value has state 0. All timeframe Hull averages use the same lookback.
Calculation: Extreme pivot high or low = a confirmed pivot of the momentum oscillator above its upper extreme threshold or below its lower extreme threshold, respectively. Use equal left and right pivot lookbacks; the signal occurs on the confirmation bar.
Long: Chart-timeframe momentum oscillator < its midpoint.
Short: Chart-timeframe momentum oscillator > its midpoint.
Long: Trend score > 0.
Short: Trend score < 0.
Long: Last completed Hull moving average of close on a selected timeframe > its previous distinct value.
Short: Last completed Hull moving average of close on a selected timeframe < its previous distinct value.
Long: Close > last completed Hull moving average of close on a selected timeframe.
Short: Close < last completed Hull moving average of close on a selected timeframe.
Long: Extreme pivot low on an eligible selected timeframe is newly observed.
Short: Extreme pivot high on an eligible selected timeframe is newly observed.
Long: On a minute-based chart, an extreme pivot low on the selected lower or equal timeframe is newly observed AND trend score >= the negative trend threshold AND the last accepted extreme pivot label was not a low.
Short: On a minute-based chart, an extreme pivot high on the selected lower or equal timeframe is newly observed AND trend score <= the positive trend threshold AND the last accepted extreme pivot label was not a high.
Long: A pending chart-timeframe extreme pivot low exists AND trend score >= the negative trend threshold at chart-bar close.
Short: A pending chart-timeframe extreme pivot high exists AND trend score <= the positive trend threshold at chart-bar close.
Calculation: Pending pivot = the latest chart-timeframe extreme pivot high or low since the previous pending pivot was consumed; a new pivot replaces any pending pivot, and a qualifying trend-score comparison consumes it. For selected-timeframe pivot observations, use the last available lower-timeframe sample when the selected timeframe is lower than the chart timeframe, the chart bar when equal, and the last completed higher-timeframe bar historically or the still-forming bar in real time when higher. Selected-timeframe eligibility is controlled by a maximum chart timeframe for each selected timeframe.