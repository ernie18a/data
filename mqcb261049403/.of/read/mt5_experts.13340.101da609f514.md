Calculation: Oscillator = For five momentum lookbacks ordered from shortest to longest, calculate each momentum as 100 × selected OHLC-derived price / that price the lookback bars ago. Form their weighted sum, using the same weight for the second- and third-shortest lookbacks. Smooth the sum recursively as S[t] = sum[t]/smoothing length 1 + S[t-1] × (1 - 1/smoothing length 1); then calculate O[t] = (sum[t] - S[t])/smoothing length 2 + O[t-1] × (1 - 1/smoothing length 2). Initialize S to the first sum divided by smoothing length 1 and O to (first sum - S) divided by smoothing length 2.
Calculation: Signal oscillator = Oscillator on a configurable indicator timeframe that may be higher or lower than the chart timeframe; use the last completed indicator bar by default, or the forming bar if the signal-bar parameter selects it. Earlier values refer to consecutive preceding indicator bars. Evaluate completed-bar signals when a new indicator bar begins.
Long: Chart-timeframe oscillator > 0 AND chart-timeframe oscillator > its previous value
Long: Chart-timeframe oscillator < 0 AND chart-timeframe oscillator > its previous value
Long: Signal oscillator > its previous value AND its value two indicator bars ago > its previous value
Short: Chart-timeframe oscillator > 0 AND chart-timeframe oscillator < its previous value
Short: Chart-timeframe oscillator < 0 AND chart-timeframe oscillator < its previous value
Short: Signal oscillator < its previous value AND its value two indicator bars ago < its previous value
Exit: long, signal oscillator < its previous value
Exit: short, signal oscillator > its previous value
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance