# Delta Heiken Ashi

- url: https://www.tradingview.com/script/jMocVx8c-Delta-Heiken-Ashi/
- type: indicator
- pine_id: PUB;c8cfd7095a264e55850acb0d8e1a4f5f
- version: 2.0

## Description

Heiken Ashi candles colored by estimated buying/selling pressure.
Standard HA candles smooth price action but lose information about what's happening inside each bar. This indicator adds that back by approximating delta (net buying vs selling volume) and using it to color each bar into one of three momentum states:
[list]
[*]Strong — Pressure is accelerating in the trend direction. Conviction is high.
[*]Moderate — Pressure is flat. Trend intact but unconfirmed.
[*]Fading — Pressure is decelerating or contradicting the move. Momentum is dying. Watch for a turn.
[/list]
The result is a cleaner visual read on when trends have real participation behind them and when they're running on fumes.
⚠️ Important: This is not true delta. True order flow requires bid/ask volume from Level 2 data, which TradingView does not provide. This indicator approximates delta by attributing volume based on where price closes within each bar's range. It's directionally useful but it is an estimate, not actual order flow. Don't confuse the two.
Features:

[list]
[*]3-tier momentum coloring (fully customizable colors)
[*]Optional momentum shift markers (fading → strong transitions)
[*]Optional delta zero-cross signals
[*]Configurable alerts for all signal types
[*]Works on any instrument and timeframe
[*]No premium data required
[/list]

## Source Code

````pine
// © TatankaTrading
//@version=6
indicator("Delta Heiken Ashi", overlay = true, max_labels_count = 500)
// ============================================================================
// INPUTS
// ============================================================================
g_ha = "═══ Heiken Ashi ═══"
i_show = input.bool(true, "Show HA Candles", group = g_ha)
g_delta = "═══ Delta Engine ═══"
i_deltaLen = input.int(4, "Delta EMA Length", minval = 1, maxval = 30, tooltip = "Smoothing on raw delta. Lower = more responsive, noisier.", group = g_delta)
i_momLen   = input.int(6, "Momentum SMA Length", minval = 2, maxval = 30, tooltip = "Delta's own moving average. Delta above/below this = accelerating/decelerating.", group = g_delta)
g_signals = "═══ Signals ═══"
i_showTrans  = input.bool(false, "Show Momentum Shift Markers", tooltip = "Triangle when delta momentum shifts from fading to strong (new conviction).", group = g_signals)
i_showFlip   = input.bool(false, "Show Delta Zero Cross", tooltip = "Dot when delta crosses zero (buyers/sellers taking control).", group = g_signals)
i_alerts     = input.bool(false, "Enable Alerts", group = g_signals)
g_bear = "═══ Bear Colors ═══"
i_bearStrong = input.color(color.rgb(200, 25, 25),   "Strong",   inline = "b", group = g_bear)
i_bearMod    = input.color(color.rgb(170, 80, 90),    "Moderate", inline = "b", group = g_bear)
i_bearFade   = input.color(color.rgb(140, 120, 130),   "Fading",   inline = "b", group = g_bear)
g_bull = "═══ Bull Colors ═══"
i_bullStrong = input.color(color.rgb(0, 180, 255),    "Strong",   inline = "u", group = g_bull)
i_bullMod    = input.color(color.rgb(60, 130, 175),    "Moderate", inline = "u", group = g_bull)
i_bullFade   = input.color(color.rgb(110, 140, 155),   "Fading",   inline = "u", group = g_bull)
// ============================================================================
// HEIKEN ASHI
// ============================================================================
var float haClose = na
var float haOpen  = na
haClose := (open + high + low + close) / 4.0
haOpen  := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
float haHigh   = math.max(high, math.max(haOpen, haClose))
float haLow    = math.min(low, math.min(haOpen, haClose))
bool  is_haBear = haClose < haOpen
// ============================================================================
// DELTA ENGINE
// ============================================================================
float barRange = high - low
float deltaRaw = barRange > 0 ? volume * ((close - open) / barRange) : 0.0
float delta    = ta.ema(deltaRaw, i_deltaLen)
float deltaMa  = ta.sma(delta, i_momLen)
// Normalize distance from MA for tier classification
float maGap    = delta - deltaMa
float maGapMax = ta.highest(math.abs(maGap), i_momLen * 5)
float maGapPct = maGapMax > 0 ? maGap / maGapMax : 0.0
// ============================================================================
// 3-TIER STATE CLASSIFICATION
// ============================================================================
// Contrary: delta sign opposes HA direction (buyers in a bear bar or vice versa)
bool is_contrary = is_haBear ? (delta > 0) : (delta < 0)
// Accelerating: delta pulling away from MA in the HA direction
bool is_accel = is_haBear ? (maGapPct < -0.15) : (maGapPct > 0.15)
// Decelerating: delta clearly moving back toward/past MA against HA direction
bool is_decel = is_haBear ? (maGapPct > 0.15) : (maGapPct < -0.15)
// State: 2 = strong, 1 = moderate, 0 = fading
var int state = 1
if is_contrary or is_decel
    state := 0
else if is_accel
    state := 2
else
    state := 1
// ============================================================================
// TRANSITION DETECTION
// ============================================================================
int prevState = nz(state[1], 1)
// Fading → Strong = new conviction (potential entry signal)
bool is_bullShift = not is_haBear and prevState == 0 and state == 2
bool is_bearShift = is_haBear and prevState == 0 and state == 2
// Delta zero cross
bool is_deltaFlipBull = delta > 0 and delta[1] <= 0
bool is_deltaFlipBear = delta < 0 and delta[1] >= 0
// ============================================================================
// COLOR
// ============================================================================
color bearClr = state == 2 ? i_bearStrong : state == 1 ? i_bearMod : i_bearFade
color bullClr = state == 2 ? i_bullStrong : state == 1 ? i_bullMod : i_bullFade
color finalClr = is_haBear ? bearClr : bullClr
// ============================================================================
// PLOT
// ============================================================================
barcolor(i_show ? color.new(color.black, 100) : na)
plotcandle(
     i_show ? haOpen  : na,
     i_show ? haHigh  : na,
     i_show ? haLow   : na,
     i_show ? haClose : na,
     title       = "Delta HA",
     color       = finalClr,
     wickcolor   = finalClr,
     bordercolor = finalClr)
// ─── Momentum Shift Markers ─────────────────────────────────────────
MARKER_OFFSET = ta.atr(14) * 0.3
plotshape(
     i_showTrans and is_bullShift ? haLow - MARKER_OFFSET * 2: na,
     title    = "Bull Shift",
     style    = shape.triangleup,
     location = location.absolute,
     color    = i_bullStrong,
     size     = size.tiny)
plotshape(
     i_showTrans and is_bearShift ? haHigh + MARKER_OFFSET * 2: na,
     title    = "Bear Shift",
     style    = shape.triangledown,
     location = location.absolute,
     color    = i_bearStrong,
     size     = size.tiny)
// ─── Delta Zero Cross ───────────────────────────────────────────────
plotshape(
     i_showFlip and is_deltaFlipBull ? haLow - MARKER_OFFSET : na,
     title    = "Delta Flip Bull",
     style    = shape.circle,
     location = location.absolute,
     color    = i_bullStrong,
     size     = size.tiny)
plotshape(
     i_showFlip and is_deltaFlipBear ? haHigh + MARKER_OFFSET  : na,
     title    = "Delta Flip Bear",
     style    = shape.circle,
     location = location.absolute,
     color    = i_bearStrong,
     size     = size.tiny)
// ============================================================================
// ALERTS
// ============================================================================
if i_alerts and is_bullShift
    alert("DELTA HA — Bull momentum shift @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
if i_alerts and is_bearShift
    alert("DELTA HA — Bear momentum shift @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
if i_alerts and is_deltaFlipBull
    alert("DELTA HA — Delta flipped positive @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
if i_alerts and is_deltaFlipBear
    alert("DELTA HA — Delta flipped negative @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
````
