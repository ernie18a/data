# Dual-Phase Trend Regime Strategy [Zeiierman X PineIndicators]

- url: https://www.tradingview.com/script/iJKQeI6A-Dual-Phase-Trend-Regime-Strategy-Zeiierman-X-PineIndicators/
- type: strategy
- pine_id: PUB;0e7a155aebac42a0b62642c47817d2df
- version: 1.0

## Description

This strategy is based on the Dual-Phase Trend Regime Indicator by Zeiierman.

[b]Full credit for the original concept and logic goes to Zeiierman.[/b]

This non-repainting strategy dynamically switches between fast and slow oscillators based on market volatility, providing adaptive entries and exits with high clarity and reliability.

[b]Core Concepts[/b]
[b]1. Adaptive Dual Oscillator Logic[/b]
The system uses two oscillators:
[list]
[*] [b]Fast Oscillator:[/b] Activated in high-volatility phases for quick reaction.
[*] [b]Slow Oscillator:[/b] Used during low-volatility phases to reduce noise.
[/list]

The system automatically selects the appropriate oscillator depending on the market's volatility regime.

[b]2. Volatility Regime Detection[/b]
Volatility is calculated using the standard deviation of returns. A median-split algorithm clusters volatility into:
[list]
[*] [b]Low Volatility Cluster[/b]
[*] [b]High Volatility Cluster[/b]
[/list]
The current volatility is then compared to these clusters to determine whether the regime is low or high volatility.

[b]3. Trend Regime Identification[/b]
Based on the active oscillator:
[list]
[*] [b]Bullish Trend:[/b] Oscillator > 0.5
[*] [b]Bearish Trend:[/b] Oscillator < 0.5
[*] [b]Neutral Trend:[/b] Oscillator = 0.5
[/list]

The strategy reacts to changes in this trend regime.

[b]4. Signal Source Options[/b]
You can choose between:
[list]
[*] [b]Regime Shift (Arrows):[/b] Trade based on oscillator value changes (from bullish to bearish and vice versa).
[*] [b]Oscillator Cross:[/b] Trade based on crossovers between the fast and slow oscillators.
[/list]

[b]Trade Logic[/b]
[b]Trade Direction Options[/b]
[list]
[*] Long Only
[*] Short Only
[*] Long & Short
[/list]

[b]Entry Conditions[/b]
[list]
[*] [b]Long Entry:[/b] Triggered on bullish regime shift or fast crossing above slow.
[*] [b]Short Entry:[/b] Triggered on bearish regime shift or fast crossing below slow.
[/list]

[b]Exit Conditions[/b]
[list]
[*] [b]Long Exit:[/b] Triggered on bearish shift or fast crossing below slow.
[*] [b]Short Exit:[/b] Triggered on bullish shift or fast crossing above slow.
[/list]

The strategy closes opposing positions before opening new ones.

[b]Visual Features[/b]
[list]
[*] [b]Oscillator Bands:[/b] Plots fast and slow oscillators, colored by trend.
[*] [b]Background Highlight:[/b] Indicates current trend regime.
[*] [b]Signal Markers:[/b] Triangle shapes show bullish/bearish shifts.
[*] [b]Dashboard Table:[/b] Displays live trend status ("Bullish", "Bearish", "Neutral") in the chart’s corner.
[/list]

[b]Inputs & Customization[/b]
[list]
[*] [b]Oscillator Periods[/b] – Fast and slow lengths.
[*] [b]Refit Interval[/b] – How often volatility clusters update.
[*] [b]Volatility Lookback & Smoothing[/b]
[*] [b]Color Settings[/b] – Choose your own bullish/bearish colors.
[*] [b]Signal Mode[/b] – Regime shift or oscillator crossover.
[*] [b]Trade Direction Mode[/b]
[/list]

[b]Use Cases[/b]
[list]
[*] [b]Swing Trading:[/b] Take entries based on adaptive regime shifts.
[*] [b]Trend Following:[/b] Follow the active trend using filtered oscillator logic.
[*] [b]Volatility-Responsive Systems:[/b] Adjust your trade behavior depending on market volatility.
[*] [b]Clean Exit Management:[/b] Automatically closes positions on opposite signal.
[/list]

[b]Conclusion[/b]
The [b]Dual-Phase Trend Regime Strategy[/b] is a smart, adaptive, non-repainting system that:
[list]
[*] Automatically switches between fast and slow trend logic.
[*] Responds dynamically to changes in volatility.
[*] Provides clean and visual entry/exit signals.
[*] Supports both momentum and reversal trading logic.
[/list]

[b]This strategy is ideal for traders seeking a volatility-aware, trend-sensitive tool across any market or timeframe.[/b]
[b]Full credit to Zeiierman.[/b]

## Source Code

````pine
// © Zeiierman – CC BY-NC-SA 4.0
//@version=6
strategy("Dual-Phase Trend Regime Strategy [Zeiierman X PineIndicators]", overlay=true,
         default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// ═════════════════ Benutzereinstellungen ═════════════════
tradeDirection = input.string("Long & Short", "Trade Direction",
                              options = ["Long & Short","Long Only","Short Only"])
signalSource   = input.string("Regime Shift (Arrows)", "Signal Source",
                              options = ["Regime Shift (Arrows)","Oscillator Cross"])

// ───── Indikator-Parameter aus dem Original ─────
lengthSlow   = input.int(36, "Slow-Osc Length",  minval=2, group="Oscillator")
lengthFast   = input.int(18, "Fast-Osc Length",  minval=2, group="Oscillator")
refitBars    = input.int(50, "Volatility Refit Interval", minval=1, group="Vol-Detection")
volLookback  = input.int(20, "Current Volatility Period", minval=1, group="Vol-Detection")
volSmoothLen = input.int(5 , "Volatility Smoothing Length",minval=1, group="Smoothing")
bullColor    = input.color(color.rgb( 33,150,243,0), "Bullish Color", group="Style")
bearColor    = input.color(color.rgb(255, 82, 82 ,0), "Bearish Color", group="Style")

// ══════════════ Variable Deklarationen ══════════════
var array<float> volHist   = array.new<float>()
var int          lastRefit = na
var float        lowClust  = na
var float        highClust = na
var int          volRegime = na        // 0 / 1 / na
var int          trendReg  = na        // -1 / 0 / 1 / na

// ══════════════ Hilfsfunktionen ═════════════════════
// Preis-Zeit-Korrelation als 0…1-Oszillator
osc(src, len) =>
    r = ta.correlation(src, bar_index, len)
    not na(r) ? (r + 1) / 2 : na      // :contentReference[oaicite:1]{index=1}

// Median-Split für zwei Volatilitäts-Cluster
medianSplit(arr) =>
    n = array.size(arr)
    if n < 10
        [na, na]
    else
        med = array.median(arr)
        sLow = 0.0
        sHigh = 0.0
        kLow = 0
        kHigh = 0
        for i = 0 to n - 1
            v = array.get(arr, i)
            if not na(v)
                if v < med
                    sLow += v
                    kLow += 1
                else
                    sHigh += v
                    kHigh += 1
        [kLow > 0 ? sLow / kLow : na,
         kHigh > 0 ? sHigh / kHigh : na]

// ══════════════ Haupt­berechnungen ═══════════════════
// 1) Returns & Volatilität
ret      = close / close[1] - 1
vNow     = ta.stdev(ret, volLookback)
vNowSmth = ta.sma(vNow, volSmoothLen)

if not na(vNow)
    array.push(volHist, vNow)
if array.size(volHist) > 150
    array.shift(volHist)

// 2) Cluster-Refit
if barstate.isconfirmed and array.size(volHist) >= 150 and (na(lastRefit) or bar_index - lastRefit >= refitBars)
    [c1, c2] = medianSplit(volHist)
    if not na(c1) and not na(c2)
        lowClust  := na(lowClust)  ? c1 : lowClust  + 0.1 * (c1 - lowClust)
        highClust := na(highClust) ? c2 : highClust + 0.1 * (c2 - highClust)
        lastRefit := bar_index
    // Reihenfolge korrigieren
    if not na(lowClust) and not na(highClust) and lowClust > highClust
        tmp = lowClust
        lowClust  := highClust
        highClust := tmp

// 3) Volatilitäts-Regime (0 = low, 1 = high)
if not na(vNowSmth) and not na(lowClust) and not na(highClust)
    volRegime := vNowSmth < (lowClust + highClust) / 2 ? 0 : 1

// 4) Zwei Oszillatoren
oscSlow = osc(close, lengthSlow)
oscFast = osc(close, lengthFast)

// 5) Trend-Regime (Fallback = Fast, solange volRegime na)
useOsc  = not na(volRegime) ? (volRegime == 1 ? oscFast : oscSlow) : oscFast
trendReg := na(useOsc) ? na : useOsc > 0.5 ? 1 : useOsc < 0.5 ? -1 : 0

bullShift = not na(trendReg) and trendReg == 1  and (na(trendReg[1]) or trendReg[1] != 1)
bearShift = not na(trendReg) and trendReg == -1 and (na(trendReg[1]) or trendReg[1] != -1)

// 6) Signale
longE  = signalSource == "Regime Shift (Arrows)" ? bullShift  : ta.crossover(oscFast, oscSlow)
shortE = signalSource == "Regime Shift (Arrows)" ? bearShift  : ta.crossunder(oscFast, oscSlow)
longX  = signalSource == "Regime Shift (Arrows)" ? bearShift  : ta.crossunder(oscFast, oscSlow)
shortX = signalSource == "Regime Shift (Arrows)" ? bullShift  : ta.crossover(oscFast, oscSlow)

// 7) Orders – zuerst schliessen, dann eröffnen
if longE  and tradeDirection != "Short Only"
    strategy.close("Short")
    strategy.entry("Long", strategy.long)

if shortE and tradeDirection != "Long Only"
    strategy.close("Long")
    strategy.entry("Short", strategy.short)

if strategy.position_size > 0 and longX
    strategy.close("Long")
if strategy.position_size < 0 and shortX
    strategy.close("Short")

// ══════════════ Plots & Visuals ════════════════════════
hline(0.5, "Mid", color=color.gray, linestyle=hline.style_dashed)
pSlow = plot(oscSlow, "Slow Osc", color = oscSlow >= 0.5 ? bullColor : bearColor)
pFast = plot(oscFast, "Fast Osc", color = oscFast >= 0.5 ? bullColor : bearColor)
fill(pSlow, pFast, color = oscSlow >= 0.5 ? color.new(bullColor, 80) : color.new(bearColor, 80))

pTop = plot( 1.2, display = display.none)
pBot = plot(-0.2, display = display.none)
bg   = not na(trendReg) ? (trendReg == 1 ? color.new(bullColor, 90) : color.new(bearColor, 90)) : na
fill(pTop, pBot, color = bg)

plotshape(bullShift ? 1.2 : na, "Bull Shift", location = location.absolute,
          color = color.new(bullColor, 0), style=shape.triangleup,   size=size.tiny)
plotshape(bearShift ? -0.2 : na, "Bear Shift", location = location.absolute,
          color = color.new(bearColor, 0), style=shape.triangledown, size=size.tiny)

var table info = table.new(position.top_right, 1, 1, bgcolor=color.new(color.gray, 85))
if barstate.islast
    lbl = "Calculating..."
    bkg = color.new(color.gray, 20)
    if not na(trendReg)
        lbl := trendReg == 1 ? "Bullish" : trendReg == -1 ? "Bearish" : "Neutral"
        bkg := trendReg == 1 ? color.new(bullColor, 20) : trendReg == -1 ? color.new(bearColor, 20) : color.new(color.gray, 20)
    table.cell(info, 0, 0, lbl, bgcolor = bkg, text_color = color.white, text_size = size.small)
````
