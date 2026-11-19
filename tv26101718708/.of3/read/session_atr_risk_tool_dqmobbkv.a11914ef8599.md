Calculation: Session Range Average = mean of up to Session Lookback most recent completed Session Window high-low ranges, calculated from chart bars.
Calculation: Effective Entry Price = configured entry price when supplied, otherwise close.
Calculation: Stop Distance = stop multiplier × selected stop basis, where the basis is ATR(ATR Lookback) on chart bars or Session Range Average, as selected.
Exit: long, Stop Distance is defined AND low <= Effective Entry Price - Stop Distance
Exit: short, Stop Distance is defined AND high >= Effective Entry Price + Stop Distance