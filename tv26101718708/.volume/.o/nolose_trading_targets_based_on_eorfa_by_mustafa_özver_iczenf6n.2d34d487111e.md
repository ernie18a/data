Calculation: EoRfA = (WMA(VWAP + HLC3, short lookback) − EMA(WMA(VWAP + HLC3, short lookback), lookback)) / standard deviation of WMA(VWAP + HLC3, short lookback) over that same lookback
Calculation: Buy setup = EoRfA below its negative threshold AND EoRfA rising
Calculation: Sell setup = EoRfA above its positive threshold AND EoRfA falling
Calculation: Active buy area = previous bar’s buy setup starts the area; it persists from the previous bar until the current buy-area reset condition is met. Its upper boundary is the maximum of the current bar’s OHLC-derived prices; while active, retain the previous boundary. Its low extreme is the lowest low since activation.
Calculation: Active sell area = previous bar’s sell setup starts the area; it persists from the previous bar until the current sell-area reset condition is met. Its lower boundary is the minimum of the current bar’s OHLC-derived prices; while active, retain the previous boundary. Its high extreme is the highest high since activation.
Calculation: Buy-area reset condition = buy-area upper boundary at or below the greater of open and close OR sell setup OR previous bar’s sell-entry retracement level below close
Calculation: Sell-area reset condition = sell-area lower boundary at or above the lesser of open and close OR buy setup OR previous bar’s buy-entry retracement level above close
Calculation: Fibonacci rate = (close − lower range bound) / (upper range bound − lower range bound), where the bounds are the active buy-area upper boundary and low extreme during a buy area, the active sell-area lower boundary and high extreme during a sell area, and HLC3 otherwise
Calculation: Range verification = upper range bound plus lower range bound unchanged from the previous bar AND upper range bound / lower range bound above one plus a tolerance
Calculation: Verified setup = (active buy area OR active sell area) AND range verification
Calculation: Buy-entry retracement level = lower Fibonacci retracement level between the active buy-area upper boundary and low extreme
Calculation: Sell-entry retracement level = upper Fibonacci retracement level between the active sell-area lower boundary and high extreme
Long: Buy setup AND active buy area is inactive
Long: Active buy area AND verified setup AND no open position AND Fibonacci rate between the two consecutive lower retracement levels AND EoRfA rising
Short: Sell setup AND active sell area is inactive
Short: Active sell area AND verified setup AND no open position AND Fibonacci rate between the two consecutive upper retracement levels AND EoRfA falling
Exit: long, close above the stored long exit price
Exit: short, close below the stored short exit price