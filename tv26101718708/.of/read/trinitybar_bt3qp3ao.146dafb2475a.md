Calculation: Daily-reset VWAP = cumulative ((high + low + close) / 3 × volume) since the start of the day, divided by cumulative volume since the start of the day
Calculation: Bar lower third = low + (high − low) / 3; bar upper third = high − (high − low) / 3
Calculation: Long target = signal-bar high + multiplier × (signal-bar high − prior signal-bar low); long stop = signal-bar low
Calculation: Short target = signal-bar low − multiplier × (prior signal-bar high − signal-bar low); short stop = signal-bar high
Long: (signal-bar open ≤ signal-bar lower third AND signal-bar close ≥ signal-bar upper third OR signal-bar open ≥ signal-bar upper third AND signal-bar close ≥ signal-bar upper third) AND prior signal-bar low < signal-bar low AND prior signal-bar low < current-bar VWAP AND signal-bar close > current-bar VWAP
Short: (signal-bar open ≤ signal-bar lower third AND signal-bar close ≤ signal-bar lower third OR signal-bar open ≥ signal-bar upper third AND signal-bar close ≤ signal-bar lower third) AND prior signal-bar high > signal-bar high AND prior signal-bar high > current-bar VWAP AND signal-bar close < current-bar VWAP
Exit: Long, valid short signal OR low ≤ long stop OR high ≥ long target
Exit: Short, valid long signal OR high ≥ short stop OR low ≤ short target