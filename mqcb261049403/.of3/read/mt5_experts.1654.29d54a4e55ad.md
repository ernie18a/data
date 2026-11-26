Calculation: weighted price = (5 × close + 2 × open + high + low) / 9 on T1 bars
Calculation: oscillator = EMA(weighted price, fast lookback) − EMA(weighted price, slow lookback) on T1 bars, with fast lookback shorter than slow lookback
Calculation: filter = EMA(weighted price, separate filter lookback) on T1 bars, with filter lookback shorter than fast lookback
Long: on the last completed T1 bar, the latest prior signal is not long AND oscillator[0] > oscillator[1] AND filter[0] ≥ filter[1] AND oscillator[1] ≤ oscillator[2] AND the current forming T2 chart bar has close > open
Short: on the last completed T1 bar, the latest prior signal is not short AND oscillator[0] < oscillator[1] AND filter[0] ≤ filter[1] AND oscillator[1] ≥ oscillator[2] AND the current forming T2 chart bar has close < open
Exit: long, on the last completed T1 bar, the latest prior signal is not short AND oscillator[0] < oscillator[1] AND filter[0] ≤ filter[1] AND oscillator[1] ≥ oscillator[2]
Exit: short, on the last completed T1 bar, the latest prior signal is not long AND oscillator[0] > oscillator[1] AND filter[0] ≥ filter[1] AND oscillator[1] ≤ oscillator[2]