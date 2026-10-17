# Renko Close Alert

- url: https://www.tradingview.com/script/z8mZMyn7-Renko-Close-Alert/
- type: indicator
- pine_id: PUB;897fc73d9ca941d38f5ca7c6942c2712
- version: 1.0

## Description

alert when a new renko brick closes. only to be used on a traditional renko chart

## Source Code

````pine
//@version=5
indicator("Renko Close Alert", overlay=true)

// ===== INPUTS =====
brickSize = input.float(10, "Renko Brick Size", step=0.1)  
useATR = input.bool(false, "Use ATR for brick size?")
atrLength = input.int(14, "ATR Length", minval=1)

// ===== RENKO CALCULATION =====
src = close
atr = ta.atr(atrLength)
size = useATR ? atr : brickSize

var float renkoClose = na
var float renkoOpen = na
var int direction = 0  // 1 = up, -1 = down

var bool upBrickClosed = false
var bool downBrickClosed = false

if na(renkoClose)
    renkoClose := src
    renkoOpen := src

diff = src - renkoClose
upBrickClosed := false
downBrickClosed := false

if diff >= size
    renkoOpen := renkoClose
    renkoClose := renkoClose + size
    direction := 1
    upBrickClosed := true
if diff <= -size
    renkoOpen := renkoClose
    renkoClose := renkoClose - size
    direction := -1
    downBrickClosed := true

// ===== PLOT RENKO BRICKS =====
plot(renkoClose, color=direction==1 ? color.green : direction==-1 ? color.red : color.gray, linewidth=2, style=plot.style_linebr)
bgcolor(direction == 1 ? color.new(color.green, 85) : direction == -1 ? color.new(color.red, 85) : na)

// ===== ALERT CONDITIONS =====
alertcondition(upBrickClosed, title="Renko Up Brick Closed", message="Renko Up Brick Closed!")
alertcondition(downBrickClosed, title="Renko Down Brick Closed", message="Renko Down Brick Closed!")
````
