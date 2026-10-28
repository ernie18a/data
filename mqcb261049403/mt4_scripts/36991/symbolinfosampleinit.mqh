//+------------------------------------------------------------------+
//|                                           TestSymbolInfoInit.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
//---
//+------------------------------------------------------------------+
//| Arrays to initialize graphics objects SymbolInfoSample.          |
//+------------------------------------------------------------------+
//--- for ExtLabel[]
#define MODE_LEVERAGE 100

string init_l_newstr[] =
  {
   "MODE_LOW",
   "MODE_HIGH",
   "MODE_TIME",
   "MODE_BID",
   "MODE_ASK",
   "MODE_POINT",
   "MODE_DIGITS",
   "MODE_SPREAD",
   "MODE_STOPLEVEL",
   "MODE_TICKVALUE",
   "MODE_TICKSIZE",
   "MODE_SWAPLONG",
   "MODE_SWAPSHORT",
   "MODE_STARTING",
   "MODE_EXPIRATION",
   "MODE_TRADEALLOWED",
   "MODE_MINLOT",
   "MODE_LOTSTEP",
   "MODE_MAXLOT",
   "MODE_SWAPTYPE",
   "MODE_PROFITCALCMODE",
   "MODE_MARGINCALCMODE",
   "MODE_MARGININIT",
   "MODE_MARGINMAINTENANCE",
   "MODE_MARGINHEDGED",
   "MODE_MARGINREQUIRED",
   "MODE_FREEZELEVEL",
   "MODE_CLOSEBY_ALLOWED",
   "MODE_LEVERAGE"
  };

int init_l_newstrint[] =
  {
   MODE_LOW,
   MODE_HIGH,
   MODE_TIME,
   MODE_BID,
   MODE_ASK,
   MODE_POINT,
   MODE_DIGITS,
   MODE_SPREAD,
   MODE_STOPLEVEL,
   MODE_TICKVALUE,
   MODE_TICKSIZE,
   MODE_SWAPLONG,
   MODE_SWAPSHORT,
   MODE_STARTING,
   MODE_EXPIRATION,
   MODE_TRADEALLOWED,
   MODE_MINLOT,
   MODE_LOTSTEP,
   MODE_MAXLOT,
   MODE_SWAPTYPE,
   MODE_PROFITCALCMODE,
   MODE_MARGINCALCMODE,
   MODE_MARGININIT,
   MODE_MARGINMAINTENANCE,
   MODE_MARGINHEDGED,
   MODE_MARGINREQUIRED,
   MODE_FREEZELEVEL,
   MODE_CLOSEBY_ALLOWED,
   MODE_LEVERAGE
  };


int ENUM_SYMBOL_INFO_STRING_[] =
  {
   SYMBOL_CURRENCY_BASE,
   SYMBOL_CURRENCY_PROFIT,
   SYMBOL_CURRENCY_MARGIN,
   SYMBOL_DESCRIPTION,
   SYMBOL_PATH
  };

//+------------------------------------------------------------------+
string BoolToString(bool var)
  {
   if(var)
      return("true");
   else
      return("false");
  }
//+------------------------------------------------------------------+
