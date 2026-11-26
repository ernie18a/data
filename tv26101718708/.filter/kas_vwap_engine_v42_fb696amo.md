# KAS VWAP Engine v4.2

- url: https://www.tradingview.com/script/fB696amO-KAS-VWAP-Engine-v4-2/
- type: indicator
- pine_id: PUB;a31d3c2d34d0431197781797c4e8bb8f
- version: 1.0

## Description

KAS VWAP Engine v4.2 is an open-source auto-anchored VWAP indicator designed for mean-reversion setups around volume-weighted average price. The anchor automatically resets when price establishes a new structural high or low over a configurable lookback period. A 2-stage state machine ensures signals only fire after a confirmed band-touch followed by an opposite-band close-reclaim.

WHAT IT DOES

- Plots an auto-anchored VWAP that resets on structure breaks (configurable lookback)
- Adds inner and outer ATR-based deviation bands around the VWAP baseline
- Detects mean-reversion entries when price touches the outer band and reclaims the inner band
- Visualizes completed trades as directional vectors with inline P&L labels
- Filters signals through an HTF EMA 200 trend gate (optional) and an ATR Z-Score volatility regime gate (optional)
- Displays a real-time dashboard with current reversion state, VWAP value, price deviation, HTF trend, and ATR filter status

HOW IT WORKS

1. Auto-Anchor Detection
The anchor resets when the current bar high exceeds the highest high of the previous N bars (configurable, default 50), or when the current low breaks below the lowest low. Implementation uses ta.highest(high[1], swingLen) and ta.lowest(low[1], swingLen) for the structure-break comparison.

2. Manual VWAP Accumulators
The VWAP uses hlc3 as price source and resets accumulator buffers on each new anchor. This produces a session-style VWAP from each detected structure point. Formula: VWAP = sumSrcVol / sumVol, where sumSrcVol accumulates hlc3 multiplied by volume.

3. ATR Deviation Bands with Bridge
Bands are placed at the VWAP plus/minus inner-multiplier and outer-multiplier times the ATR-14 baseline (SMA-smoothed over 100 bars). On anchor-reset bars, a dedicated bridge variable substitutes hlc3 for the freshly-reset VWAP value, preventing ghost-line artifacts in the visualization.

4. 2-Stage State Machine (Arm to Fire)
Stage 1 (Arm): a touch of the outer band sets the armed state to +1 (long-arm) or -1 (short-arm).
Stage 2 (Fire): a close back inside the inner band fires the entry signal in the same direction.
A signal cooldown (configurable bars) and a VWAP-touch-reset clear the armed state.

5. ATR Z-Score Regime Gate
The ATR-14 z-score is computed against its 100-bar SMA and 100-bar standard deviation. When the z-score falls below -1.0, the regime is classified as Low Vol and signals are blocked (optional filter, on by default).

6. HTF EMA 200 Filter
A request.security call retrieves the EMA-200 from a higher timeframe (default 4h). When enabled, long-reversion signals only fire when close is above the HTF EMA, and short-reversion signals only fire when close is below the HTF EMA.

WHY IT'S UNIQUE

- Unlike standard auto-anchored VWAP scripts that produce ghost-line artifacts when the anchor resets, this indicator substitutes hlc3 on the reset bar via a dedicated bridge variable, providing a continuous, artifact-free anchored VWAP visualization.
- Unlike instant-fire band-touch signals common in VWAP deviation scripts, this indicator uses a 2-stage Arm to Fire state machine: an outer-band touch only arms the setup, and the signal fires only after an inner-band close-reclaim, significantly reducing false signals during volatile band-pierces.
- Unlike static signal markers, this indicator visualizes each completed trade as a directional vector from entry to exit (Take Profit at VWAP, or Stop at opposite outer band) with inline P&L percentage labels, enabling rapid visual back-test review on historical bars.

HOW TO USE

- Add the indicator to a standard candlestick chart on any timeframe (intraday 5m-15m and swing 1h-4h work well)
- Default settings work for most liquid instruments; adjust Structure Lookback (50 bars) based on your timeframe density
- Watch for Revert Long (triangle below bar) or Revert Short (triangle above bar) signals after a touch of the outer band
- The dashboard shows current reversion state, VWAP deviation, HTF trend direction, and whether the ATR regime gate is blocking signals
- Trade trajectory beams visualize each completed setup with TP (return to VWAP) or STOP (extension to opposite band) outcomes
- Combine with your own risk management; the indicator is analytical, not a recommendation

LIMITATIONS

- Mean-reversion logic is designed for ranging or oscillating markets; performance is reduced in strong directional trends
- ATR Z-Score regime detection requires at least 100 bars of history to stabilize
- The HTF EMA 200 filter requires sufficient history on the higher timeframe; on newly-listed instruments or very short timeframes the HTF signal may be unstable
- Signals fire on bar close (barstate.isconfirmed); intra-bar movements are not signaled
- This indicator is for analytical purposes only and does not constitute financial advice or a recommendation to trade

ABOUT

Knecht Alpha Signals delivers Pine Script v6 indicators focused on precision over noise. This open-source release is part of our public toolkit for the TradingView community.

## Source Code

````pine
//@version=6
// =============================================================================
// KAS VWAP Engine v4.2
// Auto-Anchored VWAP | ATR Deviation Bands | State Machine | HTF Filter
// KAS Architecture v6 Standard - 2026-05-19
// =============================================================================
indicator("KAS VWAP Engine v4.2", overlay=true,
  max_lines_count=500, max_labels_count=500)

// =============================================================================
// ===== INPUTS ================================================================
// =============================================================================
grpAnchor    = "Auto Anchor (Market Structure)"
int swingLen = input.int(50, "Structure Lookback (Bars)", minval=10, group=grpAnchor,
  tooltip="Resets VWAP when price makes a new High or Low over this period. 50 bars = standard for 15m intraday. Increase to 100-200 for 4h swing.")

grpVWAP          = "VWAP & ATR Deviation"
float innerMult  = input.float(1.5,  "Inner ATR Multiplier",            step=0.1,  group=grpVWAP)
float outerMult  = input.float(3.0,  "Outer ATR Multiplier",            step=0.1,  group=grpVWAP)
bool  useBodyExit  = input.bool(false, "Exit requires Close near VWAP",              group=grpVWAP,
  tooltip="If true, waits for the candle to close near the VWAP instead of just touching it with a wick.")
float exitTolMult  = input.float(0.10, "Exit Tolerance (ATR multiples)",  step=0.01, minval=0.0, group=grpVWAP)
float epsMult      = input.float(0.05, "Outer Touch Tolerance (ATR multiples)", step=0.01, minval=0.0, group=grpVWAP,
  tooltip="Allows a signal to trigger when price is within this ATR fraction of the outer band, instead of requiring an exact touch.")

grpHTF             = "Filters: HTF & ATR Regime"
string htfTf       = input.timeframe("240", "HTF Timeframe (EMA 200)", group=grpHTF)
bool   useHTF      = input.bool(false, "Filter Signals by HTF Trend", group=grpHTF,
  tooltip="Only allows LONG reversions in Bull trend, and SHORT reversions in Bear trend.")
bool   useAtrFilter = input.bool(true, "Block Signals in Low Vol Regime", group=grpHTF)
int    sigCooldown  = input.int(5, "Signal Cooldown (bars)", minval=1, group=grpHTF)

grpVis             = "Appearance"
color colVWAP      = input.color(color.rgb(204, 173, 0),   "VWAP Baseline",         group=grpVis)
color colBull      = input.color(color.rgb(38, 166, 154),  "Bullish Zones",         group=grpVis)
color colBear      = input.color(color.rgb(239, 83, 80),   "Bearish Zones",         group=grpVis)
bool  showVectors  = input.bool(true, "Show Trade Trajectory Beams", group=grpVis,
  tooltip="Draws visual arrows and P&L labels from Entry to Exit.")
bool  showAnchorBg = input.bool(false, "Show Anchor Reset Tints", group=grpVis,
  tooltip="Highlights bars where the structure-break anchor resets. Off by default for a cleaner chart view.")
bool  showDash     = input.bool(true, "Show Dashboard", group=grpVis)
string dashPosInput = input.string("Top Right", "Dashboard Position",
  options=["Top Left","Top Center","Top Right","Middle Left","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
  group=grpVis)

// =============================================================================
// ===== POSITION RESOLVER (BR-01: switch ONLY) ================================
// =============================================================================
getDashPos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.top_left

// =============================================================================
// ===== GLOBAL TABLE GUARDS (BR-06: global scope) =============================
// =============================================================================
var table dash = na

// =============================================================================
// ===== 1. HTF & ATR REGIME ===================================================
// =============================================================================
float htfEma = request.security(syminfo.tickerid, htfTf, ta.ema(close, 200), barmerge.gaps_off, barmerge.lookahead_off)
bool  htfBull  = close > htfEma
bool  htfBear  = close < htfEma

float atr14 = ta.atr(14)
float atrS  = ta.sma(atr14, 100)
float atrSD = ta.stdev(atr14, 100)
bool  canZ  = not na(atrS) and not na(atrSD) and atrSD != 0.0
float atrZ  = canZ ? (atr14 - atrS) / atrSD : na
bool  atrZ_na  = na(atrZ)
bool  isLowVol = canZ and atrZ < -1.0
float atrBase  = not na(atrS) ? atrS : atr14

string regimeTxt  = atrZ_na ? "N/A" : atrZ > 1.0 ? "High Vol" : isLowVol ? "Low Vol" : "Normal"
string atrGateTxt = isLowVol ? "BLOCKED (Low Vol)" : "ACTIVE (" + regimeTxt + ")"

// =============================================================================
// ===== 2. ZERO-LAG SWING ANCHORING ===========================================
// =============================================================================
float structHigh  = ta.highest(high[1], swingLen)
float structLow   = ta.lowest(low[1],   swingLen)
bool  isNewHigh   = high > structHigh
bool  isNewLow    = low  < structLow
bool  isFirstBar  = bar_index == 0
bool  isNewAnchor = isNewHigh or isNewLow or isFirstBar

// =============================================================================
// ===== 3. MANUAL VWAP ACCUMULATORS ===========================================
// =============================================================================
var float sumSrcVol = 0.0
var float sumVol    = 0.0
float src = hlc3
float vol = nz(volume, 0.0)

if isNewAnchor
    sumSrcVol := src * vol
    sumVol    := vol
else
    sumSrcVol += src * vol
    sumVol    += vol

float vwap   = sumVol != 0.0 ? (sumSrcVol / sumVol) : na
bool  vwapNa = na(vwap)

// =============================================================================
// ===== 4. ATR DEVIATION BANDS (KAS Bridge for Ghost-Line Prevention) =========
// =============================================================================
// Bridge: on anchor-reset bars, use hlc3 instead of vwap to prevent ghost lines
float bridgeVWAP = isNewAnchor ? hlc3 : vwap

float upperOuter = not na(bridgeVWAP) ? bridgeVWAP + outerMult * atrBase : na
float upperInner = not na(bridgeVWAP) ? bridgeVWAP + innerMult * atrBase : na
float lowerInner = not na(bridgeVWAP) ? bridgeVWAP - innerMult * atrBase : na
float lowerOuter = not na(bridgeVWAP) ? bridgeVWAP - outerMult * atrBase : na

bool  uoNa    = na(upperOuter)
bool  uiNa    = na(upperInner)
bool  loNa    = na(lowerOuter)
bool  liNa    = na(lowerInner)
float eps     = epsMult     * atrBase
float exitTol = exitTolMult * atrBase

// =============================================================================
// ===== 5. STATE MACHINE ======================================================
// =============================================================================
var int  state         = 0
var int  armedState    = 0
var int  lastSignalBar = na

bool okCooldown  = na(lastSignalBar) or (bar_index - lastSignalBar) >= sigCooldown
bool okHTF_Long  = useHTF ? htfBull : true
bool okHTF_Short = useHTF ? htfBear : true
bool okATR       = useAtrFilter ? not isLowVol : true

bool touchedUpperOuter     = not uoNa and high >= upperOuter - eps
bool closedBelowUpperInner = not uiNa and close < upperInner
bool touchedLowerOuter     = not loNa and low  <= lowerOuter + eps
bool closedAboveLowerInner = not liNa and close > lowerInner
bool touchedVWAP_any       = not vwapNa and low <= vwap and high >= vwap

if touchedLowerOuter
    armedState := 1
else if touchedUpperOuter
    armedState := -1

if touchedVWAP_any or isNewAnchor
    armedState := 0

bool fireRevertLong  = false
bool fireRevertShort = false

if state == 0 and okCooldown and okATR
    if armedState == 1 and closedAboveLowerInner and okHTF_Long
        fireRevertLong := true
        state          := 1
        armedState     := 0
        lastSignalBar  := bar_index
    else if armedState == -1 and closedBelowUpperInner and okHTF_Short
        fireRevertShort := true
        state           := -1
        armedState      := 0
        lastSignalBar   := bar_index

float devCloseAbs      = vwapNa ? na : math.abs(close - vwap)
bool  touchedVWAP_body = not vwapNa and not na(devCloseAbs) and devCloseAbs <= exitTol
bool  touchedVWAP      = useBodyExit ? touchedVWAP_body : touchedVWAP_any

bool fireInvalidation = false
bool fireTakeProfit   = false
int  statePrev        = bar_index > 0 ? state[1] : 0

if statePrev != 0
    if touchedVWAP
        fireTakeProfit := true
        state          := 0
    else if (statePrev == 1 and touchedLowerOuter) or (statePrev == -1 and touchedUpperOuter) or isNewAnchor
        fireInvalidation := true
        state            := 0

// =============================================================================
// ===== 6. PLOTS (BR-18: ONE block, AFTER all variable declarations) ==========
// =============================================================================
color cAnchorBg = color.new(color.white, 95)
color cBear30   = color.new(colBear, 30)
color cBear60   = color.new(colBear, 60)
color cBear90   = color.new(colBear, 90)
color cBear95   = color.new(colBear, 95)
color cBull30   = color.new(colBull, 30)
color cBull60   = color.new(colBull, 60)
color cBull90   = color.new(colBull, 90)
color cBull95   = color.new(colBull, 95)

bgcolor(showAnchorBg and isNewAnchor ? cAnchorBg : na, title="Anchor Reset Point")

p_uo = plot(upperOuter, "Upper Outer",  color=cBear30, linewidth=1)
p_ui = plot(upperInner, "Upper Inner",  color=cBear60, linewidth=1)
p_vw = plot(bridgeVWAP, "Anchored VWAP", color=colVWAP, linewidth=2)
p_li = plot(lowerInner, "Lower Inner",  color=cBull60, linewidth=1)
p_lo = plot(lowerOuter, "Lower Outer",  color=cBull30, linewidth=1)

fill(p_uo, p_ui, color=cBear90, title="Short Exhaustion Zone")
fill(p_ui, p_vw, color=cBear95, title="Upper Value Zone")
fill(p_vw, p_li, color=cBull95, title="Lower Value Zone")
fill(p_li, p_lo, color=cBull90, title="Long Exhaustion Zone")

// Entry signals (BR-09: direct barstate.isconfirmed)
plotshape(fireRevertLong  and barstate.isconfirmed, "Revert Long",  shape.triangleup,   location.belowbar, colBull, size=size.small, text="Revert")
plotshape(fireRevertShort and barstate.isconfirmed, "Revert Short", shape.triangledown, location.abovebar, colBear, size=size.small, text="Revert")

// TP marker (BR-09: direct inline guard)
plotshape(fireTakeProfit and barstate.isconfirmed ? vwap : na, "TP Halo",        shape.circle, location.absolute, color.new(color.black, 0), size=size.small)
plotshape(fireTakeProfit and barstate.isconfirmed ? vwap : na, "Target Reached", shape.circle, location.absolute, color.new(color.white, 0), size=size.tiny)

// Invalidation marker (BR-09: direct inline guard)
plotshape(fireInvalidation and barstate.isconfirmed ? close : na, "Invalidated", shape.xcross, location.absolute, color.new(color.rgb(255, 0, 0), 0), size=size.small)

// =============================================================================
// ===== 7. TRADE TRAJECTORY VECTORS ===========================================
// =============================================================================
var int   tradeEntryBar   = na
var float tradeEntryPrice = na

if fireRevertLong or fireRevertShort
    tradeEntryBar   := bar_index
    tradeEntryPrice := close

var line[]  kasLines  = array.new_line()
var label[] kasLabels = array.new_label()

if fireTakeProfit and barstate.isconfirmed and showVectors and not na(tradeEntryPrice) and tradeEntryPrice != 0.0
    float movePct = ((vwap - tradeEntryPrice) / tradeEntryPrice) * 100.0
    if statePrev == -1
        movePct := movePct * -1.0
    string labelText = "TP | +" + str.tostring(math.abs(movePct), "0.00") + "%"
    array.push(kasLines,  line.new(x1=tradeEntryBar, y1=tradeEntryPrice, x2=bar_index, y2=vwap,  color=color.new(colVWAP, 20), width=2, style=line.style_arrow_right))
    array.push(kasLabels, label.new(x=bar_index, y=vwap,  text=labelText, color=color.new(colBull, 85), textcolor=colBull, style=label.style_label_down, size=size.small))

if fireInvalidation and barstate.isconfirmed and showVectors and not na(tradeEntryPrice) and tradeEntryPrice != 0.0
    float movePct = ((close - tradeEntryPrice) / tradeEntryPrice) * 100.0
    if statePrev == -1
        movePct := movePct * -1.0
    string labelText = "STOP | " + str.tostring(movePct, "0.00") + "%"
    array.push(kasLines,  line.new(x1=tradeEntryBar, y1=tradeEntryPrice, x2=bar_index, y2=close, color=color.new(colBear, 20), width=2, style=line.style_arrow_right))
    array.push(kasLabels, label.new(x=bar_index, y=close, text=labelText, color=color.new(colBear, 85), textcolor=colBear, style=label.style_label_up,   size=size.small))

// Garbage Collection (max 50 vectors)
while array.size(kasLines)  > 50
    line.delete(array.shift(kasLines))
while array.size(kasLabels) > 50
    label.delete(array.shift(kasLabels))

// =============================================================================
// ===== 8. DASHBOARD (BR-05: delete->new | BR-06: white text) =================
// =============================================================================
if showDash and barstate.islast
    if not na(dash)
        table.delete(dash)
    dash := table.new(getDashPos(dashPosInput), 2, 5, border_width=1)

    color cGray80 = color.new(color.gray, 80)
    color cGray60 = color.new(color.gray, 60)
    color cBlack0 = color.new(color.black, 0)
    color cRed30  = color.new(color.rgb(255, 0, 0), 30)
    color cBlue70 = color.new(color.rgb(0, 120, 255), 70)
    color cVWAP20 = color.new(colVWAP, 20)

    string sState = state == 1 ? "ACTIVE (LONG)" : state == -1 ? "ACTIVE (SHORT)" : "NEUTRAL"
    color  cState = state > 0 ? cBull60 : state < 0 ? cBear60 : cGray80

    float devPctCalc = not vwapNa and vwap != 0.0 ? ((close - vwap) / vwap) * 100.0 : 0.0
    color cDev       = devPctCalc > 0.0 ? color.new(colBear, 70) : color.new(colBull, 70)
    color cHTF       = htfBull ? cBull60 : htfBear ? cBear60 : cGray60

    table.cell(dash, 0, 0, "Reversion State",     text_color=color.white, bgcolor=cBlack0)
    table.cell(dash, 1, 0, sState,                text_color=color.white, bgcolor=cState)

    table.cell(dash, 0, 1, "Current VWAP",        text_color=color.white, bgcolor=cBlack0)
    table.cell(dash, 1, 1, vwapNa ? "n/a" : str.tostring(vwap, format.mintick), text_color=color.white, bgcolor=cVWAP20)

    table.cell(dash, 0, 2, "Price vs VWAP",       text_color=color.white, bgcolor=cBlack0)
    table.cell(dash, 1, 2, str.tostring(devPctCalc, "0.00") + " %", text_color=color.white, bgcolor=cDev)

    table.cell(dash, 0, 3, "HTF EMA 200",         text_color=color.white, bgcolor=cBlack0)
    table.cell(dash, 1, 3, htfBull ? "BULL (above EMA200)" : "BEAR (below EMA200)", text_color=color.white, bgcolor=cHTF)

    table.cell(dash, 0, 4, "ATR Filter Gate",     text_color=color.white, bgcolor=cBlack0)
    table.cell(dash, 1, 4, atrGateTxt,            text_color=color.white, bgcolor=isLowVol ? cRed30 : cBlue70)

// =============================================================================
// ===== 9. ALERTS (BR-09: English ASCII + {{ticker}} {{interval}} {{close}}) ==
// =============================================================================
alertcondition(fireRevertLong,
  "KAS VWAP: Revert Long (ENTRY)",
  "VWAP Long Entry | {{ticker}} | TF {{interval}} | Close={{close}} | Price exhausted at Lower Outer Band. Mean-reversion long setup active.")

alertcondition(fireRevertShort,
  "KAS VWAP: Revert Short (ENTRY)",
  "VWAP Short Entry | {{ticker}} | TF {{interval}} | Close={{close}} | Price exhausted at Upper Outer Band. Mean-reversion short setup active.")

alertcondition(fireTakeProfit,
  "KAS VWAP: Target Reached (EXIT)",
  "VWAP Take Profit | {{ticker}} | TF {{interval}} | Close={{close}} | Price returned to VWAP baseline. Mean-reversion target reached.")

alertcondition(fireInvalidation,
  "KAS VWAP: Invalidated (STOP)",
  "VWAP Invalidated | {{ticker}} | TF {{interval}} | Close={{close}} | Price extended beyond opposite band. Trade invalidated.")
````
