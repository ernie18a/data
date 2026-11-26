Calculation: AnchoredVWAP = sum(price * weight) / sum(weight) over anchor window, where price = price source, weight = volume weight(volume), and anchor window = last rolling length bars, or bars since start of current T1 bar still forming, or bars since anchor date, as selected by anchor mode
Long: close crosses above AnchoredVWAP
Short: close crosses below AnchoredVWAP
Long: AnchoredVWAP - AnchoredVWAP[slope lookback] > slope threshold * ATR(max(ATR period floor, slope lookback))
Short: AnchoredVWAP[slope lookback] - AnchoredVWAP > slope threshold * ATR(max(ATR period floor, slope lookback))
Long: close > AnchoredVWAP
Short: close < AnchoredVWAP