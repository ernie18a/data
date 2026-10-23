//+------------------------------------------------------------------+
//|                           DVD Level(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010"
#property link      ""
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // order (limit) object
//+---------------------------------------------------+
//|Money Management                                   |
//+---------------------------------------------------+
input bool AccountIsMini=true;         // Change to true if trading mini account
input bool MoneyManagement=true;       // Change to false to shutdown money management controls.
input bool UseTrailingStop=false;
//--- Lots = 1 will be in effect and only 1 lot will be open regardless of equity.  
input double TradeSizePercent=10;   // Change to whatever percent of equity you wish to risk.
input double Lots=0.01;  // you can change the lot but be aware of margin. Its better to trade with 1/4 of your capital. 
input double MaxLots=4;
input ushort StopLoss=210;  // Maximum pips willing to lose per position.
input ushort TakeProfit=18;  // Maximum profit level achieved. recomended  no more than 200
input double MarginCutoff      = 300;  // Expert will stop trading if equity level decreases to that level.
input ulong Slippage           = 40;   // Possible fix for not getting closed Could be higher with some brokers    
//----
ulong MagicNumber;      // Magic EA identifier. Allows for several co-existing EA with different input values
string ExpertName;      // To "easy read" which EA place an specific order and remember me forever :)
double lotMM;
int TradesInThisSymbol;

double BAL,RAVI0_2_24_H1,LastBid,RAVI0_2_24_D1,RAVI0_2_24_D1_1,RAVI0_2_24_D1_2,RAVI0_2_24_D1_3;

int    handle_iMA_H1_2;                // variable for storing the handle of the iMA indicator 
int    handle_iMA_H1_24;               // variable for storing the handle of the iMA indicator 
int    handle_iMA_D1_2;                // variable for storing the handle of the iMA indicator 
int    handle_iMA_D1_24;               // variable for storing the handle of the iMA indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Lots<=0.0)
     {
      Print("The \"Lots\" can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- create handle of the indicator iMA
   handle_iMA_H1_2=iMA(Symbol(),PERIOD_H1,2,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_H1_2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_H1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_H1_24=iMA(Symbol(),PERIOD_H1,24,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_H1_24==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_H1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_D1_2=iMA(Symbol(),PERIOD_D1,2,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_D1_2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_D1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_D1_24=iMA(Symbol(),PERIOD_D1,24,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_D1_24==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_D1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
   MagicNumber=3000+func_Symbol2Val(Symbol())*100+(int)Period();
   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(Slippage);
   m_symbol.Name(Symbol());
   RefreshRates();
   ExpertName="DVD 100 cent: "+IntegerToString(MagicNumber)+" : "+Symbol()+"_"+EnumToString(Period());
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
//| CheckExitCondition                                               |
//| Check if any rules are met for close of trade                    |
//| This EA closes trades by hitting StopLoss or TrailingStop        |
//| No Exit rules so always return false                             |
//+------------------------------------------------------------------+
bool CheckExitCondition(string TradeType,double OpenPrice,datetime OpenTime)
  {
   return(false);
  }
//+------------------------------------------------------------------+
//| Calculation Trend                                                |
//+------------------------------------------------------------------+
void CalcTrend()
  {
   double MA1=0.0,MA2=0.0;
   MA1=iMAGet(handle_iMA_H1_2,0);
   MA2=iMAGet(handle_iMA_H1_24,0);
   RAVI0_2_24_H1=((MA1-MA2)/MA2)*100;

   MA1=iMAGet(handle_iMA_D1_2,0);
   MA2=iMAGet(handle_iMA_D1_24,0);
   RAVI0_2_24_D1=((MA1-MA2)/MA2)*100;

   MA1=iMAGet(handle_iMA_D1_2,1);
   MA2=iMAGet(handle_iMA_D1_24,1);
   RAVI0_2_24_D1_1=((MA1-MA2)/MA2)*100;

   MA1=iMAGet(handle_iMA_D1_2,2);
   MA2=iMAGet(handle_iMA_D1_24,2);
   RAVI0_2_24_D1_2=((MA1-MA2)/MA2)*100;

   MA1=iMAGet(handle_iMA_D1_2,3);
   MA2=iMAGet(handle_iMA_D1_24,3);
   RAVI0_2_24_D1_3=((MA1-MA2)/MA2)*100;
  }
//+------------------------------------------------------------------+
//| CheckEntryCondition                                              |
//| Check if rules are met for Buy trade                             |
//+------------------------------------------------------------------+
bool CheckEntryConditionBUY()
  {
   BAL=0;

   if(RAVI0_2_24_H1<-0.00) BAL=BAL+10;

   double Level100;
   int PointFromLevelGo=50,PtFrRise=700;
   if(!RefreshRates())
      return(false);

   Level100=NormalizeDouble(m_symbol.Bid(),2)+PointFromLevelGo*Point();

   if(iHigh(NULL,PERIOD_H1,1)>(Level100+PtFrRise*Point()) || 
      iHigh(NULL,PERIOD_H1,2)>(Level100+PtFrRise*Point()))
      BAL=BAL+7;

   if(m_symbol.Bid()<Level100 && 
      iClose(NULL,PERIOD_M1,1)>Level100 && 
      iLow(NULL,PERIOD_H1,0)>(Level100-PointFromLevelGo*Point()+30*Point()) && 
      iLow(NULL,PERIOD_H1,1)>(Level100-PointFromLevelGo*Point()+30*Point()) && 
      iLow(NULL,PERIOD_H1,2)>(Level100-PointFromLevelGo*Point()))
      BAL=BAL+45;

   int HiLevel=600,LoLevel=250,x,LoLevel2=450;
   for(x=0;x<=11;x++)
     {
      if(iHigh(NULL,PERIOD_M1,x)>(Level100+HiLevel*Point()))
         BAL=BAL-50;
     }

   for(x=0;x<=30;x++)
     {
      if(iHigh(NULL,PERIOD_M1,x+3)-iLow(NULL,PERIOD_M1,x)>(300*Point()) && 
         iOpen(NULL,PERIOD_M1,x+3)>iClose(NULL,PERIOD_M1,x) && 
         RAVI0_2_24_D1<-2)
         BAL=BAL-50;
     }

   bool IsCrossLowLevel2=false;
   for(x=0;x<=14;x++)
     {
      if(iHigh(NULL,PERIOD_H1,x)>(Level100+LoLevel2*Point()))
         IsCrossLowLevel2=true;
     }
   if(IsCrossLowLevel2==false)
      BAL=BAL-50;

   if(iHigh(NULL,PERIOD_M30,0)<(Level100+LoLevel*Point()) && 
      iHigh(NULL,PERIOD_M30,1)<(Level100+LoLevel*Point()) && 
      iHigh(NULL,PERIOD_M30,2)<(Level100+LoLevel*Point()) && 
      iHigh(NULL,PERIOD_M30,3)<(Level100+LoLevel*Point()) && 
      iHigh(NULL,PERIOD_M30,4)<(Level100+LoLevel*Point()) && 
      iHigh(NULL,PERIOD_M30,5)<(Level100+LoLevel*Point()) && 
      iHigh(NULL,PERIOD_M30,6)<(Level100+LoLevel*Point()) && 
      iHigh(NULL,PERIOD_M30,7)<(Level100+LoLevel*Point()))
      BAL=BAL-50;
   if(BAL>=50)
      return(true);

   return(false);
  }
//+------------------------------------------------------------------+
//| CheckEntryCondition                                              |
//| Check if rules are met for open of trade                         |
//+------------------------------------------------------------------+
int MyLevel=100;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckEntryConditionSELL()
  {
   BAL=0;

   if(RAVI0_2_24_H1>0.00)
      BAL=BAL+10;

   double Level100;
   int PointFromLevelGo=50,PtFrRise=700;
   if(!RefreshRates())
      return(false);

   Level100=NormalizeDouble(m_symbol.Bid(),2)-PointFromLevelGo*Point();

   if(iLow(NULL,PERIOD_H1,1)<(Level100-PtFrRise*Point()) || 
      iLow(NULL,PERIOD_H1,2)<(Level100-PtFrRise*Point()))
      BAL=BAL+7;

   if(m_symbol.Bid()>Level100 && 
      iClose(NULL,PERIOD_M1,1)<Level100 && 
      iHigh(NULL,PERIOD_H1,0)<(Level100+PointFromLevelGo*Point()-30*Point()) && 
      iHigh(NULL,PERIOD_H1,1)<(Level100+PointFromLevelGo*Point()-30*Point()) && 
      iHigh(NULL,PERIOD_H1,2)<(Level100+PointFromLevelGo*Point()))
      BAL=BAL+45;

   int HiLevel=600,LoLevel=250,x,LoLevel2=450;
   for(x=0;x<=11;x++)
     {
      if(iLow(NULL,PERIOD_M1,x)<(Level100-HiLevel*Point()))
         BAL=BAL-50;
     }

   for(x=0;x<=30;x++)
     {
      if((iHigh(NULL,PERIOD_M1,x)-iLow(NULL,PERIOD_M1,x+3))>(300*Point()) && 
         iClose(NULL,PERIOD_M1,x)>iOpen(NULL,PERIOD_M1,x+3) && 
         RAVI0_2_24_D1>2)
         BAL=BAL-50;
     }

   bool IsCrossLowLevel2=false;
   for(x=0;x<=14;x++)
     {
      if(iLow(NULL,PERIOD_H1,x)<(Level100-LoLevel2*Point()))
         IsCrossLowLevel2=true;
     }
   if(IsCrossLowLevel2==false)
      BAL=BAL-50;

   if(iLow(NULL,PERIOD_M30,0)>(Level100-LoLevel*Point()) && 
      iLow(NULL,PERIOD_M30,1)>(Level100-LoLevel*Point()) && 
      iLow(NULL,PERIOD_M30,2)>(Level100-LoLevel*Point()) && 
      iLow(NULL,PERIOD_M30,3)>(Level100-LoLevel*Point()) && 
      iLow(NULL,PERIOD_M30,4)>(Level100-LoLevel*Point()) && 
      iLow(NULL,PERIOD_M30,5)>(Level100-LoLevel*Point()) && 
      iLow(NULL,PERIOD_M30,6)>(Level100-LoLevel*Point()) && 
      iLow(NULL,PERIOD_M30,7)>(Level100-LoLevel*Point()))
      BAL=BAL-50;
   if(BAL>=50)
      return(true);

   return(false);
  }
//+------------------------------------------------------------------+
//| Проверка времени торгов                                           |
//+------------------------------------------------------------------+
bool ValidTime()
  {
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
   if(str1.day_of_week==1 && str1.hour<=6)
      return(false);
   return(true);
  }

int OpPozBUYpred,OpPozSELLpred;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   CalcTrend();
   HandleOpenPositions();

   if(!ValidTime())
      return;

   TradesInThisSymbol=CountPositions();
   int OpPozBUY=CounBUY();
   int OpPozSELL=CounSELL();
//+------------------------------------------------------------------+
//| Check if OK to make new trades                                   |
//+------------------------------------------------------------------+
// Only allow 1 trade per Symbol
   int KolPozOpen=1;

// If there is no open trade for this pair and this EA
   if(m_account.FreeMargin()<MarginCutoff)
     {
      Print("Not enough money to trade Strategy:",ExpertName);
      return;
     }
   lotMM=GetLots();

   if(!RefreshRates())
      return;

   if(OpPozBUYpred>OpPozBUY)
     {
      SendMail("DVD 100 cent: Close BUY at "+DoubleToString(m_symbol.Bid(),Digits()),"");
     }
   OpPozBUYpred=OpPozBUY;

   if(CheckEntryConditionBUY() && OpPozBUY<KolPozOpen)
     {
      OpenBuyOrder();
     }

   if(OpPozSELLpred>OpPozSELL)
     {
      SendMail("DVD 100 cent: Close SELL at "+DoubleToString(m_symbol.Bid(),Digits()),"");
     }
   OpPozSELLpred=OpPozSELL;

   if(CheckEntryConditionSELL() && OpPozSELL<KolPozOpen)
     {
      OpenSellOrder();
     }

   return;
  }
//+------------------------------------------------------------------+
//| OpenBuyOrder                                                     |
//| If Stop Loss or TakeProfit are used the values are calculated    |
//| for each trade                                                   |
//+------------------------------------------------------------------+
void OpenBuyOrder()
  {

   uint err=0;
   ulong m_ticket=0;

   if(!RefreshRates())
      return;

   double myPrice=m_symbol.Bid()-10*Point()*10;
   double myTakeProfit=myPrice+TakeProfit*Point()*10;                                                     //
   if(RAVI0_2_24_D1>1 && RAVI0_2_24_D1<5 && 
      RAVI0_2_24_D1_1<RAVI0_2_24_D1 && 
      RAVI0_2_24_D1_2<RAVI0_2_24_D1_1 && 
      RAVI0_2_24_D1_3<RAVI0_2_24_D1_2)
      myTakeProfit=myTakeProfit+25*Point()*10;
   double myStopLoss   = myPrice - StopLoss * Point()*10;
   datetime myTimeEnd  = TimeCurrent() + 1200;

//m_ticket=OrderSend(Symbol(),OP_BUYLIMIT,lotMM,myPrice,Slippage,myStopLoss,myTakeProfit,ExpertName,MagicNumber,myTimeEnd,myColor);
   bool result=m_trade.BuyLimit(lotMM,myPrice,Symbol(),myStopLoss,myTakeProfit,ORDER_TIME_SPECIFIED,myTimeEnd,ExpertName);

   string MyTxt,subject;
   MyTxt=" for "+DoubleToString(myPrice,4)+
         " BAL :"+DoubleToString(BAL,Digits())+
         " RAVI0_2_24_H1 :"+DoubleToString(RAVI0_2_24_H1,Digits());

   subject="DVD 100 cent: BuyLimit for "+DoubleToString(myPrice,4)+" "+Symbol()+" lot "+DoubleToString(lotMM,2);
   if(!result)
     {
      err=m_trade.ResultRetcode();
      Print("DVD 100 cent: Error opening BuyLimit order ["+ExpertName+"]: ("+IntegerToString(err)+") "+
            m_trade.ResultRetcodeDescription()+" /// "+MyTxt);
      SendMail("DVD 100 cent: Error BuyLimit ","["+ExpertName+"]: ("+IntegerToString(err)+") "+
               m_trade.ResultRetcodeDescription()+" /// "+MyTxt);
      return;
     }
   Print("DVD 100 cent: BuyLimit"+MyTxt);
   SendMail(subject,MyTxt);
  }
//+------------------------------------------------------------------+
//| OpenSellOrder                                                    |
//| If Stop Loss or TakeProfit are used the values are calculated    |
//| for each trade                                                   |
//+------------------------------------------------------------------+
void OpenSellOrder()
  {
   uint err=0;
   ulong m_ticket=0;

   if(!RefreshRates())
      return;

   double myPrice=m_symbol.Bid()+7*Point()*10;
   double myTakeProfit=myPrice-TakeProfit*Point()*10;                                                           //
   if(RAVI0_2_24_D1<-1 && RAVI0_2_24_D1>-5 && 
      RAVI0_2_24_D1_1>RAVI0_2_24_D1 && 
      RAVI0_2_24_D1_2>RAVI0_2_24_D1_1 && 
      RAVI0_2_24_D1_3>RAVI0_2_24_D1_2)
      myTakeProfit=myTakeProfit-25*Point()*10;
//if (CounSELL() > 0)  myTakeProfit = myTakeProfit - 101 * Point()*10;
   double myStopLoss=myPrice+StopLoss*Point()*10;
//if (CounSELL() > 0)  myStopLoss = myStopLoss - 100 * Point()*10;
   datetime myTimeEnd=TimeCurrent()+1200;

//m_ticket=OrderSend(Symbol(),OP_SELLLIMIT,lotMM,myPrice,Slippage,myStopLoss,myTakeProfit,ExpertName,MagicNumber,myTimeEnd,myColor);
   bool result=m_trade.SellLimit(lotMM,myPrice,Symbol(),myStopLoss,myTakeProfit,ORDER_TIME_SPECIFIED,myTimeEnd,ExpertName);

   string MyTxt,subject;
   MyTxt=" for "+DoubleToString(myPrice,4)+
         " BAL :"+DoubleToString(BAL,Digits())+
         " RAVI0_2_24_H1 :"+DoubleToString(RAVI0_2_24_H1,Digits());

   subject="DVD 100 cent: SellLimit for "+DoubleToString(myPrice,4)+" "+Symbol()+" lot "+DoubleToString(lotMM,2);

   if(!result)
     {
      err=m_trade.ResultRetcode();
      Print("DVD 100 cent: Error opening SellLimit order ["+ExpertName+"]: ("+IntegerToString(err)+") "+
            m_trade.ResultRetcodeDescription()+" /// "+MyTxt);
      SendMail("DVD 100 cent: Error SellLimit ","["+ExpertName+"]: ("+IntegerToString(err)+") "+
               m_trade.ResultRetcodeDescription()+" /// "+MyTxt);
      return;
     }
   Print("DVD 100 cent: SellLimit"+MyTxt);
   SendMail(subject,MyTxt);
  }
//+------------------------------------------------------------------------+
//| Counts the number of open positions                                    |
//+------------------------------------------------------------------------+
int CountPositions()
  {
   int op=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // scan all positions
     {
      if(!m_position.SelectByIndex(i))
         return(op);
      if(m_position.Symbol()==Symbol())
        {
         op++;
        }
     }

   for(int i=OrdersTotal()-1;i>=0;i--) // scan all limit orders
     {
      if(!m_order.SelectByIndex(i))
         return(op);
      if(m_order.Symbol()==Symbol())
        {
         if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT || m_order.OrderType()==ORDER_TYPE_SELL_LIMIT)
           {
            op++;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------------+
//| Counts the number of open positions BUY                                |
//+------------------------------------------------------------------------+
int CounBUY()
  {
   int op=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // scan all positions
     {
      if(!m_position.SelectByIndex(i))
         return(op);
      if(m_position.Symbol()==Symbol() || m_position.PositionType()==POSITION_TYPE_BUY)
        {
         op++;
        }
     }

   for(int i=OrdersTotal()-1;i>=0;i--) // scan all limit orders
     {
      if(!m_order.SelectByIndex(i))
         return(op);
      if(m_order.Symbol()==Symbol() || m_order.OrderType()==ORDER_TYPE_BUY_LIMIT)
        {
         op++;
        }
     }
   return(op);
  }
//+------------------------------------------------------------------------+
//| Counts the number of open positions SELL                               |
//+------------------------------------------------------------------------+
int CounSELL()
  {
   int op=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // scan all positions
     {
      if(!m_position.SelectByIndex(i))
         return(op);
      if(m_position.Symbol()==Symbol() || m_position.PositionType()==POSITION_TYPE_SELL)
        {
         op++;
        }
     }

   for(int i=OrdersTotal()-1;i>=0;i--) // scan all limit orders
     {
      if(!m_order.SelectByIndex(i))
         return(op);
      if(m_order.Symbol()==Symbol() || m_order.OrderType()==ORDER_TYPE_SELL_LIMIT)
        {
         op++;
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//| Handle Trailing Stop                                             |
//+------------------------------------------------------------------+
void HandleTrailingStop(string type,ulong m_ticket,double op,double os,double tp)
  {
   int x; bool IsGoHi;

   if(!RefreshRates())
      return;

   if(type=="SELL")
     {
      IsGoHi=false;
      for(x=0;x<=30;x++)
        {
         if((iHigh(NULL,PERIOD_M1,x)-iLow(NULL,PERIOD_M1,x+3))>(500*Point()) && 
            iClose(NULL,PERIOD_M1,x)>iOpen(NULL,PERIOD_M1,x+3))
            IsGoHi=true;
        }
      if(op<m_symbol.Ask() && IsGoHi && (tp<op-50*Point()))
         ModifyPosition(m_ticket,op,os,op-10*Point());
     }

   if(type=="BUY")
     {
      IsGoHi=false;
      for(x=0;x<=30;x++)
        {
         if((iHigh(NULL,PERIOD_M1,x+3)-iLow(NULL,PERIOD_M1,x))>(500*Point()) && 
            iClose(NULL,PERIOD_M1,x)<iOpen(NULL,PERIOD_M1,x+3))
            IsGoHi=true;
        }
      if(op>m_symbol.Bid() && IsGoHi && tp>op+50*Point())
         ModifyPosition(m_ticket,op,os,op+10*Point());
     }
  }
//+------------------------------------------------------------------+
//|  Modify Open Position Controls                                   |
//|  Try to modify position 3 times                                  |
//+------------------------------------------------------------------+
void ModifyPosition(ulong pos_ticket,double op,double price,double tp)
  {
   int CloseCnt;
   uint  err;
   CloseCnt=0;
   while(CloseCnt<3)
     {
      if(m_trade.PositionModify(pos_ticket,price,tp))
        {
         CloseCnt=3;
        }
      else
        {
         err=m_trade.ResultRetcode();
         Print(CloseCnt," Error modifying position : (",err,") "+m_trade.ResultRetcodeDescription());
         if(err>0)
            CloseCnt++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Handle Open Positions                                            |
//| Check if any open positions need to be closed or modified        |
//+------------------------------------------------------------------+
void HandleOpenPositions()
  {
   bool YesClose=false;
//---
   int total=PositionsTotal();
   for(int cnt=total-1;cnt>=0;cnt--)
     {
      if(!m_position.SelectByIndex(cnt))
         return;
      if(m_position.Symbol()!=Symbol())
         continue;
      if(m_position.Magic()!=MagicNumber)
         continue;
      if(m_position.PositionType()==POSITION_TYPE_BUY)
        {
         if(CheckExitCondition("BUY",m_position.PriceOpen(),m_position.Time()))
           {
            m_trade.PositionClose(m_position.Ticket());
           }
         else
           {
            if(UseTrailingStop)
              {
               HandleTrailingStop("BUY",m_position.Ticket(),m_position.PriceOpen(),
                                  m_position.StopLoss(),m_position.TakeProfit());
              }
           }
        }
      if(m_position.PositionType()==POSITION_TYPE_SELL)
        {
         if(CheckExitCondition("SELL",m_position.PriceOpen(),m_position.Time()))
           {
            m_trade.PositionClose(m_position.Ticket());
           }
         else
           {
            if(UseTrailingStop)
              {
               HandleTrailingStop("SELL",m_position.Ticket(),m_position.PriceOpen(),
                                  m_position.StopLoss(),m_position.TakeProfit());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Get number of lots for this trade                                |
//+------------------------------------------------------------------+
double GetLots()
  {
   double lot;
   if(MoneyManagement)
     {
      lot=LotsOptimized();
     }
   else
     {
      lot=Lots;
      if(AccountIsMini)
        {
         if(lot > 1.0) lot=lot/10;
         if(lot < 0.1) lot=0.1;
        }
     }
//----
   return(lot);
  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
//--- select lot size
   lot=NormalizeDouble(MathFloor(m_account.FreeMargin()*TradeSizePercent/1000)/100,2);
//--- check if mini or standard Account
   if(AccountIsMini)
     {
      lot=MathFloor(lot*100)/100;
      //--- use at least 1 mini lot
      if(lot<0.1)
         lot=0.1;
      if(lot>MaxLots)
         lot=MaxLots;
     }
   else
     {
      if(lot<1.0)
         lot=1.0;
      if(lot>MaxLots)
         lot=MaxLots;
     }
//----
   return(lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int func_Symbol2Val(string symbol)
  {
   if(symbol=="AUDCAD")
     {
      return(1);
     }
   else if(symbol=="AUDJPY")
     {
      return(2);
     }
   else if(symbol=="AUDNZD")
     {
      return(3);
     }
   else if(symbol=="AUDUSD")
     {
      return(4);
     }
   else if(symbol=="CHFJPY")
     {
      return(5);
     }
   else if(symbol=="EURAUD")
     {
      return(6);
     }
   else if(symbol=="EURCAD")
     {
      return(7);
     }
   else if(symbol=="EURCHF")
     {
      return(8);
     }
   else if(symbol=="EURGBP")
     {
      return(9);
     }
   else if(symbol=="EURJPY")
     {
      return(10);
     }
   else if(symbol=="EURUSD")
     {
      return(11);
     }
   else if(symbol=="GBPCHF")
     {
      return(12);
     }
   else if(symbol=="GBPJPY")
     {
      return(13);
     }
   else if(symbol=="GBPUSD")
     {
      return(14);
     }
   else if(symbol=="NZDUSD")
     {
      return(15);
     }
   else if(symbol=="USDCAD")
     {
      return(16);
     }
   else if(symbol=="USDCHF")
     {
      return(17);
     }
   else if(symbol=="USDJPY")
     {
      return(18);
     }
   else
     {
      Comment("unexpected Symbol");
      return(0);
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int handle,const int index)
  {
   double MA[];
   ArraySetAsSeries(MA,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,0,index+1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[index]);
  }
//+------------------------------------------------------------------+
