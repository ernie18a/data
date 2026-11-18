Long: current price > the open of the still-forming signal-timeframe bar AND the distance from that open to the bar's low > a threshold AND there are no open orders AND the current hour < an entry-hour cutoff
Short: current price < the open of the still-forming signal-timeframe bar AND the distance from that open to the bar's high > a threshold AND there are no open orders AND the current hour < a separately set entry-hour cutoff
Exit: long, current hour > the market-close-hour parameter minus one hour
Exit: short, current hour > the market-close-hour parameter minus one hour