# Eclipse Transition Scanner [forexobroker]

- url: https://www.tradingview.com/script/WxgSpePO-Eclipse-Transition-Scanner-forexobroker/
- type: indicator
- pine_id: PUB;766a2a52d491418b9c7cd7463b1866b6
- version: 1.0

## Description

Eclipse Transition Scanner finds MA crossovers that happen from a near-coincident state -- where the fast and slow MAs had stayed within a tight ATR-scaled spread for several bars before crossing -- and requires RSI and volume confirmation. These "eclipse" crossovers are rarer and far cleaner than typical MA crosses.

Built for traders who know that most MA crosses fail, and want a structural filter that only accepts crosses out of compressed MA states.

🔶 CONCEPTS

An MA cross where the two MAs were already drifting in the same direction and just happened to touch produces noisy signals. An MA cross that follows a genuine MA compression -- where fast and slow have been intertwined for several bars -- marks an actual regime flip, because neither trend was dominant before and one finally won. Adding RSI (momentum confirmation) and volume (participation confirmation) on the cross bar filters out the remaining low-quality crosses and leaves only the highest-probability transitions.

🔶 HOW IT WORKS

- Computes fast and slow EMAs
- Measures absolute spread between them, normalized by ATR
- Tracks the maximum spread over the last N bars (Eclipse Proximity Window)
- Declares the eclipse proximity met when max spread in window / ATR <= Max Pre-Cross Spread
- Detects fresh MA crossover / crossunder events
- Confirms volume is above average by the volume multiplier
- Confirms RSI is above the bullish floor (for bull cross) or below the bearish ceiling (for bear cross)
- Combines proximity tightness, volume, RSI deviation from 50, and cross event into a 0-100 Eclipse Score
- Classifies state as CLEAR, PENUMBRA, PARTIAL, or TOTAL
- Fires signal on confirmed eclipse transition

🔶 HOW TO USE

1. Add the indicator -- cyan fast MA and purple slow MA each drawn with 3-layer glow
2. Watch the dashboard (top-right) for live spread/ATR, proximity flag, cross state, RSI, and volume confirmation
3. Green BUY triangles with "ECLIPSE ↑" label fire on bullish eclipse transitions; pink SELL triangles on bearish
4. Tighten Max Pre-Cross Spread (ATR) for only the most compressed eclipses; widen for more signals
5. Adjust Bullish RSI Floor / Bearish RSI Ceiling to match instrument behavior

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Proximity-gated crossover (rare, high-quality transitions only)
- Triple confirmation (proximity + volume + RSI)

🔶 SETTINGS GUIDE

- Fast MA / Slow MA Length -- Two EMAs whose cross is the trigger
- Eclipse Proximity Window -- Bars over which max spread is measured
- Max Pre-Cross Spread (ATR) -- Max spread allowed in proximity window
- Volume Average Length / Volume Confirm Multiplier -- Volume confirmation
- RSI Length / Bullish RSI Floor / Bearish RSI Ceiling -- RSI confirmation criteria
- ATR Length -- ATR period used for spread normalization
- Eclipse Score Threshold -- Minimum 0-100 score required at fire
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- ETS Buy Eclipse -- Confirmed bullish eclipse transition
- ETS Sell Eclipse -- Confirmed bearish eclipse transition
- ETS Any Signal -- Any eclipse signal
- ETS Total Eclipse -- Score reaches 85+
- ETS Proximity -- MAs in tight proximity (informational)
- ETS Bull Cross -- Fresh fast-over-slow cross (informational)
- ETS Bear Cross -- Fresh fast-under-slow cross (informational)
- ETS Volume Confirm -- Volume multiplier condition met
- ETS Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Requiring proximity means many ordinary crosses will never trigger -- that's intended.
- On strongly trending instruments, eclipses become rare; consider loosening thresholds.
- The Eclipse Score is a composite heuristic, not a calibrated probability.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Eclipse Transition Scanner [forexobroker]", shorttitle="ETS [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_eclipse = "Eclipse Settings"
string g_signal  = "Signal Settings"
string g_visual  = "Visual Settings"

int    i_fastLen   = input.int(12, "Fast MA Length", minval=3, maxval=50, group=g_eclipse)
int    i_slowLen   = input.int(34, "Slow MA Length", minval=10, maxval=200, group=g_eclipse)
int    i_tightWin  = input.int(4, "Eclipse Proximity Window", minval=2, maxval=15, group=g_eclipse, tooltip="Bars around the cross where spread must stay minimal")
float  i_spreadAtr = input.float(0.2, "Max Pre-Cross Spread (ATR)", minval=0.05, maxval=1.0, step=0.05, group=g_eclipse, tooltip="Fast-Slow spread in ATR within the proximity window")
int    i_volLen    = input.int(20, "Volume Average Length", minval=5, maxval=100, group=g_eclipse)
float  i_volMult   = input.float(1.25, "Volume Confirm Multiplier", minval=1.0, maxval=3.0, step=0.05, group=g_eclipse)
int    i_rsiLen    = input.int(14, "RSI Length", minval=3, maxval=50, group=g_eclipse)
float  i_rsiBull   = input.float(52, "Bullish RSI Floor", minval=40, maxval=65, group=g_eclipse)
float  i_rsiBear   = input.float(48, "Bearish RSI Ceiling", minval=35, maxval=60, group=g_eclipse)
int    i_atrLen    = input.int(14, "ATR Length", minval=5, maxval=50, group=g_eclipse)
int    i_scoreThr  = input.int(70, "Eclipse Score Threshold", minval=40, maxval=95, group=g_signal)
int    i_cooldown  = input.int(15, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable = input.bool(true, "Show Eclipse Dashboard", group=g_visual)
bool   i_showBg    = input.bool(true, "Show Eclipse Background", group=g_visual)
bool   i_showGlow  = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
bool   i_showMa    = input.bool(true, "Show MA Glow", group=g_visual)
color  i_buyColor  = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float atrVal  = ta.atr(i_atrLen)
float fastMa  = ta.ema(close, i_fastLen)
float slowMa  = ta.ema(close, i_slowLen)
float spread  = math.abs(fastMa - slowMa)
float spreadN = atrVal > 0 ? spread / atrVal : 0.0
float rsiVal  = ta.rsi(close, i_rsiLen)
float avgVol  = ta.sma(volume, i_volLen)
bool volOk   = volume >= avgVol * i_volMult

// Was spread small in the recent proximity window?
float maxSpreadInWin = ta.highest(spread, i_tightWin)
bool eclipseProximity = atrVal > 0 and maxSpreadInWin / atrVal <= i_spreadAtr

// Fresh crossover
bool freshBullCross = ta.crossover(fastMa, slowMa)
bool freshBearCross = ta.crossunder(fastMa, slowMa)

bool bullEclipse = freshBullCross and eclipseProximity and volOk and rsiVal > i_rsiBull
bool bearEclipse = freshBearCross and eclipseProximity and volOk and rsiVal < i_rsiBear

// ─── ECLIPSE SCORING (0-100) ──────────────────────────────────────────────────
float sProxim = eclipseProximity ? math.min((i_spreadAtr - maxSpreadInWin / atrVal) * 150.0 + 20.0, 35.0) : 0.0
float sVol    = avgVol > 0 ? math.min(math.max((volume / avgVol - 1.0) * 45.0, 0.0), 25.0) : 0.0
float sRsi    = bullEclipse ? math.min((rsiVal - 50.0) * 2.0, 25.0) : bearEclipse ? math.min((50.0 - rsiVal) * 2.0, 25.0) : 0.0
float sCross  = (bullEclipse or bearEclipse) ? 20.0 : 0.0
float eclScore = math.round(math.min(sProxim + sVol + sRsi + sCross, 100.0))

string eclState = eclScore >= 85 ? "TOTAL" : eclScore >= 70 ? "PARTIAL" : eclScore >= 50 ? "PENUMBRA" : "CLEAR"
color  stateCol = eclScore >= 85 ? c_gold : eclScore >= 70 ? c_green : eclScore >= 50 ? c_cyan : color.gray

// ─── DIRECTIONAL BIAS ──────────────────────────────────────────────────────────
bool bullBias = bullEclipse
bool bearBias = bearEclipse

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool scoreOk    = eclScore >= i_scoreThr

bool rawBuy  = bullBias and scoreOk and cooldownOk and confirmed
bool rawSell = bearBias and scoreOk and cooldownOk and confirmed
bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Eclipse Background Gradient ──────────────────────────────────────
color eclBg = na
if i_showBg
    if eclScore >= 85
        eclBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_gold, 90)
    else if eclScore >= 70
        eclBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_cyan, 94)
    else if eclipseProximity
        eclBg := color.new(c_purple, 96)
bgcolor(eclBg)

// ─── VISUAL: MAs with 3-Layer Glow ────────────────────────────────────────────
plot(i_showMa ? fastMa : na, "FastMA Glow 1", color=color.new(c_cyan, 70), linewidth=5)
plot(i_showMa ? fastMa : na, "FastMA Glow 2", color=color.new(c_cyan, 40), linewidth=3)
plot(i_showMa ? fastMa : na, "FastMA Core",   color=color.new(c_cyan, 0),  linewidth=1)
plot(i_showMa ? slowMa : na, "SlowMA Glow 1", color=color.new(c_purple, 70), linewidth=5)
plot(i_showMa ? slowMa : na, "SlowMA Glow 2", color=color.new(c_purple, 40), linewidth=3)
plot(i_showMa ? slowMa : na, "SlowMA Core",   color=color.new(c_purple, 0),  linewidth=1)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="ECLIPSE ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="ECLIPSE ↓", textcolor=color.white)

// ─── VISUAL: Eclipse Context Label ────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "ECLIPSE ↑\nScore: " + str.tostring(eclScore) + "/100\nSpread: " + str.tostring(math.round(spreadN, 2)) + " ATR", style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "ECLIPSE ↓\nScore: " + str.tostring(eclScore) + "/100\nSpread: " + str.tostring(math.round(spreadN, 2)) + " ATR", style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Eclipse Dashboard ────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Eclipse Transition Scanner", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "Eclipse Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(eclScore) + "/100", text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 2, "State", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, eclState, text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 3, "Spread / ATR", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(math.round(spreadN, 2)), text_color=eclipseProximity ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 4, "Proximity", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, eclipseProximity ? "YES" : "NO", text_color=eclipseProximity ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 5, "MA Cross", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, fastMa > slowMa ? "BULL" : "BEAR", text_color=fastMa > slowMa ? c_green : c_pink, text_size=size.small)
    table.cell(dash, 0, 6, "RSI", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(math.round(rsiVal, 1)), text_color=rsiVal > i_rsiBull ? c_green : rsiVal < i_rsiBear ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 7, "Vol x Avg", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, avgVol > 0 ? str.tostring(math.round(volume / avgVol, 2)) + "x" : "-", text_color=volOk ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"ETS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"eclipse":' + str.tostring(eclScore) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"ETS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"eclipse":' + str.tostring(eclScore) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                         "ETS Buy Eclipse",      "Eclipse BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                        "ETS Sell Eclipse",     "Eclipse SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,           "ETS Any Signal",       "Any eclipse signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(eclScore >= 85,                    "ETS Total Eclipse",    "Eclipse score 85+ on {{ticker}} {{interval}}")
alertcondition(eclipseProximity,                  "ETS Proximity",        "MAs in tight proximity on {{ticker}} {{interval}}")
alertcondition(freshBullCross,                    "ETS Bull Cross",       "Fast MA crossed above slow on {{ticker}} {{interval}}")
alertcondition(freshBearCross,                    "ETS Bear Cross",       "Fast MA crossed below slow on {{ticker}} {{interval}}")
alertcondition(volOk,                             "ETS Volume Confirm",   "Volume multiplier condition met on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,           "ETS Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"ETS\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
