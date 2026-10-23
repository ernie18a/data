//+------------------------------------------------------------------+
//|                                                 ArbSynthetic.mq5 |
//|                                   Copyright 2016, Dmitrievsky Max|
//|                        https://www.mql5.com/ru/users/dmitrievsky |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Dmitrievsky Max."
#property link      "https://www.mql5.com/ru/users/dmitrievsky"
#property version   "1.5"
#property strict

#include <Trade\Trade.mqh>        
#include <Trade\PositionInfo.mqh> 
#include <Trade\AccountInfo.mqh>

CTrade            m_Trade;
CPositionInfo     m_Position;
CAccountInfo myaccount;
CPositionInfo myposition;

input int spread=35;      //Spread deviations in points (between synthetic and base pair)

double MedianEURUSD, MedianGBPUSD, MedianEURGBP, MedianSynthetic, 
       Diff, EURdiff, GBPdiff, GBPsynthetic, EURsynthetic, 
       DiffMax, DiffMin, EurDiffMax, EurDiffMin, GbpDiffMax, GbpDiffMin; 
long msTime,esTime,gsTime,mEur,mGbp,mEurGbp,timeDiff,timeEurDiff,timeGbpDiff;

MqlTick tickEUR,tickGBP,tickEURGBP;

void OnTick()
  {    
   if(!SymbolInfoTick("EURUSD",tickEUR)) {Print("EURUSD price has not been received"); return;}
   if(!SymbolInfoTick("GBPUSD",tickGBP)) {Print("GBPUSD price has not been received"); return;}
   if(!SymbolInfoTick("EURGBP",tickEURGBP)) {Print("EURGBP price has not been received"); return;}
  
   if(tickEUR.ask!=0 && tickEUR.bid!=0)
    {
     if(MedianEURUSD!=NormalizeDouble(tickEUR.ask-(tickEUR.ask-tickEUR.bid)/2,_Digits)) 
      {
       MedianEURUSD=NormalizeDouble(tickEUR.ask-(tickEUR.ask-tickEUR.bid)/2,_Digits);
       mEur=tickEUR.time_msc;
      }
    } else return; 
    
   if(tickGBP.ask!=0 && tickGBP.bid!=0)
    {
     if(MedianGBPUSD!=NormalizeDouble(tickGBP.ask-(tickGBP.ask-tickGBP.bid)/2,_Digits))
      { 
       MedianGBPUSD=NormalizeDouble(tickGBP.ask-(tickGBP.ask-tickGBP.bid)/2,_Digits);
       mGbp=tickGBP.time_msc;
      }
    } else return;
    
   if(tickEURGBP.ask!=0 && tickEURGBP.bid!=0) 
    {
     if(MedianEURGBP!=NormalizeDouble(tickEURGBP.ask-(tickEURGBP.ask-tickEURGBP.bid)/2,_Digits)) 
      {
       MedianEURGBP=NormalizeDouble(tickEURGBP.ask-(tickEURGBP.ask-tickEURGBP.bid)/2,_Digits);
       mEurGbp=tickEURGBP.time_msc;
      }
    } else return;
   
   if(MedianSynthetic!=NormalizeDouble(MedianEURUSD/MedianGBPUSD,_Digits)) //если средние цены по инструменту изменились, сохраняем новую цену и ее время
    {
     MedianSynthetic=NormalizeDouble(MedianEURUSD/MedianGBPUSD,_Digits);  
     if(tickEUR.time_msc<tickGBP.time_msc) msTime=tickEUR.time_msc; else msTime=tickGBP.time_msc;
    }
   if(EURsynthetic!=NormalizeDouble(MedianGBPUSD*MedianEURGBP,_Digits))
    {
     EURsynthetic=NormalizeDouble(MedianGBPUSD*MedianEURGBP,_Digits);
     if(tickEURGBP.time_msc<tickGBP.time_msc) esTime=tickEURGBP.time_msc; else esTime=tickGBP.time_msc;
    }
   if(GBPsynthetic!=NormalizeDouble(MedianEURUSD/MedianEURGBP,_Digits))
    {
     GBPsynthetic=NormalizeDouble(MedianEURUSD/MedianEURGBP,_Digits);
     if(tickEURGBP.time_msc<tickEUR.time) gsTime=tickEURGBP.time_msc; else gsTime=tickEUR.time_msc;
    }
   
   Diff=NormalizeDouble(MedianSynthetic-MedianEURGBP,_Digits); 
   EURdiff=NormalizeDouble(EURsynthetic-MedianEURUSD,_Digits);
   GBPdiff=NormalizeDouble(GBPsynthetic-MedianGBPUSD,_Digits);
   timeDiff=msTime-mEurGbp;
   timeEurDiff=esTime-mEur;
   timeGbpDiff=gsTime-mGbp;
   
   if(Diff>DiffMax)DiffMax=Diff;             
   if(EURdiff>EurDiffMax)EurDiffMax=EURdiff;
   if(GBPdiff>GbpDiffMax)GbpDiffMax=GBPdiff;
   if(Diff<DiffMin)DiffMin=Diff;
   if(EURdiff<EurDiffMin)EurDiffMin=EURdiff;
   if(GBPdiff<GbpDiffMin)GbpDiffMin=GBPdiff;
          
   TradeFunc("EURGBP",Diff,timeDiff,spread,1);    
   TradeFunc("EURUSD",EURdiff,timeEurDiff,spread,1);
   TradeFunc("GBPUSD",GBPdiff,timeGbpDiff,spread,1);
  }

void TradeFunc(string symbol, double diff, long time, int Spread, long timedif) //ф-я проверяет наличие сигнала по каждому иснтрументу и открывает сделки
  {
    if(diff>0 && SufficiencyOfEquity(symbol))
     {
      
      double Lot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
      Lot = NormalizeDouble(Lot, 3); 
      double priceBuy=SymbolInfoDouble(symbol,SYMBOL_ASK);
      long stoplvl = SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
      if(m_Position.Select(symbol))
        { 
         if(m_Position.PositionType()==POSITION_TYPE_SELL && m_Position.Profit()+m_Position.Commission()>0) m_Trade.PositionClose(symbol);
        }  
      if(diff>Spread*0.00001 && time>timedif)  
      {
      if(CountPosBuy(symbol)==0 && CountPosSell(symbol)==0) 
       {
         m_Trade.PositionOpen(symbol,ORDER_TYPE_BUY,Lot,priceBuy,0,0,"Diff: "+DoubleToString(diff/_Point,0)+" Delay: "+string(timedif));       
       } 
      }
     }
     
   if(diff<0 && SufficiencyOfEquity(symbol))
     {
      double Lot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
      Lot = NormalizeDouble(Lot, 3); 
      double priceSell=SymbolInfoDouble(symbol,SYMBOL_BID);
      long stoplvl = SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
       if(m_Position.Select(symbol))
        { 
         if(m_Position.PositionType()==POSITION_TYPE_BUY && m_Position.Profit()+m_Position.Commission()>0) m_Trade.PositionClose(symbol);
        } 
       if(diff<Spread*0.00001*-1 && time<timedif*-1)
       { 
       if(CountPosSell(symbol)==0 && CountPosBuy(symbol)==0) 
        {
         m_Trade.PositionOpen(symbol,ORDER_TYPE_SELL,Lot,priceSell,0,0,"Diff: "+DoubleToString(diff/_Point,0)+" Delay: "+string(timedif));   
        }
       }
     }
  }
   
int CountPosBuy(string symbol)
  {
   int result=0;
   for(int k=0; k<PositionsTotal(); k++)
     {
      if(myposition.Select(symbol)==true)
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {result++;}
         else
           {}
        }
     }
    return(result);
   }

int CountPosSell(string symbol)
     {
      int result=0;
      for(int k=0; k<PositionsTotal(); k++)
        {
         if(myposition.Select(symbol)==true)
           {
            if(myposition.PositionType()==POSITION_TYPE_SELL)
              {result++;}
            else
              {}
           }
         }
       return(result);
      }
  
 bool SufficiencyOfEquity(string symb)
  {
   if(100000*0.01/AccountInfoInteger(ACCOUNT_LEVERAGE)*SymbolInfoDouble(symb,SYMBOL_BID) < myaccount.FreeMargin()) return(true);
   else return(false);
  }