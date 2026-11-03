Calculation: VWAP = volume-weighted average of the selected price source since the selected anchor/reset
Calculation: Upper/lower 1-standard-deviation bands = VWAP ± 1 standard deviation
Calculation: Upper inner/outer bands = upper 1-standard-deviation band ± 0.25/0.5 standard deviations
Calculation: Lower inner/outer bands = lower 1-standard-deviation band ± 0.25/0.5 standard deviations
Calculation: Dollar volume = close × volume
Calculation: Position size = floor(risk budget / distance from VWAP to upper 1-standard-deviation band)
Long: current conditions true and previous bar conditions false, where current conditions are VWAP available AND previous completed chart bar close is between the previous bar's upper inner bands inclusive AND dollar volume meets the minimum threshold scaled to chart bar duration AND developing POC is between the previous bar's upper inner bands inclusive AND developing VAH is between the previous bar's upper 1-standard-deviation band and upper outer band inclusive AND position size > 0
Short: current conditions true and previous bar conditions false, where current conditions are VWAP available AND previous completed chart bar close is between the previous bar's lower inner bands inclusive AND dollar volume meets the minimum threshold scaled to chart bar duration AND developing POC is between the previous bar's lower inner bands inclusive AND developing VAL is between the previous bar's lower outer band and lower 1-standard-deviation band inclusive AND position size > 0
Exit: Long, low <= VWAP at entry minus one minimum price increment
Exit: Short, high >= VWAP at entry plus one minimum price increment