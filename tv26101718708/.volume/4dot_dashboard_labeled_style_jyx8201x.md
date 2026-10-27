# 4-Dot Dashboard - Labeled Style

- url: https://www.tradingview.com/script/jYx8201x-4-Dot-Dashboard-Labeled-Style/
- type: indicator
- pine_id: PUB;2d4ae3ae40084bed9f67aa79ac68910f
- version: 2.0

## Description

This indicator provides a compact, multi-layered visual dashboard to monitor trend bias, price action structure, and momentum exhaustion/strength in real-time. By stacking four distinct logic layers, it allows traders to identify "confluence" at a glance without cluttering the main price chart.

The Four Layers
Row 1: BIAS (Trend Filter)Uses the Directional Movement Index (DMI). If [symbol="BMV:DI"]BMV:DI[/symbol]+ > DI-$, the dot reflects a bullish bias. If [symbol="BMV:DI"]BMV:DI[/symbol]- > DI+$, the dot reflects a bearish bias. This serves as your primary trend filter.
Row 2: HH/LL (Price Action)Tracks "Higher Highs" and "Lower Lows." A bullish dot appears when the current high/low is higher than the previous bar's high/low during a bullish bias. A bearish dot appears when price is making lower lows during a bearish bias.
Row 3: ADX (Trend Strength)Monitors the Average Directional Index. When ADX is above the user-defined threshold (default 20), it signals a strengthening trend.
Row 4: VOL (Volume Flow)Compares current volume against a moving average. This highlights bars where volume is expanding, confirming the participation behind the move.
Master Sync Logic
The dashboard features a "Color Sync" mechanism. When Row 1 (Bias) and Row 2 (Price Action) align, the indicator considers the trend "Synchronized." Rows 3 and 4 will then dynamically change color to match the trend if their specific conditions are met, signaling high-probability momentum.

## Source Code

````pine
//@version=5
indicator("4-Dot Dashboard - Dynamic Label Sync", overlay=false, precision=1, max_labels_count=50)

// --- INPUTS ---
tfInput      = input.timeframe("", "Indicator Timeframe") 
dotSize      = input.string("Tiny", "Dot Size", options=["Tiny", "Small", "Normal", "Large"])
gap          = input.float(0.5, "Vertical Spacing", minval=0.1, step=0.1)

adxLen       = input.int(14, "ADX Length")
adxThreshold = input.int(20, "Row 3: ADX Threshold")
volLen       = input.int(5, "Volume Avg Lookback")

// Color Pickers
c_bull  = input.color(color.blue,   "Bullish Sync Color")
c_bear  = input.color(color.red,    "Bearish Sync Color")
c3_def  = input.color(color.gray,   "Row 3: Default ADX Color")
c4_def  = input.color(color.yellow, "Row 4: Default Volume Color")

// --- LOGIC FUNCTION ---
f_logic() =>
    [diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
    _isBull = diPlus > diMinus
    _cond2_bull = _isBull and (high > high[1] and low > low[1])
    _cond2_bear = not _isBull and (low < low[1] and high < high[1])
    _syncBull = _isBull and _cond2_bull
    _syncBear = not _isBull and _cond2_bear
    _cond3 = adx > adxThreshold
    _cond4 = volume > ta.sma(volume[1], volLen)
    [_isBull, _cond2_bull, _cond2_bear, _cond3, _cond4, _syncBull, _syncBear]

// --- MTF SECURITY CALL ---
[isBullishBias, c2_bull, c2_bear, cond3, cond4, syncBull, syncBear] = request.security(syminfo.tickerid, tfInput, f_logic(), lookahead=barmerge.lookahead_on)

// Final Color Mapping
color1 = isBullishBias ? c_bull : c_bear
cond2  = c2_bull or c2_bear
color2 = c2_bull ? c_bull : c_bear
color3 = syncBull ? c_bull : syncBear ? c_bear : c3_def
color4 = syncBull ? c_bull : syncBear ? c_bear : c4_def

// Positioning
y1 = 1.0 * gap
y2 = 2.0 * gap
y3 = 3.0 * gap
y4 = 4.0 * gap

// Size Logic
isT = dotSize == "Tiny"
isS = dotSize == "Small"
isN = dotSize == "Normal"
isL = dotSize == "Large"

// --- THE PLOTS (Shared Titles to Clean the Menu) ---
// Row 1
plotshape(true and isT ? y1 : na, title="Row 1: BIAS", style=shape.circle, location=location.absolute, color=color1, size=size.tiny)
plotshape(true and isS ? y1 : na, title="Row 1: BIAS", style=shape.circle, location=location.absolute, color=color1, size=size.small)
plotshape(true and isN ? y1 : na, title="Row 1: BIAS", style=shape.circle, location=location.absolute, color=color1, size=size.normal)
plotshape(true and isL ? y1 : na, title="Row 1: BIAS", style=shape.circle, location=location.absolute, color=color1, size=size.large)

// Row 2
plotshape(cond2 and isT ? y2 : na, title="Row 2: HHLL", style=shape.circle, location=location.absolute, color=color2, size=size.tiny)
plotshape(cond2 and isS ? y2 : na, title="Row 2: HHLL", style=shape.circle, location=location.absolute, color=color2, size=size.small)
plotshape(cond2 and isN ? y2 : na, title="Row 2: HHLL", style=shape.circle, location=location.absolute, color=color2, size=size.normal)
plotshape(cond2 and isL ? y2 : na, title="Row 2: HHLL", style=shape.circle, location=location.absolute, color=color2, size=size.large)

// Row 3
plotshape(cond3 and isT ? y3 : na, title="Row 3: ADX", style=shape.circle, location=location.absolute, color=color3, size=size.tiny)
plotshape(cond3 and isS ? y3 : na, title="Row 3: ADX", style=shape.circle, location=location.absolute, color=color3, size=size.small)
plotshape(cond3 and isN ? y3 : na, title="Row 3: ADX", style=shape.circle, location=location.absolute, color=color3, size=size.normal)
plotshape(cond3 and isL ? y3 : na, title="Row 3: ADX", style=shape.circle, location=location.absolute, color=color3, size=size.large)

// Row 4
plotshape(cond4 and isT ? y4 : na, title="Row 4: VOL", style=shape.circle, location=location.absolute, color=color4, size=size.tiny)
plotshape(cond4 and isS ? y4 : na, title="Row 4: VOL", style=shape.circle, location=location.absolute, color=color4, size=size.small)
plotshape(cond4 and isN ? y4 : na, title="Row 4: VOL", style=shape.circle, location=location.absolute, color=color4, size=size.normal)
plotshape(cond4 and isL ? y4 : na, title="Row 4: VOL", style=shape.circle, location=location.absolute, color=color4, size=size.large)

// --- SYNCED LABELS ---
// We use a function to draw labels that only show if the user hasn't unchecked the row
f_drawLabel(_y, _txt, _color) =>
    var label lbl = label.new(bar_index, _y, _txt, color=color.new(color.black, 100), textcolor=_color, style=label.style_label_left, size=size.small)
    label.set_x(lbl, bar_index + 2)
    label.set_y(lbl, _y)
    label.set_textcolor(lbl, _color)
    label.set_text(lbl, _txt)

f_drawLabel(y1, "BIAS", color1)
f_drawLabel(y2, isBullishBias ? "HH" : "LL", color2)
f_drawLabel(y3, "ADX", color3)
f_drawLabel(y4, "VOL", color4)

// Tracks
hline(y1, color=color.new(color.gray, 90), title="Grid Lines")
hline(y2, color=color.new(color.gray, 90), title="Grid Lines")
hline(y3, color=color.new(color.gray, 90), title="Grid Lines")
hline(y4, color=color.new(color.gray, 90), title="Grid Lines")
````
