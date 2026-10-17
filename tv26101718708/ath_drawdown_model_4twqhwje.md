# ATH Drawdown model

- url: https://www.tradingview.com/script/4twqhWjE-ATH-Drawdown-model/
- type: indicator
- pine_id: PUB;a04752d994094899a8856a7fe0eb5ac9
- version: 1.0

## Description

Best way to use:
On this model, the most useful reclaim alerts are usually L4, L3, and L2, because they often mark recovery from deeper drawdown zones back into improving structure. The cleanest use is on Daily, with 12H or 6H for earlier but still confirmed signals, always based on the completed candle close rather than mid-candle movement.

Clean interpretation:
A simple interpretation rule would be:
>Entered L4/L5: deep drawdown / stress zone.
>Reclaimed L4: early recovery signal.
>Reclaimed L3: stronger improvement in structure.
>Reclaimed L2: recovery gaining real traction

How to interpret “dead” names
Using this model, a name looks more structurally broken when it spends long periods in L4/L5, fails to reclaim those levels on confirmed bar closes, or reclaims them briefly and then loses them again. The Patreon guidance does not define “dead stock” directly, but it does emphasize using confirmed bar-close behavior rather than intrabar noise, so the meaningful signal is not a bounce during the candle — it is whether the level is reclaimed and held at candle close.

Best timeframe
The Patreon post says daily is great, while 12-hour or 6-hour can show direction changes earlier as long as you still confirm on bar close. So a practical setup is daily for your main map, 12H for earlier tactical signals, and 6H only when you want more responsiveness and accept more noise.

NO FINANCIAL ADVICE

## Source Code

````pine
// Peter Rossler
// based on IA reasoning 06.2026

//@version=6
indicator("ATH Drawdown model", overlay=true, max_labels_count=500)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
groupAth = "ATH Drawdown Levels"
dd1 = input.float(10.0, "Level 1 Drawdown %", minval=0.1, step=0.1, group=groupAth)
dd2 = input.float(20.0, "Level 2 Drawdown %", minval=0.1, step=0.1, group=groupAth)
dd3 = input.float(30.0, "Level 3 Drawdown %", minval=0.1, step=0.1, group=groupAth)
dd4 = input.float(40.0, "Level 4 Drawdown %", minval=0.1, step=0.1, group=groupAth)
dd5 = input.float(50.0, "Level 5 Drawdown %", minval=0.1, step=0.1, group=groupAth)

groupDisplay = "Display"
showATHLabel      = input.bool(true, "Show ATH Label", group=groupDisplay)
showLevelLabels   = input.bool(true, "Show Right-Side Level Labels", group=groupDisplay)
showLevelClouds   = input.bool(true, "Shade Drawdown Zones", group=groupDisplay)
showNewATHMarker  = input.bool(true, "Mark New ATH", group=groupDisplay)
showRecoveryMarks = input.bool(true, "Show Recovery Markers", group=groupDisplay)
showEntryMarks    = input.bool(true, "Show Entry Markers", group=groupDisplay)

groupStyle = "Style"
athColor = input.color(color.new(color.blue, 0), "ATH Color", group=groupStyle)
l1Color  = input.color(color.new(color.lime, 0), "Level 1 Color", group=groupStyle)
l2Color  = input.color(color.new(color.green, 0), "Level 2 Color", group=groupStyle)
l3Color  = input.color(color.new(color.yellow, 0), "Level 3 Color", group=groupStyle)
l4Color  = input.color(color.new(color.orange, 0), "Level 4 Color", group=groupStyle)
l5Color  = input.color(color.new(color.red, 0), "Level 5 Color", group=groupStyle)

//--------------------------------------------------
// Dynamic ATH
//--------------------------------------------------
var float ath = na
ath := na(ath[1]) ? high : math.max(ath[1], high)

bool newATH = high > nz(ath[1], high - syminfo.mintick)

//--------------------------------------------------
// Drawdown levels below ATH
//--------------------------------------------------
float l1 = ath * (1.0 - dd1 / 100.0)
float l2 = ath * (1.0 - dd2 / 100.0)
float l3 = ath * (1.0 - dd3 / 100.0)
float l4 = ath * (1.0 - dd4 / 100.0)
float l5 = ath * (1.0 - dd5 / 100.0)

float currDD = ath > 0 ? ((ath - close) / ath) * 100.0 : na

string zoneText =
     close >= l1 ? "Above L1" :
     close >= l2 ? "L1-L2" :
     close >= l3 ? "L2-L3" :
     close >= l4 ? "L3-L4" :
     close >= l5 ? "L4-L5" : "Below L5"

//--------------------------------------------------
// Entry alerts (entered deeper drawdown on bar close)
//--------------------------------------------------
bool enteredL1 = close <= l1 and close[1] > l1[1]
bool enteredL2 = close <= l2 and close[1] > l2[1]
bool enteredL3 = close <= l3 and close[1] > l3[1]
bool enteredL4 = close <= l4 and close[1] > l4[1]
bool enteredL5 = close <= l5 and close[1] > l5[1]

//--------------------------------------------------
// Recovery alerts (reclaimed level on bar close)
//--------------------------------------------------
bool reclaimL1 = close > l1 and close[1] <= l1[1]
bool reclaimL2 = close > l2 and close[1] <= l2[1]
bool reclaimL3 = close > l3 and close[1] <= l3[1]
bool reclaimL4 = close > l4 and close[1] <= l4[1]
bool reclaimL5 = close > l5 and close[1] <= l5[1]

//--------------------------------------------------
// Plots
//--------------------------------------------------
pATH = plot(ath, title="ATH", color=athColor, linewidth=3)
pL1  = plot(l1, title="L1", color=l1Color, linewidth=2)
pL2  = plot(l2, title="L2", color=l2Color, linewidth=2)
pL3  = plot(l3, title="L3", color=l3Color, linewidth=2)
pL4  = plot(l4, title="L4", color=l4Color, linewidth=2)
pL5  = plot(l5, title="L5", color=l5Color, linewidth=3)

//--------------------------------------------------
// Clouds
//--------------------------------------------------
fill(pATH, pL1, color = showLevelClouds ? color.new(l1Color, 90) : na, title="ATH-L1 Zone")
fill(pL1, pL2, color = showLevelClouds ? color.new(l2Color, 90) : na, title="L1-L2 Zone")
fill(pL2, pL3, color = showLevelClouds ? color.new(l3Color, 90) : na, title="L2-L3 Zone")
fill(pL3, pL4, color = showLevelClouds ? color.new(l4Color, 90) : na, title="L3-L4 Zone")
fill(pL4, pL5, color = showLevelClouds ? color.new(l5Color, 90) : na, title="L4-L5 Zone")

//--------------------------------------------------
// Markers (minimal: only L3 / L4 / L5, no text)
//--------------------------------------------------
plotshape(showNewATHMarker and newATH, title="New ATH", style=shape.circle,
     location=location.abovebar, color=color.new(athColor, 20), size=size.tiny)

plotshape(showEntryMarks and enteredL3, title="Entered L3", style=shape.triangledown,
     location=location.abovebar, color=color.new(l3Color, 15), size=size.tiny)
plotshape(showEntryMarks and enteredL4, title="Entered L4", style=shape.triangledown,
     location=location.abovebar, color=color.new(l4Color, 15), size=size.tiny)
plotshape(showEntryMarks and enteredL5, title="Entered L5", style=shape.triangledown,
     location=location.abovebar, color=color.new(l5Color, 15), size=size.tiny)

plotshape(showRecoveryMarks and reclaimL3, title="Reclaim L3", style=shape.triangleup,
     location=location.belowbar, color=color.new(l3Color, 15), size=size.tiny)
plotshape(showRecoveryMarks and reclaimL4, title="Reclaim L4", style=shape.triangleup,
     location=location.belowbar, color=color.new(l4Color, 15), size=size.tiny)
plotshape(showRecoveryMarks and reclaimL5, title="Reclaim L5", style=shape.triangleup,
     location=location.belowbar, color=color.new(l5Color, 15), size=size.tiny)

//--------------------------------------------------
// ATH label
//--------------------------------------------------
var label athLbl = na
if barstate.islast
    if showATHLabel
        if na(athLbl)
            athLbl := label.new(bar_index, ath, "", xloc=xloc.bar_index, style=label.style_label_left)
        label.set_xy(athLbl, bar_index, ath)
        label.set_text(athLbl, "ATH " + str.tostring(ath, format.mintick))
        label.set_color(athLbl, athColor)
        label.set_textcolor(athLbl, color.white)
    else
        if not na(athLbl)
            label.delete(athLbl)
            athLbl := na

//--------------------------------------------------
// Right-side dynamic labels
//--------------------------------------------------
var label lbL1 = na
var label lbL2 = na
var label lbL3 = na
var label lbL4 = na
var label lbL5 = na

f_setLabel(label _lbl, int _x, float _y, string _txt, color _bg) =>
    label.set_xy(_lbl, _x, _y)
    label.set_text(_lbl, _txt)
    label.set_color(_lbl, _bg)
    label.set_textcolor(_lbl, color.white)

if barstate.islast
    if showLevelLabels
        if na(lbL1)
            lbL1 := label.new(bar_index, l1, "", xloc=xloc.bar_index, style=label.style_label_left)
            lbL2 := label.new(bar_index, l2, "", xloc=xloc.bar_index, style=label.style_label_left)
            lbL3 := label.new(bar_index, l3, "", xloc=xloc.bar_index, style=label.style_label_left)
            lbL4 := label.new(bar_index, l4, "", xloc=xloc.bar_index, style=label.style_label_left)
            lbL5 := label.new(bar_index, l5, "", xloc=xloc.bar_index, style=label.style_label_left)

        f_setLabel(lbL1, bar_index, l1, "L1 -" + str.tostring(dd1, "#.#") + "%", l1Color)
        f_setLabel(lbL2, bar_index, l2, "L2 -" + str.tostring(dd2, "#.#") + "%", l2Color)
        f_setLabel(lbL3, bar_index, l3, "L3 -" + str.tostring(dd3, "#.#") + "%", l3Color)
        f_setLabel(lbL4, bar_index, l4, "L4 -" + str.tostring(dd4, "#.#") + "%", l4Color)
        f_setLabel(lbL5, bar_index, l5, "L5 -" + str.tostring(dd5, "#.#") + "%", l5Color)
    else
        if not na(lbL1)
            label.delete(lbL1)
            label.delete(lbL2)
            label.delete(lbL3)
            label.delete(lbL4)
            label.delete(lbL5)
            lbL1 := na
            lbL2 := na
            lbL3 := na
            lbL4 := na
            lbL5 := na

//--------------------------------------------------
// Alerts
//--------------------------------------------------
alertcondition(newATH, title="New ATH Reached", message="Price has made a new all-time high.")

alertcondition(enteredL1, title="Entered Level 1", message="Price entered ATH drawdown Level 1 on bar close.")
alertcondition(enteredL2, title="Entered Level 2", message="Price entered ATH drawdown Level 2 on bar close.")
alertcondition(enteredL3, title="Entered Level 3", message="Price entered ATH drawdown Level 3 on bar close.")
alertcondition(enteredL4, title="Entered Level 4", message="Price entered ATH drawdown Level 4 on bar close.")
alertcondition(enteredL5, title="Entered Level 5", message="Price entered ATH drawdown Level 5 on bar close.")

alertcondition(reclaimL1, title="Reclaimed Level 1", message="Price reclaimed ATH drawdown Level 1 on bar close.")
alertcondition(reclaimL2, title="Reclaimed Level 2", message="Price reclaimed ATH drawdown Level 2 on bar close.")
alertcondition(reclaimL3, title="Reclaimed Level 3", message="Price reclaimed ATH drawdown Level 3 on bar close.")
alertcondition(reclaimL4, title="Reclaimed Level 4", message="Price reclaimed ATH drawdown Level 4 on bar close.")
alertcondition(reclaimL5, title="Reclaimed Level 5", message="Price reclaimed ATH drawdown Level 5 on bar close.")

//--------------------------------------------------
// Status table
//--------------------------------------------------
var table t = table.new(position.top_right, 1, 1)
if barstate.islast
    table.cell(
        t, 0, 0,
        "ATH DD: " + str.tostring(currDD, "#.##") + "% | Zone: " + zoneText,
        text_color=color.white,
        bgcolor=color.new(color.black, 20)
    )
````
