# MSL Squeeze Pulse

- url: https://www.tradingview.com/script/r5K5QbCv-msl-squeeze-pulse/
- type: indicator
- pine_id: PUB;2600c6fc17264fb39a689f8c23a6e9c5
- version: 2.0

## Description

**MSL Squeeze Pulse** is a volatility-compression and momentum indicator. It highlights when the market is winding up before an explosive move and shows the direction once the spring uncoils.

### What you see

- **Yellow background on the pane** — the market is currently in compression. Price is tightening, volatility is fading, movement stalls. The longer the yellow stays on, the larger the expected breakout.
- **Yellow diamond on the zero line** — the bar where the coil unwinds. Compression has ended, a new move begins.
- **Pulse histogram** — direction and pace of the move:
    - filled green = up, accelerating
    - hollow green = up, fading
    - filled red = down, accelerating
    - hollow red = down, fading
- **Dots on the zero line** — current volatility state: yellow = coiled, gray = expanded, blue = neutral.

### How to use

This is a context tool, not a stand-alone signal. The yellow zone is your cue to prepare: pick the setup, mark levels, wait for direction. When the tint clears and the diamond appears, look at the histogram color — that's the direction the coil released into.

On a strong trend the histogram stays solidly filled. The first hollow bars are an early warning that momentum is fading.

### Alerts (optional)

Via TradingView's Add Alert dialog you can set push/email notifications:

- **Coil On** — compression has started
- **Coil Released** — the spring uncoiled
- **Pulse Flip Up / Down** — pulse changed sign

Alerts are notifications only — nothing is drawn on the chart. The indicator does NOT produce BUY/SELL arrows.

### Suggested timeframes

- Intraday: 15m – 4h
- Swing: 1D – 1W

### Settings

- **Volatility Length / Mult** — standard-deviation band parameters. Wider band = rarer coils.
- **Channel Length / Mult** — bar-range channel parameters. Wider channel = more frequent coils.
- **Use True Range** — use True Range instead of high − low (handles gaps).[url=https://www.tradingview.com/x/6j9riC1f/]https://www.tradingview.com/x/6j9riC1f/[/url][image]https://www.tradingview.com/x/6j9riC1f/[/image]

## Source Code

````pine
// This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// You may share and adapt this code for non-commercial purposes, with attribution.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// MSL Squeeze Pulse — developed by MarketStructureLab.
// May your trades be green and your stops never hit. Good luck out there.
//@version=6
indicator(title="MSL Squeeze Pulse", shorttitle="MSL Sqz", overlay=false, precision=2, max_bars_back=1000)

//==== INPUTS ============================================================
groupCalc   = "Calculation"
groupVisual = "Visuals"

priceSrc = input.source(close, title="Source", group=groupCalc, display=display.none, tooltip="Price series used for the dispersion measure and for the pulse oscillator. Default close. The range measure and the range midpoint always use high and low regardless of this setting.")
bandLen  = input.int(defval=20, minval=2, maxval=500, title="Volatility Length", group=groupCalc, display=display.none, tooltip="Lookback of the standard deviation of the source. Higher = smoother dispersion reading and slower state changes; lower = more reactive.")
chanLen  = input.int(defval=20, minval=2, maxval=500, title="Channel Length", group=groupCalc, display=display.none, tooltip="Lookback of the average bar range. Also sets the window of the pulse oscillator and the length of its ATR normalisation, so changing it changes the histogram as well. Higher = smoother; lower = more reactive.")
useTR    = input.bool(defval=true, title="Use True Range", group=groupCalc, display=display.none, tooltip="Use True Range for the range measure. Off uses high - low. True Range accounts for gaps between sessions.")
rankLen  = input.int(defval=252, minval=50, maxval=500, title="Compression Lookback", group=groupCalc, display=display.none, tooltip="How many bars of its own history the compression ratio is ranked against. Higher = the state reflects a longer volatility regime and changes less often; lower = the state adapts faster to the recent regime. Until this many bars exist the rank is undefined and the state is held neutral, while the histogram is calculated as usual from the start.")
statePct = input.float(defval=25.0, minval=1.0, maxval=49.0, step=1.0, title="State Percentile", group=groupCalc, display=display.none, tooltip="Percentile that defines the two outer states. Coiled is a rank at or below this value, expanded is a rank at or above 100 minus this value, and the rest is neutral. Higher = coiled and expanded occur more often and neutral shrinks; lower = both outer states become rarer and neutral widens.")

showPulse   = input.bool(defval=true, title="Show Pulse Histogram", group=groupVisual, display=display.none, tooltip="Plot the pulse histogram.")
showState   = input.bool(defval=true, title="Show State Markers", group=groupVisual, display=display.none, tooltip="Plot the compression state dots on the zero line.")
showBgTint  = input.bool(defval=true, title="Highlight Coil Zones", group=groupVisual, display=display.none, tooltip="Tint the indicator pane background while the compression ratio sits in its coiled percentile.")
showRelease = input.bool(defval=true, title="Mark Coil Release", group=groupVisual, display=display.none, tooltip="Highlight the single bar where the coiled state ends. The state that follows can be neutral or expanded.")

bullColor     = input.color(color.rgb(34, 197, 94),   title="Bull",     inline="pulse", group=groupVisual, display=display.none, tooltip="Positive pulse color (filled = extending, hollow = fading).")
bearColor     = input.color(color.rgb(239, 68, 68),   title="Bear",     inline="pulse", group=groupVisual, display=display.none, tooltip="Negative pulse color (filled = extending, hollow = fading).")
coiledColor   = input.color(color.rgb(245, 158, 11),  title="Coiled",   inline="state", group=groupVisual, display=display.none, tooltip="Dot color when the compression ratio is in its lowest percentile band. Also used for the background tint and the release marker.")
expandedColor = input.color(color.rgb(203, 213, 225), title="Expanded", inline="state", group=groupVisual, display=display.none, tooltip="Dot color when the compression ratio is in its highest percentile band.")
neutralColor  = input.color(color.rgb(71, 85, 105),   title="Neutral",  inline="state", group=groupVisual, display=display.none, tooltip="Dot color when the compression ratio sits between the two percentile bands. This is the most common state at the default percentile.")

//==== COLORS ============================================================
gridColor  = color.new(color.gray, 75)
guideColor = color.new(color.gray, 85)

//==== HELPERS ===========================================================
safeDiv(a, b) => b == 0 or na(b) ? 0.0 : a / b

//==== CALCULATIONS ======================================================
// Two measures of how much the market is moving.
// Dispersion: how far the source spreads around its own mean.
dispersion = ta.stdev(priceSrc, bandLen)

// Travel: how much ground a bar physically covers, averaged.
barRng = useTR ? ta.tr(true) : (high - low)
travel = ta.sma(barRng, chanLen)

// Compression ratio, then its place inside its own history.
sqRatio = safeDiv(dispersion, travel)
sqRank  = ta.percentrank(sqRatio, rankLen)

coiled   = not na(sqRank) and sqRank <= statePct
expanded = not na(sqRank) and sqRank >= 100.0 - statePct

// Pulse oscillator: displacement from the midpoint of the recent range,
// fitted over the window and expressed in ATR units.
rangeMid   = (ta.highest(high, chanLen) + ta.lowest(low, chanLen)) / 2
atrRef     = ta.atr(chanLen)
pulseFit   = ta.linreg(priceSrc - rangeMid, chanLen, 0)
pulseVal   = safeDiv(pulseFit, atrRef)

// State transitions (used for alerts and the release marker)
coilOn        = coiled and not coiled[1]
coilReleased  = (not coiled) and coiled[1]
pulseFlipUp   = pulseVal > 0 and nz(pulseVal[1]) <= 0
pulseFlipDown = pulseVal < 0 and nz(pulseVal[1]) >= 0

//==== VISUAL STATE ======================================================
isUpPulse  = pulseVal > 0
accelPulse = isUpPulse ? pulseVal > nz(pulseVal[1]) : pulseVal < nz(pulseVal[1])
baseColor  = isUpPulse ? bullColor : bearColor

pulseBorder = showPulse ? baseColor : na
pulseBody   = showPulse ? (accelPulse ? baseColor : color.new(baseColor, 100)) : na

pulseOpen  = 0.0
pulseClose = pulseVal
pulseHigh  = math.max(0.0, pulseVal)
pulseLow   = math.min(0.0, pulseVal)

stateColor = coiled ? coiledColor : expanded ? expandedColor : neutralColor
statePlot  = showState ? 0.0 : na

bgTint       = (showBgTint and coiled) ? color.new(coiledColor, 88) : na
releaseFire  = (showRelease and coilReleased) ? 0.0 : na
releaseColor = color.new(coiledColor, 0)

//==== PLOTS =============================================================
hline(0, "Zero", color=gridColor)
hline(1, "Plus one ATR", color=guideColor, linestyle=hline.style_dashed)
hline(-1, "Minus one ATR", color=guideColor, linestyle=hline.style_dashed)
bgcolor(bgTint, title="Coil Highlight")

plotcandle(pulseOpen, pulseHigh, pulseLow, pulseClose, title="Pulse", color=pulseBody, bordercolor=pulseBorder, wickcolor=pulseBorder)
plot(statePlot, title="Coil State", style=plot.style_circles, linewidth=3, color=stateColor)
plotshape(releaseFire, title="Coil Release", style=shape.diamond, location=location.absolute, size=size.small, color=releaseColor)

//==== ALERTS ============================================================
alertcondition(coilOn,        title="Coil On",        message="{{ticker}} compression ratio entered its coiled percentile on {{interval}}")
alertcondition(coilReleased,  title="Coil Released",  message="{{ticker}} compression ratio left its coiled percentile on {{interval}}")
alertcondition(pulseFlipUp,   title="Pulse Flip Up",  message="{{ticker}} pulse flipped positive on {{interval}}")
alertcondition(pulseFlipDown, title="Pulse Flip Down", message="{{ticker}} pulse flipped negative on {{interval}}")

//==== USAGE GUIDE =======================================================
// The two states are percentiles of the script's own compression ratio, so a
// coiled reading always appears at roughly the rate you set, even in a market
// that never truly compresses. The ratio is dispersion divided by travel: it
// falls when closes cluster while bars keep covering their usual ground.
// The pulse is a lagging measure of displacement already in place, in ATR
// units, so heights are comparable between symbols and timeframes.
// Nothing here defines an entry, a stop or a target.
````
