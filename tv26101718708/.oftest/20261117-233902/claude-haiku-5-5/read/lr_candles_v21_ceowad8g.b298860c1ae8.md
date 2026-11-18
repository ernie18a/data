Calculation: SignalLine = SMA(LinReg(close, linreg length, linreg offset) if linreg switch else close, signal length) if SMA switch else EMA(LinReg(close, linreg length, linreg offset) if linreg switch else close, signal length)
Long: VWMA(close, vwma length) crosses above SignalLine
Short: VWMA(close, vwma length) crosses below SignalLine