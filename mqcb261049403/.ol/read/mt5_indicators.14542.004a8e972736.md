Calculation: XRSX = 100 × clamp(smoothed price change / smoothed absolute price change, -1, 1), using the longer smoothing lookback
Calculation: Signal line = smoothed XRSX using a shorter lookback than the XRSX smoothing
Calculation: Fast stepped line and slow stepped line = trailing step levels of (XRSX + 100) / 2, using the same recursive trend and level-clamping rules, with the fast step size smaller than the slow step size
Long: XRSX > previous bar's signal line OR fast stepped line > slow stepped line
Short: XRSX < previous bar's signal line OR fast stepped line < slow stepped line