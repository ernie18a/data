Calculation: PEMA = round to the configured price increment the combination 8E1 − 28E2 + 56E3 − 70E4 + 56E5 − 28E6 + 8E7 − E8, where each E is a successive EMA of the preceding series, all using the same lookback, starting from the selected applied price.
Calculation: Upper and lower envelopes = PEMA × (1 ± deviation/100), using the channel value from the configured shift bars earlier.
Long: close > upper envelope OR (on the lower indicator timeframe's last completed bar, close > upper envelope AND the immediately preceding bar's close ≤ its upper envelope).
Short: close < lower envelope OR (on the lower indicator timeframe's last completed bar, close < lower envelope AND the immediately preceding bar's close ≥ its lower envelope).
Exit: long, close < lower envelope on the lower indicator timeframe's last completed bar.
Exit: short, close > upper envelope on the lower indicator timeframe's last completed bar.