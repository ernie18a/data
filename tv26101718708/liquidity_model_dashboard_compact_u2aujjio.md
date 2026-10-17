# Liquidity Model Dashboard (Compact)

- url: https://www.tradingview.com/script/u2aUjJIO-Liquidity-Model-Dashboard-Compact/
- type: indicator
- pine_id: PUB;83c9d34a33b847c5a5271cfa38189c10
- version: 1.0

## Description

new indicator by manny version 1 test cjbdscguiowergsioufre rijlgfhetir5ohgiehighei bfvbvoierboviberuiobvrbfkuer ierbvuioe vgjldfvoudbugiodrvf fdvbdusfbvulberuo fbjkrsedbfruigbheriuof

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dent3x

//@version=5
indicator("Liquidity Model Dashboard (Compact)", overlay=true)

//────────────────────────────
// HTF BIAS
//────────────────────────────
bull1h = request.security(syminfo.tickerid, "60", close > ta.ema(close, 50))
bear1h = request.security(syminfo.tickerid, "60", close < ta.ema(close, 50))

bull4h = request.security(syminfo.tickerid, "240", close > ta.ema(close, 50))
bear4h = request.security(syminfo.tickerid, "240", close < ta.ema(close, 50))

bullTrend = bull1h and bull4h
bearTrend = bear1h and bear4h

//────────────────────────────
// DISPLACEMENT
//────────────────────────────
body = math.abs(close - open)
avgBody = ta.sma(body, 20)

displacement = body > avgBody * 1.5

bullDisp = close > open and displacement
bearDisp = close < open and displacement

//────────────────────────────
// HTF FVG
//────────────────────────────
bearFVG_5m  = request.security(syminfo.tickerid, "5",  high < low[2])
bearFVG_15m = request.security(syminfo.tickerid, "15", high < low[2])

bullFVG_5m  = request.security(syminfo.tickerid, "5",  low > high[2])
bullFVG_15m = request.security(syminfo.tickerid, "15", low > high[2])

//────────────────────────────
// LTF INVERSION
//────────────────────────────
ltfBull =
     request.security(syminfo.tickerid, "1", low > high[2]) or
     request.security(syminfo.tickerid, "2", low > high[2]) or
     request.security(syminfo.tickerid, "3", low > high[2])

ltfBear =
     request.security(syminfo.tickerid, "1", high < low[2]) or
     request.security(syminfo.tickerid, "2", high < low[2]) or
     request.security(syminfo.tickerid, "3", high < low[2])

//────────────────────────────
// CONTINUATION MODEL
//────────────────────────────
contBull =
     bullTrend and
     (bearFVG_5m or bearFVG_15m) and
     bullDisp

contBear =
     bearTrend and
     (bullFVG_5m or bullFVG_15m) and
     bearDisp

contValid = contBull or contBear

//────────────────────────────
// MECH MODEL
//────────────────────────────
mechBull =
     (bullFVG_5m or bullFVG_15m) and
     bullDisp and
     ltfBear

mechBear =
     (bearFVG_5m or bearFVG_15m) and
     bearDisp and
     ltfBull

mechValid = mechBull or mechBear

//────────────────────────────
// GRADING
//────────────────────────────
Aplus = (mechValid or contValid) and bull1h == bull4h
A = mechValid or contValid
B = bullTrend or bearTrend

setup =
     Aplus ? "A+" :
     A ? "A" :
     B ? "B" :
     "NONE"

//────────────────────────────
// DASHBOARD
//────────────────────────────
var table panel = table.new(position.bottom_right, 1, 4)

bg =
     setup == "A+" ? color.green :
     setup == "A"  ? color.lime :
     setup == "B"  ? color.orange :
     color.gray

table.cell(panel, 0, 0, setup, bgcolor=bg)

table.cell(panel, 0, 1,
     mechValid ? "MECH" :
     contValid ? "CONT" :
     "NONE")

table.cell(panel, 0, 2,
     bullTrend ? "BULL" : "BEAR")

table.cell(panel, 0, 3,
     (bull1h and bull4h) ? "1H+4H OK" : "WEAK")

//────────────────────────────
// ALERTS
//────────────────────────────
alertcondition(Aplus, title="A+ Setup", message="A+ Setup Detected")
alertcondition(A, title="A Setup", message="A Setup Detected")
alertcondition(mechValid, title="MECH Model", message="MECH Trigger")
alertcondition(contValid, title="CONT Model", message="CONT Trigger")
````
