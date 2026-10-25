//+------------------------------------------------------------------+
//|                            JS-Chaos(barabashkakvn's edition).mq5 |
//|                                               Copyright © Сергей |
//|                                               http://wsforex.ru/ |
//+------------------------------------------------------------------+
#property copyright "wsforex@list.ru"
#property link      "http://wsforex.ru/"
#property version   "3.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object
//+------------------------------------------------------------------+
//| Enum hours                                                       |
//+------------------------------------------------------------------+
enum ENUM_HOURS
  {
   hour_00  =0,   // 00
   hour_01  =1,   // 01
   hour_02  =2,   // 02
   hour_03  =3,   // 03
   hour_04  =4,   // 04
   hour_05  =5,   // 05
   hour_06  =6,   // 06
   hour_07  =7,   // 07
   hour_08  =8,   // 08
   hour_09  =9,   // 09
   hour_10  =10,  // 10
   hour_11  =11,  // 11
   hour_12  =12,  // 12
   hour_13  =13,  // 13
   hour_14  =14,  // 14
   hour_15  =15,  // 15
   hour_16  =16,  // 16
   hour_17  =17,  // 17
   hour_18  =18,  // 18
   hour_19  =19,  // 19
   hour_20  =20,  // 20
   hour_21  =21,  // 21
   hour_22  =22,  // 22
   hour_23  =23,  // 23
  };
//--- input parameters
input bool        InpExpertTime     = true;     // Use time
input ENUM_HOURS  InpOpenHour       = hour_07;  // Open hour
input ENUM_HOURS  InpCloseHour      = hour_18;  // Close hour
input double      InpLots           = 0.1;      // Lots
input ushort      InpIndenting      = 0;        // Indenting from fractals(in pips)
input double      InpFibo_1         = 1.618;    // Fibo_1  
input double      InpFibo_2         = 4.618;    // Fibo_2
input bool        InpClosePos       = true;     // Use close positions
input bool        InpTrailing       = true;     // Use trailing 
input bool        InpBreakeven      = true;     // Use breakeven  
input ushort      InpBreakevenPlus  = 1;        // Breakeven plus (in pips)
input ulong       m_magic           = 321232123;// magic number
//---
ulong             m_slippage=30;       // slippage

double            ExtIndenting=0.0;
double            ExtBreakevenPlus=0.0;
//---
bool              EaDisabled=false;
string            com;
double            Lips;
double            ma_21_=0;
int               handle_iFractals;                // variable for storing the handle of the iFractals indicator 
int               handle_iMA;                      // variable for storing the handle of the iMA indicator 
int               handle_iAC;                      // variable for storing the handle of the iAC indicator 
int               handle_iAlligator;               // variable for storing the handle of the iAlligator indicator 
int               handle_iAO;                      // variable for storing the handle of the iAO indicator 
int               handle_iStdDev;                  // variable for storing the handle of the iStdDev indicator 
double            m_adjusted_point;                // point value adjusted for 3 or 5 points
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
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtIndenting=InpIndenting*m_adjusted_point;
   ExtBreakevenPlus=InpBreakevenPlus*m_adjusted_point;
//--- create handle of the indicator iFractals
   handle_iFractals=iFractals(m_symbol.Name(),Period());
//--- if the handle is not created 
   if(handle_iFractals==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iFractals indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),Period(),21,0,MODE_SMMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iAC
   handle_iAC=iAC(m_symbol.Name(),Period());
//--- if the handle is not created 
   if(handle_iAC==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAC indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iAlligator
   handle_iAlligator=iAlligator(m_symbol.Name(),Period(),13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iAlligator==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAlligator indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iAO
   handle_iAO=iAO(m_symbol.Name(),Period());
//--- if the handle is not created 
   if(handle_iAO==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAO indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStdDev   
   handle_iStdDev=iStdDev(m_symbol.Name(),Period(),10,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iStdDev==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStdDev indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
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
   if(!RefreshRates())
      return;
//---
   com="JS-Chaos";
//---        
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
   Comment("\n\n\n",
           "The adviser of \"JS-Chaos\" all in work: - ",IIcm(IsTradetime(str1) && !EaDisabled),"\n",
           "Day: - ",Dayof(str1),"\n",
           "Trade mode: - ",TradeMode(),"\n",
           "Time GMT: - "+TimeToString(TimeGMT(str1),TIME_SECONDS),"\n",
           "Spread: - ",m_symbol.Spread(),"\n",
           "StopLevel: - ",m_symbol.StopsLevel(),"\n",
           "Leverage: - ",m_account.Leverage()
           );
//---
   Lips=iAlligatorGet(GATORLIPS_LINE,0);
   ma_21_=iMAGet(0);
   if(InpTrailing)
      TrailingMA();
   if(InpBreakeven)
      ModifyBreakeven();
//--- 
   double fractals_up=FractalsUp(10);
   double fractals_down=FractalsDown(10);
   if(IsTradetime(str1) && !EaDisabled)
     {
      double tp,lots;
      //--- placing BUYSTOP pending orders
      if(fractals_up!=0.0)
         if(Signals()==1 && fractals_up>Lips && CalculatePendingOrders(ORDER_TYPE_BUY_STOP)==0 &&
            CalculatePositions(POSITION_TYPE_BUY)==0)
           {
            tp=Lips+(fractals_up-Lips)*InpFibo_1;
            lots=InpLots*2.0;
            if(tp>0 && tp-fractals_up>1.0*m_adjusted_point && fractals_up-Lips>1.0*m_adjusted_point && 
               m_symbol.Ask()+1.0*m_adjusted_point<fractals_up)
               if(m_trade.BuyStop(lots,fractals_up,m_symbol.Name(),
                  m_symbol.NormalizePrice(Lips),
                  m_symbol.NormalizePrice(tp)))
                  if(m_trade.ResultOrder()==0)
                    {
                     for(int i=GlobalVariablesTotal()-1;i>-0;i--)
                       {
                        string name=GlobalVariableName(i);
                        if(StringFind(name,"Ticket.buy.1 "+m_symbol.Name(),0)!=-1)
                           GlobalVariableDel(name);
                       }
                     GlobalVariableSet("Ticket.buy.1 "+m_symbol.Name()+IntegerToString(m_trade.ResultOrder()),0.0);
                    }
           }
      //--- placing OP_SELLSTOP pending orders
      if(fractals_down!=0.0)
         if(Signals()==2 && fractals_down<Lips && CalculatePendingOrders(ORDER_TYPE_SELL_STOP)==0 && 
            CalculatePositions(POSITION_TYPE_SELL)==0)
           {
            tp=Lips-(Lips-fractals_down)*InpFibo_1;
            lots=InpLots*2.0;
            if(tp>0 && fractals_down-tp>1.0*m_adjusted_point && Lips-fractals_down>1.0*m_adjusted_point && 
               m_symbol.Bid()-1.0*m_adjusted_point>fractals_down)
               if(m_trade.SellStop(lots,fractals_down,m_symbol.Name(),
                  m_symbol.NormalizePrice(Lips),
                  m_symbol.NormalizePrice(tp)))
                  if(m_trade.ResultOrder()==0)
                    {
                     for(int i=GlobalVariablesTotal()-1;i>-0;i--)
                       {
                        string name=GlobalVariableName(i);
                        if(StringFind(name,"Ticket.sel.1 "+m_symbol.Name(),0)!=-1)
                           GlobalVariableDel(name);
                       }
                     GlobalVariableSet("Ticket.sel.1 "+m_symbol.Name()+IntegerToString(m_trade.ResultOrder()),0.0);
                    }
           }
      //--- placing a second BUYSTOP pending orders
      if(fractals_up!=0.0)
         if(Signals()==1 && fractals_up>Lips && CalculatePendingOrders(ORDER_TYPE_BUY_STOP)==1 &&
            CalculatePositions(POSITION_TYPE_BUY)==0 && IsPendingOrder("Ticket.buy.1 "+m_symbol.Name()))
           {
            tp=Lips+(fractals_up-Lips)*InpFibo_2;
            lots=InpLots*1;
            if(tp>0 && tp-fractals_up>1.0*m_adjusted_point && fractals_up-Lips>1.0*m_adjusted_point && 
               m_symbol.Ask()+1.0*m_adjusted_point<fractals_up)
              {
               if(m_trade.BuyStop(lots,fractals_up,m_symbol.Name(),
                  m_symbol.NormalizePrice(Lips),
                  m_symbol.NormalizePrice(tp)))
                  if(m_trade.ResultOrder()==0)
                    {
                     for(int i=GlobalVariablesTotal()-1;i>-0;i--)
                       {
                        string name=GlobalVariableName(i);
                        if(StringFind(name,"Ticket.buy.2 "+m_symbol.Name(),0)!=-1)
                           GlobalVariableDel(name);
                       }
                     GlobalVariableSet("Ticket.buy.2 "+m_symbol.Name()+IntegerToString(m_trade.ResultOrder()),0.0);
                    }
              }
           }
      //--- placing a second SELLSTOP pending orders
      if(fractals_down!=0.0)
         if(Signals()==2 && fractals_down<Lips && CalculatePendingOrders(ORDER_TYPE_SELL_STOP)==1 && 
            CalculatePositions(POSITION_TYPE_SELL)==0 && IsPendingOrder("Ticket.sel.1 "+m_symbol.Name()))
           {
            tp=Lips-(Lips-fractals_down)*InpFibo_2;
            lots=InpLots*1;
            if(tp>0 && fractals_down-tp>1.0*m_adjusted_point && Lips-fractals_down>1.0*m_adjusted_point && 
               m_symbol.Bid()-1.0*m_adjusted_point>fractals_down)
              {
               if(m_trade.SellStop(lots,fractals_down,m_symbol.Name(),
                  m_symbol.NormalizePrice(Lips),
                  m_symbol.NormalizePrice(tp)))
                  if(m_trade.ResultOrder()==0)
                    {
                     for(int i=GlobalVariablesTotal()-1;i>-0;i--)
                       {
                        string name=GlobalVariableName(i);
                        if(StringFind(name,"Ticket.sel.2 "+m_symbol.Name(),0)!=-1)
                           GlobalVariableDel(name);
                       }
                     GlobalVariableSet("Ticket.sel.2 "+m_symbol.Name()+IntegerToString(m_trade.ResultOrder()),0.0);
                    }
              }
           }
      //---
      if(Signals()==2)
         DeleteOrders(ORDER_TYPE_BUY_STOP);
      if(Signals()==1)
         DeleteOrders(ORDER_TYPE_SELL_STOP);
      //---
      if(InpClosePos)
        {
         if(Lips>iOpen(m_symbol.Name(),Period(),1))
            ClosePositions(POSITION_TYPE_BUY);
         if(Lips<iOpen(m_symbol.Name(),Period(),1))
            ClosePositions(POSITION_TYPE_SELL);
        }
     }
  }
//+------------------------------------------------------------------+
//| Modify breakeven                                                 |
//+------------------------------------------------------------------+
void ModifyBreakeven()
  {
//---
   bool fbu=false;
   bool fsl=false;
   int cnt=OrdersTotal();

   ulong ticket_buy_1   = 0;
   ulong ticket_buy_2   = 0;
   ulong ticket_sell_1  = 0;
   ulong ticket_sell_2  = 0;
   for(int i=GlobalVariablesTotal()-1;i>-0;i--)
     {
      string name=GlobalVariableName(i);
      if(StringFind(name,"Ticket.buy.1 "+m_symbol.Name(),0)!=-1)
         ticket_buy_1=StringToInteger(StringSubstr(name,13+StringLen(m_symbol.Name())));
      if(StringFind(name,"Ticket.buy.2 "+m_symbol.Name(),0)!=-1)
         ticket_buy_2=StringToInteger(StringSubstr(name,13+StringLen(m_symbol.Name())));
      if(StringFind(name,"Ticket.sel.1 "+m_symbol.Name(),0)!=-1)
         ticket_sell_1=StringToInteger(StringSubstr(name,13+StringLen(m_symbol.Name())));
      if(StringFind(name,"Ticket.sel.2 "+m_symbol.Name(),0)!=-1)
         ticket_sell_2=StringToInteger(StringSubstr(name,13+StringLen(m_symbol.Name())));
     }
//---
   if(!m_position.SelectByTicket(ticket_buy_1))
      fbu=true;
   if(!m_position.SelectByTicket(ticket_sell_1))
      fsl=true;
//---
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(ticket_buy_2==m_position.Ticket() && fbu==true)
                  if(m_position.StopLoss()<m_position.PriceOpen())
                     if(m_position.PriceOpen()+ExtBreakevenPlus<=m_symbol.Bid())
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceOpen()+ExtBreakevenPlus),
                           m_position.TakeProfit()))
                           Print("ModifyBreakeven. Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                       }
              }
            else
              {
               if(ticket_sell_2==m_position.Ticket() && fsl==true)
                  if(m_position.StopLoss()>m_position.PriceOpen())
                     if(m_position.PriceOpen()-ExtBreakevenPlus>=m_symbol.Ask())
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceOpen()-ExtBreakevenPlus),
                           m_position.TakeProfit()))
                           Print("ModifyBreakeven. Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                       }
              }

           }
//---
   return;
  }
//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+
void TrailingMA()
  {
//---
   double AC_0=iACGet(0);
   double AC_1=iACGet(1);
   double AO_0=iAOGet(0);
   double AO_1=iAOGet(1);
//double ma_21_=iMAGet(0);
   double StdDev_0=iStdDevGet(0);
   double StdDev_1=iStdDevGet(1);
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if((m_position.StopLoss()==0.0) || ((!CompareDoubles(m_position.StopLoss(),ma_21_) && m_position.StopLoss()<ma_21_) && StdDev_0>StdDev_1 && AO_0>AO_1 && AC_0>AC_1))
                 {
                  if(ma_21_+1.0*m_adjusted_point<=m_symbol.Bid())
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(ma_21_),
                        m_position.TakeProfit()))
                        Print("TrailingMA. Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                 }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if((m_position.StopLoss()==0.0) || ((!CompareDoubles(m_position.StopLoss(),ma_21_) && m_position.StopLoss()>ma_21_) && StdDev_0>StdDev_1 && AO_0<AO_1 && AC_0<AC_1))
                 {
                  if(ma_21_-1.0*m_adjusted_point>=m_symbol.Ask())
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(ma_21_),
                        m_position.TakeProfit()))
                        Print("TrailingMA. Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                 }
              }
           }
//---
   return;
  }
//+------------------------------------------------------------------------------+
//|                   |
//+------------------------------------------------------------------------------+
string Dayof(MqlDateTime &str1)
  {
   string dd="";
   switch(str1.day_of_week)
     {
      case 1: dd = "Monday"; break;
      case 2: dd = "Tuesday"; break;
      case 3: dd = "Environment"; break;
      case 4: dd = "Thursday"; break;
      case 5: dd = "Friday"; break;
      case 6: dd = "Saturday"; break;
      case 7: dd = "Sunday"; break;
     }
   return(dd);
  }
//+------------------------------------------------------------------+
//| Signals                                                          |
//+------------------------------------------------------------------+
int Signals()
  {
//---
   double AC_1=iACGet(1);
   double AC_2=iACGet(2);
   double AO_0=iAOGet(0);
   double AO_1=iAOGet(1);
   double AO_2=iAOGet(2);
   double AL_Lips=iAlligatorGet(GATORLIPS_LINE,0);    // Lips
   double AL_Teeth=iAlligatorGet(GATORTEETH_LINE,0);  // Teeth
   double AL_Jaws=iAlligatorGet(GATORJAW_LINE,0);     // Jaws
//---
   if(AO_0>AO_1 && AO_1>0.0 && AL_Lips>AL_Teeth && AL_Teeth>AL_Jaws)
      return(1);
   if(AO_0<AO_1 && AO_1<0.0 && AL_Lips<AL_Teeth && AL_Teeth<AL_Jaws)
      return(2);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Calculate pending orders for symbol                              |
//+------------------------------------------------------------------+
int CalculatePendingOrders(ENUM_ORDER_TYPE order_type)
  {
   int total=0;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Calculate positions                                              |
//+------------------------------------------------------------------+
int CalculatePositions(ENUM_POSITION_TYPE position_type)
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==position_type)
               total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FractalsUp(int bars)
  {
   double arr_Fractals_UPPER[];
   ArraySetAsSeries(arr_Fractals_UPPER,true);   // the index "0" is the rightmost bar on the chart
   if(!iFractalsGet(UPPER_LINE,bars,arr_Fractals_UPPER))
      return(0.0);
   for(int i=0; i<bars; i++)
     {
      if(arr_Fractals_UPPER[i]!=EMPTY_VALUE)
         return(arr_Fractals_UPPER[i]+ExtIndenting);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FractalsDown(int bars)
  {
   double arr_Fractals_LOWER[];
   ArraySetAsSeries(arr_Fractals_LOWER,true);   // the index "0" is the rightmost bar on the chart
   if(!iFractalsGet(LOWER_LINE,bars,arr_Fractals_LOWER))
      return(0.0);
   for(int i=0; i<bars; i++)
     {
      if(arr_Fractals_LOWER[i]!=EMPTY_VALUE)
         return(arr_Fractals_LOWER[i]-ExtIndenting);
     }
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string IIcm(bool value)
  {
   if(value)
      return("Yes:");
   else
      return("No:");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TradeMode()
  {
   string text="";
   text=StringSubstr(EnumToString(m_account.TradeMode()),19);
   return(text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradetime(MqlDateTime &str1)
  {
//---
   bool TradingTime=false;
//---
   if(InpOpenHour>InpCloseHour)
      if(str1.hour<=InpCloseHour || str1.hour>=InpOpenHour)
         TradingTime=true;
   if(InpOpenHour<InpCloseHour)
      if(str1.hour>=InpOpenHour && str1.hour<=InpCloseHour)
         TradingTime=true;
   if(InpOpenHour==InpCloseHour)
      if(str1.hour==InpOpenHour)
         TradingTime=true;
   if(str1.day_of_week==1 && str1.hour<3)
      TradingTime=false;
   if(str1.day_of_week>=5 && str1.hour>18)
      TradingTime=false;
   if(str1.mon==1 && str1.day<10)
      TradingTime=false;
   if(str1.mon==12 && str1.day>20)
      TradingTime=false;
   if(!InpExpertTime)
      TradingTime=true;
// ---
   return(TradingTime);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsPendingOrder(string variable_name)
  {
   ulong ticket=0;
   for(int i=GlobalVariablesTotal()-1;i>-0;i--)
     {
      string name=GlobalVariableName(i);
      if(StringFind(name,variable_name,0)!=-1)
        {
         ticket=StringToInteger(StringSubstr(name,13+StringLen(m_symbol.Name())));
         if(m_order.Select(ticket))
            return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
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
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
// double min_volume=m_symbol.LotsMin();
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
// double max_volume=m_symbol.LotsMax();
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
// double volume_step=m_symbol.LotsStep();
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iFractals                           |
//|  the buffer numbers are the following:                           |
//|   0 - UPPER_LINE, 1 - LOWER_LINE                                 |
//+------------------------------------------------------------------+
bool iFractalsGet(const int buffer,const int count,double &buffer_fractals[])
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iFractalsBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iFractals,buffer,0,count,buffer_fractals)!=count)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iFractals indicator, error code %d",GetLastError());
      //--- quit with false result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iAC                                |
//+------------------------------------------------------------------+
double iACGet(const int index)
  {
   double AC[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iACBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iAC,0,index,1,AC)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iAC indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(AC[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iAlligator                          |
//|  the buffer numbers are the following:                           |
//|   0 - GATORJAW_LINE, 1 - GATORTEETH_LINE, 2 - GATORLIPS_LINE     |
//+------------------------------------------------------------------+
double iAlligatorGet(const int buffer,const int index)
  {
   double Alligator[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iAlligator,buffer,index,1,Alligator)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iAlligator indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Alligator[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iAO                                 |
//+------------------------------------------------------------------+
double iAOGet(const int index)
  {
   double AO[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iAO array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iAO,0,index,1,AO)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iAO indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(AO[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iStdDev                             |
//+------------------------------------------------------------------+
double iStdDevGet(const int index)
  {
   double StdDev[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStdDev array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(
      handle_iStdDev,// indicator handle 
      0,             // indicator buffer number 
      index,         // start position 
      1,             // amount to copy 
      StdDev         // target array to copy 
      )<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStdDev indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(StdDev[0]);
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,Digits())==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
