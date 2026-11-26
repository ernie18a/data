# CQ_(L)_Oscillators Overlay

- url: https://www.tradingview.com/script/tw8lIwW1-CQ-L-Oscillators-Overlay/
- type: indicator
- pine_id: PUB;97d04b8bccee42d2a43821aabb28daac
- version: 1.0

## Description

================================================================================
CQ_(L)_OSCILLATORS OVERLAY
User Manual
================================================================================

OVERVIEW
--------------------------------------------------------------------------------
This indicator takes a sub-pane oscillator engine (originally built for a
separate pane) and re-renders it directly on the price chart as an overlay.
You choose one of eight oscillator types, and the script draws it as a
scaled, floating panel above or below price action, using a rolling window
of recent bars. It borrows its array-based collection/redraw technique and
box-drawing style from the CQ Larry Williams Vix Fix overlay script.

Because the oscillator is bidirectional (it can swing both above and below
its own midline, unlike Vix Fix which only measures magnitude), the drawing
engine scales values based on distance from the midline rather than raw
value, and can mirror in either direction.


SECTION 1 — INDICATOR SELECTION
--------------------------------------------------------------------------------
A dropdown lets you choose which oscillator drives the overlay:

  MACD        - Standard MACD/Signal/Histogram
  VMACD       - Volume-weighted MACD (volume-weighted EMAs)
  RSI         - Relative Strength Index
  MFI         - Money Flow Index (volume-weighted RSI)
  CCI         - Commodity Channel Index
  DRM         - Directional Range Momentum (custom range-breakout momentum)
  Stochastic  - Standard %K / %D
  Stoch RSI   - Stochastic applied to RSI instead of price

A second dropdown ("Trend") controls an optional trend filter used by the
buy/sell signal logic:

  Off             - No trend filter; signals fire on oscillator conditions alone
  200 EMA Trend   - Filters signals using a 200-period EMA of price
  VWAP Trend      - Filters signals using session VWAP instead of the 200 EMA
  Range           - Same trend line, but skips the "must agree with trend"
                    requirement (used for range-bound markets)


SECTION 2 — COLOR & LINE STYLE
--------------------------------------------------------------------------------
- Two color pickers set the oscillator line color and the
  basis/signal line color.
- "Alternate Colors" toggle: when on, the signal/basis line becomes
  transparent, and the main oscillator line instead turns green when above
  its midline and red when below it (a simple directional color scheme).


SECTION 3 — MACD / VW-MACD SETTINGS
--------------------------------------------------------------------------------
  Fast Length    (default 12)
  Slow Length    (default 26)
  Signal Length  (default 9)

These only apply when MACD or VMACD is the selected indicator. VMACD uses
volume-weighted EMAs instead of plain EMAs for the fast/slow lines.


SECTION 4 — OSCILLATOR SETTINGS (RSI / Stochastic family)
--------------------------------------------------------------------------------
  Length      (default 14) - lookback for RSI, MFI, CCI, DRM, or Stochastic %K
  Smoothing   (default 3)  - smoothing applied to the raw oscillator/%K
  Signal      (default 14) - length of the basis/EMA signal line, or %D length

OB/OS (Overbought/Oversold)
  OB/OS value   (default 70) - sets the overbought line; the oversold line is
                                mirrored automatically around the midline
  Extreme       (default 10) - added to OB/OS to define an "Extreme" zone
                                (used for stronger/"slow-cooldown" signals)

Volume Pressure
  A toggle that overlays a secondary line built from a fast/slow blended MFI
  reading, compressed through a power curve. Useful as a volume-based
  confirmation line drawn against the same midline.

Options row
  Fill Lines   - shades the area between the oscillator and its basis line
                 (blue when oscillator is above basis, orange when below)
  Fill OB/OS   - shades the area between the oscillator and the OB/OS
                 reference lines when price pushes into those zones
                 (deeper shade in the "Extreme" zone)
  Divergence   - draws bullish/bearish divergence lines and labels comparing
                 price pivots against oscillator pivots


SECTION 5 — OVERLAY DISPLAY OPTIONS (Group: "OVERLAY — Display Options")
--------------------------------------------------------------------------------
  Number of Bars to Show   (default 50, max 150)
      How many of the most recent bars are drawn in the overlay panel.
      Capped at 150 to respect TradingView's per-indicator object budget.

  Oscillator Height        (default 300, price units)
      The vertical distance (in price units) that the extreme OB/OS+Extreme
      value is stretched out to, measured from the panel's baseline.

  Separation from Price    (default 150%, range 100-1400%)
      How far the panel's baseline sits from the highest/lowest visible
      candle. 100% means the baseline touches price; higher values add gap.

  Placement                (Top / Bottom, default Bottom)
      Whether the panel is drawn above the visible highs or below the
      visible lows.

  Flip Upside Down
      Mirrors the panel vertically (useful if you prefer overbought
      readings to point toward price rather than away from it).

  Show OB/Mid/OS Reference Lines
      Draws dotted horizontal lines marking the midline, overbought, and
      oversold levels across the visible window.

  Show OB/OS Zone Fill
      Shades the band between the OB and OS reference lines.


SECTION 6 — HOW THE OVERLAY IS DRAWN (for reference)
--------------------------------------------------------------------------------
Each bar's oscillator, basis, histogram, and volume-pressure values are
pushed into rolling arrays capped at "Number of Bars to Show." On the last
bar, all previous drawings are deleted and redrawn:

  1. A baseline price level is computed from the visible high/low range,
     offset by Height x Separation%.
  2. A scale factor ("wMax") is derived from the OB+Extreme distance and the
     actual oscillator/basis range, so the panel never clips.
  3. Oscillator and basis values are converted to price-scale y-coordinates
     relative to the midline and drawn as connected line segments.
  4. For MACD/VMACD, histogram bars are drawn as thin boxes from the
     baseline out to each bar's scaled histogram value, colored by
     rising/falling and above/below-zero state.
  5. A text label with the selected indicator's name is placed at the end
     of the panel.

This mirrors the same rolling-window / redraw-on-last-bar technique used in
the Vix Fix overlay script, adapted for a two-sided (bidirectional)
oscillator instead of a one-sided magnitude series.


SECTION 7 — SIGNALS & ALERTS
--------------------------------------------------------------------------------
MACD Signals (only when MACD is selected)
  - Buy:  MACD crosses over Signal while price is above the trend EMA/VWAP,
          and the cross happens at or near zero (MACD or its prior value
          below zero).
  - Sell: Mirror image condition for a bearish cross.
  - Both have dedicated alertcondition() alerts.

Oscillator Signals (RSI, CCI, DRM, Stochastic, Stoch RSI)
  Two signal speeds, each with its own cooldown to prevent rapid repeat
  firing:
    Fast  (5-bar cooldown) - oscillator crosses its basis line while still
                              inside normal territory, OR crosses the
                              "Extreme" OB/OS+Extreme level.
    Slow  (10-bar cooldown) - oscillator crosses the standard OB/OS level.
  If the Trend filter is not "Off" or "Range", signals additionally require
  price to agree with the trend EMA/VWAP direction.
  Buy/Sell background highlighting (green/red) marks bars where any of
  these signals fire, matched to whichever oscillator is active.


SECTION 8 — DIVERGENCE
--------------------------------------------------------------------------------
When "Divergence" is enabled, the script compares 5-bar-left/5-bar-right
pivot highs and lows in price against the oscillator's own pivots:
  - Bullish divergence: price makes a lower low while the oscillator makes
    a higher low -> green line + "Bull Div" label below the bar.
  - Bearish divergence: price makes a higher high while the oscillator
    makes a lower high -> red line + "Bear Div" label above the bar.


SECTION 9 — PRACTICAL NOTES & LIMITS
--------------------------------------------------------------------------------
- "Number of Bars to Show" is capped at 150 bars to stay within Pine's
  line/box drawing budget when combined with fills, reference lines, and
  histogram boxes.
- The overlay drawing loop stops adding new line objects once the combined
  oscillator + basis + volume-pressure line count reaches 480, as a safety
  margin under the 500-object limit declared at the top of the script.
- Volume Pressure, Fill Lines, Fill OB/OS, and Divergence are independent
  toggles and can be combined freely, but turning on several at once with a
  high bar count will use more of the drawing budget.
- OB/OS zone fill and reference lines are skipped for MACD/VMACD, since
  those use a zero-centered histogram instead of a fixed OB/OS band.
- All original oscillator calculations run on the current chart's timeframe
  by default (the internal multi-timeframe parameter is left blank), so the
  overlay reflects the chart timeframe you have open.

================================================================================
End of manual — CQ_(L)_Oscillators Overlay
================================================================================

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CQuevedo345
// Oscillator engine based on open-source work by TheeHoganator:
// https://www.tradingview.com/script/ (CQ_(L)_Oscillators)
// Overlay rendering engine adapted from CQ_(A)_Larry Williams Vix Fix V4:
// array-based rolling window collection, price-scaled box/line drawing on barstate.islast,
// height / separation / placement / flip controls.

//@version=6
indicator(title = 'CQ_(L)_Oscillators Overlay', overlay = true, precision = 2,
     max_bars_back = 500, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────────────────────────────────────
Black   = #000000
Charcoal= #363A45
Gray    = #787B86
Silver  = #C0C0C0
White   = #FFFFFF
Red     = #FF0000
Green   = #00B060
Aqua    = #00BCD4
None    = color.new(Black, 100)

col_grow_above = #26A69A
col_fall_above = #B2DFDB
col_grow_below = #FFCDD2
col_fall_below = #EF5350


// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — Indicator Selection
// ─────────────────────────────────────────────────────────────────────────────
source = close

IndicatorSelection = input.string(defval = 'MACD', title = '', options = ['MACD', 'RSI', 'CCI', 'DRM', 'VMACD', 'MFI', 'Stochastic', 'Stoch RSI'], inline = 'Indicator')
bMACD       = IndicatorSelection == 'MACD' or IndicatorSelection == 'VMACD'
bRSI        = IndicatorSelection == 'RSI'  or IndicatorSelection == 'MFI'
bCCI        = IndicatorSelection == 'CCI'
bDRM        = IndicatorSelection == 'DRM'
bVWMACD     = IndicatorSelection == 'VMACD'
bMFI        = IndicatorSelection == 'MFI'
bStochastic = IndicatorSelection == 'Stochastic'
bstochRSI   = IndicatorSelection == 'Stoch RSI'

tf = ''
TrendSelection = input.string(defval = 'Off', title = 'Trend', options = ['Off', '200 EMA Trend', 'VWAP Trend', 'Range'], inline = 'Indicator')
bVWAP = TrendSelection == 'VWAP Trend'
bTrendSignalFilter = TrendSelection != 'Range'
bSignals = TrendSelection != 'Off'

col_osc     = input.color(#0094ff, '', inline = 'Indicator')
col_osc_ema = input.color(#ff6a00, '', inline = 'Indicator')
bAlt_col    = input.bool(false, '', inline = 'Indicator',
     tooltip = "First color is the leading line, second is the signal line.\n'Alternate Colors' makes the signal line transparent and colors the leading line blue/red depending on whether it's above/below the middle line.")

fast_length   = input.int(title = '(VW)MACD', defval = 12, inline = 'MACD Settings')
slow_length   = input.int(title = '',         defval = 26, inline = 'MACD Settings')
signal_length = input.int(title = '',         defval = 9,  inline = 'MACD Settings', tooltip = 'Fast, Slow, Signal')
histSize      = 2


// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — Oscillator Settings
// ─────────────────────────────────────────────────────────────────────────────
length       = input.int(title = 'RSI/Stoch', minval = 1, defval = 14, inline = 'OSC Length')
smoothlength = input.int(title = '',          minval = 1, defval = 3,  inline = 'OSC Length')
ema_length   = input.int(title = '',          minval = 1, defval = 14, inline = 'OSC Length', tooltip = 'Length, Smoothing, Signal')

obNumber = input.int(title = 'OB/OS', minval = 51, defval = 70, inline = 'OB/OS')
miNumber = bMACD or bVWMACD or bCCI ? 0 : 50
osNumber = miNumber - (obNumber - miNumber)

extreme = input.int(title = 'Extreme', defval = 10, minval = 0, inline = 'OB/OS',
     tooltip = "OB/OS value plus this amount marks the 'Extreme' zone (mirrored for OS).")

bVPMid     = input.bool(title = 'Volume Pressure', defval = false, inline = 'OB/OS')
bFillLines = input(false, 'Fill Lines', inline = 'options')
bFillOBOS  = input(false, 'Fill OB/OS', inline = 'options')
bDivergence = input(false, 'Divergence', inline = 'options')


// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — Overlay Layout  (engine adapted from the Vix Fix overlay script)
// ─────────────────────────────────────────────────────────────────────────────
grpDisp = 'OVERLAY — Display Options'

i_nBars     = input.int(50, title = 'Number of Bars to Show', minval = 5, maxval = 150, group = grpDisp,
     tooltip = 'Capped at 150 to stay within the platform line-drawing budget.')
i_height    = input.float(300, title = 'Oscillator Height (price units)', minval = 10, step = 25, group = grpDisp,
     tooltip = 'Price-unit distance the extreme OB/OS+Extreme value is scaled out to from the baseline.')
i_histSep   = input.int(150, title = 'Separation from Price (% of Height)', minval = 100, maxval = 1400, step = 5, group = grpDisp,
     tooltip = '100 = baseline touches the highest/lowest visible candle. Higher = more gap.')
i_placement = input.string('Bottom', title = 'Placement', options = ['Top', 'Bottom'], group = grpDisp)
i_flip      = input.bool(false, title = 'Flip Upside Down', group = grpDisp)
i_showRef   = input.bool(true, title = 'Show OB/Mid/OS Reference Lines', group = grpDisp)
i_showZone  = input.bool(true, title = 'Show OB/OS Zone Fill', group = grpDisp)


// ─────────────────────────────────────────────────────────────────────────────
//  CALCULATIONS — MACD / VW-MACD
// ─────────────────────────────────────────────────────────────────────────────
fast_ma = bVWMACD ? (ta.ema(volume * source, fast_length) / ta.ema(volume, fast_length)) : ta.ema(source, fast_length)
slow_ma = bVWMACD ? (ta.ema(volume * source, slow_length) / ta.ema(volume, slow_length)) : ta.ema(source, slow_length)

outmacd   = 10000 * (fast_ma - slow_ma) / slow_ma
outsignal = ta.ema(outmacd, signal_length)
outhist   = (outmacd - outsignal) * histSize

[macd, signal, hist] = request.security(syminfo.tickerid, tf, [outmacd, outsignal, outhist], gaps = barmerge.gaps_off)

col_hist = None
col_hist := hist > 0 ? (hist > hist[1] ? col_grow_above : hist < hist[1] ? col_fall_above : col_hist[1]) : (hist > hist[1] ? col_grow_below : hist < hist[1] ? col_fall_below : col_hist[1])


// ─────────────────────────────────────────────────────────────────────────────
//  CALCULATIONS — CCI
// ─────────────────────────────────────────────────────────────────────────────
ccisrc = hlc3
ma  = ta.sma(ccisrc, length)
cci = (ccisrc - ma) / (0.015 * ta.dev(ccisrc, length))


// ─────────────────────────────────────────────────────────────────────────────
//  CALCULATIONS — DRM
// ─────────────────────────────────────────────────────────────────────────────
smooth(series float s, simple int n, simple string m) =>
    switch m
        'EMA' => ta.ema(s, n)
        'SMA' => ta.sma(s, n)
        'RMA' => ta.rma(s, n)
        'TMA' => ta.sma(ta.sma(s, n), n)
        =>      ta.rma(s, n)

float rangePeak  = ta.highest(source, length)
float rangeValey = ta.lowest(source, length)
float rangeSpan  = rangePeak - rangeValey
float tickDelta  = source - source[1]
float rangeForce = rangePeak > rangePeak[1] ? rangeSpan : rangeValey < rangeValey[1] ? -rangeSpan : tickDelta

float sUp  = smooth(rangeForce, length, 'RMA')
float sAbs = smooth(math.abs(rangeForce), length, 'RMA')


// ── Volume Pressure — dual MFI with power-curve compression ──────────────────
compress(series float x, simple float k) =>
    float n = (x / 100.0 - 0.5) * 2.0
    k * 100.0 * (n > 0 ? 1.0 : -1.0) * math.pow(math.abs(n), 0.75)

int   vpFastLen = math.max(math.round(length / 1.33), 2)
int   vpSlowLen = math.round(length * 1.33)
float vpSrcVal  = hlc3
float vpFastRaw = ta.mfi(vpSrcVal, vpFastLen)
float vpSlowRaw = ta.mfi(vpSrcVal, vpSlowLen)
float vpMid     = (compress(ta.sma(vpFastRaw * 0.5 + vpSlowRaw * 0.5, 2), 0.7) / 2.0) * ((obNumber - miNumber) / 30) + miNumber


// ─────────────────────────────────────────────────────────────────────────────
//  CALCULATIONS — Stochastic / Stoch RSI
// ─────────────────────────────────────────────────────────────────────────────
StochKlength = length
StochKsmooth = smoothlength
StochDlength = ema_length

rsi    = ta.rsi(source, length)
StochK = bstochRSI ? ta.sma(ta.stoch(rsi, rsi, rsi, StochKlength), StochKsmooth) : ta.sma(ta.stoch(close, high, low, StochKlength), StochKsmooth)
StochD = ta.sma(StochK, StochDlength)


// ─────────────────────────────────────────────────────────────────────────────
//  CALCULATIONS — Composite Oscillator / Basis / Trend
// ─────────────────────────────────────────────────────────────────────────────
outosc   = bMFI ? ta.ema(ta.mfi(source, length), smoothlength) : bRSI ? ta.ema(ta.rsi(source, length), smoothlength) : bCCI ? ta.ema(ta.cci(hlc3, length), smoothlength) : bDRM ? ta.ema((sAbs != 0 ? (sUp / sAbs) * 50.0 + 50.0 : 50.0), smoothlength) : bStochastic or bstochRSI ? StochK : na
outbasis = bRSI or bCCI or bDRM or bMFI ? ta.ema(outosc, ema_length) : bStochastic or bstochRSI ? ta.sma(StochK, StochDlength) : na
outTrend = bVWAP ? ta.vwap(close) : ta.ema(source, 200)

[MTFosc, MTFbasis, MTFema] = request.security(syminfo.tickerid, tf, [outosc, outbasis, outTrend], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

osc      = bMACD ? macd   : MTFosc
basis    = bMACD ? signal : MTFbasis
TrendEMA = MTFema


// ─────────────────────────────────────────────────────────────────────────────
//  SIGNALS — MACD Cross
// ─────────────────────────────────────────────────────────────────────────────
bMACDCrossOver  = ta.crossover(macd, signal)
bMACDCrossUnder = ta.crossunder(macd, signal)

MACDBuySignal  = bMACD and (hlc3 > TrendEMA and bMACDCrossOver  and (macd < 0 or macd[1] < 0))
MACDSellSignal = bMACD and (hlc3 < TrendEMA and bMACDCrossUnder and (macd > 0 or macd[1] > 0))

alertcondition(MACDBuySignal,  title = 'MACD Buy Signal',  message = '{{ticker}} MACD Buy Signal on the {{interval}} chart')
alertcondition(MACDSellSignal, title = 'MACD Sell Signal', message = '{{ticker}} MACD Sell Signal on the {{interval}} chart')


// ─────────────────────────────────────────────────────────────────────────────
//  SIGNALS — Oscillator Cross (fast / slow cooldown)
// ─────────────────────────────────────────────────────────────────────────────
bOscCrossOver     = ta.crossover(osc, basis)
bOscCrossUnder    = ta.crossunder(osc, basis)
bOscCrossOverOS   = ta.crossover(osc, osNumber)
bOscCrossUnderOB  = ta.crossunder(osc, obNumber)
bOscCrossOverSOS  = ta.crossover(osc, osNumber - extreme)
bOscCrossUnderSOB = ta.crossunder(osc, obNumber + extreme)

CooldownFast = 5
CooldownSlow = 10

var int lastBuyFastBar  = na
var int lastBuySlowBar  = na
var int lastSellFastBar = na
var int lastSellSlowBar = na

buyFastCond = (bOscCrossOver and osc < osNumber) or bOscCrossOverSOS
buySlowCond = bOscCrossOverOS
canBuyFast  = na(lastBuyFastBar) or (bar_index - lastBuyFastBar >= CooldownFast)
canBuySlow  = na(lastBuySlowBar) or (bar_index - lastBuySlowBar >= CooldownSlow)
buyTrendOK  = not bTrendSignalFilter or (hl2 > TrendEMA and close > TrendEMA)

OscBuySignalFast = buyFastCond and canBuyFast and buyTrendOK
OscBuySignalSlow = buySlowCond and canBuySlow and buyTrendOK and not OscBuySignalFast
OscBuySignalCooledDown = OscBuySignalFast or OscBuySignalSlow

if OscBuySignalFast
    lastBuyFastBar := bar_index
    lastBuySlowBar := bar_index
else if OscBuySignalSlow
    lastBuySlowBar := bar_index

sellFastCond = (bOscCrossUnder and osc > obNumber) or bOscCrossUnderSOB
sellSlowCond = bOscCrossUnderOB
canSellFast  = na(lastSellFastBar) or (bar_index - lastSellFastBar >= CooldownFast)
canSellSlow  = na(lastSellSlowBar) or (bar_index - lastSellSlowBar >= CooldownSlow)
sellTrendOK  = not bTrendSignalFilter or (hl2 < TrendEMA and close < TrendEMA)

OscSellSignalFast = sellFastCond and canSellFast and sellTrendOK
OscSellSignalSlow = sellSlowCond and canSellSlow and sellTrendOK and not OscSellSignalFast
OscSellSignalCooledDown = OscSellSignalFast or OscSellSignalSlow

if OscSellSignalFast
    lastSellFastBar := bar_index
    lastSellSlowBar := bar_index
else if OscSellSignalSlow
    lastSellSlowBar := bar_index

RSIBuySignal  = bRSI and OscBuySignalCooledDown
RSISellSignal = bRSI and OscSellSignalCooledDown
CCIBuySignal  = bCCI and OscBuySignalCooledDown
CCISellSignal = bCCI and OscSellSignalCooledDown
DRMBuySignal  = bDRM and OscBuySignalCooledDown
DRMSellSignal = bDRM and OscSellSignalCooledDown
StochBuySignal  = bStochastic and OscBuySignalCooledDown
StochSellSignal = bStochastic and OscSellSignalCooledDown
StochRSIBuySignal  = bstochRSI and OscBuySignalCooledDown
StochRSISellSignal = bstochRSI and OscSellSignalCooledDown

bgcolor(bSignals and (MACDBuySignal or RSIBuySignal or CCIBuySignal or DRMBuySignal or StochBuySignal or StochRSIBuySignal) ? color.new(Green, 60) : na, editable = true, title = 'Long Signal')
bgcolor(bSignals and (MACDSellSignal or RSISellSignal or CCISellSignal or DRMSellSignal or StochSellSignal or StochRSISellSignal) ? color.new(Red, 60) : na, editable = true, title = 'Short Signal')


// ─────────────────────────────────────────────────────────────────────────────
//  DIVERGENCE
// ─────────────────────────────────────────────────────────────────────────────
lbLInput = 5
lbRInput = 5

float phOsc = ta.pivothigh(osc, lbLInput, lbRInput)
float plOsc = ta.pivotlow(osc, lbLInput, lbRInput)

var float plPriceMem = na
var float plOscMem   = na
var int   plIndexMem = na
if not na(plOsc)
    if not na(plPriceMem) and osc[lbRInput] > plOscMem and low[lbRInput] < plPriceMem
        if bDivergence
            line.new(plIndexMem, plPriceMem, bar_index - lbRInput, low[lbRInput], color = Green, width = 2)
            label.new(bar_index - lbRInput, low[lbRInput], 'Bull Div', yloc = yloc.belowbar, textcolor = Green, color = None, size = size.small, style = label.style_label_up)
    plPriceMem := low[lbRInput]
    plOscMem   := osc[lbRInput]
    plIndexMem := bar_index - lbRInput

var float phPriceMem = na
var float phOscMem   = na
var int   phIndexMem = na
if not na(phOsc)
    if not na(phPriceMem) and osc[lbRInput] < phOscMem and high[lbRInput] > phPriceMem
        if bDivergence
            line.new(phIndexMem, phPriceMem, bar_index - lbRInput, high[lbRInput], color = Red, width = 2)
            label.new(bar_index - lbRInput, high[lbRInput], 'Bear Div', yloc = yloc.abovebar, textcolor = Red, color = None, size = size.small, style = label.style_label_down)
    phPriceMem := high[lbRInput]
    phOscMem   := osc[lbRInput]
    phIndexMem := bar_index - lbRInput


// ─────────────────────────────────────────────────────────────────────────────
//  OVERLAY ENGINE — rolling window collection
//  (array technique adapted from the Vix Fix overlay script: push each bar,
//  trim to i_nBars)
// ─────────────────────────────────────────────────────────────────────────────
var float[] a_osc       = array.new_float()
var float[] a_basis     = array.new_float()
var float[] a_hist      = array.new_float()
var color[] a_histCol   = array.new_color()
var float[] a_vpMid     = array.new_float()
var int[]   a_bar_index = array.new_int()
var float[] a_low       = array.new_float()
var float[] a_high      = array.new_float()

array.push(a_osc,       osc)
array.push(a_basis,     basis)
array.push(a_hist,      bMACD ? hist : 0.0)
array.push(a_histCol,   col_hist)
array.push(a_vpMid,     vpMid)
array.push(a_bar_index, bar_index)
array.push(a_low,       low)
array.push(a_high,      high)

if array.size(a_osc) > i_nBars
    array.shift(a_osc)
    array.shift(a_basis)
    array.shift(a_hist)
    array.shift(a_histCol)
    array.shift(a_vpMid)
    array.shift(a_bar_index)
    array.shift(a_low)
    array.shift(a_high)


// ─────────────────────────────────────────────────────────────────────────────
//  OVERLAY ENGINE — draw  (barstate.islast redraw, mirrors the Vix Fix
//  overlay's box/line drawing block, but scaled by delta-from-midline / wMax
//  instead of raw magnitude, since this oscillator is bidirectional)
// ─────────────────────────────────────────────────────────────────────────────
var line[]     a_oscLines   = array.new_line()
var line[]     a_basisLines = array.new_line()
var line[]     a_vpLines    = array.new_line()
var box[]      a_histBoxes  = array.new_box()
var line[]     a_refLines   = array.new_line()
var box[]      a_zoneBox    = array.new_box()
var linefill[] a_fills      = array.new_linefill()
var label      titleLbl     = na

f_scaledY(float val, float base, float wMax, float ht, float mid, bool flip) =>
    float delta = val - mid
    base + (flip ? -1 : 1) * (delta / wMax) * ht

if barstate.islast
    // ── Clear previous drawings ───────────────────────────────────────────
    if array.size(a_oscLines) > 0
        for _i = 1 to array.size(a_oscLines)
            line.delete(array.shift(a_oscLines))
    if array.size(a_basisLines) > 0
        for _i = 1 to array.size(a_basisLines)
            line.delete(array.shift(a_basisLines))
    if array.size(a_vpLines) > 0
        for _i = 1 to array.size(a_vpLines)
            line.delete(array.shift(a_vpLines))
    if array.size(a_histBoxes) > 0
        for _i = 1 to array.size(a_histBoxes)
            box.delete(array.shift(a_histBoxes))
    if array.size(a_refLines) > 0
        for _i = 1 to array.size(a_refLines)
            line.delete(array.shift(a_refLines))
    if array.size(a_zoneBox) > 0
        for _i = 1 to array.size(a_zoneBox)
            box.delete(array.shift(a_zoneBox))
    if array.size(a_fills) > 0
        for _i = 1 to array.size(a_fills)
            linefill.delete(array.shift(a_fills))
    label.delete(titleLbl)

    n = array.size(a_osc)
    if n > 1
        lowestLow   = array.min(a_low)
        highestHigh = array.max(a_high)

        // wMax always includes the OB+Extreme bound so the reference zone
        // never gets clipped, then expands to fit the actual osc/basis range.
        float wMax = math.abs(obNumber + extreme - miNumber)
        for i = 0 to n - 1
            wMax := math.max(wMax, math.abs(array.get(a_osc, i) - miNumber), math.abs(array.get(a_basis, i) - miNumber))
        wMax := wMax == 0 ? 1 : wMax

        sepMult = i_histSep / 100.0
        float baseline = i_placement == 'Top' ? highestHigh + i_height * sepMult : lowestLow - i_height * sepMult

        int firstBi = array.get(a_bar_index, 0)
        int lastBi  = array.get(a_bar_index, n - 1)

        float yMid = f_scaledY(miNumber, baseline, wMax, i_height, miNumber, i_flip)
        float yOB  = f_scaledY(obNumber, baseline, wMax, i_height, miNumber, i_flip)
        float yOS  = f_scaledY(osNumber, baseline, wMax, i_height, miNumber, i_flip)

        // ── OB/OS zone background ───────────────────────────────────────────
        if i_showZone and not bMACD
            array.push(a_zoneBox, box.new(left = firstBi, top = yOB, right = lastBi, bottom = yOS,
                 border_color = color.new(#9915FF, 100), bgcolor = color.new(#9915FF, 90)))

        // ── Reference lines: OB / Mid / OS ──────────────────────────────────
        var line obRefLine = na
        var line osRefLine = na
        if i_showRef or bFillOBOS
            array.push(a_refLines, line.new(firstBi, yMid, lastBi, yMid, xloc.bar_index, extend.none, Silver, line.style_dotted, 1))
            if not bMACD
                obRefLine := line.new(firstBi, yOB, lastBi, yOB, xloc.bar_index, extend.none, Gray, line.style_dotted, 1)
                osRefLine := line.new(firstBi, yOS, lastBi, yOS, xloc.bar_index, extend.none, Gray, line.style_dotted, 1)
                array.push(a_refLines, obRefLine)
                array.push(a_refLines, osRefLine)

        // ── Volume Pressure mid reference (reused for the fill anchor) ─────
        var line vpMidLine = na
        if bVPMid
            vpMidLine := line.new(firstBi, yMid, lastBi, yMid, xloc.bar_index, extend.none, color.new(Silver, 100), line.style_solid, 1)
            array.push(a_refLines, vpMidLine)

        for i = 0 to n - 2
            if array.size(a_oscLines) + array.size(a_basisLines) + array.size(a_vpLines) < 480
                bi0 = array.get(a_bar_index, i)
                bi1 = array.get(a_bar_index, i + 1)

                oscV0 = array.get(a_osc, i)
                oscV1 = array.get(a_osc, i + 1)
                basV0 = array.get(a_basis, i)
                basV1 = array.get(a_basis, i + 1)

                yOsc0 = f_scaledY(oscV0, baseline, wMax, i_height, miNumber, i_flip)
                yOsc1 = f_scaledY(oscV1, baseline, wMax, i_height, miNumber, i_flip)
                yBas0 = f_scaledY(basV0, baseline, wMax, i_height, miNumber, i_flip)
                yBas1 = f_scaledY(basV1, baseline, wMax, i_height, miNumber, i_flip)

                // ── MACD Histogram ────────────────────────────────────────────
                if bMACD
                    histV = array.get(a_hist, i)
                    yHist = f_scaledY(histV, baseline, wMax, i_height, 0.0, i_flip)
                    array.push(a_histBoxes, box.new(bi0, baseline, bi0, yHist, array.get(a_histCol, i), 4))

                // ── Oscillator line ───────────────────────────────────────────
                colOsc = bAlt_col ? (oscV0 > miNumber ? Green : Red) : col_osc
                oscLine = line.new(bi0, yOsc0, bi1, yOsc1, xloc.bar_index, extend.none, colOsc, line.style_solid, 2)
                array.push(a_oscLines, oscLine)

                // ── Basis / Signal line ───────────────────────────────────────
                colBasis = bAlt_col ? None : col_osc_ema
                basisLine = line.new(bi0, yBas0, bi1, yBas1, xloc.bar_index, extend.none, colBasis, line.style_solid, 2)
                array.push(a_basisLines, basisLine)

                // ── Fill Lines (osc vs basis) ─────────────────────────────────
                if bFillLines
                    FillColor = oscV0 > basV0 ? color.new(#0094ff, 25) : color.new(#ff6a00, 25)
                    array.push(a_fills, linefill.new(oscLine, basisLine, FillColor))

                // ── OB/OS Fill ───────────────────────────────────────────────
                if bFillOBOS and not bMACD
                    superB = oscV0 > obNumber + extreme
                    overB  = oscV0 > obNumber
                    superS = oscV0 < osNumber - extreme
                    overS  = oscV0 < osNumber
                    if overB
                        array.push(a_fills, linefill.new(oscLine, obRefLine, superB ? color.new(Green, 25) : color.new(Green, 50)))
                    if overS
                        array.push(a_fills, linefill.new(oscLine, osRefLine, superS ? color.new(Red, 25) : color.new(Red, 50)))

                // ── Volume Pressure Fill ────────────────────────────────────
                if bVPMid
                    vp0 = array.get(a_vpMid, i)
                    vp1 = array.get(a_vpMid, i + 1)
                    yVp0 = f_scaledY(vp0, baseline, wMax, i_height, miNumber, i_flip)
                    yVp1 = f_scaledY(vp1, baseline, wMax, i_height, miNumber, i_flip)
                    vpLine = line.new(bi0, yVp0, bi1, yVp1, xloc.bar_index, extend.none, color.new(Aqua, 100), line.style_solid, 1)
                    array.push(a_vpLines, vpLine)
                    array.push(a_fills, linefill.new(vpLine, vpMidLine, vp0 >= miNumber ? color.new(#00bcd4, 80) : color.new(#7b1fa2, 80)))

        // ── Title label ──────────────────────────────────────────────────────
        titleLbl := label.new(lastBi + 6, baseline, text = IndicatorSelection,
             style = i_placement == 'Top' ? label.style_label_down : label.style_label_up,
             color = None, textcolor = White, size = size.normal)
````
