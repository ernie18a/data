# CFETS RMB Index  25currencies.2026

- url: https://www.tradingview.com/script/IE8u0Zsi-CFETS-RMB-Index-25currencies-2026/
- type: indicator
- pine_id: PUB;b57ed8768cf24a5cae8b8b1b5fe4da7c
- version: 2.0

## Description

Réplica on Trading View https://www.chinamoney.com.cn/english/bmkidxrud/

## Source Code

````pine
//@version=6
indicator("China CFETS RMB Index", overlay = false, precision = 3)

useCustomAnchor = input.bool(true,   "Ancrer sur une date précise (sinon : 1er bar = ancre)")
anchorValue     = input.float(100.0, "Valeur de l'indice à la date d'ancrage")
anchorTime      = input.time(timestamp("2026-01-01T01:00:00"), "Date d'ancrage")

calcTF = timeframe.in_seconds() < 900 ? "15" : timeframe.period

src = close
p_usd = request.security("FX_IDC:USDCNY", calcTF, src)
p_eur = request.security("FX_IDC:EURCNY", calcTF, src)
p_krw = request.security("FX_IDC:KRWCNY", calcTF, src)
p_jpy = request.security("FX_IDC:JPYCNY", calcTF, src)
p_aud = request.security("FX_IDC:AUDCNY", calcTF, src)
p_myr = request.security("FX_IDC:MYRCNY", calcTF, src)
p_rub = request.security("FX_IDC:RUBCNY", calcTF, src)
p_hkd = request.security("FX_IDC:HKDCNY", calcTF, src)
p_thb = request.security("FX_IDC:THBCNY", calcTF, src)
p_sgd = request.security("FX_IDC:SGDCNY", calcTF, src)
p_mxn = request.security("FX_IDC:MXNCNY", calcTF, src)
p_gbp = request.security("FX_IDC:GBPCNY", calcTF, src)
p_cad = request.security("FX_IDC:CADCNY", calcTF, src)
p_chf = request.security("FX_IDC:CHFCNY", calcTF, src)
p_zar = request.security("FX_IDC:ZARCNY", calcTF, src)
p_pln = request.security("FX_IDC:PLNCNY", calcTF, src)
p_try = 1.0 / request.security("FX_IDC:CNYTRY", calcTF, src)
p_nzd = request.security("FX_IDC:NZDCNY", calcTF, src)
p_sek = request.security("FX_IDC:SEKCNY", calcTF, src)
p_huf = 1.0 / request.security("FX_IDC:CNYHUF", calcTF, src)
p_dkk = 1.0 / request.security("FX_IDC:CNYDKK", calcTF, src)
p_nok = 1.0 / request.security("FX_IDC:CNYNOK", calcTF, src)

p_sar = p_usd / 3.7500
p_aed = p_usd / 3.6725
p_mop = p_hkd / 1.0300

w_usd = 0.183068
w_eur = 0.178619
w_krw = 0.084558
w_jpy = 0.081182
w_aud = 0.054093
w_myr = 0.051467
w_rub = 0.050401
w_hkd = 0.040565
w_thb = 0.036407
w_sgd = 0.029978
w_sar = 0.028508
w_mxn = 0.027828
w_gbp = 0.027366
w_aed = 0.026117
w_cad = 0.024333
w_chf = 0.014680
w_zar = 0.013957
w_pln = 0.011877
w_try = 0.011500
w_nzd = 0.005432
w_sek = 0.005070
w_huf = 0.004648
w_dkk = 0.004456
w_nok = 0.002792
w_mop = 0.001099

S =  (-w_usd) * math.log(p_usd)
S += (-w_eur) * math.log(p_eur)
S += (-w_krw) * math.log(p_krw)
S += (-w_jpy) * math.log(p_jpy)
S += (-w_aud) * math.log(p_aud)
S += (-w_myr) * math.log(p_myr)
S += (-w_rub) * math.log(p_rub)
S += (-w_hkd) * math.log(p_hkd)
S += (-w_thb) * math.log(p_thb)
S += (-w_sgd) * math.log(p_sgd)
S += (-w_sar) * math.log(p_sar)
S += (-w_mxn) * math.log(p_mxn)
S += (-w_gbp) * math.log(p_gbp)
S += (-w_aed) * math.log(p_aed)
S += (-w_cad) * math.log(p_cad)
S += (-w_chf) * math.log(p_chf)
S += (-w_zar) * math.log(p_zar)
S += (-w_pln) * math.log(p_pln)
S += (-w_try) * math.log(p_try)
S += (-w_nzd) * math.log(p_nzd)
S += (-w_sek) * math.log(p_sek)
S += (-w_huf) * math.log(p_huf)
S += (-w_dkk) * math.log(p_dkk)
S += (-w_nok) * math.log(p_nok)
S += (-w_mop) * math.log(p_mop)

var float S_first = na
if barstate.isfirst
    S_first := S

var float S_custom = na
crossed = useCustomAnchor and not na(time[1]) and time >= anchorTime and time[1] < anchorTime
if crossed
    S_custom := S

baseS = useCustomAnchor and not na(S_custom) ? S_custom : S_first
idx   = anchorValue * math.exp(S - baseS)

plot(idx, "RMB Index", color = color.new(color.white, 0), linewidth = 2)
hline(100, "Base 2014 = 100", color = color.new(color.gray, 50), linestyle = hline.style_dashed)
````
