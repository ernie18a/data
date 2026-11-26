//+------------------------------------------------------------------+
//|                       Proffessor v3(barabashkakvn's edition).mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // pending orders object
//--- input parameters
input double            InpLots           = 0.1;            // Lots
input double            InpCoefLot        = 1.0;            // Multiplication of volume 
input double            InpPlusLot        = 0.01;           // Addition of volume
input uchar             InpMaxLines       = 5;              // Max Lines (maximum number of pending orders in each direction)  
input int               InpPlusDelta      = -5;             // Grid distance increase factor
input double            InpDelta_1        = 70;             // Delta 1: distance to the safety of a pending order
input int               InpDelta_2        = 60;             // Delta 2: distance inside the grid
input double            ProfitClose       = 15.0;           // Profit Close: profit target 
input double            LossClose         = -150.0;         // Loss Close: maximum loss  
input double            f                 = 40;             // Level of flat ADX
input int               bar               = 2;              // Currenr bar ADX
input ENUM_TIMEFRAMES   InpWorkTimeFrame  = PERIOD_CURRENT; // Work TimeFrame
input uchar             InpStartHour      = 0;              // Start hour
input uchar             InpEndHour        = 24;             // End hour

input ulong    m_magic=166399440;// magic number
//---
ulong m_slippage=10;                // slippage

double ExtPlusDelta=0.0;
double ExtDelta_1=0.0;
double ExtDelta_2=0.0;

int    handle_iADX;                 // variable for storing the handle of the iADX indicator 

double m_adjusted_point;            // point value adjusted for 3 or 5 points

bool   m_close_all=false;
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

   ExtPlusDelta   = InpPlusDelta * m_adjusted_point;
   ExtDelta_1     = InpDelta_1   * m_adjusted_point;
   ExtDelta_2     = InpDelta_2   * m_adjusted_point;
//--- create handle of the indicator iADX
   handle_iADX=iADX(m_symbol.Name(),InpWorkTimeFrame,14);
//--- if the handle is not created 
   if(handle_iADX==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iADX indicator for the symbol %s/%s, error code %d",
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
   if(m_close_all)
     {
      if(IsPositionExists())
        {
         CloseAllPositions();
         return;
        }
      if(IsPendingOrdersExists())
        {
         DeleteAllPendingOrders();
         return;
        }
      m_close_all=false;
     }
//---
   if(!IsPositionExists())
     {
      if(!Time())
         return;
      double adx_main,adx_plus_di,adx_minus_di;
      if(!iADXGet(adx_main,adx_plus_di,adx_minus_di,bar))
         return;
      if(!RefreshRates())
         return;
      //---
      if(adx_main<f && adx_plus_di>adx_minus_di)//условие для покупки и определение флета
        {
         double Lots=InpLots;
         if(!OpenBuy(0.0,0.0))
            return;
         PendingOrder(ORDER_TYPE_SELL_STOP,Lots,m_symbol.Bid()-ExtDelta_1,0.0,0.0);

         for(int x=1;x<=InpMaxLines;x++)
           {
            double lot=LotCheck(Lots*InpCoefLot+InpPlusLot);
            if(lot==0.0)
               continue;
            PendingOrder(ORDER_TYPE_BUY_LIMIT,lot,m_symbol.Ask()-(ExtDelta_1+x*(ExtDelta_2+ExtPlusDelta*x/2.0)),0.0,0.0);
            PendingOrder(ORDER_TYPE_SELL_LIMIT,lot,m_symbol.Bid()+x*(ExtDelta_2+ExtPlusDelta*x/2.0),0.0,0.0);
           }
         int d=0;
        }
      else if(adx_main<f && adx_plus_di<adx_minus_di)//условие для продажи и определение флета
        {
         double Lots=InpLots;
         if(!OpenSell(0.0,0.0))
            return;
         PendingOrder(ORDER_TYPE_BUY_STOP,Lots,m_symbol.Ask()+ExtDelta_1,0.0,0.0);

         for(int x=1;x<=InpMaxLines;x++)
           {
            double lot=LotCheck(Lots*InpCoefLot+InpPlusLot);
            if(lot==0.0)
               continue;
            PendingOrder(ORDER_TYPE_BUY_LIMIT,lot,m_symbol.Ask()-x*(ExtDelta_2+ExtPlusDelta*x/2.0),0.0,0.0);
            PendingOrder(ORDER_TYPE_SELL_LIMIT,lot,m_symbol.Bid()+ExtDelta_1+x*(ExtDelta_2+ExtPlusDelta*x/2.0),0.0,0.0);
           }
         int d=0;
        }
      else if(adx_main>f && adx_plus_di>adx_minus_di)//условие для покупки и определение тренда
        {
         double Lots=InpLots;;
         if(!OpenBuy(0.0,0.0))
            return;
         PendingOrder(ORDER_TYPE_SELL_STOP,Lots,m_symbol.Bid()-ExtDelta_1,0.0,0.0);

         for(int x=1;x<=InpMaxLines;x++)
           {
            double lot=LotCheck(Lots*InpCoefLot+InpPlusLot);
            if(lot==0.0)
               continue;
            PendingOrder(ORDER_TYPE_SELL_STOP,lot,m_symbol.Bid()-(ExtDelta_1+x*(ExtDelta_2+ExtPlusDelta*x/2.0)),0.0,0.0);
            PendingOrder(ORDER_TYPE_BUY_STOP,lot,m_symbol.Ask()+x*(ExtDelta_2+ExtPlusDelta*x/2.0),0.0,0.0);
           }
         int d=0;
        }
      else if(adx_main>f && adx_plus_di<adx_minus_di)//условие для продажи и определение тренда
        {
         double Lots=InpLots;
         if(!OpenSell(0.0,0.0))
            return;
         PendingOrder(ORDER_TYPE_BUY_STOP,Lots,m_symbol.Ask()+ExtDelta_1,0.0,0.0);
         for(int x=1;x<=InpMaxLines;x++)
           {
            double lot=LotCheck(Lots*InpCoefLot+InpPlusLot);
            if(lot==0.0)
               continue;
            PendingOrder(ORDER_TYPE_SELL_STOP,lot,m_symbol.Bid()-x*(ExtDelta_2+ExtPlusDelta*x/2.0),0.0,0.0);
            PendingOrder(ORDER_TYPE_BUY_STOP,lot,m_symbol.Ask()+(ExtDelta_1+x*(ExtDelta_2+ExtPlusDelta*x/2.0)),0.0,0.0);
           }
         int d=0;
        }
      else
         return;
     }
   else
     {
      double profit=ProfitAllPositions();
      if(profit>ProfitClose || (LossClose!=0.0 && profit<LossClose))
         m_close_all=true;
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
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iADX                                |
//|  the buffer numbers are the following:                           |
//|    0 - MAIN_LINE, 1 - PLUSDI_LINE, 2 - MINUSDI_LINE              |
//+------------------------------------------------------------------+
bool iADXGet(double &main,double &plus_di,double &minus_di,const int index)
  {
   double ADX[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iADX,MAIN_LINE,index,1,ADX)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   else
      main=ADX[0];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iADX,PLUSDI_LINE,index,1,ADX)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   else
      plus_di=ADX[0];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iADX,MINUSDI_LINE,index,1,ADX)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   else
      minus_di=ADX[0];
//---
   return(true);
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
//| Is pendinf orders exists                                         |
//+------------------------------------------------------------------+
bool IsPendingOrdersExists(void)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(double sl,double tp)
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
               PrintResultTrade(m_trade,m_symbol);
               return(false);
              }
            else
              {
               Print(__FUNCTION__,", #2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResultTrade(m_trade,m_symbol);
               return(true);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
            return(false);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< Lots (",DoubleToString(InpLots,2),")");
         return(false);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return(false);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(double sl,double tp)
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
               PrintResultTrade(m_trade,m_symbol);
               return(false);
              }
            else
              {
               Print(__FUNCTION__,", #2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResultTrade(m_trade,m_symbol);
               return(true);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
            return(false);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< Lots (",DoubleToString(InpLots,2),")");
         return(false);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return(false);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("File: ",__FILE__,", symbol: ",m_symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
  }
//+------------------------------------------------------------------+
//| Pending order                                                    |
//+------------------------------------------------------------------+
void PendingOrder(ENUM_ORDER_TYPE order_type,double volume,double price,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   if(m_trade.OrderOpen(m_symbol.Name(),order_type,volume,0.0,
      m_symbol.NormalizePrice(price),m_symbol.NormalizePrice(sl),m_symbol.NormalizePrice(tp)))
     {
      if(m_trade.ResultOrder()==0)
        {
         Print("#1 ",EnumToString(order_type)," -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
        }
      else
        {
         Print("#2 ",EnumToString(order_type)," -> true. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      Print("#3 ",EnumToString(order_type)," -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription());
      PrintResultTrade(m_trade,m_symbol);
     }
//---
  }
//+------------------------------------------------------------------+
//| Profit all positions                                             |
//+------------------------------------------------------------------+
double  ProfitAllPositions()
  {
   double profit=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            profit+=m_position.Commission()+m_position.Swap()+m_position.Profit();
//---
   return(profit);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Delete all pending orders                                        |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Time()
  {
   MqlDateTime STimeCurrent;
   TimeToStruct(TimeCurrent(),STimeCurrent);
   if(InpStartHour<InpEndHour)
     {
      if(STimeCurrent.hour>=InpStartHour && STimeCurrent.hour<InpEndHour)
         return(true);
      else
         return(false);
     }
   else if(InpStartHour>InpEndHour)
     {
      if(STimeCurrent.hour>=InpEndHour && STimeCurrent.hour<InpStartHour)
         return(false);
      else
         return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
