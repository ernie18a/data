<!-- tradingview-pine-id: PUB;ece2730e74044cf5a16822588c33585d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CORNELUS LA PIRAMIDE

Source: https://www.tradingview.com/script/GHZfDGjS-CORNELUS-LA-PIRAMIDE/

## Description

ATR Risk Dashboard (FX)

A minimal position-sizing dashboard for forex. It reads the ATR of the
current chart timeframe, converts it into a stop distance, and shows how
many lots you can trade while keeping the theoretical risk at or below a
fixed dollar amount.

Four lines, nothing else:

  ATR    - average true range in pips, current timeframe
  Stop   - ATR x multiplier, in pips
  Risk   - your dollar risk, entered manually
  Lots   - position size, rounded down to 0.01

HOW IT WORKS

1. ATR is calculated on whatever timeframe the chart is on. Nothing is
   hard-coded - switch from 5m to 1h and the numbers follow.

2. Stop distance = ATR x multiplier. This is a DISTANCE, not a price.
   The script draws no lines and places no orders.

3. Risk per lot = stop distance x units per lot x quote-currency rate.
   The quote currency is converted to USD automatically using
   request.currency_rate(), so the dollar figure is correct on USDJPY,
   GBPJPY, EURAUD, NZDCAD and any other cross - not just USD-quoted pairs.

4. Lots = risk / risk per lot, always rounded DOWN to 0.01.

EXAMPLE - EURUSD, ATR 4.5 pips, multiplier 1.5, risk $200

  Stop     = 4.5 x 1.5 = 6.75 pips (0.000675)
  Risk/lot = 0.000675 x 100,000 x 1 = $67.50
  Lots     = 200 / 67.50 = 2.962 -> 2.96

  2.96 x $67.50 = $199.80, at or below the $200 limit.

Displayed values are rounded to one decimal for readability, but the
sizing math uses the raw unrounded stop. A stop shown as "6.8" is
divided as 6.75.

SETTINGS

  ATR Length       default 14
  ATR Multiplier   default 1.5
  Risk $           default 500
  Units per Lot    default 100000 (standard lot)

For metals, set Units per Lot to 100 for XAUUSD or 5000 for XAGUSD.
Leave it at 100000 for all currency pairs.

NOTES

- Pip size is derived as mintick x 10, which handles JPY pairs correctly.
- Sizing is risk-based only. It does not check available margin - a valid
  lot size can still exceed what your leverage allows.
- Spread is not included in the stop. On very low timeframes the stop can
  be only a few pips, where spread is a significant share of the risk.
- The last bar updates live, so figures move until the bar closes.

Not financial advice. Position sizing is one input among many.

---

## Source Code

````pine
//@version=6
indicator("CORNELUS LA PIRAMIDE", overlay = true)

// ── Inputs ─────────────────────────────────────────────
atrLength = input.int(14,       "ATR Length",     minval = 1)
atrMult   = input.float(1.5,    "ATR Multiplier", minval = 0.1, step = 0.1)
riskUsd   = input.int(500,      "Risk $",         minval = 0,   step = 50)
lotUnits  = input.float(100000, "Units per Lot",  minval = 1)

// ── Conversia valutei de cotare în USD (scop global) ───
quoteToUsd = request.currency_rate(syminfo.currency, "USD")

// ── Calcule ────────────────────────────────────────────
pipSize   = syminfo.mintick * 10

atrPrice  = ta.atr(atrLength)                 // în preț, timeframe-ul curent
stopPrice = atrPrice * atrMult                // brut, nerotunjit

atrPips   = atrPrice  / pipSize
stopPips  = stopPrice / pipSize

riskPerLot = stopPrice * lotUnits * quoteToUsd     // $ pierduți la 1 lot

lots = na(riskPerLot) or riskPerLot <= 0 ? 0.0 : math.floor(riskUsd / riskPerLot * 100) / 100

// ── Dashboard ──────────────────────────────────────────
var table dash = table.new(position.top_right, 1, 4)

if barstate.islast
    txt = chart.fg_color
    table.cell(dash, 0, 0, na(atrPips)  ? "ATR n/a"  : "ATR "  + str.tostring(atrPips,  "0.0"),           text_color = txt, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 0, 1, na(stopPips) ? "Stop n/a" : "Stop " + str.tostring(stopPips, "0.0") + " pips", text_color = txt, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 0, 2, "Risk $" + str.tostring(riskUsd),          text_color = txt, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 0, 3, "Lots "  + str.tostring(lots, "0.00"),     text_color = txt, text_size = size.normal, text_halign = text.align_left)
````
