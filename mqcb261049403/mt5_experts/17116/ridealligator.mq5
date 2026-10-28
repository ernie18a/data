//+------------------------------------------------------------------+
//|                       RideAlligator(barabashkakvn's edition).mq5 |
//|            Copyright © 2011 http://www.mql4.com/ru/users/rustein |
//-------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
input int      AlligatorPeriod=5;
input ENUM_MA_METHOD AlliggatorMODE=MODE_LWMA; // 0=SMA,1=EMA,2=SSMA,3=LWMA
input double   RiskFactor=0.5;
//---
ulong          m_magic=200276450;            // magic number
int            handle_iAlligator;            // variable for storing the handle of the iAlligator indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number

   int A1=(int)MathRound(AlligatorPeriod*1.61803398874989);
   int A2=(int)MathRound(A1*1.61803398874989);
   int A3=(int)MathRound(A2*1.61803398874989);
//--- create handle of the indicator iAlligator
   handle_iAlligator=iAlligator(Symbol(),Period(),A3,A2,A2,A1,A1,AlligatorPeriod,AlliggatorMODE,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iAlligator==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAlligator indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|            DO NOT MODIFY ANYTHING BELOW THIS LINE!!!             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int wtf=0;
   double Lots;
   double MinLot=m_symbol.LotsMin();

   if(MinLot<=0.01)
      wtf=2;
   if(MinLot>=0.1)
      wtf=1;
   double MMLot=NormalizeDouble(m_account.Balance()*RiskFactor/100.00/100.00,wtf);
   if(MMLot>=MinLot)
      Lots=MMLot;
   else
      Lots=MinLot;

   double LipsNow = iAlligatorGet(GATORLIPS_LINE,1);
   double LipsPre = iAlligatorGet(GATORLIPS_LINE,2);
   double JawsNow = iAlligatorGet(GATORJAW_LINE,1);
   double JawsPre = iAlligatorGet(GATORJAW_LINE,2);
   double TeethNow= iAlligatorGet(GATORTEETH_LINE,1);

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            total++;

   if(!RefreshRates())
      return;

//if(LipsNow<m_symbol.Bid() && JawsNow<m_symbol.Bid() && TeethNow<m_symbol.Bid())
   if(LipsNow>JawsNow && TeethNow<JawsNow && LipsPre<JawsPre && total<1)
     {
      m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),0.0,0.0,"RideAlligator");
      return;
     }
//if(LipsNow>m_symbol.Bid() && JawsNow>m_symbol.Bid() && TeethNow>m_symbol.Bid())
   if(LipsNow<JawsNow && TeethNow>JawsNow && LipsPre>JawsPre && total<1)
     {
      m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),0.0,0.0,"RideAlligator");
      return;
     }

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.StopLoss()!=JawsNow && JawsNow>0 && JawsNow!=EMPTY_VALUE)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(JawsNow<m_position.PriceCurrent()) // если текущая цена НАД "JawsNow"
                     if(m_position.StopLoss()==0 || JawsNow>m_position.StopLoss()+1*Point())//(JawsNow>m_position.StopLoss()+10*Point() && JawsNow>m_position.PriceCurrent()))
                        m_trade.PositionModify(m_position.Ticket(),NormalizeDouble(JawsNow,Digits()),0.0);
                 }

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(JawsNow>m_position.PriceCurrent()) // если текущая цена ПОД "JawsNow"
                     if(m_position.StopLoss()==0 || JawsNow<m_position.StopLoss()-1*Point())//(JawsNow<m_position.StopLoss()-10*Point() && JawsNow<m_position.PriceCurrent()))
                        m_trade.PositionModify(m_position.Ticket(),NormalizeDouble(JawsNow,Digits()),0.0);
                 }
              }
           }
   return;
  }
//+------------------------------------------------------------------+
//|---------------------------// END //--------(24/08/2011)----------|
//|            Copyright © 2011 http://www.mql4.com/ru/users/rustein |
//-------------------------------------------------------------------+
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
