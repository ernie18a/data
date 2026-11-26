Calculation: selected MA(source, lookback, type, timeframe) = selected SMA/EMA/RMA/WMA/VWMA(source, lookback) calculated on timeframe bars and mapped to chart bars; each configured MA has separate source, lookback, type, and timeframe parameters; higher-timeframe values use the last completed bar historically and the still-forming bar in real time
Calculation: volatility = 100 * (highest(close, lookback) - lowest(close, lookback)) / lowest(close, lookback)
Long: long entries enabled AND selected short-term MA > selected long-term MA AND selected mid-term MA crosses above selected long-term MA AND volatility > volatility threshold AND (bull-bear filter disabled OR selected long-term MA > selected bull-bear MA)
Short: short entries enabled AND selected short-term MA < selected long-term MA AND selected mid-term MA crosses below selected long-term MA AND volatility > volatility threshold AND (bull-bear filter disabled OR selected long-term MA < selected bull-bear MA)
Exit: long, bull-bear filter enabled AND selected long-term MA < selected bull-bear MA
Exit: short, bull-bear filter enabled AND selected long-term MA > selected bull-bear MA
Exit: short, bull-bear filter enabled AND selected long-term MA < selected bull-bear MA AND selected short-term MA > selected long-term MA AND selected mid-term MA crosses above selected long-term MA AND volatility > volatility threshold
Exit: long, bull-bear filter enabled AND selected long-term MA > selected bull-bear MA AND selected short-term MA < selected long-term MA AND selected mid-term MA crosses below selected long-term MA AND volatility > volatility threshold
Exit: short, bull-bear filter disabled AND long entries disabled AND selected short-term MA > selected long-term MA AND selected mid-term MA crosses above selected long-term MA AND volatility > volatility threshold
Exit: long, bull-bear filter disabled AND short entries disabled AND selected short-term MA < selected long-term MA AND selected mid-term MA crosses below selected long-term MA AND volatility > volatility threshold
Exit: long, low <= entry price * (1 - stop-loss percentage)
Exit: short, high >= entry price * (1 + stop-loss percentage)