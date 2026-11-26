# Strat Market Scanner Pro v6

- url: https://www.tradingview.com/script/VK9gGdeA-Strat-Market-Scanner-Pro-v6/
- type: indicator
- pine_id: PUB;16418c878f524626aaf6b775e5381be8
- version: 1.0

## Description

Scan multiple stocks in real time for high-probability Strat setups including 2-1-2, 3-1-2, 2-2, 1-2, 1-3, 3-2, 2-1-1, and 3-2-1 patterns. The scanner automatically calculates entry, stop loss, target levels, higher timeframe continuity (1H, 4H, Daily, Weekly), and grades each setup from A+ to C based on alignment and volume confirmation.

Features:
• Multi-symbol Strat pattern scanner
• Real-time setup detection
• Entry, stop, and target calculations
• HTF continuity scoring (up to 4/4)
• A+, A, B, and C setup grading
• Volume confirmation filter
• Dynamic alert notifications
• Clean scanner table for rapid trade identification

Designed for traders who use The Strat methodology and want to quickly identify actionable setups across multiple tickers without manually reviewing every chart.

## Source Code

````pine
//@version=6
indicator("Strat Market Scanner Pro v6", overlay=false, max_labels_count=500)

// === INPUTS ===
scanTF = input.timeframe("60", "Scanner Timeframe")
rr = input.float(2.0, "Risk Reward Target", step=0.25)
minHTFScore = input.int(2, "Minimum HTF Score", minval=0, maxval=4)

useVolumeConfirm = input.bool(true, "Use Volume Confirmation")
volumeLength = input.int(20, "Volume SMA Length")

// === SYMBOLS ===
s1 = input.symbol("SPY", "Symbol 1")
s2 = input.symbol("QQQ", "Symbol 2")
s3 = input.symbol("IWM", "Symbol 3")
s4 = input.symbol("NVDA", "Symbol 4")
s5 = input.symbol("TSLA", "Symbol 5")
s6 = input.symbol("AAPL", "Symbol 6")
s7 = input.symbol("MSFT", "Symbol 7")
s8 = input.symbol("META", "Symbol 8")

// === COLORS ===
bullColor = color.rgb(0, 95, 45)
bearColor = color.rgb(180, 40, 40)
blackBg = color.black
neutralColor = color.gray

// === STRAT PATTERN ENGINE ===
// Pattern IDs:
// 1  = 2-1-2 Bull
// 2  = 2-1-2 Bear
// 3  = 3-1-2 Bull
// 4  = 3-1-2 Bear
// 5  = 2-2 Bull
// 6  = 2-2 Bear
// 7  = 1-2 Bull
// 8  = 1-2 Bear
// 9  = 1-3 Bull
// 10 = 1-3 Bear
// 11 = 3-2 Bull
// 12 = 3-2 Bear
// 13 = 2-1-1 Bull
// 14 = 2-1-1 Bear
// 15 = 3-2-1 Bull
// 16 = 3-2-1 Bear

scanLogic() =>
    inside0 = high <= high[1] and low >= low[1]
    outside0 = high > high[1] and low < low[1]
    twoUp0 = high > high[1] and not (low < low[1])
    twoDown0 = low < low[1] and not (high > high[1])

    inside1 = high[1] <= high[2] and low[1] >= low[2]
    outside1 = high[1] > high[2] and low[1] < low[2]
    twoUp1 = high[1] > high[2] and not (low[1] < low[2])
    twoDown1 = low[1] < low[2] and not (high[1] > high[2])

    outside2 = high[2] > high[3] and low[2] < low[3]
    twoUp2 = high[2] > high[3] and not (low[2] < low[3])
    twoDown2 = low[2] < low[3] and not (high[2] > high[3])

    bull212 = twoDown2 and inside1 and twoUp0
    bear212 = twoUp2 and inside1 and twoDown0

    bull312 = outside2 and inside1 and twoUp0
    bear312 = outside2 and inside1 and twoDown0

    bull22 = twoDown1 and twoUp0
    bear22 = twoUp1 and twoDown0

    bull12 = inside1 and twoUp0
    bear12 = inside1 and twoDown0

    bull13 = inside1 and outside0 and close > open
    bear13 = inside1 and outside0 and close < open

    bull32 = outside1 and twoUp0
    bear32 = outside1 and twoDown0

    bull211 = twoDown2 and inside1 and inside0
    bear211 = twoUp2 and inside1 and inside0

    bull321 = outside2 and twoDown1 and inside0
    bear321 = outside2 and twoUp1 and inside0

    patternId =
         bull212 ? 1 :
         bear212 ? 2 :
         bull312 ? 3 :
         bear312 ? 4 :
         bull22 ? 5 :
         bear22 ? 6 :
         bull12 ? 7 :
         bear12 ? 8 :
         bull13 ? 9 :
         bear13 ? 10 :
         bull32 ? 11 :
         bear32 ? 12 :
         bull211 ? 13 :
         bear211 ? 14 :
         bull321 ? 15 :
         bear321 ? 16 : 0

    dir = patternId == 1 or patternId == 3 or patternId == 5 or patternId == 7 or patternId == 9 or patternId == 11 or patternId == 13 or patternId == 15 ? 1 :
          patternId == 2 or patternId == 4 or patternId == 6 or patternId == 8 or patternId == 10 or patternId == 12 or patternId == 14 or patternId == 16 ? -1 : 0

    entry = dir == 1 ? high : dir == -1 ? low : na
    stop = dir == 1 ? low : dir == -1 ? high : na
    target = dir == 1 ? entry + ((entry - stop) * rr) : dir == -1 ? entry - ((stop - entry) * rr) : na

    volOk = not useVolumeConfirm or volume > ta.sma(volume, volumeLength)

    [patternId, dir, entry, stop, target, volOk]

// === SCANNER CALL ===
scanSymbol(sym) =>
    request.security(sym, scanTF, scanLogic(), barmerge.gaps_off, barmerge.lookahead_off)

// === HTF SCORE ===
htfScore(sym, direction) =>
    d60 = request.security(sym, "60", close >= open ? 1 : -1, barmerge.gaps_off, barmerge.lookahead_off)
    d4h = request.security(sym, "240", close >= open ? 1 : -1, barmerge.gaps_off, barmerge.lookahead_off)
    dd = request.security(sym, "D", close >= open ? 1 : -1, barmerge.gaps_off, barmerge.lookahead_off)
    dw = request.security(sym, "W", close >= open ? 1 : -1, barmerge.gaps_off, barmerge.lookahead_off)

    direction == 0 ? 0 : (d60 == direction ? 1 : 0) + (d4h == direction ? 1 : 0) + (dd == direction ? 1 : 0) + (dw == direction ? 1 : 0)

// === TEXT HELPERS ===
patternText(id) =>
    switch id
        1 => "2-1-2 Bull"
        2 => "2-1-2 Bear"
        3 => "3-1-2 Bull"
        4 => "3-1-2 Bear"
        5 => "2-2 Bull"
        6 => "2-2 Bear"
        7 => "1-2 Bull"
        8 => "1-2 Bear"
        9 => "1-3 Bull"
        10 => "1-3 Bear"
        11 => "3-2 Bull"
        12 => "3-2 Bear"
        13 => "2-1-1 Bull"
        14 => "2-1-1 Bear"
        15 => "3-2-1 Bull"
        16 => "3-2-1 Bear"
        => "-"

grade(score, volOk) =>
    score >= 4 and volOk ? "A+" : score >= 3 ? "A" : score >= 2 ? "B" : "C"

// === SCAN SYMBOLS ===
[p1, d1, e1, sl1, t1, v1] = scanSymbol(s1)
[p2, d2, e2, sl2, t2, v2] = scanSymbol(s2)
[p3, d3, e3, sl3, t3, v3] = scanSymbol(s3)
[p4, d4, e4, sl4, t4, v4] = scanSymbol(s4)
[p5, d5, e5, sl5, t5, v5] = scanSymbol(s5)
[p6, d6, e6, sl6, t6, v6] = scanSymbol(s6)
[p7, d7, e7, sl7, t7, v7] = scanSymbol(s7)
[p8, d8, e8, sl8, t8, v8] = scanSymbol(s8)

score1 = htfScore(s1, d1)
score2 = htfScore(s2, d2)
score3 = htfScore(s3, d3)
score4 = htfScore(s4, d4)
score5 = htfScore(s5, d5)
score6 = htfScore(s6, d6)
score7 = htfScore(s7, d7)
score8 = htfScore(s8, d8)

// === TABLE ===
var table scanner = table.new(position.top_left, 8, 10, border_width=1)

drawHeader() =>
    table.cell(scanner, 0, 0, "Ticker", text_color=color.white, bgcolor=blackBg)
    table.cell(scanner, 1, 0, "Pattern", text_color=color.white, bgcolor=blackBg)
    table.cell(scanner, 2, 0, "Dir", text_color=color.white, bgcolor=blackBg)
    table.cell(scanner, 3, 0, "Grade", text_color=color.white, bgcolor=blackBg)
    table.cell(scanner, 4, 0, "Entry", text_color=color.white, bgcolor=blackBg)
    table.cell(scanner, 5, 0, "SL", text_color=color.white, bgcolor=blackBg)
    table.cell(scanner, 6, 0, "Target", text_color=color.white, bgcolor=blackBg)
    table.cell(scanner, 7, 0, "HTF", text_color=color.white, bgcolor=blackBg)

drawRow(row, sym, patternId, dir, entry, stop, target, score, volOk) =>
    active = dir != 0 and score >= minHTFScore and volOk
    bg = dir == 1 ? bullColor : dir == -1 ? bearColor : neutralColor
    dirTxt = dir == 1 ? "Long" : dir == -1 ? "Short" : "-"

    table.cell(scanner, 0, row, sym, text_color=color.white, bgcolor=active ? bg : blackBg)
    table.cell(scanner, 1, row, active ? patternText(patternId) : "-", text_color=color.white, bgcolor=active ? bg : blackBg)
    table.cell(scanner, 2, row, active ? dirTxt : "-", text_color=color.white, bgcolor=active ? bg : blackBg)
    table.cell(scanner, 3, row, active ? grade(score, volOk) : "-", text_color=color.white, bgcolor=active ? bg : blackBg)
    table.cell(scanner, 4, row, active ? str.tostring(entry, format.mintick) : "-", text_color=color.white, bgcolor=active ? bg : blackBg)
    table.cell(scanner, 5, row, active ? str.tostring(stop, format.mintick) : "-", text_color=color.white, bgcolor=active ? bg : blackBg)
    table.cell(scanner, 6, row, active ? str.tostring(target, format.mintick) : "-", text_color=color.white, bgcolor=active ? bg : blackBg)
    table.cell(scanner, 7, row, active ? str.tostring(score) + "/4" : "-", text_color=color.white, bgcolor=active ? bg : blackBg)

if barstate.islast
    drawHeader()
    drawRow(1, s1, p1, d1, e1, sl1, t1, score1, v1)
    drawRow(2, s2, p2, d2, e2, sl2, t2, score2, v2)
    drawRow(3, s3, p3, d3, e3, sl3, t3, score3, v3)
    drawRow(4, s4, p4, d4, e4, sl4, t4, score4, v4)
    drawRow(5, s5, p5, d5, e5, sl5, t5, score5, v5)
    drawRow(6, s6, p6, d6, e6, sl6, t6, score6, v6)
    drawRow(7, s7, p7, d7, e7, sl7, t7, score7, v7)
    drawRow(8, s8, p8, d8, e8, sl8, t8, score8, v8)

// === ALERT ENGINE ===
sendAlert(sym, patternId, dir, entry, stop, target, score, volOk) =>
    active = dir != 0 and score >= minHTFScore and volOk
    if active and not active[1]
        direction = dir == 1 ? "LONG" : "SHORT"
        msg = "🚨 STRAT SETUP\nTicker: " + sym + "\nPattern: " + patternText(patternId) + "\nDirection: " + direction + "\nTF: " + scanTF + "\nEntry: " + str.tostring(entry, format.mintick) + "\nStop: " + str.tostring(stop, format.mintick) + "\nTarget: " + str.tostring(target, format.mintick) + "\nHTF: " + str.tostring(score) + "/4\nGrade: " + grade(score, volOk)
        alert(msg, alert.freq_once_per_bar_close)

sendAlert(s1, p1, d1, e1, sl1, t1, score1, v1)
sendAlert(s2, p2, d2, e2, sl2, t2, score2, v2)
sendAlert(s3, p3, d3, e3, sl3, t3, score3, v3)
sendAlert(s4, p4, d4, e4, sl4, t4, score4, v4)
sendAlert(s5, p5, d5, e5, sl5, t5, score5, v5)
sendAlert(s6, p6, d6, e6, sl6, t6, score6, v6)
sendAlert(s7, p7, d7, e7, sl7, t7, score7, v7)
sendAlert(s8, p8, d8, e8, sl8, t8, score8, v8)
````
