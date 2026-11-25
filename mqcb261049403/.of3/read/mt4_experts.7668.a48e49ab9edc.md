Long: Donchian lower channel (lookback, T1, last completed bar) > Donchian lower channel (lookback, T1, two bars ago); evaluate on chart bars using T1 values
Short: Donchian upper channel (lookback, T1, last completed bar) < Donchian upper channel (lookback, T1, two bars ago); evaluate on chart bars using T1 values
Calculation: Long stop = highest Donchian lower channel (lookback, T1, bar still forming) since entry, updated on chart bars using T1 values
Calculation: Short stop = lowest Donchian upper channel (lookback, T1, bar still forming) since entry, updated on chart bars using T1 values
Exit: long, low <= Long stop
Exit: short, high >= Short stop