# Gold Forward Read

- url: https://www.tradingview.com/script/RQpAS7fz-Gold-Forward-Read/
- type: indicator
- pine_id: PUB;d6ba20db25b240a89c1a36a348f124cc
- version: 2.0

## Description

XAU Forward reads the dollar, the 10-year yield, and oil, then shows the part of that push gold has not priced yet. You put it on a 5-minute XAUUSD chart. The box in the top right is the live read. The columns underneath are the open gap.

How the three markets are read

The dollar and the 10-year yield normally move opposite to gold. Dollar down, or yields down, pushes gold up. Dollar up, or yields up, pushes gold down. The script checks the last 30 bars. If that link is still inverse, the row says inverse. If gold and that market have started moving the same way, the row says with and the color follows the new link. If the link is unclear, the row says weak.

Oil has no fixed direction. It only counts when those recent bars show a real link. Otherwise the oil row stays flat.

Green on a row means that market is pushing gold up right now. Red means it is pushing gold down.

What the columns are

The script adds the dollar push and the yield push, plus oil only when oil has a link. Then it subtracts the move gold has already made. What is left is the column.

A green column above the line means upside is still open. A red column below the line means downside is still open. A column on the line means the other markets are already in the price.

What the word means

LEAN LONG or LEAN SHORT is the early read. The dollar and the yield point the same way, and gold has not fully followed.

LONG or SHORT is that same read once both pushes are strong and the open gap is large.

FLAT means there is no open gap. Stand aside.

UNSTABLE means gold and the dollar are rising or falling together, so the usual lead is off. Those columns turn grey and follow gold itself. Grey is not a long and not a short.

How this helps

It tells you when a gold move still has a reason behind it. A red column into a drop means the dollar and yields were already pointing gold down, and gold had not fallen enough yet. The selloff is gold catching up. A green column into a rally is the same idea upward. When the box says FLAT, the move is already priced and there is nothing to chase. When it says UNSTABLE, the usual dollar lead is broken, so you do not force a trade.

Use it as a filter on the 5-minute chart. Act when DXY and US10Y are the same color and NEXT says LEAN, then LONG or SHORT if the column grows. Leave it alone on FLAT and UNSTABLE.

## Source Code

````pine
//@version=6
indicator("Gold Forward", "XAU Forward", overlay=false, precision=2, max_bars_back=5000)

// XAUUSD CFD, 1 to 15 minutes.
// The box and the columns change only when the chart candle closes.
// Price moving inside the open candle does not flip the word.
//
// The number on each row is the last closed minute inside that candle.
// The word beside it (inverse, with, mixed, prior, flat) is measured from
// every active hour loaded on this chart, up to about 800 hours.
// Scroll the chart back so TradingView loads more history. More hours,
// better relationship. Until about 40 active hours exist, dollar and yield
// stay on their usual inverse link and the word says "prior".
//
// NOW is the scalp:
//   ENTER LONG / ENTER SHORT  The minute is moving, gold is still behind,
//                              and the 5-minute and 15-minute are not
//                              going the other way. You can still enter.
//   PRICED                    Those markets explain the move and gold
//                              has already caught up.
//   AGAINST                   The minute says one way, the 5-minute or
//                              15-minute says the other. Skip it.
//   UNCLEAR                   Gold is moving and dollar, yield, and oil
//                              are not the reason.
//   SPLIT                     Dollar and yield disagree.
//   UNSTABLE                  Lately gold and the dollar are moving together.
//   FLAT                      Nothing to do.
//
// Green pushes gold up. Red pushes gold down. Grey is not a trade.
// Columns are the room gold has not priced yet.
// Above the line, long room is still open. Below the line, short room.
//
// Dollar TVC:DXY    Yield TVC:US10Y    Oil TVC:USOIL
// If a feed is invalid, paste the symbol from the same list as your XAUUSD.
// If the yield symbol rises when yields fall, turn off "Falling yield is gold-bullish".

grpSym = "Symbols"
grpSig = "Signal"
grpSes = "Session"

dxySym    = input.symbol("TVC:DXY", "Dollar", group=grpSym, tooltip="If invalid, pick DXY from the same broker as your XAUUSD.")
yldSym    = input.symbol("TVC:US10Y", "US 10-year yield", group=grpSym)
oilSym    = input.symbol("TVC:USOIL", "WTI oil", group=grpSym)
invertYld = input.bool(true, "Falling yield is gold-bullish", group=grpSym)

wDxy    = input.float(1.0, "Dollar weight", minval=0.0, step=0.1, group=grpSig)
wYld    = input.float(1.0, "Yield weight", minval=0.0, step=0.1, group=grpSig)
wOil    = input.float(0.5, "Oil weight", minval=0.0, step=0.05, group=grpSig, tooltip="Oil is used only when the loaded hours show a real link to gold.")
moveThr = input.float(0.80, "Minute move", minval=0.2, step=0.05, group=grpSig, tooltip="How large the last minute must be before it counts. One market is enough.")
openThr = input.float(0.45, "Room still open", minval=0.1, step=0.05, group=grpSig, tooltip="Gold must still be behind by at least this much.")
breakThr  = input.float(0.35, "Unstable correlation", minval=0.05, maxval=0.95, step=0.05, group=grpSig)
breakBand = input.float(0.15, "Unstable exit", minval=0.05, step=0.05, group=grpSig)
coolBars  = input.int(3, "Min bars between alerts", minval=1, group=grpSig)

useSess = input.bool(false, "London to New York only", group=grpSes)
sess    = input.session("0300-1700", "Session (New York hours)", group=grpSes)

zMove() =>
    float c = close - close[1]
    float dev = ta.stdev(c, 120)
    float avg = ta.sma(c, 120)
    na(c) or na(dev) or dev == 0.0 ? na : (c - avg) / dev

doneMove() =>
    close[1] - close[2]

pearson(array<float> xs, array<float> ys) =>
    int n = math.min(array.size(xs), array.size(ys))
    float r = na
    if n >= 40
        float sx = 0.0
        float sy = 0.0
        for i = 0 to n - 1
            sx := sx + array.get(xs, i)
            sy := sy + array.get(ys, i)
        float mx = sx / n
        float my = sy / n
        float numc = 0.0
        float dx = 0.0
        float dy = 0.0
        for j = 0 to n - 1
            float a = array.get(xs, j) - mx
            float b = array.get(ys, j) - my
            numc := numc + a * b
            dx := dx + a * a
            dy := dy + b * b
        r := dx == 0.0 or dy == 0.0 ? na : numc / math.sqrt(dx * dy)
    r

pushPair(array<float> xs, array<float> ys, float x, float y, int cap) =>
    if not na(x) and not na(y) and x != 0.0 and y != 0.0
        array.push(xs, x)
        array.push(ys, y)
        if array.size(xs) > cap
            array.shift(xs)
            array.shift(ys)

sideOf(float dE, float yE, float oE, float thr, float oDir) =>
    bool dOn = not na(dE) and math.abs(dE) >= thr
    bool yOn = not na(yE) and math.abs(yE) >= thr
    bool oOn = oDir != 0.0 and not na(oE) and math.abs(oE) >= thr
    bool spl = dOn and yOn and (dE > 0.0) != (yE > 0.0)
    int sd = 0
    if not spl
        if dOn
            sd := dE > 0.0 ? 1 : -1
        else if yOn
            sd := yE > 0.0 ? 1 : -1
        else if oOn
            sd := oE > 0.0 ? 1 : -1
    sd

// Each timeframe's own last-bar reaction, scaled on that timeframe.
zG1 = request.security(syminfo.tickerid, "1", zMove(), barmerge.gaps_off, barmerge.lookahead_off)
zD1 = request.security(dxySym, "1", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
zY1 = request.security(yldSym, "1", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
zO1 = request.security(oilSym, "1", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

zD5 = request.security(dxySym, "5", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
zY5 = request.security(yldSym, "5", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
zO5 = request.security(oilSym, "5", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

zD15 = request.security(dxySym, "15", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
zY15 = request.security(yldSym, "15", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
zO15 = request.security(oilSym, "15", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

zD60 = request.security(dxySym, "60", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
zY60 = request.security(yldSym, "60", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
zO60 = request.security(oilSym, "60", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

zD240 = request.security(dxySym, "240", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
zY240 = request.security(yldSym, "240", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
zO240 = request.security(oilSym, "240", zMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

chG15 = request.security(syminfo.tickerid, "15", doneMove(), barmerge.gaps_off, barmerge.lookahead_off)
chD15 = request.security(dxySym, "15", doneMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
chY15 = request.security(yldSym, "15", doneMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
chO15 = request.security(oilSym, "15", doneMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

chG60 = request.security(syminfo.tickerid, "60", doneMove(), barmerge.gaps_off, barmerge.lookahead_off)
chD60 = request.security(dxySym, "60", doneMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
chY60 = request.security(yldSym, "60", doneMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)
chO60 = request.security(oilSym, "60", doneMove(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

var array<float> gDxyG = array.new_float()
var array<float> gDxyD = array.new_float()
var array<float> gYldG = array.new_float()
var array<float> gYldY = array.new_float()
var array<float> gOilG = array.new_float()
var array<float> gOilO = array.new_float()
var array<float> qDxyG = array.new_float()
var array<float> qDxyD = array.new_float()
var array<float> qYldG = array.new_float()
var array<float> qYldY = array.new_float()
var array<float> qOilG = array.new_float()
var array<float> qOilO = array.new_float()

var float corrD60 = na
var float corrY60 = na
var float corrO60 = na
var float corrD15 = na
var float corrY15 = na
var float corrO15 = na
var int seenH = na
var int seenQ = na

int hId = time("60")
if not na(hId) and hId != seenH
    seenH := hId
    pushPair(gDxyG, gDxyD, chG60, chD60, 800)
    pushPair(gYldG, gYldY, chG60, chY60, 800)
    pushPair(gOilG, gOilO, chG60, chO60, 800)
    corrD60 := pearson(gDxyG, gDxyD)
    corrY60 := pearson(gYldG, gYldY)
    corrO60 := pearson(gOilG, gOilO)

int qId = time("15")
if not na(qId) and qId != seenQ
    seenQ := qId
    pushPair(qDxyG, qDxyD, chG15, chD15, 400)
    pushPair(qYldG, qYldY, chG15, chY15, 400)
    pushPair(qOilG, qOilO, chG15, chO15, 400)
    corrD15 := pearson(qDxyG, qDxyD)
    corrY15 := pearson(qYldG, qYldY)
    corrO15 := pearson(qOilG, qOilO)

float linkD = not na(corrD60) ? corrD60 : corrD15
float linkY = not na(corrY60) ? corrY60 : corrY15
float linkO = not na(corrO60) ? corrO60 : corrO15

dirOf(float c, float prior) =>
    na(c) or math.abs(c) < 0.12 ? prior : c > 0.0 ? 1.0 : -1.0

float dxyDir = dirOf(linkD, -1.0)
float yldDir = dirOf(linkY, invertYld ? -1.0 : 1.0)
float oilDir = dirOf(linkO, 0.0)

float dxyE1 = na(zD1) ? na : dxyDir * zD1
float yldE1 = na(zY1) ? na : yldDir * zY1
float oilE1 = na(zO1) ? na : oilDir * zO1
float dxyE5 = na(zD5) ? na : dxyDir * zD5
float yldE5 = na(zY5) ? na : yldDir * zY5
float oilE5 = na(zO5) ? na : oilDir * zO5
float dxyE15 = na(zD15) ? na : dxyDir * zD15
float yldE15 = na(zY15) ? na : yldDir * zY15
float oilE15 = na(zO15) ? na : oilDir * zO15
float dxyE60 = na(zD60) ? na : dxyDir * zD60
float yldE60 = na(zY60) ? na : yldDir * zY60
float oilE60 = na(zO60) ? na : oilDir * zO60
float dxyE240 = na(zD240) ? na : dxyDir * zD240
float yldE240 = na(zY240) ? na : yldDir * zY240
float oilE240 = na(zO240) ? na : oilDir * zO240

bool dOn = not na(dxyE1) and math.abs(dxyE1) >= moveThr
bool yOn = not na(yldE1) and math.abs(yldE1) >= moveThr
bool oOn = oilDir != 0.0 and not na(oilE1) and math.abs(oilE1) >= moveThr
bool split = dOn and yOn and (dxyE1 > 0.0) != (yldE1 > 0.0)

int side = 0
float num = 0.0
float den = 0.0
string who = ""
if not split
    if dOn
        side := dxyE1 > 0.0 ? 1 : -1
        num := num + wDxy * dxyE1
        den := den + wDxy
        who := "DXY"
    if yOn and (side == 0 or (yldE1 > 0.0 ? 1 : -1) == side)
        side := yldE1 > 0.0 ? 1 : -1
        num := num + wYld * yldE1
        den := den + wYld
        who := who == "" ? "YIELD" : who + "+YLD"
    if oOn and (side == 0 or (oilE1 > 0.0 ? 1 : -1) == side)
        side := oilE1 > 0.0 ? 1 : -1
        num := num + wOil * oilE1
        den := den + wOil
        who := who == "" ? "OIL" : who + "+OIL"

float push = den > 0.0 ? num / den : na
float gap = na(push) or na(zG1) ? na : push - zG1
float room = na(gap) or side == 0 ? 0.0 : side == 1 and gap > 0.0 ? gap : side == -1 and gap < 0.0 ? gap : 0.0

float fightThr = 1.0
int s5 = sideOf(dxyE5, yldE5, oilE5, fightThr, oilDir)
int s15 = sideOf(dxyE15, yldE15, oilE15, fightThr, oilDir)
int s60 = sideOf(dxyE60, yldE60, oilE60, fightThr, oilDir)
int s240 = sideOf(dxyE240, yldE240, oilE240, fightThr, oilDir)
bool oppose = side != 0 and ((s5 != 0 and s5 != side) or (s15 != 0 and s15 != side))

var bool breakOn = false
if not na(corrD15)
    if corrD15 >= breakThr
        breakOn := true
    else if corrD15 <= breakThr - breakBand
        breakOn := false

bool roomOpen = side != 0 and not split and math.abs(room) >= openThr
bool enterLong = roomOpen and side == 1 and not oppose and not breakOn
bool enterShort = roomOpen and side == -1 and not oppose and not breakOn
bool against = roomOpen and oppose and not breakOn
bool priced = side != 0 and not split and not breakOn and not roomOpen
bool unclear = side == 0 and not split and not breakOn and not na(zG1) and math.abs(zG1) >= moveThr
bool fixD = bar_index > 300 and na(zD1)
bool fixY = bar_index > 300 and na(zY1)

string ctx = ""
if side != 0
    if s5 != 0 and s5 != side
        ctx := "vs 5m"
    else if s15 != 0 and s15 != side
        ctx := "vs 15m"
    else if s60 != 0 and s60 != side
        ctx := "vs 1h"
    else if s240 != 0 and s240 != side
        ctx := "vs 4h"
    else if s15 == side
        ctx := s60 == side ? "15m+1h" : "with 15m"
    else if s5 == side
        ctx := "with 5m"
    else if s60 == side
        ctx := "with 1h"
    else if s240 == side
        ctx := "with 4h"
    else
        ctx := "1m only"

string banner = fixD ? "FIX DOLLAR" : fixY ? "FIX YIELD" : breakOn ? "UNSTABLE" : split ? "SPLIT" : enterLong ? "ENTER LONG" : enterShort ? "ENTER SHORT" : against ? "AGAINST" : priced ? "PRICED" : unclear ? "UNCLEAR" : "FLAT"
string tag = banner == "UNCLEAR" ? "no macro" : banner == "UNSTABLE" ? "together" : banner == "SPLIT" ? "DXY vs yield" : who == "" ? ctx : ctx == "" ? who : who + " " + ctx

inSess = not useSess or not na(time(timeframe.period, sess, "America/New_York"))
var int lastBar = na
bool coolOk = na(lastBar) ? true : bar_index - lastBar >= coolBars
bool longFire = barstate.isconfirmed and coolOk and inSess and enterLong and not enterLong[1]
bool shortFire = barstate.isconfirmed and coolOk and inSess and enterShort and not enterShort[1] and not longFire
if longFire or shortFire
    lastBar := bar_index

upC   = color.rgb(8, 153, 129)
dnC   = color.rgb(242, 54, 69)
muteC = color.rgb(130, 134, 145)
panel = color.rgb(14, 16, 20)
float dead = 0.20
float goldTape = na(zG1) or math.abs(zG1) < dead ? 0.0 : zG1
float shown = breakOn or unclear ? goldTape : math.abs(room) < dead ? 0.0 : room
color expCol = breakOn or unclear ? muteC : enterLong ? upC : enterShort ? dnC : shown > 0.0 ? color.new(upC, 45) : shown < 0.0 ? color.new(dnC, 45) : color.new(muteC, 55)

var float holdDxy = na
var float holdYld = na
var float holdOil = na
var float holdLinkD = na
var float holdLinkY = na
var float holdLinkO = na
var float holdOilDir = 0.0
var float holdShown = 0.0
var string holdBanner = "FLAT"
var string holdTag = ""
var bool holdLong = false
var bool holdShort = false
var color holdCol = color.new(color.gray, 55)
if barstate.isconfirmed
    holdDxy := dxyE1
    holdYld := yldE1
    holdOil := oilE1
    holdLinkD := linkD
    holdLinkY := linkY
    holdLinkO := linkO
    holdOilDir := oilDir
    holdShown := shown
    holdBanner := banner
    holdTag := tag
    holdLong := enterLong
    holdShort := enterShort
    holdCol := expCol

plot(holdShown, "Room left", style=plot.style_columns, color=holdCol, linewidth=2)
plot(0.0, "Zero", color=color.new(muteC, 55), display=display.pane)

meter(float z) =>
    float mag = na(z) ? 0.0 : math.min(math.abs(z), 2.5) / 2.5 * 8.0
    int n = math.round(mag)
    n := math.min(8, math.max(0, n))
    string s = ""
    for k = 1 to 8
        s := s + (k <= n ? "█" : "░")
    s

sgn(float z) =>
    na(z) ? "-" : (z > 0.0 ? "+" : "") + str.tostring(z, "#.#")

tone(float z) =>
    na(z) or z == 0.0 ? muteC : z > 0.0 ? upC : dnC

linkWord(float c) =>
    na(c) ? "prior" : math.abs(c) < 0.12 ? "mixed" : c < 0.0 ? "inverse" : "with"

fmt(x) =>
    na(x) ? "-" : str.tostring(x, "#.#")

var table pan = table.new(position.top_right, 4, 4, bgcolor=panel, border_width=0, frame_width=0, force_overlay=true)

nameCell(int row, string txt) =>
    table.cell(pan, 0, row, txt, text_color=muteC, text_size=size.small, text_halign=text.align_left, bgcolor=panel)
linkCell(int row, string txt) =>
    table.cell(pan, 1, row, txt, text_color=muteC, text_size=size.small, text_halign=text.align_left, bgcolor=panel)
barCell(int row, string txt, color c) =>
    table.cell(pan, 2, row, txt, text_color=c, text_size=size.small, text_halign=text.align_left, bgcolor=panel)
numCell(int row, string txt, color c) =>
    table.cell(pan, 3, row, txt, text_color=c, text_size=size.small, text_halign=text.align_right, bgcolor=panel)

if barstate.islast
    nameCell(0, "DXY")
    linkCell(0, linkWord(holdLinkD))
    barCell(0, meter(holdDxy), tone(holdDxy))
    numCell(0, sgn(holdDxy), tone(holdDxy))
    nameCell(1, "US10Y")
    linkCell(1, linkWord(holdLinkY))
    barCell(1, meter(holdYld), tone(holdYld))
    numCell(1, sgn(holdYld), tone(holdYld))
    nameCell(2, "OIL")
    linkCell(2, holdOilDir == 0.0 ? "flat" : linkWord(holdLinkO))
    barCell(2, meter(holdOil), tone(holdOil))
    numCell(2, holdOilDir == 0.0 ? "flat" : sgn(holdOil), tone(holdOil))
    color callC = holdLong ? upC : holdShort ? dnC : muteC
    nameCell(3, "NOW")
    linkCell(3, holdTag)
    barCell(3, meter(holdShown), callC)
    table.cell(pan, 3, 3, holdBanner, text_color=callC, text_size=size.normal, text_halign=text.align_right, bgcolor=panel)

if longFire
    string msg = "Gold still behind. Enter long. " + tag + ". Room " + fmt(room)
    alert(msg, alert.freq_once_per_bar_close)

if shortFire
    string msg = "Gold still behind. Enter short. " + tag + ". Room " + fmt(room)
    alert(msg, alert.freq_once_per_bar_close)

alertcondition(longFire, "Enter long", "A fast macro push is gold-bullish and gold has not caught up.")
alertcondition(shortFire, "Enter short", "A fast macro push is gold-bearish and gold has not caught up.")
````
