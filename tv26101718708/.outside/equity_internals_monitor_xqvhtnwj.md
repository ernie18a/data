# Equity Internals Monitor

- url: https://www.tradingview.com/script/xQvHtNwJ-Equity-Internals-Monitor/
- type: indicator
- pine_id: PUB;94ab17c074124752838d9831a702b6c5
- version: 3.0

## Description

This indicator uses 3 Ratios for intraday trading with the ES. 
NQ/ES
RTY/ES
HYG/IEF
  
CONV ON: Bullish 
CONV OFF: Bearish
NARROW: Possible fade into strength
CREDIT: Credit leading equities lower
NO LEAD: Neutral

## Source Code

````pine
//@version=6
indicator("Equity Internals + 10Y (Simplified)", shorttitle="EIM5", overlay=false, max_labels_count=500)

// =============================================================================
// INPUTS
// =============================================================================
es_sym   = input.symbol("CME_MINI:ES1!", "ES")
nq_sym   = input.symbol("CME_MINI:NQ1!", "NQ (leadership)")
rty_sym  = input.symbol("CME_MINI:RTY1!","RTY (breadth)")
hyg_sym  = input.symbol("AMEX:HYG",      "HYG (credit)")
ief_sym  = input.symbol("NASDAQ:IEF",    "IEF (duration)")
tnx_sym  = input.symbol("TVC:TNX",       "10Y Yield")

ma_slow      = input.int(50,  "MA length", minval=5)
roc_len      = input.int(10,  "ROC lookback", minval=2)
roc_thresh   = input.float(0.15, "Equity ROC threshold (%)", minval=0.01, step=0.05)
yld_roc_len  = input.int(10,  "Yield ROC lookback", minval=2)
yld_thresh   = input.float(0.3, "Yield ROC threshold (%)", minval=0.05, step=0.05)
show_table   = input.bool(true, "Show status table")
show_bg      = input.bool(true, "Show regime background")
show_yield   = input.bool(true, "Plot 10Y yield line")
show_markers = input.bool(true, "Show regime markers on chart")

// =============================================================================
// DATA
// =============================================================================
es  = request.security(es_sym,  timeframe.period, close)
nq  = request.security(nq_sym,  timeframe.period, close)
rty = request.security(rty_sym, timeframe.period, close)
hyg = request.security(hyg_sym, timeframe.period, close)
ief = request.security(ief_sym, timeframe.period, close)
tnx = request.security(tnx_sym, timeframe.period, close)

// =============================================================================
// RATIOS & NORMALIZATION
// =============================================================================
nq_es   = nq  / es
rty_es  = rty / es
hyg_ief = hyg / ief

norm(float src, int len) =>
    ma = ta.sma(src, len)
    ma == 0 ? 0.0 : (src - ma) / ma * 100

n_nq_es   = norm(nq_es,   ma_slow)
n_rty_es  = norm(rty_es,  ma_slow)
n_hyg_ief = norm(hyg_ief, ma_slow)
n_tnx     = norm(tnx,     ma_slow)

// =============================================================================
// RATE OF CHANGE
// =============================================================================
roc_nq_es   = ta.roc(nq_es,   roc_len)
roc_rty_es  = ta.roc(rty_es,  roc_len)
roc_hyg_ief = ta.roc(hyg_ief, roc_len)
roc_es      = ta.roc(es,      roc_len)
roc_tnx     = ta.roc(tnx,     yld_roc_len)

// =============================================================================
// REGIME LOGIC
// =============================================================================
es_up   = roc_es >  roc_thresh
es_down = roc_es < -roc_thresh

confirm_up   = (roc_nq_es > 0 ? 1 : 0) + (roc_rty_es > 0 ? 1 : 0) + (roc_hyg_ief > 0 ? 1 : 0)
confirm_down = (roc_nq_es < 0 ? 1 : 0) + (roc_rty_es < 0 ? 1 : 0) + (roc_hyg_ief < 0 ? 1 : 0)

yld_rising  = roc_tnx >  yld_thresh
yld_falling = roc_tnx < -yld_thresh

risk_on      = es_up   and confirm_up   >= 2
risk_off     = es_down and confirm_down >= 2
hollow_rally = es_up   and confirm_up   <  2
credit_warn  = roc_hyg_ief < -roc_thresh * 2
liquidation  = es_down and yld_rising

regime_text = liquidation     ? "LIQUIDATION"   :
              credit_warn     ? "CREDIT WARN"   :
              risk_off        ? "RISK-OFF"      :
              hollow_rally    ? "HOLLOW RALLY"  :
              risk_on and yld_rising  ? "RISK-ON-D" :
              risk_on and yld_falling ? "RISK-ON-F" :
              risk_on         ? "RISK-ON"       : "NEUTRAL"

regime_color = liquidation     ? color.maroon  :
               credit_warn     ? color.orange  :
               risk_off        ? color.red     :
               hollow_rally    ? color.yellow  :
               risk_on         ? color.lime    : color.gray

regime_changed = regime_text != regime_text[1]

// =============================================================================
// PLOTS
// =============================================================================
plot(n_nq_es,   "NQ/ES",   color=color.new(color.aqua,    0), linewidth=2)
plot(n_rty_es,  "RTY/ES",  color=color.new(color.orange,  0), linewidth=2)
plot(n_hyg_ief, "HYG/IEF", color=color.new(color.fuchsia, 0), linewidth=2)
plot(show_yield ? n_tnx : na, "10Y", color=color.new(color.white, 0), linewidth=1)

hline(0, "Zero", color=color.new(color.gray, 50))

bgcolor(show_bg and risk_on      ? color.new(color.lime,   88) : na, title="Risk-on bg")
bgcolor(show_bg and risk_off     ? color.new(color.red,    85) : na, title="Risk-off bg")
bgcolor(show_bg and hollow_rally ? color.new(color.yellow, 88) : na, title="Hollow rally bg")
bgcolor(show_bg and credit_warn  ? color.new(color.orange, 82) : na, title="Credit warn bg")
bgcolor(show_bg and liquidation  ? color.new(color.maroon, 75) : na, title="Liquidation bg")

// =============================================================================
// REGIME MARKERS — plotshape with text (more reliable than labels in panes)
// One plotshape per regime, anchored to top of pane
// =============================================================================
// =============================================================================
// REGIME MARKERS — plotshape with text (more reliable than labels in panes)
// Bearish regimes stacked ABOVE zero, bullish regimes stacked BELOW zero
// =============================================================================
// Track pane extremes to position markers in the right zones
var float pane_top = 0.0
var float pane_bot = 0.0
pane_top := math.max(nz(pane_top), nz(n_nq_es), nz(n_rty_es), nz(n_hyg_ief), nz(n_tnx))
pane_bot := math.min(nz(pane_bot), nz(n_nq_es), nz(n_rty_es), nz(n_hyg_ief), nz(n_tnx))

// Bearish lanes ABOVE zero, stacked top-down by severity
y_liquidation  = pane_top + 3.2  // most bearish, highest
y_credit       = pane_top + 2.4
y_risk_off     = pane_top + 1.6
y_hollow       = pane_top + 0.8  // mildly bearish, closest to zero

// Bullish lanes BELOW zero, stacked top-down by conviction
y_risk_on_d    = pane_bot - 0.8  // most bullish (durable), closest to zero from below
y_risk_on      = pane_bot - 1.6  // neutral risk-on
y_risk_on_f    = pane_bot - 2.4  // fragile, lowest (least conviction)

plotshape(show_markers and regime_changed and liquidation ? y_liquidation : na,
     title="Liquidation marker", text="LIQ", textcolor=color.white,
     style=shape.labeldown, location=location.absolute, color=color.maroon, size=size.tiny)

plotshape(show_markers and regime_changed and credit_warn and not liquidation ? y_credit : na,
     title="Credit warn marker", text="CRED", textcolor=color.white,
     style=shape.labeldown, location=location.absolute, color=color.orange, size=size.tiny)

plotshape(show_markers and regime_changed and risk_off and not credit_warn and not liquidation ? y_risk_off : na,
     title="Risk-off marker", text="OFF", textcolor=color.white,
     style=shape.labeldown, location=location.absolute, color=color.red, size=size.tiny)

plotshape(show_markers and regime_changed and hollow_rally and not credit_warn ? y_hollow : na,
     title="Hollow rally marker", text="HOLL", textcolor=color.black,
     style=shape.labeldown, location=location.absolute, color=color.yellow, size=size.tiny)

plotshape(show_markers and regime_changed and risk_on and yld_rising ? y_risk_on_d : na,
     title="Risk-on durable marker", text="ON-D", textcolor=color.white,
     style=shape.labelup, location=location.absolute, color=color.lime, size=size.tiny)

plotshape(show_markers and regime_changed and risk_on and yld_falling ? y_risk_on_f : na,
     title="Risk-on fragile marker", text="ON-F", textcolor=color.black,
     style=shape.labelup, location=location.absolute, color=color.olive, size=size.tiny)

plotshape(show_markers and regime_changed and risk_on and not yld_rising and not yld_falling ? y_risk_on : na,
     title="Risk-on marker", text="ON", textcolor=color.white,
     style=shape.labelup, location=location.absolute, color=color.green, size=size.tiny)

// =============================================================================
// STATUS TABLE (with big regime banner at top)
// =============================================================================
trend_arrow(float v, float t) => v >  t ? "▲" : v < -t ? "▼" : "→"
trend_color(float v, float t) => v >  t ? color.lime : v < -t ? color.red : color.gray

var table tbl = table.new(position.top_right, 3, 8, border_width=1)
if show_table and barstate.islast
    table.cell(tbl, 0, 0, "REGIME", bgcolor=color.new(color.black, 30), text_color=color.white, text_size=size.normal)
    table.merge_cells(tbl, 1, 0, 2, 0)
    table.cell(tbl, 1, 0, regime_text, bgcolor=regime_color, text_color=color.white, text_size=size.large)

    table.cell(tbl, 0, 1, "Indicator", bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(tbl, 1, 1, "ROC%",      bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(tbl, 2, 1, "Trend",     bgcolor=color.new(color.gray, 70), text_color=color.white)

    table.cell(tbl, 0, 2, "NQ/ES",     text_color=color.white)
    table.cell(tbl, 1, 2, str.tostring(roc_nq_es, "#.00"),  text_color=trend_color(roc_nq_es, roc_thresh))
    table.cell(tbl, 2, 2, trend_arrow(roc_nq_es, roc_thresh), text_color=trend_color(roc_nq_es, roc_thresh))

    table.cell(tbl, 0, 3, "RTY/ES",    text_color=color.white)
    table.cell(tbl, 1, 3, str.tostring(roc_rty_es, "#.00"), text_color=trend_color(roc_rty_es, roc_thresh))
    table.cell(tbl, 2, 3, trend_arrow(roc_rty_es, roc_thresh), text_color=trend_color(roc_rty_es, roc_thresh))

    table.cell(tbl, 0, 4, "HYG/IEF",   text_color=color.white)
    table.cell(tbl, 1, 4, str.tostring(roc_hyg_ief, "#.00"), text_color=trend_color(roc_hyg_ief, roc_thresh))
    table.cell(tbl, 2, 4, trend_arrow(roc_hyg_ief, roc_thresh), text_color=trend_color(roc_hyg_ief, roc_thresh))

    table.cell(tbl, 0, 5, "ES",        text_color=color.white)
    table.cell(tbl, 1, 5, str.tostring(roc_es, "#.00"), text_color=trend_color(roc_es, roc_thresh))
    table.cell(tbl, 2, 5, trend_arrow(roc_es, roc_thresh), text_color=trend_color(roc_es, roc_thresh))

    table.cell(tbl, 0, 6, "10Y yield", text_color=color.white)
    table.cell(tbl, 1, 6, str.tostring(roc_tnx, "#.00"), text_color=trend_color(roc_tnx, yld_thresh))
    table.cell(tbl, 2, 6, trend_arrow(roc_tnx, yld_thresh), text_color=trend_color(roc_tnx, yld_thresh))

    data_ok = not (na(es) or na(nq) or na(rty) or na(hyg) or na(ief) or na(tnx))
    table.cell(tbl, 0, 7, "Data", text_color=color.white)
    table.merge_cells(tbl, 1, 7, 2, 7)
    table.cell(tbl, 1, 7, data_ok ? "all sources OK" : "MISSING DATA",
               bgcolor=data_ok ? color.new(color.green, 60) : color.new(color.red, 30),
               text_color=color.white)

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(risk_on,      title="RISK-ON",       message="Risk-on: ES rallying with internal confirmation. Check yield direction for durable vs fragile.")
alertcondition(risk_off,     title="RISK-OFF",      message="Risk-off: ES selling with internal confirmation. Defensive posture warranted.")
alertcondition(hollow_rally, title="HOLLOW RALLY",  message="ES up but internals not confirming. Narrow/low-quality tape, fade strength into resistance.")
alertcondition(credit_warn,  title="CREDIT WARNING",message="HYG/IEF breaking down sharply. Credit leading equities lower, expect ES to follow.")
alertcondition(liquidation,  title="LIQUIDATION",   message="ES down with yields rising — no safe haven bid. Forced selling / hawkish regime, worst tape.")
````
