<!-- tradingview-pine-id: PUB;42fabcb89e1e40d8905cc1f110f6ebb7 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# BranchenLookup_B5_pub

Source: https://www.tradingview.com/script/87J4BO8z/

## Description

Library  "BranchenLookup_B5_pub"

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
// ║  BranchenLookup_B5_pub  ·  REITs / Immobilien                              ║
// ║  Publish as: S-Schmidt/BranchenLookup_B5_pub/1                             ║
// ║  Usage:   import S-Schmidt/BranchenLookup_B5_pub/1 as bl_b5                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
// Lookbacks: Z1=0.75J  Z2=2.00J  Z3=6.00J  Z4=12.0J
// Tickers  : 35 Werte (US, DE, FR, GB, SG, AU)

library("BranchenLookup_B5_pub", overlay = false)

export is_member(simple string t) =>
    (t == "BATS:O" or t == "BATS:SPG" or t == "BATS:PSA" or t == "BATS:WPC" or
     t == "BATS:VTR" or t == "BATS:WELL" or t == "BATS:NNN" or t == "BATS:STAG" or
     t == "BATS:VICI" or t == "BATS:AMT" or t == "BATS:CCI" or t == "BATS:DLR" or
     t == "BATS:EQIX" or t == "BATS:MPW" or t == "BATS:ARE" or
     t == "XETR_DLY:VNA" or t == "XETR_DLY:LEG" or t == "XETR_DLY:AOX" or
     t == "EURONEXT_DLY:URW" or t == "EURONEXT_DLY:GFC" or t == "EURONEXT_DLY:COV" or
     t == "LSE_DLY:LAND" or t == "LSE_DLY:BLND" or t == "LSE_DLY:SGRO" or
     t == "LSE_DLY:HMSO" or t == "LSE_DLY:LMP" or t == "LSE_DLY:PHP" or
     t == "SGX_DLY:C38U" or t == "SGX_DLY:ME8U" or t == "SGX_DLY:M44U" or
     t == "SGX_DLY:A17U" or t == "ASX_DLY:SCG" or t == "ASX_DLY:DXS" or
     t == "ASX_DLY:GMG" or t == "ASX_DLY:MGR")

export get_z1(simple string t) => is_member(t) ? 0.75 : na
export get_z2(simple string t) => is_member(t) ? 2.00 : na
export get_z3(simple string t) => is_member(t) ? 6.00 : na
export get_z4(simple string t) => is_member(t) ? 12.0 : na
````
