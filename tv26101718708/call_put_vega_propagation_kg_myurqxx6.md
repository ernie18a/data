#  Call Put Vega Propagation [KG]

- url: https://www.tradingview.com/script/myuRQxx6-Call-Put-Vega-Propagation-KG/
- type: indicator
- pine_id: PUB;c6c0563ff9014466b88ba2bc3ce23537
- version: 2.0

## Description

This is an options-analytics tool for TradingView. It doesn't plot price — it plots Vega, which is a measure of how sensitive an option's price is to changes in implied volatility (IV). In simple terms: Vega tells you how much extra premium an option gains or loses when the market's expectation of future volatility rises or falls.

The script builds two Vega values using the real Black-Scholes options pricing formula:

Call Vega — sensitivity of call options to volatility changes, based on your Call IV input
Put Vega — sensitivity of put options to volatility changes, based on your Put IV input

Because you can set Call IV and Put IV differently (this is called "volatility skew," which is normal in real markets), the two lines move independently. From these it derives:

Net Vega = Call Vega + Put Vega
Vega Difference = Call Vega − Put Vega
Call/Put Ratio = Call Vega divided by Put Vega
Daily Highs = the peak value each line reached so far that trading day

All of this shows up in a table on your chart, plus an oscillator-style panel below the price chart with the Call, Put, and Net Vega lines plotted over time.

1)How to read the dashboard:
What you see	        &              What it means
Call Vega rising--Call options are becoming more sensitive/valuable to a rise in volatility
Put Vega rising--Same idea, but for put options
Net Vega > 0 (green)--Overall Vega exposure is skewed toward calls
Net Vega < 0 (orange)--Overall Vega exposure is skewed toward puts
Bias = "Bullish (Call Dominant)"--Call Vega is currently above Put Vega
Bias = "Bearish (Put Dominant)"--Put Vega is currently above Call Vega
Signal = BUY--Call Vega just crossed above Put Vega while Call Vega itself was positive
Signal = SELL--Put Vega just crossed above Call Vega while Put Vega itself was positive
Signal = WAIT--No fresh cross has happened

2)How people typically use a tool like this:
Trend confirmation, not entry timing on its own. A BUY signal suggests options-volatility dynamics are tilting toward calls — some traders use this as a filter to confirm a bullish bias before entering a trade based on price action or another indicator.
Watch Net Vega for regime shifts. When Net Vega crosses from negative to positive (or back), it can indicate a broad change in how the options market is positioning around volatility.
Use the Call/Put Ratio for extremes. A ratio far from 1 suggests lopsided Vega exposure, which some traders treat as a sign of stretched positioning.
Combine, don't isolate. Because this is a derived, model-based indicator (not raw price or volume), it works best layered with price action, support/resistance, or a trend indicator — not traded in isolation.

3)Timeframe:

This was built with intraday index/options trading in mind (the inputs reference expiry dates, strike steps, and Indian market time formatting — "Asia/Kolkata" —  it's designed for Nifty/Bank Nifty options). Reasonable defaults:

5-minute to 15-minute charts for intraday options trading, where Vega shifts matter most as expiry approaches
1-hour or daily if you want a slower, higher-conviction read on volatility bias rather than fast signals

The Call/Put Rate-of-Change lengths (14 and 21 by default) control how reactive the two lines are — shorter values = faster, noisier signals; longer values = smoother, slower signals. You may want to adjust these depending on your timeframe.

4)A few things to know before trusting the signals-
The Vega values are modeled, not pulled from a live options chain. Spot price, a rough ATM strike, and your manually entered IV percentages feed a Black-Scholes formula — they're an approximation of real market Vega, not the actual quoted Vega from your broker's option chain.
IV inputs are static numbers you set once, not live IV data — so if real implied volatility moves away from your input, the indicator's read will drift from reality.
Crossovers (like Call crossing Put) can produce false signals in choppy or low-volatility conditions, same as any crossover-based system.

5)Disclaimer:

This is an educational breakdown of what the code does, not trading advice. This indicator, like any technical or options-analytics tool, does not guarantee profitable trades and should not be used as a sole basis for financial decisions. Its Vega calculations rely on user-supplied and approximated inputs rather than live market data, which limits their precision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6

// ════════════════════════════════════════════════════════════════════════════
//  VEGA DASHBOARD
//  A professional options-analytics dashboard that tracks Call Vega, Put
//  Vega, Net Vega and derived bias / signal metrics, and renders them in a
//  premium, theme-aware, mobile-friendly table plus a supporting oscillator
//  panel with independently-oscillating plots and a dynamic Y-axis scale.
//
//  Vega is computed with the actual Black-Scholes formula (Section 2),
//  using spot price, strike, risk-free rate, time-to-expiry and separate
//  Call/Put implied volatility inputs. Call and Put Vega only diverge
//  because of IV skew (Call IV vs Put IV) — exactly as in real markets —
//
//  LIVE IV: IV is now sourced from live NSE:INDIAVIX via request.security(),
// ════════════════════════════════════════════════════════════════════════════

indicator(title       = " Call Put Vega Propagation [KG]",
     shorttitle       = "CE-PE Vega [KG]",
     overlay          = false,
     precision        = 4,
     max_labels_count = 500,
     max_lines_count  = 500,
     max_boxes_count  = 500)

// ══════════════════════════════════════════════════════════════════════════
//  SECTION 1 — USER INPUTS
// ══════════════════════════════════════════════════════════════════════════
grp_general = "General"
i_showDashboard = input.bool(true,  "Show Dashboard",      group = grp_general)
i_showPlot      = input.bool(true,  "Show Plot",           group = grp_general)
i_showNetVega   = input.bool(true,  "Show Net Vega Line",  group = grp_general)
i_showZeroLine  = input.bool(true,  "Show Zero Line",      group = grp_general)

grp_theme = "Theme"
i_theme = input.string("Auto", "Theme", options = ["Dark", "Light", "Auto"], group = grp_theme,
     tooltip = "Auto reads the chart background brightness and switches the dashboard palette automatically.")

grp_table = "Dashboard Table"
i_tablePos  = input.string("Top Right", "Table Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = grp_table)
i_textSize  = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grp_table)
i_rowPad    = input.bool(true, "Adaptive Row Height (extra padding)", group = grp_table)

grp_plot = "Plot Settings"
i_plotWidth = input.int(2, "Plot Line Width", minval = 1, maxval = 6, group = grp_plot)
i_lineStyle = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = grp_plot,
     tooltip = "Approximated via plot render styles — Pine's plot() call has no true dash pattern.")
i_transp    = input.int(0, "Plot Transparency", minval = 0, maxval = 90, group = grp_plot)

grp_visual = "Visual Features"
i_bgColoring  = input.bool(false, "Enable Background Coloring", group = grp_visual)
i_barColoring = input.bool(false, "Enable Bar Coloring",        group = grp_visual)
i_showLabels  = input.bool(false, "Show Signal Labels",         group = grp_visual)
i_showMarkers = input.bool(true,  "Show Signal Markers",        group = grp_visual)
i_showArrows  = input.bool(false, "Show Trend Arrows",          group = grp_visual)

grp_bs = "Black-Scholes Vega Inputs"
i_strikeMode   = input.string("ATM (Auto)", "Strike Mode", options = ["ATM (Auto)", "Manual"], group = grp_bs,
     tooltip = "Auto rounds spot price to the nearest Strike Step to approximate the ATM strike each bar.")
i_manualStrike = input.float(0.0, "Manual Strike Price (used if Strike Mode = Manual)", minval = 0.0, group = grp_bs)
i_strikeStep   = input.float(50.0, "Strike Step (for ATM Auto rounding)", minval = 0.01, group = grp_bs)
i_expiry       = input.time(timestamp("2025-12-25T00:00:00"), "Option Expiry Date/Time", group = grp_bs)
i_riskFreeRatePct = input.float(6.5, "Risk-Free Rate (%)", minval = 0.0, group = grp_bs)
i_vegaScale    = input.float(1.0, "Vega Display Scale Factor", minval = 0.0001, step = 0.5, group = grp_bs,
     tooltip = "Multiplies the signed Vega momentum for display convenience only — does not affect signal logic.")
i_callLen = input.int(14, "Call Vega Rate-of-Change Length", minval = 1, group = grp_bs,
     tooltip = "Different from the Put length on purpose — this is what decouples the two lines so they cross independently instead of mirroring each other.")
i_putLen  = input.int(21, "Put Vega Rate-of-Change Length", minval = 1, group = grp_bs)

grp_iv = "Live IV (INDIAVIX)"
i_useIndiaVix   = input.bool(true, "Use Live INDIAVIX for IV (else Manual IV below)", group = grp_iv,
     tooltip = "Pulls NSE:INDIAVIX every bar via request.security(). If it's unavailable (na or <=0), the script automatically falls back to the manual Call/Put IV inputs below.")
i_callIVSkewPct = input.float(-2.0, "Call IV Skew vs VIX (%, added to live VIX)", group = grp_iv,
     tooltip = "Call IV = live INDIAVIX + this offset. Negative skews calls cheaper than the VIX print, which is typical.")
i_putIVSkewPct  = input.float(0.0, "Put IV Skew vs VIX (%, added to live VIX)", group = grp_iv,
     tooltip = "Put IV = live INDIAVIX + this offset. Keep Call/Put skew different from each other so Call and Put Vega keep diverging realistically.")
i_callIVPct    = input.float(15.0, "Manual Call IV (%) — fallback / used if toggle off", minval = 0.01, group = grp_iv)
i_putIVPct     = input.float(17.0, "Manual Put IV (%) — fallback / used if toggle off", minval = 0.01, group = grp_iv)

// ══════════════════════════════════════════════════════════════════════════
//  SECTION 2 — BLACK-SCHOLES VEGA ENGINE
// ══════════════════════════════════════════════════════════════════════════
// Standard Black-Scholes Vega (always ≥ 0, since every term is positive):
//   d1        = ( ln(S/K) + (r + σ²/2) * T ) / ( σ * √T )
//   RawVega   = S * φ(d1) * √T / 100      (per 1% change in IV)
// where φ(x) is the standard normal probability density function.


f_normDensity(x) =>
    math.exp(-(x * x) / 2) / math.sqrt(2 * math.pi)

f_d1(S, K, r, sigma, T) =>
    (math.log(S / K) + (r + math.pow(sigma, 2) / 2) * T) / (sigma * math.sqrt(T))

f_bsVegaRaw(S, K, r, sigma, T) =>
    d1 = f_d1(S, K, r, sigma, T)
    (S * f_normDensity(d1) * math.sqrt(T)) / 100

// ── Live INDIAVIX feed (same mechanism as the Option Chain script) ──
vixClose = request.security("NSE:INDIAVIX", timeframe.period, close, ignore_invalid_symbol = true)
vixValid = i_useIndiaVix and not na(vixClose) and vixClose > 0

// Shared market state each bar
i_riskFreeRate = i_riskFreeRatePct / 100

// Call/Put IV: live VIX + skew when available, manual inputs as fallback.
// math.max(..., 0.0001) guards against a skew offset dragging IV to/below zero.
i_callIVPct_live = math.max(vixClose + i_callIVSkewPct, 0.01)
i_putIVPct_live  = math.max(vixClose + i_putIVSkewPct,  0.01)

i_callIVPct_eff = vixValid ? i_callIVPct_live : i_callIVPct
i_putIVPct_eff  = vixValid ? i_putIVPct_live  : i_putIVPct

i_callIV = i_callIVPct_eff / 100
i_putIV  = i_putIVPct_eff  / 100

f_currentStrike() =>
    i_strikeMode == "Manual" ? i_manualStrike : math.round(close / i_strikeStep) * i_strikeStep

f_timeToExpiryYears() =>
    math.max((i_expiry - time) / 31536000000.0, 0.0001)   

// Signed Call Vega momentum, rooted in real Black-Scholes Vega
f_callVegaBS() =>
    K   = f_currentStrike()
    T   = f_timeToExpiryYears()
    raw = f_bsVegaRaw(close, K, i_riskFreeRate, i_callIV, T)
    chg = ta.change(raw, i_callLen)
    smoothed = ta.ema(chg, math.max(i_callLen / 3, 1))
    smoothed * i_vegaScale

// Signed Put Vega momentum, rooted in real Black-Scholes Vega
f_putVegaBS() =>
    K   = f_currentStrike()
    T   = f_timeToExpiryYears()
    raw = f_bsVegaRaw(close, K, i_riskFreeRate, i_putIV, T)
    chg = ta.change(raw, i_putLen)
    // Independent lookback + independent smoothing window on purpose, so
    // Put decouples from Call
    smoothed = ta.ema(chg, math.max(i_putLen / 4, 1))
    smoothed * i_vegaScale

// ══════════════════════════════════════════════════════════════════════════
//  SECTION 3 — CORE CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════
callVega = f_callVegaBS()
putVega  = f_putVegaBS()

netVega  = callVega + putVega                                          // Net Vega = Call + Put
vegaDiff = callVega - putVega                                          // Vega Difference = Call − Put
cpRatio  = callVega / math.max(math.abs(putVega), 0.0000001)          // divide-by-zero safe

// ── Daily highest Call / Put Vega tracking (reset each new session) ──
// "Highest" = the peak value actually reached that day (sign-agnostic —
// both lines can wander positive or negative, so we track the running max).
isNewDay = ta.change(time("D")) != 0
var float highestCallVegaToday = na
var float highestPutVegaToday  = na
if isNewDay
    highestCallVegaToday := callVega
    highestPutVegaToday  := putVega
else
    highestCallVegaToday := math.max(nz(highestCallVegaToday), callVega)
    highestPutVegaToday  := math.max(nz(highestPutVegaToday),  putVega)

// ── Bias classification ──
biasText  = callVega > putVega ? "Bullish (Call Dominant)" :
             putVega > callVega ? "Bearish (Put Dominant)"  : "Neutral"
biasColor = callVega > putVega ? color.new(color.lime, 0) :
             putVega > callVega ? color.new(color.red,  0) : color.new(color.yellow, 0)

callBiasActive = callVega > putVega
putBiasActive  = putVega  > callVega

// ══════════════════════════════════════════════════════════════════════════
//  SECTION 4 — SIGNAL ENGINE
// ══════════════════════════════════════════════════════════════════════════

vegaCrossBull = ta.crossover(callVega, putVega)     // Call Vega crosses above Put Vega
vegaCrossBear = ta.crossunder(callVega, putVega)    // Put Vega crosses above Call Vega

buySignal  = vegaCrossBull and callVega > 0    // Call crosses above Put AND Call line itself is above zero
sellSignal = vegaCrossBear and putVega  > 0    // Put crosses above Call AND Put line itself is above zero
waitSignal = not buySignal and not sellSignal

netVegaCrossUp   = ta.crossover(netVega, 0)
netVegaCrossDown = ta.crossunder(netVega, 0)

// Persisted signal state text/colour for the dashboard (only changes on a new signal)
var string signalState = "WAIT"
var color  signalColor = color.new(color.yellow, 0)
if buySignal
    signalState := "BUY"
    signalColor := color.new(color.lime, 0)
else if sellSignal
    signalState := "SELL"
    signalColor := color.new(color.red, 0)

// ══════════════════════════════════════════════════════════════════════════
//  SECTION 5 — THEME ENGINE  (Dark / Light / Auto-detect)
// ══════════════════════════════════════════════════════════════════════════
f_isDarkChart() =>
    bg  = chart.bg_color
    lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum < 128

useDark = i_theme == "Dark" ? true : i_theme == "Light" ? false : f_isDarkChart()

// Palette
c_tableBg   = useDark ? color.new(#0d0f1a, 5)   : color.new(#f5f5f7, 5)
c_titleBg   = useDark ? color.new(#141726, 0)   : color.new(#dcdfe6, 0)
c_headerBg  = useDark ? color.new(#1c2033, 0)   : color.new(#e8e8ee, 0)
c_rowBgA    = useDark ? color.new(#12141f, 10)  : color.new(#ffffff, 10)
c_rowBgB    = useDark ? color.new(#181b2b, 10)  : color.new(#f0f0f4, 10)
c_border    = useDark ? color.new(#3a3f5c, 20)  : color.new(#c2c5d1, 20)
c_titleText = useDark ? color.new(#ffd76a, 0)   : color.new(#7a5200, 0)
c_headerTxt = useDark ? color.new(#ffffff, 0)   : color.new(#1a1a1a, 0)
c_paramTxt  = useDark ? color.new(#c8ccdc, 0)   : color.new(#333333, 0)
c_valueTxt  = useDark ? color.new(#ffffff, 0)   : color.new(#1a1a1a, 0)

// ══════════════════════════════════════════════════════════════════════════
//  SECTION 6 — TABLE / TEXT / LINE-STYLE HELPERS
// ══════════════════════════════════════════════════════════════════════════
f_getTablePos(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        =>                position.top_right

f_getTextSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        =>          size.normal

f_getPlotStyle(s) =>
    // plot() has no native dashed/dotted render — approximate with distinct styles
    switch s
        "Dashed" => plot.style_stepline
        "Dotted" => plot.style_circles
        =>          plot.style_line

fs  = f_getTextSize(i_textSize)
pad = i_rowPad ? " " : ""   // adaptive-height illusion via padded strings

// ══════════════════════════════════════════════════════════════════════════
//  SECTION 7 — DASHBOARD TABLE
// ══════════════════════════════════════════════════════════════════════════

var table dash = na
if i_showDashboard and na(dash)
    dash := table.new(f_getTablePos(i_tablePos), 2, 16,
         bgcolor       = c_tableBg,
         border_width  = 2,
         border_color  = c_border,
         frame_width   = 2,
         frame_color   = c_border)

if i_showDashboard and barstate.islast
    // ---- Row 0: Title ----
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 0, 0, "⚡ VEGA DASHBOARD [KG]" + pad,
         text_color = c_titleText, bgcolor = c_titleBg, text_size = fs, text_halign = text.align_center)

    // ---- Row 1: Column headers ----
    table.cell(dash, 0, 1, "Parameter" + pad, text_color = c_headerTxt, bgcolor = c_headerBg, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 1, "Value" + pad,     text_color = c_headerTxt, bgcolor = c_headerBg, text_size = fs, text_halign = text.align_right)

    // ---- IV source row (new) ----
    ivSrcTxt = vixValid ? "LIVE VIX " + str.tostring(vixClose, "#.##") + "%" : "MANUAL (fallback)"
    ivSrcColor = vixValid ? color.new(color.lime, 0) : color.new(color.orange, 0)
    table.cell(dash, 0, 2, "🎯 IV Source" + pad, text_color = c_paramTxt, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 2, ivSrcTxt + pad, text_color = ivSrcColor, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_right)

    table.cell(dash, 0, 3, "Call IV / Put IV" + pad, text_color = c_paramTxt, bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(i_callIVPct_eff, "#.##") + "% / " + str.tostring(i_putIVPct_eff, "#.##") + "%" + pad, text_color = c_valueTxt, bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_right)

    // ---- Data rows (fractional/decimal formatting — "#.####") ----
    ceColorNow = callVega >= 0 ? color.new(color.lime, 0) : color.new(#ff8080, 0)
    table.cell(dash, 0, 4, "🟢 Call Vega" + pad, text_color = c_paramTxt, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(callVega, "#.####") + pad, text_color = ceColorNow, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_right)

    peColorNow = putVega <= 0 ? color.new(color.red, 0) : color.new(#80c0ff, 0)
    table.cell(dash, 0, 5, "🔴 Put Vega" + pad, text_color = c_paramTxt, bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(putVega, "#.####") + pad, text_color = peColorNow, bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_right)

    netColor = netVega > 0 ? color.new(#39ff6a, 0) : netVega < 0 ? color.new(color.orange, 0) : c_valueTxt
    table.cell(dash, 0, 6, "⚪ Net Vega" + pad, text_color = c_paramTxt, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(netVega, "#.####") + pad, text_color = netColor, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_right)

    table.cell(dash, 0, 7, "🟡 Vega Difference" + pad, text_color = c_paramTxt, bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(vegaDiff, "#.####") + pad, text_color = color.new(color.yellow, 0), bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_right)

    table.cell(dash, 0, 8, "🟣 Call / Put Vega Ratio" + pad, text_color = c_paramTxt, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 8, str.tostring(cpRatio, "#.##") + pad, text_color = color.new(color.purple, 0), bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_right)

    table.cell(dash, 0, 9, "🔺 Highest Call Vega Today" + pad, text_color = c_paramTxt, bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 9, str.tostring(nz(highestCallVegaToday), "#.####") + pad, text_color = color.new(color.teal, 0), bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_right)

    table.cell(dash, 0, 10, "🔻 Highest Put Vega Today" + pad, text_color = c_paramTxt, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 10, str.tostring(nz(highestPutVegaToday), "#.####") + pad, text_color = color.new(color.maroon, 0), bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_right)

    table.cell(dash, 0, 12, "🟢 Call Bias" + pad, text_color = c_paramTxt, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 12, (callBiasActive ? "ACTIVE" : "—") + pad, text_color = callBiasActive ? color.new(color.lime, 0) : c_valueTxt, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_right)

    table.cell(dash, 0, 13, "🔴 Put Bias" + pad, text_color = c_paramTxt, bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 13, (putBiasActive ? "ACTIVE" : "—") + pad, text_color = putBiasActive ? color.new(color.red, 0) : c_valueTxt, bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_right)

    table.cell(dash, 0, 14, "📈 Vega Signal" + pad, text_color = c_paramTxt, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 14, signalState + pad, text_color = signalColor, bgcolor = c_rowBgA, text_size = fs, text_halign = text.align_right)

    table.cell(dash, 0, 15, "🕒 Last Update" + pad, text_color = c_paramTxt, bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_left)
    table.cell(dash, 1, 15, str.format_time(timenow, "HH:mm:ss", "Asia/Kolkata") + pad, text_color = c_valueTxt, bgcolor = c_rowBgB, text_size = fs, text_halign = text.align_right)

// ══════════════════════════════════════════════════════════════════════════
//  SECTION 8 — CHART PLOTS
// ══════════════════════════════════════════════════════════════════════════

plotStyle = f_getPlotStyle(i_lineStyle)

plot(i_showPlot ? callVega : na, title = "Call Vega", color = color.new(color.lime, i_transp), linewidth = i_plotWidth, style = plotStyle)
plot(i_showPlot ? putVega  : na, title = "Put Vega",  color = color.new(color.red,  i_transp), linewidth = i_plotWidth, style = plotStyle)
plot(i_showPlot and i_showNetVega ? netVega : na, title = "Net Vega", color = color.new(color.white, i_transp), linewidth = i_plotWidth, style = plotStyle)

hline(i_showZeroLine ? 0 : na, title = "Zero Line", color = #f0fc51fa, linestyle = hline.style_dashed, linewidth = 1)

// ══════════════════════════════════════════════════════════════════════════
//  SECTION 9 — VISUAL FEATURES (background / bars / labels / markers / arrows)
// ══════════════════════════════════════════════════════════════════════════
bgColor = signalState == "BUY" ? color.new(color.lime, 90) :
     signalState == "SELL" ? color.new(color.red, 90) : na
bgcolor(i_bgColoring ? bgColor : na, title = "Signal Background")

barColor = signalState == "BUY" ? color.new(color.lime, 0) :
     signalState == "SELL" ? color.new(color.red, 0) : na
barcolor(i_barColoring ? barColor : na, title = "Signal Bar Color")

if i_showLabels and buySignal
    label.new(bar_index, putVega, "BUY", style = label.style_label_up, color = color.new(color.lime, 0), textcolor = color.black, size = size.small)
if i_showLabels and sellSignal
    label.new(bar_index, callVega, "SELL", style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white, size = size.small)

plotchar(i_showArrows and buySignal,  title = "Bull Arrow", char = "↑", location = location.bottom, color = color.new(color.lime, 0), size = size.small)
plotchar(i_showArrows and sellSignal, title = "Bear Arrow", char = "↓", location = location.top,    color = color.new(color.red,  0), size = size.small)

// ══════════════════════════════════════════════════════════════════════════
//  SECTION 10 — ALERTS
// ══════════════════════════════════════════════════════════════════════════
alertcondition(buySignal,         title = "BUY Signal",          message = "Vega Dashboard: BUY signal — Call Vega crossed above Put Vega with Net Vega > 0")
alertcondition(sellSignal,        title = "SELL Signal",         message = "Vega Dashboard: SELL signal — Put Vega crossed above Call Vega with Net Vega < 0")
alertcondition(vegaCrossBull,     title = "Bullish Vega Cross",  message = "Vega Dashboard: Call Vega crossed above Put Vega")
alertcondition(vegaCrossBear,     title = "Bearish Vega Cross",  message = "Vega Dashboard: Put Vega crossed above Call Vega")
alertcondition(netVegaCrossUp,    title = "Net Vega Positive",   message = "Vega Dashboard: Net Vega crossed above zero")
alertcondition(netVegaCrossDown,  title = "Net Vega Negative",   message = "Vega Dashboard: Net Vega crossed below zero")

// ══════════════════════════════════════════════════════════════════════════
//  END OF SCRIPT
// ══════════════════════════════════════════════════════════════════════════
````
