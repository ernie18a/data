Calculation: Opening-range high = highest high during the configured opening-range session, fixed when the session completes
Calculation: Opening-range low = lowest low during the configured opening-range session, fixed when the session completes
Calculation: Opening-range midpoint = average of the opening-range high and low
Calculation: Opening-range width = opening-range high − opening-range low
Calculation: Target offset = opening-range width × the configured target fraction
Calculation: Daily bias = compare the completed current session opening-range midpoint with the previous session's completed opening-range midpoint
Long: opening-range high > opening-range low AND long signal is armed AND ((daily bias is disabled AND close crosses above opening-range high) OR (daily bias is enabled AND ((current midpoint >= previous completed midpoint AND close crosses above opening-range high) OR (current midpoint < previous completed midpoint AND close crosses above opening-range high + target offset))))
Short: opening-range high > opening-range low AND short signal is armed AND ((daily bias is disabled AND close crosses below opening-range low) OR (daily bias is enabled AND ((current midpoint <= previous completed midpoint AND close crosses below opening-range low) OR (current midpoint > previous completed midpoint AND close crosses below opening-range low − target offset))))
Calculation: Long signal is armed initially after the opening-range session completes and is re-armed after a long signal when close < opening-range midpoint
Calculation: Short signal is armed initially after the opening-range session completes and is re-armed after a short signal when close > opening-range midpoint