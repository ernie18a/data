Calculation: VWAP slope (%) = (current session VWAP − session VWAP <lookback> bars ago) / session VWAP <lookback> bars ago × 100
Calculation: Long stop price = selected stop method: entry price − ATR × multiplier; lowest low over the swing lookback; slow EMA; or entry price × (1 − fixed stop percentage)
Calculation: Short stop price = selected stop method: entry price + ATR × multiplier; highest high over the swing lookback; slow EMA; or entry price × (1 + fixed stop percentage)
Calculation: Long target price = entry price + (entry price − long stop price) × risk-reward ratio
Calculation: Short target price = entry price − (short stop price − entry price) × risk-reward ratio
Long: fast EMA crosses above session VWAP AND fast EMA > slow EMA AND VWAP slope > 0 AND absolute VWAP slope ≥ flat threshold AND datetime is Monday through Friday when weekday-only trading is enabled
Short: fast EMA crosses below session VWAP AND fast EMA < slow EMA AND VWAP slope < 0 AND absolute VWAP slope ≥ flat threshold AND datetime is Monday through Friday when weekday-only trading is enabled
Exit: long, low ≤ long stop price OR high ≥ long target price
Exit: short, high ≥ short stop price OR low ≤ short target price