//+------------------------------------------------------------------+
//|                                           Market Status Info.mq4 |
//|                                                       SvetoslavB |
//|                                               s_boiadgiev@abv.bg |
//+------------------------------------------------------------------+
#property copyright "SvetoslavB"
#property link      "s_boiadgiev@abv.bg"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Symb=Symbol();
ENUM_SYMBOL_TRADE_MODE TRADE_MODE;
ENUM_SYMBOL_TRADE_EXECUTION execution;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
// Setup Time
   int TimHourGMT=TimeHour(TimeGMT());
   int TimMinGMT= TimeMinute(TimeGMT());
   if(TimHourGMT==0)
     {
      TimHourGMT=24;
     }
   string Time_GMT;
   if(TimHourGMT<10)
     {
      if(TimMinGMT<10)
        {
         Time_GMT="0"+(string)TimHourGMT+":0"+(string)TimMinGMT;
        }
      else
        {
         Time_GMT="0"+(string)TimHourGMT+":"+(string)TimMinGMT;
        }
     }
   else
     {
      if(TimMinGMT<10)
        {
         Time_GMT=(string)TimHourGMT+":0"+(string)TimMinGMT;
        }
      else
        {
         Time_GMT=(string)TimHourGMT+":"+(string)TimMinGMT;
        }
     }

   int TimHourBr=TimeHour(TimeCurrent());
   int TimMinBr= TimeMinute(TimeCurrent());
   if(TimHourBr==0)
     {
      TimHourBr=24;
     }
   string Time_Bro;
   if(TimHourBr<10)
     {
      if(TimMinBr<10)
        {
         Time_Bro="0"+(string)TimHourBr+":0"+(string)TimMinBr;
        }
      else
        {
         Time_Bro="0"+(string)TimHourBr+":"+(string)TimMinBr;
        }
     }
   else
     {
      if(TimMinBr<10)
        {
         Time_Bro=(string)TimHourBr+":0"+(string)TimMinBr;
        }
      else
        {
         Time_Bro=(string)TimHourBr+":"+(string)TimMinBr;
        }
     }

   string Time_Broker;
   if(TimHourBr-TimHourGMT==0)
     {
      Time_Broker="   "+(string)(TimHourBr-TimHourGMT);
     }
   if(TimHourBr-TimHourGMT>0)
     {
      Time_Broker="+"+(string)(TimHourBr-TimHourGMT);
     }
   else
     {
      if(TimHourBr-TimHourGMT<0)
        {
         Time_Broker=(string)(TimHourBr-TimHourGMT);
        }
     }
   int TimHourLoc=TimeHour(TimeLocal());
   int TimMinLoc= TimeMinute(TimeLocal());
   if(TimHourLoc==0)
     {
      TimHourLoc=24;
     }
   string Time_Loca;
   if(TimHourLoc<10)
     {
      if(TimMinLoc<10)
        {
         Time_Loca="0"+(string)TimHourLoc+":0"+(string)TimMinLoc;
        }
      else
        {
         Time_Loca="0"+(string)TimHourLoc+":"+(string)TimMinLoc;
        }
     }
   else
     {
      if(TimMinLoc<10)
        {
         Time_Loca=(string)TimHourLoc+":0"+(string)TimMinLoc;
        }
      else
        {
         Time_Loca=(string)TimHourLoc+":"+(string)TimMinLoc;
        }
     }

   string Time_Local;
   if(TimHourLoc-TimHourGMT==0)
     {
      Time_Local="   "+(string)(TimHourLoc-TimHourGMT);
     }
   if(TimHourLoc-TimHourGMT>0)
     {
      Time_Local="+"+(string)(TimHourLoc-TimHourGMT);
     }
   else
     {
      if(TimHourLoc-TimHourGMT<0)
        {
         Time_Local=(string)(TimHourLoc-TimHourGMT);
        }
     }

// Name of the company
   string company=AccountInfoString(ACCOUNT_COMPANY);

// Name of the server
   string server=AccountInfoString(ACCOUNT_SERVER);

// Demo, contest or real account
   ENUM_ACCOUNT_TRADE_MODE account_type=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
   string trade_mode;
   switch(account_type)
     {
      case  ACCOUNT_TRADE_MODE_DEMO:
        {
         trade_mode="Demo account!";
         break;
        }
      case  ACCOUNT_TRADE_MODE_CONTEST:
        {
         trade_mode="Contest account!";
         break;
        }
      default:
        {
         trade_mode="Real account!";
         break;
        }
     }

// Account currency
   string currency=AccountInfoString(ACCOUNT_CURRENCY);

// Account leverage
   long leverage=AccountInfoInteger(ACCOUNT_LEVERAGE);

// Allowed trade for the current account
   string AccTradeAllowed;
   if(AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      AccTradeAllowed="Yes";
     }
   else
     {
      AccTradeAllowed="No";
     }

// Allowed trade for an Expert Advisor
   string ExpTradeAllowed;
   if(AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      ExpTradeAllowed="Yes";
     }
   else
     {
      ExpTradeAllowed="No";
     }

// Automated trading is allowed in the terminal settings
   string TermTradeAllowed;
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      TermTradeAllowed="Yes";
     }
   else
     {
      TermTradeAllowed="No";
     }

// Profit calculation mode
   string ProfitMode;
   switch((int) MarketInfo(Symb,MODE_PROFITCALCMODE))
     {
      case 0:
        {
         ProfitMode="FOREX";
         break;
        }
      case 1:
        {
         ProfitMode="CFD";
         break;
        }
      case 2:
        {
         ProfitMode="Futures";
         break;
        }
     }

// Margin calculation mode
   string MarginCallMode;
   switch((int) MarketInfo(Symb,MODE_MARGINCALCMODE))
     {
      case 0:
        {
         MarginCallMode="FOREX";
         break;
        }
      case 1:
        {
         MarginCallMode="CFD";
         break;
        }
      case 2:
        {
         MarginCallMode="Futures";
         break;
        }
      case 3:
        {
         MarginCallMode="CFD for indices";
         break;
        }
     }

// SPREAD MODE method
   bool Spread=SymbolInfoInteger(Symb,SYMBOL_SPREAD_FLOAT);
   string Spread_Mode;
   switch(Spread)
     {
      case 0:
        {
         Spread_Mode="Fixed spread!";
         break;
        }
      case 1:
        {
         Spread_Mode="Floating spread!";
         break;
        }
     }


// TRADE MODE method
   TRADE_MODE=(ENUM_SYMBOL_TRADE_MODE) SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   string Trade;
   switch(TRADE_MODE)
     {
      case SYMBOL_TRADE_MODE_DISABLED :
        {
         Trade="Trade is disabled for the symbol!";
         break;
        }
      case SYMBOL_TRADE_MODE_LONGONLY :
        {
         Trade="Allowed only long positions!";
         break;
        }
      case SYMBOL_TRADE_MODE_SHORTONLY  :
        {
         Trade="Allowed only short positions!";
         break;
        }
      case SYMBOL_TRADE_MODE_CLOSEONLY:
        {
         Trade="Allowed only position close operations!";
         break;
        }
      case SYMBOL_TRADE_MODE_FULL:
        {
         Trade="No trade restrictions!";
         break;
        }
     }

// TRADE EXECUTION method
   execution=(ENUM_SYMBOL_TRADE_EXECUTION) SymbolInfoInteger(_Symbol,SYMBOL_TRADE_EXEMODE);
   string TRADE_EXECUTION;
   string Trade_Mode;
   switch(execution)
     {
      case SYMBOL_TRADE_EXECUTION_REQUEST :
        {
         TRADE_EXECUTION="Execution by request!";
         Trade_Mode="(Dealing Desk or Market Maker)";
         break;
        }
      case SYMBOL_TRADE_EXECUTION_INSTANT :
        {
         TRADE_EXECUTION="Instant execution!";
         Trade_Mode="(Dealing Desk or Market Maker)";
         break;
        }
      case SYMBOL_TRADE_EXECUTION_MARKET  :
        {
         TRADE_EXECUTION="Market execution!";
         Trade_Mode="(No Dealing Desk)";
         break;
        }
      case SYMBOL_TRADE_EXECUTION_EXCHANGE:
        {
         TRADE_EXECUTION="Exchange execution!";
         Trade_Mode="These values are not used in MQL4!";
         break;
        }
      default:
         TRADE_EXECUTION="Unknown Trade Execution!";
     }

// Swap calculation method
   string SwapType;
   string SwapTypeCurrency;
   switch((int) MarketInfo(Symb,MODE_SWAPTYPE))
     {
      case 0:
        {
         SwapType="In points!";
         SwapTypeCurrency="points";
         break;
        }
      case 1:
        {
         SwapType="In the symbol base currency!";
         SwapTypeCurrency="in the symbol base currency";
         break;
        }
      case 2:
        {
         SwapType="By interest!";
         SwapTypeCurrency="interest";
         break;
        }
      case 3:
        {
         SwapType="In the margin currency!";
         SwapTypeCurrency="in the margin currency";
         break;
        }
     }

// Stop Out is set in percentage or money
   ENUM_ACCOUNT_STOPOUT_MODE stop_out_mode=(ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   string StOut;
   string StOut_calc;
   switch(stop_out_mode)
     {
      case ACCOUNT_STOPOUT_MODE_PERCENT:
        {
         StOut="\" % \"";
         StOut_calc="(Equity / Used margin) * 100";
         break;
        }
      case ACCOUNT_STOPOUT_MODE_MONEY:
        {
         StOut=currency;
         StOut_calc=" Money!";
         break;
        }
     }
   double margin_call=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
   double stop_out=AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);

// Creating the information
   string Information="GMT time is :\t\t\t\t"+Time_GMT+" / "+"   0"+" hours"+"\n"+
                      "Terminal time is :\t\t\t\t"+Time_Bro+" / "+Time_Broker+" hours difference"+"\n"+
                      "Computer time is :\t\t\t\t"+Time_Loca+" / "+Time_Local+" hours difference"+"\n"+
                      "-----------------------------"+"\n"+
                      "Account information :"+"\n"+
                      "-----------------------------"+"\n"+
                      "Name of a company :\t\t\t"+company+"\n"+
                      "Trade server name :\t\t\t"+server+"\n"+
                      "The type of account :\t\t\t"+trade_mode+"\n"+
                      "Account currency :\t\t\t\t"+currency+"\n"+
                      "Account leverage :\t\t\t\t"+"1 : "+(string)leverage+"\n"+
                      "Allowed trade for the current account :\t"+AccTradeAllowed+"\n"+
                      "Allowed trade for an Expert Advisor :\t\t"+ExpTradeAllowed+"\n"+
                      "Automated trading is "+"\n"+
                      "allowed in the terminal settings :\t\t"+TermTradeAllowed+"\n"+
                      "MarginCall and StopOut levels is set in :\t"+StOut+"\n"+
                      "MarginCall and StopOut is calculated by :\t"+StOut_calc+"\n\n"+
                      "MarginCall level :\t\t\t\t"+DoubleToStr(margin_call,2)+((stop_out_mode==ACCOUNT_STOPOUT_MODE_PERCENT)?" %":currency)+"\n"+
                      "(When your account equity reaches the MarginCall, account replenishment is required!)"+"\n\n"+
                      "StopOut level :\t\t\t\t"+DoubleToStr(stop_out,2)+((stop_out_mode==ACCOUNT_STOPOUT_MODE_PERCENT)?" %":currency)+"\n"+
                      "(When your account equity reaches the StopOut, all active positions will be closed automatically!)"+"\n"+
                      "---------------------------------------------"+"\n"+
                      "Traded instrument information :"+"\n"+
                      "---------------------------------------------"+"\n"+
                      "Symbol of the current chart :\t\t"+"\" "+Symb+"\""+"\n"+
                      "Symbol spread mode :\t\t\t"+Spread_Mode+"\n"+
                      "Symbol trading mode :\t\t\t"+Trade+"\n"+
                      "Deal execution mode :\t\t\t"+TRADE_EXECUTION+"\t"+Trade_Mode+"\n"+
                      "Profit calculation mode :\t\t\t"+ProfitMode+"\n"+
                      "Margin calculation mode :\t\t\t"+MarginCallMode+"\n"+
                      "Minimum permitted amount of a lot :\t\t"+DoubleToStr(MarketInfo(Symb,MODE_MINLOT),2)+"\n"+
                      "Maximum permitted amount of a lot :\t"+DoubleToStr(MarketInfo(Symb,MODE_MAXLOT),2)+"\n"+
                      "Step for changing lots: \t\t\t"+DoubleToStr(MarketInfo(Symb,MODE_LOTSTEP),2)+"\n"+
                      "Free margin required to open Min. lot :\t"+DoubleToStr(MarketInfo(Symb,MODE_MARGINREQUIRED)*MarketInfo(Symb,MODE_MINLOT),2)+" "+currency+"\n"+
                      "Pips value in the deposit currency :\t\t"+DoubleToStr(MarketInfo(Symbol(),MODE_TICKVALUE),2)+" "+currency+"\n"+
                      "Swap calculation method :\t\t\t"+SwapType+"\n"+
                      "Swap of the buy order : \t\t\t"+DoubleToStr(MarketInfo(Symb,MODE_SWAPLONG),2)+" "+SwapTypeCurrency+"\n"+
                      "Swap of the sell order : \t\t\t"+DoubleToStr(MarketInfo(Symb,MODE_SWAPSHORT),2)+" "+SwapTypeCurrency+"\n\n"+
                      "Stop level in points :\t\t\t"+DoubleToStr(MarketInfo(Symb,MODE_STOPLEVEL),2)+" or "+DoubleToStr(MarketInfo(Symb,MODE_STOPLEVEL)*Point,Digits)+"\n"+
                      "(Restrictions on the minimal distance for Stop Loss/Take Profit!)"+"\n\n"+
                      "Order Freeze level in points :\t\t"+DoubleToStr(MarketInfo(Symb,MODE_FREEZELEVEL),2)+" or "+DoubleToStr(MarketInfo(Symb,MODE_FREEZELEVEL)*Point,Digits)+"\n"+
                      "(If the execution price lies within the range defined by the Freeze level, the order cannot be modified, cancelled or closed!)";

   MessageBox(Information,"Market Status Info Script",MB_OK);

  }
//+------------------------------------------------------------------+
