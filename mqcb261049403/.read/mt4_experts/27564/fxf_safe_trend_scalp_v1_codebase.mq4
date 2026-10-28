//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                         FXF Safe Trend Scalp.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright © 2017 - 2020, FXnode.ir"
#property link        "http://www.FXnode.ir"
#property version     "1.0"
#property description "Safe Trend Scalp v1"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input    int      MagicNumber    =     123321;     // Magic Number
input    double   StaticLot      =     0.01;       // Static Order lot for MoneyManagment OFF
input    int      SL             =     500;        // Order Stop loss (Point)
input    int      TP             =     500;        // Order Take Profit (Point)
input    int      MaxSpread      =     20;         // Maximum Spread Allowed
input    int      TTprofit       =     50;         // Total Profit to close All Martingle Orders
input    ENUM_TIMEFRAMES TimeFrame  = PERIOD_H1;   // Working time frame
input    bool     drawarrow      = false;          // Draw Buy sell signal


int        LossLimit      =  20,
           losses         =  0;

//+------------------------------------------------------------------+
//|  Global Variable init                                            |
//+------------------------------------------------------------------+
double   OrderLot    =  0,
         MaxOrderLot,
         ASK,
         BID,
         POINT,
         SPREAD,
         Risk        =  1;

int      MyOrderTicket=0,
         MartingleTicket=0;

string   SYMBOL;
string   SIGNAL = "none";

/////////////// TREND LINE
int       InpDepth         = 2;  // Depth
int       InpDeviation     = 3;   // Deviation
int       InpBackstep      = 1;   // Backstep
int       ZigZagNum        = 10;  // Number Of High And Low
color     Color_UPLine     = clrOrange;    // Color Of Sell Line
color     Color_DWLine     = clrDarkTurquoise;    // Color Of Buy Line

string  MODE = "none"; //trendLine mode
bool    DrawTrend = false;

double Bullish = EMPTY_VALUE, Bearish = EMPTY_VALUE, ZigZagHigh[], ZigZagLow[],LineValLow=0,LineValHigh=0;
int  First_Low_Candel=0,Secund_Low_Candel=3,First_High_Candel=0,Secund_High_Candel=3,ZigHCandel[],ZigLCandel[];
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//|  OnInit                                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   TrendLine();
   SYMBOL      =  Symbol();
   POINT       =  Point;
  
   ChartSetSymbolPeriod(0,NULL,TimeFrame);
   return(INIT_SUCCEEDED);
  }
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//|  OnDeinit                                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(ChartID(), "FXNODE.");
   Comment("");
  }
//====================================================================
//====================================================================
//+------------------------------------------------------------------+
//|  OnTick                                                          |
//+------------------------------------------------------------------+
void OnTick()
  {
   TrendLine();
   double   AllBuyProfit,
            AllSellProfit,
            MyTotalProfit,
            MA100=0,
            MA50 =0;

   bool     WeHaveSellOrder=  false,
            WeHaveBuyOrder =  false,
            SellMartingle  =  false,
            BuyMartingle   =  false;

   int      TotalOrder     =  0,
            TotalSell      =  0,
            TotalBuy       =  0;

   RefreshRates();
   ASK       =  Ask;
   BID       =  Bid;
   SPREAD    =  MarketInfo(SYMBOL,MODE_SPREAD);

   AllBuyProfit    = TotalProfit("Buy",Symbol(),MagicNumber);
   AllSellProfit   = TotalProfit("Sell",Symbol(),MagicNumber);
   MyTotalProfit   = AllBuyProfit+AllSellProfit;
   TotalSell       = OrderCount("Sell",Symbol(),MagicNumber);
   TotalBuy        = OrderCount("Buy",Symbol(),MagicNumber);
   TotalOrder      = TotalSell+TotalBuy;

//+------------------------------------------------------------------+
//|  Your Strategi To Open New Orders                                |
//+------------------------------------------------------------------+
//-------MA's Time Frame Actual Vela Anterior--------


   LineValHigh = NormalizeDouble(ObjectGetValueByShift("FXNODE.HighLine", 0),Digits);
   LineValLow  = NormalizeDouble(ObjectGetValueByShift("FXNODE.LowLine", 0),Digits);

   if(TotalOrder==0)
     {
      MA100  =  iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,0);
      MA50   =  iMA(NULL,0,2,0,MODE_SMA,PRICE_CLOSE,0);
      if(ASK > LineValHigh-10*Point && SIGNAL != "SELL" && MA50<MA100)
         SIGNAL = "SELL";
      if(ASK < LineValLow+10*Point &&  SIGNAL != "BUY" && MA50>MA100)
         SIGNAL = "BUY";
     }

   if(TotalSell > 0)
      WeHaveSellOrder   =  true;
   if(TotalBuy  > 0)
      WeHaveBuyOrder    =  true;

   if(WeHaveSellOrder && AllSellProfit < 0)
      SellMartingle = TRUE;
   if(WeHaveBuyOrder  && AllBuyProfit  < 0)
      BuyMartingle  = TRUE;

   if(isNewBar() && TotalOrder == 0 && SPREAD<=MaxSpread)
     {
      OrderLot        =  CheckLots(Symbol(),Risk,SL,StaticLot);
      if(OrderLot > 0)
        {
         if(SIGNAL == "BUY" && TotalBuy==0)
           {
            MyOrderTicket  = SendBuyOrder(SYMBOL,OrderLot,SL,TP,MagicNumber,20,10," BUY",0,clrLimeGreen);
           }
         if(SIGNAL == "SELL" && TotalSell==0)
           {
            MyOrderTicket  = SendSellOrder(SYMBOL,OrderLot,SL,TP,MagicNumber,20,10," SELL",0,clrBrown);
           }
        }
     }

   if(MyTotalProfit > OrderLot*TTprofit)
      CloseAll("All",SYMBOL,MagicNumber,"TP riched at " + (string)MyTotalProfit);
  }
//====================================================================


//+------------------------------------------------------------------+
//|  Take Buy Order                                                  |
//+------------------------------------------------------------------+
int SendBuyOrder(string sym, double FXlot, int stopLoss,int takeProfit, int magic, int maxspread, int slipage, string FXcomment, datetime  expi, color Ocolor)
  {
   if(maxspread > 0 && MarketInfo(sym, MODE_SPREAD) > maxspread)
      return(0);
   double sl, tp, point = MarketInfo(sym, MODE_POINT), price = MarketInfo(sym, MODE_ASK);
   if(stopLoss != 0)
      sl = NormalizeDouble(MathMin(price - stopLoss * point, MarketInfo(sym, MODE_BID) - MarketInfo(sym, MODE_STOPLEVEL) * point), (int)MarketInfo(sym, MODE_DIGITS));
   else
      sl = 0;
   if(takeProfit != 0)
      tp = NormalizeDouble(MathMax(price + takeProfit * point, MarketInfo(sym, MODE_BID) + MarketInfo(sym, MODE_STOPLEVEL) * point), (int)MarketInfo(sym, MODE_DIGITS));
   else
      tp = 0;
   return(OrderSend(sym, OP_BUY, FXlot, price, slipage, sl, tp, FXcomment + " | BUY", magic,expi,Ocolor));
  }
//+------------------------------------------------------------------+
//|  Take Sell Order                                                 |
//+------------------------------------------------------------------+
int SendSellOrder(string sym, double FXlot, int stopLoss,int takeProfit, int magic, int maxspread, int slipage, string FXcomment, datetime  expi, color Ocolor)
  {
   if(maxspread > 0 && MarketInfo(sym, MODE_SPREAD) > maxspread)
      return(0);
   double sl, tp, point = MarketInfo(sym, MODE_POINT), price = MarketInfo(sym, MODE_BID);
   if(stopLoss != 0)
      sl = NormalizeDouble(MathMax(price + stopLoss * point, MarketInfo(sym, MODE_ASK) +
                                   MarketInfo(sym, MODE_STOPLEVEL) * point), (int)MarketInfo(sym, MODE_DIGITS));
   else
      sl = 0.0;
   if(takeProfit != 0)
      tp = NormalizeDouble(MathMin(price - takeProfit * point, MarketInfo(sym, MODE_ASK) -
                                   MarketInfo(sym, MODE_STOPLEVEL) * point), (int)MarketInfo(sym, MODE_DIGITS));
   else
      tp = 0.0;
   return(OrderSend(sym, OP_SELL, FXlot, price, slipage, sl, tp, FXcomment + " | SELL", magic,expi,Ocolor));
  }













//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrendLine()
  {
   ArrayResize(ZigZagHigh,ZigZagNum,1);
   ArrayResize(ZigZagLow,ZigZagNum,1);
   ArrayResize(ZigHCandel,ZigZagNum,1);
   ArrayResize(ZigLCandel,ZigZagNum,1);
   double high = -1, low = -1;
   double data=0;
   int    lowcount = 0, highcount = 0;

   for(int i = 0; i < 200; i++)
     {
      high = iCustom(Symbol(),TimeFrame, "ZigZag", InpDepth,InpDeviation,InpBackstep, 1, i);
      if((high > 0) && (high == iCustom(Symbol(),TimeFrame, "ZigZag", InpDepth,InpDeviation,InpBackstep, 0, i)))
        {
         ZigZagHigh[highcount] = high;
         ZigHCandel[highcount] = i;
         highcount++;
        }
      high = -1;
      if(highcount == ZigZagNum)
         break;
     }

  
  
   for(int i = 0; i < 200; i++)
     {
      low = iCustom(Symbol(),TimeFrame, "ZigZag", InpDepth,InpDeviation,InpBackstep, 2, i);
      if((low > 0) && (low == iCustom(Symbol(),TimeFrame, "ZigZag", InpDepth,InpDeviation,InpBackstep, 0, i)))
        {
         ZigZagLow[lowcount] = low;
         ZigLCandel[lowcount] = i;
         lowcount++;
        }
      low = -1;
      if(lowcount == ZigZagNum)
         break;
     }


   if (drawarrow == true)
   {
   for(int j = 0; j <= ZigZagNum-1; j++)
     {
      if(ObjectFind(0,"FXNODE.ZigZagHigh") < 0)
        {
         ObjectDelete("FXNODE.ZigZagHigh."+IntegerToString(j));
         ObjectCreate(0,"FXNODE.ZigZagHigh."+IntegerToString(j),OBJ_ARROW,0,0,0,0,0);          // Create an arrow
         ObjectSetInteger(0,"FXNODE.ZigZagHigh."+IntegerToString(j),OBJPROP_ARROWCODE,238);    // Set the arrow code
         ObjectSetInteger(0,"FXNODE.ZigZagHigh."+IntegerToString(j),OBJPROP_COLOR,clrCrimson);
        }
      ObjectSetInteger(0,"FXNODE.ZigZagHigh."+IntegerToString(j),OBJPROP_TIME,Time[ZigHCandel[j]]);        // Set time
      ObjectSetDouble(0,"FXNODE.ZigZagHigh."+IntegerToString(j),OBJPROP_PRICE,ZigZagHigh[j]+(10+(Period()/100))*Point);// Set price
     }

   for(int j = 0; j <= ZigZagNum-1; j++)
     {
      if(ObjectFind(0,"FXNODE.ZigZagLow") < 0)
        {
         ObjectDelete("FXNODE.ZigZagLow."+IntegerToString(j));
         ObjectCreate(0,"FXNODE.ZigZagLow."+IntegerToString(j),OBJ_ARROW,0,0,0,0,0);          // Create an arrow
         ObjectSetInteger(0,"FXNODE.ZigZagLow."+IntegerToString(j),OBJPROP_ARROWCODE,236);    // Set the arrow code
         ObjectSetInteger(0,"FXNODE.ZigZagLow."+IntegerToString(j),OBJPROP_COLOR,clrOliveDrab);
        }
      ObjectSetInteger(0,"FXNODE.ZigZagLow."+IntegerToString(j),OBJPROP_TIME,Time[ZigLCandel[j]]);        // Set time
      ObjectSetDouble(0,"FXNODE.ZigZagLow."+IntegerToString(j),OBJPROP_PRICE,ZigZagLow[j]-(10+(Period()/250))*Point);// Set price
     }
   }
  
   DrawTrend = true;
   First_Low_Candel=0;
   Secund_Low_Candel=3;
   First_High_Candel=0;
   Secund_High_Candel=3;
   MODE = "none";


/////////////////////////////////////////////////////////////////////////////////////////////

   if((highcount > 2) && (DrawTrend == true))
     {
      //DrawLine("FXNODE.HighLine",Time[ZigHCandel[Secund_High_Candel]],ZigZagHigh[Secund_High_Candel],Time[ZigHCandel[First_High_Candel]],ZigZagHigh[First_High_Candel],clrBlack,1);
      ObjectDelete("FXNODE.HighLine");
      ObjectCreate("FXNODE.HighLine", OBJ_TREND, 0, Time[ZigHCandel[Secund_High_Candel]],ZigZagHigh[Secund_High_Candel],Time[ZigHCandel[First_High_Candel]],ZigZagHigh[First_High_Candel]);
      ObjectSet("FXNODE.HighLine", OBJPROP_COLOR, clrChocolate);
      ObjectSet("FXNODE.HighLine", OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, "FXNODE.HighLine", OBJPROP_HIDDEN,false);
     }
   if((lowcount > 2) && (DrawTrend == true))
     {
      //DrawLine("FXNODE.LowLine",Time[ZigLCandel[Secund_Low_Candel]],ZigZagLow[Secund_Low_Candel],Time[ZigLCandel[First_Low_Candel]],ZigZagLow[First_Low_Candel],clrBlack,1);
      ObjectDelete("FXNODE.LowLine");
      ObjectCreate("FXNODE.LowLine", OBJ_TREND, 0, Time[ZigLCandel[Secund_Low_Candel]],ZigZagLow[Secund_Low_Candel],Time[ZigLCandel[First_Low_Candel]],ZigZagLow[First_Low_Candel]);
      ObjectSet("FXNODE.LowLine", OBJPROP_COLOR, clrSpringGreen);
      ObjectSet("FXNODE.LowLine", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("FXNODE.LowLine", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, "FXNODE.LowLine", OBJPROP_HIDDEN,false);
     }
  }






//+------------------------------------------------------------------+
//| CloseOrder With Type and magic                                   |
//+------------------------------------------------------------------+
void CloseAll(string type, string symbol, int magic, string FXcomment)
  {
   int Check;
   for(int FXi = OrdersTotal() - 1; FXi >= 0; FXi--)
      if(OrderSelect(FXi,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderMagicNumber() == magic && OrderSymbol() == symbol)
           {
            if(type == "All")  // Close All orders type
              {
               if(OrderType() == OP_BUY)
                  Check = OrderClose(OrderTicket(), OrderLots(), MarketInfo(symbol,MODE_BID), 5, clrGold);
               if(OrderType() == OP_SELL)
                  Check = OrderClose(OrderTicket(), OrderLots(), MarketInfo(symbol,MODE_ASK), 5, clrGold);
               Print("Close All " +symbol+ " orders. | " + FXcomment);
               Sleep(50);
              }
            if(type == "Buy")  // Close All Buy type
              {
               if(OrderType() == OP_BUY)
                  Check = OrderClose(OrderTicket(), OrderLots(), MarketInfo(symbol,MODE_BID), 5, clrGold);
               Print("Close " +symbol+ " Buys. | " + FXcomment);
               Sleep(50);
              }
            if(type == "Sell")  // Close All Sell type
              {
               if(OrderType() == OP_SELL)
                  Check = OrderClose(OrderTicket(), OrderLots(), MarketInfo(symbol,MODE_ASK), 5, clrGold);
               Print("Close " +symbol+ " Sells. | " + FXcomment);
               Sleep(50);
              }
           }
  }

//+------------------------------------------------------------------+
//| Manage Order Volum (LOT)                                         |
//+------------------------------------------------------------------+
double CheckLots(string symbol, double FXrisk,double stopSize, double staticlot)
  {
   double   Margin_required = MarketInfo(symbol, MODE_MARGINREQUIRED),
            MinLot          = MarketInfo(symbol, MODE_MINLOT),
            MaxLot          = MarketInfo(symbol, MODE_MAXLOT),
            Lot_step        = MarketInfo(symbol, MODE_LOTSTEP),
            Tick_value      = MarketInfo(symbol, MODE_TICKVALUE);
   if(Lot_step==0)
      Lot_step=0.01;

   
      if(staticlot*Margin_required > AccountFreeMargin()) staticlot=0;
      
      if(staticlot>0)
        {
         staticlot=MathFloor(staticlot/Lot_step + 0.5)* Lot_step;
         if(staticlot < MinLot)
            staticlot = MinLot;
         if(staticlot > MaxLot)
            staticlot = MaxLot;
        }
     return(staticlot);
  }




//+------------------------------------------------------------------+
//|  To Run the expert once per every new Bar                        |
//+------------------------------------------------------------------+
bool isNewBar()
  {
   static datetime TimeBar=0;
   bool newbar=false;
   if(TimeBar!=Time[0])
     {
      TimeBar=Time[0];
      newbar=true;
     }
   return (newbar);
  }



//+------------------------------------------------------------------+
//|  Count Opened Stop Order                                         |
//+------------------------------------------------------------------+
int OrderCount(string type, string symbol, int magic)
  {
   int count = 0, tikket;
   for(int trade = OrdersTotal() - 1; trade >= 0; trade--)
     {
      tikket = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != symbol || OrderMagicNumber() != magic)
         continue;
      if(type == "All")
        {
         if(OrderType() == OP_SELL || OrderType() == OP_BUY)
            count++;
        }
      if(type == "Buy")
        {
         if(OrderType() == OP_BUY)
            count++;
        }
      if(type == "Sell")
        {
         if(OrderType() == OP_SELL)
            count++;
        }
     }
   return (count);
  }


//+------------------------------------------------------------------+
//| TotalProfit                                                      |
//+------------------------------------------------------------------+
double TotalProfit(string type, string symbol, int magic)
  {
   double totalProfit=0;
   int tikkk,conter;
   for(conter = OrdersTotal() - 1; conter >= 0; conter--)
     {
      tikkk = OrderSelect(conter, SELECT_BY_POS, MODE_TRADES);
      if((OrderSymbol() == symbol && OrderMagicNumber() == magic) || (symbol=="All"))
        {
         if(type=="All" && (OrderType() == OP_BUY || OrderType() == OP_SELL))
           {
            totalProfit = totalProfit + OrderProfit() + OrderCommission() + OrderSwap();
           }
         else
            if(type == "Buy" && OrderType() == OP_BUY)
              {
               totalProfit = totalProfit + OrderProfit() + OrderCommission() + OrderSwap();
              }
            else
               if(type == "Sell" && OrderType() == OP_SELL)
                 {
                  totalProfit = totalProfit + OrderProfit() + OrderCommission() + OrderSwap();
                 }
        }
     }
   return(totalProfit);
  }
//+------------------------------------------------------------------+