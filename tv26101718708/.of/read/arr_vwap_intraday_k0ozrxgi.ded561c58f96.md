Long: VWAP > prior bar VWAP AND RSI > configured buy threshold AND bar hour > configured trade start hour AND bar hour < configured close hour
Short: VWAP < prior bar VWAP AND RSI < configured sell threshold AND bar hour > configured trade start hour AND bar hour < configured close hour
Exit: long, VWAP < prior bar VWAP OR bar hour = configured close hour
Exit: short, VWAP > prior bar VWAP OR bar hour = configured close hour