Calculation: Zero Gamma Line = session VWAP, falling back to a moving average of close when session VWAP is unavailable
Calculation: Call Wall = Zero Gamma Line + ATR-scaled offset
Calculation: Put Wall = Zero Gamma Line − ATR-scaled offset
Calculation: Breakout threshold = highest high over a shorter rolling lookback of completed bars
Long: During midday, close crosses above the breakout threshold AND volume exceeds its moving average
Exit: long, high reaches or exceeds the Call Wall
Exit: short, low reaches or falls below the Put Wall