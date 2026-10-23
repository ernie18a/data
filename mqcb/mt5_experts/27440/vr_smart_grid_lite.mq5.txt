//************************************************************************************************/
//*                              VR Smart Grid Lite for mt5.mq5                                  */
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
#include <Trade\PositionInfo.mqh> CPositionInfo     m_position;
#include <Trade\Trade.mqh> CTrade trade;
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
   trade.LogLevel(LOG_LEVEL_ERRORS);
   trade.SetExpertMagicNumber(iMagicNumber);
   trade.SetDeviationInPoints(iSlippage);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(Symbol());

   return(INIT_SUCCEEDED);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnTick()
  {
   double
   BuyPriceMax=0,BuyPriceMin=0,BuyPriceMaxLot=0,BuyPriceMinLot=0,
   SelPriceMin=0,SelPriceMax=0,SelPriceMinLot=0,SelPriceMaxLot=0;

   ulong
   BuyPriceMaxTic=0,BuyPriceMinTic=0,SelPriceMaxTic=0,SelPriceMinTic=0;

   double
   op=0,lt=0,tp=0;

   ulong    tk=0;
   int b=0,s=0;

   int total=PositionsTotal();
   for(int k=total-1; k>=0; k--)
      if(m_position.SelectByIndex(k))
         if(m_position.Symbol()==Symbol())
            if(m_position.Magic()==iMagicNumber)
               if(m_position.PositionType()==POSITION_TYPE_BUY || m_position.PositionType()==POSITION_TYPE_SELL)
                 {

                  op=NormalizeDouble(m_position.PriceOpen(),Digits());
                  lt=NormalizeDouble(m_position.Volume(),2);
                  tk=m_position.Ticket();

                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     b++;
                     if(op>BuyPriceMax || BuyPriceMax==0)
                       {
                        BuyPriceMax    = op;
                        BuyPriceMaxLot = lt;
                        BuyPriceMaxTic = tk;
                       }
                     if(op<BuyPriceMin || BuyPriceMin==0)
                       {
                        BuyPriceMin    = op;
                        BuyPriceMinLot = lt;
                        BuyPriceMinTic = tk;
                       }
                    }
                  // ===
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     s++;
                     if(op>SelPriceMax || SelPriceMax==0)
                       {
                        SelPriceMax    = op;
                        SelPriceMaxLot = lt;
                        SelPriceMaxTic = tk;
                       }
                     if(op<SelPriceMin || SelPriceMin==0)
                       {
                        SelPriceMin    = op;
                        SelPriceMinLot = lt;
                        SelPriceMinTic = tk;
                       }
                    }
                 }
//*************************************************************//
   double   AwerageBuyPrice=0,AwerageSelPrice=0;

   if(iCloseOrder == Awerage)
     {
      if(b>=2)
         AwerageBuyPrice=NormalizeDouble((BuyPriceMax*BuyPriceMaxLot+BuyPriceMin*BuyPriceMinLot)/(BuyPriceMaxLot+BuyPriceMinLot)+iMinimalProfit*Point(),Digits());
      if(s>=2)
         AwerageSelPrice=NormalizeDouble((SelPriceMax*SelPriceMaxLot+SelPriceMin*SelPriceMinLot)/(SelPriceMaxLot+SelPriceMinLot)-iMinimalProfit*Point(),Digits());
     }
   if(iCloseOrder == PartClose)
     {
      if(b >= 2)
         AwerageBuyPrice = NormalizeDouble((BuyPriceMax * iStartLots + BuyPriceMin * BuyPriceMinLot) / (iStartLots + BuyPriceMinLot) + iMinimalProfit * Point(), Digits());
      if(s >= 2)
         AwerageSelPrice = NormalizeDouble((SelPriceMax * SelPriceMaxLot + SelPriceMin * iStartLots) / (SelPriceMaxLot + iStartLots) - iMinimalProfit * Point(), Digits());
     }
//*************************************************************//
   double BuyLot=0,SelLot=0;
   if(BuyPriceMinLot==0)
      BuyLot=iStartLots;
   else
      BuyLot=BuyPriceMinLot*2;
   if(SelPriceMaxLot==0)
      SelLot=iStartLots;
   else
      SelLot=SelPriceMaxLot*2;
//*************************************************************//
   if(iMaximalLots >0)
     {
      if(BuyLot>iMaximalLots)
         BuyLot=iMaximalLots;
      if(SelLot>iMaximalLots)
         SelLot=iMaximalLots;
     }
   if(!CheckVolumeValue(BuyLot) || !CheckVolumeValue(SelLot))
      return;
//*************************************************************//
   MqlRates rates[];
   CopyRates(Symbol(),PERIOD_CURRENT,0,2,rates);

   MqlTick tick;
   if(!SymbolInfoTick(Symbol(),tick))
      Print("SymbolInfoTick() failed, error = ",GetLastError());

   if(rates[1].close>rates[1].open)

      if((b==0) || (b>0 && (BuyPriceMin-tick.ask)>(iPointOrderStep*Point())))
         if(!trade.Buy(NormalizeDouble(BuyLot,2)))
            Print("OrderSend error #",GetLastError());

   if(rates[1].close<rates[1].open)
      if((s==0) || (s>0 && (tick.bid-SelPriceMax)>(iPointOrderStep*Point())))
         if(!trade.Sell(NormalizeDouble(SelLot,2)))
            Print("OrderSend error #",GetLastError());
//*************************************************************//

   for(int k=total-1; k>=0; k--)
      if(m_position.SelectByIndex(k))
         if(m_position.Symbol()==Symbol())
            if(m_position.Magic()==iMagicNumber)
               if(m_position.PositionType()==POSITION_TYPE_BUY || m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  op=NormalizeDouble(m_position.PriceOpen(),Digits());
                  tp=NormalizeDouble(m_position.TakeProfit(),Digits());
                  lt=NormalizeDouble(m_position.Volume(),2);
                  tk=m_position.Ticket();

                  if(m_position.PositionType()==POSITION_TYPE_BUY && b==1 && tp==0)
                     if(!trade.PositionModify(tk,m_position.StopLoss(),NormalizeDouble(tick.ask+iTakeProfit*Point(),Digits())))
                        Print("OrderModify error #",GetLastError());

                  if(m_position.PositionType()==POSITION_TYPE_SELL && s==1 && tp==0)
                     if(!trade.PositionModify(tk,m_position.StopLoss(),NormalizeDouble(tick.bid-iTakeProfit*Point(),Digits())))
                        Print("OrderModify error #",GetLastError());
                  if(iCloseOrder == Awerage)
                    {
                     if(m_position.PositionType()==POSITION_TYPE_BUY && b>=2)
                       {
                        if(tk==BuyPriceMaxTic || tk==BuyPriceMinTic)
                           if(tick.bid<AwerageBuyPrice && tp!=AwerageBuyPrice)
                              if(!trade.PositionModify(tk,m_position.StopLoss(),AwerageBuyPrice))
                                 Print("OrderModify error #",GetLastError());

                        if(tk!=BuyPriceMaxTic && tk!=BuyPriceMinTic && tp!=0)
                           if(!trade.PositionModify(tk,0,0))
                              Print("OrderModify error #",GetLastError());
                       }
                     if(m_position.PositionType()==POSITION_TYPE_SELL && s>=2)
                       {
                        if(tk==SelPriceMaxTic || tk==SelPriceMinTic)
                           if(tick.ask>AwerageSelPrice && tp!=AwerageSelPrice)
                              if(!trade.PositionModify(tk,m_position.StopLoss(),AwerageSelPrice))
                                 Print("OrderModify error #",GetLastError());

                        if(tk!=SelPriceMaxTic && tk!=SelPriceMinTic && tp!=0)
                           if(!trade.PositionModify(tk,0,0))
                              Print("OrderModify error #",GetLastError());
                       }
                    }
                 }
   if(iCloseOrder == PartClose)
     {
      if(b >= 2)
         if(AwerageBuyPrice > 0 && tick.bid >= AwerageBuyPrice)
           {

            if(!trade.PositionClosePartial(BuyPriceMaxTic,iStartLots,iSlippage))
               Print("OrderClose Error ", GetLastError());
            if(!trade.PositionClose(BuyPriceMinTic,iSlippage))
               Print("OrderClose Error ", GetLastError());
           }
      if(s >= 2)
         if(AwerageSelPrice > 0 && tick.ask <= AwerageSelPrice)
           {
            if(!trade.PositionClosePartial(SelPriceMinTic,iStartLots,iSlippage))
               Print("OrderClose Error ", GetLastError());
            if(!trade.PositionClose(SelPriceMaxTic,iSlippage))
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
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
      return(false);

//--- максимально допустимый объем для торговых операций
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
      return(false);

//--- получим минимальную градацию объема
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
      return(false);

   return(true);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/