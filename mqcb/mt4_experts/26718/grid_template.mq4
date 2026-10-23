//+------------------------------------------------------------------+
//|                                                Grid_Template.mq4 |
//|                             Copyright 2019, DKP Sweden,CS Robots |
//|                             https://www.mql5.com/en/users/kenpar |
//+------------------------------------------------------------------+
//This is a simple template for grid order system in which you can add
//additional functions as you like, entry signals, trailing stop and such
//A new grid is openend as soon as expiration hours exceeded and all
//pending orders deleted that was not activated.
//Grid positions is not openend by 'new bar' rule!
//Grid positions are opened at each side of price!
//Use as you like - This is just a template!!!!!
//--------------------------------------------------------------------
#property copyright   "Copyright 2019,DKP Sweden | CS Robots"
#property link        "https://www.mql5.com/en/users/kenpar"
#property version     "1.01"
#property description "Grid Template EA"
#property strict
//--External variables
extern int    MagicNumber       = 987654321;//Magic number
extern string EaComment         = "Grid_Template";//Order comment
extern double StaticLot         = 0.01;//Static lots size
extern bool   MM                = false;//Money Management
extern int    Risk              = 2;//Risk %
extern double TakeProfit        = 20.;//Take Profit in pips
extern double StopLoss          = 30.;//Stop loss in pips
extern double PriceDistance     = 15.;//Distance from price in pips
extern double GridStep          = 10.;//Step between grid orders in pips
extern int    GridOrders        = 2;//Amount of grid orders
extern int    PendingExpiration = 4;//Pending expiration after xx hours
//--Internal variables
double
PriceB,
PriceS,
StopB,
StopS,
TakeB,
TakeS,
_points,
PT,
Lots,
MPP;
datetime
_e = 0;
int
Ticket  = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   MPP=1;
   if((MarketInfo(Symbol(),MODE_DIGITS)==3)||(MarketInfo(Symbol(),MODE_DIGITS)==5))
      MPP=10;
   PT=MarketInfo(Symbol(),MODE_TICKSIZE)*MPP;
//--
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//If trade allowed and no positions exists by any chart - open a new set of grid orders
   if(IsTradeAllowed() && !IsTradeContextBusy())
     {
      if(PosSelect()==0)
         GridPos(PriceDistance,TakeProfit,StopLoss);//Place grid
     }
  }
///////////////////////////////////////////////////////////
//Grid order send function
void GridPos(double _Dist,double _Take,double _Stop)
  {
   int i;
   _e=TimeCurrent()+PendingExpiration*60*60;
//--
   for(i=0; i<GridOrders; i++)
     {
      PriceB = NormalizeDouble(Ask+(_Dist*PT)+(i*GridStep*PT),Digits);
      TakeB  = PriceB + _Take * PT;
      StopB  = PriceB - _Stop * PT;
      double
      lotcheckA=CheckVolumeValue(LotSize());
      if((CheckMoneyForTrade(Symbol(),lotcheckA,OP_BUY))&&(IsNewOrderAllowed()))
         Ticket=OrderSend(Symbol(),OP_BUYSTOP,lotcheckA,PriceB,3,StopB,TakeB,EaComment,MagicNumber,_e,Green);
      //--
      PriceS = NormalizeDouble(Bid-(_Dist*PT)-(i*GridStep*PT),Digits);
      TakeS  = PriceS - _Take * PT;
      StopS  = PriceS + _Stop * PT;
      double
      lotcheckB=CheckVolumeValue(LotSize());
      if((CheckMoneyForTrade(Symbol(),lotcheckB,OP_SELL))&&(IsNewOrderAllowed()))
         Ticket=OrderSend(Symbol(),OP_SELLSTOP,lotcheckB,PriceS,3,StopS,TakeS,EaComment,MagicNumber,_e,Red);
     }
   if(Ticket<1)
     {
      Print("Order send error - errcode: ",GetLastError());
      return;
     }
   else
      Print("Grid placed successfully!");
  }
//////////////////////////////////////////////////////////
//PositionSelector - Determines open positions
int PosSelect()
  {
//---
   int poss=0;
   for(int k = OrdersTotal() - 1; k >= 0; k--)
     {
      if(!OrderSelect(k, SELECT_BY_POS))
         break;
      if(OrderSymbol()!=Symbol() && OrderMagicNumber()!=MagicNumber)
         continue;
      if((OrderCloseTime() == 0) && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType() == OP_BUY||OrderType() == OP_SELL)
            poss = 1;
         if(!(OrderType() == OP_BUY||OrderType() == OP_SELL))
            poss = 1;
        }
     }
   return(poss);
  }
////////////////////////////////////////////////////////////
//Lots size calculation
double LotSize()
  {
   if(MM == true)
     {
      Lots = MathMin(MathMax((MathRound((AccountFreeMargin()*Risk/1000/100)
                                        /MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),
                             MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
     }
   else
     {
      Lots = MathMin(MathMax((MathRound(StaticLot/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),
                             MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
     }

   return(Lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewOrderAllowed()
  {

   int max_allowed_orders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

   if(max_allowed_orders == 0)
      return true;

   int orders = OrdersTotal();

   return orders < max_allowed_orders;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckVolumeValue(double checkedvol)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(checkedvol<min_volume)
      return(min_volume);

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(checkedvol>max_volume)
      return(max_volume);

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(checkedvol/volume_step);
   if(MathAbs(ratio*volume_step-checkedvol)>0.0000001)
      return(ratio*volume_step);
   return(checkedvol);
  }
//+----------------End of Grid Template EA-------------------+
