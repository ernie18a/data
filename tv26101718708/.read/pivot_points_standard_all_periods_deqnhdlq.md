# Pivot Points Standard (All Periods)

- url: https://www.tradingview.com/script/DeQnhDLq/
- type: indicator
- pine_id: PUB;59f336a24880497690a15e3f80df3ed3
- version: 1.0

## Description

使って

## Source Code

````pine
//@version=5
indicator("Pivot Points Standard (All Periods)", overlay=true, max_lines_count=500, max_labels_count=500)

// === 入力 ===
showD = input.bool(true,  "Show Daily Pivots")
showW = input.bool(true,  "Show Weekly Pivots")
showM = input.bool(true,  "Show Monthly Pivots")
showY = input.bool(true,  "Show Yearly Pivots")

lookback   = input.int(3, "Pivots to Show (incl. current)", minval=1, maxval=100)
showLabels = input.bool(true, "Show Labels")
showPrices = input.bool(true, "Show Prices")

// === アラート設定 ===
alertOn   = input.bool(true,  "Enable Breakout Alerts")
breakPips = input.float(3.0,  "Breakout Pips", minval=0.1, step=0.5)
alertOnClose = input.bool(true, "Confirm on Bar Close (else fire intrabar)")

// === 期間ごとの線の太さ ===
widthDaily   = input.int(1, "Daily Line Width",   minval=1, maxval=10)
widthWeekly  = input.int(2, "Weekly Line Width",  minval=1, maxval=10)
widthMonthly = input.int(3, "Monthly Line Width", minval=1, maxval=10)
widthYearly  = input.int(5, "Yearly Line Width",  minval=1, maxval=10)

// === 期間ごとの色 ===
colDaily   = input.color(#ff4d4d, "Daily Color")
colWeekly  = input.color(#ffeb3b, "Weekly Color")
colMonthly = input.color(#00e5ff, "Monthly Color")
colYearly  = input.color(#76ff03, "Yearly Color")

// === Pivot 計算 ===
calcPivots(h, l, c) =>
    p  = (h + l + c) / 3
    r1 = p * 2 - l
    s1 = p * 2 - h
    r2 = p + (h - l)
    s2 = p - (h - l)
    r3 = h + 2 * (p - l)
    s3 = l - 2 * (h - p)
    [p, r1, s1, r2, s2, r3, s3]

// === ラベル描画ヘルパ ===
addLabel(int xPos, float price, color col, string txt, label[] arr) =>
    if showLabels
        labTxt = showPrices ? txt + " " + str.tostring(price, format.mintick) : txt
        lbl = label.new(xPos, price, labTxt, xloc=xloc.bar_time, style=label.style_none, textcolor=col, size=size.large)
        array.push(arr, lbl)

// === アラート発火ヘルパ ===
fireAlert(string msg) =>
    freq = alertOnClose ? alert.freq_once_per_bar_close : alert.freq_once_per_bar
    alert(msg, freq)

// === 期間ごとの処理 ===
processPivots(string tf, bool enabled, string prefix, color col, int lw, line[] aP, line[] aR1, line[] aS1, line[] aR2, line[] aS2, line[] aR3, line[] aS3, float[] fP, float[] fR1, float[] fS1, float[] fR2, float[] fS2, float[] fR3, float[] fS3, label[] aLab) =>
    [htfH, htfL, htfC, htfT] = request.security(syminfo.tickerid, tf, [high[1], low[1], close[1], time[1]], lookahead=barmerge.lookahead_on)
    [P, R1, S1, R2, S2, R3, S3] = calcPivots(htfH, htfL, htfC)
    isNew = ta.change(htfT) != 0

    var int curStart = na
    var float vP = na
    var float vR1 = na
    var float vS1 = na
    var float vR2 = na
    var float vS2 = na
    var float vR3 = na
    var float vS3 = na

    var line eP = na
    var line eR1 = na
    var line eS1 = na
    var line eR2 = na
    var line eS2 = na
    var line eR3 = na
    var line eS3 = na

    if enabled and isNew and not na(htfT)
        if not na(curStart) and not na(vP) and lookback > 1
            array.push(aP,  line.new(curStart, vP,  time, vP,  xloc=xloc.bar_time, color=col, width=lw))
            array.push(aR1, line.new(curStart, vR1, time, vR1, xloc=xloc.bar_time, color=col, width=lw))
            array.push(aS1, line.new(curStart, vS1, time, vS1, xloc=xloc.bar_time, color=col, width=lw))
            array.push(aR2, line.new(curStart, vR2, time, vR2, xloc=xloc.bar_time, color=col, width=lw))
            array.push(aS2, line.new(curStart, vS2, time, vS2, xloc=xloc.bar_time, color=col, width=lw))
            array.push(aR3, line.new(curStart, vR3, time, vR3, xloc=xloc.bar_time, color=col, width=lw))
            array.push(aS3, line.new(curStart, vS3, time, vS3, xloc=xloc.bar_time, color=col, width=lw))
            array.push(fP,  vP)
            array.push(fR1, vR1)
            array.push(fS1, vS1)
            array.push(fR2, vR2)
            array.push(fS2, vS2)
            array.push(fR3, vR3)
            array.push(fS3, vS3)
            if array.size(aP) > lookback - 1
                line.delete(array.shift(aP))
                line.delete(array.shift(aR1))
                line.delete(array.shift(aS1))
                line.delete(array.shift(aR2))
                line.delete(array.shift(aS2))
                line.delete(array.shift(aR3))
                line.delete(array.shift(aS3))
                array.shift(fP)
                array.shift(fR1)
                array.shift(fS1)
                array.shift(fR2)
                array.shift(fS2)
                array.shift(fR3)
                array.shift(fS3)
        curStart := time
        vP  := P
        vR1 := R1
        vS1 := S1
        vR2 := R2
        vS2 := S2
        vR3 := R3
        vS3 := S3

    if enabled and barstate.islast and not na(curStart) and not na(vP)
        line.delete(eP)
        line.delete(eR1)
        line.delete(eS1)
        line.delete(eR2)
        line.delete(eS2)
        line.delete(eR3)
        line.delete(eS3)
        rightT = time + (time - time[1]) * 10
        eP  := line.new(curStart, vP,  rightT, vP,  xloc=xloc.bar_time, color=col, width=lw)
        eR1 := line.new(curStart, vR1, rightT, vR1, xloc=xloc.bar_time, color=col, width=lw)
        eS1 := line.new(curStart, vS1, rightT, vS1, xloc=xloc.bar_time, color=col, width=lw)
        eR2 := line.new(curStart, vR2, rightT, vR2, xloc=xloc.bar_time, color=col, width=lw)
        eS2 := line.new(curStart, vS2, rightT, vS2, xloc=xloc.bar_time, color=col, width=lw)
        eR3 := line.new(curStart, vR3, rightT, vR3, xloc=xloc.bar_time, color=col, width=lw)
        eS3 := line.new(curStart, vS3, rightT, vS3, xloc=xloc.bar_time, color=col, width=lw)

        while array.size(aLab) > 0
            label.delete(array.shift(aLab))

        n = array.size(aP)
        if n > 0
            for i = 0 to n - 1
                startT = line.get_x1(array.get(aP, i))
                addLabel(startT, array.get(fP,  i), col, prefix+"P",  aLab)
                addLabel(startT, array.get(fR1, i), col, prefix+"R1", aLab)
                addLabel(startT, array.get(fS1, i), col, prefix+"S1", aLab)
                addLabel(startT, array.get(fR2, i), col, prefix+"R2", aLab)
                addLabel(startT, array.get(fS2, i), col, prefix+"S2", aLab)
                addLabel(startT, array.get(fR3, i), col, prefix+"R3", aLab)
                addLabel(startT, array.get(fS3, i), col, prefix+"S3", aLab)

        addLabel(curStart, vP,  col, prefix+"P",  aLab)
        addLabel(curStart, vR1, col, prefix+"R1", aLab)
        addLabel(curStart, vS1, col, prefix+"S1", aLab)
        addLabel(curStart, vR2, col, prefix+"R2", aLab)
        addLabel(curStart, vS2, col, prefix+"S2", aLab)
        addLabel(curStart, vR3, col, prefix+"R3", aLab)
        addLabel(curStart, vS3, col, prefix+"S3", aLab)

    // === 貫通アラート判定 ===
    breakDist = breakPips * syminfo.mintick * 10

    upP  = not na(vP)  and ta.crossover(close,  vP  + breakDist)
    dnP  = not na(vP)  and ta.crossunder(close, vP  - breakDist)
    upR1 = not na(vR1) and ta.crossover(close,  vR1 + breakDist)
    dnR1 = not na(vR1) and ta.crossunder(close, vR1 - breakDist)
    upS1 = not na(vS1) and ta.crossover(close,  vS1 + breakDist)
    dnS1 = not na(vS1) and ta.crossunder(close, vS1 - breakDist)
    upR2 = not na(vR2) and ta.crossover(close,  vR2 + breakDist)
    dnR2 = not na(vR2) and ta.crossunder(close, vR2 - breakDist)
    upS2 = not na(vS2) and ta.crossover(close,  vS2 + breakDist)
    dnS2 = not na(vS2) and ta.crossunder(close, vS2 - breakDist)
    upR3 = not na(vR3) and ta.crossover(close,  vR3 + breakDist)
    dnR3 = not na(vR3) and ta.crossunder(close, vR3 - breakDist)
    upS3 = not na(vS3) and ta.crossover(close,  vS3 + breakDist)
    dnS3 = not na(vS3) and ta.crossunder(close, vS3 - breakDist)

    if enabled and alertOn and not isNew
        sym = syminfo.ticker
        priceStr = str.tostring(close, format.mintick)
        if upP
            fireAlert(sym + " " + prefix + "P 上抜け @ " + priceStr)
        if dnP
            fireAlert(sym + " " + prefix + "P 下抜け @ " + priceStr)
        if upR1
            fireAlert(sym + " " + prefix + "R1 上抜け @ " + priceStr)
        if dnR1
            fireAlert(sym + " " + prefix + "R1 下抜け @ " + priceStr)
        if upS1
            fireAlert(sym + " " + prefix + "S1 上抜け @ " + priceStr)
        if dnS1
            fireAlert(sym + " " + prefix + "S1 下抜け @ " + priceStr)
        if upR2
            fireAlert(sym + " " + prefix + "R2 上抜け @ " + priceStr)
        if dnR2
            fireAlert(sym + " " + prefix + "R2 下抜け @ " + priceStr)
        if upS2
            fireAlert(sym + " " + prefix + "S2 上抜け @ " + priceStr)
        if dnS2
            fireAlert(sym + " " + prefix + "S2 下抜け @ " + priceStr)
        if upR3
            fireAlert(sym + " " + prefix + "R3 上抜け @ " + priceStr)
        if dnR3
            fireAlert(sym + " " + prefix + "R3 下抜け @ " + priceStr)
        if upS3
            fireAlert(sym + " " + prefix + "S3 上抜け @ " + priceStr)
        if dnS3
            fireAlert(sym + " " + prefix + "S3 下抜け @ " + priceStr)

// === Daily ===
var lD_P  = array.new_line()
var lD_R1 = array.new_line()
var lD_S1 = array.new_line()
var lD_R2 = array.new_line()
var lD_S2 = array.new_line()
var lD_R3 = array.new_line()
var lD_S3 = array.new_line()
var fD_P  = array.new_float()
var fD_R1 = array.new_float()
var fD_S1 = array.new_float()
var fD_R2 = array.new_float()
var fD_S2 = array.new_float()
var fD_R3 = array.new_float()
var fD_S3 = array.new_float()
var lD_Lab = array.new_label()
processPivots("D", showD, "D-", colDaily, widthDaily, lD_P, lD_R1, lD_S1, lD_R2, lD_S2, lD_R3, lD_S3, fD_P, fD_R1, fD_S1, fD_R2, fD_S2, fD_R3, fD_S3, lD_Lab)

// === Weekly ===
var lW_P  = array.new_line()
var lW_R1 = array.new_line()
var lW_S1 = array.new_line()
var lW_R2 = array.new_line()
var lW_S2 = array.new_line()
var lW_R3 = array.new_line()
var lW_S3 = array.new_line()
var fW_P  = array.new_float()
var fW_R1 = array.new_float()
var fW_S1 = array.new_float()
var fW_R2 = array.new_float()
var fW_S2 = array.new_float()
var fW_R3 = array.new_float()
var fW_S3 = array.new_float()
var lW_Lab = array.new_label()
processPivots("W", showW, "W-", colWeekly, widthWeekly, lW_P, lW_R1, lW_S1, lW_R2, lW_S2, lW_R3, lW_S3, fW_P, fW_R1, fW_S1, fW_R2, fW_S2, fW_R3, fW_S3, lW_Lab)

// === Monthly ===
var lM_P  = array.new_line()
var lM_R1 = array.new_line()
var lM_S1 = array.new_line()
var lM_R2 = array.new_line()
var lM_S2 = array.new_line()
var lM_R3 = array.new_line()
var lM_S3 = array.new_line()
var fM_P  = array.new_float()
var fM_R1 = array.new_float()
var fM_S1 = array.new_float()
var fM_R2 = array.new_float()
var fM_S2 = array.new_float()
var fM_R3 = array.new_float()
var fM_S3 = array.new_float()
var lM_Lab = array.new_label()
processPivots("M", showM, "M-", colMonthly, widthMonthly, lM_P, lM_R1, lM_S1, lM_R2, lM_S2, lM_R3, lM_S3, fM_P, fM_R1, fM_S1, fM_R2, fM_S2, fM_R3, fM_S3, lM_Lab)

// === Yearly ===
var lY_P  = array.new_line()
var lY_R1 = array.new_line()
var lY_S1 = array.new_line()
var lY_R2 = array.new_line()
var lY_S2 = array.new_line()
var lY_R3 = array.new_line()
var lY_S3 = array.new_line()
var fY_P  = array.new_float()
var fY_R1 = array.new_float()
var fY_S1 = array.new_float()
var fY_R2 = array.new_float()
var fY_S2 = array.new_float()
var fY_R3 = array.new_float()
var fY_S3 = array.new_float()
var lY_Lab = array.new_label()
processPivots("12M", showY, "Y-", colYearly, widthYearly, lY_P, lY_R1, lY_S1, lY_R2, lY_S2, lY_R3, lY_S3, fY_P, fY_R1, fY_S1, fY_R2, fY_S2, fY_R3, fY_S3, lY_Lab)
````
