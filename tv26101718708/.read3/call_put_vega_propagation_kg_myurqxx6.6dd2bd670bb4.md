Calculation: Strike = manual strike in manual mode; otherwise round(close / strike step) × strike step
Calculation: Time to expiry = max((expiry datetime − datetime) / year duration, minimum time to expiry)
Calculation: Risk-free rate = risk-free rate percentage / 100
Calculation: Call IV = max((India VIX close on the current chart bar + call IV skew) / 100, minimum IV percentage / 100) when live IV is enabled and India VIX is available and positive; otherwise manual call IV percentage / 100
Calculation: Put IV = max((India VIX close on the current chart bar + put IV skew) / 100, minimum IV percentage / 100) when live IV is enabled and India VIX is available and positive; otherwise manual put IV percentage / 100
Calculation: Call Vega = EMA(change(Black-Scholes vega(close, strike, risk-free rate, call IV, time to expiry), call lookback), max(call lookback / call smoothing divisor, minimum smoothing lookback))
Calculation: Put Vega = EMA(change(Black-Scholes vega(close, strike, risk-free rate, put IV, time to expiry), put lookback), max(put lookback / put smoothing divisor, minimum smoothing lookback))
Long: Call Vega > Put Vega
Short: Put Vega > Call Vega
Long: Call Vega crosses above Put Vega
Short: Call Vega crosses below Put Vega
Long: Call Vega crosses above Put Vega AND Call Vega > 0
Short: Call Vega crosses below Put Vega AND Put Vega > 0