Calculation: Model outputs = the trained neural model's direction score and projected price distance from the latest three completed bars on the chart timeframe, using RSI and MACD main, signal, and main-minus-signal values computed from typical prices
Calculation: Long take-profit level = signal-bar bid + the smaller of projected distance × profit multiplier and maximum take-profit points × point size
Calculation: Long stop-loss level = signal-bar bid − stop-loss points × point size
Calculation: Short take-profit level = signal-bar bid + the larger of projected distance × profit multiplier and negative maximum take-profit points × point size
Calculation: Short stop-loss level = signal-bar bid + stop-loss points × point size
Long: direction score ≥ trade threshold AND projected distance ≥ minimum target points × point size AND no existing long position
Short: direction score ≤ −trade threshold AND projected distance ≤ −minimum target points × point size AND no existing short position
Exit: long, low ≤ long stop-loss level OR high ≥ long take-profit level
Exit: short, high ≥ short stop-loss level OR low ≤ short take-profit level