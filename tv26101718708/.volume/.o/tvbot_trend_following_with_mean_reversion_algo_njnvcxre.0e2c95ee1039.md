Calculation: VWMA long signal = after close crosses above the shorter-term VWMA, store that close; signal when the VWMA subsequently crosses above the stored close. Cancel this setup when close crosses below the VWMA. Long and short signals alternate, with long initially eligible.
Calculation: VWMA short signal = after close crosses below the shorter-term VWMA, store that close; signal when the VWMA subsequently crosses below the stored close. Cancel this setup when close crosses above the VWMA.
Calculation: HMA long signal = after close crosses above the HMA, store that close; signal when the HMA subsequently crosses above the stored close. Cancel this setup when close crosses below the HMA. Long and short signals alternate, with long initially eligible.
Calculation: HMA short signal = after close crosses below the HMA, store that close; signal when the HMA subsequently crosses below the stored close. Cancel this setup when close crosses above the HMA.
Calculation: Mean-reversion thresholds = upper and lower thresholds at a configurable percentage above and below the long-term EMA mean.
Calculation: EMA touch flag = true when the bar's high and low straddle the long-term trend EMA or either configurable EMA band, or close is strictly between the bands; reset on a new position or opposite VWMA signal. Use the previous bar's flag for entry conditions.
Long: VWMA long signal AND close > long-term trend EMA AND previous-bar EMA touch flag OR HMA long signal AND close < lower mean-reversion threshold
Short: VWMA short signal AND close < long-term trend EMA AND previous-bar EMA touch flag OR HMA short signal AND close > upper mean-reversion threshold
Exit: long, VWMA short signal OR HMA short signal AND close > upper mean-reversion threshold
Exit: short, VWMA long signal OR HMA long signal AND close < lower mean-reversion threshold
Exit: long, HMA short signal OR VWMA short signal AND close < long-term trend EMA AND previous-bar EMA touch flag
Exit: short, HMA long signal OR VWMA long signal AND close > long-term trend EMA AND previous-bar EMA touch flag