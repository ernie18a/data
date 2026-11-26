# DCA Credit Flow Proxy 

- url: https://www.tradingview.com/script/T5QTTJTS-DCA-Credit-Flow-Proxy/
- type: indicator
- pine_id: PUB;66210a8066594f949b9dfe9ca242bb3d
- version: 2.0

## Description

**Richard Werner's Credit Flow Proxy – ΔCF vs ΔCR**

This is an open-source indicator designed as a real-time proxy for Richard Werner’s **Quantity Theory of Credit**.

It approximates the split between:
- **ΔC_F** (financial/asset credit growth) → red line + orange histogram (real estate, financials, speculation → bubble risk)
- **ΔC_R** (productive/real-economy credit growth) → green line + green histogram (sustainable growth)

[b]**Key features:**[/b]
- All lines and the MACD-style histogram are centered on the same yellow zero line for easy reading
- Histogram: green above zero = productive credit lead (low risk), orange below zero = CF dominance (bubble risk)
- Minsky Instability line (purple) showing acceleration toward speculative/Ponzi phase
- Fully customizable with toggles and scaling options

**Important:**
This is a **proxy only**. PineScript cannot access actual bank credit data (Fed H.8, ECB lending surveys, etc.). It uses sector ETF relative growth rates (ROC) as the closest real-time approximation of Werner’s ΔC_F vs ΔC_R framework. Always cross-check with official monthly central bank credit data for confirmation.

No repainting. No guarantees. Purely educational and analytical.

[b]**How to use:**[/b]
Add to any broad market index (SPY, QQQ, ^SPX, ^STOXX50E, ^N225, etc.).  
- Green histogram + rising green line → productive credit dominant (more sustainable market move)  
- Orange histogram + rising red line → CF dominance (higher asset bubble risk)

[b]**How to create your own proxy (easy to fork):**[/b]
1. Change the tickers above to whatever sectors/index you want
2. Modify the `cf_proxy` line to include/exclude sectors
3. Adjust the `bubble_score` formula if you want different weighting
4. Turn `show_minsky` off if you want it cleaner

Feel free to fork this script and publish your own version!

Inspired by Richard Werner’s empirical research on bank money creation and the Quantity Theory of Credit.

## Source Code

````pine
//@version=6
indicator("Credit Flow Proxy – Werner's ΔCF vs ΔCR", shorttitle="DCA Proxy CF CR", overlay=false, precision=2)

// Tickers
broad_ticker   = input.symbol("SPY",     "Broad Market (SPY for SPX/QQQ)", group="Tickers")
fin_ticker     = input.symbol("XLF",      "Financials (CF proxy)", group="Tickers")
re_ticker      = input.symbol("XLRE",     "Real Estate (asset credit)", group="Tickers")
real_ticker    = input.symbol("XLI",      "Industrials (productive CR)", group="Tickers")
extra_cf       = input.symbol("XLK",      "Optional extra CF (tech/speculation)", group="Tickers")
use_extra_cf   = input.bool(false, "Include extra CF?", group="Tickers")

// Settings
len            = input.int(26, "Lookback (bars) – smaller = longer history", minval=10, group="Settings")
ema_len        = input.int(20, "Smoothing EMA", minval=10, group="Settings")
roc_len        = input.int(20, "ROC length for Δ (growth rate)", minval=5, group="Settings")
vol_mult       = input.float(1.4, "Volume surge multiplier", minval=1.0, group="Settings")
hist_scale     = input.float(2.0, "Histogram amplitude", minval=0.5, step=0.1, group="Display")
line_scale     = input.float(1.5, "CF/Productive line amplitude", minval=0.5, step=0.1, group="Display")

// Toggles
show_cf_prod   = input.bool(true,  "Show CF & Productive Lines", group="Display")
show_histogram = input.bool(true,  "Show MACD-style Bubble Histogram", group="Display")
show_minsky    = input.bool(true,  "Show Minsky Line", group="Display")
show_table     = input.bool(true,  "Show Info Table", group="Display")

// Data
b_close = request.security(broad_ticker, timeframe.period, close)
f_close = request.security(fin_ticker,   timeframe.period, close)
re_close= request.security(re_ticker,    timeframe.period, close)
r_close = request.security(real_ticker,  timeframe.period, close)
x_close = request.security(extra_cf,     timeframe.period, close)
b_vol   = request.security(broad_ticker, timeframe.period, volume)

// === MORE CORRECT MATH: Growth rates (Δ) to match Werner’s equations ===
cf_sum   = f_close + re_close + (use_extra_cf ? x_close : 0.0)
cf_count = use_extra_cf ? 3 : 2
cf_proxy = ta.roc(cf_sum / cf_count, roc_len)          // ΔCF
productive_proxy = ta.roc(r_close, roc_len)            // ΔCR

cf_mom   = ta.roc(cf_proxy, 20)
cf_accel = ta.roc(cf_mom, 10)
vol_surge = b_vol > ta.sma(b_vol, len) * vol_mult

// Bubble Score (your exact formula)
rel_strength = cf_proxy / productive_proxy
rel_hist     = ta.percentrank(rel_strength, len*2)
bubble_score = math.min(100, math.max(0, rel_hist * 1.2))
bubble_score := (cf_mom > 0 and vol_surge) ? bubble_score * 1.25 : bubble_score
bubble_score := bubble_score > 100 ? 100 : bubble_score

// Reversed histogram (green = productive lead) — your exact visual
bubble_dev   = 50 - bubble_score
bubble_hist  = bubble_dev * hist_scale

// Minsky (your exact code)
minsky_mom   = ta.percentrank(cf_mom, len*2)
minsky_score = (cf_accel > 0 and bubble_score > 50) ? math.min(100, minsky_mom * 1.35) : minsky_mom

// Centered plots — CF and CR lines now properly centered on yellow zero line
cf_dev       = cf_proxy * line_scale
prod_dev     = productive_proxy * line_scale
minsky_dev   = minsky_score - 50

// Plots — exactly as you wanted
plot(show_cf_prod ? cf_dev : na,         title="ΔCF (Asset Credit Growth)",          color=color.red,   linewidth=2)
plot(show_cf_prod ? prod_dev : na,       title="ΔCR (Productive Credit Growth)",      color=color.green, linewidth=2)
hline(0, title="Neutral / ZERO Line for ALL", color=color.yellow, linestyle=hline.style_dashed)

plot(show_histogram ? bubble_hist : na, title="Bubble Risk Histogram (MACD-style)", 
     color = bubble_dev >= 0 ? color.new(color.green, 80) : color.new(color.orange, 80), 
     linewidth=4, style=plot.style_histogram)

plot(show_minsky ? minsky_dev : na, title="Minsky Instability Line", color=color.new(color.purple, 40), linewidth=2)

// Signals & labels — your exact ones
bgcolor(bubble_score > 75 and vol_surge and cf_mom > 0 ? color.new(color.red, 85) : na)
bgcolor(minsky_score > 75 ? color.new(color.purple, 90) : na)

plotshape(show_minsky and ta.crossover(minsky_score, 75), title="Minsky Warning", location=location.top, color=color.purple, style=shape.triangledown, size=size.tiny, text="M")
plotshape(bubble_score > 80 and ta.crossunder(cf_proxy, ta.ema(cf_proxy, 30)), title="CF Peak", location=location.top, color=color.red, style=shape.triangledown, size=size.tiny, text="CF ↓")
plotshape(bubble_score < 35 and ta.crossover(productive_proxy, 0), title="Productive Rebound", location=location.bottom, color=color.green, style=shape.triangleup, size=size.tiny, text="CR ↑")

// Intuitive Table — your exact table
var table info = table.new(position.top_right, 1, 7, bgcolor=color.new(color.black, 85), border_width=1)
if barstate.islast and show_table
    bubble_text = bubble_score > 70 ? "HIGH BUBBLE RISK (CF dominant)" : bubble_score > 50 ? "Moderate Risk" : "LOW RISK – Productive Lead"
    bubble_color = bubble_score > 70 ? color.red : bubble_score > 50 ? color.orange : color.lime
    
    minsky_text = minsky_score > 75 ? "HIGH PONZI RISK" : minsky_score > 50 ? "Building Instability" : "Stable"
    minsky_color = minsky_score > 75 ? color.purple : minsky_score > 50 ? color.orange : color.lime
    
    table.cell(info, 0, 0, "Proxy CF CR", text_color=color.white, text_size=size.normal)
    table.cell(info, 0, 1, bubble_text, text_color=bubble_color)
    table.cell(info, 0, 2, minsky_text, text_color=minsky_color)
    table.cell(info, 0, 3, "Histogram: " + (bubble_dev >= 0 ? "↑ Productive" : "↓ CF Bubble"), text_color=bubble_dev >= 0 ? color.lime : color.orange)
    table.cell(info, 0, 4, "Minsky Line: " + str.tostring(math.round(minsky_score)), text_color=minsky_color)
    table.cell(info, 0, 5, "Use Weekly with real Fed H.8 data", text_color=color.gray)
    table.cell(info, 0, 6, "Proxy only – now uses Δ growth rates", text_color=color.gray)

// Alerts
alertcondition(bubble_score > 80 and vol_surge and cf_mom > 0, "CF Bubble Alert", "Werner CF dominance high → asset bubble risk")
alertcondition(ta.crossover(minsky_score, 75), "Minsky Instability Alert", "CF momentum accelerating → Ponzi phase warning")
````
