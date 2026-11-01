Calculation: MFI SMI = Stochastic Momentum Index calculated from the Money Flow Index of a selected price source; its signal is a selected moving average of the SMI. Calculate a separate MFI SMI and signal with independently selected parameters for the histogram, which is their difference multiplied by a positive scale factor. Calculate these on the chart timeframe or on a higher timeframe using either the still-forming bar or the last completed bar; compare the resulting series on chart bars.
Calculation: Dynamic zone = nearest-rank upper and lower percentiles of the MFI SMI over a rolling sample on the same timeframe and with the same completed-or-forming-bar choice as the MFI SMI.
Calculation: Divergence pivots = confirmed pivot highs or lows of the selected MFI SMI or histogram on chart bars, using independently selected left and right lookbacks; evaluate a pivot on its confirmation bar and compare it with the previous confirmed pivot of the same type. The pivot separation must be within the selected inclusive minimum and maximum chart-bar distances.
Long: Histogram >= 0
Short: Histogram < 0
Long: MFI SMI >= its signal
Short: MFI SMI < its signal
Long: MFI SMI crosses above its signal AND previous chart-bar MFI SMI <= a selected upper limit AND, if the outside-zone filter is enabled, previous chart-bar MFI SMI < the current lower dynamic-zone boundary OR previous chart-bar MFI SMI > the current upper dynamic-zone boundary
Short: MFI SMI crosses below its signal AND previous chart-bar MFI SMI >= a selected lower limit AND, if the outside-zone filter is enabled, previous chart-bar MFI SMI < the current lower dynamic-zone boundary OR previous chart-bar MFI SMI > the current upper dynamic-zone boundary
Long: MFI SMI crosses above its signal AND previous chart-bar MFI SMI <= a second selected upper limit AND, if the inside-zone filter is enabled, previous chart-bar MFI SMI >= the current lower dynamic-zone boundary AND previous chart-bar MFI SMI <= the current upper dynamic-zone boundary
Short: MFI SMI crosses below its signal AND previous chart-bar MFI SMI >= a second selected lower limit AND, if the inside-zone filter is enabled, previous chart-bar MFI SMI >= the current lower dynamic-zone boundary AND previous chart-bar MFI SMI <= the current upper dynamic-zone boundary
Long: MFI SMI > the upper dynamic-zone boundary
Short: MFI SMI < the lower dynamic-zone boundary
Long: MFI SMI signal crosses above a selected lower threshold
Short: MFI SMI signal crosses below a selected upper threshold
Long: A confirmed oscillator pivot low is higher than the previous oscillator pivot low AND the price low at that pivot is lower than the price low at the previous oscillator pivot low AND pivot separation is within the selected range
Long: A confirmed oscillator pivot low is lower than the previous oscillator pivot low AND the price low at that pivot is higher than the price low at the previous oscillator pivot low AND pivot separation is within the selected range
Short: A confirmed oscillator pivot high is lower than the previous oscillator pivot high AND the price high at that pivot is higher than the price high at the previous oscillator pivot high AND pivot separation is within the selected range
Short: A confirmed oscillator pivot high is higher than the previous oscillator pivot high AND the price high at that pivot is lower than the price high at the previous oscillator pivot high AND pivot separation is within the selected range