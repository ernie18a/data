# Clean Chart ALMA/RSI/ADX - FiBuy Edition

- url: https://www.tradingview.com/script/y4ZxnNKP-Clean-Chart-ALMA-RSI-ADX-FiBuy-Edition/
- type: indicator
- pine_id: PUB;d055b73901074d73ab288185b715291c
- version: 1.0

## Description

Buy-Sell signals are based on Fibonacci; please ensure the momentum and trend are favorable before entering a trade using this indicator.

## Source Code

````pine
//@version=6
indicator("Clean Chart ALMA/RSI/ADX - FiBuy Edition", overlay=true)

// --- INPUTS ---
int alma9_len    = input.int(9, "ALMA 9 Length")
int alma14_len   = input.int(14, "ALMA 14 Length")
int alma21_len   = input.int(21, "ALMA 21 Length")
float alma_sigma = input.float(6.0, "ALMA Sigma")
float alma_offset = input.float(0.85, "ALMA Offset")

int rsi_len      = input.int(14, "RSI Length")
int adx_len      = input.int(14, "ADX Length")
int chop_len     = input.int(14, "Choppiness Length")

// Fibonacci Inputs
int fib_lookback = input.int(60, "Standard Lookback Period")
bool use_session_reset = input.bool(true, "Reset Lookback at Session Open (09:15)")
color fib_color = input.color(color.new(color.gray, 50), "Fib Line Color")

// --- SESSION LOGIC (Indian Market 09:15) ---
is_new_day = ta.change(time("D")) != 0
var int bars_since_open = 0
if is_new_day
    bars_since_open := 0
else
    bars_since_open += 1

// Determine actual lookback to use
int active_lookback = use_session_reset ? math.min(bars_since_open, fib_lookback) : fib_lookback

// --- CALCULATIONS ---
float alma9  = ta.alma(close, alma9_len, alma_offset, alma_sigma)
float alma14 = ta.alma(close, alma14_len, alma_offset, alma_sigma)
float alma21 = ta.alma(close, alma21_len, alma_offset, alma_sigma)

// --- REFINED TREND LOGIC ---
// Bullish Stack: 9 > 14 > 21
bool trendUp   = alma9 > alma14 and alma14 > alma21

// Bearish Stack: 9 < 14 < 21
bool trendDown = alma9 < alma14 and alma14 < alma21

// --- SIGNAL ENGINE ---
// ALMA Buy: Crossover of 9/14 ONLY when the stack is already bullish
bool almaBuy  = ta.crossover(alma9, alma14) and trendUp

// ALMA Sell: Crossunder of 14/21 ONLY when the stack is already bearish
bool almaSell = ta.crossunder(alma14, alma21) and trendDown

// --- PLOTTING ---
// Standard ALMA BUY
plotshape(almaBuy, 
     style=shape.labelup, location=location.belowbar, color=color.green, 
     text="BUY", textcolor=color.white, size=size.small)

// Standard ALMA SELL
plotshape(almaSell, 
     style=shape.labeldown, location=location.abovebar, color=color.red, 
     text="SELL", textcolor=color.white, size=size.small)

float rsiVal = ta.rsi(close, rsi_len)
[diplus, diminus, adxVal] = ta.dmi(adx_len, adx_len)
float ci = 100 * math.log10(math.sum(ta.atr(1), chop_len) / (ta.highest(high, chop_len) - ta.lowest(low, chop_len))) / math.log10(chop_len)

// --- FIBONACCI ENGINE ---
float highestHigh = ta.highest(high, math.max(1, active_lookback))
float lowestLow   = ta.lowest(low, math.max(1, active_lookback))
float fibRange    = highestHigh - lowestLow

// Standard Fib Levels
float fib0   = highestHigh
float fib50  = highestHigh - (fibRange * 0.50)
float fib618 = highestHigh - (fibRange * 0.618)
float fib100 = lowestLow

// Plotting Fib Levels (Optional visual reference)
var line l50 = line.new(na, na, na, na, color=fib_color, style=line.style_dashed)
var line l618 = line.new(na, na, na, na, color=fib_color, style=line.style_dashed)

if barstate.islast
    line.set_xy1(l50, bar_index[active_lookback], fib50)
    line.set_xy2(l50, bar_index, fib50)
    line.set_xy1(l618, bar_index[active_lookback], fib618)
    line.set_xy2(l618, bar_index, fib618)

// --- SIGNAL ENGINE ---

// FiBuy Condition: ALMA Buy + Price in Golden Pocket (50% - 61.8%)
bool inGoldenPocket = close >= fib618 and close <= fib50
bool fiBuy = almaBuy and inGoldenPocket

// Plotting Signals
plotshape(fiBuy ? bool(na) : almaBuy,  style=shape.labelup,   location=location.belowbar, color=color.green, text="BUY",   textcolor=color.white, size=size.small)
plotshape(fiBuy ? true : bool(na),     style=shape.labelup,   location=location.belowbar, color=color.aqua,  text="FiBuy", textcolor=color.black, size=size.small)
plotshape(almaSell,                    style=shape.labeldown, location=location.abovebar, color=color.red,    text="SELL",  textcolor=color.white, size=size.small)

// --- MOMENTUM TRACKER (RSI Stacked Dots) ---
float atrVal   = ta.atr(14)
float baseLine = low - (atrVal * 0.4)
float space    = atrVal * 0.25

plot(rsiVal > 50 ? baseLine : na, "RSI > 50", color.blue, 3, plot.style_circles)
plot(rsiVal > 60 ? baseLine - space : na, "RSI > 60", color.green, 3, plot.style_circles)
plot(rsiVal > 70 ? baseLine - (space * 2) : na, "RSI > 70", color.aqua, 3, plot.style_circles)
plot(rsiVal > 75 ? baseLine - (space * 3) : na, "RSI > 75", color.fuchsia, 3, plot.style_circles)

// --- POWER & SAFETY ---
bool adxTrending = adxVal > 25
plotshape(adxTrending, style=shape.diamond, location=location.abovebar, color=color.yellow, size=size.tiny)
bgcolor(ci > 60 ? color.new(color.gray, 85) : na)
````
