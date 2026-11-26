Calculation: XRVI value = XRVI(open, high, low, close, XRVI period, XRVI smoothing method, XRVI smoothing parameter), calculated on T1 bars
Calculation: XRVI signal line = smooth(XRVI value, signal period, signal smoothing method, signal smoothing parameter), calculated on T1 bars
Long: on chart ticks, long entries enabled AND XRVI value[1] > XRVI signal line[1] AND XRVI value[0] <= XRVI signal line[0]
Short: on chart ticks, short entries enabled AND XRVI value[1] < XRVI signal line[1] AND XRVI value[0] >= XRVI signal line[0]
Exit: long, on chart ticks, long exits enabled AND short entries disabled AND XRVI value[1] < XRVI signal line[1] AND XRVI value[0] >= XRVI signal line[0]
Exit: short, on chart ticks, short exits enabled AND long entries disabled AND XRVI value[1] > XRVI signal line[1] AND XRVI value[0] <= XRVI signal line[0]