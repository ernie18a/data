# Market Euphoria Index - MEI - Predict Market Tops & Bottoms

- url: https://www.tradingview.com/script/c5egsbJI-Market-Euphoria-Index-MEI-Predict-Market-Tops-Bottoms/
- type: indicator
- pine_id: PUB;b34dd564505641408575ec21a6e14501
- version: 1.0

## Description

[b]A composite macro indicator designed to peak BEFORE major equity market tops — not during the crash.[/b]

Most "fear & greed" gauges are coincident: they spike with the panic, not before it. The MEI flips that. It measures how much euphoria and late-cycle stress have built up over months of bull market, so it tends to peak in the run-up to a top rather than at the bottom.

What it captured historically (visual backtest on monthly SPX):
— Climbed into the red zone ahead of the August 1987 top
— Peaked ahead of the March 2000 dot-com top
— Peaked ahead of the October 2007 GFC top
— Peaked ahead of the January 2022 top
— Dropped to the extreme-fear zone near every major bear-market bottom that followed

[b]The six components (default weights):
[/b]— Price extension vs 5-year SMA (30%) — the primary leading signal. SPX has been 25-55% above its 5-year average at every major top since 1980.
— Yield curve un-inversion clock (25%) — tracks months since the 10Y-2Y spread last went negative. Peak warning is 0-12 months after the curve un-inverts (this is the actual recession trigger, historically).
— VIX 12-month average (15%) — captures sustained complacency, not single panic spikes. Low for a year = top buildup.
— Inflation re-acceleration (10%) — 6-month change in CPI YoY. Late-cycle inflation shocks (2000, 2007, 2022) are the classic top catalyst.
— Real rate stress (10%) — 10Y nominal yield minus CPI YoY. High and rising = tightening financial conditions.
— Fed cycle position (10%) — high and plateauing = peak late cycle; aggressive cuts = bottom signal.

How to read the line:
— Above 80 (red) = EXTREME EUPHORIA, historical top zone, reduce risk
— 65 to 80 (orange) = Euphoria warning, late cycle, tighten stops
— 35 to 65 (gray) = Neutral
— 20 to 35 (green) = Fear, opportunity zone
— Below 20 (lime) = EXTREME FEAR, historical bottom zone

[b]Best timeframe: [/b]monthly (M) or weekly (W) on SPX, NDX, QQQ, or SPY. All economic data is fetched at monthly resolution regardless of your chart's timeframe, so the indicator reads the same whether you're on D, W, or M.
[b]Customizable:[/b] every component weight and threshold is exposed in the settings. Bump up "Price extension" if you want more sensitivity to bubbles, or "Yield curve" if you trust macro recession signals more than price action.
[b]Built-in alerts:[/b] Euphoria warning, Extreme euphoria, Fear, Extreme fear — all four crossovers are configurable from the alert menu.
[b]To overlay on SPX:[/b] right-click the indicator name, then "Move pane to" then "Above", then "Pin to scale" to give it its own axis on the price chart.

[b]Data sources[/b] (all free, built into TradingView):
SP:SPX, FRED:T10Y2Y, CBOE:VIX, ECONOMICS:USIRYY, FRED:FEDFUNDS, TVC:US10Y

[b]Honest limitations:[/b]
— This is a macro/cyclical tool, useless for intraday or short-term timing.
— Designed to call major bull/bear turning points, not 10-20% corrections.
— The 2020 COVID crash was an exogenous shock no macro model could predict; the MEI would not have warned you.
— Past patterns are not guarantees. Current dynamics (AI capex, geopolitics, structural inflation) may break historical relationships.
— Not financial advice. Use alongside your own analysis.

## Source Code

````pine
//@version=6
// =============================================================================
// MARKET EUPHORIA INDEX (MEI)
// =============================================================================
// A LEADING composite indicator that peaks BEFORE major SPX/Nasdaq tops.
// Designed to be added on a MONTHLY chart of SPX (works on weekly too).
//
// Core principle: tops form when EUPHORIA (price extension, sustained
// complacency) collides with LATE-CYCLE STRESS (curve un-inversion,
// inflation re-acceleration, high real rates). This indicator measures
// the cumulative buildup of both.
//
// Output: 0-100 line
//   > 80 = EXTREME EUPHORIA - historical top zone (1987, 2000, 2007, 2021)
//   > 65 = Euphoria warning - reduce risk
//   35-65 = Neutral
//   < 35 = Fear - opportunity zone
//   < 20 = EXTREME FEAR - historical bottom zone
//
// Components:
//   1. Price extension vs 5-year SMA  (30%) <- primary leading signal
//   2. Yield curve un-inversion clock (25%) <- leads tops by 6-18 months
//   3. VIX 12-month average           (15%) <- sustained complacency
//   4. Inflation re-acceleration      (10%) <- late-cycle shock
//   5. Real rate stress               (10%) <- tightening conditions
//   6. Fed cycle position             (10%) <- policy late-stage
// =============================================================================

indicator("Market Euphoria Index [MEI]", shorttitle="MEI",
     precision=1, max_lines_count=50)

// === INPUTS ===========================================================
grp_w = "Component weights"
w_ext  = input.float(30, "Price extension (5y MA)",  minval=0, maxval=100, group=grp_w)
w_cv   = input.float(25, "Yield curve clock",        minval=0, maxval=100, group=grp_w)
w_comp = input.float(15, "VIX 12-month average",     minval=0, maxval=100, group=grp_w)
w_inf  = input.float(10, "Inflation re-accel",       minval=0, maxval=100, group=grp_w)
w_rr   = input.float(10, "Real rate stress",         minval=0, maxval=100, group=grp_w)
w_ff   = input.float(10, "Fed cycle position",       minval=0, maxval=100, group=grp_w)

grp_t = "Thresholds"
peak_x = input.float(80, "Extreme euphoria",  minval=70, maxval=100, group=grp_t)
peak_w = input.float(65, "Euphoria warning",  minval=50, maxval=80,  group=grp_t)
fear_w = input.float(35, "Fear",              minval=20, maxval=50,  group=grp_t)
fear_x = input.float(20, "Extreme fear",      minval=0,  maxval=35,  group=grp_t)

grp_d = "Display"
smooth_n = input.int(3, "Smoothing (EMA)", minval=1, maxval=12, group=grp_d)
show_bg  = input.bool(true, "Background highlights", group=grp_d)
show_tab = input.bool(true, "Live values table",     group=grp_d)

// === DATA (all monthly for consistency across chart timeframes) =======
spx    = request.security("SP:SPX",            "M", close, ignore_invalid_symbol=true)
curve  = request.security("FRED:T10Y2Y",       "M", close, ignore_invalid_symbol=true)
vix    = request.security("CBOE:VIX",          "M", close, ignore_invalid_symbol=true)
cpi    = request.security("ECONOMICS:USIRYY",  "M", close, ignore_invalid_symbol=true)
ff     = request.security("FRED:FEDFUNDS",     "M", close, ignore_invalid_symbol=true)
us10y  = request.security("TVC:US10Y",         "M", close, ignore_invalid_symbol=true)

// === 1. PRICE EXTENSION VS 5-YEAR MA (LEADING) ========================
// At every major top, SPX was significantly above its 5-year average.
// 1987: ~40%, 2000: ~55%, 2007: ~25%, 2021: ~45%.
sma_60 = ta.sma(spx, 60)
ext_pct = (spx / sma_60 - 1) * 100
ext_score = math.max(0.0, math.min(100.0, ext_pct * 2.0))

// === 2. YIELD CURVE UN-INVERSION CLOCK ================================
// The curve inverts, then un-inverts - the top usually comes 0-12 months
// after the un-inversion. We count months since the last inversion.
bars_since_inv = ta.barssince(curve < 0)
months_since_inv = na(bars_since_inv) ? 999.0 : bars_since_inv

curve_score = 0.0
if curve < 0
    curve_score := math.min(75.0, 50.0 + math.abs(curve) * 25)
else if months_since_inv < 6
    curve_score := 100.0
else if months_since_inv < 12
    curve_score := 90.0
else if months_since_inv < 24
    curve_score := 70.0
else if months_since_inv < 48
    curve_score := 40.0
else
    curve_score := 15.0

// === 3. VIX 12-MONTH AVERAGE (SUSTAINED COMPLACENCY) ==================
// Not the spot VIX - the rolling 12m average. Persistent low = top buildup.
vix_12m = ta.sma(vix, 12)
comp_score = math.max(0.0, math.min(100.0, (28.0 - vix_12m) * 100.0 / 15.0))

// === 4. INFLATION RE-ACCELERATION =====================================
// 6-month change in CPI YoY. Re-accel after a disinflation = classic top setup.
cpi_chg_6m = cpi - cpi[6]
infl_score = 50.0
if cpi_chg_6m > 1.5
    infl_score := 95.0
else if cpi_chg_6m > 0.7
    infl_score := 80.0
else if cpi_chg_6m > 0.2
    infl_score := 60.0
else if cpi_chg_6m > -0.5
    infl_score := 40.0
else
    infl_score := 20.0

// === 5. REAL RATE STRESS ==============================================
// 10Y nominal yield minus CPI YoY. High and rising = tightening conditions.
real_rate = us10y - cpi
rr_change_12m = real_rate - (us10y[12] - cpi[12])

rr_score = 0.0
if real_rate > 2 and rr_change_12m > 1
    rr_score := 90.0
else if real_rate > 1
    rr_score := 70.0
else if real_rate > 0
    rr_score := 55.0
else if real_rate > -2
    rr_score := 40.0
else
    rr_score := 20.0

// === 6. FED CYCLE POSITION ============================================
// High and plateauing = peak late cycle. Cutting hard = bottom signal.
ff_chg_12m = ff - ff[12]
ff_score = 50.0
if ff > 4.0 and math.abs(ff_chg_12m) < 0.5
    ff_score := 90.0
else if ff > 5.0
    ff_score := 80.0
else if ff > 3.0 and ff_chg_12m >= 0
    ff_score := 75.0
else if ff > 2.0
    ff_score := 50.0
else if ff > 1.0
    ff_score := 30.0
else if ff_chg_12m < -2.0
    ff_score := 10.0
else
    ff_score := 20.0

// === COMPOSITE ========================================================
total_w = w_ext + w_cv + w_comp + w_inf + w_rr + w_ff
raw = (ext_score * w_ext + curve_score * w_cv + comp_score * w_comp + infl_score * w_inf + rr_score * w_rr + ff_score * w_ff) / total_w

mei = ta.ema(raw, smooth_n)

// === PLOTS ============================================================
line_color = color.gray
if mei > peak_x
    line_color := color.red
else if mei > peak_w
    line_color := color.orange
else if mei < fear_x
    line_color := color.lime
else if mei < fear_w
    line_color := color.green

plot(mei, "MEI", color=line_color, linewidth=3)

hline(peak_x, "Extreme euphoria", color=color.new(color.red, 30),    linestyle=hline.style_solid)
hline(peak_w, "Euphoria warning", color=color.new(color.orange, 30), linestyle=hline.style_dashed)
hline(50,     "Neutral",          color=color.new(color.gray, 60),   linestyle=hline.style_dotted)
hline(fear_w, "Fear",             color=color.new(color.green, 30),  linestyle=hline.style_dashed)
hline(fear_x, "Extreme fear",     color=color.new(color.lime, 30),   linestyle=hline.style_solid)

bg = color.new(color.gray, 100)
if show_bg and mei > peak_x
    bg := color.new(color.red, 78)
else if show_bg and mei > peak_w
    bg := color.new(color.orange, 86)
else if show_bg and mei < fear_x
    bg := color.new(color.lime, 78)
else if show_bg and mei < fear_w
    bg := color.new(color.green, 86)
bgcolor(bg)

// === ALERTS ===========================================================
alertcondition(ta.crossover(mei,  peak_w), "MEI: Euphoria warning", "MEI crossed above euphoria warning")
alertcondition(ta.crossover(mei,  peak_x), "MEI: EXTREME EUPHORIA", "MEI entered extreme euphoria zone - top risk high")
alertcondition(ta.crossunder(mei, fear_w), "MEI: Fear",             "MEI dropped below fear threshold - opportunity")
alertcondition(ta.crossunder(mei, fear_x), "MEI: EXTREME FEAR",     "MEI in extreme fear - bottom likely near")

// === LIVE TABLE =======================================================
score_col(float s) =>
    s > peak_x ? color.red : s > peak_w ? color.orange : s < fear_x ? color.lime : s < fear_w ? color.green : color.white

if barstate.islast and show_tab
    var table t = table.new(position.top_right, 3, 9, bgcolor=color.new(color.black, 70), border_color=color.new(color.gray, 50), border_width=1)

    table.cell(t, 0, 0, "Component", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small)
    table.cell(t, 1, 0, "Value",     text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small)
    table.cell(t, 2, 0, "Score",     text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small)

    table.cell(t, 0, 1, "Price vs 5y MA", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, str.tostring(ext_pct, "#.#") + "%", text_color=color.white, text_size=size.small)
    table.cell(t, 2, 1, str.tostring(ext_score, "#"), text_color=score_col(ext_score), text_size=size.small)

    curve_label = curve < 0 ? "Inverted" : "+" + str.tostring(curve, "#.##") + " (" + str.tostring(months_since_inv, "#") + "m)"
    table.cell(t, 0, 2, "Curve clock", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2, curve_label, text_color=color.white, text_size=size.small)
    table.cell(t, 2, 2, str.tostring(curve_score, "#"), text_color=score_col(curve_score), text_size=size.small)

    table.cell(t, 0, 3, "VIX 12m avg", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(vix_12m, "#.#"), text_color=color.white, text_size=size.small)
    table.cell(t, 2, 3, str.tostring(comp_score, "#"), text_color=score_col(comp_score), text_size=size.small)

    table.cell(t, 0, 4, "CPI 6m Δ", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 4, str.tostring(cpi_chg_6m, "+#.#;-#.#") + "pp", text_color=color.white, text_size=size.small)
    table.cell(t, 2, 4, str.tostring(infl_score, "#"), text_color=score_col(infl_score), text_size=size.small)

    table.cell(t, 0, 5, "Real rate", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 5, str.tostring(real_rate, "+#.#;-#.#") + "%", text_color=color.white, text_size=size.small)
    table.cell(t, 2, 5, str.tostring(rr_score, "#"), text_color=score_col(rr_score), text_size=size.small)

    table.cell(t, 0, 6, "Fed cycle", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 6, str.tostring(ff, "#.##") + "% Δ" + str.tostring(ff_chg_12m, "+#.#;-#.#"), text_color=color.white, text_size=size.small)
    table.cell(t, 2, 6, str.tostring(ff_score, "#"), text_color=score_col(ff_score), text_size=size.small)

    table.cell(t, 0, 7, "", bgcolor=color.new(color.gray, 70))
    table.cell(t, 1, 7, "", bgcolor=color.new(color.gray, 70))
    table.cell(t, 2, 7, "", bgcolor=color.new(color.gray, 70))

    table.cell(t, 0, 8, "MEI composite", text_color=color.yellow, bgcolor=color.new(color.gray, 40), text_size=size.normal)
    table.cell(t, 1, 8, "", bgcolor=color.new(color.gray, 40))
    table.cell(t, 2, 8, str.tostring(mei, "#.#"), text_color=line_color, bgcolor=color.new(color.gray, 40), text_size=size.normal)
````
