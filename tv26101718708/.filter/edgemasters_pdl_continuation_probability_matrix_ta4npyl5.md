# EdgeMaster's PDL Continuation Probability Matrix

- url: https://www.tradingview.com/script/TA4NpYl5-EdgeMaster-s-PDL-Continuation-Probability-Matrix/
- type: indicator
- pine_id: PUB;4f1eac9be2d243a5935d4b6a1b9ebac9
- version: 1.0

## Description

📊 EdgeMaster’s PDH Sweep Continuation Probability Matrix

This indicator models how price behaves after a prior day high (PDH) liquidity sweep by projecting a structured continuation probability matrix above the PDH level.

When price trades above the previous day high, the script activates and plots a predefined ladder of extension levels above that high, each representing statistically weighted continuation or reaction zones based on a fixed point distribution model.

🧠 Core Concept

Markets often do not reverse immediately after sweeping prior day liquidity. Instead, price frequently:

extends into imbalance zones
targets incremental liquidity pockets
reacts at structured fib-like expansion levels

This tool maps that behavior into a consistent visual framework.

⚙️ How It Works
Uses the previous day high (PDH) as the anchor reference.
Detects when price sweeps above PDH.
Once triggered, it projects a fixed matrix of levels above PDH using predefined offsets.

Each level is paired with a label that represents:

continuation probability zones
reaction thresholds
take-profit / entry areas
📈 Visual Output

When a PDH sweep occurs, the indicator plots:

A full continuation ladder above PDH
Semi-transparent horizontal levels
Descriptive labels such as:
Entry zones
Partial reaction zones
Take-profit targets

Each level is color-coded to distinguish:

continuation bias zones (green)
reaction / pullback risk zones (red)
neutral / decision zones (yellow)
🎯 Intended Use

This tool is designed for traders focusing on:

liquidity sweep models
ICT-style PDH/PDL manipulation concepts
intraday continuation after stop runs
structured profit-taking frameworks

It helps answer:

“After PDH is taken, how far does price statistically tend to continue before reacting?”

⚠️ Important Notes
This is a probability visualization model, not a signal system.
Levels are static once triggered and do not repaint historical sweeps.
It is intended for context, confluence, and trade planning, not automation.

## Source Code

````pine
//@version=6
indicator("EdgeMaster's PDL Continuation Probability Matrix", overlay=true)

//========================
// PDH
//========================
yHigh = request.security(syminfo.tickerid, "D", high[1])
plot(yHigh, color=color.red, linewidth=2)

//========================
// SWEEP
//========================
tookHigh = high > yHigh

//========================
// LEVEL DATA (FLAT ARRAYS ONLY)
//========================
pts = array.from(0,25,50,75,100,150,175,200,225,250,275,300,350,400,425,450,525,550,650,725,800,1025)

txts = array.from(
"0","25 90%","50 75%","75 63%","100 TP 50%",
"150 30%","175 TP 28%","200 22%","225 18%","250 TP 15%",
"275 11%","300 10%","350 TP 7%","400 TP 4%","425 2%",
"450 Entry","525 TP","550 Entry","650 TP","725 Entry","800 TP","1025 TP"
)

//========================
// STORAGE
//========================
var line[] lines = array.new_line()
var label[] labels = array.new_label()

if barstate.isfirst
    for i = 0 to array.size(pts) - 1
        array.push(lines, na)
        array.push(labels, na)

//========================
// COLOR SWITCH (SAFE)
//========================
f_col(txt) =>
    if txt == "0 Entry"
        color.yellow
    else if txt == "25 90%"
        color.green
    else if txt == "50 75%"
        color.green
    else if txt == "75 63%"
        color.green
    else if txt == "100 TP 50%"
        color.green
    else if txt == "150 30%"
        color.red
    else if txt == "175 TP 28%"
        color.green
    else if txt == "200 22%"
        color.red
    else if txt == "225 18%"
        color.red
    else if txt == "250 TP 15%"
        color.green
    else if txt == "275 11%"
        color.red
    else if txt == "300 10%"
        color.red
    else if txt == "350 TP 7%"
        color.green
    else if txt == "400 TP 4%"
        color.green
    else if txt == "425 2%"
        color.red
    else if txt == "450 Entry"
        color.yellow
    else if txt == "525 TP"
        color.green
    else if txt == "550 Entry"
        color.yellow
    else if txt == "650 TP"
        color.green
    else if txt == "725 Entry"
        color.yellow
    else if txt == "800 TP"
        color.green
    else
        color.green

//========================
// DRAW
//========================
if tookHigh
    for i = 0 to array.size(pts) - 1

        level = yHigh + array.get(pts, i)
        txt = array.get(txts, i)
        col = f_col(txt)

        l = array.get(lines, i)
        lb = array.get(labels, i)

        if na(l)
            l := line.new(bar_index - 50, level, bar_index - 5, level, color=color.new(col, 40))
            array.set(lines, i, l)
        else
            line.set_xy1(l, bar_index - 50, level)
            line.set_xy2(l, bar_index - 5, level)
            line.set_color(l, color.new(col, 40))

        if na(lb)
            lb := label.new(bar_index - 55, level, txt, style=label.style_none, textcolor=col, size=size.tiny)
            array.set(labels, i, lb)
        else
            label.set_xy(lb, bar_index - 55, level)
            label.set_text(lb, txt)
            label.set_textcolor(lb, col)
````
