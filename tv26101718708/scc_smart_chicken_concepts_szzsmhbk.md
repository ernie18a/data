# SCC - Smart Chicken Concepts

- url: https://www.tradingview.com/script/Szzsmhbk-SCC-Smart-Chicken-Concepts/
- type: indicator
- pine_id: PUB;591878d0019040c9ba00174a4cc5c064
- version: 1.0

## Description

SMART CHICKEN CONCEPTS  (SCC)

The world's first chicken-powered trading system.

At random intervals, a chicken is presented with three choices:

🥣 LONG

🥣 SHORT

🚫 NO THANKS

If the chicken pecks LONG → BUY

If the chicken pecks SHORT → SELL

If the chicken refuses to eat → STAY OUT

No indicators.
No analysis.
No hidden algorithms.

Just chicken.

100% Random.
100% Chicken.
0% Financial Advice.

## Source Code

````pine
//@version=6
indicator("SMC - Smart Chicken Concepts", overlay=true, max_labels_count=500)

maxMinutes = input.int(30, "Máximo de minutos", minval=15)
showLabels = input.bool(true)

random(seed) =>
    x = math.sin(seed) * 10000
    x - math.floor(x)

var int nextDecision = na
var string chickenChoice = "NO, THKS"

if na(nextDecision)
    nextDecision := time

newDecision = time >= nextDecision

if newDecision
    seed = time + bar_index * 999
    r = random(seed)
    chickenChoice :=
         r < 0.33 ? "LONG" :
         r < 0.66 ? "SHORT" :
         "NO, THKS"
    randomTime = math.floor(random(seed + 777) * maxMinutes) + 1
    nextDecision := time + randomTime * 60 * 1000


if newDecision and showLabels
    txt = chickenChoice == "LONG" ? "🐔 LONG" : chickenChoice == "SHORT" ? "🐔 SHORT" : "🐔 NO, THKS"
    label.new(bar_index, high, txt, style=label.style_label_down, color=color.yellow, textcolor=color.black)

// -- Branded Smart Chicken top-center table --
var table novaT = table.new(position.top_center, 2, 2, bgcolor=color.new(color.navy, 85), border_color=color.new(color.orange, 85), border_width=2)

friendlyChoice = chickenChoice == "LONG" ? "🐔 LONG 🟢" : chickenChoice == "SHORT" ? "🐔 SHORT 🔴" : "🐔 NO, THKS"

if barstate.islast
    headerColor = color.new(color.orange, 50)
    table.cell(novaT, 0, 0, "🐔 SMART CHICKEN CONCEPT", text_color=color.white, text_size=size.normal, bgcolor=headerColor)
    table.cell(novaT, 1, 0, "", bgcolor=headerColor)
    choiceBg = chickenChoice == "LONG"  ? color.new(color.green, 75) :
               chickenChoice == "SHORT" ? color.new(color.red, 75)   :
               color.new(color.gray, 70)
    choiceTextColor = chickenChoice == "LONG"  ? color.lime :
                      chickenChoice == "SHORT" ? color.orange :
                      color.white
    table.cell(novaT, 0, 1, friendlyChoice, text_color=choiceTextColor, text_size=size.huge, bgcolor=choiceBg)
    table.cell(novaT, 1, 1, "", bgcolor=choiceBg)
````
