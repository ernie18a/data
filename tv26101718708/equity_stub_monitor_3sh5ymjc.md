# Equity Stub Monitor

- url: https://www.tradingview.com/script/3sh5ymjC-Equity-Stub-Monitor/
- type: indicator
- pine_id: PUB;d6c067b060b449188dad8b681a160f2d
- version: 1.0

## Description

MarketCap as % of Enterprise Value, giving you an idea how the equity is valued in relation to its cash or debt position.

## Source Code

````pine
//@version=6
indicator("Equity Stub Monitor", shorttitle="EqStub", format=format.percent, precision=1)

// ─── Inputs ───────────────────────────────────────────────────────────────────
// Die Schwellenwerte beziehen sich auf den Anteil der Marktkapitalisierung am Enterprise Value (EV).
danger_pct = input.float(20.0, title="Danger Zone – MktCap % of EV", minval=1, maxval=100)
warn_pct   = input.float(40.0, title="Warning Zone – MktCap % of EV", minval=1, maxval=100)

// ─── Financial Data ───────────────────────────────────────────────────────────
tso        = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ")
total_debt = request.financial(syminfo.tickerid, "TOTAL_DEBT",               "FQ")
cash       = request.financial(syminfo.tickerid, "CASH_N_EQUIVALENTS",        "FQ")

// ─── Core Calculations ────────────────────────────────────────────────────────
mktcap   = not na(tso) ? tso * close : na
net_debt = not na(total_debt) and not na(cash) ? total_debt - cash : na
ev       = not na(mktcap) and not na(net_debt) ? mktcap + net_debt : na

// Marktkapitalisierung als % von EV – Die entscheidende Metrik für den Equity Stub
mc_pct_ev = not na(mktcap) and not na(ev) and ev > 0 ? (mktcap / ev) * 100 : na

// ─── Farbe nach Danger Zone ───────────────────────────────────────────────────
mc_color = color.new(color.teal, 20)
if not na(mc_pct_ev)
    if mc_pct_ev < danger_pct
        mc_color := color.new(color.red, 20)
    else if mc_pct_ev < warn_pct
        mc_color := color.new(color.orange, 20)

// ─── Plots ────────────────────────────────────────────────────────────────────
plot(mc_pct_ev, title="MktCap % of EV", color=mc_color, style=plot.style_area, linewidth=2)

// ─── Reference Lines ──────────────────────────────────────────────────────────
hline(danger_pct, "Danger Zone",  color=color.red,    linestyle=hline.style_dashed, linewidth=1)
hline(warn_pct,   "Warning Zone", color=color.orange, linestyle=hline.style_dashed, linewidth=1)
hline(100,        "100%",         color=color.gray,   linestyle=hline.style_dotted, linewidth=1)

// ─── Tracking: Datenhistorie pro Quartal ──────────────────────────────────────
var string last_period = ""
cur_period = str.tostring(year) + " Q" + str.tostring(math.ceil(month / 3))

var string[] per_h  = array.new_string()
var float[]  ev_h   = array.new_float()
var float[]  mc_h   = array.new_float()
var float[]  nd_h   = array.new_float()
var float[]  pct_h  = array.new_float()

if not na(mc_pct_ev) and cur_period != last_period
    last_period := cur_period
    array.push(per_h,  cur_period)
    array.push(ev_h,   na(ev)       ? 0.0 : ev)
    array.push(mc_h,   na(mktcap)   ? 0.0 : mktcap)
    array.push(nd_h,   na(net_debt) ? 0.0 : net_debt)
    array.push(pct_h,  na(mc_pct_ev) ? 0.0 : mc_pct_ev)

// ─── Formatierung ─────────────────────────────────────────────────────────────
fmt(float v) => 
    val_abs = math.abs(v)
    val_abs >= 1e9 ? str.tostring(math.round(v / 1e9, 2)) + " B" : 
     val_abs >= 1e6 ? str.tostring(math.round(v / 1e6, 1)) + " M" : 
     str.tostring(math.round(v, 2))

// ─── Tabelle (Positionierung links oben) ──────────────────────────────────────
var table t1 = table.new(position.top_left, 5, 33,
     bgcolor=color.new(color.black, 80), border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast
    table.cell(t1, 0, 0, "Periode",    text_color=color.gray, text_size=size.small)
    table.cell(t1, 1, 0, "EV",         text_color=color.gray, text_size=size.small)
    table.cell(t1, 2, 0, "Mkt Cap",    text_color=color.gray, text_size=size.small)
    table.cell(t1, 3, 0, "Net Debt",   text_color=color.gray, text_size=size.small)
    table.cell(t1, 4, 0, "MC % of EV", text_color=color.gray, text_size=size.small)

    n = array.size(per_h)
    if n > 0
        for i = 0 to math.min(31, n - 1)
            idx     = n - 1 - i
            row     = i + 1
            pct_val = array.get(pct_h, idx)

            row_col = color.white
            if pct_val < danger_pct
                row_col := color.new(color.red, 20)
            else if pct_val < warn_pct
                row_col := color.new(color.orange, 20)

            table.cell(t1, 0, row, array.get(per_h, idx),          text_color=color.white, text_size=size.normal)
            table.cell(t1, 1, row, fmt(array.get(ev_h, idx)),      text_color=color.white, text_size=size.normal)
            table.cell(t1, 2, row, fmt(array.get(mc_h, idx)),      text_color=color.white, text_size=size.normal)
            table.cell(t1, 3, row, fmt(array.get(nd_h, idx)),      text_color=color.white, text_size=size.normal)
            table.cell(t1, 4, row, str.tostring(math.round(pct_val, 1)) + " %", text_color=row_col, text_size=size.normal)
````
