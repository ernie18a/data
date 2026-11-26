# VWAP Bands [DYNA]

- url: https://www.tradingview.com/script/P0wYbpeA-VWAP-Bands-DYNA/
- type: indicator
- pine_id: PUB;a96113c09f14410a829c3c96d684aa80
- version: 1.0

## Description

VWAP Bands plots a session-anchored Volume Weighted Average Price together with three pairs of standard-deviation bands at ±1σ, ±2σ, and ±3σ. VWAP is the session's dynamic fair value, and the bands are its statistical envelope: inside ±1σ is normal, beyond ±2σ is stretched, beyond ±3σ is extreme. The result is a single overlay that tells you where price sits relative to the day's mean and how volatile that session actually is.

Most VWAP indicators give you only the line. Most band indicators (Bollinger, Keltner) use a rolling window that carries yesterday's noise into today. VWAP Bands combines the two: volume-weighted anchoring plus intraday-only σ bands that widen and contract with the current session's realised volatility. At session open the bands reset to zero and fan out as the session develops.


[b]Key Features[/b]

[list]
[*] [b]Session-Anchored VWAP[/b] -- Uses the TradingView session picker plus a timezone dropdown so the same indicator works on any regional market without code edits.
[*] [b]Three Band Pairs[/b] -- ±1σ, ±2σ, ±3σ with independently configurable multipliers. Each pair has its own visibility toggle.
[*] [b]Adaptive Volatility Envelope[/b] -- Bands widen automatically when intraday volatility rises and compress on quiet sessions. No manual lookback window required.
[*] [b]Gradient Band Shading[/b] -- Optional zone fills between adjacent bands, lighter toward the outer bands, so you can read where price is inside the envelope at a glance.
[*] [b]Volume-Agnostic[/b] -- On instruments with no traded volume (some cash indices) the indicator falls back to a flat weight, so VWAP and bands still render meaningfully.
[*] [b]Four Alerts[/b] -- Bullish VWAP cross, bearish VWAP cross, +2σ touch, -2σ touch. All confirmed on bar close.
[*] [b]No Repainting[/b] -- Signal conditions are gated on confirmed bars; once an alert has fired, the historical signal does not move.
[/list]


[b]How It Works[/b]

At the start of each session -- determined by your session window and timezone -- the indicator begins accumulating the typical price weighted by volume: Σ(src × vol) divided by Σ(vol) gives the VWAP. In parallel it tracks Σ(src² × vol) to compute the volume-weighted variance, then the square root is the standard deviation. Bands are plotted at VWAP ± (multiplier × σ) for each of the three multipliers.

Because the sums are cumulative from session open, every bar updates VWAP and the bands. At the start of the session the bands collapse onto the VWAP line; as the session progresses they fan out and reflect the volatility the market is actually producing that day.

When the session ends and a new one begins, all accumulators reset. The lines are drawn only inside the configured session window -- no stale levels during off-hours.

[image]https://www.tradingview.com/x/WJV9Xvud/[/image]
[i]VWAP (blue) with ±1σ, ±2σ, ±3σ bands (green below, red above) anchored to the session open. Bands fan out from VWAP as the session's realised volatility accumulates.[/i]


[b]Settings[/b]

[b]Session Time[/b] (default: 0915-1530) and [b]Timezone[/b] (default: Asia/Kolkata) define the session window. [b]VWAP Source[/b] (default: hlc3) sets the price used in the weighted average; hlc3 matches TradingView's built-in VWAP.

[b]Band 1 / 2 / 3 Multiplier[/b] (defaults 1.0, 2.0, 3.0) set each band pair's offset in standard deviations. The defaults match the statistical convention -- ±1σ covers roughly 68% of in-session variation, ±2σ ~95%, ±3σ ~99.7% under a normal distribution. Adjust upward if the default envelopes feel too tight for your instrument.

[b]Show VWAP Line[/b] and the three [b]Show ±Nσ Bands[/b] toggles let you hide any line you do not want on the chart. [b]Shade Between Bands[/b] enables gradient fills between adjacent bands; [b]Fill Transparency[/b] (default: 85) controls how subtle those fills are.

The two alert toggles enable or disable the VWAP-cross and ±2σ-touch alerts independently.


[b]Alerts[/b]

[list]
[*] [b]Price Crosses Above VWAP[/b] -- Fires when close crosses above the VWAP line, signalling a session bias flip to bullish. [i]"VWAP Bands [DYNA]: Price crossed above VWAP -- session bias flipping bullish."[/i]
[*] [b]Price Crosses Below VWAP[/b] -- Fires when close crosses below the VWAP line. [i]"VWAP Bands [DYNA]: Price crossed below VWAP -- session bias flipping bearish."[/i]
[*] [b]Price Touches +2σ Band[/b] -- Fires when the bar high reaches the +2σ upper band, marking a stretched upside condition. [i]"VWAP Bands [DYNA]: Price touched the +2σ upper band -- stretched above VWAP."[/i]
[*] [b]Price Touches -2σ Band[/b] -- Fires when the bar low reaches the -2σ lower band, marking a stretched downside condition. [i]"VWAP Bands [DYNA]: Price touched the -2σ lower band -- stretched below VWAP."[/i]
[/list]

To set up alerts: click TradingView's Alerts button, choose "VWAP Bands [DYNA]" from the condition dropdown, pick one of the four alert variants, and select your notification channel.


[b]Best Practices[/b]

[list]
[*] Give the bands 3-5 bars to stabilise at session open. Early-session standard deviation is tiny so the bands collapse onto VWAP; wait for the fan-out before reading them.
[*] Use ±2σ and ±3σ as mean-reversion zones. Touches of the outer bands under normal volatility often see a snap back toward VWAP, especially on higher timeframes.
[*] Use VWAP itself and ±1σ as pullback entry zones when price is trending cleanly on one side of VWAP.
[*] On volatile news sessions, bands expand rapidly -- a ±2σ touch there is much less extreme than a ±2σ touch on a quiet session. Let the band width itself inform how much weight to give each touch.
[*] On cash-index charts with no volume, treat the indicator as a session-anchored σ-band system rather than a true VWAP. The bands still reflect intraday dispersion meaningfully; the weighting just falls back to flat.
[*] Match [b]Session Time[/b] to regular trading hours only -- including extended hours drags the VWAP and widens the bands unnecessarily.
[/list]


[b]Part of the DYNA Ecosystem[/b]

VWAP Bands is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// VWAP Bands [DYNA]
// Session-anchored VWAP with 1σ, 2σ, and 3σ volatility bands for intraday mean reversion and trend targets.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("VWAP Bands [DYNA]", shorttitle = "VWAPB [DYNA]", overlay = true)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800
color VWAP_COLOR    = #2962ff

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

string GRP_CORE  = "Core Settings"
string GRP_VIS   = "Visual"
string GRP_ALERT = "Alerts"

// --- Core Settings ---
string i_session   = input.session("0915-1530", "Session Time", group = GRP_CORE, tooltip = "Session window that anchors the VWAP. VWAP and bands reset at the start of each new session.")
string i_timezone  = input.string("Asia/Kolkata", "Timezone", options = ["Asia/Kolkata", "America/New_York", "America/Chicago", "Europe/London", "UTC", "Asia/Tokyo", "Asia/Singapore", "Australia/Sydney"], group = GRP_CORE, tooltip = "Timezone used to interpret the session window. Match the exchange's local time to avoid DST drift.")
i_source           = input.source(hlc3, "VWAP Source", group = GRP_CORE, tooltip = "Price source used in the VWAP calculation. Default hlc3 matches TradingView's built-in VWAP.")
float  i_mult1     = input.float(1.0, "Band 1 Multiplier (σ)", minval = 0.1, maxval = 10.0, step = 0.1, group = GRP_CORE, tooltip = "Inner band offset in standard deviations above and below VWAP.")
float  i_mult2     = input.float(2.0, "Band 2 Multiplier (σ)", minval = 0.1, maxval = 10.0, step = 0.1, group = GRP_CORE, tooltip = "Middle band offset in standard deviations. ±2σ is the statistical \"stretched\" zone.")
float  i_mult3     = input.float(3.0, "Band 3 Multiplier (σ)", minval = 0.1, maxval = 10.0, step = 0.1, group = GRP_CORE, tooltip = "Outer band offset in standard deviations. ±3σ is the statistical \"extreme\" zone.")

// --- Visual ---
bool i_showVwap    = input.bool(true, "Show VWAP Line", group = GRP_VIS, tooltip = "Display the session-anchored VWAP center line.")
bool i_showBand1   = input.bool(true, "Show ±1σ Bands",  group = GRP_VIS, tooltip = "Display the inner ±1σ bands.")
bool i_showBand2   = input.bool(true, "Show ±2σ Bands",  group = GRP_VIS, tooltip = "Display the middle ±2σ bands.")
bool i_showBand3   = input.bool(true, "Show ±3σ Bands",  group = GRP_VIS, tooltip = "Display the outer ±3σ bands.")
bool i_fillBands   = input.bool(true, "Shade Between Bands", group = GRP_VIS, tooltip = "Fill the zones between adjacent bands with a gradient (lighter toward the outer bands).")
int  i_fillOpacity = input.int(85, "Fill Transparency", minval = 50, maxval = 95, group = GRP_VIS, tooltip = "Higher = more transparent band fills.")

// --- Alerts ---
bool i_alertCross  = input.bool(true, "Alert: VWAP Crosses", group = GRP_ALERT, tooltip = "Fire alerts when price closes across the VWAP line.")
bool i_alert2Sigma = input.bool(true, "Alert: ±2σ Touches",  group = GRP_ALERT, tooltip = "Fire alerts when price reaches the ±2σ band (stretched condition).")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Session anchoring ---
// `sessionDay` returns a constant timestamp (the session's daily start) for every
// bar inside the configured session, and `na` outside. Detecting newSession via
// `sessionDay != sessionDay[1]` is robust whether the chart shows or hides off-hours bars.
int  sessionDay = time("D", i_session, i_timezone)
bool inSession  = not na(sessionDay)
bool newSession = inSession and (na(sessionDay[1]) or sessionDay != sessionDay[1])

// --- Per-session cumulative accumulators ---
// Pine rolls back `var` state between ticks in realtime, so `:=` accumulation is safe.
var float sumPV  = 0.0
var float sumV   = 0.0
var float sumPPV = 0.0

if newSession
    sumPV  := 0.0
    sumV   := 0.0
    sumPPV := 0.0

if inSession
    float v = math.max(nz(volume, 0.0), 1.0)
    sumPV  := sumPV  + i_source * v
    sumV   := sumV   + v
    sumPPV := sumPPV + i_source * i_source * v

// --- VWAP and standard deviation ---
float vwap     = sumV > 0 ? sumPV / sumV : na
float variance = sumV > 0 ? math.max(sumPPV / sumV - vwap * vwap, 0.0) : na
float stdev    = na(variance) ? na : math.sqrt(variance)

float upper1 = na(vwap) ? na : vwap + i_mult1 * stdev
float lower1 = na(vwap) ? na : vwap - i_mult1 * stdev
float upper2 = na(vwap) ? na : vwap + i_mult2 * stdev
float lower2 = na(vwap) ? na : vwap - i_mult2 * stdev
float upper3 = na(vwap) ? na : vwap + i_mult3 * stdev
float lower3 = na(vwap) ? na : vwap - i_mult3 * stdev

// Plot only inside the session (hide during off-hours bars).
float plotVwap   = inSession and i_showVwap  ? vwap   : na
float plotUpper1 = inSession and i_showBand1 ? upper1 : na
float plotLower1 = inSession and i_showBand1 ? lower1 : na
float plotUpper2 = inSession and i_showBand2 ? upper2 : na
float plotLower2 = inSession and i_showBand2 ? lower2 : na
float plotUpper3 = inSession and i_showBand3 ? upper3 : na
float plotLower3 = inSession and i_showBand3 ? lower3 : na

// --- Signal conditions (confirmed bars only, per no-repaint rule) ---
bool confirmed  = barstate.isconfirmed
bool crossUp    = confirmed and ta.crossover(close, vwap)
bool crossDown  = confirmed and ta.crossunder(close, vwap)
bool touch2Up   = confirmed and not na(upper2) and not na(upper2[1]) and high  >= upper2 and high[1]  <  upper2[1]
bool touch2Down = confirmed and not na(lower2) and not na(lower2[1]) and low   <= lower2 and low[1]   >  lower2[1]

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Band + VWAP lines ---
pU3 = plot(plotUpper3, title = "+3σ", color = color.new(BEAR_COLOR, 35), linewidth = 1)
pU2 = plot(plotUpper2, title = "+2σ", color = color.new(BEAR_COLOR, 25), linewidth = 1)
pU1 = plot(plotUpper1, title = "+1σ", color = color.new(BEAR_COLOR, 45), linewidth = 1)
pV  = plot(plotVwap,   title = "VWAP", color = color.new(VWAP_COLOR, 0), linewidth = 2)
pL1 = plot(plotLower1, title = "-1σ", color = color.new(BULL_COLOR, 45), linewidth = 1)
pL2 = plot(plotLower2, title = "-2σ", color = color.new(BULL_COLOR, 25), linewidth = 1)
pL3 = plot(plotLower3, title = "-3σ", color = color.new(BULL_COLOR, 35), linewidth = 1)

// --- Gradient fills between adjacent bands (only when both neighbours are visible) ---
int fillInner = i_fillOpacity
int fillMid   = math.min(i_fillOpacity + 3, 99)
int fillOuter = math.min(i_fillOpacity + 6, 99)

fill(pV,  pU1, color = i_fillBands and i_showBand1             ? color.new(BEAR_COLOR, fillInner) : na, title = "VWAP → +1σ")
fill(pU1, pU2, color = i_fillBands and i_showBand1 and i_showBand2 ? color.new(BEAR_COLOR, fillMid)   : na, title = "+1σ → +2σ")
fill(pU2, pU3, color = i_fillBands and i_showBand2 and i_showBand3 ? color.new(BEAR_COLOR, fillOuter) : na, title = "+2σ → +3σ")
fill(pV,  pL1, color = i_fillBands and i_showBand1             ? color.new(BULL_COLOR, fillInner) : na, title = "VWAP → -1σ")
fill(pL1, pL2, color = i_fillBands and i_showBand1 and i_showBand2 ? color.new(BULL_COLOR, fillMid)   : na, title = "-1σ → -2σ")
fill(pL2, pL3, color = i_fillBands and i_showBand2 and i_showBand3 ? color.new(BULL_COLOR, fillOuter) : na, title = "-2σ → -3σ")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(crossUp    and i_alertCross,  title = "Price Crosses Above VWAP",
    message = "VWAP Bands [DYNA]: Price crossed above VWAP — session bias flipping bullish.")
alertcondition(crossDown  and i_alertCross,  title = "Price Crosses Below VWAP",
    message = "VWAP Bands [DYNA]: Price crossed below VWAP — session bias flipping bearish.")
alertcondition(touch2Up   and i_alert2Sigma, title = "Price Touches +2σ Band",
    message = "VWAP Bands [DYNA]: Price touched the +2σ upper band — stretched above VWAP.")
alertcondition(touch2Down and i_alert2Sigma, title = "Price Touches -2σ Band",
    message = "VWAP Bands [DYNA]: Price touched the -2σ lower band — stretched below VWAP.")
````
