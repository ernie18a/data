Calculation: PVT = cumulative sum of volume * (close - previous close) / previous close
Calculation: EOM = sign(x) * ln(1 + |x|), where x = (change in (high+low)/2 from previous bar) * TrueRange / (close * volume), and x = 0 if volume = 0 or TrueRange = 0
Calculation: swing low of PVT = a bar whose PVT is the lowest among N bars before and M bars after it (confirmed M bars later); swing high is the mirror
Long: change in (high+low)/2 from the previous bar >= 0
Long: at confirmation of a PVT swing low, the previous PVT swing low is no more than a maximum number of bars earlier AND PVT at this swing low < PVT at the previous swing low AND EOM at this swing-low bar > EOM at the previous swing-low bar
Short: change in (high+low)/2 from the previous bar < 0
Short: at confirmation of a PVT swing high, the previous PVT swing high is no more than a maximum number of bars earlier AND PVT at this swing high > PVT at the previous swing high AND EOM at this swing-high bar < EOM at the previous swing-high bar