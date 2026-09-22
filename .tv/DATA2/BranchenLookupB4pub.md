<!-- tradingview-pine-id: PUB;f6649a15cf9842bbb537099b1ae7b5f3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BranchenLookup_B4_pub

Source: https://www.tradingview.com/script/3OgygSL6/

## Description

Library  "BranchenLookup_B4_pub"

is_member(t)
  Parameters:
    t (simple string)

get_z1(t)
  Parameters:
    t (simple string)

get_z2(t)
  Parameters:
    t (simple string)

get_z3(t)
  Parameters:
    t (simple string)

get_z4(t)
  Parameters:
    t (simple string)

---

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  BranchenLookup_B4_pub  ·  Finanzen / Versicherung / Banken                ║
// ║  Publish as: S-Schmidt/BranchenLookup_B4_pub/1                             ║
// ║  Usage:   import S-Schmidt/BranchenLookup_B4_pub/1 as bl_b4                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
// Lookbacks: Z1=0.75J  Z2=2.50J  Z3=6.00J  Z4=15.0J
// Tickers  : 27 Werte (DE, CH, FR, IT, GB, US, CA, JP)
// ─────────────────────────────────────────────────────────────────────────────

library("BranchenLookup_B4_pub", overlay = false)

export is_member(simple string t) =>
    (t == "XETR_DLY:ALV"          or t == "XETR_DLY:MUV2"         or
     t == "XETR_DLY:HNR1"         or t == "SIX_DLY:ZURN"          or
     t == "SIX_DLY:SREN"          or t == "EURONEXT_DLY:CS"        or
     t == "MIL_LS:BGN"             or t == "EURONEXT_DLY:AGN"       or
     t == "EURONEXT_DLY:NN"        or t == "LSE_DLY:LGEN"           or
     t == "LSE_DLY:AV"             or t == "LSE_DLY:PRU"            or
     t == "BATS:MET"               or t == "BATS:PRU"               or
     t == "BATS:JPM"               or t == "BATS:WFC"               or
     t == "BATS:USB"               or t == "TSX_DLY:BNS"            or
     t == "TSX_DLY:TD"             or t == "TSX_DLY:RY"             or
     t == "LSE_DLY:HSBA"           or t == "LSE_DLY:BARC"           or
     t == "EURONEXT_DLY:BNP"       or t == "BME_DLY:SAN"            or
     t == "XETR_DLY:DBK"           or t == "EURONEXT_DLY:INGA"      or
     t == "TSE_DLY:8306")

export get_z1(simple string t) => is_member(t) ? 0.75 : na
export get_z2(simple string t) => is_member(t) ? 2.50 : na
export get_z3(simple string t) => is_member(t) ? 6.00 : na
export get_z4(simple string t) => is_member(t) ? 15.0 : na
````
