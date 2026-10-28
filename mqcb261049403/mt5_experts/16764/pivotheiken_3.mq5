//+------------------------------------------------------------------+
//|                       PivotHeiken 3(barabashkakvn's edition).mq5 |
//|                               Copyright © orBanAway aka cucurucu |
//+------------------------------------------------------------------+
#property copyright "orBanAway aka cucurucu"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//+------------------------------------------------------------------+
//| Enum TrailingStop                                                |
//+------------------------------------------------------------------+
enum ENUM_TRAILING_TYPE
  {
   type_0=0,   // "type 0": NO TRAILING
   type_1=1,   // "type 1": moves the stoploss without delay     
   type_2=2,   // "type 2": waits for price to move the amount of the trailStop before moving stop loss then moves like type 1
   type_3=3,   // "type 3": uses up to 3 levels for trailing stop                    
  };
//--- input parameters
input ENUM_TIMEFRAMES      InpWorkTimeFrame  = PERIOD_CURRENT; // Indicators time frame
input double               InpLots           = 0.1;            // Lots
input ushort               InpStopLoss       = 50;             // Stop Loss (in pips)
input ushort               InpTakeProfit     = 350;            // Take Profit (in pips)
input ENUM_TRAILING_TYPE   InpTrailingType   = type_2;         // Trailing Stop type
input ushort               InpTrailingStop   = 50;             // Trailing Stop (in pips)
input ushort               InpFirstMove      = 30;             // First Move (in pips)
input ushort               InpFirstStopLoss  = 50;             // First Stop Loss (Breakeven) (in pips)
input ushort               InpSecondMove     = 40;             // Second Move (in pips)
input ushort               InpSecondStopLoss = 50;             // Second Stop Loss (Move stop to lock is profit) (in pips)
input ushort               InpThirdMove      = 50;             // Third Move (in pips)
input ushort               InpTrailingStop3  = 50;             // Move stop and trail from there (in pips)
input ulong                m_magic           = 78907825;       // magic number
//---
ulong          m_slippage=10;                // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStop=0.0;
double         ExtFirstMove=0.0;
double         ExtFirstStopLoss=0.0;
double         ExtSecondMove=0.0;
double         ExtSecondStopLoss=0.0;
double         ExtThirdMove=0.0;
double         ExtTrailingStop3=0.0;

int            handle_iCustom_Pivot;         // variable for storing the handle of the iCustom indicator 
int            handle_iCustom_Heiken;        // variable for storing the handle of the iCustom indicator 

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(__FUNCTION__,", ERROR: ",err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss       = InpStopLoss        * m_adjusted_point;
   ExtTakeProfit     = InpTakeProfit      * m_adjusted_point;
   ExtTrailingStop   = InpTrailingStop    * m_adjusted_point;
   ExtFirstMove      = InpFirstMove       * m_adjusted_point;
   ExtFirstStopLoss  = InpFirstStopLoss   * m_adjusted_point;
   ExtSecondMove     = InpSecondMove      * m_adjusted_point;
   ExtSecondStopLoss = InpSecondStopLoss  * m_adjusted_point;
   ExtThirdMove      = InpThirdMove       * m_adjusted_point;
   ExtTrailingStop3  = InpTrailingStop3   * m_adjusted_point;
//--- create handle of the indicator iCustom
   handle_iCustom_Pivot=iCustom(m_symbol.Name(),InpWorkTimeFrame,"pivot-2");
//--- if the handle is not created 
   if(handle_iCustom_Pivot==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(InpWorkTimeFrame),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCustom
   handle_iCustom_Heiken=iCustom(m_symbol.Name(),InpWorkTimeFrame,"Heiken ashi smoothed oscillator");
//--- if the handle is not created 
   if(handle_iCustom_Heiken==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(InpWorkTimeFrame),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=Time(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!RefreshRates())
      return;
//---
   HandleOpenPositions();
   if(IsPositionExists())
      return;
   if(CheckEntryCondition("BUY"))
     {
      double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
      OpenBuy(sl,tp);
     }
   if(CheckEntryCondition("SELL"))
     {
      double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
      OpenSell(sl,tp);
     }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      else
         error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      else
         error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем не кратен минимальному шагу SYMBOL_VOLUME_STEP=%.2f, ближайший правильный объем %.2f",
                                        volume_step,ratio*volume_step);
      else
         error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                        volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
double iCustomGet(int handle,const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckExitCondition(string TradeType)
  {
   double Pivot=iCustomGet(handle_iCustom_Pivot,3,0);  // Pivot buffer "Pivot"
   double line=iCustomGet(handle_iCustom_Heiken,1,0); // Heiken Ashi buffer "line"
   double average=iCustomGet(handle_iCustom_Heiken,2,0); // Heiken Ashi buffer "average"
//---
   bool YesTrade=false;
   if(TradeType=="SELL")
     {
      if(line>average && m_symbol.Bid()<Pivot)
         YesTrade=true;
     }
   if(TradeType=="BUY")
     {
      if(line<average && m_symbol.Bid()>Pivot)
         YesTrade=true;
     }
   return(YesTrade);
  }
//+------------------------------------------------------------------+
//| CheckEntryCondition                                              |
//| Check if entry condition is met                                  |
//+------------------------------------------------------------------+
bool CheckEntryCondition(string TradeType)
  {
   double Pivot=iCustomGet(handle_iCustom_Pivot,3,0);  // Pivot buffer "Pivot"
   double line=iCustomGet(handle_iCustom_Heiken,1,0); // Heiken Ashi buffer "line"
   double average=iCustomGet(handle_iCustom_Heiken,2,0); // Heiken Ashi buffer "average"
//---
   bool YesTrade=false;
   if(TradeType=="BUY")
     {
      if(line>average && m_symbol.Bid()<Pivot)
         YesTrade=true;
     }
   if(TradeType=="SELL")
     {
      if(line<average && m_symbol.Bid()>Pivot)
         YesTrade=true;
     }
   return(YesTrade);
  }
//+------------------------------------------------------------------+
//| Handle Open Positions                                            |
//| Check if any open positions need to be closed or modified        |
//+------------------------------------------------------------------+
void HandleOpenPositions()
  {
   int count_buys=0;
   int count_sells=0;
   CalculatePositions(count_buys,count_sells);
   bool exit_buy=false;
   bool exit_sell=false;
   if(count_buys>0)
      exit_buy=CheckExitCondition("BUY");
   if(count_sells>0)
      exit_sell=CheckExitCondition("SELL");

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(exit_buy)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                 }
               else
                 {
                  if(InpTrailingType!=type_0)
                    {
                     HandleTrailingStop("BUY",m_position.Ticket(),m_position.PriceOpen(),
                                        m_position.StopLoss(),m_position.TakeProfit());
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(exit_sell)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                 }
               else
                 {
                  if(InpTrailingType!=type_0)
                    {
                     HandleTrailingStop("SELL",m_position.Ticket(),m_position.PriceOpen(),
                                        m_position.StopLoss(),m_position.TakeProfit());
                    }
                 }
              }
           }
  }
//+------------------------------------------------------------------+
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys,int &count_sells)
  {
   count_buys=0;
   count_sells=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| HandleTrailingStop                                               |
//| Type 1 moves the stoploss without delay.                         |
//| Type 2 waits for price to move the amount of the trailStop       |
//| before moving stop loss then moves like type 1                   |
//| Type 3 uses up to 3 levels for trailing stop                     |
//|      Level 1 Move stop to 1st level                              |
//|      Level 2 Move stop to 2nd level                              |
//|      Level 3 Trail like type 1 by fixed amount other than 1      |
//+------------------------------------------------------------------+
void HandleTrailingStop(string type,ulong ticket,double op,double os,double tp)
  {
   double pt,TS=0;
//---
   if(type=="BUY")
     {
      switch(InpTrailingType)
        {
         case type_1:
            pt=ExtStopLoss;
            if(m_symbol.Bid()-os>pt)
               ModifyStopLoss(ticket,op,m_symbol.Bid()-pt,tp);
            break;
         case type_2:
            pt=ExtTrailingStop;
            if(m_symbol.Bid()-op>pt)
              {
               if(os<m_symbol.Bid()-pt || os==0)
                  ModifyStopLoss(ticket,op,m_symbol.Bid()-pt,tp);
              }
            break;
         case type_3:
            if(m_symbol.Bid()-op>ExtFirstMove)
              {
               TS=op+ExtFirstMove-ExtFirstStopLoss;
               if(os<TS)
                 {
                  ModifyStopLoss(ticket,op,TS,tp);
                 }
              }
            if(m_symbol.Bid()-op>ExtSecondMove)
              {
               TS=op+ExtSecondMove-ExtSecondStopLoss;
               if(os<TS)
                 {
                  ModifyStopLoss(ticket,op,TS,tp);
                 }
              }
            if(m_symbol.Bid()-op>ExtThirdMove)
              {
               TS=m_symbol.Bid()-ExtTrailingStop3;
               if(os<TS)
                 {
                  ModifyStopLoss(ticket,op,TS,tp);
                 }
              }
            break;
        }
     }
   if(type=="SELL")
     {
      switch(InpTrailingType)
        {
         case type_1:
            pt=ExtStopLoss;
            if(os-m_symbol.Ask()>pt)
               ModifyStopLoss(ticket,op,m_symbol.Ask()+pt,tp);
            break;
         case type_2:
            pt=ExtTrailingStop;
            if(op-m_symbol.Ask()>pt)
              {
               if(os>m_symbol.Ask()+pt || os==0)
                  ModifyStopLoss(ticket,op,m_symbol.Ask()+pt,tp);
              }
            break;
         case type_3:
            if(op-m_symbol.Ask()>ExtFirstMove)
              {
               TS=op-ExtFirstMove+ExtFirstStopLoss;
               if(os>TS)
                 {
                  ModifyStopLoss(ticket,op,TS,tp);
                 }
              }
            if(op-m_symbol.Ask()>ExtSecondMove)
              {
               TS=op-ExtSecondMove+ExtSecondStopLoss;
               if(os>TS)
                 {
                  ModifyStopLoss(ticket,op,TS,tp);
                 }
              }
            if(op-m_symbol.Ask()>ExtThirdMove)
              {
               TS=m_symbol.Ask()+ExtTrailingStop3;
               if(os>TS)
                 {
                  ModifyStopLoss(ticket,op,TS,tp);
                 }
              }
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Modify Open Position Controls                                    |
//|  Try to modify position 3 times                                  |
//+------------------------------------------------------------------+
void ModifyStopLoss(ulong ticket,double op,double sl,double tp)
  {
//---
   if(!m_trade.PositionModify(ticket,m_symbol.NormalizePrice(sl),tp))
      Print("Modify ",ticket,
            " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription());
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Buy(InpLots,m_symbol.Name(),m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print(__FUNCTION__,", #1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print(__FUNCTION__,", #2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< Lots (",DoubleToString(InpLots,2),")");
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Sell(InpLots,m_symbol.Name(),m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print(__FUNCTION__,", #1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print(__FUNCTION__,", #2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< Lots (",DoubleToString(InpLots,2),")");
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResult(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result: "+trade.ResultRetcodeDescription());
   Print("deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("current bid price: "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("current ask price: "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("broker comment: "+trade.ResultComment());
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime Time(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0; // datetime "0" -> D'1970.01.01 00:00:00'
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0)
      time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
