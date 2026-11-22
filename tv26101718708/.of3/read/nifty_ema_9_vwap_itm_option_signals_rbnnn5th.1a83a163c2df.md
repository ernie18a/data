Long: EMA(close, lookback) crosses above VWAP(hlc3) AND CE close is available
Short: EMA(close, lookback) crosses below VWAP(hlc3) AND PE close is available
Exit: long, CE premium high >= entry premium * (1 + target percentage / 100) OR EMA(close, lookback) crosses below VWAP(hlc3) AND PE close is unavailable
Exit: short, PE premium high >= entry premium * (1 + target percentage / 100) OR EMA(close, lookback) crosses above VWAP(hlc3) AND CE close is unavailable
Calculation: option premium target = option closing premium at entry × (1 + premium target percentage / 100)
Option: buy call, NIFTY spot EMA (EMA length parameter) crosses above NIFTY spot VWAP
Option: buy put, NIFTY spot EMA (EMA length parameter) crosses below NIFTY spot VWAP
Exit: long call, call option high >= option premium target
Exit: long put, put option high >= option premium target