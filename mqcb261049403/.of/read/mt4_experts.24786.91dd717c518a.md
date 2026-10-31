Calculation: Range position = (close − low) / (high − low) for the still-forming higher-timeframe bar; use zero when high equals low.
Calculation: Price change = percentage change from the last completed higher-timeframe bar's close to the still-forming bar's close, rounded to two decimal places.
Long: Range position >= high threshold OR price change > 0
Short: Range position <= low threshold OR price change < 0
Exit: long, low <= entry price − stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price − target distance