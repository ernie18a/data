Calculation: Cash-session VWAP = cumulative (HLC3 × volume) divided by cumulative volume, reset at the start of each cash session
Calculation: Initial Balance high and low = highest high and lowest low during the first hour of the cash session
Long: During the cash session, close > cash-session VWAP AND close > Initial Balance high AND (low <= cash-session VWAP OR low <= Initial Balance high)
Short: During the cash session, close < cash-session VWAP AND close < Initial Balance low AND (high >= cash-session VWAP OR high >= Initial Balance low)