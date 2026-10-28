//+------------------------------------------------------------------+
//|                                                CustomSymbols.mqh |
//|                                                           Рэндом |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Рэндом"
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

void CopyProperty(string name,string sym)
{
   CustomSymbolSetString(name,SYMBOL_BASIS,SymbolInfoString(sym,SYMBOL_BASIS));
   CustomSymbolSetString(name,SYMBOL_CURRENCY_BASE,SymbolInfoString(sym,SYMBOL_CURRENCY_BASE));
   CustomSymbolSetString(name,SYMBOL_CURRENCY_PROFIT,SymbolInfoString(sym,SYMBOL_CURRENCY_PROFIT));
   CustomSymbolSetString(name,SYMBOL_CURRENCY_MARGIN,SymbolInfoString(sym,SYMBOL_CURRENCY_MARGIN));
   CustomSymbolSetString(name,SYMBOL_DESCRIPTION,SymbolInfoString(sym,SYMBOL_DESCRIPTION));
   CustomSymbolSetString(name,SYMBOL_ISIN,SymbolInfoString(sym,SYMBOL_ISIN));
   
   CustomSymbolSetInteger(name,SYMBOL_CUSTOM,true);
   CustomSymbolSetInteger(name,SYMBOL_SPREAD_FLOAT,SymbolInfoInteger(sym,SYMBOL_SPREAD_FLOAT));
   CustomSymbolSetInteger(name,SYMBOL_DIGITS,SymbolInfoInteger(sym,SYMBOL_DIGITS));
   CustomSymbolSetInteger(name,SYMBOL_TICKS_BOOKDEPTH,SymbolInfoInteger(sym,SYMBOL_TICKS_BOOKDEPTH));
   CustomSymbolSetInteger(name,SYMBOL_CHART_MODE,SymbolInfoInteger(sym,SYMBOL_CHART_MODE));
   CustomSymbolSetInteger(name,SYMBOL_TRADE_CALC_MODE,SymbolInfoInteger(sym,SYMBOL_TRADE_CALC_MODE));
   CustomSymbolSetInteger(name,SYMBOL_TRADE_MODE,SymbolInfoInteger(sym,SYMBOL_TRADE_MODE));
   CustomSymbolSetInteger(name,SYMBOL_START_TIME,SymbolInfoInteger(sym,SYMBOL_START_TIME));
   CustomSymbolSetInteger(name,SYMBOL_EXPIRATION_TIME,SymbolInfoInteger(sym,SYMBOL_EXPIRATION_TIME));
   CustomSymbolSetInteger(name,SYMBOL_TRADE_STOPS_LEVEL,SymbolInfoInteger(sym,SYMBOL_TRADE_STOPS_LEVEL));
   CustomSymbolSetInteger(name,SYMBOL_TRADE_FREEZE_LEVEL,SymbolInfoInteger(sym,SYMBOL_TRADE_FREEZE_LEVEL));
   CustomSymbolSetInteger(name,SYMBOL_TRADE_EXEMODE,SymbolInfoInteger(sym,SYMBOL_TRADE_EXEMODE));
   CustomSymbolSetInteger(name,SYMBOL_SWAP_MODE,SymbolInfoInteger(sym,SYMBOL_SWAP_MODE));
   CustomSymbolSetInteger(name,SYMBOL_SWAP_ROLLOVER3DAYS,SymbolInfoInteger(sym,SYMBOL_SWAP_ROLLOVER3DAYS));
   CustomSymbolSetInteger(name,SYMBOL_MARGIN_HEDGED_USE_LEG,SymbolInfoInteger(sym,SYMBOL_MARGIN_HEDGED_USE_LEG));
   CustomSymbolSetInteger(name,SYMBOL_EXPIRATION_MODE,SymbolInfoInteger(sym,SYMBOL_EXPIRATION_MODE));
   CustomSymbolSetInteger(name,SYMBOL_FILLING_MODE,SymbolInfoInteger(sym,SYMBOL_FILLING_MODE));
   CustomSymbolSetInteger(name,SYMBOL_ORDER_MODE,SymbolInfoInteger(sym,SYMBOL_ORDER_MODE));
   CustomSymbolSetInteger(name,SYMBOL_ORDER_GTC_MODE,SymbolInfoInteger(sym,SYMBOL_ORDER_GTC_MODE));
   CustomSymbolSetInteger(name,SYMBOL_OPTION_MODE,SymbolInfoInteger(sym,SYMBOL_OPTION_MODE));
   CustomSymbolSetInteger(name,SYMBOL_OPTION_RIGHT,SymbolInfoInteger(sym,SYMBOL_OPTION_RIGHT));
   
   CustomSymbolSetDouble(name,SYMBOL_POINT,SymbolInfoDouble(sym,SYMBOL_POINT));
   CustomSymbolSetDouble(name,SYMBOL_TRADE_TICK_VALUE,SymbolInfoDouble(sym,SYMBOL_TRADE_TICK_VALUE));
   CustomSymbolSetDouble(name,SYMBOL_TRADE_TICK_VALUE_PROFIT,SymbolInfoDouble(sym,SYMBOL_TRADE_TICK_VALUE_PROFIT));
   CustomSymbolSetDouble(name,SYMBOL_TRADE_TICK_VALUE_LOSS,SymbolInfoDouble(sym,SYMBOL_TRADE_TICK_VALUE_LOSS));
   CustomSymbolSetDouble(name,SYMBOL_TRADE_TICK_SIZE,SymbolInfoDouble(sym,SYMBOL_TRADE_TICK_SIZE));
   CustomSymbolSetDouble(name,SYMBOL_TRADE_FACE_VALUE,SymbolInfoDouble(sym,SYMBOL_TRADE_FACE_VALUE));
   CustomSymbolSetDouble(name,SYMBOL_TRADE_LIQUIDITY_RATE,SymbolInfoDouble(sym,SYMBOL_TRADE_LIQUIDITY_RATE));
   CustomSymbolSetDouble(name,SYMBOL_VOLUME_MIN,SymbolInfoDouble(sym,SYMBOL_VOLUME_MIN));
   CustomSymbolSetDouble(name,SYMBOL_VOLUME_MAX,SymbolInfoDouble(sym,SYMBOL_VOLUME_MAX));
   CustomSymbolSetDouble(name,SYMBOL_VOLUME_STEP,SymbolInfoDouble(sym,SYMBOL_VOLUME_STEP));
   CustomSymbolSetDouble(name,SYMBOL_VOLUME_LIMIT,SymbolInfoDouble(sym,SYMBOL_VOLUME_LIMIT));
   CustomSymbolSetDouble(name,SYMBOL_SWAP_LONG,SymbolInfoDouble(sym,SYMBOL_SWAP_LONG));
   CustomSymbolSetDouble(name,SYMBOL_SWAP_SHORT,SymbolInfoDouble(sym,SYMBOL_SWAP_SHORT));
   CustomSymbolSetDouble(name,SYMBOL_MARGIN_INITIAL,SymbolInfoDouble(sym,SYMBOL_MARGIN_INITIAL));
   CustomSymbolSetDouble(name,SYMBOL_MARGIN_MAINTENANCE,SymbolInfoDouble(sym,SYMBOL_MARGIN_MAINTENANCE));
   CustomSymbolSetDouble(name,SYMBOL_MARGIN_HEDGED,SymbolInfoDouble(sym,SYMBOL_MARGIN_HEDGED));
   CustomSymbolSetDouble(name,SYMBOL_TRADE_CONTRACT_SIZE,SymbolInfoDouble(sym,SYMBOL_TRADE_CONTRACT_SIZE));
}
