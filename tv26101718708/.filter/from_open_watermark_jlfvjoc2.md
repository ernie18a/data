# % From Open Watermark

- url: https://www.tradingview.com/script/Jlfvjoc2-From-Open-Watermark/
- type: indicator
- pine_id: PUB;2e958c7b44074c48a090781c6be0282a
- version: 3.0

## Description

% From Open Watermark displays the current percentage change from the session open as a large, semi-transparent watermark overlaid on your chart. It calculates the move from the daily, weekly, or monthly open (your choice) to the current close and updates in real time as price moves. The text color shifts automatically, turning green when you're up on the session, red when you're down, and gray when flat. This gives you an at-a-glance read on session performance without having to do mental math or glance at a separate panel.

The watermark is fully customizable. Place it in any of nine positions on the chart (top, middle, or bottom paired with left, center, or right), choose from six text sizes including an auto-scaling option, and adjust the transparency and colors to match your chart theme. You can toggle the leading "+" sign on positive moves and set decimal precision from 0 to 4 places. Because it renders as a positioned table rather than a price-anchored label, it stays put as you scroll and zoom, just like a real watermark.

## Source Code

````pine
//@version=6
indicator("% Change Watermark", overlay = true, max_bars_back = 5000)

// ─── Inputs ───────────────────────────────────────────────────────────────
grpPos     = "Position"
autoPos    = input.bool(true, "Auto-position (avoid candles)", group = grpPos)
posV       = input.string("top",   "Vertical (manual / tie-break)",   options = ["top", "middle", "bottom"], group = grpPos)
posH       = input.string("right", "Horizontal (manual / tie-break)", options = ["left", "center", "right"], group = grpPos)
botPenalty = input.float(0.30, "Bottom row penalty", minval = 0, step = 0.05, tooltip = "Extra weight on the bottom row to avoid overlaid volume bars. 0 = none.", group = grpPos)
ctrPenalty = input.float(0.30, "Center penalty", minval = 0, step = 0.05, tooltip = "Extra weight on middle-center to avoid the symbol watermark. 0 = none.", group = grpPos)
stickiness = input.float(0.10, "Stickiness", minval = 0, maxval = 1, step = 0.05, tooltip = "Only move when another spot is emptier by this fraction. Prevents jumping on live ticks.", group = grpPos)

grpStyle  = "Style"
txtSize   = input.string("huge", "Text Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = grpStyle)
boldTxt   = input.bool(true, "Bold text", group = grpStyle)
upColor   = input.color(color.new(color.green, 30), "Up Color",   group = grpStyle)
dnColor   = input.color(color.new(color.red,   30), "Down Color", group = grpStyle)
flatColor = input.color(color.new(color.gray,  30), "Flat Color", group = grpStyle)
showBg    = input.bool(true, "Background box", group = grpStyle)
bgCol     = input.color(color.new(#131722, 35), "Background Color", group = grpStyle)
showSign  = input.bool(true, "Show + sign on gains", group = grpStyle)
decimals  = input.int(2, "Decimal places", minval = 0, maxval = 4, group = grpStyle)

grpData   = "Data"
reference = input.string("Open", "Reference Price", options = ["Open", "Previous Close"], tooltip = "Open = current session open, Previous Close = prior session close", group = grpData)
session   = input.string("D", "Session", options = ["D", "W", "M"], tooltip = "D = Daily, W = Weekly, M = Monthly", group = grpData)

// ─── Calculate reference price and % change ───────────────────────────────
float openPrice = request.security(syminfo.tickerid, session, open,     lookahead = barmerge.lookahead_on)
float prevClose = request.security(syminfo.tickerid, session, close[1], lookahead = barmerge.lookahead_on)

float refPrice  = reference == "Open" ? openPrice : prevClose
float pctChange = (close - refPrice) / refPrice * 100

// ─── Format text ──────────────────────────────────────────────────────────
string fmt     = decimals == 0 ? "0" : "0." + str.repeat("0", decimals)
string sign    = showSign and pctChange > 0 ? "+" : ""
string pctText = sign + str.tostring(pctChange, fmt) + "%"

color txtColor = pctChange > 0 ? upColor : pctChange < 0 ? dnColor : flatColor

txtSizeF = switch txtSize
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    "huge"   => size.huge
    => size.auto

// ─── Grid helpers (cell = row * 3 + col, row 0 = top, col 0 = left) ──────
var positions = array.from(position.top_left,    position.top_center,    position.top_right,
                           position.middle_left, position.middle_center, position.middle_right,
                           position.bottom_left, position.bottom_center, position.bottom_right)

int rowIdx     = posV == "top" ? 0 : posV == "middle" ? 1 : 2
int colIdx     = posH == "left" ? 0 : posH == "center" ? 1 : 2
int manualCell = rowIdx * 3 + colIdx

// ─── Track visible range ──────────────────────────────────────────────────
var int leftIdx  = na
var int rightIdx = na
if time == chart.left_visible_bar_time
    leftIdx := bar_index
if time == chart.right_visible_bar_time
    rightIdx := bar_index

varip int curCell = na
if na(curCell)
    curCell := manualCell

// ─── Pick the emptiest cell ───────────────────────────────────────────────
if barstate.islast and autoPos
    int lIdx     = na(leftIdx)  ? 0         : leftIdx
    int rIdx     = na(rightIdx) ? bar_index : rightIdx
    int startOff = bar_index - rIdx
    int endOff   = math.min(bar_index - lIdx, 4999)
    int n        = endOff - startOff + 1

    if n > 2
        float hi = high[startOff]
        float lo = low[startOff]
        for i = startOff to endOff
            hi := math.max(hi, high[i])
            lo := math.min(lo, low[i])
        float rng = hi - lo

        if rng > 0
            occ = array.new_float(9, 0.0)
            for i = startOff to endOff
                int p    = endOff - i                        // 0 = leftmost visible bar
                int col  = math.min(2, math.floor(p * 3.0 / n))
                int rTop = math.min(2, math.floor((hi - high[i]) / rng * 3))
                int rBot = math.min(2, math.floor((hi - low[i])  / rng * 3))
                for r = rTop to rBot
                    int c = r * 3 + col
                    occ.set(c, occ.get(c) + 1)

            // Normalize to fraction of bars per column, then apply penalties
            float perCol = n / 3.0
            for c = 0 to 8
                float v = occ.get(c) / perCol
                if c >= 6
                    v += botPenalty
                if c == 4
                    v += ctrPenalty
                occ.set(c, v)

            // Stay put unless another cell is clearly emptier
            int best = curCell
            for c = 0 to 8
                if occ.get(c) < occ.get(best) - stickiness
                    best := c
            curCell := best

// ─── Draw watermark ───────────────────────────────────────────────────────
var table watermark = table.new(position.top_right, 1, 1)

if barstate.islast
    int cell = autoPos ? curCell : manualCell
    watermark.set_position(positions.get(cell))
    watermark.cell(0, 0, pctText,
         text_color      = txtColor,
         text_size       = txtSizeF,
         text_formatting = boldTxt ? text.format_bold : text.format_none,
         bgcolor         = showBg ? bgCol : na)
````
