Calculation: Volume MA = simple moving average of volume over a configurable lookback
Calculation: Trend MA = EMA or SMA of the selected price source over a configurable lookback
Long: (volume >= low-volume threshold × Volume MA AND selected price source > Trend MA) OR (volume > Volume MA AND selected price source > Trend MA)
Short: (volume >= low-volume threshold × Volume MA AND selected price source <= Trend MA) OR (volume > Volume MA AND selected price source <= Trend MA)