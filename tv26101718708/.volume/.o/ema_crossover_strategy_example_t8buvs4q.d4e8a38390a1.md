Calculation: HLC3 = (high + low + close) / 3
Long: short moving average of HLC3 crosses above long moving average of HLC3 AND datetime is within the configured backtest date range; the short lookback is shorter than the long lookback
Exit: long, close crosses below the exit moving average of HLC3 AND datetime is within the configured backtest date range
Exit: long, datetime is outside the configured backtest date range