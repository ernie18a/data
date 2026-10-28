Calculation: Event-reset VWAP basis = cumulative (selected price source × volume) divided by cumulative volume since the most recent reset event
Calculation: Upper VWAP band = event-reset VWAP basis + multiplier × volume-weighted standard deviation of the selected price source since the most recent reset event
Calculation: Lower VWAP band = event-reset VWAP basis − multiplier × volume-weighted standard deviation of the selected price source since the most recent reset event
Long: EMA of close crosses above event-reset VWAP basis
Short: EMA of close crosses below event-reset VWAP basis
Exit: long, high ≥ upper VWAP band AND low ≤ upper VWAP band OR highest high since entry has gained at least the activation profit percentage AND close ≤ highest high since entry × (1 − trailing distance percentage)
Exit: short, high ≥ lower VWAP band AND low ≤ lower VWAP band OR lowest low since entry has gained at least the activation profit percentage AND close ≥ lowest low since entry × (1 + trailing distance percentage)