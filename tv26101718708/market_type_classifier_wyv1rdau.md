# Market Type Classifier

- url: https://www.tradingview.com/script/wyv1Rdau-Market-Type-Classifier/
- type: indicator
- pine_id: PUB;ae60f2f9ee2b4b3388614b6a1f11e337
- version: 1.0

## Description

Market Type based on Bolinger Band and candlesticks/bar characteristic


1. Sideway
2. Bull
3. Bear

## Source Code

````pine
//@version=5
indicator("Market Type Classifier Final", overlay=true)

// --- 1. Input & Bollinger Bands ---
length = input.int(20, minval=1, title="BB Length")
mult   = input.float(2.0, minval=0.001, title="BB StdDev")
src    = input(close, title="Source")

[basis, upper, lower] = ta.bb(src, length, mult)

// --- 2. Metrik Pengiraan ---
bb_width     = upper - lower
bb_width_sma = ta.sma(bb_width, 20)
slope_basis  = basis - basis[1]
range_size   = high - low
avg_range    = ta.sma(range_size, 20)

// Threshold Trend
sideway_limit = ta.atr(14) * 0.1
is_sideway    = math.abs(slope_basis) < sideway_limit
is_bull       = slope_basis >= sideway_limit
is_bear       = slope_basis <= -sideway_limit

// Variable Output
var string m_type = "Scanning"
var color  m_color = color.new(color.gray, 80)

// --- 3. Logik Klasifikasi ---

if is_sideway
    if bb_width > bb_width_sma and range_size < avg_range
        m_type := "Sideway: Quiet", m_color := color.new(color.blue, 80)
    else if bb_width > bb_width_sma and range_size > avg_range
        m_type := "Sideway: Volatile", m_color := color.new(color.purple, 80)
    else
        m_type := "Sideway: Normal", m_color := color.new(color.gray, 80)

else if is_bull
    if bb_width < bb_width_sma and range_size < avg_range and close > basis
        m_type := "Bull: Quiet", m_color := color.new(color.green, 85)
    else if bb_width > bb_width_sma and range_size > avg_range
        m_type := "Bull: Volatile", m_color := color.new(color.orange, 70)
    else if bb_width > bb_width_sma and close > upper
        m_type := "Bull: Strong", m_color := color.new(color.green, 40)
    else if high >= upper
        m_type := "Bull: Fast", m_color := color.new(color.green, 60)
    else
        m_type := "Bull: Normal", m_color := color.new(color.green, 80)

else if is_bear
    if bb_width < bb_width_sma and range_size < avg_range and close < basis
        m_type := "Bear: Quiet", m_color := color.new(color.red, 85)
    else if bb_width > bb_width_sma and range_size > avg_range
        m_type := "Bear: Volatile", m_color := color.new(color.maroon, 70)
    else if bb_width > bb_width_sma and close < lower
        m_type := "Bear: Strong", m_color := color.new(color.red, 40)
    else if low <= lower
        m_type := "Bear: Fast", m_color := color.new(color.red, 60)
    else
        m_type := "Bear: Normal", m_color := color.new(color.red, 80)

// --- 4. Visual Output ---

// Background
bgcolor(m_color, title="Market Type Background")

// BB Plot
plot(basis, color=color.new(color.gray, 50), title="Mid BB")
p1 = plot(upper, color=color.new(color.teal, 50), title="Upper BB")
p2 = plot(lower, color=color.new(color.teal, 50), title="Lower BB")
fill(p1, p2, color=color.new(color.teal, 96), title="BB Fill")

// Label di hujung harga
if barstate.islast
    label.new(bar_index, high, "Type: " + m_type, color=m_color, style=label.style_label_down, textcolor=color.black)
````
