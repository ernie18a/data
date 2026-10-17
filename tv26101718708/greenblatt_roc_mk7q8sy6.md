# Greenblatt ROC

- url: https://www.tradingview.com/script/mk7Q8Sy6-Greenblatt-ROC/
- type: indicator
- pine_id: PUB;5c19d318df054fd482e104c66cb0b989
- version: 1.0

## Description

TVs Net Working Capital doesnt really fit official numbers

## Source Code

````pine
//@version=5
indicator("Greenblatt ROC", overlay=false)

period = input.string("FY", "Periode", options=["FY", "FQ", "FH"])

ebit        = request.financial(syminfo.tickerid, "EBIT",                      period)
curr_assets = request.financial(syminfo.tickerid, "TOTAL_CURRENT_ASSETS",      period)
curr_liab   = request.financial(syminfo.tickerid, "TOTAL_CURRENT_LIABILITIES", period)
net_ppe     = request.financial(syminfo.tickerid, "PPE_TOTAL_NET",              period)

net_wc       = curr_assets - curr_liab
invested_cap = net_wc + net_ppe
roc          = invested_cap != 0 ? (ebit / invested_cap) * 100 : na

plot(roc, "Greenblatt ROC %", color=color.teal, linewidth=2)
hline(25, "25% Ziel",  color=color.lime,   linestyle=hline.style_dashed)
hline(0,  "Zero",      color=color.gray,   linestyle=hline.style_dashed)

var table t = table.new(position.top_right, 2, 4,
     bgcolor=color.new(color.black, 70), border_width=1)
if barstate.islast
    table.cell(t, 0, 0, "Greenblatt ROC", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 0, str.tostring(roc, "#.##") + " %",
               text_color = roc > 25 ? color.lime : roc > 0 ? color.yellow : color.red,
               text_size=size.small)
    table.cell(t, 0, 1, "EBIT",           text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, str.tostring(ebit/1e6, "#.#") + "M",
               text_color=color.white, text_size=size.small)
    table.cell(t, 0, 2, "Net WC",         text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(net_wc/1e6, "#.#") + "M",
               text_color = net_wc >= 0 ? color.lime : color.red, text_size=size.small)
    table.cell(t, 0, 3, "Net PPE",        text_color=color.white, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(net_ppe/1e6, "#.#") + "M",
               text_color=color.white, text_size=size.small)
````
