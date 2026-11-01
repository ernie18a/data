Calculation: Range position = 100 × (bar midpoint of high and low − lowest low) / (highest high − lowest low), using a lookback that includes the bar; use 0 when highest high equals lowest low. Calculate on the chart timeframe or a selectable higher or lower timeframe, using the selected signal bar, which may be the last completed bar, an earlier completed bar, or the bar still forming.
Long: Entry-zone mode AND range position > upper threshold AND previous range position <= upper threshold
Long: Exit-zone mode AND range position > lower threshold AND previous range position <= lower threshold
Short: Entry-zone mode AND range position < lower threshold AND previous range position >= lower threshold
Short: Exit-zone mode AND range position < upper threshold AND previous range position >= upper threshold
Exit: long, most recent short signal is more recent than the most recent long signal
Exit: short, most recent long signal is more recent than the most recent short signal
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance