Calculation: Time = datetime if bar-open timing, else datetime + bar duration
Calculation: Price = open if bar-open timing, else close
Calculation: Lag = 1 if bar-open timing, else 0
Calculation: Start = first Time >= plan start
Calculation: Deposits = -1 if Time < plan start, else floor((Time - Start) / deposit interval)
Calculation: Rebalances = floor((Time - Start) / rebalance interval)
Calculation: Peak = highest Price since Start
Calculation: Buy = 1 if Deposits > Deposits[1], or for any dip level k, Price <= Peak * (1 - dip level k / 100) and dip level k not yet bought since the last new peak; otherwise 0
Calculation: Rise open = 1 if minimum rise is 0, or no sale has occurred since the last full liquidation, or the highest Price since the last sale >= the last sale's Price * (1 + minimum rise / 100); otherwise 0
Calculation: Armed = 1 from the first bar after the last sale (or after the first buy if there is no sale) on which Rise open = 1, Price * (1 - transaction cost) >= entry price * (1 + trailing activation / 100), and Price > trailing peak at the last sale (unless that sale was a full liquidation); stays 1 until a sale; otherwise 0
Calculation: Trailing peak = highest Price since Armed became 1, or none when Armed = 0
Long: chart timeframe is T1 or T2 AND Deposits > Deposits[1]
Long: chart timeframe is T1 or T2 AND Price <= Peak * (1 - dip level 1 / 100) AND dip level 1 not yet bought since the last new peak
Long: chart timeframe is T1 or T2 AND Price <= Peak * (1 - dip level 2 / 100) AND dip level 2 not yet bought since the last new peak
Long: chart timeframe is T1 or T2 AND Price <= Peak * (1 - dip level 3 / 100) AND dip level 3 not yet bought since the last new peak
Long: chart timeframe is T1 or T2 AND Price <= Peak * (1 - dip level 4 / 100) AND dip level 4 not yet bought since the last new peak
Exit: long, chart timeframe is T1 or T2 AND Armed[1] = 1 AND Price <= Trailing peak[1] * (1 - trailing distance / 100) AND Buy = 0
Exit: long, chart timeframe is T1 or T2 AND Armed[1] = 1 AND Price * (1 - transaction cost) > entry price AND Price <= Trailing peak[1] * (1 - trailing distance / 100) AND (Price < EMA(close, shorter lookback)[Lag] OR Price <= EMA(close, longer lookback)[Lag] OR EMA(close, shorter lookback)[Lag] <= EMA(close, longer lookback)[Lag] OR EMA(close, longer lookback)[Lag] <= EMA(close, longer lookback)[Lag + slope lookback] OR Price <= Trailing peak[1] * (1 - trailing distance * weakness multiplier / 100)) AND Buy = 0
Exit: long, chart timeframe is T1 or T2 AND Buy = 0 AND Rise open = 1 AND Rebalances > Rebalances at the previous bar where Buy = 0 and Rise open = 1 AND Price * (1 - transaction cost) > entry price