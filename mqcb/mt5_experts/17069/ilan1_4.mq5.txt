//+------------------------------------------------------------------+
//|                   2008      Ilan1.4(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Nikisaki@yandex.ru"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
//---
input int     MMType=1;          // Тип ММ: 0-Lots, 1-как было в 1.2, 2-мартингейл (коэффициент LotExponent)
input bool    UseClose=false;    // закрытие по убытку PipStep. рекомендутся false 
input bool    UseAdd=true;       // переоткрытие с новым лотом. лот для переоткрытия считается по LotExponent независимо от MMType рекомендутся = true
input double  LotExponent=1.667; // умножение лотов в серии по експоненте для вывода в безубыток. первый лот 0.1, серия: 0.16, 0.26, 0.43 ...
input ushort  InpSlip=3;         // допустимое проскальзывание цены в пипсах
input double  Lots=0.1;          // теперь можно и микролоты 0.01 при этом если стоит 0.1 то следующий лот в серии будет 0.16
input int     LotsDigits=2;      // 2 - микролоты 0.01, 1 - мини лоты 0.1, 0 - нормальные лоты 1.0
input ushort  InpTakeProfit=96;  // Уровень прибыли в пипсах от цены открытия.
//--- этот параметр не работает
double  Stoploss=500; // 
input ushort  InpTrailStart=10;  // минимальная прибыль в пунктах каждой позиции, при превышении которой включатся трейлинг
input ushort  InpTrailStop=10;   // расстофние между ценой и StopLoss
input ushort  InpPipStep=30;     // растоянию в пипсах убытка на котором открываеться следующий ордер колена.
input int     MaxTrades=10;
input bool    UseEquityStop=false;
input double  TotalEquityRisk=10; //loss as a percentage of equity
input bool    UseTrailingStop=true;
input bool    UseTimeOut=false;
input double  MaxTradeOpenHours=48;
//----
int m_magic=12324;
double PriceTarget,StartEquity,BuyTarget,SellTarget;
double AveragePrice,SellLimit,BuyLimit;
double ClosePrice,Spread;
int flag;
string EAName="Ilan1/4";
datetime timeprev=0,time_expiration=0;
int NumOfTrades=0;
double iLots;

double Stopper=0;
bool TradeNow=false,LongTrade=false,ShortTrade=false;
bool NewOrdersPlaced=false;
//---
ulong  ExtSlip=0.0;
double ExtTakeProfit=0.0;
double ExtPipStep=0.0;
double ExtTrailStart=0.0;
double ExtTrailStop=0.0;
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number

//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtSlip        =InpSlip       * digits_adjust;
   ExtTakeProfit  =InpTakeProfit * digits_adjust;
   ExtPipStep     =InpPipStep    * digits_adjust;
   ExtTrailStart  =InpTrailStart * digits_adjust;
   ExtTrailStop   =InpTrailStop  * digits_adjust;

   m_trade.SetDeviationInPoints(ExtSlip);

   Spread=m_symbol.Spread()*Point();
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
   if(UseTrailingStop)
     {
      TrailingAlls(ExtTrailStart,ExtTrailStop,AveragePrice);
     }
   if(UseTimeOut)
     {
      if(TimeCurrent()>=time_expiration)
        {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
        }
     }
   if(timeprev==iTime(m_symbol.Name(),Period(),0))
     {
      return;
     }
   timeprev=iTime(m_symbol.Name(),Period(),0);
//---
   double CurrentPairProfit=CalculateProfit();
   if(UseEquityStop)
     {
      if(CurrentPairProfit<0 && MathAbs(CurrentPairProfit)>(TotalEquityRisk/100)*AccountEquityHigh())
        {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         NewOrdersPlaced=false;
        }
     }
   int total=CountTrades();
//---
   if(total==0)
     {
      flag=0;
     }
   double LastBuyLots=0.0;
   double LastSellLots=0.0;
   double LastBuyPrice=0.0;
   double LastSellPrice=0.0;
//--- поиск последнего объёма и последней цены для BUY и SELL
   GetLasts(LastBuyLots,LastSellLots,LastBuyPrice,LastSellPrice);

   if(total>0 && total<=MaxTrades)
     {
      if(!RefreshRates())
         return;

      if(LongTrade && (LastBuyPrice-m_symbol.Ask())>=(ExtPipStep*Point()))
        {
         TradeNow=true;
        }
      if(ShortTrade && (m_symbol.Bid()-LastSellPrice)>=(ExtPipStep*Point()))
        {
         TradeNow=true;
        }
     }
   if(total<1)
     {
      ShortTrade=true;
      LongTrade=true;
      TradeNow=true;
      StartEquity=m_account.Equity();
     }
   if(TradeNow)
     {
      if(!RefreshRates())
         return;

      if(ShortTrade)
        {
         if(UseClose)
           {
            PositionClose(false,true);
            iLots=NormalizeDouble(LotExponent*LastSellLots,LotsDigits);
           }
         else
           {
            iLots=fGetLots(ORDER_TYPE_SELL);
           }
         if(UseAdd)
           {
            NumOfTrades=total;
            if(iLots>0)
              {//#
               if(!m_trade.Sell(iLots,m_symbol.Name(),m_symbol.Bid(),0.0,0.0,EAName+"-"+IntegerToString(NumOfTrades)))
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                  return;
                 }
               //LastSellPrice=FindLastSellPrice();
               TradeNow=false;
               NewOrdersPlaced=true;
               return;
              }//#
           }
        }
      else if(LongTrade)
        {
         if(UseClose)
           {
            PositionClose(true,false);
            iLots=NormalizeDouble(LotExponent*LastBuyLots,LotsDigits);
           }
         else
           {
            iLots=fGetLots(ORDER_TYPE_BUY);
           }
         if(UseAdd)
           {
            NumOfTrades=total;
            if(iLots>0)
              {//#
               if(!m_trade.Buy(iLots,m_symbol.Name(),m_symbol.Ask(),0.0,0.0,EAName+"-"+IntegerToString(NumOfTrades)))
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                  return;
                 }
               //LastBuyPrice=FindLastBuyPrice();
               TradeNow=false;
               NewOrdersPlaced=true;
               return;
              }//#
           }
        }
     }

   if(TradeNow && total<1)
     {
      double PrevCl=iClose(m_symbol.Name(),Period(),2);
      double CurrCl=iClose(m_symbol.Name(),Period(),1);

      if(!RefreshRates())
         return;

      SellLimit=m_symbol.Bid();
      BuyLimit=m_symbol.Ask();
      if(!ShortTrade && !LongTrade)
        {
         NumOfTrades=total;
         if(PrevCl>CurrCl)
           {
            iLots=fGetLots(ORDER_TYPE_SELL);
            if(iLots>0)
              {//#
               if(!m_trade.Sell(iLots,m_symbol.Name(),SellLimit,0,0,EAName+"-"+IntegerToString(NumOfTrades)))
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                  return;
                 }
               //LastBuyPrice=FindLastBuyPrice();
               NewOrdersPlaced=true;
              }//#
           }
         else
           {
            iLots=fGetLots(ORDER_TYPE_BUY);
            if(iLots>0)
              {//#      
               if(!m_trade.Buy(iLots,m_symbol.Name(),BuyLimit,0,0,EAName+"-"+IntegerToString(NumOfTrades)))
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                  return;
                 }
               //LastSellPrice=FindLastSellPrice();
               NewOrdersPlaced=true;
              }//#
           }
        }
      time_expiration=(datetime)(TimeCurrent()+MaxTradeOpenHours*60*60);
      TradeNow=false;
      return;
     }
//--- CALCULATE AVERAGE OPENING PRICE
   total=0;
   AveragePrice=0.0;
   double Count=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            AveragePrice+=m_position.PriceOpen()*m_position.Volume();
            Count+=m_position.Volume();
            total++;
           }
   if(total>0)
      AveragePrice=NormalizeDouble(AveragePrice/Count,Digits());
//--- RECALCULATE STOPLOSS & PROFIT TARGET BASED ON AVERAGE OPENING PRICE
   if(NewOrdersPlaced)
     {
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY) // Calculate profit/stop target for long 
                 {
                  PriceTarget=AveragePrice+(ExtTakeProfit*Point());
                  BuyTarget=PriceTarget;
                  Stopper=AveragePrice-(Stoploss*Point());
                  //      Stopper=0; 
                  flag=1;
                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL) // Calculate profit/stop target for short
                 {
                  PriceTarget=AveragePrice-(ExtTakeProfit*Point());
                  SellTarget=PriceTarget;
                  Stopper=AveragePrice+(Stoploss*Point());
                  //      Stopper=0; 
                  flag=1;
                 }
              }
     }
//--- IF NEEDED CHANGE ALL OPEN ORDERS TO NEWLY CALCULATED PROFIT TARGET    
   if(NewOrdersPlaced)
      if(flag==1)// check if average has really changed
        {
         for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
            if(m_position.SelectByIndex(i))
               if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
                 {
                  m_trade.PositionModify(m_position.Ticket(),m_position.StopLoss(),PriceTarget);
                  NewOrdersPlaced=false;
                 }
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ND(double v)
  {
   return(NormalizeDouble(v,Digits()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionClose(bool aCloseBuy=true,bool aCloseSell=true)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY && aCloseBuy)
              {
               m_trade.PositionClose(m_position.Ticket());
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL && aCloseSell)
              {
               m_trade.PositionClose(m_position.Ticket());
              }
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fGetLots(ENUM_ORDER_TYPE aTradeType)
  {
   double tLots=0.0;
   switch(MMType)
     {
      case 0:
         tLots=Lots;
         break;
      case 1:
         tLots=NormalizeDouble(Lots*MathPow(LotExponent,NumOfTrades),LotsDigits);
         break;
      case 2:
        {
         datetime LastClosedTime=0;
         tLots=Lots;
         //--- request trade history 
         HistorySelect(TimeCurrent()-86400,TimeCurrent()+86400);
         uint     total=HistoryDealsTotal();
         //--- for all deals 
         for(uint i=0;i<total;i++)
           {
            if(m_deal.SelectByIndex(i))
               if(m_deal.Symbol()==m_symbol.Name() && m_deal.Magic()==m_magic && m_deal.Entry()==DEAL_ENTRY_OUT)
                 {
                  if(LastClosedTime<m_deal.Time())
                    {
                     LastClosedTime=m_deal.Time();
                     if(m_deal.Profit()<0)
                        tLots=NormalizeDouble(m_deal.Volume()*LotExponent,LotsDigits);
                     else
                        tLots=Lots;
                    }
                 }
           }
        }
      break;
     }
   if(!RefreshRates())
      return(0);

   double margin=0.0;
   double price=0.0;
   if(aTradeType==ORDER_TYPE_BUY)
      price=m_symbol.Ask();
   if(aTradeType==ORDER_TYPE_SELL)
      price=m_symbol.Bid();
   if(!OrderCalcMargin(aTradeType,m_symbol.Name(),tLots,price,margin))
     {
      return(0);
     }
   else
     {
      double free_margin=m_account.FreeMargin();
      if(margin>=m_account.FreeMargin())
         return(0);
     }
   return(tLots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades()
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopLong(double price,int stop)
  {
   if(stop==0)
      return(0);
   else
      return(price-(stop*Point()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StopShort(double price,int stop)
  {
   if(stop==0)
      return(0);
   else
      return(price+(stop*Point()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeLong(double price,int take)
  {
   if(take==0)
      return(0);
   else
      return(price+(take*Point()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeShort(double price,int take)
  {
   if(take==0)
      return(0);
   else
      return(price-(take*Point()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit()
  {
   double Profit=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            Profit+=m_position.Profit();
   return(Profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls(double start,double stop,double AvgPrice)
  {
//--- минимальная прибыль в пунктах каждой позиции, при превышении которой включатся трейлинг
//--- то есть если каждая поиция имеет прибыль больше минимального уровня, то будет включён трейлинг
   int profit=0;
   bool trailing=true;
   double stoptrade;
   double stopcal;
   if(stop==0)
      return;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.Profit()<0)
              {
               trailing=false;
               break;
              }
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if((m_position.PriceCurrent()-m_position.PriceOpen())/Point()<start)
                 {
                  trailing=false;
                  break;
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if((m_position.PriceOpen()-m_position.PriceCurrent())/Point()<start)
                 {
                  trailing=false;
                  break;
                 }
              }
           }

   if(!trailing) // не все позиции прибыльны или не все позиции имеют прибыль более уровня "start"
      return;

   if(!RefreshRates())
      return;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               stoptrade= m_position.StopLoss();
               stopcal  = m_symbol.Bid()-(stop*Point());
               if(stoptrade==0 || (stoptrade!=0 && stopcal>stoptrade))
                  m_trade.PositionModify(m_position.Ticket(),stopcal,m_position.TakeProfit());
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               stoptrade= m_position.StopLoss();
               stopcal  = m_symbol.Ask()+(stop*Point());
               if(stoptrade==0 || (stoptrade!=0 && stopcal<stoptrade))
                  m_trade.PositionModify(m_position.Ticket(),stopcal,m_position.TakeProfit());
              }
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquityHigh()
  {
   static double AccountEquityHighAmt,PrevEquity;
   if(CountTrades()==0)
      AccountEquityHighAmt=m_account.Equity();

   if(AccountEquityHighAmt<PrevEquity)
      AccountEquityHighAmt=PrevEquity;
   else
      AccountEquityHighAmt=m_account.Equity();

   PrevEquity=m_account.Equity();

   return(AccountEquityHighAmt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetLasts(double &buy_lots,double &sell_lots,double &buy_price,double &sell_price)
  {
   buy_lots=0.0;
   sell_lots=0.0;
   buy_price=0.0;
   sell_price=0.0;

   ulong  TimeMsc_buy=0;
   ulong  TimeMsc_sell=0;

//--- поиск по времени открытия (msc)
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.TimeMsc()>TimeMsc_buy)
                 {
                  TimeMsc_buy=m_position.TimeMsc();
                  buy_lots=m_position.Volume();
                  buy_price=m_position.PriceOpen();
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.TimeMsc()>TimeMsc_sell)
                 {
                  TimeMsc_sell=m_position.TimeMsc();
                  sell_lots=m_position.Volume();
                  sell_price=m_position.PriceOpen();
                 }
              }
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
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
