# Bitcoin Power-Law, Halvings & Wyckoff Model (Macro 1W/1M)

- url: https://www.tradingview.com/script/H2PiwKL5/
- type: indicator
- pine_id: PUB;4cf4c32edbbe410ca96611932176736d
- version: 1.0

## Description

An advanced Bitcoin macro analysis tool on weekly (1W) and monthly (1M) time frames. The script automatically maps global BTC cycles by combining the Power-Law mathematical model, Halving cyclicality, and precise institutional market geometry according to Richard Wyckoff's methodology. 

[b]How does the indicator work? (Key Pillars) [/b]
[i]1. Bitcoin Power-Law Model[/i] 
The script calculates the time elapsed since the birth of the Bitcoin network (the so-called Genesis Block – January 3, 2009). Based on a logarithmic scale, it marks four fixed long-term trend lines: 
- Blue Line (Fair Value): Shows Bitcoin's mathematical fair value, around which the market has been fluctuating for over a decade. 
- Purple Line (Medium-Term Ceiling): Marks historical market overheating zones and bull market bubble peaks. 
- Green Line (Price Floor): Key macro support level, marking the ultimate market bottom during the greatest capitulation. 
- Red Line: A safety band running deep below the chart, constituting the ultimate boundary of the uptrend. 

[i]2. Halving Cycles (Halving Counter)[/i] 
The indicator automatically locates past and future miner reward events on the timeline (including the upcoming Halving in April 2028). It plots vertical orange dashed lines with labels on the chart, allowing you to instantly assess which phase of the 4-year cycle the price is currently in. 

[i]3. Wyckoff Pattern Detection Macro (Post-Fact Drawing)[/i] 
This indicator operates in a highly secure and conservative manner. It doesn't guess patterns in real time to avoid false signals during trends. Instead, it scans the market for flat consolidations (sideways ranges) only in extreme regions: 
- Accumulation (Bear Bottoms): Searched only when the price is deep below the central axis (in the area of ​​the green line). 
- Distribution (Bull Tops): Searched only when the price is high above the central axis (in the area of ​​the 2024-2025 highs). 

Trigger Moment: When the market is building a sideways trend and the price officially crosses the 10-period moving average (SMA 10) (an upside breakout for accumulation or a downside breakdown for distribution), the algorithm validates the structure. In this split second, the script moves back on the chart for the designated period and plots the complete Wyckoff Anatomy using the spread: It draws automatic, horizontal support and resistance lines of the trading range (Trading Range). 
It sets vertical black lines dividing the structure into official market sub-phases. It marks precise turning points:
- institutional capital: PS/PSY (Initial Support/Resistance), 
- SC/BC (Selling/Buying Climax), 
- AR (Automatic Rebound), 
 - ST (Secondary Test), 
 - Spring/UTAD (Clearing Liquidity Lows/Highs), 
- LPS/LPSY (Last Support/Resistance Points) 
- and PHASE E – the moment of releasing a new, powerful macro trend. 

[b]User Manual Interval:[/b] 
The indicator was designed and calibrated exclusively for high time frames: 1 Week (1W) or 1 Month (1M). 

[i]Logarithmic Scale:[/i] In order for the Power-Law lines and labels to perfectly match the Bitcoin price chart and not "float" when scrolling the screen, you must have the logarithmic scale enabled on the TradingView chart (click the Log button in the lower right corner of the screen). 

Application: The tool is used to identify global turning points (wealth generation) – it allows you to buy Bitcoin in Phase E of macro accumulation and safely implement profits as Phase E distribution heralds the arrival of a bear market.

## Source Code

````pine
//@version=6
indicator("Bitcoin Power-Law, Halvings & Wyckoff Model v43 (Macro 1W/1M)", overlay=true, max_labels_count=500, max_lines_count=500)

// ==========================================
// 1. ZMIENNE GLOBALNE I GRAFICZNE
// ==========================================
var int last_halving_bar = 0
var int last_accum_bar = 0
var int last_dist_bar = 0

// ==========================================
// 2. USTAWIENIA I PARAMETRY WEJSCIE
// ==========================================
gp_power = "Model Power-Law"
exponent = input.float(5.686, title="Wykładnik (Exponent)", group=gp_power)
intercept = input.float(-37.99, title="Przesunięcie (Intercept)", group=gp_power)
top_offset = input.float(1.2, title="Mnożnik Szczytu (Log Offset)", group=gp_power)
bottom_offset = input.float(-0.4, title="Mnożnik Dołka (Log Offset)", group=gp_power)
red_line_drop = input.float(-1.2, title="Obniżenie czerwonej linii pod wykres", group=gp_power)

gp_wyckoff = "Detekcja Wyckoffa (Makro 1W / 1M)"
wyckoff_len = input.int(20, title="Okres analizy konsolidacji", minval=10, group=gp_wyckoff)
show_sr_lines = input.bool(true, title="Rysuj linie S/R Wyckoffa", group=gp_wyckoff)

// ==========================================
// 3. OBLICZENIA GLOBALNE I FILTRY CYKLU
// ==========================================
atr = ta.atr(14)
highest_high = ta.highest(high, wyckoff_len)
lowest_low = ta.lowest(low, wyckoff_len)

range_width = (highest_high - lowest_low) / (lowest_low > 0 ? lowest_low : 1)
is_flat_range = range_width < 0.40

macro_sma = ta.sma(close, 10)
macro_crossover = ta.crossover(close, macro_sma)
macro_crossunder = ta.crossunder(close, macro_sma)

// ==========================================
// 4. OBLICZENIA MODELU POWER-LAW
// ==========================================
genesis_time = timestamp(2009, 1, 3, 0, 0, 0)
days_since_genesis = (time - genesis_time) / (24 * 60 * 60 * 1000)

var float fair_price = na
var float peak_price = na
var float bottom_price = na
var float linear_trend = na

if days_since_genesis > 0
    fair_price := math.exp(exponent * math.log(days_since_genesis) + intercept)
    peak_price := math.exp(exponent * math.log(days_since_genesis) + intercept + top_offset)
    bottom_price := math.exp(exponent * math.log(days_since_genesis) + intercept + bottom_offset)
    linear_trend := math.exp(exponent * math.log(days_since_genesis) + intercept + red_line_drop)

plot(fair_price, title="Cena Godziwa (Fair Value)", color=color.blue, linewidth=2)
plot(peak_price, title="Sufit Srednioterminowy", color=color.purple, linewidth=2)
plot(bottom_price, title="Podloga Cenowa", color=color.green, linewidth=2)
plot(linear_trend, title="Czerwona Linia pod wykresem", color=color.red, linewidth=2)

// ==========================================
// 5. DATY HALVINGOW I PODSWIETLENIA (NA BIEZACO)
// ==========================================
is_h1 = (time >= timestamp(2012, 11, 23, 0, 0) and time <= timestamp(2012, 11, 30, 0, 0))
is_h2 = (time >= timestamp(2016, 7, 5, 0, 0)   and time <= timestamp(2016, 7, 12, 0, 0))
is_h3 = (time >= timestamp(2020, 5, 8, 0, 0)   and time <= timestamp(2020, 5, 15, 0, 0))
is_h4 = (time >= timestamp(2024, 4, 15, 0, 0)  and time <= timestamp(2024, 4, 22, 0, 0))
is_h5 = (time >= timestamp(2028, 4, 14, 0, 0)  and time <= timestamp(2028, 4, 21, 0, 0))

if (is_h1 or is_h2 or is_h3 or is_h4 or is_h5) and bar_index > last_halving_bar
    last_halving_bar := bar_index
    line.new(bar_index, low * 0.1, bar_index, high * 10, extend=extend.both, color=color.new(color.orange, 40), style=line.style_dashed, width=1)
    label.new(bar_index, high, text="HALVING", color=color.orange, textcolor=color.white, style=label.style_label_down, size=size.small)

is_bear = (time >= timestamp(2014, 1, 1) and time <= timestamp(2015, 1, 14)) or (time >= timestamp(2018, 1, 1) and time <= timestamp(2018, 12, 15)) or (time >= timestamp(2022, 1, 1) and time <= timestamp(2022, 11, 21)) or (time >= timestamp(2025, 6, 1))
is_bull = (time >= timestamp(2012, 11, 28) and time <= timestamp(2013, 11, 30)) or (time >= timestamp(2016, 7, 9)  and time <= timestamp(2017, 12, 17)) or (time >= timestamp(2020, 5, 11) and time <= timestamp(2021, 11, 10)) or (time >= timestamp(2022, 11, 22) and time < timestamp(2025, 6, 1))

bgcolor(is_bear ? color.new(color.red, 95) : na, title="Okresy Bessy")
bgcolor(is_bull ? color.new(color.green, 95) : na, title="Okresy Hossy")

// ==========================================
// 6. MAKRO DETEKCJA STRUKTUR WYCKOFFA
// ==========================================
is_macro_tf = timeframe.isweekly or timeframe.ismonthly

near_macro_bottom = ta.lowest(low, 10) <= bottom_price * 1.50
near_macro_top    = ta.highest(high, 10) >= peak_price * 0.65

wyckoff_accumulation = is_macro_tf and is_bear and is_flat_range and near_macro_bottom and macro_crossover
wyckoff_distribution = is_macro_tf and is_bull and is_flat_range and near_macro_top and macro_crossunder

if wyckoff_accumulation and (bar_index - last_accum_bar > 30)
    last_accum_bar := bar_index
    r1 = highest_high
    r2 = highest_high - (atr * 0.4)
    s1 = lowest_low
    s2 = lowest_low + (atr * 0.4)
    
    // Rysowanie S/R w oparciu o bezpieczne przypisania lokalne v6
    line l_sr1 = show_sr_lines ? line.new(bar_index[wyckoff_len], r1, bar_index, r1, color=color.red, width=2) : na
    line l_sr2 = show_sr_lines ? line.new(bar_index[wyckoff_len], r2, bar_index, r2, color=color.orange, width=1, style=line.style_dashed) : na
    line l_sr3 = show_sr_lines ? line.new(bar_index[wyckoff_len], s1, bar_index, s1, color=color.green, width=2) : na
    line l_sr4 = show_sr_lines ? line.new(bar_index[wyckoff_len], s2, bar_index, s2, color=color.lime, width=1, style=line.style_dashed) : na
    
    // FAZA A
    line ln_a1 = line.new(bar_index - 24, low * 0.2, bar_index - 24, high * 5, extend=extend.both, color=color.black, style=line.style_dashed, width=1)
    label lb_a1 = label.new(bar_index - 24, s1, text="PS", color=color.gray, textcolor=color.white, style=label.style_label_up, size=size.small)
    label lb_a2 = label.new(bar_index - 22, s1, text="SC", color=color.red, textcolor=color.white, style=label.style_label_up, size=size.small)
    label lb_a3 = label.new(bar_index - 20, r1, text="AR", color=color.green, textcolor=color.white, style=label.style_label_down, size=size.small)
    label lb_a4 = label.new(bar_index - 18, s2, text="ST (A)", color=color.gray, textcolor=color.white, style=label.style_label_up, size=size.small)
    // FAZA B
    line ln_a2 = line.new(bar_index - 14, low * 0.2, bar_index - 14, high * 5, extend=extend.both, color=color.black, style=line.style_dashed, width=1)
    label lb_a5 = label.new(bar_index - 11, s2, text="ST (B)", color=color.orange, textcolor=color.black, style=label.style_label_up, size=size.small)
    // FAZA C
    line ln_a3 = line.new(bar_index - 8, low * 0.2, bar_index - 8, high * 5, extend=extend.both, color=color.black, style=line.style_dashed, width=1)
    label lb_a6 = label.new(bar_index - 7, s1, text="Spring", color=color.blue, textcolor=color.white, style=label.style_label_up, size=size.small)
    label lb_a7 = label.new(bar_index - 5, s2, text="Test (C)", color=color.navy, textcolor=color.white, style=label.style_label_up, size=size.small)
    // FAZA D
    line ln_a4 = line.new(bar_index - 4, low * 0.2, bar_index - 4, high * 5, extend=extend.both, color=color.black, style=line.style_dashed, width=1)
    label lb_a8 = label.new(bar_index - 3, s2, text="LPS", color=color.olive, textcolor=color.white, style=label.style_label_up, size=size.small)
    label lb_a9 = label.new(bar_index - 2, r2, text="SOS", color=color.teal, textcolor=color.white, style=label.style_label_down, size=size.small)
    label lb_a10 = label.new(bar_index - 1, r1, text="BU/LPS", color=color.green, textcolor=color.white, style=label.style_label_down, size=size.small)
    // FAZA E
    line ln_a5 = line.new(bar_index, low * 0.2, bar_index, high * 5, extend=extend.both, color=color.black, style=line.style_dashed, width=1)
    label lb_a11 = label.new(bar_index, high, text="FAZA E", color=color.lime, textcolor=color.black, style=label.style_label_down, size=size.small)

if wyckoff_distribution and (bar_index - last_dist_bar > 30)
    last_dist_bar := bar_index
    r1 = highest_high
    r2 = highest_high - (atr * 0.4)
    s1 = lowest_low
    s2 = lowest_low + (atr * 0.4)
    
    // Rysowanie S/R w oparciu o bezpieczne przypisania lokalne v6
    line l_sr5 = show_sr_lines ? line.new(bar_index[wyckoff_len], r1, bar_index, r1, color=color.red, width=2) : na
    line l_sr6 = show_sr_lines ? line.new(bar_index[wyckoff_len], r2, bar_index, r2, color=color.orange, width=1, style=line.style_dashed) : na
    line l_sr7 = show_sr_lines ? line.new(bar_index[wyckoff_len], s1, bar_index, s1, color=color.green, width=2) : na
    line l_sr8 = show_sr_lines ? line.new(bar_index[wyckoff_len], s2, bar_index, s2, color=color.lime, width=1, style=line.style_dashed) : na
        
    // FAZA A
    line ln_dist1 = line.new(bar_index - 24, low * 0.2, bar_index - 24, high * 5, extend=extend.both, color=color.black, style=line.style_dashed, width=1)
    label lb_dist1 = label.new(bar_index - 24, r1, text="PSY", color=color.gray, textcolor=color.white, style=label.style_label_down, size=size.small)
    label lb_dist2 = label.new(bar_index - 22, r1, text="BC", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)
    label lb_dist3 = label.new(bar_index - 20, s1, text="AR", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small)
    label lb_dist4 = label.new(bar_index - 18, r2, text="ST (A)", color=color.gray, textcolor=color.white, style=label.style_label_down, size=size.small)
    // FAZA B
    line ln_dist2 = line.new(bar_index - 14, low * 0.2, bar_index - 14, high * 5, extend=extend.both, color=color.black, style=line.style_dashed, width=1)
    label lb_dist5 = label.new(bar_index - 11, r2, text="UA (B)", color=color.orange, textcolor=color.black, style=label.style_label_down, size=size.small)// FAZA Cline ln_dist3 = line.new(bar_index - 8, low * 0.2, bar_index - 8, high * 5, extend=extend.both, color=color.black, style=line.style_dashed, width=1)label lb_dist6 = label.new(bar_index - 7, r1, text="UTAD", color=color.purple, textcolor=color.white, style=label.style_label_down, size=size.small)label lb_dist7 = label.new(bar_index - 5, r2, text="Test (C)", color=color.maroon, textcolor=color.white, style=label.style_label_down, size=size.small)// FAZA Dline ln_dist4 = line.new(bar_index - 4, low * 0.2, bar_index - 4, high * 5, extend=extend.both, color=color.black, style=line.style_dashed, width=1)label lb_dist8 = label.new(bar_index - 3, r2, text="LPSY", color=color.orange, textcolor=color.white, style=label.style_label_down, size=size.small)label lb_dist9 = label.new(bar_index - 2, s2, text="SOW", color=color.red, textcolor=color.white, style=label.style_label_up, size=size.small)label lb_dist10 = label.new(bar_index - 1, s1, text="BU/LPSY", color=color.maroon, textcolor=color.white, style=label.style_label_up, size=size.small)// FAZA Eline ln_dist5 = line.new(bar_index, low * 0.2, bar_index, high * 5, extend=extend.both, color=color.black, style=line.style_dashed, width=1)label lb_dist11 = label.new(bar_index, low, text="FAZA E", color=color.red, textcolor=color.white, style=label.style_label_up, size=size.small)
````
