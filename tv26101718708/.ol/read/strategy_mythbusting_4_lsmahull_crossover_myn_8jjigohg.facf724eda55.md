Calculation: LSMA = least-squares linear regression of close over a lookback, evaluated at the current bar
Calculation: Hull line = selected HMA, EHMA, or THMA of close; if sourced from another timeframe, use the last completed higher-timeframe bar
Long: LSMA crosses above the Hull line AND close > Hull line AND Hull line <= its value two bars ago AND (ADX filter is disabled OR ADX > its threshold)
Short: LSMA crosses below the Hull line AND close < Hull line AND Hull line > its value two bars ago AND (ADX filter is disabled OR ADX > its threshold)
Exit: Long, close < entry price × (1 − stop-loss fraction) OR high >= entry price × (1 + configured take-profit fraction)
Exit: Short, close > entry price × (1 + stop-loss fraction) OR low <= entry price × (1 − configured take-profit fraction)