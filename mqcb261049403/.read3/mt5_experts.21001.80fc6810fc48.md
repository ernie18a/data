Calculation: slow line = second selected smoothing method(first selected smoothing method(applied price, slow first lookback, slow first phase), slow second lookback, slow second phase), calculated on chart bars
Calculation: entry line = second selected smoothing method(first selected smoothing method(applied price, entry first lookback, entry first phase), entry second lookback, entry second phase), calculated on T1 bars using the last completed T1 bar and mapped to chart bars
Calculation: line color index = 1 when the line rises, 2 when it falls, and 0 when it is unchanged
Long: long entries enabled AND slow line color index = 1 AND entry line color index at the selected signal bar != 1 AND entry line color index at the preceding bar = 1
Short: short entries enabled AND slow line color index = 2 AND entry line color index at the selected signal bar != 2 AND entry line color index at the preceding bar = 2
Exit: long, long trend close enabled AND slow line color index = 2
Exit: short, short trend close enabled AND slow line color index = 1
Exit: long, long signal close enabled AND entry line color index on the last completed T1 bar = 2
Exit: short, short signal close enabled AND entry line color index on the last completed T1 bar = 1
Long: entry line color index at the selected signal bar = 2 AND entry line color index at the preceding chart bar != 2
Short: entry line color index at the selected signal bar = 1 AND entry line color index at the preceding chart bar != 1