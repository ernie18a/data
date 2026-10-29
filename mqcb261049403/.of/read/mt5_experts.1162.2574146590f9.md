Calculation: Up MA points = 1 when the current selected-bar value of a simple moving average is greater than its prior-bar value, otherwise 0; use five moving averages with progressively longer lookbacks.
Calculation: Down MA points = 1 when the current selected-bar value of a simple moving average is less than its prior-bar value, otherwise 0; use the same five lookbacks.
Calculation: Oscillator up points = 3 if ((the current Accelerator Oscillator value is below zero and greater than each of the prior three values in sequence) OR (the current value is above the prior value, the prior value is above the second-prior value, and the current value is above zero)); otherwise 0.
Calculation: Oscillator down points = 3 if ((the current Accelerator Oscillator value is above zero and less than each of the prior three values in sequence) OR (the current value is below the prior value, the prior value is below the second-prior value, and the current value is below zero)); otherwise 0.
Calculation: Bull score per timeframe = 12.5 × (sum of the five up MA points + oscillator up points, if an oscillator is used on that timeframe).
Calculation: Bear score per timeframe = 12.5 × (sum of the five down MA points + oscillator down points, if an oscillator is used on that timeframe).
Calculation: Signal = start at 0; set to 1 if bull scores on all three configured timeframes are > 50; then set to -1 if bear scores on all three are > 50; then set to 2 if bull scores on all three are ≥ 75; then set to -2 if bear scores on all three are ≥ 75, applying these assignments in order. Calculate five moving averages and the oscillator on the chart timeframe and two higher timeframes; use the configured indicator bar (forming if shift is 0, otherwise last completed) and prior bars for comparisons.
Long: Signal > the configured open threshold
Short: Signal < -the configured open threshold
Exit: Long, Signal < -the configured close threshold
Exit: Short, Signal > the configured close threshold