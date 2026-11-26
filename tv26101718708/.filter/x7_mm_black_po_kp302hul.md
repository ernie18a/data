# x7 mm black po

- url: https://www.tradingview.com/script/kp302Hul/
- type: indicator
- pine_id: PUB;e5a3b194943742cfb6a9bbb323a3feff
- version: 1.0

## Description

x7 mm black po by 221, Danimanipulation e Matte, based on mm model 4 black project

## Source Code

````pine
//@version=6
// =============================================================================
// FXM WorkTime - TradingView port
// Original: "!FXM_WorkTime_v1.5c.ex4"
// Disegna box delle sessioni Asia / Frankfurt / London / New York con label
// (orari broker — di default GMT, configurabili). Marca chiusura giornaliera.
// =============================================================================
indicator("x7 mm black po", overlay=true, max_boxes_count=500, max_labels_count=500)

// ---- Inputs ----
tz          = input.string("GMT", "Timezone (es. 'GMT', 'Europe/Rome', 'America/New_York')")
showAsia    = input.bool(true,  "Show Asia",       inline="asia")
asiaStartH  = input.int(0,  "Start", minval=0, maxval=23, inline="asia")
asiaEndH    = input.int(7,  "End",   minval=0, maxval=23, inline="asia")
asiaCol     = input.color(color.new(color.yellow, 85), "Col", inline="asia")

showFFM     = input.bool(true,  "Show Frankfurt",  inline="ffm")
ffmStartH   = input.int(6,  "Start", minval=0, maxval=23, inline="ffm")
ffmEndH     = input.int(8,  "End",   minval=0, maxval=23, inline="ffm")
ffmCol      = input.color(color.new(color.orange, 85), "Col", inline="ffm")

showLDN     = input.bool(true,  "Show London",     inline="ldn")
ldnStartH   = input.int(7,  "Start", minval=0, maxval=23, inline="ldn")
ldnEndH     = input.int(15, "End",   minval=0, maxval=23, inline="ldn")
ldnCol      = input.color(color.new(color.green, 85), "Col", inline="ldn")

showNY      = input.bool(true,  "Show New York",   inline="ny")
nyStartH    = input.int(12, "Start", minval=0, maxval=23, inline="ny")
nyEndH      = input.int(20, "End",   minval=0, maxval=23, inline="ny")
nyCol       = input.color(color.new(color.blue, 85), "Col", inline="ny")

// ---- Helper: tempo sessione ----
sessHour(s, e) =>
    h = hour(time, tz)
    s <= e ? (h >= s and h < e) : (h >= s or h < e)

drawSession(active, sCol, name) =>
    var box bx = na
    newSess = active and not active[1]
    if newSess
        bx := box.new(left=bar_index, top=high+syminfo.mintick*5, right=bar_index, bottom=low-syminfo.mintick*5, bgcolor=sCol, border_color=color.new(sCol, 50))
        label.new(bar_index, high, name, style=label.style_label_down, color=color.new(sCol, 0), textcolor=color.white, size=size.small)
    if active and not na(bx)
        box.set_right(bx, bar_index)
        box.set_top(bx, math.max(box.get_top(bx), high))
        box.set_bottom(bx, math.min(box.get_bottom(bx), low))

drawSession(showAsia and sessHour(asiaStartH, asiaEndH), asiaCol, "ASIA")
drawSession(showFFM  and sessHour(ffmStartH,  ffmEndH),  ffmCol,  "FFM")
drawSession(showLDN  and sessHour(ldnStartH,  ldnEndH),  ldnCol,  "LDN")
drawSession(showNY   and sessHour(nyStartH,   nyEndH),   nyCol,   "NY")

// ---- Daily close line ----
isNewDay = ta.change(time("D")) != 0
plot(isNewDay ? close[1] : na, "Daily Close", style=plot.style_circles, color=color.new(color.white, 50))
````
