Calculation: opening gap top = max(close[1], open) on the first chart bar of each T1 period; hold through that period
Calculation: opening gap bottom = min(close[1], open) on the first chart bar of each T1 period; hold through that period
Long: position is flat AND no entry has occurred in the current T1 period AND high > opening gap top has occurred on a chart bar in the current T1 period (including the current bar) AND low <= opening gap top AND low > opening gap bottom
Short: position is flat AND no entry has occurred in the current T1 period AND low < opening gap bottom has occurred on a chart bar in the current T1 period (including the current bar) AND high >= opening gap bottom AND high < opening gap top
Exit: long, high since entry reaches entry price + activation distance in ticks AND low <= highest high since activation
Exit: short, low since entry reaches entry price - activation distance in ticks AND high >= lowest low since activation