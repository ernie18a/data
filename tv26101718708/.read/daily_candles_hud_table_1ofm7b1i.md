# Daily Candles HUD - Table

- url: https://www.tradingview.com/script/1OFM7B1i-Daily-Candles-HUD-Table/
- type: indicator
- pine_id: PUB;c677e54017ca438ea3ab73b4cb541b32
- version: 1.0

## Description

A fixed-position visual dashboard that displays current and previous daily candles in a structured table format, solving the limitations of traditional floating HUDs that move with price action or lose alignment over time.

This tool provides a stable, always-visible candle comparison without interfering with chart readability or requiring manual repositioning.

[b]Why This Version[/b]

Traditional HUD-based candle overlays can become misaligned as price moves or when pinned to fixed coordinates. This table-based approach solves that by keeping the visual structure locked in place at all times.

[b]Displayed Data[/b]

[list]
[*] [b]Current Day Candle[/b] (Open, High, Low, Close)
[*] [b]Previous Day Candle[/b]
[*] [b]Optional Second Previous Day Candle[/b] (3-candle mode)
[/list]

[b]Features[/b]

[list]
[*] Fully fixed-position visual dashboard (no drift with price movement).
[*] Clean table-based candle rendering for maximum stability.
[*] 2-candle and 3-candle comparison modes.
[*] Color-coded bullish, bearish and doji candle states.
[*] Accurate wick and body representation inside a grid structure.
[*] Adjustable vertical and horizontal placement.
[*] Configurable spacing, body size and wick thickness.
[*] Intraday-only optimized rendering for performance and clarity.
[/list]

## Source Code

````pine
//@version=6
indicator("Daily Candles HUD - Table", overlay = true)

// ==========================================
// USER INPUTS
// ==========================================
gp_config = "Configuration"
viewMode  = input.string("3 Candles", "View Mode", options=["2 Candles", "3 Candles"], group=gp_config)

gp_visual = "Visual Settings"
bullCol   = input.color(#089981, "Bullish Color", group=gp_visual)
bearCol   = input.color(#f23645, "Bearish Color", group=gp_visual)
wickCol   = input.color(color.new(color.black, 40), "Wicks Color", group=gp_visual)
dojiCol   = input.color(color.black, "Doji Color", group=gp_visual)

gp_dim    = "Dimensions"
cellH     = input.float(0.3, "Cell Height", step=0.01, group=gp_dim)
bodyW     = input.float(0.6, "Body Width", step=0.1, group=gp_dim)
wickW     = input.float(0.06, "Wick Width", step=0.1, group=gp_dim)
spacingW  = input.float(0.5, "Space Between Candles", step=0.1, group=gp_dim)

gp_ui     = "Position & Margin"
posV      = input.string("top", "Vertical Position", options=["top", "middle", "bottom"], group=gp_ui)
posH      = input.string("right", "Horizontal Position", options=["left", "center", "right"], group=gp_ui)
topMargin = input.int(20, "Top Margin (Rows)", minval=0, group=gp_ui)

// ==========================================
// DATA FETCHING
// ==========================================
[yyO, yyH, yyL, yyC] = request.security(syminfo.tickerid, "D", [open[2], high[2], low[2], close[2]], lookahead = barmerge.lookahead_on)
[yO, yH, yL, yC]     = request.security(syminfo.tickerid, "D", [open[1], high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[dO, dH, dL, dC]     = request.security(syminfo.tickerid, "D", [open, high, low, close], lookahead = barmerge.lookahead_on)

// ==========================================
// CORE RENDERER
// ==========================================
if barstate.islast
    int res       = 60 
    int totalRows = res + topMargin
    bool is3      = viewMode == "3 Candles"
    int totalCols = is3 ? 11 : 7
    
    var table hud = table.new(posV + "_" + posH, totalCols, totalRows, border_width = 0)
    table.clear(hud, 0, 0, totalCols - 1, totalRows - 1)

    float gMax = is3 ? math.max(dH, yH, yyH) : math.max(dH, yH)
    float gMin = is3 ? math.min(dL, yL, yyL) : math.min(dL, yL)
    float span = gMax - gMin
    string inv = " " 

    if timeframe.isintraday and span > 0
        float stepSize = span / res
        
        // --- FIXED COLOR LOGIC (Based on ORIGINAL prices) ---
        color finalYYCol = yyC > yyO ? bullCol : (yyC < yyO ? bearCol : dojiCol)
        color finalYCol  = yC > yO   ? bullCol : (yC < yO   ? bearCol : dojiCol)
        color finalDCol  = dC > dO   ? bullCol : (dC < dO   ? bearCol : dojiCol)

        // --- FIXED CONNECTION LOGIC ---
        float gapFactor = 1.1 
        
        // 1. Yesterday (Y) relative to (YY)
        float v_yO = yO
        if is3
            bool yyBull = yyC >= yyO
            bool yBull  = yC >= yO
            if math.abs(v_yO - yyC) < stepSize
                if (yyBull and not yBull) or (not yyBull and yBull) 
                    v_yO := yyC
                else if yyBull and yBull 
                    v_yO := yyC + (stepSize * gapFactor)
                else 
                    v_yO := yyC - (stepSize * gapFactor)

        // 2. Today (D) relative to (Y)
        float v_dO = dO
        bool prevBull = yC >= v_yO
        bool currBull = dC >= dO
        if math.abs(v_dO - yC) < stepSize
            if (not prevBull and currBull) or (prevBull and not currBull)
                v_dO := yC
            else if (prevBull and currBull) 
                v_dO := yC + (stepSize * gapFactor)
            else 
                v_dO := yC - (stepSize * gapFactor)

        // --- RENDER LOOP ---
        for i = 0 to res - 1
            float t = gMax - (i * stepSize)
            float b = gMax - ((i + 1) * stepSize)
            int r   = topMargin + i

            // Detection
            bool isYYB = (math.max(yyO, yyC) >= b and math.min(yyO, yyC) <= t)
            bool isYYW = yyH >= b and yyL <= t
            bool isYB  = (math.max(v_yO, yC) >= b and math.min(v_yO, yC) <= t)
            bool isYW  = yH >= b and yL <= t
            bool isDB  = (math.max(v_dO, dC) >= b and math.min(v_dO, dC) <= t)
            bool isDW  = dH >= b and dL <= t

            // Cell Coloring Logic using Pre-calculated colors
            color resYYB = isYYB ? finalYYCol : color.new(color.white, 100)
            color resYYW = isYYB ? finalYYCol : (isYYW ? wickCol : color.new(color.white, 100))
            color resYB  = isYB  ? finalYCol  : color.new(color.white, 100)
            color resYW  = isYB  ? finalYCol  : (isYW  ? wickCol : color.new(color.white, 100))
            color resDB  = isDB  ? finalDCol  : color.new(color.white, 100)
            color resDW  = isDB  ? finalDCol  : (isDW  ? wickCol : color.new(color.white, 100))

            if is3
                table.cell(hud, 0, r, inv, bgcolor=resYYB, width=bodyW, height=cellH)
                table.cell(hud, 1, r, inv, bgcolor=resYYW, width=wickW, height=cellH)
                table.cell(hud, 2, r, inv, bgcolor=resYYB, width=bodyW, height=cellH)
                table.cell(hud, 3, r, inv, width=spacingW, height=cellH)
                table.cell(hud, 4, r, inv, bgcolor=resYB, width=bodyW, height=cellH)
                table.cell(hud, 5, r, inv, bgcolor=resYW, width=wickW, height=cellH)
                table.cell(hud, 6, r, inv, bgcolor=resYB, width=bodyW, height=cellH)
                table.cell(hud, 7, r, inv, width=spacingW, height=cellH)
                table.cell(hud, 8, r, inv, bgcolor=resDB, width=bodyW, height=cellH)
                table.cell(hud, 9, r, inv, bgcolor=resDW, width=wickW, height=cellH)
                table.cell(hud, 10, r, inv, bgcolor=resDB, width=bodyW, height=cellH)
            else
                table.cell(hud, 0, r, inv, bgcolor=resYB, width=bodyW, height=cellH)
                table.cell(hud, 1, r, inv, bgcolor=resYW, width=wickW, height=cellH)
                table.cell(hud, 2, r, inv, bgcolor=resYB, width=bodyW, height=cellH)
                table.cell(hud, 3, r, inv, width=spacingW, height=cellH)
                table.cell(hud, 4, r, inv, bgcolor=resDB, width=bodyW, height=cellH)
                table.cell(hud, 5, r, inv, bgcolor=resDW, width=wickW, height=cellH)
                table.cell(hud, 6, r, inv, bgcolor=resDB, width=bodyW, height=cellH)

    // --- MARGIN ---
    if topMargin > 0
        for m = 0 to topMargin - 1
            for col = 0 to totalCols - 1
                float w = is3 ? ((col==1 or col==5 or col==9) ? wickW : (col==3 or col==7) ? spacingW : bodyW) : ((col==1 or col==5) ? wickW : (col==3) ? spacingW : bodyW)
                table.cell(hud, col, m, inv, width=w, height=cellH)
````
