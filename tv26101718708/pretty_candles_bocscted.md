# Pretty Candles

- url: https://www.tradingview.com/script/BOCsCtEd-Pretty-Candles/
- type: indicator
- pine_id: PUB;7c235cfe46574a98a007ece208aca2d2
- version: 2.0

## Description

Here's a clean TradingView publish description — copy/paste ready:

---

## ✨ Pretty Candles — Clean, Themed Candlestick Redesign

A standalone cosmetic indicator that replaces TradingView's default candles with a professional, customizable design inspired by modern trading platforms. Pure visual enhancement — **no signals, no alerts, no logic** — just better candles to look at while you trade.

---

### 🎨 5 Built-in Themes

Switch with a single click in the indicator settings:

- **Modern** — refined Tailwind-inspired green/red palette (default)
- **Soft** — pastel tones, easy on the eyes during long sessions
- **Neon** — high-contrast green/pink, perfect for dark-mode charts
- **Mono** — Bloomberg Terminal aesthetic, white bull / dark bear
- **Custom** — pick your own bull, bear, border, and wick colors

### 🔥 Smart Visual Effects

**Momentum Brightness** — strong candles appear vibrant and saturated, sideways/weak candles fade out. Lets you see at a glance where real action is happening on the chart.

**Big Bar Emphasis** — when a candle's body is significantly larger than the recent average, it automatically gets a bold border and dot marker. Surfaces breakout candles instantly.

**High/Low Markers** — automatic triangle markers and labels when price prints a new local high or low (50-bar lookback, fully adjustable).

**Background Trend Tint** — very subtle ambient gradient (96% transparent by default) shifts between green and red based on the EMA20 vs EMA50 trend relationship.

**Hollow Mode** — toggle bull and bear candles to outline-only for a minimalist Bloomberg-style look.

**EMA20 Trend Anchor** — thin reference line gives you a quick trend bias without cluttering the chart.

### ⚙️ Fully Customizable

Every visual element can be toggled or fine-tuned:
- Wick brightness
- Background gradient opacity
- High/Low lookback period
- Big-bar size multiplier threshold
- Independent on/off switches for each feature

### 📋 Setup (Important!)

To see the Pretty Candles properly, hide TradingView's default candles first:

1. Right-click the chart → **Settings** → **Symbol** tab
2. Set **Body**, **Borders**, and **Wick** to transparent (top-right of color picker)
3. Apply

Now Pretty Candles takes over as your visual layer.

### 💡 Use Cases

- Pair with your existing strategy/indicator for cleaner visuals
- Long trading sessions where eye fatigue is real
- Backtesting and chart analysis where readability matters
- Streamers and educators who want professional-looking charts
- Anyone tired of TradingView's default colors

### ✅ What This Indicator Does NOT Do

- Generate buy/sell signals
- Send alerts
- Repaint or affect price action
- Add overhead to your strategy backtests

It's purely a visual replacement. Use it alongside any other indicator without conflict.

---

**Categories:** Chart Patterns · Visualization · Tools  
**Tags:** candles, theme, cosmetic, visualization, clean, modern, design, professional, ui

---

**Disclaimer:** This indicator is for visualization purposes only. It does not generate trading signals or provide trading advice. Past performance is not indicative of future results.

## Source Code

````pine
//@version=5
indicator("Pretty Candles", shorttitle="✨ Candles", overlay=true, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════
//  Standalone cosmetic candle redesign — v2 with 12 themes
//  Add on any chart. Hide native candles first:
//  Right-click chart → Settings → Symbol →
//  Body / Borders / Wick → all transparent
// ═══════════════════════════════════════════════════════════════

// ─── CANDLE THEME ─────────────────────────────────────────
theme = input.string("Modern", "Candle theme", group="Theme",
     options=["Modern", "Soft", "Neon", "Mono", "Sunset",
              "Ocean", "Forest", "Royal", "Lavender", "Cyber",
              "Coffee", "Glacier", "Custom"])

// Custom colors (only used when theme = "Custom")
customBull       = input.color(#16A34A, "Custom bull body",   group="Custom theme")
customBear       = input.color(#DC2626, "Custom bear body",   group="Custom theme")
customBullBorder = input.color(#15803D, "Custom bull border", group="Custom theme")
customBearBorder = input.color(#B91C1C, "Custom bear border", group="Custom theme")
customWick       = input.color(#475569, "Custom wick",        group="Custom theme")

// Theme color resolution
bullBody = theme == "Modern" ? #22C55E : theme == "Soft" ? #86EFAC : theme == "Neon" ? #00FF88 : theme == "Mono" ? #F8FAFC : theme == "Sunset" ? #FB923C : theme == "Ocean" ? #06B6D4 : theme == "Forest" ? #65A30D : theme == "Royal" ? #A78BFA : theme == "Lavender" ? #DDD6FE : theme == "Cyber" ? #00F5FF : theme == "Coffee" ? #D4A574 : theme == "Glacier" ? #7DD3FC : customBull

bearBody = theme == "Modern" ? #EF4444 : theme == "Soft" ? #FCA5A5 : theme == "Neon" ? #FF0066 : theme == "Mono" ? #1E293B : theme == "Sunset" ? #BE185D : theme == "Ocean" ? #1E3A8A : theme == "Forest" ? #92400E : theme == "Royal" ? #1E1B4B : theme == "Lavender" ? #6D28D9 : theme == "Cyber" ? #FF00AA : theme == "Coffee" ? #4A2C2A : theme == "Glacier" ? #0369A1 : customBear

bullBorder = theme == "Modern" ? #16A34A : theme == "Soft" ? #22C55E : theme == "Neon" ? #00FF88 : theme == "Mono" ? #CBD5E1 : theme == "Sunset" ? #EA580C : theme == "Ocean" ? #0891B2 : theme == "Forest" ? #4D7C0F : theme == "Royal" ? #7C3AED : theme == "Lavender" ? #A78BFA : theme == "Cyber" ? #00C2D1 : theme == "Coffee" ? #92400E : theme == "Glacier" ? #0284C7 : customBullBorder

bearBorder = theme == "Modern" ? #DC2626 : theme == "Soft" ? #EF4444 : theme == "Neon" ? #FF0066 : theme == "Mono" ? #0F172A : theme == "Sunset" ? #9F1239 : theme == "Ocean" ? #1E40AF : theme == "Forest" ? #78350F : theme == "Royal" ? #312E81 : theme == "Lavender" ? #5B21B6 : theme == "Cyber" ? #DB2777 : theme == "Coffee" ? #292524 : theme == "Glacier" ? #075985 : customBearBorder

wickColor = theme == "Modern" ? #475569 : theme == "Soft" ? #94A3B8 : theme == "Neon" ? #94A3B8 : theme == "Mono" ? #64748B : theme == "Sunset" ? #78716C : theme == "Ocean" ? #475569 : theme == "Forest" ? #57534E : theme == "Royal" ? #6B7280 : theme == "Lavender" ? #9CA3AF : theme == "Cyber" ? #64748B : theme == "Coffee" ? #57534E : theme == "Glacier" ? #64748B : customWick


// ─── BACKGROUND SETTINGS ──────────────────────────────────
bgStyle = input.string("Auto", "Background style", group="Background",
     options=["None", "Auto", "Solid", "Trend tint",
              "Gradient up", "Gradient down", "Vignette", "Custom solid"])

bgTrendOpacity = input.int(96, "Trend tint transparency", minval=85, maxval=99, step=1, group="Background")
customBgColor = input.color(color.new(#0F172A, 90), "Custom bg color", group="Background")

// Auto background that matches each theme
autoBg = theme == "Modern" ? color.new(#0F172A, 88) : theme == "Soft" ? color.new(#FAFAF9, 60) : theme == "Neon" ? color.new(#000000, 50) : theme == "Mono" ? color.new(#475569, 88) : theme == "Sunset" ? color.new(#451A03, 88) : theme == "Ocean" ? color.new(#082F49, 90) : theme == "Forest" ? color.new(#1A2E05, 88) : theme == "Royal" ? color.new(#1E1B4B, 90) : theme == "Lavender" ? color.new(#F5F3FF, 50) : theme == "Cyber" ? color.new(#020617, 60) : theme == "Coffee" ? color.new(#1C1917, 88) : theme == "Glacier" ? color.new(#0C4A6E, 92) : color.new(#0F172A, 88)


// ─── CANDLE STYLE ─────────────────────────────────────────
showWicks       = input.bool(true,  "Show wicks",                    group="Candles")
hollowBull      = input.bool(false, "Hollow bull",                    group="Candles")
hollowBear      = input.bool(false, "Hollow bear",                    group="Candles")
wickOpacity     = input.int(70,     "Wick brightness %", minval=20, maxval=100, step=10, group="Candles")

// ─── HIGH/LOW MARKERS ─────────────────────────────────────
showHL          = input.bool(true,  "Mark recent High/Low",          group="Levels")
hlLookback      = input.int(50,     "Lookback bars", minval=10, maxval=500, group="Levels")
showHLLabels    = input.bool(true,  "Show H/L labels",               group="Levels")

// ─── MOMENTUM HEATMAP ─────────────────────────────────────
showMomentum    = input.bool(true,  "Momentum-based brightness",     group="Momentum")
momentumLen     = input.int(14,     "Momentum lookback", minval=5,   group="Momentum")

// ─── BAR SIZE EMPHASIS ────────────────────────────────────
emphasizeBigBars = input.bool(true, "Emphasize big bars",            group="Emphasis")
bigBarMultiplier = input.float(1.8, "Multiplier vs avg",             step=0.1, group="Emphasis")

// ─── TREND ANCHOR ─────────────────────────────────────────
showEma         = input.bool(true,  "Show trend anchor (EMA20)",     group="Trend")


// ═══════════════════════════════════════════════════════════
//                        LOGIC
// ═══════════════════════════════════════════════════════════

isBull    = close >= open
bodySize  = math.abs(close - open)
avgBody   = ta.sma(bodySize, 20)
isBigBar  = emphasizeBigBars and bodySize > avgBody * bigBarMultiplier

priceMomentum = math.abs(ta.change(close, momentumLen))
avgMomentum   = ta.sma(math.abs(ta.change(close, momentumLen)), 50)
momentumRatio = avgMomentum > 0 ? priceMomentum / avgMomentum : 1.0
momentumOpacity = showMomentum ? math.max(0, math.min(60, int(40 - (momentumRatio * 20)))) : 0

bullBodyFinal = hollowBull ? color.new(bullBody, 100) : color.new(bullBody, momentumOpacity)
bearBodyFinal = hollowBear ? color.new(bearBody, 100) : color.new(bearBody, momentumOpacity)
bullBorderFinal = isBigBar ? bullBorder : color.new(bullBorder, 0)
bearBorderFinal = isBigBar ? bearBorder : color.new(bearBorder, 0)
bodyColor   = isBull ? bullBodyFinal   : bearBodyFinal
borderColor = isBull ? bullBorderFinal : bearBorderFinal
wickCol     = showWicks ? color.new(wickColor, 100 - wickOpacity) : color.new(color.white, 100)


// ─── CANDLES ──────────────────────────────────────────────
plotcandle(open, high, low, close,
     title="Pretty Candle",
     color=bodyColor,
     bordercolor=borderColor,
     wickcolor=wickCol,
     display=display.all)


// ─── BACKGROUND ───────────────────────────────────────────
// Auto / Solid / Custom solid → flat
solidBg = (bgStyle == "Auto"         ? autoBg
         : bgStyle == "Solid"        ? color.new(bullBody, 95)
         : bgStyle == "Custom solid" ? customBgColor
         : na)
bgcolor(solidBg, title="Solid bg")

// Trend tint → green/red based on EMA
trendUp = ta.ema(close, 20) > ta.ema(close, 50)
trendTint = bgStyle == "Trend tint" ? (trendUp ? color.new(bullBody, bgTrendOpacity) : color.new(bearBody, bgTrendOpacity)) : na
bgcolor(trendTint, title="Trend tint bg")

// Gradient effects — position-based opacity
priceHigh  = ta.highest(high, 100)
priceLow   = ta.lowest(low, 100)
priceRange = priceHigh - priceLow
posRatio   = priceRange > 0 ? (close - priceLow) / priceRange : 0.5

gradUp   = bgStyle == "Gradient up"   ? color.new(bullBody, int(95 + posRatio * 4)) : na
gradDown = bgStyle == "Gradient down" ? color.new(bearBody, int(99 - posRatio * 4)) : na
vignette = bgStyle == "Vignette"      ? color.new(wickColor, int(90 + math.abs(posRatio - 0.5) * 18)) : na

bgcolor(gradUp,   title="Gradient up bg")
bgcolor(gradDown, title="Gradient down bg")
bgcolor(vignette, title="Vignette bg")


// ─── HIGH / LOW MARKERS ───────────────────────────────────
recentHigh = ta.highest(high, hlLookback)
recentLow  = ta.lowest(low,  hlLookback)
isNewHigh  = showHL and high >= recentHigh and high >= recentHigh[1]
isNewLow   = showHL and low  <= recentLow  and low  <= recentLow[1]

plotshape(isNewHigh, title="New High", style=shape.triangledown,
     location=location.abovebar, size=size.tiny, color=color.new(#0EA5E9, 0))
plotshape(isNewLow,  title="New Low",  style=shape.triangleup,
     location=location.belowbar, size=size.tiny, color=color.new(#F59E0B, 0))

if showHLLabels and isNewHigh
    label.new(bar_index, high, text="H " + str.tostring(high, "#.####"),
         color=color.new(#0EA5E9, 80), textcolor=#0369A1, size=size.tiny,
         style=label.style_label_down, yloc=yloc.abovebar)
if showHLLabels and isNewLow
    label.new(bar_index, low, text="L " + str.tostring(low, "#.####"),
         color=color.new(#F59E0B, 80), textcolor=#92400E, size=size.tiny,
         style=label.style_label_up, yloc=yloc.belowbar)


// ─── BIG BAR DOTS ─────────────────────────────────────────
plotshape(isBigBar and isBull,    title="Big bull bar",
     style=shape.circle, location=location.belowbar, size=size.tiny,
     color=color.new(bullBorder, 30))
plotshape(isBigBar and not isBull, title="Big bear bar",
     style=shape.circle, location=location.abovebar, size=size.tiny,
     color=color.new(bearBorder, 30))


// ─── TREND ANCHOR ─────────────────────────────────────────
ema20 = ta.ema(close, 20)
plot(showEma ? ema20 : na, "Trend anchor (EMA20)",
     color=color.new(wickColor, 40), linewidth=1)
````
