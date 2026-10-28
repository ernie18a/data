Calculation: Estimated delta = EMA(volume × (2 × (close − low) / max(high − low, minimum price increment) − 1))
Calculation: Cumulative delta = running sum of unsmoothed estimated delta
Calculation: CVD baseline = SMA of cumulative delta
Calculation: Delta change (%) = abs(current pivot delta − previous pivot delta) / max(abs(previous pivot delta), 1) × 100
Calculation: Pivot low = current low is the lowest low in the preceding lookback window and current bar
Calculation: Pivot high = current high is the highest high in the preceding lookback window and current bar
Long: At a pivot low no more than the maximum pivot distance after the previous pivot low, current low < previous pivot low AND current smoothed delta > previous pivot delta AND delta change (%) ≥ minimum AND volume ≥ volume SMA × multiplier AND cumulative delta > its SMA baseline
Long: At a pivot low no more than the maximum pivot distance after the previous pivot low, current low > previous pivot low AND current smoothed delta < previous pivot delta AND delta change (%) ≥ minimum AND volume ≥ volume SMA × multiplier
Short: At a pivot high no more than the maximum pivot distance after the previous pivot high, current high > previous pivot high AND current smoothed delta < previous pivot delta AND delta change (%) ≥ minimum AND volume ≥ volume SMA × multiplier AND cumulative delta ≤ its SMA baseline
Short: At a pivot high no more than the maximum pivot distance after the previous pivot high, current high < previous pivot high AND current smoothed delta > previous pivot delta AND delta change (%) ≥ minimum AND volume ≥ volume SMA × multiplier