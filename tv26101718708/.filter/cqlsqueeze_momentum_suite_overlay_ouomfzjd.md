# CQ_(L)_Squeeze Momentum Suite Overlay

- url: https://www.tradingview.com/script/OUoMFzJD-CQ-L-Squeeze-Momentum-Suite-Overlay/
- type: indicator
- pine_id: PUB;34957482a7694240920af2277ae1950d
- version: 4.0

## Description

================================================================================
CQ_(L)_SQUEEZE MOMENTUM SUITE OVERLAY
Description and User Manual
================================================================================

--------------------------------------------------------------------------------
1. OVERVIEW
--------------------------------------------------------------------------------

CQ Squeeze Momentum Suite Overlay is an all-in-one price-chart overlay that
combines several classic sub-pane oscillators (Squeeze Momentum, ADX/DMI, an
Expert Trend Locator, a Hull Moving Average, and Momentum divergence
detection) into a single indicator that draws directly on the price chart
instead of a separate panel below it.

Every oscillator-scale value (Momentum, Momentum Strength, Signal, ADX, Key
Level) is mapped onto real price coordinates using a shared "baseline"
reference. This baseline is the single zero-point anchor for all of the
above: when an oscillator crosses zero, its line will touch the baseline
exactly, and the whole visible window of oscillator history is drawn flush
against that same flat, straight reference line.

--------------------------------------------------------------------------------
2. HOW THE OVERLAY MAPPING WORKS
--------------------------------------------------------------------------------

- The script looks back over "Display Length (bars)" candles and finds the
  highest high / lowest low in that window.
- Depending on "Placement" (Top or Bottom), the baseline is anchored either
  just above the recent highs or just below the recent lows, with some
  breathing room controlled by "Vertical Position Adjustment."
- "Height" controls how much vertical price-space the oscillators are
  allowed to occupy above/below the baseline.
- All oscillator values are rescaled into that price-space and drawn as
  lines/boxes anchored to the baseline, so the whole panel effectively
  "floats" over the candles without needing a separate sub-chart.
- Because one single baseline value is used across the entire redrawn
  window, the zero-line and every series are always shown as a flat,
  straight reference instead of a value that drifts bar-to-bar.
- The redraw happens once per bar-close (snapshot pattern), which keeps the
  indicator inside TradingView's per-indicator line/box drawing limits.

--------------------------------------------------------------------------------
3. FEATURE LIST
--------------------------------------------------------------------------------

A) SQUEEZE MOMENTUM
   - Momentum oscillator (linear-regression based), selectable moving-average
     engine (SMA, EMA, WMA, HMA, DEMA, TEMA, VWMA, ALMA, KAMA, JMA, Zero Lag,
     Tillson T3, VIDYA, and more).
   - Four render styles: Columns, Histogram, Line, Area.
   - Optional Momentum Strength cloud (Momentum minus its own moving-average
     Signal line).
   - Optional Signal(Momentum) line.
   - Multiple color palettes (5 built-in color schemes) reflecting whether
     Momentum is positive/negative and rising/falling.
   - Optional background tint reflecting the current Momentum color state,
     plus a separate "dark mode" gray background option.

B) SQUEEZE PRO DOTS
   - Circular markers above price flag when a Bollinger Band / Keltner
     Channel squeeze is active, using three intensity levels (Low/Mid/High
     squeeze) with distinct colors.
   - Only rendered within the "Display Length (bars)" window (see Section 5).

C) ADX WITH KEY LEVEL
   - ADX (Average Directional Index) rescaled to sit on the same baseline as
     Momentum, so trend strength can be read directly against price.
   - A "Key Level" reference line (ADX's neutral/trigger threshold, offset by
     the "Distance" input) drawn alongside it.
   - Colored Directional Movement Index (DMI): triangle markers below price
     mark whether +DI is above or below -DI, colored by trend strength/slope.
   - A DMI status label anchored at the baseline explaining, in plain text,
     the current trend state (Bullish/Bearish/Weak/No Trend), the ADX value,
     whether it is growing or falling, and how many bars since the last DI
     cross.
   - Bullish/Bearish DMI trend-change alert conditions.

D) EXPERT TREND LOCATOR (XTL)
   - A CCI-style trend classifier (traditional or non-traditional formula)
     that can recolor the candlesticks themselves (Bull / Bear / Neutral)
     based on a configurable threshold.

E) HULL MOVING AVERAGE (HMA)
   - Selectable Hull variant: HMA, EHMA, THMA, or Adaptive HMA (AHMA).
   - Long/short cross markers (triangle up/down) when the Hull average
     changes direction.
   - Optional background tint reflecting the Hull trend direction.

F) MOMENTUM DIVERGENCE ENGINE
   - Automatic detection of regular and hidden bullish/hidden bearish
     divergence between price and the Momentum oscillator.
   - Configurable pivot lookback, "2 pivots back" comparison, and a
     repaint-safe "delay until candle closes" option.
   - Connector lines and "R"/"H" labels drawn at the correct baseline-mapped
     price level.
   - Alert conditions for all four divergence types.

G) OVERLAY LAYOUT (shared baseline settings)
   - Display Length (bars): how many recent bars the baseline / oscillator
     mapping and the Squeeze Dots / DMI triangles are drawn across.
   - Placement: Top or Bottom of the visible price range.
   - Height: how much vertical price-space the oscillators occupy.
   - Vertical Position Adjustment: padding between the baseline and the
     actual candle range.

--------------------------------------------------------------------------------
4. INPUT REFERENCE (BY GROUP)
--------------------------------------------------------------------------------

SQUEEZE MOMENTUM
  Show Momentum            - toggles the Momentum plot.
  Color Format             - selects one of 5 color palettes (1-5).
  Background Off           - disables the Momentum-colored background tint.
  Momentum Style           - Area / Columns / Histogram / Line.
  Show Signal              - toggles the Signal(Momentum) line.
  Show Strength (MOM)      - toggles the Momentum Strength cloud/line.
  Draw Divergence          - master toggle for the divergence engine.
  Gray Background for Dark Mode - alternate gray background tint.
  Show Squeeze PRO [SQZ]   - toggles the Squeeze dots.
  Show SQZ Zero Line       - draws the flat baseline/zero reference line.

ADX
  Show ADX with KeyLevel   - toggles ADX + Key Level lines.
  Scale for ADX            - divisor used to rescale ADX into Momentum units.
  Positive/Negative slope colors - ADX line color when rising/falling.
  KeyLevel with color      - colors the Key Level line by DMI trend instead
                              of the ADX slope color.
  Distance between KeyLevel and 0 - offsets the Key Level line from zero.
  Display the colored DMI triangles - toggles the +DI/-DI triangle markers.
  Hide DMI Label           - hides the plain-text DMI status label.
  DMI Label Text Size      - Auto/Tiny/Small/Normal/Large/Huge.

(unnamed group, XTL bar coloring)
  Use XTL Bars Color       - recolors candles per the XTL trend state.
  XTL: Trend Up / Neutral / Trend Down - colors for each XTL state.

HULL MOVING AVERAGE
  Show (Hull Moving Average) Signal - toggles Hull cross markers.
  Background                - toggles the Hull-trend background tint.

OVERLAY LAYOUT
  Display Length (bars)    - lookback window for the baseline mapping AND
                              the Squeeze Dots / DMI triangle visibility.
  Placement                - Top or Bottom anchor for the baseline.
  Height                   - vertical space (in "notches") given to the
                              oscillators.
  Vertical Position Adjustment - padding between the baseline and the
                              recent price range.

SQUEEZE MOMENTUM INDICATOR PARAMETERS (SQZMOM)
  MOM Length / Source / Type - Momentum calculation length, price source,
                              and moving-average engine.
  Signal Length             - smoothing length for Signal(Momentum).
  Squeeze Length / Source   - length and source used for the Bollinger Band
                              / Keltner Channel squeeze detection.
  BB Calculation Type / MultFactor - Bollinger Band moving-average type and
                              standard-deviation multiplier.
  Keltner Channel Calculation Type / Use TrueRange - Keltner Channel
                              moving-average type and range source.

DIRECTIONAL MOVEMENT INDEX (Colored DMI)
  Alert: Bullish/Bearish Trend - enable/disable DMI trend-change alerts.
  ADX Smoothing / DI Length - standard ADX/DMI calculation lengths.
  Key level for ADX          - the ADX threshold considered "trending."
  Weak Trend Threshold       - the ADX threshold below which trend is
                              considered absent.
  Historical Label Readings  - shows the DMI label's reading from N bars
                              back instead of the current bar.

EXPERT TREND LOCATOR (XTL)
  Length / Type / Source     - CCI-style calculation length, moving-average
                              type, and price source.
  Threshold Level            - the +/- CCI threshold that defines Bull/Bear.
  Use the traditional CCI formula - switches between the classic and
                              non-traditional CCI denominator.

HULL MOVING AVERAGE (HMA)
  Length / Type / Source     - Hull average length, variant, and price
                              source.

DIVERGENCES FOR MOMENTUM
  Plot Bullish / Hidden Bullish / Bearish / Hidden Bearish - toggle each
                              divergence type independently.
  Delay plot until candle is closed - avoids repainting divergence signals.
  Lookback 2 Pivots?         - also compares against the pivot two bars back.
  Pivot Lookback Right/Left  - pivot-detection window.
  Min/Max of Lookback Range  - how far back (in bars) a divergence pair may
                              span to still be considered valid.

--------------------------------------------------------------------------------
5. NOTES ON THE "DISPLAY LENGTH (BARS)" SETTING
--------------------------------------------------------------------------------

"Display Length (bars)" (in the Overlay Layout group) controls THREE things
at once:

  1. How many historical bars the baseline/oscillator snapshot engine
     redraws (Momentum, Strength, Signal, ADX, Key Level, Zero Line).
  2. How many recent bars show Squeeze PRO dots above price.
  3. How many recent bars show the colored DMI triangles below price.

Anything older than this window is simply not drawn, keeping the chart
readable and staying within TradingView's per-indicator object limits
(500 lines / 500 boxes / 50 labels). Increasing this value shows more
history but uses more of that budget; the input is capped at 100 bars to
leave headroom for all series that can be active simultaneously.

--------------------------------------------------------------------------------
6. ALERTS
--------------------------------------------------------------------------------

  - DMI Bullish Trend / DMI Bearish Trend (on trend-state change)
  - Regular Bull Divergence / Hidden Bull Divergence
  - Regular Bear Divergence / Hidden Bear Divergence

--------------------------------------------------------------------------------
7. QUICK START
--------------------------------------------------------------------------------

  1. Add the indicator to a price chart (it renders as an overlay, not a
     separate pane).
  2. In "Overlay Layout," set Display Length to match how much recent price
     history you want the oscillators plotted against, and adjust
     Placement/Height/Vertical Position Adjustment until the oscillator
     band sits where you want it relative to candles.
  3. Enable/disable Momentum, Strength, Signal, ADX, Squeeze Dots, DMI
     triangles, and Divergences as needed under their respective groups.
  4. Use "Show SQZ Zero Line" if you want an explicit flat reference line
     at the baseline.
  5. Set up alerts from the DMI or Divergence alert conditions if you want
     notifications outside of TradingView.

================================================================================
End of manual.
================================================================================

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CQuevedo345

//@version=6
// Overlay rendering engine (baseline-anchored collect-then-draw): adapted from
// CQ_(L)_Reverse MACD Overlay's snapshot drawing pattern.

indicator(title="CQ_(L)_Squeeze Momentum Suite Overlay", overlay=true,
     max_lines_count = 500, max_boxes_count = 500, max_labels_count = 50, max_bars_back = 500)

// Tick Volume
tick     = syminfo.mintick
rng      = close - open
tickrng  = tick
tickrng := math.abs(rng) < tick ? nz(tickrng[1]) : rng
tickvol  = math.abs(tickrng)/tick
volumen  = nz(volume) == 0 ? tickvol : volume

// Function to select the type of source
get_src(Type) =>
    switch Type        
        "Close" => close
        "Open" => open
        "HL2" => hl2
        "HLC3" => hlc3
        "OHLC4" => ohlc4
        "HLCC4" => hlcc4        
        "High" => high
        "Low" => low
        "Volume" => volumen
        "VWAP" => ta.vwap
        "vwap(Close)" => ta.vwap(close)
        "vwap(Open)" => ta.vwap(open)
        "vwap(High)" => ta.vwap(high)
        "vwap(Low)" => ta.vwap(low)
        "AVG(vwap(H,L))" => math.avg(ta.vwap(high), ta.vwap(low))
        "AVG(vwap(O,C))" => math.avg(ta.vwap(open), ta.vwap(close))
        "OBV" => ta.obv // On Balance Volume        
        "AccDist" => ta.accdist // Accumulation Distribution
        "PVT" => ta.pvt // Price Volume Trend
        'AVG(volume)' => math.avg(ta.obv, ta.pvt, ta.accdist)        

// Kaufman's Adaptive Moving Average
kama(x, t)=>
    fastK = 0.666 // KAMA Fast End
    slowK = 0.0645 // KAMA Slow End
    dist   = math.abs(x[0] - x[1])
    signal = math.abs(x - x[t])
    noise  = math.sum(dist, t)
    effr   = noise != 0 ? signal/noise : 1
    sc     = math.pow(effr*(fastK - slowK) + slowK,2)
    KAMA   = x
    KAMA  := nz(KAMA[1]) + sc*(x - nz(KAMA[1]))

// Jurik Moving Average of @everget
jma(src, length, power, phase) => 
    phaseRatio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase / 100 + 1.5
    beta = 0.45 * (length - 1) / (0.45 * (length - 1) + 2)
    alpha = math.pow(beta, power)
    JMA = 0.0
    e0 = 0.0
    e0 := (1 - alpha) * src + alpha * nz(e0[1])
    e1 = 0.0
    e1 := (src - e0) * (1 - beta) + beta * nz(e1[1])
    e2 = 0.0
    e2 := (e0 + phaseRatio * e1 - nz(JMA[1])) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1])
    JMA := e2 + nz(JMA[1])

cti(sm, src, cd) =>
    di = (sm - 1.0) / 2.0 + 1.0
    c1 = 2 / (di + 1.0)
    c2 = 1 - c1
    c3 = 3.0 * (cd * cd + cd * cd * cd)
    c4 = -3.0 * (2.0 * cd * cd + cd + cd * cd * cd)
    c5 = 3.0 * cd + 1.0 + cd * cd * cd + 3.0 * cd * cd
    i1 = 0.0
    i2 = 0.0
    i3 = 0.0
    i4 = 0.0
    i5 = 0.0
    i6 = 0.0
    i1 := c1*src + c2*nz(i1[1])
    i2 := c1*i1 + c2*nz(i2[1])
    i3 := c1*i2 + c2*nz(i3[1])
    i4 := c1*i3 + c2*nz(i4[1])
    i5 := c1*i4 + c2*nz(i5[1])
    i6 := c1*i5 + c2*nz(i6[1])        
    bfr = -cd*cd*cd*i6 + c3*(i5) + c4*(i4) + c5*(i3)
    
T3ma(src,Len) =>
    a = 0.618
    e1 = ta.ema(src, Len)
    e2 = ta.ema(e1, Len)
    e3 = ta.ema(e2, Len)
    e4 = ta.ema(e3, Len)
    e5 = ta.ema(e4, Len)
    e6 = ta.ema(e5, Len)
    C1 = -a*a*a
    C2 = 3*a*a+3*a*a*a
    C3 = -6*a*a-3*a-3*a*a*a
    C4 = 1+3*a+a*a*a+3*a*a
    C1*e6+C2*e5+C3*e4+C4*e3

VIDYA(src,Len) =>
    mom     = ta.change(src)
    upSum   = math.sum(math.max(mom, 0), Len)
    downSum = math.sum(-math.min(mom, 0), Len)
    out     = (upSum - downSum) / (upSum + downSum)
    cmo     = math.abs(out)
    alpha   = 2 / (Len + 1)
    vidya   = 0.0
    vidya   := src * alpha * cmo + nz(vidya[1]) * (1 - alpha * cmo)

// ZLEMA: Zero Lag
zema(_src, _len) =>
    alpha = (_len - 1) / 2
    zlema0 = (_src + (_src - _src[alpha]))
    zlemaF = ta.ema(zlema0, _len)

// ADX Weighted Moving Average of @Duyck 
adx_weighted_ma(_src, _period) =>
    [_,_, _adx] = ta.dmi(17, 14)
    vol_sum  = 0.0
    adx_sum  = 0.0
    for i = 0 to _period
        vol_sum  := _src[i] * _adx[i] + vol_sum
        adx_sum  := _adx[i] + adx_sum 
    volwma   = vol_sum / adx_sum

// COVWMA - Coefficient of Variation Weighted Moving Average of @DonovanWall
covwma(a, b) =>
    cov    = ta.stdev(a, b) / ta.sma(a, b)
    cw     = a*cov
    covwma = math.sum(cw, b) / math.sum(cov, b)

// FRAMA - Fractal Adaptive Moving Average of @DonovanWall
frama(a, b) =>
    w = -4.6 // "Coefficient"
    frama = 0.0
    n3    = (ta.highest(high, b) - ta.lowest(low, b))/b
    hd2   = ta.highest(high, b/2)
    ld2   = ta.lowest(low, b/2)
    n2    = (hd2 - ld2)/(b/2)
    n1    = (hd2[b/2] - ld2[b/2])/(b/2)
    dim   = (n1 > 0) and (n2 > 0) and (n3 > 0) ? (math.log(n1 + n2) - math.log(n3))/math.log(2) : 0
    alpha = math.exp(w*(dim - 1))
    sc    = (alpha < 0.01 ? 0.01 : (alpha > 1 ? 1 : alpha))
    frama := ta.cum(1)<=2*b ? a : (a*sc) + nz(frama[1])*(1 - sc)

// EMA RSI Adaptive of @glaz
rsi_ema(src, period) =>
    RsiPeriod = 14
    ema = 0.0
    RSvoltl = math.abs(ta.rsi(close, RsiPeriod)-50)+1.0
    multi   = (5.0+100.0/RsiPeriod) / (0.06+0.92*RSvoltl+0.02*math.pow(RSvoltl,2))
    pdsx    = multi*period
    alpha   = 2.0 /(1.0+pdsx)
    ema     := nz(ema[1])+alpha*(ta.sma(close, period)-nz(ema[1]))

// VAMA - Volume Adjusted Moving Average of @allanster
vama(_src,_len,_fct,_rul,_nvb) =>                             // vama(source,length,factor,rule,sample)
    tvb = 0, tvb := _nvb == 0 ? nz(tvb[1]) + 1 : _nvb         // total volume bars used in sample            
    tvs = _nvb == 0 ? ta.cum(volumen) : math.sum(volumen, _nvb) // total volume in sample
    v2i = volumen / ((tvs / tvb) * _fct)                       // ratio of volume to increments of volume                                                  
    wtd = _src*v2i                                            // weighted prices 
    nmb = 1                                                   // initialize number of bars summed back               
    wtdSumB = 0.0                                             // initialize weighted prices summed back
    v2iSumB = 0.0                                             // initialize ratio of volume to increments of volume summed back
    for i = 1 to _len * 10                                    // set artificial cap for strict to VAMA length * 10 to help reduce edge case timeout errors
        strict = _rul ? false : i == _len                     // strict rule N bars' v2i ratios >= vama length, else <= vama length
        wtdSumB := wtdSumB + nz(wtd[i-1])                     // increment number of bars' weighted prices summed back
        v2iSumB := v2iSumB + nz(v2i[i-1])                     // increment number of bars' v2i's summed back
        if v2iSumB >= _len or strict                          // if chosen rule met
            break                                             // break (exit loop)
        nmb := nmb + 1                                        // increment number of bars summed back counter
    nmb                                                       // number of bars summed back to fulfill volume requirements or vama length
    wtdSumB                                                   // number of bars' weighted prices summed back
    v2iSumB                                                   // number of bars' v2i's summed back
    vama = (wtdSumB - (v2iSumB - _len) * _src[nmb]) / _len    // volume adjusted moving average

// New WMA
NWMA(_src, _n1) =>
    fast   = int(_n1 / 2)
    lambda = _n1 / fast
    alpha  = lambda * (_n1 - 1) / (_n1 - lambda)
    ma1    = ta.wma(_src, _n1)
    ma2    = ta.wma(ma1, fast)
    nwma   = (1 + alpha) * ma1 - alpha * ma2

// RSS_WMA of @RedKTrader
f_LazyLine(_data, _length) =>
    w1 = 0,     w2 = 0,     w3 = 0
    L1 = 0.0,   L2 = 0.0,   L3 = 0.0
    w = _length / 3
    if _length > 2
        w2 := math.round(w)
        w1 := math.round((_length - w2) / 2)
        w3 := int((_length - w2) / 2)
        L1 := ta.wma(_data, w1)
        L2 := ta.wma(L1, w2)
        L3 := ta.wma(L2, w3)        
    else
        L3 := _data        
    L3 

enhanced_vwma(_series, _length) =>    
    vmp  = _series * volumen
    VWMA = math.sum(vmp, _length) / math.sum(volumen, _length)

// ALMA - Arnaud Legoux Moving Average of @kurtsmock
enhanced_alma(_series, _length, _offset, _sigma) =>
    length      = int(_length) // Floating point protection
    numerator   = 0.0
    denominator = 0.0 
    m = _offset * (length - 1)
    s = length / _sigma
    for i=0 to length-1
        weight       = math.exp(-((i-m)*(i-m)) / (2 * s * s))
        numerator   := numerator   + weight * _series[length - 1 - i]
        denominator := denominator + weight
    numerator / denominator

ma(MAType, MASource, MAPeriod) =>
    switch MAType
        "SMA" => ta.sma(MASource, MAPeriod)
        "EMA" => ta.ema(MASource, MAPeriod)
        "WMA" => ta.wma(MASource, MAPeriod)
        "HMA" => ta.hma(MASource, MAPeriod)
        "DEMA" => e = ta.ema(MASource, MAPeriod), 2 * e - ta.ema(e, MAPeriod)
        "TEMA" => e = ta.ema(MASource, MAPeriod), 3 * (e - ta.ema(e, MAPeriod)) + ta.ema(ta.ema(e, MAPeriod), MAPeriod)
        "VWMA" => enhanced_vwma(MASource, MAPeriod)
        "ALMA" => enhanced_alma(MASource, MAPeriod, .85, 6)
        "CTI" => cti(MAPeriod, MASource, 0)
        "KAMA" => kama(MASource, MAPeriod)
        "SWMA" => ta.swma(MASource)
        "JMA" => jma(MASource, MAPeriod, 2, 50)
        "LSMA" => ta.linreg(MASource, MAPeriod, 0) // Least Squares
        "Wilder" => wild = MASource, wild := nz(wild[1]) + (MASource - nz(wild[1])) / MAPeriod // Wilder's moving average
        "Tillson T3" => T3ma(MASource, MAPeriod)
        "VIDYA" => VIDYA(MASource, MAPeriod)
        "DWMA" => ta.wma(ta.wma(MASource, MAPeriod), MAPeriod) // Double Weighted Moving Average
        "DVWMA" => ta.vwma(ta.vwma(MASource, MAPeriod), MAPeriod) // Double Volume-Weighted Moving Average
        "Zero Lag" => zema(MASource, MAPeriod)
        "Median" => ta.median(MASource, MAPeriod)
        "RSI EMA" => rsi_ema(MASource, MAPeriod)
        "ADX MA" => adx_weighted_ma(MASource, MAPeriod)
        "COVWMA" => covwma(MASource, MAPeriod)
        "FRAMA" => frama(MASource, MAPeriod)
        "VAMA" => vama(MASource, MAPeriod, 0.67, true, 0)
        "NWMA" => NWMA(MASource, MAPeriod)
        "RSS_WMA" => f_LazyLine(MASource, MAPeriod)

show_Momen = input.bool(true,        "⫸ Show Momentum ", inline="mom", group = "Squeeze Momentum")
color_M    = input.int(3,            "Color Format", minval=1, maxval=5, inline="mom")
bgoff      = input.bool(true,        "Background Off", inline="mom")
StyleMom   = input.string("Columns", "Momentum Style", options=["Area", "Columns", "Histogram", "Line"], inline="M2")
showSignal = input.bool(false,       "Show Signal", inline="M2")
show_strength = input.bool(false,    "Show Strength (MOM)", inline = "M2")
drdiv      = input.bool(true,        "Draw Divergence", inline="l1")
darkm      = input.bool(false,       "Gray Background for Dark Mode", inline="l1")
show_sqz   = input.bool(true,        "▷ Show Squeeze PRO [SQZ]", inline="S")
zeroSQZ    = input.bool(false,       "▷ Show SQZ Zero Line", inline="S")

show_ADX  = input.bool(true,       "⫸ Show ADX with KeyLevel", inline="showAdx", group = "ADX")
scale     = input.float(55.0,      "Scale for ADX", inline="dmi0")
pos       = input.color(#bde9ff, "Positive slope", inline="dmi0") 
neg       = input.color(#526172, "Negative slope", inline="dmi0")
keyColor  = input.bool(true,      "KeyLevel with color | ", inline="k_level")
distance  = input.int(0,          "Distance between KeyLevel and 0", inline="k_level")  
show_DMI  = input.bool(true,       "▷ Display the colored DMI triangles", inline="showDMI")
hideLabel = input.bool(false,      "▷ Hide DMI Label ◁", inline= "showDMI")

candles_XTL = input.bool(false,      "▷ Use XTL Bars Color")
color_xtlUP = input.color(#00BFFF, "XTL: Trend Up",   inline="ColXTL")
color_xtlNe = input.color(#FFFFFF, "Neutral",    inline="ColXTL")
color_xtlDN = input.color(#FF4000, "Trend Down", inline="ColXTL")

show_Hull = input.bool(false, "▷ Show (Hull Moving Average) Signal", inline="hull0", group = "Hull Moving Average")
bg_Hull   = input.bool(false,  "Background",  inline="hull0")

// ── Overlay Layout (baseline anchor — same pattern as CQ_(L)_Reverse MACD Overlay) ──
grp_lay     = "Overlay Layout Settings"
i_lookback  = input.int(50,     "Display Length (bars)", minval = 10, maxval = 100, group = grp_lay)
i_placement = input.string("Bottom", "Placement", options = ["Top", "Bottom"], inline = "LAY", group = grp_lay)
i_height    = 12 - input.int(5, "Height", minval = 1, maxval = 10, inline = "LAY", group = grp_lay)
i_vertAdj   = input.int(9,      "Vertical Position Adjustment", minval = 0, maxval = 15, group = grp_lay) / 10
i_histBorderWidth = input.int(3, "Histogram Border Width", minval = 1, maxval = 5, inline = "HBORD", group = grp_lay)
i_histBorderColor = input.color(color.new(color.black, 100), "Border Color", inline = "HBORD", group = grp_lay)
i_histBoxWidth    = input.float(90, "Histogram Box Width (%)", minval = 10, maxval = 100, step = 5, group = grp_lay,
     tooltip = "Percentage of the full bar width each histogram column occupies, centered on the bar.")

// Input - Squeeze Momentum Indicator
group_mom  = "Squeeze Momentum Indicator Parameters (SQZMOM)"
lengthM    = input.int(20,           "MOM Length", minval=1, step=1, inline="M", group = group_mom)
srcM       = input.source(close,     "Source", inline="M", group = group_mom)
typeMom    = input.string('SMA',     "Type", inline = "M", group = group_mom, options=["SMA", "EMA", "ALMA", "WMA", "DWMA", "VAMA", "VWMA", "DVWMA", "Wilder", "RSS_WMA", "NWMA", "HMA", "JMA", "KAMA", "Zero Lag", "Tillson T3", "VIDYA", "CTI", "DEMA", "TEMA", "SWMA", "Median", "COVWMA", "FRAMA", "ADX MA", "RSI EMA"])
sigLen     = input.int(5,            "Signal Length", inline="M2", group = group_mom)
length     = input.int(20,           "Squeeze Length",  minval=1, step=1, inline="S", group = group_mom)
src        = input.source(ohlc4,     "Source", inline="S", group = group_mom)
bbmatype   = input.string('SMA',     "BB Calculation Type", inline = "bb", group = group_mom, options=["SMA", "EMA", "WMA", "DWMA", "ALMA", "NWMA", "VAMA", "VWMA", "DVWMA", "HMA", "LSMA", "Wilder", "JMA", "Zero Lag", "Tillson T3", "VIDYA", "KAMA", "CTI", "DEMA", "TEMA", "SWMA", "Median", "COVWMA", "FRAMA", "ADX MA", "RSI EMA"])
multBB     = input.float(2.0 ,       "BB MultFactor", step=0.05, inline = "bb", group = group_mom) //Bollinger Bands Multiplier
kcmatype   = input.string('EMA',     "Keltner Channel Calculation Type", inline = "kc", group = group_mom, options=["SMA", "EMA", "WMA", "DWMA", "ALMA", "NWMA", "VAMA", "VWMA", "DVWMA", "HMA", "LSMA", "Wilder", "JMA", "Zero Lag", "Tillson T3", "VIDYA", "KAMA", "CTI", "DEMA", "TEMA", "SWMA", "Median", "COVWMA", "FRAMA", "ADX MA", "RSI EMA"])
useTR      = input.bool(true,        "Use TrueRange (KC)", inline = "kc", group = group_mom)

// Input - ADX and DMI
group_dmi = "Directional Movement Index (Colored DMI)"
detect_bull_dmi = input.bool(false, '◁ Alert: Bullish Trend', inline='alert_dmi', group=group_dmi)
detect_bear_dmi = input.bool(false, '◁ Alert: Bearish Trend', inline='alert_dmi', group=group_dmi)
adxlen    = input.int(14,           "ADX Smoothing", minval=1, maxval=50, group=group_dmi)
dilen     = input.int(14,           "DI Length", minval=1, group=group_dmi) 
keyLevel  = input.int(23,           "Key level for ADX", group=group_dmi)
weakTrend = input.int(17,           "Weak Trend Theshold", group=group_dmi)
histLabel = input.int(0    ,        "Historical Label Readings", minval=0, group=group_dmi)
dmiLabelSize = input.string(size.tiny, "DMI Label Text Size", group=group_dmi,
     options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge])

// Input - Expert Trend Locator
group_xtl   = "Expert Trend Locator (XTL)"
period_xtl  = input.int(26,          "Length", minval=2, inline="xtl", group=group_xtl)
MA_Type2    = input.string("DVWMA",  "Type", inline="xtl", group=group_xtl, options=["SMA", "EMA", "WMA", "DWMA", "ALMA", "VAMA", "VWMA", "DVWMA", "Wilder", "JMA", "RSS_WMA", "NWMA", "HMA", "LSMA", "Zero Lag", "Tillson T3", "VIDYA", "KAMA", "CTI", "DEMA", "TEMA", "SWMA", "Median", "COVWMA", "FRAMA", "ADX MA", "RSI EMA"])
src_xtl     = input.string("HLC3",   "Source", inline="xtl", group=group_xtl, options=["VWAP", "Close", "Open", "HL2", "HLC3", "OHLC4", "HLCC4", "High", "Low", "vwap(Close)", "vwap(Open)", "vwap(High)", "vwap(Low)", "AVG(vwap(H,L))", "AVG(vwap(O,C))", "OBV", "AccDist", "PVT", "Volume"])
fixed_Value = input.int(37,          "Threshold Level", minval=10, group=group_xtl, inline="xtl2")
uTrad       = input.bool(false,      "Use the traditional CCI formula", group=group_xtl, inline="xtl2")

// Input - Hull Moving Average
group_hull = "Hull Moving Average (HMA)"
h_Length  = input.int(55,         "Length", minval=1, step=1, inline = "hull", group=group_hull)
h_type    = input.string("HMA",   "Type", options=["HMA", "EHMA", "THMA", "AHMA"], inline = "hull", group=group_hull)
h_src     = input.string("Close", "Source", inline = "hull", group=group_hull, options=["Close", "Open", "HL2", "HLC3", "OHLC4", "HLCC4", "VWAP", "High", "Low", "vwap(Close)", "vwap(Open)", "vwap(High)", "vwap(Low)", "AVG(vwap(H,L))", "AVG(vwap(O,C))", 'AVG(volume)'])

// Divergences
group_divergences = "Divergences For Momentum"
plotBull              = input.bool(true,  "Plot Bullish", inline="bull", group=group_divergences)
plotHiddenBull        = input.bool(false, "Plot Hidden Bullish", inline="bull", group=group_divergences)
plotBear              = input.bool(true,  "Plot Bearish", inline="bear", group=group_divergences)
plotHiddenBear        = input.bool(false, "Plot Hidden Bearish", inline="bear", group=group_divergences)
delay_plot_til_closed = input.bool(true,  "Delay plot until candle is closed (don't repaint)", group=group_divergences)
usex2LB               = input.bool(true,  "Lookback 2 Pivots?", group=group_divergences)
lbR                   = input.int(1,      "Pivot Lookback Right", group=group_divergences)
lbL                   = input.int(2,      "Pivot Lookback Left", group=group_divergences)
rangeLower            = input.int(1,      "Min of Lookback Range", group=group_divergences)
rangeUpper            = input.int(60,     "Max of Lookback Range", group=group_divergences)
i_bullDivOffset       = input.int(0,      "Bullish Divergence Horizontal Offset (bars)", minval=-20, maxval=20, group=group_divergences,
     tooltip = "Shifts Regular and Hidden Bullish divergence lines/labels left(-) or right(+).")
i_bearDivOffset       = input.int(0,      "Bearish Divergence Horizontal Offset (bars)", minval=-20, maxval=20, group=group_divergences,
     tooltip = "Shifts Regular and Hidden Bearish divergence lines/labels left(-) or right(+).")
i_bullDivVOffset      = input.int(0,      "Bullish Divergence Vertical Offset (ticks)", minval=-5000, maxval=5000, step=100, group=group_divergences,
     tooltip = "Shifts Regular and Hidden Bullish divergence lines/labels up(+) or down(-), in price ticks.")
i_bearDivVOffset      = input.int(0,      "Bearish Divergence Vertical Offset (ticks)", minval=-5000, maxval=5000, step=100, group=group_divergences,
     tooltip = "Shifts Regular and Hidden Bearish divergence lines/labels up(+) or down(-), in price ticks.")

//_________________________________________________________________________________
// Based on "Squeeze Momentum Indicator" - Author:@LazyBear and @J-Streak          
// https://www.tradingview.com/script/nqQ1DT5a-Squeeze-Momentum-Indicator-LazyBear/
// https://www.tradingview.com/script/557GijRq-JS-Squeeze-Pro-2/                   
//_________________________________________________________________________________
// Bollinger Bands Basis Line
basis = ma(bbmatype, src, length) 

// Keltner Channel Basis Line
basiskc = ma(kcmatype, src, length)
// Keltner Channel Range
range_src = useTR ? ta.tr : (high - low)
range_kc  = ma(kcmatype, range_src, length)
// Keltner Channel Low Multiplier
multlowKC = 2.0
// Keltner Channel Mid Multiplier
multmidKC = 1.5
// Keltner Channel High Multiplier
multhighKC = 1.0

// Bollinger Bands 
dev         = multBB * ta.stdev(src, length)
upperBB     = basis + dev
lowerBB     = basis - dev
// Keltner Channel Bands Low 
upperKCl    = basiskc + range_kc * multlowKC
lowerKCl    = basiskc - range_kc * multlowKC
// Keltner Channel Bands Mid
upperKCm    = basiskc + range_kc * multmidKC
lowerKCm    = basiskc - range_kc * multmidKC
// Keltner Channel Bands High
upperKCh    = basiskc + range_kc * multhighKC
lowerKCh    = basiskc - range_kc * multhighKC

//------------------------{ Squeeze Momentum Basics }------------------------------------
// Momentum
ma_momentum = ma(typeMom, srcM, lengthM)
sz = ta.linreg(srcM - math.avg(math.avg(ta.highest(high, lengthM), ta.lowest(low, lengthM)), ma_momentum), lengthM, 0)
sigM = ta.sma(sz, sigLen)
momentum_strength = sz - sigM

// Momentum Conditions
sc1 = sz >= 0
sc2 = sz < 0
sc3 = sz >= sz[1]
sc4 = sz < sz[1]

// Squeeze On
lowsqz      = lowerBB > lowerKCl and upperBB < upperKCl
lsf         = lowsqz == false
midsqz      = lowerBB > lowerKCm and upperBB < upperKCm
msf         = midsqz == false
highsqz     = lowerBB > lowerKCh and upperBB < upperKCh
hsf         = highsqz == false

//-----------------------{ Color Components }-----------------------------------
// Color Conditions
clr1        = sc1 and sc3 ? #00EEFF : 
   sc1 and sc4 ? #000EFF : sc2 and sc4 ? #FF0000 : sc2 and sc3 ? #FFE500 : color.gray
clr2        = sc1 and sc3 ? #00bcd4 : 
   sc1 and sc4 ? #0D47A1 : sc2 and sc4 ? #BA68C8 : sc2 and sc3 ? #9C27B0 : #673AB7
clr3        = sc1 and sc3 ? #15FF00 : sc1 and sc4 ? #335E33 : 
   sc2 and sc4 ? #F44336 : sc2 and sc3 ? #B71C1C : color.gray
clr4        = sc1 and sc3 ? #fff59d : 
   sc1 and sc4 ? #FFD600 : sc2 and sc4 ? #FFCC80 : sc2 and sc3 ? #FF9800 : #702700
clr5        = sc1 and sc3 ? #2196F3 : 
   sc1 and sc4 ? #0D47A1 : sc2 and sc4 ? #EF9A9A : sc2 and sc3 ? #D32F2F : #CE93D8
color_mom   = color_M == 1 ? clr1 : color_M == 2 ? clr2 : 
   color_M == 3 ? clr3 : color_M == 4 ? clr4 : color_M == 5 ? clr5 : na

//______________________________________________________________________________
// Overlay Price-Scale Mapping Engine — every oscillator below is expressed as
// an offset from `baseline`, the single shared zero-point anchor. Because the
// snapshot redraw loop reuses ONE `baseline`/`hAdj`/`oscHighest` value across
// the entire lookback window, the zero-line renders as a perfectly straight
// horizontal reference, exactly like CQ_(L)_Reverse MACD Overlay.
//______________________________________________________________________________
basePrice(float ph, float pl) =>
    i_placement == "Top" ? ph : pl

priceHighest    = ta.highest(high, i_lookback)
priceLowest     = ta.lowest(low,   i_lookback)
priceChangeRate = (priceHighest - priceLowest) / priceHighest
priceLowest    := priceLowest  * (1 - priceChangeRate * i_vertAdj)
priceHighest    := priceHighest * (1 + priceChangeRate * i_vertAdj)
oscHighestRaw   = ta.highest(math.abs(sz), i_lookback)
oscHighest      = oscHighestRaw == 0 ? 1 : oscHighestRaw
hAdj            = priceChangeRate / i_height
baseline        = basePrice(priceHighest, priceLowest)

// Histogram boxes are drawn with xloc.bar_time (instead of the bar_index xloc
// used everywhere else) because box x-coordinates in xloc.bar_index mode must
// land on whole bar indices — they can't express a sub-bar-width column. Time
// coordinates are continuous, so i_histBoxWidth can shrink each column
// symmetrically around its bar's center.
barMs = timeframe.in_seconds() * 1000
histHalfWidthMs = int(math.round(barMs * (i_histBoxWidth / 100) / 2))

// Live per-bar helper (used by the divergence engine, which draws continuously
// rather than in the last-bar snapshot loop below).
scaledPrice(float val) =>
    baseline * (1 + val / oscHighest * hAdj)

//-----------------{ Indicator Components and Plots }---------------------------
// Squeeze Dot Colors
orange_red    = #FF4000 // Original Squeeze 
golden_yellow = #FFE500 // High Squeeze
color_sqz = highsqz ? golden_yellow : midsqz ? orange_red : lowsqz ? #2F4F4F : na
// Squeeze Dot Plot Above (location.top is chart-relative, works unchanged on overlay)
// show_last ties visibility to the same "Display Length (bars)" window as the
// DMI triangles and the baseline engine, hiding dots beyond that range.
sqzpro = zeroSQZ ? false : highsqz ? highsqz : midsqz ? midsqz : lowsqz ? lowsqz : false
plotshape(show_sqz ? sqzpro : false, "Squeeze Dots", shape.circle, location.top, color_sqz, show_last = i_lookback)

color_strength        = momentum_strength > 0 ? #05FFA6 : #FF9900
color_strength_cloud  = momentum_strength > 0 ? color.new(#05FFA6, 85) : color.new(#FF9900, 85)
color_sigM            = sz >= sigM ? color.new(#1500FF, 15) : color.new(#FF007A, 15)

//______________________________________________________________________________
// Based on "Directional Movement Index and ADX"
// https://www.tradingview.com/script/VroqhJmg/
//______________________________________________________________________________
[diplus, diminus, adxValue] = ta.dmi(dilen, adxlen)

biggest(series) =>
    max = 0.0
    max := nz(max[1], series)
    if series > max
        max := series
    max

// Calculate ADX Scale
ni = biggest(sz)
adx_scale = (adxValue - keyLevel + distance) * ni/scale
keylevel_scale = distance * ni/scale

// J. Welles Wilder, developer of DMI, believed that a DMI reading above 25 indicated a strong trend, 
// while a reading below 20 indicated a weak or non-existent trend.
dmiBull = diplus   >= diminus  and adxValue >= keyLevel
dmiBear = diplus   <  diminus  and adxValue >= keyLevel
dmiWeak = adxValue <  keyLevel and adxValue >  weakTrend

// Colored Directional Movement Index (CDMI) by @dgtrd and modified by @OskarGallard
slope_positive = adxValue > adxValue[1]
diCross = bar_index - ta.valuewhen(ta.cross(diplus, diminus), bar_index, 0)
strong = slope_positive ? "Strong" : " "
weak_up_dn = dmiWeak ? (diplus >= diminus ? "[uptrend]" : "[downtrend]") : ""

dmiColor = dmiBull ? (slope_positive ? color.rgb(0, 100, 28, 50) : color.rgb(0, 255, 8, 70)) : 
           dmiBear ? (slope_positive ? color.rgb(114, 0, 0, 50)  : color.rgb(255, 0, 0, 70)) : 
           dmiWeak ? (slope_positive ? color.rgb(48, 57, 67, 50) : color.rgb(157, 177, 199, 70)) : 
           (slope_positive           ? color.rgb(104, 50, 0, 50) : color.rgb(255, 166, 0, 70))

txtColor = dmiBull ? (slope_positive ? color.rgb(255, 255, 255) : color.rgb(0, 255, 8)) : 
           dmiBear ? (slope_positive ? color.rgb(255, 255, 255) : color.rgb(255, 0, 0)) : 
           dmiWeak ? (slope_positive ? color.rgb(255, 255, 255) : color.rgb(157, 177, 199)) : 
           (slope_positive           ? color.rgb(255, 255, 255) : color.rgb(255, 166, 0))   
 
color_ADX = slope_positive ? pos : neg
color_zero = highsqz ? golden_yellow : midsqz ? orange_red : lowsqz ? color.gray : clr3

// ── Background Conditions (bgcolor works the same in overlay mode) ──
bg1_dark = color.new(color.gray, 95)
bg2_dark = color.new(#673AB7, 95)
bg3_dark = color.new(color.gray, 95)
bg4_dark = color.new(#FFD600, 95)
bg5_dark = color.new(#CE93D8, 95)

bgc_dark = bgoff ? na : color_M == 1 ? bg1_dark : color_M == 2 ? bg2_dark : 
   color_M == 3 ? bg3_dark : color_M == 4 ? bg4_dark : color_M == 5 ? bg5_dark : na

clr1_bg        = sc1 and sc3 ? color.new(#00EEFF, 80) : 
   sc1 and sc4 ? color.new(#000EFF, 80) : sc2 and sc4 ? color.new(#FF0000, 80) : sc2 and sc3 ? color.new(#FFE500, 80) : color.new(color.gray, 80)
clr2_bg        = sc1 and sc3 ? color.new(#00bcd4, 80) : 
   sc1 and sc4 ? color.new(#0D47A1, 80) : sc2 and sc4 ? color.new(#BA68C8, 80) : sc2 and sc3 ? color.new(#9C27B0, 80) : color.new(#673AB7, 80)
clr3_bg        = sc1 and sc3 ? color.new(#15FF00, 80) : sc1 and sc4 ? color.new(#388E3C, 80) : 
   sc2 and sc4 ? color.new(#F44336, 80) : sc2 and sc3 ? color.new(#B71C1C, 80) : color.new(color.gray, 80)
clr4_bg        = sc1 and sc3 ? color.new(#fff59d, 80) : 
   sc1 and sc4 ? color.new(#FFD600, 80) : sc2 and sc4 ? color.new(#FFCC80, 80) : sc2 and sc3 ? color.new(#FF9800, 80) : color.new(#702700, 80)
clr5_bg        = sc1 and sc3 ? color.new(#2196F3, 80) : 
   sc1 and sc4 ? color.new(#0D47A1, 80) : sc2 and sc4 ? color.new(#EF9A9A, 80) : sc2 and sc3 ? color.new(#D32F2F, 80) : color.new(#CE93D8, 80)
choice_bg      = color_M == 1 ? clr1_bg : color_M == 2 ? clr2_bg : 
   color_M == 3 ? clr3_bg : color_M == 4 ? clr4_bg : color_M == 5 ? clr5_bg : na

bgcolor(darkm ? bgc_dark : na, title = "Gray Background", editable=false)
bgcolor(bgoff ? na : choice_bg, title = "Momentum Background")

//______________________________________________________________________________
// Snapshot Collect-then-Draw Engine (mirrors CQ_(L)_Reverse MACD Overlay)
// All oscillators (Momentum, Strength, Signal, ADX, Key Level) are redrawn
// once per bar-close using ONE shared `baseline`/`hAdj`/`oscHighest`, so the
// zero-line and every series sit flush against a single straight baseline.
//______________________________________________________________________________
var a_lines = array.new_line()
var a_hist  = array.new_box()

if barstate.islast
    if array.size(a_lines) > 0
        for _i = 1 to array.size(a_lines)
            line.delete(array.shift(a_lines))
    if array.size(a_hist) > 0
        for _i = 1 to array.size(a_hist)
            box.delete(array.shift(a_hist))

    // Baseline / Zero Line — one straight segment spanning the whole window
    if zeroSQZ
        array.push(a_lines, line.new(
             bar_index - i_lookback + 1, baseline, bar_index, baseline,
             xloc.bar_index, extend.none, color_zero, line.style_solid, 2))

    // ── PASS 1: boxes (Momentum histogram + Strength) — drawn first so every
    // line created in Pass 2 is guaranteed to render on top of them, since
    // Pine stacks later-created drawing objects above earlier ones regardless
    // of type or bar position. ──────────────────────────────────────────────
    for b = 0 to i_lookback - 1
        if array.size(a_hist) < 490

            // ── Momentum: Columns/Histogram/Area as baseline-anchored boxes ──
            // Boxes have real width (bar_index[b] to bar_index[b]+1), a
            // user-configurable border, and the color set via bgcolor so they
            // render as solid filled columns instead of a top/bottom outline
            // artifact.
            if show_Momen and (StyleMom == "Columns" or StyleMom == "Histogram" or StyleMom == "Area")
                float momTop = baseline * (1 + sz[b] / oscHighest * hAdj)
                bwc = StyleMom == "Area" ? color.new(color_mom[b], 70) : color_mom[b]
                int momCenterT = time[b] + int(barMs / 2)
                array.push(a_hist, box.new(momCenterT - histHalfWidthMs, baseline, momCenterT + histHalfWidthMs, momTop, xloc = xloc.bar_time, border_color = i_histBorderColor, border_width = i_histBorderWidth, bgcolor = bwc))

            // ── Momentum Strength boxes (same real-width/bgcolor fill technique) ──
            if show_strength
                float strTop = baseline * (1 + (momentum_strength[b]*3) / oscHighest * hAdj)
                int strCenterT = time[b] + int(barMs / 2)
                array.push(a_hist, box.new(strCenterT - histHalfWidthMs, baseline, strCenterT + histHalfWidthMs, strTop, xloc = xloc.bar_time, border_color = i_histBorderColor, border_width = i_histBorderWidth, bgcolor = color_strength_cloud[b]))

    // ── PASS 2: lines (Momentum-Line, Signal, ADX, Key Level) — created after
    // every box above, so they always sit visually on top of the histogram. ──
    for b = 0 to i_lookback - 1
        if array.size(a_lines) < 490

            // ── Momentum: Line style ──
            if show_Momen and StyleMom == "Line"
                array.push(a_lines, line.new(
                     bar_index[b],     baseline * (1 + sz[b]   / oscHighest * hAdj),
                     bar_index[b + 1], baseline * (1 + sz[b+1] / oscHighest * hAdj),
                     xloc.bar_index, extend.none, color_mom[b], line.style_solid, 2))

            // ── Signal(Momentum) line ──
            if showSignal
                array.push(a_lines, line.new(
                     bar_index[b],     baseline * (1 + sigM[b]   / oscHighest * hAdj),
                     bar_index[b + 1], baseline * (1 + sigM[b+1] / oscHighest * hAdj),
                     xloc.bar_index, extend.none, color_sigM[b], line.style_solid, 2))

            // ── ADX line ──
            if show_ADX
                array.push(a_lines, line.new(
                     bar_index[b],     baseline * (1 + adx_scale[b]   / oscHighest * hAdj),
                     bar_index[b + 1], baseline * (1 + adx_scale[b+1] / oscHighest * hAdj),
                     xloc.bar_index, extend.none, color_ADX[b], line.style_solid, 2))

                // ── Key Level line ──
                if not zeroSQZ
                    array.push(a_lines, line.new(
                         bar_index[b],     baseline * (1 + keylevel_scale[b]   / oscHighest * hAdj),
                         bar_index[b + 1], baseline * (1 + keylevel_scale[b+1] / oscHighest * hAdj),
                         xloc.bar_index, extend.none, keyColor ? dmiColor[b] : color_ADX[b], line.style_solid, 1))

// Colored DMI (location.bottom is chart-relative, works unchanged on overlay)
// show_last ties visibility to the same "Display Length (bars)" window used
// by the Overlay Layout baseline engine, so historic triangles beyond that
// range are hidden.
plotshape(show_DMI and diplus >= diminus, " +DI > -DI", shape.triangleup,   location.bottom, dmiColor, show_last = i_lookback)
plotshape(show_DMI and diplus <  diminus, " +DI < -DI", shape.triangledown, location.bottom, dmiColor, show_last = i_lookback)

alert_dmiBull = detect_bull_dmi and (dmiBull and dmiBull[1] != dmiBull)
alert_dmiBear = detect_bear_dmi and (dmiBear and dmiBear[1] != dmiBear)

if alert_dmiBull
    alert('Symbol = (' + syminfo.tickerid + ') \n TimeFrame = (' + timeframe.period + ') \n Current Price (' + str.tostring(close) + ') \n Bullish Trend [DMI].', alert.freq_once_per_bar_close)

if alert_dmiBear
    alert('Symbol = (' + syminfo.tickerid + ') \n TimeFrame = (' + timeframe.period + ') \n Current Price (' + str.tostring(close) + ') \n Bearish Trend [DMI].', alert.freq_once_per_bar_close)

// Label — position reference is the baseline (the shared zero-point anchor)
oneDay = 24 * 60 * 60 * 1000
barsAhead = 3
onward = if timeframe.ismonthly
    barsAhead * oneDay * 30
else if timeframe.isweekly
    barsAhead * oneDay * 7
else if timeframe.isdaily
    barsAhead * oneDay
else if timeframe.isminutes
    barsAhead * oneDay * timeframe.multiplier / 1440
else if timeframe.isseconds
    barsAhead * oneDay * timeframe.multiplier / 86400
else
    0

lbStat  = histLabel > 0 ? "\n\n Timeframe: " + timeframe.period + ", " + str.tostring(histLabel) + " bar(s) earlier historical value.-": 
          "\n\n Timeframe: " + timeframe.period + ", last DI cross " + str.tostring(diCross) + " bar(s) before.-"

adxMom  = slope_positive ? " ▲ Rising | Previous ADX: " + str.tostring(adxValue[1], "#.##") + ")\n» " : " ▼ Falling | Previous ADX(" + str.tostring(adxValue[1], "#.##") + ")\n» "

diStat  = diplus >= diminus ? "DI+ (" + str.tostring(diplus, "#.##") + ") >= DI- (" + str.tostring(diminus, "#.##") + ")" :
          "DI+ (" + str.tostring(diplus, "#.##") + ") < DI- (" + str.tostring(diminus, "#.##") + ")"

dmiText = dmiBull ? strong + " Bullish\n» ADX(" + str.tostring(adxValue, "#.##") + ")" + adxMom + diStat: 
          dmiBear ? strong + " Bearish\n» ADX(" + str.tostring(adxValue, "#.##") + ")" + adxMom + diStat:
          dmiWeak ? "WEAK " + weak_up_dn + "\n» ADX(" + str.tostring(adxValue, "#.##") + ")" + adxMom + diStat:
          "NO TREND\n» ADX(" + str.tostring(adxValue, "#.##") + ")" + adxMom + diStat

// ── FIX: phantom DMI label bug ──────────────────────────────────────────────
// The previous approach created a fresh label every execution and tried to
// delete the label via bar-indexed history: label.delete(dmiLabel[1]).
// dmiLabel[1] only advances once a bar CLOSES, but this block runs on every
// realtime tick of the still-forming bar. Each intra-bar tick created a new
// label without deleting the one from the previous tick of that same bar —
// only the last tick's label of the PREVIOUS candle ever got cleaned up when
// the next bar started. Every earlier tick's label was orphaned forever,
// which is exactly the "phantom drawing left behind on every new candle" bug.
//
// Fix: track the actual live object reference in a `var label` and explicitly
// delete THAT reference on every single execution (every tick) before
// creating the replacement. This guarantees at most one live label exists at
// any moment, regardless of how many ticks occur within a bar.
var label dmiLabel = na
label.delete(dmiLabel)
dmiLabel := na

if not hideLabel
    dmiLabel := label.new(time, baseline, text="DMI reading: " + dmiText[histLabel] + lbStat
         ,tooltip="                 ◁ Colored DMI Reading ▷\n🔘 Triangle Shapes:\n      ▲- Bullish : DI+ >= DI-\n      ▼- Bearish : DI+ < DI-\n🔘 Colors:\n     🟩 - Bullish : ADX >= 23 and DI+ > DI-\n     🟥 - Bearish : ADX >= 23 and DI+ < DI- \n     ⬜ - Weak Trend : Weak Trend < ADX < 23\n     🟧 - No Trend : ADX < Weak Trend\n🔘 Color Density:\n      Darker : ADX Rising\n      Lighter : ADX Falling "
         ,color=dmiColor[histLabel], xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, size=dmiLabelSize, textcolor = txtColor, textalign=text.align_left)
    label.set_x(dmiLabel, label.get_x(dmiLabel) + onward)

//_____________________________________________________________________________________
// Hull Moving Average
//_____________________________________________________________________________________
// EHMA    
EHMA(_src, _length) =>  ta.ema((2 * ta.ema(_src, _length / 2)) - ta.ema(_src, _length), math.round(math.sqrt(_length)))
// THMA    
THMA(_src, _length) =>  ta.wma(ta.wma(_src, _length / 3) * 3 - ta.wma(_src, _length / 2) - ta.wma(_src, _length), _length)
// Adaptive HMA 
AHMA(_src, _length) => ta.wma(2 * ta.wma(_src, _length / 2) - ta.wma(_src, _length), math.floor(math.sqrt(_length))) 

// Hull type
hull_type(type, src, len) =>
    type == "HMA"  ? ta.hma(src, len) : type == "EHMA" ? EHMA(src, len) : type == "THMA" ? THMA(src, len/2) : AHMA(src, len)

xHMA = hull_type(h_type, get_src(h_src), h_Length)
longHMA  = ta.crossover(xHMA[0], xHMA[2])
shortHMA = ta.crossunder(xHMA[0], xHMA[2])

hull_color = xHMA[0] > xHMA[2] ? color.new(#45CEA2, 85) : color.new(#CE4571, 85)
bgcolor(bg_Hull ? hull_color : na, title = "Hull MA Background")
plotshape(show_Hull and longHMA,  "Hull - Long Cross",  shape.triangleup,   location.bottom, color.new(#45CEA2, 10), size=size.tiny, text='H', textcolor = #45CEA2)
plotshape(show_Hull and shortHMA, "Hull - Short Cross", shape.triangledown, location.top,    color.new(#CE4571, 10), size=size.tiny, text='H', textcolor = #CE4571)

//______________________________________________________________________________
// The Expert Trend Locator - XTL 
//______________________________________________________________________________
media  = ma(MA_Type2, get_src(src_xtl), period_xtl)
cciNT = (get_src(src_xtl) - media) / (0.015 * ta.dev(get_src(src_xtl), period_xtl))
cciT  = (get_src(src_xtl) - media) / (0.015 * ta.dev(math.abs(get_src(src_xtl) - media), period_xtl))
values = uTrad ? cciT : cciNT

var color color_XTL = na
if (values < -fixed_Value) 
    color_XTL := color_xtlDN // Bear
if (-fixed_Value <= values and values <= fixed_Value)
    color_XTL := color_xtlNe // Neutral
if (values > fixed_Value)
    color_XTL := color_xtlUP // Bull
barcolor(candles_XTL ? color_XTL : na, title="XTL - Expert Trend Locator", editable=false) 


//___________________________________________________________________________________________
// Based on "Better Divergence On Any Indicator" - Author: @DoctaBot
// https://www.tradingview.com/script/tbrsp75I-Better-Divergence-On-Any-Indicator-DoctaBot/
// Pivot DETECTION runs on raw oscillator units (unaffected by scale); only the
// drawn coordinates are passed through scaledPrice() so they sit correctly on
// the baseline-anchored overlay.
//___________________________________________________________________________________________
osc             = show_Momen and drdiv ? sz : na
bearColor       = color.new(color.red, 0)
bullColor       = color.new(color.lime, 0)
hiddenBullColor = color.new(#00945F, 15)
hiddenBearColor = color.new(#990040, 15)
textColor       = color.new(color.white, 0)
textColor2      = color.new(#000000, 15)

repaint = (not(delay_plot_til_closed) or barstate.ishistory or barstate.isconfirmed)

plFound = na(ta.pivotlow(osc, lbL, lbR))  ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true

_inRange(cond, occurence) =>
	bars = (bar_index - ta.valuewhen(cond, bar_index, occurence))
	rangeLower <= bars and bars <= rangeUpper
	
oscPLCur    = ta.valuewhen(plFound, osc[lbR], 0)                    //Current Oscillator Pivot Low
oscPL1      = ta.valuewhen(plFound, osc[lbR], 1)                    //Last Oscillator Pivot Low
oscPL2      = ta.valuewhen(plFound, osc[lbR], 2)                    //2 Back Oscillator Pivot Low

oscPLCurBar = ta.valuewhen(plFound, bar_index - lbR, 0)             //Current Oscillator Pivot Low Bar Index
oscPL1Bar   = ta.valuewhen(plFound, bar_index - lbR, 1)             //Last Oscillator Pivot Low Bar Index
oscPL2Bar   = ta.valuewhen(plFound, bar_index - lbR, 2)             //2 Back Oscillator Pivot Low Bar Index

oscPHCur    = ta.valuewhen(phFound, osc[lbR], 0)                    //Current Oscillator Pivot High
oscPH1      = ta.valuewhen(phFound, osc[lbR], 1)                    //Last Oscillator Pivot High
oscPH2      = ta.valuewhen(phFound, osc[lbR], 2)                    //2 Back Oscillator Pivot High

oscPHCurBar = ta.valuewhen(phFound, bar_index - lbR, 0)             //Current Oscillator Pivot High Bar Index
oscPH1Bar   = ta.valuewhen(phFound, bar_index - lbR, 1)             //Last Oscillator Pivot High Bar Index
oscPH2Bar   = ta.valuewhen(phFound, bar_index - lbR, 2)             //2 Back Oscillator Pivot High Bar Index

oscPL2Slope = (osc[lbR] - oscPL2)/((bar_index - lbR) - oscPL2Bar)   //Slope Between Pivot Lows
oscPL2Lim   = ((oscPL1Bar - oscPL2Bar)*(oscPL2Slope)) + oscPL2      //Pivot Low Oscillator Intersect Limit

oscPH2Slope = (osc[lbR] - oscPH2)/((bar_index - lbR) - oscPH2Bar)   //Slope Between Pivot Highs
oscPH2Lim   = ((oscPH1Bar - oscPH2Bar)*(oscPH2Slope)) + oscPH2      //Pivot High Oscillator Intersect Limit

// Oscilator Pivots
oscHL1 = (osc[lbR] > oscPL1 and _inRange(plFound, 1))                           //Osc. Higher Low compared to previous
oscHL2 = (osc[lbR] > oscPL2 and _inRange(plFound, 2) and oscPL1 > oscPL2Lim)    //Osc. Higher Low compared to 2 back with no intersection
     
oscLL1 = (osc[lbR] < oscPL1 and _inRange(plFound, 1))                           //Osc. Lower Low compared to previous
oscLL2 = (osc[lbR] < oscPL2 and _inRange(plFound, 2) and oscPL1 > oscPL2Lim)    //Osc. Lower Low compared to 2 back with no intersection
        
oscLH1 = (osc[lbR] < oscPH1 and _inRange(phFound, 1))                           //Osc. Lower High compared to previous
oscLH2 = (osc[lbR] < oscPH2 and _inRange(phFound, 2) and oscPH1 < oscPH2Lim)    //Osc. Lower High compared to 2 back with no intersection
        
oscHH1 = (osc[lbR] > oscPH1 and _inRange(phFound, 1))                           //Osc. Higher High compared to previous
oscHH2 = (osc[lbR] > oscPH2 and _inRange(phFound, 2) and oscPH1 < oscPH2Lim)    //Osc. Higher High compared to 2 back with no intersection

// Price Pivots
priceLL1 = ta.lowest(close, lbR + 2) < ta.valuewhen(plFound, ta.lowest(close, lbR + 2), 1)      //Price Lower Low compared to previous
priceLL2 = ta.lowest(close, lbR + 2) < ta.valuewhen(plFound, ta.lowest(close, lbR + 2), 2)      //Price Lower Low compared to 2 back

priceHL1 = ta.lowest(close, lbR + 2) > ta.valuewhen(plFound, ta.lowest(close, lbR + 2), 1)      //Price Higher Low compared to previous
priceHL2 = ta.lowest(close, lbR + 2) > ta.valuewhen(plFound, ta.lowest(close, lbR + 2), 2)      //Price Higher Low compared to 2 back

priceHH1 = ta.highest(close, lbR + 2) > ta.valuewhen(phFound, ta.highest(close, lbR + 2), 1)    //Price Higher High compared to previous
priceHH2 = ta.highest(close, lbR + 2) > ta.valuewhen(phFound, ta.highest(close, lbR + 2), 2)    //Price Higher High compared to 2 back

priceLH1 = ta.highest(close, lbR + 2) < ta.valuewhen(phFound, ta.highest(close, lbR + 2), 1)    //Price Lower High compared to previous
priceLH2 = ta.highest(close, lbR + 2) < ta.valuewhen(phFound, ta.highest(close, lbR + 2), 2)    //Price Lower High compared to 2 back

// Conditions
bullCond1       = plotBull          and plFound and repaint and (priceLL1 and oscHL1) and osc < 0
bullCond2       = plotBull          and plFound and repaint and (usex2LB ? (priceLL2 and oscHL2) : false) and osc < 0

hiddenBullCond1 = plotHiddenBull    and plFound and repaint and (priceHL1 and oscLL1) and osc < 0
hiddenBullCond2 = plotHiddenBull    and plFound and repaint and (usex2LB ? (priceHL2 and oscLL2) : false) and osc < 0

bearCond1       = plotBear          and phFound and repaint and (priceHH1 and oscLH1) and osc > 0
bearCond2       = plotBear          and phFound and repaint and (usex2LB ? (priceHH2 and oscLH2) : false) and osc > 0

hiddenBearCond1 = plotHiddenBear    and phFound and repaint and (priceLH1 and oscHH1) and osc > 0
hiddenBearCond2 = plotHiddenBear    and phFound and repaint and (usex2LB ? (priceLH2 and oscHH2) : false) and osc > 0

f_drawLine(_x1, _x2, _y1, _y2, _color, _width) =>
    line.new(
     x1     = _x1,
     x2     = _x2,
     y1     = _y1,
     y2     = _y2,
     color  = _color,
     width  = _width,
     xloc   = xloc.bar_index
     )

// Divergence connector lines are one-off drawn objects (not redrawn every bar
// like plotshape), so they need to be tracked and pruned manually once they
// fall outside the "Display Length (bars)" window used everywhere else.
var a_bullDivLines = array.new_line()
var a_bearDivLines = array.new_line()

// Plot Bull Lines (y-coordinates anchored to `baseline`; x/y fine-tuned by i_bullDivOffset/i_bullDivVOffset)
if plFound
    array.push(a_bullDivLines, f_drawLine(
     (bullCond1 or hiddenBullCond1 ? oscPL1Bar : bullCond2 or hiddenBullCond2 ? oscPL2Bar : oscPLCurBar) + i_bullDivOffset, 
     oscPLCurBar + i_bullDivOffset, 
     scaledPrice(bullCond1 or hiddenBullCond1 ? oscPL1 : bullCond2 or hiddenBullCond2 ? oscPL2 : oscPLCur) + i_bullDivVOffset * tick, 
     scaledPrice(oscPLCur) + i_bullDivVOffset * tick, 
     bullCond1 or bullCond2 ? bullColor : hiddenBullColor, 
     2))

// Plot Bear Lines (y-coordinates anchored to `baseline`; x/y fine-tuned by i_bearDivOffset/i_bearDivVOffset)
if phFound
    array.push(a_bearDivLines, f_drawLine(
     (bearCond1 or hiddenBearCond1 ? oscPH1Bar : bearCond2 or hiddenBearCond2 ? oscPH2Bar : oscPHCurBar) + i_bearDivOffset, 
     oscPHCurBar + i_bearDivOffset, 
     scaledPrice(bearCond1 or hiddenBearCond1 ? oscPH1 : bearCond2 or hiddenBearCond2 ? oscPH2 : oscPHCur) + i_bearDivVOffset * tick, 
     scaledPrice(oscPHCur) + i_bearDivVOffset * tick, 
     bearCond1 or bearCond2 ? bearColor : hiddenBearColor, 
     2))

// Prune connector lines that have aged out of the Display Length window
if array.size(a_bullDivLines) > 0
    for i = array.size(a_bullDivLines) - 1 to 0
        ln = array.get(a_bullDivLines, i)
        if bar_index - line.get_x2(ln) > i_lookback
            line.delete(ln)
            array.remove(a_bullDivLines, i)

if array.size(a_bearDivLines) > 0
    for i = array.size(a_bearDivLines) - 1 to 0
        ln = array.get(a_bearDivLines, i)
        if bar_index - line.get_x2(ln) > i_lookback
            line.delete(ln)
            array.remove(a_bearDivLines, i)

// Plot Bull Labels (show_last caps visibility to the Display Length window)
plotshape(
	 bullCond1 or bullCond2 ? scaledPrice(osc[lbR]) + i_bullDivVOffset * tick : na,
	 offset=-lbR + i_bullDivOffset,
	 title="Regular Bullish Label",
	 text=" R ",
	 style=shape.labelup,
	 location=location.absolute,
	 color=bullColor,
	 textcolor=textColor2,
	 show_last=i_lookback
	 )

// Plot Hidden Bull Labels
plotshape(
	 hiddenBullCond1 or hiddenBullCond2 ? scaledPrice(osc[lbR]) + i_bullDivVOffset * tick : na,
	 offset=-lbR + i_bullDivOffset,
	 title="Hidden Bullish Label",
	 text=" H ",
	 style=shape.labelup,
	 location=location.absolute,
	 color=hiddenBullColor,
	 textcolor=textColor,
	 show_last=i_lookback
	 )

// Plot Bear Labels
plotshape(
	 bearCond1 or bearCond2 ? scaledPrice(osc[lbR]) + i_bearDivVOffset * tick : na,
	 offset=-lbR + i_bearDivOffset,
	 title="Regular Bearish Label",
	 text=" R ",
	 style=shape.labeldown,
	 location=location.absolute,
	 color=bearColor,
	 textcolor=textColor,
	 show_last=i_lookback
	 )

// Plot Hidden Bear Labels
plotshape(
	 hiddenBearCond1 or hiddenBearCond2 ? scaledPrice(osc[lbR]) + i_bearDivVOffset * tick : na,
	 offset=-lbR + i_bearDivOffset,
	 title="Hidden Bearish Label",
	 text=" H ",
	 style=shape.labeldown,
	 location=location.absolute,
	 color=hiddenBearColor,
	 textcolor=textColor,
	 show_last=i_lookback
	 )

// Alerts
if bullCond1 or bullCond2
    alert("Regular Bull Divergence", alert.freq_once_per_bar_close )

if hiddenBullCond1 or hiddenBullCond2
    alert("Hidden Bull Divergence", alert.freq_once_per_bar_close )
    
if bearCond1 or bearCond2
    alert("Regular Bear Divergence", alert.freq_once_per_bar_close )
    
if hiddenBearCond1 or hiddenBearCond2
    alert("Hidden Bear Divergence", alert.freq_once_per_bar_close )
    
alertcondition(bullCond1 or bullCond2,             title = "Regular Bull Divergence", message = "Regular Bull Divergence")
alertcondition(hiddenBullCond1 or hiddenBullCond2, title = "Hidden Bull Divergence",  message = "Hidden Bull Divergence")
alertcondition(bearCond1 or bearCond2,             title = "Regular Bear Divergence", message = "Regular Bear Divergence")
alertcondition(hiddenBearCond1 or hiddenBearCond2, title = "Hidden Bear Divergence",  message = "Hidden Bear Divergence")
````
