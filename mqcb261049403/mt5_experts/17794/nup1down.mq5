//+------------------------------------------------------------------+
//|                                                     NUp1Down.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#property description "N bars up, then one bar down"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedMargin m_money;
//--- input parameters
input int      InpCount          = 3;        // N bars up
input ushort   InpTakeProfit     = 50;       // Take Profit (in pips)
input ushort   InpStopLoss       = 50;       // Stop Loss (in pips)
input double   InpRisk           = 5;        // risk
input ushort   InpTrailingStop   = 10;       // TrailingStop (in pips)
input ushort   InpTrailingStep   = 5;        // TrailingStep (in pips)
//---
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;
//---
ulong          m_ticket;
ulong          m_magic=78964589;             // magic number
ulong          m_slippage=30;                // slippage

ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//SetMarginMode();
//if(!IsHedging())
//  {
//   Print("Hedging only!");
//   return(INIT_FAILED);
//  }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtTrailingStep=InpTrailingStep*m_adjusted_point;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(InpRisk); // risk
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
//--- trailing of all ticks
   Trailing();
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(m_symbol.Name(),Period(),1,InpCount+1,rates);
   if(copied<InpCount+1)
      return;
//--- testing
//string text="Bars copied: "+copied+"\n";
//string format="open = %G, high = %G, low = %G, close = %G, volume = %d";
//string out;
//int size=fmin(copied,10);
//for(int i=0;i<size;i++)
//  {
//   out+=i+":"+TimeToString(rates[i].time);
//   out+=" "+StringFormat(format,
//                         rates[i].open,
//                         rates[i].high,
//                         rates[i].low,
//                         rates[i].close,
//                         rates[i].tick_volume)+"\n";
//  }
//Comment(text+out);
   if(rates[0].close<rates[0].open) // last bar down
     {
      bool result=false;
      for(int i=1;i<InpCount+1;i++)
        {
         //--- all "bullish" bars and bars higher than the previous??
         if(i<InpCount)
            result=(rates[i].close>rates[i].open && rates[i].close>rates[i+1].close);
         else
            result=(rates[i].close>rates[i].open);

         if(!result)
            break;
        }
      //--- all 
      if(result)
        {
         if(!RefreshRates())
           {
            PrevBars=iTime(1);
            return;
           }
         OpenSell(m_symbol.Bid()+InpStopLoss*m_adjusted_point,m_symbol.Bid()-InpTakeProfit*m_adjusted_point);
        }
     }
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
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_short_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(!RefreshRates())
               return;
            //--- TrailingStop -> подтягивание StopLoss у ПРИБЫЛЬНОЙ позиции
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               //--- когда у позиции ещё нет StopLoss
               if(m_position.StopLoss()==0)
                 {
                  //--- пока StopLoss равен 0.0, TrailingStep не учитываем
                  if(m_symbol.Bid()-ExtTrailingStop>m_position.PriceOpen())
                    {
                     //--- модификация позиции
                     m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),0.0);
                    }
                 }
               //--- у позиции уже есть StopLoss
               else
                 {
                  //--- теперь TrailingStep нужно учитывать, иначе мы будет модифицировать 
                  //--- поизцию НА КАЖДОМ ТИКЕ, а это ПЛОХО
                  if(m_symbol.Bid()-ExtTrailingStop-ExtTrailingStep>m_position.StopLoss())
                    {
                     //--- модификация позиции
                     m_trade.PositionModify(m_position.Ticket(),
                                            NormalizeDouble(m_symbol.Bid()-ExtTrailingStop,m_symbol.Digits()),0.0);
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               //--- когда у позиции ещё нет StopLoss
               if(m_position.StopLoss()==0)
                 {
                  //--- пока StopLoss равен 0.0, TrailingStep не учитываем
                  if(m_symbol.Ask()+ExtTrailingStop<m_position.PriceOpen())
                    {
                     //--- модификация позиции
                     m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),0.0);
                    }
                 }
               //--- у позиции уже есть StopLoss
               else
                 {
                  //--- теперь TrailingStep нужно учитывать, иначе мы будет модифицировать 
                  //--- поизцию НА КАЖДОМ ТИКЕ, а это ПЛОХО
                  if(m_symbol.Ask()+ExtTrailingStop+ExtTrailingStep<m_position.StopLoss())
                    {
                     //--- модификация позиции
                     m_trade.PositionModify(m_position.Ticket(),
                                            NormalizeDouble(m_symbol.Ask()+ExtTrailingStop,m_symbol.Digits()),0.0);
                    }
                 }
              }
           }
  }
//+------------------------------------------------------------------+
