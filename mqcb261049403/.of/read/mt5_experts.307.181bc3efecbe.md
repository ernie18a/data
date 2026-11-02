Calculation: Bar index i = i bars before the current chart bar; i=1 is the last completed bar.
Calculation: Average body at i = mean of abs(open-close) over the close-SMA period ending at bar i.
Calculation: Range midpoint at i = (high[i]+low[i])/2; body midpoint at i = (open[i]+close[i])/2.
Long: close[3]-open[3]>average body[1] AND close[2]-open[2]>average body[1] AND close[1]-open[1]>average body[1] AND range midpoint[2]>range midpoint[3] AND range midpoint[1]>range midpoint[2].
Short: open[3]-close[3]>average body[1] AND open[2]-close[2]>average body[1] AND open[1]-close[1]>average body[1] AND range midpoint[2]<range midpoint[3] AND range midpoint[1]<range midpoint[2].
Short: close[2]-open[2]>average body[1] AND close[1]<close[2] AND close[1]>open[2] AND body midpoint[2]>close SMA[1] AND open[1]>high[2].
Long: close[1]-open[1]>average body[1] AND open[2]-close[2]>average body[1] AND close[2]>close[1] AND close[1]<open[2] AND body midpoint[2]<close SMA[2] AND open[1]<low[2].
Long: open[3]-close[3]>average body[1] AND average body[2]<average body[1]*doji fraction AND close[2]<close[3] AND open[2]<open[3] AND open[1]>close[2] AND close[1]>close[2].
Short: close[3]-open[3]>average body[1] AND average body[2]<average body[1]*doji fraction AND close[2]>close[3] AND open[2]>open[3] AND open[1]<close[2] AND close[1]<close[2].
Long: open[2]>close[2] AND close[1]-open[1]>average body[1] AND close[1]>open[2] AND body midpoint[2]<close SMA[2] AND open[1]<close[2].
Short: open[2]<close[2] AND open[1]-close[1]>average body[1] AND close[1]<open[2] AND body midpoint[2]>close SMA[2] AND open[1]>close[2].
Long: open[2]>close[2] AND close[1]-open[1]>average body[1] AND close[1]>open[2] AND body midpoint[2]<close SMA[2] AND open[1]<close[2] AND MFI[1]<long-entry MFI threshold.
Short: open[2]<close[2] AND open[1]-close[1]>average body[1] AND close[1]<open[2] AND body midpoint[2]>close SMA[2] AND open[1]>close[2] AND MFI[1]>short-entry MFI threshold.
Long: open[3]-close[3]>average body[1] AND abs(close[2]-open[2])<average body[1]*star body fraction AND close[2]<close[3] AND open[2]<open[3] AND close[1]>body midpoint[3].
Short: close[3]-open[3]>average body[1] AND abs(close[2]-open[2])<average body[1]*star body fraction AND close[2]>close[3] AND open[2]>open[3] AND close[1]<body midpoint[3].
Long: range midpoint[1]<close SMA[2] AND min(open[1],close[1])>high[1]-(high[1]-low[1])*upper-range fraction AND close[1]<close[2] AND open[1]<open[2].
Short: range midpoint[1]>close SMA[2] AND min(open[1], indicator(close[1]>high[1]-(high[1]-low[1])*upper-range fraction))!=0 AND close[1]>close[2] AND open[1]>open[2].
Long: close[1]>open[1] AND open[2]-close[2]>average body[1] AND close[1]<open[2] AND open[1]>close[2] AND range midpoint[2]<close SMA[2].
Short: close[1]<open[1] AND close[2]-open[2]>average body[1] AND close[1]>open[2] AND open[1]<close[2] AND range midpoint[2]>close SMA[2].
Long: open[2]-close[2]>average body[1] AND close[1]-open[1]>average body[1] AND abs(close[1]-close[2])<meeting fraction*average body[1].
Short: close[2]-open[2]>average body[1] AND open[1]-close[1]>average body[1] AND abs(close[1]-close[2])<meeting fraction*average body[1].
Exit: long, (MFI[1]>upper exit threshold AND MFI[2]<upper exit threshold) OR (MFI[1]<lower exit threshold AND MFI[2]>lower exit threshold) OR (open[2]<close[2] AND open[1]-close[1]>average body[1] AND close[1]<open[2] AND body midpoint[2]>close SMA[2] AND open[1]>close[2] AND MFI[1]>short-entry MFI threshold).
Exit: short, (MFI[1]>lower exit threshold AND MFI[2]<lower exit threshold) OR (MFI[1]>upper exit threshold AND MFI[2]<upper exit threshold) OR (open[2]>close[2] AND close[1]-open[1]>average body[1] AND close[1]>open[2] AND body midpoint[2]<close SMA[2] AND open[1]<close[2] AND MFI[1]<long-entry MFI threshold).