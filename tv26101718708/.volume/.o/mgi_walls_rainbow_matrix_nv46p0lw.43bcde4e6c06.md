Calculation: POC = HLC3 of the most recent radar-timeframe bar with the highest volume in the 60-bar lookback.
Calculation: Value-area deviation = square root of the volume-weighted variance of HLC3 around the POC over the 60-bar lookback.
Calculation: VAH = POC + 2.51 × value-area deviation; VAL = max(POC − 2.51 × value-area deviation, a positive floor).
Calculation: Global VWMA, POC, VAH, VAL = arithmetic mean of the available corresponding values across the five configured radar timeframes, from shortest to longest.
Calculation: Anchored VWAP = cumulative volume-weighted HLC3 since the start of the current day, week, or month, respectively; use the current period as it forms.
Calculation: Wall level = each configured radar timeframe's VWMA, POC, VAH, VAL, and Parabolic SAR; the global VWMA, POC, VAH, and VAL; and the daily, weekly, and monthly anchored VWAP. Radar-timeframe values use the last completed bar historically and the forming bar in real time; radar timeframes are ordered shortest to longest.
Long: close >= any wall level
Short: close < any wall level