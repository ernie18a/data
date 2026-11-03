Calculation: Hybrid = RSI of the selected price source weighted by a configurable fraction plus the SMA-smoothed stochastic component weighted by the remaining fraction. The stochastic component is 100 × (source − lowest low) / (highest high − lowest low) over its lookback, or the oscillator midpoint when highest high equals lowest low. Calculate one Hybrid on chart bars and two independently parameterized Hybrids on higher-timeframe bars, one at a longer timeframe than the other. For each higher timeframe, use the last completed bar, carry its value forward between completions, then smooth the resulting chart-bar series with a configurable EMA, SMA, WMA, RMA, or HMA.
Calculation: Signal = EMA, SMA, WMA, or RMA of the corresponding Hybrid, optionally followed by an EMA with an independently configurable smoothing length. Each Hybrid has independent signal parameters.
Long: Any Hybrid > its Signal AND the same Hybrid on the previous chart bar <= its Signal on the previous chart bar.
Short: Any Hybrid < its Signal AND the same Hybrid on the previous chart bar >= its Signal on the previous chart bar.
Long: All three Hybrids > their respective Signals.
Short: All three Hybrids < their respective Signals.
Long: Any Hybrid > its Signal AND that Hybrid > a configurable midpoint level.
Short: Any Hybrid < its Signal AND that Hybrid < a configurable midpoint level.