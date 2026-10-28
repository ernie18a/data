//+------------------------------------------------------------------+
//|                                                  InfoMarket.mq5  |
//|                                                                  |
//|   Script to display information about the current trading tool.  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Kim Igor V. aka KimIV"
#property link      "http://www.kimiv.ru"
#property description "Script to display information about the current trading tool"
#property script_show_confirm
//---- show input parameters
#property script_show_inputs
//+------------------------------------------------------------------+ 
//| start function                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
//----
   string st="Low="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_ASKLOW),_Digits)+"\n"
             +"High="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_BIDHIGH),_Digits)+"\n"
             +"Time="+TimeToString(SymbolInfoInteger(Symbol(),SYMBOL_TIME),TIME_SECONDS)+"\n"
             +"Bid="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_BID),_Digits)+"\n"
             +"Ask="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_ASK),_Digits)+"\n"
             +"Point="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_POINT),_Digits)+"\n"
             +"_Digits="+string(SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+"\n"
             +"Spread="+string(SymbolInfoInteger(Symbol(),SYMBOL_SPREAD))+"\n"
             +"StopLevel="+string(SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL))+"\n"
             +"LotSize="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE),2)+"\n"
             +"TickValue="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE),_Digits)+"\n"
             +"TickValue Loss="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE_LOSS),_Digits)+"\n"
             +"TickValue Profit="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE_PROFIT),_Digits)+"\n"
             +"TickSize="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE),_Digits)+"\n"
             +"SwapLong="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_SWAP_LONG),_Digits)+"\n"
             +"SwapShort="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_SWAP_SHORT),_Digits)+"\n"
             +"Starting="+TimeToString(SymbolInfoInteger(Symbol(),SYMBOL_START_TIME),TIME_DATE|TIME_MINUTES)+"\n"
             +"Expiration="+TimeToString(SymbolInfoInteger(Symbol(),SYMBOL_EXPIRATION_TIME),TIME_DATE|TIME_MINUTES)+"\n"
             +"MinLot="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN),2)+"\n"
             +"LotStep="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP),2)+"\n"
             +"MaxLot="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX),2)+"\n"
             +"SwapType="+EnumToString(ENUM_SYMBOL_SWAP_MODE(SymbolInfoInteger(Symbol(),SYMBOL_SWAP_MODE)))+"\n"
             +"MarginMaintenance="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_MARGIN_MAINTENANCE),_Digits)+"\n"
             +"MarginInitial="+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_MARGIN_INITIAL),_Digits)+"\n"
             +"FreezeLevel="+string(SymbolInfoInteger(Symbol(),SYMBOL_TRADE_FREEZE_LEVEL))+"\n"
             ;
   Comment(st);
   Sleep(20000);
   Comment("");
//----
  }
//+------------------------------------------------------------------+
