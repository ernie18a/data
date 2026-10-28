//+------------------------------------------------------------------+
//|                                        EA Basic_Trailingstop.mq4 |
//|                             Copyright 2019, DKP Sweden,CS Robots |
//|                             https://www.mql5.com/en/users/kenpar |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2019, DKP Sweden,CS Robots"
#property description "Expert adviser with trailing stop"
#property link        "https://www.mql5.com/en/users/kenpar"
#property version     "1.01"
#property strict
//////////////////////////////////////////////////////////////////////
//Fully functional expert adviser with Buy/Sell and trailing stop.
//Should not be used for trading as there are no enty rules or
//anything else.
//Basic template, do what ever you want with it. Have fun ;)
//////////////////////////////////////////////////////////////////////
//Update information
//v1.01 - Upgraded order send module
//////////////////////////////////////////////////////////////////////
//--Enum
enum OT {_buy,_sell,};
//--Externals
extern int    MagicNumber  = 1234567;
input OT      Ordertype    = _buy;
extern double TakeProfit   = 50.0;//Take profit in pips
extern double StopLoss     = 50.0;//Stop loss in pips
extern double TrailingStop = 15.0;//Trailing stop in pips
//--Internals
int    Ticket = 0;
double _stoploss,_takeprofit,_point,stops,Contract=0.0;
color col;
string _type="";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---Set digits
   if((Digits==5)||(Digits==3))
      _point=Point*10;
   else
      _point=Point;
   stops=MarketInfo(Symbol(),MODE_STOPLEVEL)*_point;
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
//---
   if(Position()==0)//If no open orders on current chart continue
      SendOrder(StopLoss,TakeProfit);//send Buy or Sell
   Trailing(TrailingStop);
  }
//--
void SendOrder(double _stop,double _take)
  {
   switch(Ordertype)
     {
      case _buy: //Buy order
         col = Green;
         _type="BUY";
         _stoploss    = Bid - sc(_stop) * _point;
         _takeprofit  = Ask + sc(_take) * _point;
         Contract=CheckVolumeValue(0.01);
         if(CheckMoneyForTrade(Symbol(),OP_BUY,Contract))
            Ticket=OrderSend(Symbol(),OP_BUY,Contract,Ask,5,_stoploss,_takeprofit,WindowExpertName(),MagicNumber,0,col);
         break;
      case _sell://Sell order
         col = Red;
         _type="SELL";
         _stoploss   = Ask + sc(_stop) * _point;
         _takeprofit = Bid - sc(_take) * _point;
         Contract=CheckVolumeValue(0.01);
         if(CheckMoneyForTrade(Symbol(),OP_SELL,Contract))
            Ticket=OrderSend(Symbol(),OP_SELL,Contract,Bid,5,_stoploss,_takeprofit,WindowExpertName(),MagicNumber,0,col);
         break;
     }
   if(Ticket<0)
     {
      Print("Order send failed, OrderType : ",(string)_type,", errcode : ",GetLastError());
      return;
     }
  }
//--
int Position()
  {
   int dir=0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS))
         break;
      if(OrderSymbol()!=Symbol()&&OrderMagicNumber()!= MagicNumber)
         continue;
      if(OrderCloseTime() == 0 && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType() == OP_SELL)
            dir = -1; //Short positon
         if(OrderType() == OP_BUY)
            dir = 1; //Long positon
        }
     }
   return(dir);
  }
//--
void Trailing(double _tstop)
  {
   double  ND;
//--
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         break;
      if(OrderSymbol()!=Symbol() && OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType()==OP_BUY)
           {
            if(_tstop>0)
              {
               if((Bid-OrderOpenPrice())>_tstop*_point)
                 {
                  if(((Bid-_tstop*_point)-OrderStopLoss())>_point)
                    {
                     ND=NormalizeDouble(Bid-_tstop*_point,Digits);
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),ND,OrderTakeProfit(),0,Yellow))
                       {
                        Print("Order modify error - code : ",GetLastError());
                       }
                    }
                 }
              }
           }
         if(OrderType()==OP_SELL)
           {
            if(_tstop>0)
              {
               if((OrderOpenPrice()-Ask)>_tstop*_point)
                 {
                  if((OrderStopLoss()-(Ask+_tstop*_point))>_point)
                    {
                     ND=NormalizeDouble(Ask+_tstop*_point,Digits);
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),ND,OrderTakeProfit(),0,DarkOrange))
                       {
                        Print("Order modify error - code : ",GetLastError());
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double sc(double _param)
  {
   if(_param < stops)
      _param=stops;
   return(_param);
  }
//--Money check
bool CheckMoneyForTrade(string symb,int type,double lots)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ",oper," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
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
//+------------------------------------------------------------------+
