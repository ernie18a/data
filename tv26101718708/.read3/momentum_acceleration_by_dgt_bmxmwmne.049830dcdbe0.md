Calculation: Speed(src, p) = SMA((src - src[p]) / p, w)
Calculation: Acc(src, p) = Speed(src, p) - (Speed(src, p) - Speed(src, p)[p]) / p
Long: Acc(src, p) > 0
Short: Acc(src, p) < 0
Long: Acc(src, p) crosses above 0
Short: Acc(src, p) crosses below 0
Long: Acc(src, p) crosses above 0, j bars ago
Short: Acc(src, p) crosses below 0, j bars ago
Long: Acc(src, p) crosses above 0, j bars ago AND NOT Acc(src, p) crosses below 0 AND long side allowed AND position side is not long
Short: Acc(src, p) crosses below 0, j bars ago AND NOT Acc(src, p) crosses above 0 AND short side allowed AND position side is not short
Long: Acc(src, p) crosses above 0, k bars ago AND (NOT long candle filter on OR close[k-1] > open[k-1]) AND long side allowed
Short: Acc(src, p) crosses below 0, k bars ago AND (NOT short candle filter on OR close[k-1] < open[k-1]) AND short side allowed
Exit: long, Acc(src, p) crosses below 0, k bars ago AND (NOT short candle filter on OR close[k-1] < open[k-1])
Exit: short, Acc(src, p) crosses above 0, k bars ago AND (NOT long candle filter on OR close[k-1] > open[k-1])
Exit: long, stop-loss on AND low <= entry price * (1 - s)
Exit: short, stop-loss on AND high >= entry price * (1 + s)