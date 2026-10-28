//+------------------------------------------------------------------+
//|                           e-TurboFx(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "© 2007 RickD"
#property link      "www.e2e-fx.net"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input int      DepthAnalysis     = 3;        // Глубина анализа баров
input double   Lots              = 0.1;      // Lots
input ushort   InpStopLoss       = 70;       // StopLoss
input ushort   InpTakeProfit     = 120;      // TakeProfit
input ulong    InpSlippage       = 1;        // Slippage
input ulong    m_magic           = 50607;    // Magic Number
//---
double         ExtStopLoss       = 0.0;      // StopLoss
double         ExtTakeProfit     = 0.0;      // TakeProfit
ulong          ExtSlippage       = 0;        // Slippage
double         m_adjusted_point  = 0.0;      // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number

//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss       = InpStopLoss   * m_adjusted_point;
   ExtTakeProfit     = InpTakeProfit * m_adjusted_point;
   ExtSlippage       = InpSlippage   * digits_adjust;

   m_trade.SetDeviationInPoints(ExtSlippage);
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
   int BuyCnt=0;
   int SellCnt=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return; // если есть хоть одна позиция - выходим
//---
   int up_1=0;
   int up_2=0;
   int dw_1=0;
   int dw_2=0;

   for(int i=1; i<=DepthAnalysis; i++)
     {
      if(iClose(i)<iOpen(i))
         up_1++;
      if(iClose(i)>iOpen(i))
         dw_1++;

      if(i<DepthAnalysis)
        {
         if(MathAbs(iClose(i)-iOpen(i))>MathAbs(iClose(i+1)-iOpen(i+1)))
           {
            up_2++;
            dw_2++;
           }
        }
     }
//---
   if(!RefreshRates())
      return;

   if(up_1==DepthAnalysis && up_2==DepthAnalysis-1)
     {
      double sl=(ExtStopLoss>0.0) ? m_symbol.NormalizePrice(m_symbol.Ask()-ExtStopLoss) : 0;
      double tp=(ExtTakeProfit>0.0) ? m_symbol.NormalizePrice(m_symbol.Ask()+ExtTakeProfit) : 0;

      if(m_trade.Buy(Lots,NULL,m_symbol.Ask(),sl,tp,"e-TurboFX"))
        {
         Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription(),
               ", ticket of deal: ",m_trade.ResultDeal());
        }
      else
        {
         Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription(),
               ", ticket of deal: ",m_trade.ResultDeal());
        }
      return;
     }

   if(dw_1==DepthAnalysis && dw_2==DepthAnalysis-1)
     {
      double sl=(ExtStopLoss>0.0) ? m_symbol.NormalizePrice(m_symbol.Bid()+ExtStopLoss) : 0;
      double tp=(ExtTakeProfit>0.0) ? m_symbol.NormalizePrice(m_symbol.Bid()-ExtTakeProfit) : 0;

      if(m_trade.Sell(Lots,NULL,m_symbol.Bid(),sl,tp,"e-TurboFX"))
        {
         Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription(),
               ", ticket of deal: ",m_trade.ResultDeal());
        }
      else
        {
         Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription(),
               ", ticket of deal: ",m_trade.ResultDeal());
        }
      return;
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
//| Get Open for specified bar index                                 | 
//+------------------------------------------------------------------+ 
double iOpen(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Open[1];
   double open=0;
   int copied=CopyOpen(symbol,timeframe,index,1,Open);
   if(copied>0) open=Open[0];
   return(open);
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+
