Calculation: SMA = simple moving average of the selected source from the last completed higher-timeframe bar, calculated over chart-timeframe bars
Calculation: Direction state = +1 when trigger price > SMA, −1 when trigger price < SMA, otherwise retain the previous value (initially 0)
Long: Direction state changes to +1 when reverse mode is off OR changes to −1 when reverse mode is on, AND bar time is within the configured session
Short: Direction state changes to −1 when reverse mode is off OR changes to +1 when reverse mode is on, AND bar time is within the configured session
Exit: long or short, bar time is outside the configured session
Exit: long, take-profit mode is enabled AND (bar high > average entry price + take-profit amount OR bar low < average entry price − stop-loss amount)
Exit: short, take-profit mode is enabled AND (bar low < average entry price − take-profit amount OR bar high > average entry price + stop-loss amount)