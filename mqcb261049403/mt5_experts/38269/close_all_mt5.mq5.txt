//+------------------------------------------------------------------+
//|                                                         CloseAll |
//|                                   Copyright 2022, Forex Bonnitta |
//|                                        https://t.me/BestAdvisors |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2022, Forex Bonnitta"
#property link        "https://t.me/BestAdvisors"
#property description "Due to recent popularity of Multi currencies EA, This codes allows to Close Orders or delete Pending orders of a Multi Currencies EA, Single Currency or Manual orders. Help : https://t.me/BestAdvisors"
#property version     "1.00"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
//---
CPositionInfo  m_position;                   // object of CPositionInfo class
CTrade         m_trade;                      // object of CTrade class
CSymbolInfo    m_symbol;
COrderInfo     m_order;
CDealInfo      m_deal;
//+------------------------------------------------------------------+
//| Enum Pos Type                                                    |
//+------------------------------------------------------------------+
enum ENUM_POS_TYPE
  {
   buy=0,      // ... only BUY positions
   sell=1,     // ... only SELL positions
   buy_sell=2, // ... BUY and SELL positions
  };
//+------------------------------------------------------------------+
//| Enum Profit In                                                   |
//+------------------------------------------------------------------+
enum ENUM_PROFIT_IN
  {
   pips=0,     // ... pips (1.00045-1.00055=1 pips)
   points=1,   // ... points (1.00045-1.00055=10 points)
   money=2,    // ... money deposit
  };
//--- input parameters
ENUM_POS_TYPE        InpPosType        = buy;         // Close positions:
ENUM_PROFIT_IN       InpProfitIn       = money;       // Profit in:
double               InpVolumeProfitIn = 3;           // Value 'Profit in'
ulong                InpDeviation      = 10;          // Deviation
ulong                InpMagic          = 0;   // Magic number

enum Mode
  {
   CloseALL,
   CloseALLandPending,
   CloseBUY,
   CloseSELL,
   CloseCurrency,
   CloseMagic,
   CloseTicket
  };

input string EAComment = "Bonnitta EA";
input Mode TypeOfClose = CloseALL;
input string Currency  = "";
input int Magic_Ticket = 1;
//---
ulong    m_arr_tickets[];                       // array tickets
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_trade.SetExpertMagicNumber(InpMagic);
   m_trade.SetDeviationInPoints(InpDeviation);

//---
   ObjectCreate(0,"CloseButton",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"CloseButton",OBJPROP_XDISTANCE,15);
   ObjectSetInteger(0,"CloseButton",OBJPROP_YDISTANCE,15);
   ObjectSetInteger(0,"CloseButton",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"CloseButton",OBJPROP_YSIZE,25);
//---
   ObjectSetString(0,"CloseButton",OBJPROP_TEXT,"Close Orders");
//---
   ObjectSetInteger(0,"CloseButton",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"CloseButton",OBJPROP_BGCOLOR,Red);
   ObjectSetInteger(0,"CloseButton",OBJPROP_BORDER_COLOR,Red);
   ObjectSetInteger(0,"CloseButton",OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,"CloseButton",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,"CloseButton",OBJPROP_STATE,false);
   ObjectSetInteger(0,"CloseButton",OBJPROP_FONTSIZE,12);
//--- Exit
   ObjectCreate(0,"Exit",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"Exit",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"Exit",OBJPROP_YDISTANCE,15);
   ObjectSetInteger(0,"Exit",OBJPROP_XSIZE,80);
   ObjectSetInteger(0,"Exit",OBJPROP_YSIZE,25);
//---
   ObjectSetString(0,"Exit",OBJPROP_TEXT,"Exit");
//---
   ObjectSetInteger(0,"Exit",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"Exit",OBJPROP_BGCOLOR,Green);
   ObjectSetInteger(0,"Exit",OBJPROP_BORDER_COLOR,Green);
   ObjectSetInteger(0,"Exit",OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,"Exit",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,"Exit",OBJPROP_STATE,false);
   ObjectSetInteger(0,"Exit",OBJPROP_FONTSIZE,12);
//---
   return(INIT_SUCCEEDED);
//---

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
//---
   int size_tickets=ArraySize(m_arr_tickets);
   if(size_tickets>0)
     {
      for(int i=size_tickets-1; i>=0; i--)
        {
         if(m_position.SelectByTicket(m_arr_tickets[i])) // selects the position by tickets for further access to its properties
            ClosePositions(m_arr_tickets[i]);
         else
           {
            ArrayRemove(m_arr_tickets,i,1);
           }
        }
      return;
     }
//---
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
        {
         ENUM_POSITION_TYPE pos_type=m_position.PositionType();
         if(pos_type==POSITION_TYPE_BUY)
           {
            if(InpPosType==sell)
               continue;
            if(InpProfitIn!=money)
              {
               //--- loss or profit
               double profit_in=GetProfitIn(m_position.Symbol());
               if(profit_in==0.0)
                  continue;
               if((InpVolumeProfitIn<0.0 && m_position.PriceCurrent()-m_position.PriceOpen()<=profit_in) ||
                  (InpVolumeProfitIn>0.0 && m_position.PriceCurrent()-m_position.PriceOpen()>=profit_in))
                 {
                  size_tickets=ArraySize(m_arr_tickets);
                  ArrayResize(m_arr_tickets,size_tickets+1,10);
                  m_arr_tickets[size_tickets]=m_position.Ticket();
                  continue;
                 }
              }
            else
              {
               double profit_in=m_position.Commission()+m_position.Swap()+m_position.Profit();
               //--- loss or profit
               if((InpVolumeProfitIn<0.0 && profit_in<=InpVolumeProfitIn) ||
                  (InpVolumeProfitIn>0.0 && profit_in>=InpVolumeProfitIn))
                 {
                  size_tickets=ArraySize(m_arr_tickets);
                  ArrayResize(m_arr_tickets,size_tickets+1,10);
                  m_arr_tickets[size_tickets]=m_position.Ticket();
                  continue;
                 }
              }
           }
         else
           {
            if(InpPosType==buy)
               continue;
            if(InpProfitIn!=money)
              {
               //--- loss or profit
               double profit_in=GetProfitIn(m_position.Symbol());
               if(profit_in==0.0)
                  continue;
               if((InpVolumeProfitIn<0.0 && m_position.PriceOpen()-m_position.PriceCurrent()<=profit_in) ||
                  (InpVolumeProfitIn>0.0 && m_position.PriceOpen()-m_position.PriceCurrent()>=profit_in))
                 {
                  size_tickets=ArraySize(m_arr_tickets);
                  ArrayResize(m_arr_tickets,size_tickets+1,10);
                  m_arr_tickets[size_tickets]=m_position.Ticket();
                  continue;
                 }
              }
            else
              {
               double profit_in=m_position.Commission()+m_position.Swap()+m_position.Profit();
               //--- loss or profit
               if((InpVolumeProfitIn<0.0 && profit_in<=InpVolumeProfitIn) ||
                  (InpVolumeProfitIn>0.0 && profit_in>=InpVolumeProfitIn))
                 {
                  size_tickets=ArraySize(m_arr_tickets);
                  ArrayResize(m_arr_tickets,size_tickets+1,10);
                  m_arr_tickets[size_tickets]=m_position.Ticket();
                  continue;
                 }
              }
           }
        }
//---
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
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check Freeze and Stops levels                                    |
//+------------------------------------------------------------------+
void FreezeStopsLevels(double &freeze,double &stops)
  {
//--- check Freeze and Stops levels

   double coeff=1;
   if(!RefreshRates() || !m_symbol.Refresh())
      return;
//--- FreezeLevel -> for pending order and modification
   double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
   if(freeze_level==0.0)
      freeze_level=(m_symbol.Ask()-m_symbol.Bid())*coeff;
//--- StopsLevel -> for TakeProfit and StopLoss
   double stop_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(stop_level==0.0)
      stop_level=(m_symbol.Ask()-m_symbol.Bid())*coeff;
//---
   freeze=freeze_level;
   stops=stop_level;
//---
   return;
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ulong icket)
  {
   double freeze=0.0,stops=0.0;
   FreezeStopsLevels(freeze,stops);

   bool take_profit_level=((m_position.TakeProfit()!=0.0 && m_position.TakeProfit()-m_position.PriceCurrent()>=freeze) || m_position.TakeProfit()==0.0);
   bool stop_loss_level=((m_position.StopLoss()!=0.0 && m_position.PriceCurrent()-m_position.StopLoss()>=freeze) || m_position.StopLoss()==0.0);
   if(take_profit_level && stop_loss_level)
      if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","CTrade.PositionClose ",m_position.Ticket());
  }
//+------------------------------------------------------------------+
//| Get Profit In                                                    |
//+------------------------------------------------------------------+
double GetProfitIn(const string name)
  {
   double m_profit_in            = 0.0;      // Profit in:        -> double
   double m_adjusted_point;                  // point value adjusted for 3 or 5 points
   if(!m_symbol.Name(name)) // sets symbol name
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: CSymbolInfo.Name");
      return(0.0);
     }
   RefreshRates();
//---
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
   if(InpProfitIn==pips) // Pips (1.00045-1.00055=1 pips)
      m_profit_in                = InpVolumeProfitIn           * m_adjusted_point;
   else
      if(InpProfitIn==points) // Points (1.00045-1.00055=10 points)
         m_profit_in             = InpVolumeProfitIn           * m_symbol.Point();
//---
   return(m_profit_in);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   int ticket=0;
   if(sparam=="CloseButton") // Close button has been pressed
     {

      int total = PositionsTotal()-1;
      for(int i=total; i>=0; i--)
        {
         if(m_position.SelectByIndex(i))
           {
            if(EAComment !="")
              {
               string cmmt = m_position.Comment();
               StringTrimLeft(cmmt);
               StringTrimRight(cmmt);

               if(StringFind(cmmt,EAComment) < 0)
                  continue;
              }

            if(TypeOfClose==CloseALL)
              {
               m_trade.PositionClose(m_position.Ticket());
              }

            if(TypeOfClose==CloseALLandPending)
              {
               m_trade.PositionClose(m_position.Ticket());
               for(int j=OrdersTotal(); j>=0; j--)
                 {
                  if(m_order.SelectByIndex(j))
                    {
                     if(EAComment !="")
                       {
                        string cmmt = m_order.Comment();
                        StringTrimLeft(cmmt);
                        StringTrimRight(cmmt);

                        if(StringFind(cmmt,EAComment) < 0)
                           continue;
                       }

                     m_trade.OrderDelete(m_order.Ticket());
                    }
                 }

              }

            if(TypeOfClose==CloseBUY)
              {
               if(m_position.PositionType()== POSITION_TYPE_BUY)
                  m_trade.PositionClose(m_position.Ticket());
              }

            if(TypeOfClose==CloseSELL)
              {
               if(m_position.PositionType()== POSITION_TYPE_SELL)
                  m_trade.PositionClose(m_position.Ticket());
              }

            if(TypeOfClose==CloseMagic && m_position.Magic()== Magic_Ticket)
              {
               m_trade.PositionClose(m_position.Ticket());
              }

            if(TypeOfClose==CloseTicket && m_position.Ticket()== Magic_Ticket)
              {
               m_trade.PositionClose(m_position.Ticket());
              }

            if(TypeOfClose==CloseCurrency)
              {
               if(Currency  == "" && m_position.Symbol()==_Symbol)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                 }

               if(Currency  != "" && m_position.Symbol()==Currency)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                 }
              }

           }
        }

      if(ticket>0)
        {
         ObjectSetInteger(0,"CloseButton",OBJPROP_STATE,false);
         //ObjectsDeleteAll();
         ExpertRemove();
        }

     }

   if(sparam=="Exit")
     {
      ObjectSetInteger(0,"Exit",OBJPROP_STATE,false);
      ObjectsDeleteAll(0);
      ExpertRemove();
     }
  }
//+------------------------------------------------------------------+
