Calculation: Prior price median = median of the selected price series over the preceding lookback bars, excluding the current bar.
Calculation: Robust scale = 1.4826 × median absolute deviation of those same prices from the prior price median.
Calculation: Prior volume median = median volume over the preceding lookback bars, excluding the current bar.
Calculation: Relative volume = current volume ÷ prior volume median.
Calculation: Volume weight = square root of relative volume clipped to the configured minimum and maximum weights.
Calculation: Raw robust Z = (current selected price − prior price median) ÷ robust scale.
Calculation: Weighted Z = raw robust Z × volume weight.
Calculation: Volume coverage = fraction of preceding lookback bars with positive, available volume.
Long: Current bar is confirmed AND the lookback price and volume data are ready, robust scale > 0.1 × minimum tick, volume coverage ≥ configured minimum, current volume > 0, prior volume median > 0, AND ((weighted Z ≥ configured outer threshold AND relative volume ≥ configured supported-volume floor) OR (raw robust Z ≥ configured outer threshold AND relative volume ≤ configured thin-volume ceiling)).
Short: Current bar is confirmed AND the lookback price and volume data are ready, robust scale > 0.1 × minimum tick, volume coverage ≥ configured minimum, current volume > 0, prior volume median > 0, AND ((weighted Z ≤ −configured outer threshold AND relative volume ≥ configured supported-volume floor) OR (raw robust Z ≤ −configured outer threshold AND relative volume ≤ configured thin-volume ceiling)).
Exit: long or short, current bar is confirmed AND lookback price and volume data are ready AND absolute weighted Z ≤ configured center-return threshold.