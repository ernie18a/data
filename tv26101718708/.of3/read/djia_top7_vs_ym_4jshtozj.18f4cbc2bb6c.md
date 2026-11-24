Calculation: component reference price = configured choice of the current session's first chart-bar open or previous session's last chart-bar close
Calculation: chart reference price = configured choice of the current T1 open or previous completed T1 close, carried onto chart bars
Calculation: component stock points = (component stock close − component reference price) / component-price divisor
Calculation: component aggregate points = sum of valid component stock points
Calculation: chart reference movement = close − chart reference price
Calculation: component aggregate gap points = sum of (component stock session open − previous session close) / component-price divisor
Calculation: chart gap points = current T1 open − previous completed T1 close, carried onto chart bars
Calculation: component VWAP balance = 100 × (sum of component weights for stocks above session VWAP − sum of component weights for stocks below session VWAP), where each weight is its reference price divided by the sum of valid positive component reference prices
Calculation: component advancing count = count of component stocks where close − reference price > breadth move threshold
Calculation: component declining count = count of component stocks where close − reference price < −breadth move threshold
Calculation: component session move (%) = 100 × (component stock close − session open) / session open
Calculation: component opening gap (%) = 100 × (session open − previous session close) / previous session close
Long: for a selected component stock, component stock points > 0
Short: for a selected component stock, component stock points < 0
Long: for a selected component stock, close > VWAP((high + low + close) / 3, volume, current session), evaluated on chart bars
Short: for a selected component stock, close ≤ VWAP((high + low + close) / 3, volume, current session), evaluated on chart bars
Long: for a selected component stock, close > VWAP((high + low + close) / 3, volume, previous session's last chart bar)
Short: for a selected component stock, close ≤ VWAP((high + low + close) / 3, volume, previous session's last chart bar)
Long: for a selected component stock with valid positive session open and previous session close, component session move (%) ≥ behavior threshold AND component opening gap (%) < −behavior threshold
Long: for a selected component stock with valid positive session open and previous session close, component session move (%) ≥ behavior threshold AND component opening gap (%) ≥ −behavior threshold
Short: for a selected component stock with valid positive session open and previous session close, component session move (%) ≤ −behavior threshold AND component opening gap (%) > behavior threshold
Short: for a selected component stock with valid positive session open and previous session close, component session move (%) ≤ −behavior threshold AND component opening gap (%) ≤ behavior threshold
Long: component aggregate points > 0
Short: component aggregate points < 0
Long: chart reference movement > 0
Short: chart reference movement < 0
Long: component advancing count > component declining count
Short: component declining count > component advancing count
Long: component VWAP balance > 0
Short: component VWAP balance < 0
Long: component aggregate gap points > 0
Short: component aggregate gap points < 0
Long: chart gap points > 0
Short: chart gap points < 0
Long: within the configured plotting session (or no session filter), valid component count ≥ minimum active component count AND selected smoothing (none, HMA, EMA, or SMA) of component aggregate points > 0 AND component VWAP balance > 0
Short: within the configured plotting session (or no session filter), valid component count ≥ minimum active component count AND selected smoothing (none, HMA, EMA, or SMA) of component aggregate points < 0 AND component VWAP balance < 0