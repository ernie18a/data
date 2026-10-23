///+------------------------------------------------------------------+
//|                                                   Surfing_3.0.mq4 |
//|                                Copyright 2022, DCAPITAL, S.Dziuba |
//|                            https://www.thefinefolio.herokuapp.com |
//+-------------------------------------------------------------------+
#property copyright "Copyright 2022, FineFolio."
#property link      "https://www.finefolio.nettlify.app"
#property version   "2.00"
#property strict

extern double Lots = 1; //number of lots
extern int TakeProfit = 80; //take profit
extern int StopLoss = 50; //stop loss
extern int Slippage = 5; //slippage
extern string comment = "Surfing"; // comment that is send when the order opens.
extern int Magic = 123; // magic number

//--- indicator parameters for both MA HIGH and MA LOW
extern int MA_Period = 50;
extern double Coef = 0.0;
extern int MA_Shift = 0;
extern int SetPrice = 2;

//--- indicator parameters RSI
input int InpRSIPeriod=10; // RSI Period

//--- indicator parameters Moving Average of RSI
extern int RSIPeriod=10;


//--when to trade
extern int startHour = 8;//from which hour expert is allowed to trade
extern int endHour = 18;//till which hour expert is allowed to trade

double PriceHigh_1, PriceHigh_2, PriceLow_1, PriceLow_2, PriceClose_1, PriceClose_2, SL, TP, RSIk, MArsi, MA100;
int ticket;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Digits == 3|| Digits == 5)
     {
      TakeProfit *= 10;
      StopLoss *= 10;
      Slippage *=10;
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {


  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   PriceHigh_1 = iMA(Symbol(), PERIOD_CURRENT, MA_Period, MA_Shift,MODE_EMA, PRICE_HIGH,1);
   PriceHigh_2 = iMA(Symbol(), PERIOD_CURRENT, MA_Period, MA_Shift,MODE_EMA, PRICE_HIGH,2);
   PriceLow_1 = iMA(Symbol(), PERIOD_CURRENT, MA_Period, MA_Shift,MODE_EMA, PRICE_LOW,1);
   PriceLow_2 = iMA(Symbol(), PERIOD_CURRENT, MA_Period, MA_Shift,MODE_EMA, PRICE_LOW,2);
   PriceClose_1 = iClose(Symbol(),PERIOD_CURRENT, 1);
   PriceClose_2 = iClose(Symbol(),PERIOD_CURRENT, 2);
   RSIk = iRSI(Symbol(),PERIOD_CURRENT,RSIPeriod,PRICE_CLOSE,0);
   MA100 = iMA(Symbol(), PERIOD_CURRENT, 100, MA_Shift,MODE_SMA, PRICE_CLOSE,1);

//+----Buy
   if(PriceClose_2 <= PriceHigh_2 && PriceClose_1 > PriceHigh_1 && CountBuy() == 0 && RSIk > 40
      && TimeHour(TimeCurrent()) >= startHour && TimeHour(TimeCurrent()) < endHour)
     {
      SL = NormalizeDouble(Ask - StopLoss * Point, Digits);
      TP = NormalizeDouble(Ask + TakeProfit * Point, Digits);
      if(CheckMoneyForTrade(Symbol(),Lots,OP_BUY))
        {
         ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0, comment, Magic, 0, Blue);
         if(ticket > 0)
           {
            if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) == true)
               bool modify2 = OrderModify(ticket, OrderOpenPrice(), SL, TP, 0);
           }
         if(ticket<0)
           {
            int errorCode = GetLastError();
            if(errorCode == ERR_NOT_ENOUGH_MONEY)
              {
               Print("Error: Not enough money to open the trade. Adjusting lot size or risk management.");
               // Implement corrective action, e.g., reducing lot size or logging the issue
              }
            else
              {
               Print("Trade failed. Error code: ", errorCode);
              }
            return;
           }
        }

     }

   if(PriceClose_2 > PriceLow_2 && PriceClose_1 <= PriceLow_1 && CountBuy() > 0)
     {
      for(int i=OrdersTotal()-1; i >=0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ==true)
           {
            if(OrderMagicNumber() == Magic && OrderType() == OP_SELL)
               bool close2 = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, Black);
           }

        }

     }

//+---Sell
   if(PriceClose_2 >= PriceLow_2 && PriceClose_1 < PriceLow_1 && CountSell() == 0 && RSIk < 65
      && TimeHour(TimeCurrent()) >= startHour && TimeHour(TimeCurrent()) < endHour)
     {
      SL = NormalizeDouble(Bid + StopLoss * Point, Digits);
      TP = NormalizeDouble(Bid - TakeProfit * Point, Digits);
      if(CheckMoneyForTrade(Symbol(),Lots,OP_SELL))
        {
         ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0, comment, Magic, 0, Red);
         if(ticket > 0)
           {
            if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) == true)
               bool modify1 = OrderModify(ticket, OrderOpenPrice(), SL, TP, 0);
           }
         if(ticket<0)
           {
            int errorCode = GetLastError();
            if(errorCode == ERR_NOT_ENOUGH_MONEY)
              {
               Print("Error: Not enough money to open the trade. Adjusting lot size or risk management.");
               // Implement corrective action, e.g., reducing lot size or logging the issue
              }
            else
              {
               Print("Trade failed. Error code: ", errorCode);
              }
            return;
           }
        }
     }

   if(PriceClose_2 <= PriceHigh_2 && PriceClose_1 > PriceHigh_1 && CountSell() > 0)
     {
      for(int i=OrdersTotal() - 1; i >= 0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
           {
            if(OrderMagicNumber() == Magic && OrderType() == OP_BUY)
               bool close1 = OrderClose(OrderTicket(), OrderLots(), Bid,Slippage, Black);
           }

        }

     }

   if(TimeHour(TimeCurrent()) >= endHour)
     {
      closeAllPos();
     }
  }



//+------------------------------------------------------------------+
//| Counting number of orders for buying and selling                 |
//+------------------------------------------------------------------+
int CountBuy()
  {
   int count = 0;
   for(int trade = OrdersTotal()-1; trade >= 0; trade--)
     {
      bool select2 = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()== Symbol()&& OrderMagicNumber() == Magic)
        {
         if(OrderType() == OP_BUY)
            count++;
        }
     }
   return (count);
  }
//+------------------------------------------------------------------+
int CountSell()
  {
   int count = 0;
   for(int trade = OrdersTotal()-1; trade >= 0; trade--)
     {
      bool select1 = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()== Symbol()&& OrderMagicNumber() == Magic)
        {
         if(OrderType() == OP_SELL)
            count++;
        }

     }
   return (count);
  }
//+------------------------------------------------------------------+
//| Trailing Stop                                                    |
//+------------------------------------------------------------------+
void tStop(string symb,int stop, int MN)// Symbol + stop in pips + magic number
  {
   double bsl=NormalizeDouble(MarketInfo(symb,MODE_BID)-stop*MarketInfo(symb,MODE_POINT),MarketInfo(symb,MODE_DIGITS));
   double ssl=NormalizeDouble(MarketInfo(symb,MODE_ASK)+stop*MarketInfo(symb,MODE_POINT),MarketInfo(symb,MODE_DIGITS));

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==MN)
            if(OrderSymbol()==symb)

               if(OrderType()==OP_BUY && (OrderStopLoss()<bsl || OrderStopLoss()==0))
                  if(OrderModify(OrderTicket(),OrderOpenPrice(),bsl,OrderTakeProfit(),0,clrNONE))
                    {
                     Print(symb+" Buy's Stop Trailled to "+(string)bsl);
                    }
                  else
                    {
                     Print(symb+" Buy's Stop Trail ERROR");
                    }

      if(OrderType()==OP_SELL && (OrderStopLoss()>ssl || OrderStopLoss()==0))
         if(OrderModify(OrderTicket(),OrderOpenPrice(),ssl,OrderTakeProfit(),0,clrNONE))
           {
            Print(symb+" Sell's Stop Trailled to "+(string)ssl);
           }
         else
           {
            Print(symb+" Sell's Stop Trail ERROR");
           }
     }
  }

// Close all postions

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeByPos()
  {
   bool repeatOpen=false;
#ifdef __MQL5__
   int cntMyPos=PositionsTotal();
   for(int ti=cntMyPos-1; ti>=0; ti--)
     {
      if(PositionGetSymbol(ti)!=_Symbol)
         continue;
      if(EA_Magic>0 && PositionGetInteger(POSITION_MAGIC)!=EA_Magic)
         continue;

      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         long closefirst=PositionGetInteger(POSITION_TICKET);
         double closeLots=PositionGetDouble(POSITION_VOLUME);

         for(int ti2=cntMyPos-1; ti2>=0; ti2--)
           {
            if(PositionGetSymbol(ti2)!=_Symbol)
               continue;
            if(EA_Magic>0 && PositionGetInteger(POSITION_MAGIC)!=EA_Magic)
               continue;
            if(PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_SELL)
               continue;
            if(PositionGetDouble(POSITION_VOLUME)!=closeLots)
               continue;

            MqlTradeRequest request;
            MqlTradeResult  result;
            ZeroMemory(request);
            ZeroMemory(result);
            request.action=TRADE_ACTION_CLOSE_BY;
            request.position=closefirst;
            request.position_by=PositionGetInteger(POSITION_TICKET);
            if(EA_Magic>0)
               request.magic=EA_Magic;
            if(OrderSend(request,result))
              {
               repeatOpen=true;
               break;
              }
           }
         if(repeatOpen)
           {
            break;
           }
        }
     }
#else
   int cntMyPos=OrdersTotal();
   if(cntMyPos>0)
     {
      for(int ti=cntMyPos-1; ti>=0; ti--)
        {
         if(OrderSelect(ti,SELECT_BY_POS,MODE_TRADES)==false)
            continue;
         if(OrderSymbol()!=_Symbol)
            continue;
         if(Magic>0 && OrderMagicNumber()!=Magic)
            continue;

         if(OrderType()==OP_BUY)
           {
            int closefirst=OrderTicket();
            double closeLots=OrderLots();

            for(int ti2=cntMyPos-1; ti2>=0; ti2--)
              {
               if(OrderSelect(ti2,SELECT_BY_POS,MODE_TRADES)==false)
                  continue;
               if(OrderSymbol()!=_Symbol)
                  continue;
               if(Magic>0 && OrderMagicNumber()!=Magic)
                  continue;
               if(OrderType()!=OP_SELL)
                  continue;
               if(OrderLots()<closeLots)
                  continue;

               if(OrderCloseBy(closefirst, OrderTicket()))
                 {
                  repeatOpen=true;
                  break;
                 }
              }
            if(repeatOpen)
              {
               break;
              }
           }

        }
     }
#endif
// если мы закрыли какую-нибудь позицию встречной,
// то снова запускаем функцию closeByPos
   if(repeatOpen)
     {
      closeByPos();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllPos()
  {
   closeByPos();
   int cntMyPos=OrdersTotal();
   if(cntMyPos>0)
     {
      for(int ti=cntMyPos-1; ti>=0; ti--)
        {
         if(OrderSelect(ti,SELECT_BY_POS,MODE_TRADES)==false)
            continue;
         if(OrderSymbol()!=_Symbol)
            continue;
         if(Magic>0 && OrderMagicNumber()!=Magic)
            continue;

         if(OrderType()==OP_BUY)
           {
            MqlTick latest_price;
            if(!SymbolInfoTick(OrderSymbol(),latest_price))
              {
               Alert(GetLastError());
               return;
              }
            if(!OrderClose(OrderTicket(), OrderLots(),latest_price.bid,100))
              {
              }
           }
         else
            if(OrderType()==OP_SELL)
              {
               MqlTick latest_price;
               if(!SymbolInfoTick(OrderSymbol(),latest_price))
                 {
                  Alert(GetLastError());
                  return;
                 }
               if(!OrderClose(OrderTicket(), OrderLots(),latest_price.ask,100))
                 {
                 }
              }
            else
              {
               if(!OrderDelete(OrderTicket()))
                 {
                 }
              }

        }
     }
  }
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type, lots);
//-- if there is not enough money
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
