Calculation: Mean return = average(simple or log return(close, shortest lookback), simple or log return(close, shorter-middle lookback), simple or log return(close, longer-middle lookback), simple or log return(close, longest lookback)), computed from T1 closes using the last completed or still-forming T1 bar according to the confirmation setting, and carried to chart bars
Long: Mean return crosses above 0
Short: Mean return crosses below 0
Calculation: TIPS momentum = average(R(C/C[P1]), R(C/C[P2]), R(C/C[P3]), R(C/C[P4])), where C is TIPS ETF closing price on timeframe T1 and R(x) is x−1 or ln(x), selected by a parameter
Long: TIPS momentum > 0
Exit: long, TIPS momentum <= 0