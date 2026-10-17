# Jurik HiLow Channel Double Smooth

- url: https://www.tradingview.com/script/zrzhDL4F-Jurik-HiLow-Channel-Double-Smooth/
- type: indicator
- pine_id: PUB;99574a85c91c468bba76245ca1a985f3
- version: 1.0

## Description

Jurik's HiLow Channel Double Smoothed adapted into pinescript

## Source Code

````pine
//@version=6
indicator("Jurik HiLow Channel Double Smooth", shorttitle="Jurik HiLow", overlay=true)

show1 = input.bool(true, "Show HiLow 1", inline="1", group="HiLow 1 Settings")
len1 = input.int(10, "Length", inline="1", group="HiLow 1 Settings")
phs1 = input.float(0, "Phase", inline="1", group="HiLow 1 Settings")

show2 = input.bool(false, "Show HiLow 2", inline="2", group="HiLow 2 Settings")
len2 = input.int(20, "Length", inline="2", group="HiLow 2 Settings")
phs2 = input.float(0, "Phase", inline="2", group="HiLow 2 Settings")

show3 = input.bool(false, "Show HiLow 3", inline="3", group="HiLow 3 Settings")
len3 = input.int(30, "Length", inline="3", group="HiLow 3 Settings")
phs3 = input.float(0, "Phase", inline="3", group="HiLow 3 Settings")

col_up = input.color(#00BFFF, "Trend Up Color", group="Colors")
col_dn = input.color(#FF69B4, "Trend Down Color", group="Colors")

f_jurik_volty(float src, float length, float phase) =>
    float safe_len = math.max(length, 1)
    float len1_calc = math.max(math.log(math.sqrt(0.5 * (safe_len - 1))) / math.log(2) + 2, 0)
    float pow1 = math.max(len1_calc - 2, 0.5)
    int avglen = 65
    var float bsmax = src, var float bsmin = src
    var float vsum = 0.0, var float avolty = 0.0
    var float Filt0 = src, var float Det0 = 0.0, var float Det1 = 0.0
    var float jurik = src
    float del1 = src - nz(bsmax[1], src)
    float del2 = src - nz(bsmin[1], src)
    float volty = math.max(math.abs(del1), math.abs(del2))
    float div = 1.0 / (10.0 + 10.0 * (math.max(math.min(safe_len - 10, 100), 0)) / 100.0)
    vsum := nz(vsum[1]) + div * (volty - nz(volty[10]))
    float tempavg = ta.sma(vsum, avglen)
    if bar_index + 1 <= avglen + 1
        avolty := nz(avolty[1]) + 2.0 * (vsum - nz(avolty[1])) / (avglen + 1.0)
    else
        avolty := tempavg
    float dvolty = avolty > 0 ? volty / avolty : 0.0
    dvolty := math.min(math.max(dvolty, 1.0), math.pow(len1_calc, 1.0 / pow1))
    float pow2 = math.pow(dvolty, pow1)
    float len2_calc = math.sqrt(0.5 * (safe_len - 1)) * len1_calc
    float kv = math.pow(len2_calc / (len2_calc + 1.0), math.sqrt(pow2))
    bsmax := del1 > 0 ? src : src - kv * del1
    bsmin := del2 < 0 ? src : src - kv * del2
    float phaseratio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase / 100.0 + 1.5
    float beta = 0.45 * (safe_len - 1) / (0.45 * (safe_len - 1) + 2)
    float alpha = math.pow(beta, pow2)
    Filt0 := (1 - alpha) * src + alpha * nz(Filt0[1])
    Det0 := (src - Filt0) * (1 - beta) + beta * nz(Det0[1])
    float Filt1 = Filt0 + phaseratio * Det0
    Det1 := (Filt1 - nz(jurik[1])) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(Det1[1])
    jurik := nz(jurik[1]) + Det1
    jurik

f_hilow(int len, float phs) =>
    float ds_high = f_jurik_volty(f_jurik_volty(high, len, phs), len, phs)
    float ds_low = f_jurik_volty(f_jurik_volty(low, len, phs), len, phs)
    
    float hiPrice = ds_high[1]
    float loPrice = ds_low[1]
    float clPrice = f_jurik_volty(f_jurik_volty(close, len, phs), len, phs)
    
    var int trend = 0
    if clPrice > hiPrice
        trend := 1
    else if clPrice < loPrice
        trend := -1
        
    float stopLine = trend == -1 ? hiPrice : loPrice
    [stopLine, trend]

[sl1, t1] = f_hilow(len1, phs1)
[sl2, t2] = f_hilow(len2, phs2)
[sl3, t3] = f_hilow(len3, phs3)

plot(show1 ? sl1 : na, "HiLow 1", color=t1 == 1 ? col_up : col_dn, style=plot.style_stepline, linewidth=2)
plot(show2 ? sl2 : na, "HiLow 2", color=t2 == 1 ? col_up : col_dn, style=plot.style_stepline, linewidth=2)
plot(show3 ? sl3 : na, "HiLow 3", color=t3 == 1 ? col_up : col_dn, style=plot.style_stepline, linewidth=2)
````
