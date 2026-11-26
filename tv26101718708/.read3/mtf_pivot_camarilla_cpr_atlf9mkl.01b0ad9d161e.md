Calculation: CP(bar) = (high(bar) + low(bar) + close(bar)) / 3
Calculation: Extended R4.5(bar, camarilla multiplier, extension coefficient) = Camarilla R4(bar, camarilla multiplier) + extension coefficient * (Camarilla R4(bar, camarilla multiplier) - Camarilla R3(bar, camarilla multiplier))
Calculation: Extended S4.5(bar, camarilla multiplier, extension coefficient) = Camarilla S4(bar, camarilla multiplier) - extension coefficient * (Camarilla S3(bar, camarilla multiplier) - Camarilla S4(bar, camarilla multiplier))
Long: close > AnchoredVWAP(anchor T1, base T5 bars, last completed bar) + flat multiplier * ATR(T1 bars, ATR length, last completed bar)
Short: close < AnchoredVWAP(anchor T1, base T5 bars, last completed bar) - flat multiplier * ATR(T1 bars, ATR length, last completed bar)
Long: close > AnchoredVWAP(anchor T2, base T5 bars, last completed bar) + flat multiplier * ATR(T1 bars, ATR length, last completed bar)
Short: close < AnchoredVWAP(anchor T2, base T5 bars, last completed bar) - flat multiplier * ATR(T1 bars, ATR length, last completed bar)
Long: close > AnchoredVWAP(anchor T3, base T5 bars, last completed bar) + flat multiplier * ATR(T1 bars, ATR length, last completed bar)
Short: close < AnchoredVWAP(anchor T3, base T5 bars, last completed bar) - flat multiplier * ATR(T1 bars, ATR length, last completed bar)
Long: close > AnchoredVWAP(anchor T4, base T6 bars, last completed bar) + flat multiplier * ATR(T1 bars, ATR length, last completed bar)
Short: close < AnchoredVWAP(anchor T4, base T6 bars, last completed bar) - flat multiplier * ATR(T1 bars, ATR length, last completed bar)
Long: CP(T1 bars, last completed bar) > CP(T1 bars, second-last completed bar)
Short: CP(T1 bars, last completed bar) < CP(T1 bars, second-last completed bar)
Long: CP(T2 bars, last completed bar) > CP(T2 bars, second-last completed bar)
Short: CP(T2 bars, last completed bar) < CP(T2 bars, second-last completed bar)
Long: CP(T3 bars, last completed bar) > CP(T3 bars, second-last completed bar)
Short: CP(T3 bars, last completed bar) < CP(T3 bars, second-last completed bar)
Long: close crosses above CP(Tp bars, last completed bar) AND bars since this alert last fired >= cooldown
Short: close crosses below CP(Tp bars, last completed bar) AND bars since this alert last fired >= cooldown
Long: close crosses above AnchoredVWAP(anchor Tp, base T5 bars, last completed bar) AND not first bar of a new Tp period AND bars since this alert last fired >= cooldown
Short: close crosses below AnchoredVWAP(anchor Tp, base T5 bars, last completed bar) AND not first bar of a new Tp period AND bars since this alert last fired >= cooldown
Long: close crosses above AnchoredVWAP(anchor T4, base T6 bars, last completed bar) AND not first bar of a new year AND bars since this alert last fired >= cooldown
Short: close crosses below AnchoredVWAP(anchor T4, base T6 bars, last completed bar) AND not first bar of a new year AND bars since this alert last fired >= cooldown
Long: for some band multiplier, close crosses above AnchoredVWAP(anchor T4, base T6 bars, last completed bar) + band multiplier * AnchoredVWAP standard deviation(anchor T4, base T6 bars, last completed bar) AND not first bar of a new year AND bars since this band's alert last fired >= cooldown
Short: for some band multiplier, close crosses below AnchoredVWAP(anchor T4, base T6 bars, last completed bar) + band multiplier * AnchoredVWAP standard deviation(anchor T4, base T6 bars, last completed bar) AND not first bar of a new year AND bars since this band's alert last fired >= cooldown
Long: high crosses above High(Tp bars, last completed bar) AND bars since this alert last fired >= cooldown
Short: low crosses below Low(Tp bars, last completed bar) AND bars since this alert last fired >= cooldown
Short: high crosses above Camarilla R3(Tp bars, camarilla multiplier, last completed bar) AND bars since this alert last fired >= cooldown
Long: low crosses below Camarilla S3(Tp bars, camarilla multiplier, last completed bar) AND bars since this alert last fired >= cooldown
Long: high crosses above Camarilla R4(Tp bars, camarilla multiplier, last completed bar) AND bars since this alert last fired >= cooldown
Short: low crosses below Camarilla S4(Tp bars, camarilla multiplier, last completed bar) AND bars since this alert last fired >= cooldown
Exit: long, high crosses above Extended R4.5(Tp bars, camarilla multiplier, extension coefficient, last completed bar) AND bars since this alert last fired >= cooldown
Exit: long, high crosses above Camarilla R5(Tp bars, camarilla multiplier, last completed bar) AND bars since this alert last fired >= cooldown
Exit: short, low crosses below Extended S4.5(Tp bars, camarilla multiplier, extension coefficient, last completed bar) AND bars since this alert last fired >= cooldown
Exit: short, low crosses below Camarilla S5(Tp bars, camarilla multiplier, last completed bar) AND bars since this alert last fired >= cooldown