Calculation: Oscillator = 100 × second-stage moving average of the first-stage moving average of the selected price's one-bar change / second-stage moving average of the first-stage moving average of the absolute one-bar change; each stage has its own selectable smoothing method and parameters.
Calculation: Trigger = oscillator shifted back by a configurable number of bars.
Long: oscillator > trigger.
Short: oscillator < trigger.
Long: higher-timeframe oscillator > higher-timeframe trigger, sampled from the still-forming higher-timeframe bar at its first chart bar and held until the next higher-timeframe bar.
Short: higher-timeframe oscillator < higher-timeframe trigger, sampled from the still-forming higher-timeframe bar at its first chart bar and held until the next higher-timeframe bar.