Calculation: Ranging = EMA(ATR(ATR lookback parameter) / close, half the ranging lookback) < EMA(ATR(ATR lookback parameter) / close, ranging lookback)
Calculation: VWMA alignment = VWMA(close, VWMA lookback) > SMA(close, SMA lookback) AND close >= VWMA(close, VWMA lookback)
Long: Position is flat AND Stochastic(close, high, low, Stochastic lookback) >= midpoint parameter AND MFI(close, MFI lookback) crosses above midpoint parameter AND VWMA alignment AND OBV > EMA(OBV, OBV EMA lookback) AND NOT Ranging
Long: Position is flat AND VWMA alignment AND Stochastic(close, high, low, Stochastic lookback) >= midpoint parameter AND Ranging AND, within the divergence persistence parameter bars, a same-bar confirmed price pivot low is higher than the preceding price pivot low and a confirmed MFI pivot low is higher than the preceding MFI pivot low
Long: VWMA(close, VWMA lookback) crosses above SMA(close, SMA lookback)
Short: VWMA(close, VWMA lookback) crosses below SMA(close, SMA lookback)
Exit: long, high >= entry price * (1 + take-profit percentage)
Exit: long, close <= the nearest support level captured at entry