Calculation: Buy stop level = high of the last completed chart-timeframe bar + upward price offset
Calculation: Sell stop level = low of the last completed chart-timeframe bar − downward price offset
Long: (a long position exists AND buy stop level − highest long entry price > position spacing) OR (no long position exists AND no pending long stop order exists)
Short: (a short position exists AND lowest short entry price − sell stop level > position spacing) OR (no short position exists AND no pending short stop order exists)
Exit: All open positions, combined open-position profit including commission and swap > minimum profit