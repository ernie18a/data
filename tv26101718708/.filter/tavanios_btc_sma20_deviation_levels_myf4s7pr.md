# tavanios BTC SMA20 Deviation Levels

- url: https://www.tradingview.com/script/myF4s7pR-tavanios-BTC-SMA20-Deviation-Levels/
- type: indicator
- pine_id: PUB;36d7b8640fdc4cab907d4165bd0696a8
- version: 1.0

## Description

by tavanios BTC Monthly SMA20 Deviation Levels

This indicator tracks Bitcoin's deviation from its 20-month Simple Moving Average (SMA20) and plots key historical accumulation zones based on previous bear market drawdowns.

The script automatically calculates the monthly SMA20 and displays three major deviation levels:

• -40% below SMA20
• -50% below SMA20
• -60% below SMA20

These levels have historically acted as areas where Bitcoin approached long-term cycle bottoms during deep market corrections.

Features:

Automatic calculation of Bitcoin's 20-month SMA.
Visual plotting of -40%, -50%, and -60% deviation levels.
Background color zones highlighting periods of extreme undervaluation.
Real-time table displaying the current deviation percentage, SMA20 value, and corresponding accumulation levels.
Designed for long-term investors and cycle analysis.

This indicator is intended for educational and market analysis purposes only and should not be considered financial advice.

## Source Code

````pine
//@version=6
indicator('BTC SMA20 Deviation Levels', overlay = true)

// === MONTHLY SMA20 ===
m_sma20 = request.security('BTCUSD', 'M', ta.sma(close, 20))
m_close = request.security('BTCUSD', 'M', close)
dev = (m_close - m_sma20) / m_sma20 * 100

// === ΕΠΙΠΕΔΑ ΑΠΟΚΛΙΣΗΣ ===
level_40 = m_sma20 * 0.60 // -40%
level_50 = m_sma20 * 0.50 // -50%
level_60 = m_sma20 * 0.40 // -60%

// === ΓΡΑΜΜΕΣ ===
plot(level_40, title = '-40% SMA20', color = color.new(color.orange, 20), linewidth = 1, style = plot.style_linebr)
plot(level_50, title = '-50% SMA20', color = color.new(color.red, 20), linewidth = 2, style = plot.style_linebr)
plot(level_60, title = '-60% SMA20', color = color.new(color.maroon, 0), linewidth = 2, style = plot.style_linebr)

// === BACKGROUND ===
bg = dev < -60 ? color.new(color.maroon, 70) : dev < -50 ? color.new(color.red, 75) : dev < -40 ? color.new(color.orange, 80) : na
bgcolor(bg)

// === ΠΙΝΑΚΑΣ ===
var table t = table.new(position.bottom_right, 2, 5, bgcolor = color.new(color.black, 75), border_width = 1, border_color = color.new(color.gray, 60))

if barstate.islast
    table.cell(t, 0, 0, 'Dev % τώρα', text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 0, str.tostring(dev, '#.#') + '%', text_color = dev < -60 ? color.maroon : dev < -50 ? color.red : dev < -40 ? color.orange : color.white, text_size = size.small)

    table.cell(t, 0, 1, '— -40% level', text_color = color.orange, text_size = size.small)
    table.cell(t, 1, 1, '$' + str.tostring(level_40, '#'), text_color = color.orange, text_size = size.small)

    table.cell(t, 0, 2, '— -50% level', text_color = color.red, text_size = size.small)
    table.cell(t, 1, 2, '$' + str.tostring(level_50, '#'), text_color = color.red, text_size = size.small)

    table.cell(t, 0, 3, '— -60% level', text_color = color.maroon, text_size = size.small)
    table.cell(t, 1, 3, '$' + str.tostring(level_60, '#'), text_color = color.maroon, text_size = size.small)

    table.cell(t, 0, 4, 'SMA20 ref', text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 4, '$' + str.tostring(m_sma20, '#'), text_color = color.gray, text_size = size.small)
````
