Calculation: Elliot oscillator = fast moving average of the configured price minus the slower moving average of the configured price; both use the configured average type
Calculation: Upper outer level = EMA of the Elliot oscillator on bars where it is above zero, carried forward unchanged otherwise; its period is the slow period plus half the fast period rounded up
Calculation: Lower outer level = EMA of the Elliot oscillator on bars where it is below zero, carried forward unchanged otherwise; its period is the slow period plus half the fast period rounded up
Calculation: Middle level = average of the upper and lower outer levels
Long: Elliot oscillator > upper outer level (outer-level mode) OR Elliot oscillator > middle level (middle-level mode) OR Elliot oscillator > its prior bar value (slope mode)
Short: Elliot oscillator < lower outer level (outer-level mode) OR Elliot oscillator < middle level (middle-level mode) OR Elliot oscillator < its prior bar value (slope mode)