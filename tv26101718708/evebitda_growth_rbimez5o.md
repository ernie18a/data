# (EV/EBITDA) / Growth

- url: https://www.tradingview.com/script/RBImEz5o-EV-EBITDA-Growth/
- type: indicator
- pine_id: PUB;0c0b94eace1746cc8753be06e53d91b4
- version: 4.0

## Description

Building blocks
Component	What it means
EV (Enterprise Value)	Market Cap + Debt + Minority Interest − Cash — the true cost to buy the whole company
EBITDA	Earnings Before Interest, Tax, Depreciation & Amortisation — a proxy for operating cash flow
EV/EBITDA	How many years of operating earnings you're paying — a valuation multiple
Growth	YoY % change in EBITDA (or Revenue) — how fast the company is expanding
The problem it solves
EV/EBITDA alone is incomplete.

A company at EV/EBITDA = 20x growing at 40%/yr → cheap
A company at EV/EBITDA = 10x growing at 2%/yr → expensive
EVEG captures this by dividing the multiple by the growth rate.

How to read it
EVEG	Interpretation
< 1	🟢 Undervalued relative to growth
= 1	🟡 Fairly valued
> 2	🔴 Expensive relative to growth
Negative	⚠️ Negative growth — ratio loses meaning
Simple example
EV/EBITDA = 15x
EBITDA Growth = 30%
EVEG = 15 ÷ 30 = 0.5 → 🟢 Cheap for its growth rate

These are three different ways to calculate (EV/EBITDA) ÷ Growth, each using a different time period for the EBITDA denominator:

EVEG @ FY — Fiscal Year
Uses annual EBITDA (last full fiscal year)
Most stable, least noisy
Best for long-term valuation comparison
Growth = YoY change in annual EBITDA
EVEG @ TTM — Trailing Twelve Months
Uses last 12 months of EBITDA (rolling)
Most current/real-time view
Reacts faster to recent earnings changes
Growth = YoY change in TTM EBITDA
EVEG @ FQ — Fiscal Quarter
Uses a blended formula: ebitda_fq + (ebitda_ttm × 3/4)
This was Lorenzo's original formula — it mixes the latest quarter with TTM to smooth out single-quarter spikes
Most granular but also most volatile
Growth still uses FY growth rate as the divisor
Which to trust?
Signal	Best Use
FY	Long-term investors, annual screening
TTM	Most balanced — current but smoothed
FQ	Short-term traders, catching turning points early
When all three are aligned and low (< 1), that's the strongest signal of undervaluation relative to growth.

## Source Code

````pine
//@version=6
indicator("EV/Ebitda/Growth FQ", overlay=false)

c_ee_fq = input.color(color.green, title="EV/Ebitda/Growth @ FQ")

EV         = request.financial(syminfo.tickerid, "ENTERPRISE_VALUE", "FQ")
ebitda_ttm = request.financial(syminfo.tickerid, "EBITDA",           "TTM")

fq_period = request.financial(syminfo.tickerid, "ENTERPRISE_VALUE", "FQ", gaps=barmerge.gaps_on)
is_new_fq = not na(fq_period)

// ── EBITDA YoY growth (TTM now vs TTM 4 quarters ago) ────────────────────────
ebitda_4q_ago = ta.valuewhen(is_new_fq, ebitda_ttm, 4)
ebitda_growth = (ebitda_ttm - ebitda_4q_ago) / math.abs(ebitda_4q_ago) * 100

// ── (EV/EBITDA) / Growth ─────────────────────────────────────────────────────
EV_ebitda_fq     = EV / ebitda_ttm
EV_ebitda_growth = ebitda_growth != 0 ? EV_ebitda_fq / ebitda_growth : na

fq_val      = ta.valuewhen(is_new_fq, EV_ebitda_growth, 0)
prev_fq_val = ta.valuewhen(is_new_fq, fq_val,           1)
pct         = (fq_val - prev_fq_val) / math.abs(prev_fq_val) * 100

plot(fq_val, color=c_ee_fq, style=plot.style_stepline, linewidth=2)
hline(0, title="Zero", color=color.gray, linestyle=hline.style_dotted)

var int last_q     = na
var int last_fq_yr = na

if is_new_fq and not na(fq_val) and not na(prev_fq_val)
    mon = month(time)
    yr  = year(time)

    // mon 12, 1, 2  → Dec quarter (Q4)
    // mon 3,  4, 5  → Mar quarter (Q1)
    // mon 6,  7, 8  → Jun quarter (Q2)
    // mon 9, 10, 11 → Sep quarter (Q3)
    fq_q  = mon == 12 ? 4 : mon <= 2 ? 4 : mon <= 5 ? 1 : mon <= 8 ? 2 : 3
    fq_yr = mon <= 2 ? yr - 1 : yr

    if na(last_q) or fq_q != last_q or fq_yr != last_fq_yr
        last_q     := fq_q
        last_fq_yr := fq_yr

        yr2      = fq_yr % 100
        mon_str  = fq_q == 4 ? "Dec" : fq_q == 1 ? "Mar" : fq_q == 2 ? "Jun" : "Sep"
        yr_str   = yr2 < 10 ? "0" + str.tostring(yr2) : str.tostring(yr2)
        date_str = mon_str + " '" + yr_str
        pct_str  = (pct >= 0 ? "(+" : "(") + str.tostring(pct, "#.##") + "%)"
        label.new(bar_index, fq_val,
             text      = str.tostring(fq_val, "#.##") + "\n" + pct_str + "\n" + date_str,
             style     = label.style_label_down,
             yloc      = yloc.price,
             color     = c_ee_fq,
             textcolor = color.white,
             size      = size.small)
````
