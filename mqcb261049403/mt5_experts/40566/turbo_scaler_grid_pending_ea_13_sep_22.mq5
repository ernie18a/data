//+------------------------------------------------------------------+
//|                                             Trail BE Stop Equity |
//|                                      Copyright 2022, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022"
#property link "alickhillpark@gmail.com"
#property version   "3.0"
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh> CTrade trade;                      // trading object
#include <Trade/Trade.mqh>
CTrade   Trade;
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // object of COrderInfo class

input group                "Parameters For Open Trades With No SL TP Or Trail "
input int               InpStopLossPoints           = 100;     // StopLoss points Added to open Trade with NO SL
input int               InpTriggerBEStopLossPoints  = 130;     // TriggerBEStopLossPoints
input int               InpBEStopLossPoints         = 30;      // BEStopLossPoints
input int               InpTrailStopLossPoints      = 250;     // TrailPoints
input double            TrailMultiplier             = 1.1;     // TrailMultiplier
input group                "Enter the SL if you want Pending Order to have SL "
input double            InpBuyStopLoss              = 0;       // BuyStop Loss price Not Pip Or point
input double            InpSellStopLoss             = 0;       // SellStop Loss price Not Pip Or point
input group                "Enter the Price at which you want A Pending Order To Open "
input group                "Pending parameters Either Sell Stop is Zero or BuyStop"
input double            BuyStopEntry                = 0;       // BuyStopEntry
input double            SellStopEntry               = 0;       // SellStopEntry
input double            Lots                        = 0.01;    // Lots
input uchar             InpUpQuantity               = 3;       // Pending quantity How many Pending u want
input ushort            InpUpStep                   = 15;      // Step/Gap between orders (in points)Distance Between Order's'
input ENUM_TIMEFRAMES   TS_period                   =PERIOD_M10;// Pend Price Trig Timeframe
input group                "When the market moves near the pending order price above you put a grid of pending can be sent "
input bool              PendingPriceTrigger         = true;   //Pending Trigs At Pend Price
input bool              PendingConditionTrigger     = false;   //Pending Trigs On Condition
input double            OrderBuyBlockStart               = 0;       // OrderBuyBlockStart
input double            OrderBuyBlockEnd               = 0;       // OrderBuyBlockEnd
input double            OrderSellBlockStart               = 0;       // OrderSellBlockStart
input double            OrderSellBlockEnd               = 0;       // OrderSellBlockEnd

input int               InpMagicNumber              = 0;
input int               PositionOpenWithin          = 300;     // Open Within Seconds Applies 2 SL

input bool              OrderTest                   = false;   //Enable Tester Order (in Backtest Only)
input int               Slippage                    = 10;      //Slippage
input group                "Equity parameters Based on 0.01 Lot. Then EA ratio's on your Lot Size"
input double            MaxFloatLoss                = 3;      //Money Equity Loss Stop
input double            EquityBEStopLoss            = 2.5;       //Money Equity BE Stop
input double            EquityTrigBEStop            = 7;       //Money To Trig BE Stop
input double            EquityTrail                 = 10;      //Money To Trail After BE
//+----------------------------------------------+
bool Stop, Profit;
double Percentage;
double EquitySL;
double         StopLoss;
double         BETrail;
double         BETrigger;
double         BESL;
double                           m_adjusted_point;                   // point value adjusted for 3 or 5 points
ulong                            m_slippage=30;                      // slippage                            
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {

//   if(ObjectFind(0,"HLineSL") == 0)// Exists
   createBackground();
   createObject("Profit","Money P/L is: $"+DoubleToString(CalculateTotalProfit(),2));
   createObject2("Percent","Percentage P/L is: "+DoubleToString(Percentage,2)+"%");
   createObject4("Equity HL","Equity Stop/L is: $"+DoubleToString(HLineSLprice(),2));
//----
   Stop=false;
   Profit = false;
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,"Background");
   ObjectDelete(0,"Profit");
   ObjectDelete(0,"Percent");
   ObjectDelete(0,"Equity HL");
   return;
//----
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {

      string   symbol         =  PositionGetString(POSITION_SYMBOL);
   Percentage = (CalculateTotalProfit()*100)/AccountInfoDouble(ACCOUNT_BALANCE);
   int        digits   =  (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double   Spred    =  NormalizeDouble(Ask() - Bid(), digits);

 double price_ask    = BuyStopEntry + (double)CountPendingOrders()* (double)(InpUpStep + Spred) * SymbolInfoDouble(symbol, SYMBOL_POINT);
// double price_bid    = SellStopEntry - (double)CountPendingOrders()* (double)(InpUpStep + Spred) * SymbolInfoDouble(symbol, SYMBOL_POINT);
 double price_bid    = SellStopEntry - (double)CountPendingOrders()* (double)(InpUpStep + Spred) * SymbolInfoDouble(symbol, SYMBOL_POINT);
      double peep = NormalizeDouble(price_ask,digits);
      double pixa = NormalizeDouble(price_bid,digits);
  // if()
   ChartWrite("OrdersP", "Number Of Pending Orders " + (string)CountPendingOrders(), 100, 11, 10, clrWhite); //Write Number of Orders on the Chart
   ChartWritevii("OrdersL", "Number Of Live Orders " + (string)IsPositionExists(), 100, 22, 10, clrWhite); //Write Number of Orders on the Chart
   ChartWritei("PriceB", "BuyStop Entry Price " + (string)peep, 100, 33, 10, clrYellowGreen); //Write price of Orders on the Chart
   ChartWritev("PriceS", "SellStop Entry Price " + (string)pixa, 100, 44, 10, clrMagenta); //Write price of Orders on the Chart
   ChartWriteii("Lot", "Lot " + (string)Lots, 100, 55, 10, clrYellow); //Write Number of Lots on the Chart
   ChartWriteiii("InpUpQuantity", "QuantityPending " + (string)InpUpQuantity, 100, 66, 10, clrGoldenrod); //Write Number of Orders on the Chart
   ChartWriteiv("GapPoint", "GapPoint " + (string)InpUpStep, 100, 77, 10, clrWhite); //Write Number of Points on the Chart
   ChartWritev("Pending", "Pending Price Triggers Pend Send " + (string)PendingPriceTrigger, 100, 88, 10, clrWhite); //Write Number of Points on the Chart
   ChartWritevi("Pend", "Condition Triggers Pending Send " + (string)PendingConditionTrigger, 100, 99, 10, clrWhite); //Write Number of Points on the Chart
//----
   if(CalculateTotalProfit() != 0)
      ObjectSetString(0,"Profit",OBJPROP_TEXT,"Money P/L is: $"+DoubleToString(CalculateTotalProfit(),2));
      
   if(Percentage != 0)
      ObjectSetString(0,"Percent",OBJPROP_TEXT,"Percentage P/L is: "+DoubleToString(Percentage,2)+"%");

  // if(ObjectFind(0,"HLineSL") == 0)
      ObjectSetString(0,"Equity HL",OBJPROP_TEXT,"Equity Stop/L is: $"+DoubleToString(HLineSLprice(),2));

////-----------------
     if( CalculateTotalProfit() >= EquityTrigBEStop *100 * Lots && ObjectFind(0,"HLineSL") < 0 )
     {
      createObject3("HLineSL", EquityBEStopLoss * 100 * Lots);
//      createBackground();
      }

//----
      if( CalculateTotalProfit() <= -MaxFloatLoss * 100 *Lots && CalculateTotalProfit() < 0
       && MaxFloatLoss > 0)     
      {
      ClosePositions();
      Print("Positions Closed At Profit");
      }
////-----------------
  InputStopLoss(Symbol(), InpMagicNumber);
  ApplyStopLoss(Symbol(), InpMagicNumber, StopLoss);
  ApplyTrailingStop( );
  ApplyBE( );
  Pending();
  PendOrder();
////-----------------
      if(CalculateTotalProfit() > HLineSLprice() + (EquityTrail * 100 * Lots * 2))
     {
         ObjectMove(0,"HLineSL",0,0, CalculateTotalProfit() - (EquityTrail * 100 * Lots));
     }
////-----------------
      if( CalculateTotalProfit() <= HLineSLprice() && CalculateTotalProfit() > 0 && HLineSLprice() > 0
      && HLineSLprice() > EquityBEStopLoss * Lots *100 && CalculateTotalProfit() > EquityBEStopLoss * Lots *100 )
     {
      ClosePositions();
      Print("Positions Closed At Profit");
      }
////-----------------
      if( CalculateTotalProfit() <= HLineSLprice() && CalculateTotalProfit() > 0 && HLineSLprice() > 0
      && HLineSLprice() == EquityBEStopLoss * Lots *100 && CalculateTotalProfit() <= EquityBEStopLoss * Lots *100 )
     {
      ClosePositions();
      Print("Positions Closed At Profit");
      }
////-----------------
      if(!IsPositionExists() && ObjectFind(0,"HLineSL") == 0 )//There are positions and Line exists
     {
      ObjectDelete(0,"HLineSL");
      ObjectDelete(0,"Equity HL");
//      ObjectDelete(0,"Background");
     }
  //-----------------
   if(Stop)
     {
      ClosePositions();
      Print("Positions Closed At Loss");
      if(!IsPositionExists())
         Stop = false;
     }
   if(Profit)
     {
      ClosePositions();
      Print("Positions Closed At Profit");
      if(!IsPositionExists())
         Profit = false;
     }
   if(OrderTest)
     {
      if(MQLInfoInteger(MQL_TESTER) && !IsPositionExists())
        {
         trade.Sell(0.1,Symbol(),Bid(),0,0,NULL);
         trade.Buy(0.1,Symbol(),Ask(),0,0,NULL);
        }
     }

   return;
  }
// 
//+------------------------------------------------------------------+
//| Pending function                                             |
//+------------------------------------------------------------------+
void Pending()
  {
   int StopsLevel=m_symbol.StopsLevel();
   if(StopsLevel==0)
      StopsLevel=m_symbol.Spread()*3;
   
     for(int i=1; i<=InpUpQuantity; i++)
     {
      string   symbol         =  PositionGetString(POSITION_SYMBOL);
   int        digits   =  (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double   Spred    =  NormalizeDouble(Ask() - Bid(), digits);
   double Maximum = iHigh(NULL,PERIOD_M30,1);
   double Minimum = iLow (NULL,PERIOD_M30,1);
   double Fifty = ((Maximum - Minimum ) * 50 / 100 ) + Minimum;
      if(InpUpStep*i>StopsLevel)
        {
         if(Lots>0.0)if(PendingConditionTrigger)
           {
     if( BuyStopEntry > 0)
      if( CountPendingOrders() < InpUpQuantity)
      if(IsPositionExists() == 0)
      if( iLow(NULL,PERIOD_D1,0) < OrderBuyBlockStart && iLow(NULL,PERIOD_D1,0) > OrderBuyBlockEnd 
      && iOpen(NULL,PERIOD_D1,0) > OrderBuyBlockStart && OrderBuyBlockStart < OrderBuyBlockEnd
      && iClose(NULL,PERIOD_H2,2) < iClose(NULL,PERIOD_H2,1) // bull candle
      && iClose(NULL,PERIOD_M30,2) > iClose(NULL,PERIOD_M30,1) // bear candle
      && Ask() < Fifty - Spred - (Spred *  3)  )              
              {
 double price_ask    = (Fifty + Spred ) + (double)CountPendingOrders()* (double)(InpUpStep) * SymbolInfoDouble(symbol, SYMBOL_POINT);
//               double Price=m_symbol.NormalizePrice(+(double)InpUpStep*(double)i*m_symbol.Point());
               double sl=0;
               double tp=0;
               m_trade.BuyStop(Lots,price_ask,m_symbol.Name(),sl,tp);
              }
              
     if( SellStopEntry > 0)
      if( CountPendingOrders() < InpUpQuantity)
      if(IsPositionExists() == 0)
      if( iHigh(NULL,PERIOD_D1,0) > OrderSellBlockStart && iHigh(NULL,PERIOD_D1,0) < OrderSellBlockEnd 
      && iOpen(NULL,PERIOD_D1,0) < OrderSellBlockStart && OrderSellBlockStart > OrderSellBlockEnd 
      && iClose(NULL,PERIOD_H2,2) > iClose(NULL,PERIOD_H2,1) // bear candle
      && iClose(NULL,PERIOD_M30,2) < iClose(NULL,PERIOD_M30,1) // bull candle
      && Bid() > Fifty + (Spred *  3)  )              
               {
 double price_bid    = ( Fifty - Spred ) - (double)CountPendingOrders()* (double)(InpUpStep + Spred) * SymbolInfoDouble(symbol, SYMBOL_POINT);
//               double Price=m_symbol.NormalizePrice(iLow(NULL,PERIOD_M5,1)-(double)InpUpStep*(double)i*m_symbol.Point());
               double sl=0;
               double tp=0;
               m_trade.SellStop(Lots,price_bid,m_symbol.Name(),sl,tp);
              }
     
         
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void  ApplyStopLoss(string symbol, int magicNumber, double stopLoss) {
   static int     digits   =  (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    double sl = 0;
    double slb = 0;
    double sls = 0;
    double sli = 0;
    double slbi = 0;
    double slii = 0;
    double slsii = 0;
   double   Spred    =  NormalizeDouble(Ask() - Bid(), digits);
   datetime checkTime = TimeCurrent() -PositionOpenWithin;
   // Trailing from the close prices
   int      count          =  PositionsTotal();
   for (int i=count-1; i>=0; i--) {
      ulong ticket   =  PositionGetTicket(i);
      if (ticket>0) {
         if (PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_MAGIC)==magicNumber) 
         if (PositionGetInteger(POSITION_TIME)>checkTime)
         {
                 if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetDouble(POSITION_SL)==0)
                {
                    sl = PositionGetDouble(POSITION_PRICE_OPEN) - (InpStopLossPoints + Spred) * SymbolInfoDouble(symbol, SYMBOL_POINT);
                    slb = NormalizeDouble(sl, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
                    sli = Bid() - (InpStopLossPoints + Spred) * SymbolInfoDouble(symbol, SYMBOL_POINT);
                    slbi = NormalizeDouble(sli, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
                    if( slb < Bid() )
            Trade.PositionModify(ticket, slb, PositionGetDouble(POSITION_TP));
               else     if( slb > Bid() )
            Trade.PositionModify(ticket, slbi, PositionGetDouble(POSITION_TP));
                }    
                else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetDouble(POSITION_SL)==0)
                {
                    sl = PositionGetDouble(POSITION_PRICE_OPEN) + (InpStopLossPoints + Spred) * SymbolInfoDouble(symbol, SYMBOL_POINT);
                    sls = NormalizeDouble(sl, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
                    slii = Ask() + (InpStopLossPoints + Spred) * SymbolInfoDouble(symbol, SYMBOL_POINT);
                    slsii = NormalizeDouble(slii, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
                    if( sls > Ask() )
            Trade.PositionModify(ticket, sls, PositionGetDouble(POSITION_TP));
                else    if( sls < Ask() )
            Trade.PositionModify(ticket, slsii, PositionGetDouble(POSITION_TP));
                }    
        }
      }
   }
    
}
//+------------------------------------------------------------------+
void  ApplyBE( ) {
   int      count          =  PositionsTotal();
   for (int i=count-1; i>=0; i--) {
      ulong ticket   =  PositionGetTicket(i);
      if (ticket>0) {
         if (PositionGetInteger(POSITION_MAGIC)==InpMagicNumber) {
             string   symbol         =  PositionGetString(POSITION_SYMBOL);
   int        digits   =  (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   // Trailing from the close prices
 //  StopLoss =  SymbolInfoDouble(symbol, SYMBOL_POINT)*InpTrailingStopPoints;   
   BETrigger =  SymbolInfoDouble(symbol, SYMBOL_POINT)*InpTriggerBEStopLossPoints;   
   BESL =  SymbolInfoDouble(symbol, SYMBOL_POINT)*InpBEStopLossPoints;   
   double   Spred    =  NormalizeDouble(Ask() - Bid(), digits);
   double   buyStopLoss    =  NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);
   double   sellStopLoss   =  NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK), digits);
   double   Trigger    =  NormalizeDouble(BETrigger + Spred, digits);
   double   BEStopLoss    =  NormalizeDouble(BESL + Spred, digits);
         
            if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY 
            && PositionGetDouble(POSITION_PRICE_CURRENT)>PositionGetDouble(POSITION_PRICE_OPEN) + Trigger 
            && (PositionGetDouble(POSITION_SL)==0 || PositionGetDouble(POSITION_PRICE_OPEN) > PositionGetDouble(POSITION_SL))) {
               Trade.PositionModify(ticket, PositionGetDouble(POSITION_PRICE_OPEN) + BEStopLoss, PositionGetDouble(POSITION_TP));
            } else
            if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL 
            && PositionGetDouble(POSITION_PRICE_CURRENT) < PositionGetDouble(POSITION_PRICE_OPEN) - Trigger 
            && (PositionGetDouble(POSITION_SL)==0 || PositionGetDouble(POSITION_PRICE_OPEN) < PositionGetDouble(POSITION_SL))) {
               Trade.PositionModify(ticket,PositionGetDouble(POSITION_PRICE_OPEN) -  BEStopLoss, PositionGetDouble(POSITION_TP));
            }
         }
      }
   }
    
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void  ApplyTrailingStop( ) {
   int      count          =  PositionsTotal();
   for (int i=count-1; i>=0; i--) {
      ulong ticket   =  PositionGetTicket(i);
      if (ticket>0) {
         if (PositionGetInteger(POSITION_MAGIC)==InpMagicNumber) {
             string   symbol         =  PositionGetString(POSITION_SYMBOL);
   int        digits   =  (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   // Trailing from the close prices
 //  StopLoss =  SymbolInfoDouble(symbol, SYMBOL_POINT)*InpTrailingStopPoints;   
   BETrail =  SymbolInfoDouble(symbol, SYMBOL_POINT)*InpTrailStopLossPoints;   
   BETrigger =  SymbolInfoDouble(symbol, SYMBOL_POINT)*InpTriggerBEStopLossPoints;   
   BESL =  SymbolInfoDouble(symbol, SYMBOL_POINT)*InpBEStopLossPoints;   
   double   buyStopLoss    =  NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);
   double   sellStopLoss   =  NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK), digits);
   double   Trigger    =  NormalizeDouble(BETrigger, digits);
   double   BEStopLoss    =  NormalizeDouble(BESL, digits);
         
            if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY 
            && PositionGetDouble(POSITION_PRICE_CURRENT)>PositionGetDouble(POSITION_SL) + (BETrail * TrailMultiplier) 
            && PositionGetDouble(POSITION_PRICE_OPEN) < PositionGetDouble(POSITION_SL)) {
               Trade.PositionModify(ticket, PositionGetDouble(POSITION_PRICE_CURRENT) - BETrail, PositionGetDouble(POSITION_TP));
            } else
            if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL 
            && PositionGetDouble(POSITION_PRICE_CURRENT) < PositionGetDouble(POSITION_SL) - (BETrail * TrailMultiplier) 
            && PositionGetDouble(POSITION_PRICE_OPEN) > PositionGetDouble(POSITION_SL)) {
               Trade.PositionModify(ticket,PositionGetDouble(POSITION_PRICE_CURRENT) +  BETrail, PositionGetDouble(POSITION_TP));
            }
         }
      }
   }
    
}
//+------------------------------------------------------------------+
// 
void  InputStopLoss(string symbol, int magicNumber) {
   static int     digits   =  (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    double slb = 0;
    double sls = 0;
   // Trailing from the close prices
   int      count          =  PositionsTotal();
   for (int i=count-1; i>=0; i--) {
      ulong ticket   =  PositionGetTicket(i);
      if (ticket>0) {
         if (PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_MAGIC)==magicNumber) 
         {
                 if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && InpBuyStopLoss > 0
                 && PositionGetDouble(POSITION_SL)!=InpBuyStopLoss
                 && (PositionGetDouble(POSITION_SL)== 0 
                 ||PositionGetDouble(POSITION_SL) <PositionGetDouble(POSITION_PRICE_OPEN) ) )
                {
                    slb = NormalizeDouble(InpBuyStopLoss, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
            Trade.PositionModify(ticket, slb, PositionGetDouble(POSITION_TP));
                }    
                else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && InpSellStopLoss > 0
                && PositionGetDouble(POSITION_SL)!=InpSellStopLoss 
                && (PositionGetDouble(POSITION_SL)== 0 
                ||PositionGetDouble(POSITION_SL) >PositionGetDouble(POSITION_PRICE_OPEN) ) )
                {
                    sls = NormalizeDouble(InpSellStopLoss, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
            Trade.PositionModify(ticket, sls, PositionGetDouble(POSITION_TP));
                }    
        }
      }
   }
    
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Is pending orders exists                                         |
//+------------------------------------------------------------------+
bool IsPendingOrdersExists(void)
  {
   for(int i=OrdersTotal()-1; i>=0; i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() )
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IsPositionExists()
  {
   int count = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetTicket(i))
         if(PositionGetString(POSITION_SYMBOL)==Symbol())
           {
            count++;
           }
//---
   return(count);
  }
//+------------------------------------------------------------------+
void PendOrder()
   {
   int StopsLevel=m_symbol.StopsLevel();
   if(StopsLevel==0)
      StopsLevel=m_symbol.Spread()*3;
   
     for(int i=1; i<=InpUpQuantity; i++)
     {
      string   symbol         =  PositionGetString(POSITION_SYMBOL);
   int        digits   =  (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double   Spred    =  NormalizeDouble(Ask() - Bid(), digits);
      if(InpUpStep*i>StopsLevel)
        {
         if(Lots>0.0) if(PendingPriceTrigger)
           {
      if( BuyStopEntry > 0)
      if( CountPendingOrders() < InpUpQuantity) //&& 
      if(IsPositionExists() == 0)
      if( Ask() < BuyStopEntry - (Spred * 3) && iClose(NULL,TS_period,1) >= BuyStopEntry && iLow(NULL,TS_period,1) >= BuyStopEntry - Spred
      && iLow(NULL,TS_period,2) >= BuyStopEntry - Spred)
              {
 double price_ask    = (BuyStopEntry + Spred) + (double)CountPendingOrders()* (double)(InpUpStep) * SymbolInfoDouble(symbol, SYMBOL_POINT);
               double sl=0;
               double tp=0;
               m_trade.BuyStop(Lots,price_ask,m_symbol.Name(),sl,tp);
              }
     if( SellStopEntry > 0)
      if( CountPendingOrders() < InpUpQuantity)
      if(IsPositionExists() == 0)
      if( Bid() > SellStopEntry + (Spred * 3) && iClose(NULL,TS_period,1) <= SellStopEntry && iHigh(NULL,TS_period,1) <= SellStopEntry + Spred
      && iHigh(NULL,TS_period,2) <= SellStopEntry + Spred)
               {
 double price_bid    = (SellStopEntry + Spred) - (double)CountPendingOrders()* (double)(InpUpStep) * SymbolInfoDouble(symbol, SYMBOL_POINT);
               double sl=0;
               double tp=0;
               m_trade.SellStop(Lots,price_bid,m_symbol.Name(),sl,tp);
              }
     
         
           }
        }
     }
  }   
//---

//+------------------------------------------------------------------+
//| Get H Line                                            |
//+------------------------------------------------------------------+
double   HLineSLprice() 
   {
   return( ObjectGetDouble(0,"HLineSL",OBJPROP_PRICE));
   }
//+------------------------------------------------------------------+
//| Get current bid value                                            |
//+------------------------------------------------------------------+
double Bid()
  {
   return (SymbolInfoDouble(Symbol(), SYMBOL_BID));
  }

//+------------------------------------------------------------------+
//| Get current ask value                                            |
//+------------------------------------------------------------------+
double Ask()
  {
   return (SymbolInfoDouble(Symbol(), SYMBOL_ASK));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int digits()
  {
   return ((int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositions()
  {
   int total=PositionsTotal();
   for(int k=total-1; k>=0; k--)
      if(PositionGetTicket(k))
         if(PositionGetInteger(POSITION_TYPE)== POSITION_TYPE_BUY 
         || PositionGetInteger(POSITION_TYPE)== POSITION_TYPE_SELL)
           {
         if(PositionGetString(POSITION_SYMBOL)==Symbol())
            // position with appropriate ORDER_MAGIC, symbol and order type
            trade.PositionClose(PositionGetInteger(POSITION_TICKET), Slippage);
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTotalProfit()
  {
   double val = 0;
   double profit = 0, swap = 0, comm = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetTicket(i))
         if(PositionGetString(POSITION_SYMBOL)==Symbol())
        {
         profit = PositionGetDouble(POSITION_PROFIT);
         swap = PositionGetDouble(POSITION_SWAP);
         comm = AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED);
         val += profit + swap + comm;
        }
     }

   return (NormalizeDouble(val,2));
  }

//+------------------------------------------------------------------+
//|                                                                  |
///+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool createObject(string name,string text)
  {
   ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0,name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0,name, OBJPROP_XDISTANCE, 30);
   ObjectSetInteger(0,name, OBJPROP_YDISTANCE, 33);
   ObjectSetString(0,name,OBJPROP_TEXT, text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,14);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);

   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createObject2(string name,string text)
  {
   ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0,name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0,name, OBJPROP_XDISTANCE, 30);
   ObjectSetInteger(0,name, OBJPROP_YDISTANCE, 62);
   ObjectSetString(0,name,OBJPROP_TEXT, text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,14);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrDodgerBlue);

   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createObject4(string name,string text)
  {
   ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0,name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0,name, OBJPROP_XDISTANCE, 30);
   ObjectSetInteger(0,name, OBJPROP_YDISTANCE, 90);
   ObjectSetString(0,name,OBJPROP_TEXT, text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,14);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrDodgerBlue);

   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createObject3(string name, double val)
  {
   ObjectCreate(0,name, OBJ_HLINE, 0, 0, val );

   return (true);
  }
//+------------------------------------------------------------------+
bool createBackground()
  {
   ObjectCreate(0, "Background", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0,"Background", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, "Background", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, "Background", OBJPROP_YDISTANCE, 100);
   ObjectSetInteger(0, "Background", OBJPROP_XSIZE, 240);
   ObjectSetInteger(0, "Background", OBJPROP_YSIZE, 100);
   ObjectSetInteger(0, "Background", OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, "Background", OBJPROP_BORDER_COLOR, clrGreenYellow);
   ObjectSetInteger(0, "Background", OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0, "Background", OBJPROP_WIDTH, 0);
   ObjectSetInteger(0, "Background", OBJPROP_BACK, false);
   ObjectSetInteger(0, "Background", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "Background", OBJPROP_HIDDEN, true);
   return (true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
int CountPendingOrders()

{
   int TodayslimitedOrders = 0;

   for(int i=0; i<OrdersTotal(); i++)
   if(OrderSelect(OrderGetTicket(i)) 
   && OrderGetString(ORDER_SYMBOL) == _Symbol )   
      {
         TodayslimitedOrders += 1;
      }
   return(TodayslimitedOrders);
}//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartWrite(string  name,
                string  comment,
                int     x_distance,
                int     y_distance,
                int     FontSize,
                color   clr)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, comment);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, name,  OBJPROP_FONT, "Lucida Console");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y_distance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartWritei(string  name,
                string  comment,
                int     x_distance,
                int     y_distance,
                int     FontSize,
                color   clr)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, comment);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, name,  OBJPROP_FONT, "Lucida Console");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y_distance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartWriteii(string  name,
                string  comment,
                int     x_distance,
                int     y_distance,
                int     FontSize,
                color   clr)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, comment);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, name,  OBJPROP_FONT, "Lucida Console");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y_distance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartWriteiii(string  name,
                string  comment,
                int     x_distance,
                int     y_distance,
                int     FontSize,
                color   clr)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, comment);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, name,  OBJPROP_FONT, "Lucida Console");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y_distance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartWriteiv(string  name,
                string  comment,
                int     x_distance,
                int     y_distance,
                int     FontSize,
                color   clr)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, comment);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, name,  OBJPROP_FONT, "Lucida Console");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y_distance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartWritev(string  name,
                string  comment,
                int     x_distance,
                int     y_distance,
                int     FontSize,
                color   clr)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, comment);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, name,  OBJPROP_FONT, "Lucida Console");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y_distance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartWritevi(string  name,
                string  comment,
                int     x_distance,
                int     y_distance,
                int     FontSize,
                color   clr)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, comment);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, name,  OBJPROP_FONT, "Lucida Console");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y_distance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartWritevii(string  name,
                string  comment,
                int     x_distance,
                int     y_distance,
                int     FontSize,
                color   clr)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, comment);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, name,  OBJPROP_FONT, "Lucida Console");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y_distance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
