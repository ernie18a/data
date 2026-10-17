# ORB Sessions - London / New York / Asia Zyntra

- url: https://www.tradingview.com/script/9M9NwqsX-ORB-Sessions-London-New-York-Asia-Zyntra/
- type: indicator
- pine_id: PUB;4944101cf1074449a021581c3be0e3e0
- version: 1.0

## Description

ORB Sessions – London / New York / Asia
This indicator automatically marks the Opening Range of the three major trading sessions — London, New York, and Asia (Tokyo) — directly on your chart.
For each session, it draws two clean horizontal lines at the High and Low of the first 15-minute candle. These levels act as key zones to watch for breakouts, rejections, and liquidity sweeps throughout the trading day.
Sessions included:

🔵 London Open — 09:00 CET
🔴 New York Open — 15:30 CET
🟢 Asia / Tokyo Open — 01:00 CET (Winter) / 02:00 CET (Summer)

Features:

Automatic daylight saving time adjustment for the Asia session — no manual changes needed throughout the year
Adjustable line length, color, and thickness for each session individually
Clean label display showing High and Low of each range
Works on the 15-minute chart

How to use:
Switch to the 15-minute chart and add the indicator. The ORB levels of each session will appear automatically. Use the High and Low as potential breakout or reversal zones for your entries.

Disclaimer:
This indicator is for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any asset. Trading involves significant risk and you may lose more than your initial investment. Past performance is not indicative of future results. Always do your own research and consult a licensed financial advisor before making any trading decisions. Use this tool at your own risk.

## Source Code

````pine
//@version=5
indicator("ORB Sessions - London / New York / Asia", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
// EINSTELLUNGEN
// ============================================================
grp_london = "London Open 09:00"
grp_ny     = "New York Open 15:30"
grp_asia   = "Asia Open Tokyo"

show_london = input.bool(true, "London anzeigen", group=grp_london)
lon_color   = input.color(#2962FF, "Farbe", group=grp_london)
lon_width   = input.int(2, "Linienstaerke", minval=1, maxval=4, group=grp_london)

show_ny     = input.bool(true, "New York anzeigen", group=grp_ny)
ny_color    = input.color(#F7525F, "Farbe", group=grp_ny)
ny_width    = input.int(2, "Linienstaerke", minval=1, maxval=4, group=grp_ny)

show_asia   = input.bool(true, "Asia anzeigen", group=grp_asia)
asia_color  = input.color(#00897B, "Farbe", group=grp_asia)
asia_width  = input.int(2, "Linienstaerke", minval=1, maxval=4, group=grp_asia)

line_bars   = input.int(10, "Linienlaenge (Anzahl Kerzen)", minval=2, maxval=100)
show_labels = input.bool(true, "Labels anzeigen")

// ============================================================
// ZEITZONE
// ============================================================
TZ = "Europe/Berlin"

// ============================================================
// FUNKTIONEN
// ============================================================

f_hour()   => hour(time, TZ)
f_minute() => minute(time, TZ)

f_is_summer() =>
    int bh = hour(time, "Europe/Berlin")
    int uh = hour(time, "UTC")
    (bh - uh + 24) % 24 == 2

f_asia_hour() =>
    f_is_summer() ? 2 : 1

f_is_orb(h, m) =>
    f_hour() == h and f_minute() == m and timeframe.in_seconds() == 900

// Linien nur ueber X Kerzen (kein extend)
f_lines(hi, lo, idx, col, lw, lbl) =>
    int end_bar = idx + line_bars
    line.new(idx, hi, end_bar, hi, color=col, width=lw, extend=extend.none, style=line.style_solid)
    line.new(idx, lo, end_bar, lo, color=col, width=lw, extend=extend.none, style=line.style_solid)
    if show_labels
        label.new(idx, hi,
             text = lbl + " H",
             style = label.style_label_right,
             color = color.new(col, 70),
             textcolor = color.white,
             size = size.small)
        label.new(idx, lo,
             text = lbl + " L",
             style = label.style_label_right,
             color = color.new(col, 70),
             textcolor = color.white,
             size = size.small)

// ============================================================
// CHART PRUEFUNG
// ============================================================
if timeframe.in_seconds() != 900
    runtime.error("Bitte 15-Minuten Chart verwenden!")

// ============================================================
// LONDON 09:00
// ============================================================
if show_london and f_is_orb(9, 0)
    f_lines(high, low, bar_index, lon_color, lon_width, "London")

// ============================================================
// NEW YORK 15:30
// ============================================================
if show_ny and f_is_orb(15, 30)
    f_lines(high, low, bar_index, ny_color, ny_width, "NY")

// ============================================================
// ASIA TOKYO
// ============================================================
if show_asia and f_is_orb(f_asia_hour(), 0)
    lbl = f_is_summer() ? "Asia 02:00" : "Asia 01:00"
    f_lines(high, low, bar_index, asia_color, asia_width, lbl)
````
