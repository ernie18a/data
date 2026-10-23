//************************************************************************************************/
//*                                   VR Smart Grid Lite.mq4                                     */
//*                            Copyright 2020, Trading-go Project.                               */
//*            Author: Voldemar, Version: 18.12.2019, Site https://trading-go.ru                 */
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
//VR Smart Grid            https://www.mql5.com/ru/market/product/28140
//VR Smart Grid Lite       https://www.mql5.com/ru/code/20223/
//VR Smart Grid MT5        https://www.mql5.com/ru/market/product/38626/
//VR Smart Grid Lite MT5   https://www.mql5.com/ru/code/25528/
//Blog RU                  https://www.mql5.com/ru/blogs/post/726568
//Blog EN                  https://www.mql5.com/en/blogs/post/726569
//************************************************************************************************/
//| All products of the Author https://www.mql5.com/ru/users/voldemar/seller
//************************************************************************************************/
#property copyright   "Copyright 2020, Trading-go Project."
#property link        "https://trading-go.ru"
#property version     "19.120"
#property description " "
#property strict
enum ENUM_ST
  {
   Awerage   = 0, // Awerage
   PartClose = 1  // Part Close
  };
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
input int          iTakeProfit         = 300;      // Take Profit (in pips)
input double       iStartLots          = 0.01;     // Start lot
input double       iMaximalLots        = 2.56;     // Maximal Lots
input ENUM_ST      iCloseOrder         = Awerage;  // Type close orders
input int          iPointOrderStep     = 390;      // Point order step (in pips)
input int          iMinimalProfit      = 70;       // Minimal profit for close grid (in pips)
input int          iMagicNumber        = 227;      // Magic Number (in number)
input int          iSlippage           = 30;       // Slippage (in pips)
//---
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnInit()
  {
   Comment("");
   return(INIT_SUCCEEDED);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnTick()
  {
   double
   BuyPriceMax = 0, BuyPriceMin = 0, BuyPriceMaxLot = 0, BuyPriceMinLot = 0,
   SelPriceMin = 0, SelPriceMax = 0, SelPriceMinLot = 0, SelPriceMaxLot = 0;

   int
   BuyPriceMaxTic = 0, BuyPriceMinTic = 0, SelPriceMaxTic = 0, SelPriceMinTic = 0;

   double
   op = 0, lt = 0, tp = 0;

   int
   tk = 0, b = 0, s = 0;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber() == iMagicNumber)
            if(OrderSymbol() == Symbol())
              {
               op = NormalizeDouble(OrderOpenPrice(), Digits());
               lt = NormalizeDouble(OrderLots(), 2);
               tk = OrderTicket();
               if(OrderType() == OP_BUY)
                 {
                  b++;
                  if(op > BuyPriceMax || BuyPriceMax == 0)
                    {
                     BuyPriceMax    = op;
                     BuyPriceMaxLot = lt;
                     BuyPriceMaxTic = tk;
                    }
                  if(op < BuyPriceMin || BuyPriceMin == 0)
                    {
                     BuyPriceMin    = op;
                     BuyPriceMinLot = lt;
                     BuyPriceMinTic = tk;
                    }
                 }
               // ===
               if(OrderType() == OP_SELL)
                 {
                  s++;
                  if(op > SelPriceMax || SelPriceMax == 0)
                    {
                     SelPriceMax    = op;
                     SelPriceMaxLot = lt;
                     SelPriceMaxTic = tk;
                    }
                  if(op < SelPriceMin || SelPriceMin == 0)
                    {
                     SelPriceMin    = op;
                     SelPriceMinLot = lt;
                     SelPriceMinTic = tk;
                    }
                 }
              }
//*************************************************************//
   double   AwerageBuyPrice = 0, AwerageSelPrice = 0;

   if(iCloseOrder == Awerage)
     {
      if(b >= 2)
         AwerageBuyPrice = NormalizeDouble((BuyPriceMax * BuyPriceMaxLot + BuyPriceMin * BuyPriceMinLot) / (BuyPriceMaxLot + BuyPriceMinLot) + iMinimalProfit * Point(), Digits());
      if(s >= 2)
         AwerageSelPrice = NormalizeDouble((SelPriceMax * SelPriceMaxLot + SelPriceMin * SelPriceMinLot) / (SelPriceMaxLot + SelPriceMinLot) - iMinimalProfit * Point(), Digits());
     }

   if(iCloseOrder == PartClose)
     {
      if(b >= 2)
         AwerageBuyPrice = NormalizeDouble((BuyPriceMax * iStartLots + BuyPriceMin * BuyPriceMinLot) / (iStartLots + BuyPriceMinLot) + iMinimalProfit * Point(), Digits());
      if(s >= 2)
         AwerageSelPrice = NormalizeDouble((SelPriceMax * SelPriceMaxLot + SelPriceMin * iStartLots) / (SelPriceMaxLot + iStartLots) - iMinimalProfit * Point(), Digits());
     }
//*************************************************************//
   double BuyLot = 0, SelLot = 0;
   if(BuyPriceMinLot == 0)
      BuyLot = iStartLots;
   else
      BuyLot = BuyPriceMinLot * 2;
   if(SelPriceMaxLot == 0)
      SelLot = iStartLots;
   else
      SelLot = SelPriceMaxLot * 2;
//*************************************************************//
   if(iMaximalLots >0)
     {
      if(BuyLot > iMaximalLots)
         BuyLot = iMaximalLots;
      if(SelLot > iMaximalLots)
         SelLot = iMaximalLots;
     }
   if(!CheckVolumeValue(BuyLot) || !CheckVolumeValue(SelLot))
      return;
//*************************************************************//
   if(Close[1] > Open[1])
      if((b == 0) || (b > 0 && (BuyPriceMin - Ask) > (iPointOrderStep * Point())))
         if(OrderSend(Symbol(), OP_BUY, NormalizeDouble(BuyLot, 2), NormalizeDouble(Ask, Digits()), iSlippage, 0, 0, "VR Setka Lite", iMagicNumber, 0, clrGreen) < 0)
            Print("OrderSend error #", GetLastError());

   if(Close[1] < Open[1])
      if((s == 0) || (s > 0 && (Bid - SelPriceMax) > (iPointOrderStep * Point())))
         if(OrderSend(Symbol(), OP_SELL, NormalizeDouble(SelLot, 2), NormalizeDouble(Bid, Digits()), iSlippage, 0, 0, "VR Setka Lite", iMagicNumber, 0, clrGreen) < 0)
            Print("OrderSend error #", GetLastError());
//*************************************************************//
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber() == iMagicNumber)
            if(OrderSymbol() == Symbol())
              {
               op = NormalizeDouble(OrderOpenPrice(), Digits());
               tp = NormalizeDouble(OrderTakeProfit(), Digits());
               lt = NormalizeDouble(OrderLots(), 2);
               tk = OrderTicket();

               if(OrderType() == OP_BUY && b == 1 && tp == 0)
                  if(!OrderModify(tk, op, OrderStopLoss(), NormalizeDouble(Ask + iTakeProfit * Point(), Digits()), 0, clrRed))
                     Print("OrderModify error #", GetLastError());

               if(OrderType() == OP_SELL && s == 1 && tp == 0)
                  if(!OrderModify(tk, op, OrderStopLoss(), NormalizeDouble(Bid - iTakeProfit * Point(), Digits()), 0, clrRed))
                     Print("OrderModify error #", GetLastError());

               if(iCloseOrder == Awerage)
                 {
                  if(OrderType() == OP_BUY && b >= 2)
                    {
                     if(tk == BuyPriceMaxTic || tk == BuyPriceMinTic)
                        if(Bid < AwerageBuyPrice && tp != AwerageBuyPrice)
                           if(!OrderModify(tk, op, OrderStopLoss(), AwerageBuyPrice, 0, clrRed))
                              Print("OrderModify error #", GetLastError());

                     if(tk != BuyPriceMaxTic && tk != BuyPriceMinTic && tp != 0)
                        if(!OrderModify(tk, op, 0, 0, 0, clrRed))
                           Print("OrderModify error #", GetLastError());
                    }
                  if(OrderType() == OP_SELL && s >= 2)
                    {
                     if(tk == SelPriceMaxTic || tk == SelPriceMinTic)
                        if(Ask > AwerageSelPrice && tp != AwerageSelPrice)
                           if(!OrderModify(tk, op, OrderStopLoss(), AwerageSelPrice, 0, clrRed))
                              Print("OrderModify error #", GetLastError());

                     if(tk != SelPriceMaxTic && tk != SelPriceMinTic && tp != 0)
                        if(!OrderModify(tk, op, 0, 0, 0, clrRed))
                           Print("OrderModify error #", GetLastError());
                    }
                 }

              }

   if(iCloseOrder == PartClose)
     {
      if(b >= 2)
         if(AwerageBuyPrice > 0 && Bid >= AwerageBuyPrice)
           {
            if(!OrderClose(BuyPriceMaxTic, iStartLots,Bid, iSlippage, clrRed))
               Print("OrderClose Error ", GetLastError());
            if(!OrderClose(BuyPriceMinTic, BuyPriceMinLot,Bid, iSlippage, clrRed))
               Print("OrderClose Error ", GetLastError());
           }
      if(s >= 2)
         if(AwerageSelPrice > 0 && Ask <= AwerageSelPrice)
           {
            if(!OrderClose(SelPriceMinTic, iStartLots,Ask, iSlippage, clrRed))
               Print("OrderClose Error ", GetLastError());
            if(!OrderClose(SelPriceMaxTic, SelPriceMaxLot,Bid, iSlippage, clrRed))
               Print("OrderClose Error ", GetLastError());
           }
     }
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnDeinit(const int reason)
  {

  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
bool CheckVolumeValue(double volume)
  {
//--- минимально допустимый объем для торговых операций
   double min_volume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   if(volume < min_volume)
      return(false);

//--- максимально допустимый объем для торговых операций
   double max_volume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   if(volume > max_volume)
      return(false);

//--- получим минимальную градацию объема
   double volume_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);

   int ratio = (int)MathRound(volume / volume_step);
   if(MathAbs(ratio * volume_step - volume) > 0.0000001)
      return(false);

   return(true);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
