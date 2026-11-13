Calculation: MFI_diff = MFI(short period) - MFI(long period), both standard Money Flow Index on chart timeframe, using volume, evaluated on the current bar
Calculation: Stoch1 = (MFI_diff - lowest MFI_diff over N bars) / (highest MFI_diff over N bars - lowest MFI_diff over N bars) * 100; if the range is 0, use previous Stoch1; then smooth: Stoch1 = previous Stoch1 + 0.5 * (Stoch1 - previous Stoch1)
Calculation: STC = (Stoch1 - lowest Stoch1 over N bars) / (highest Stoch1 over N bars - lowest Stoch1 over N bars) * 200 - 100, using the same N as for Stoch1; if the range is 0, use previous STC; then smooth: STC = previous STC + 0.5 * (STC - previous STC)
Long: STC > middle level (zero)
Short: STC < middle level (zero)