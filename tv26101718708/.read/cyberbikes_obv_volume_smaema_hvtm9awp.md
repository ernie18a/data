# Cyberbikes OBV + Volume SMA/EMA

- url: https://www.tradingview.com/script/hVtM9aWP-Cyberbikes-OBV-Volume-SMA-EMA/
- type: indicator
- pine_id: PUB;e6473e91f7c0431b814a3a2ac22bb668
- version: 1.0

## Description

How it works:

obv = standard On-Balance-Volume (with your zero-volume guard kept).
vol = raw bar volume.
Both get normalized to 0–100 over normLen, then weighted-averaged into combined.
smaCurve / emaCurve are the SMA and EMA of that combined OBV+Volume series, length set by timeframe.
The ribbon between them is green when the EMA is rising (above its previous bar) and red when falling — same logic as your other indicator.
Knobs:

OBV Weight / Volume Weight — lean the blend toward trend-conviction (OBV) or raw activity (Volume). Set one to 0 to use only the other.
Auto length by timeframe / Manual Length — smoothing control.

## Source Code

````pine
//@version=6
indicator(title="Cyberbikes OBV + Volume — SMA/EMA", shorttitle="CB OBV+VOL", timeframe="", timeframe_gaps=true)

// ════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════════════════
GRP_B = "Blend"
normLen = input.int(50, "Normalization Lookback", minval=2, group=GRP_B, tooltip="Window used to rescale OBV and Volume into 0–100 so they can be combined on one scale.")
wObv    = input.float(1.0, "OBV Weight",    minval=0, step=0.1, group=GRP_B)
wVol    = input.float(1.0, "Volume Weight", minval=0, step=0.1, group=GRP_B)

GRP_SM = "Smoothing"
autoByTf  = input.bool(true, "Auto length by timeframe", group=GRP_SM, tooltip="When on, SMA/EMA length is chosen from the chart timeframe. When off, uses Manual Length.")
manualLen = input.int(14, "Manual Length", minval=1, group=GRP_SM)
showRaw   = input.bool(false, "Show raw combined", group=GRP_SM)

// ════════════════════════════════════════════════════════════════════════════
//  DATA: OBV + VOLUME
// ════════════════════════════════════════════════════════════════════════════
var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("No volume is provided by the data vendor.")

src = close
obv = ta.cum(math.sign(ta.change(src)) * volume)
vol = volume

// Rescale a series to 0–100 over a lookback
norm(s, len) =>
    lo = ta.lowest(s, len)
    hi = ta.highest(s, len)
    hi == lo ? 50.0 : 100.0 * (s - lo) / (hi - lo)

obvN = norm(obv, normLen)
volN = norm(vol, normLen)

// Combined OBV + Volume (weighted), 0–100
wSum     = wObv + wVol
combined = wSum == 0 ? 50.0 : (obvN * wObv + volN * wVol) / wSum

// ════════════════════════════════════════════════════════════════════════════
//  TIMEFRAME-DRIVEN SMOOTHING LENGTH
// ════════════════════════════════════════════════════════════════════════════
autoLen() =>
    s = timeframe.in_seconds()
    s <= 60 ? 50 : s <= 300 ? 34 : s <= 900 ? 21 : s <= 3600 ? 14 : s <= 14400 ? 10 : 9
len = autoByTf ? autoLen() : manualLen

smaCurve = ta.sma(combined, len)
emaCurve = ta.ema(combined, len)

// EMA slope: green when rising vs its previous bar, red when falling
emaRising = emaCurve > emaCurve[1]

// ════════════════════════════════════════════════════════════════════════════
//  PLOTS
// ════════════════════════════════════════════════════════════════════════════
hline(50, "Midline", color=color.new(#787B86, 70))

plot(showRaw ? combined : na, "Raw Combined", color=color.new(color.gray, 50))

smaPlot = plot(smaCurve, "Combined SMA", color=#4FC3F7, linewidth=1)   // thin
emaPlot = plot(emaCurve, "Combined EMA", color=#4FC3F7, linewidth=3)   // thick

// Gap painted by EMA slope: green = rising, red = falling
fill(smaPlot, emaPlot, color = emaRising ? color.new(color.green, 70) : color.new(color.red, 70), title="EMA Slope Fill")
````
