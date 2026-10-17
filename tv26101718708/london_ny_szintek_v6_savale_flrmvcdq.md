# London & NY Szintek v6 savale

- url: https://www.tradingview.com/script/FlrmVcDQ-London-NY-Szintek-v6-savale/
- type: indicator
- pine_id: PUB;93c79a62e7014bcfb86f6322d587fce7
- version: 1.0

## Description

Picture this: the London and New York markets just woke up and they're clumsily stumbling around in their pajamas.

For the first 30 minutes, this indicator simply watches the chaos and draws a literal "boredom box" around the highest and lowest prices they hit.

As long as the price is just bouncing around inside this box, we do absolutely nothing (just sip our coffee and judge them). But the second the price breaks out of that box like a highly caffeinated rhino? BOOM! We jump on its back and ride the trend, because that's where the big money is! 🦏💸

## Source Code

````pine
//@version=6
indicator("Fixált London & NY Szintek v6", overlay=true)

// ==========================================
// 1. IDŐZÍTÉSEK BEÁLLÍTÁSA (Magyar idő szerint)
// ==========================================
london_calc_session = "0900-0930"
london_full_session = "0900-1500"

ny_calc_session     = "1530-1600"
ny_full_session     = "1530-0830" 

tz = "Europe/Budapest"

// Szétszedjük a zárójeleket a biztos hibamentességért
t_lon_calc = time("", london_calc_session, tz)
in_london_calc = not na(t_lon_calc)

t_lon_full = time("", london_full_session, tz)
in_london_full = not na(t_lon_full)

t_ny_calc = time("", ny_calc_session, tz)
in_ny_calc = not na(t_ny_calc)

t_ny_full = time("", ny_full_session, tz)
in_ny_full = not na(t_ny_full)

// ==========================================
// 2. TÁROLÓ VÁLTOZÓK
// ==========================================
var float lon_high = na
var float lon_low  = na

var float ny_high  = na
var float ny_low   = na

// ==========================================
// 3. LONDON SZINTEK KISZÁMÍTÁSA
// ==========================================
if in_london_full
    if in_london_calc
        if not in_london_calc[1] // Első gyertya 09:00-kor
            lon_high := high
            lon_low  := low
        else
            lon_high := math.max(high, lon_high)
            lon_low  := math.min(low, lon_low)
else
    lon_high := na
    lon_low  := na

// ==========================================
// 4. NEW YORK SZINTEK KISZÁMÍTÁSA
// ==========================================
if in_ny_full
    if in_ny_calc
        if not in_ny_calc[1] // Első gyertya 15:30-kor
            ny_high := high
            ny_low  := low
        else
            ny_high := math.max(high, ny_high)
            ny_low  := math.min(low, ny_low)
else
    ny_high := na
    ny_low  := na

// ==========================================
// 5. STABIL RAJZOLÁS (PLOT & FILL)
// ==========================================
// London vonalak és felhő
p_lon_high = plot(lon_high, color=color.green, linewidth=2, style=plot.style_linebr, title="London High")
p_lon_low  = plot(lon_low, color=color.red, linewidth=2, style=plot.style_linebr, title="London Low")
fill(p_lon_high, p_lon_low, color=color.new(color.green, 93), title="London Felhő")

// New York vonalak és felhő
p_ny_high = plot(ny_high, color=color.blue, linewidth=2, style=plot.style_linebr, title="NY High")
p_ny_low  = plot(ny_low, color=color.orange, linewidth=2, style=plot.style_linebr, title="NY Low")
fill(p_ny_high, p_ny_low, color=color.new(color.blue, 93), title="NY Felhő")
````
