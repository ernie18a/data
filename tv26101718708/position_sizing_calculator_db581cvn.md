# Position Sizing Calculator

- url: https://www.tradingview.com/script/db581CVn/
- type: indicator
- pine_id: PUB;158a612055924692bbfef2c8ece3ffd6
- version: 1.0

## Description

A simple automated calculator that shows how many shares can be bought or sold if a specific maximum amount is to be risked on the position. 

The risk per share is assumed to be the distance to the respective buy or sell line of the Supertrend indicator. This is based on a calculation of the ATR for the last ten days, which is multiplied by a fixed factor and plotted against the highest or lowest candle of the past ten days. 

The parameters can be changed manually. By default, a risk of $500 per trade is assumed. 

For each of the last bars, the calculator displays the distance to the calculated exit and, through a simple division, calculates the number of shares that could be bought or sold in a potential long or short position to achieve this hypothetical maximum risk. 

Of course, there is no guarantee that the respective price will actually be reached, but the calculator can help provide a reference point for sizing the position.

The principle is clearly visible in the screenshots: FRT is a stock that moves slowly and is only a short distance from the stop-loss level. At the current price of $114.47 and a calculated stop at $108.99, 91 shares could be purchased to risk $500. In total, that would be an order of $10,416.77 for a long position.

SOUN, on the other hand, has a very wide margin to the stop-loss; it is a stock with high volatility. Therefore, only 300 shares can be purchased here to achieve the same hypothetical risk. The position would thus be worth only $2,841.

Designed by tuvot_1a, programmed by Claude.

## Source Code

````pine
//@version=6
// ============================================================
// Position Sizing -- Supertrend-basiert
// Version: v1.3 -- 2026-05-05
//
// Berechnet zwei unabhaengige Supertrend-Levels:
// Long-Stop:  immer unterhalb des Kurses (trailing up)
// Short-Stop: immer oberhalb des Kurses (trailing down)
// Beide unabhaengig vom aktuellen Trend
// ============================================================

indicator("Position Sizing", shorttitle="Position Sizing Calculator", overlay=true)

// -- Inputs --------------------------------------------------
risk_usd   = input.float(500, "$ at Risk", minval=10, step=50)
atr_len    = input.int(10,    "ATR Periode", minval=1)
st_mult    = input.float(3.0, "ST Multiplikator", minval=0.5, step=0.5)
offset_pct = input.float(2.0, "Abstand Label (%)", minval=0.5, step=0.5)

// -- ATR -----------------------------------------------------
atr_val = ta.atr(atr_len)
src     = hl2

// -- Long-Stop: immer unter dem Kurs -------------------------
// Trailing upwards -- steigt mit dem Kurs, faellt nie
long_stop_raw  = src - st_mult * atr_val
var float long_stop = na
long_stop := na(long_stop[1]) ? long_stop_raw :
             close > long_stop[1] ? math.max(long_stop_raw, long_stop[1]) :
             long_stop_raw

// -- Short-Stop: immer ueber dem Kurs ------------------------
// Trailing downwards -- faellt mit dem Kurs, steigt nie
short_stop_raw  = src + st_mult * atr_val
var float short_stop = na
short_stop := na(short_stop[1]) ? short_stop_raw :
              close < short_stop[1] ? math.min(short_stop_raw, short_stop[1]) :
              short_stop_raw

// -- Sizing --------------------------------------------------
long_risk  = close - long_stop
short_risk = short_stop - close

shares_long  = long_risk  > 0.01 ? math.floor(risk_usd / long_risk)  : na
shares_short = short_risk > 0.01 ? math.floor(risk_usd / short_risk) : na

// -- Labels --------------------------------------------------
col = color.new(color.silver, 20)

if barstate.islast
    // Long: unterhalb Long-Stop
    if not na(shares_long) and long_risk > 0
        label.new(
          bar_index,
          long_stop * (1 - offset_pct / 100),
          "L: " + str.tostring(shares_long) + " Sh  $" + str.tostring(math.round(long_risk, 2)) + "/Sh",
          style     = label.style_label_up,
          color     = color.new(color.gray, 80),
          textcolor = col,
          size      = size.normal
        )

    // Short: oberhalb Short-Stop
    if not na(shares_short) and short_risk > 0
        label.new(
          bar_index,
          short_stop * (1 + offset_pct / 100),
          "S: " + str.tostring(shares_short) + " Sh  $" + str.tostring(math.round(short_risk, 2)) + "/Sh",
          style     = label.style_label_down,
          color     = color.new(color.gray, 80),
          textcolor = col,
          size      = size.normal
        )

// ============================================================
// Position Sizing -- v1.3 -- 2026-05-05
// ============================================================
````
