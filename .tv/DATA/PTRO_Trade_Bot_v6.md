<!-- tradingview-pine-id: PUB;3370701cf2a84e7896b438b67f354f90 -->
<!-- tradingviewscripts-format: 1 -->
# PTRO Trade Bot v6

Source: https://www.tradingview.com/script/QSEoCJG3-PTRO-Trade-Bot-v6/

## Description

//@version=6
indicator("PTRO Trade Bot v6", overlay=true)

triggerVol = input.int(50000000, "Min volume (lots)", minval=0)

[close15, vol15, high15] = request.security("IDX:PTRO", "15", [close, volume, high])

neckline = 4750.0
reclaim  = 4820.0
trim1    = 4950.0
trim2    = 5000.0
trim3    = 5200.0
hardStop = 4200.0

breakdown      = close15 < neckline and vol15 > triggerVol
reclaimTrigger = close15 > reclaim  and vol15 > triggerVol
trim1Hit       = high15 >= trim1 and high15[1] < trim1
trim2Hit       = high15 >= trim2 and high15[1] < trim2
trim3Hit       = high15 >= trim3 and high15[1] < trim3
hardStopHit    = close15 < hardStop

plot(neckline, "Neckline 4750",  color=color.red,    style=plot.style_stepline, linewidth=2)
plot(reclaim,  "BOS 4820",       color=color.green,  style=plot.style_stepline, linewidth=2)
plot(trim1,    "Trim 1 (4950)",  color=color.blue,   style=plot.style_circles)
plot(trim2,    "Trim 2 (5000)",  color=color.blue,   style=plot.style_circles)
plot(trim3,    "Trim 3 (5200)",  color=color.blue,   style=plot.style_circles)
plot(hardStop, "Hard Stop 4200", color=color.maroon, style=plot.style_cross,   linewidth=2)

alertcondition(breakdown,      "PTRO Breakdown 50pct Cut", "PTRO closed below 4750 with vol > 50M. Cut 50pct pre-market.")
alertcondition(reclaimTrigger, "PTRO BOS Reclaim",         "PTRO reclaimed 4820 on volume. Thesis confirmed.")
alertcondition(trim1Hit,       "PTRO Trim 1 (4950)",       "PTRO touched 4950. Trim 25pct, move stop to 4750.")
alertcondition(trim2Hit,       "PTRO Trim 2 (5000)",       "PTRO touched 5000. Trim 25-30pct, trail stop.")
alertcondition(trim3Hit,       "PTRO Trim 3 BOS (5200)",   "PTRO touched 5200. Final trim, trail runner 1 ATR.")
alertcondition(hardStopHit,    "PTRO Hard Stop (4200)",    "PTRO closed below 4200. Thesis dead. Exit remaining.")

---

## Source Code

````pine
//@version=6
indicator("PTRO Trade Bot v6", overlay=true)

triggerVol = input.int(50000000, "Min volume (lots)", minval=0)

[close15, vol15, high15] = request.security("IDX:PTRO", "15", [close, volume, high])

neckline = 4750.0
reclaim  = 4820.0
trim1    = 4950.0
trim2    = 5000.0
trim3    = 5200.0
hardStop = 4200.0

breakdown      = close15 < neckline and vol15 > triggerVol
reclaimTrigger = close15 > reclaim  and vol15 > triggerVol
trim1Hit       = high15 >= trim1 and high15[1] < trim1
trim2Hit       = high15 >= trim2 and high15[1] < trim2
trim3Hit       = high15 >= trim3 and high15[1] < trim3
hardStopHit    = close15 < hardStop

plot(neckline, "Neckline 4750",  color=color.red,    style=plot.style_stepline, linewidth=2)
plot(reclaim,  "BOS 4820",       color=color.green,  style=plot.style_stepline, linewidth=2)
plot(trim1,    "Trim 1 (4950)",  color=color.blue,   style=plot.style_circles)
plot(trim2,    "Trim 2 (5000)",  color=color.blue,   style=plot.style_circles)
plot(trim3,    "Trim 3 (5200)",  color=color.blue,   style=plot.style_circles)
plot(hardStop, "Hard Stop 4200", color=color.maroon, style=plot.style_cross,   linewidth=2)

alertcondition(breakdown,      "PTRO Breakdown 50pct Cut", "PTRO closed below 4750 with vol > 50M. Cut 50pct pre-market.")
alertcondition(reclaimTrigger, "PTRO BOS Reclaim",         "PTRO reclaimed 4820 on volume. Thesis confirmed.")
alertcondition(trim1Hit,       "PTRO Trim 1 (4950)",       "PTRO touched 4950. Trim 25pct, move stop to 4750.")
alertcondition(trim2Hit,       "PTRO Trim 2 (5000)",       "PTRO touched 5000. Trim 25-30pct, trail stop.")
alertcondition(trim3Hit,       "PTRO Trim 3 BOS (5200)",   "PTRO touched 5200. Final trim, trail runner 1 ATR.")
alertcondition(hardStopHit,    "PTRO Hard Stop (4200)",    "PTRO closed below 4200. Thesis dead. Exit remaining.")
````
