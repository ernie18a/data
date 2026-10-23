//+------------------------------------------------------------------+
//|                           Expert_Licence_Protection_Template.mq4 |
//|                             Copyright 2019, DKP Sweden,CS Robots |
//|                             https://www.mql5.com/en/users/kenpar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, DKP Sweden,CS Robots"
#property link      "https://www.mql5.com/en/users/kenpar"
#property version   "1.00"
#property strict
//////////////////////////////////////////////////////////////////////
//This is a template and you use it as you like, modify it,use
//parts of it in your own code and so on......
//Main purpose is to show how to implement different licence restrictions
//Adviser only execute trades in strategy tester mode
//////////////////////////////////////////////////////////////////////
//--Adviser test order
double Lot   = 0.01;
int    _take = 200;
int    _stop = 200;
//--
int Ticket=0;
double _lots;
bool _run=true;
//--
///////////////Licence protection settings (internal)/////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////
//////////////////////////////////
datetime ValidTo = D'31.12.2020';//What date to deactivate expert adviser
int      Acc     = 123456;       //Account number restriction to use in real account mode
//////////////////////////////////
bool DateRestriction=false;////////Use Date expiration(both real and demo mode)
//////////////////////////////////
bool DemoRestriction=false;////////Use Demo account restriction(Do not use with RealAccRestriction)
//////////////////////////////////
bool RealAccRestriction=false;/////Use Real Account restrictions(Do not use with DemoRestriction)
//////////////////////////////////
// Important::::You can not use Demo restriction and real account restriction at the same time with these licentypes!
// The main thing here is to limit the adviser to either work only on unlimited accounts in 'DEMO' mode when used
// and when real account restriction set to be in use it's limited to only work with one real account number on
// real accounts plus unlimited demo account numbers if demo accounts used.
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---Work only on demo account
   if(!IsDemo()&&DemoRestriction)//Is Demo restriction in use?If yes do demo check else skip and continue
     {
      Alert("Account not demo!");//Alert user that account is not demo!
      ExpertRemove();//Remove adviser from chart
      return(INIT_FAILED);//Initiation failed due to wrong account type
     }
//--Only certain account number work on real accounts
   if(RealAccRestriction)//Is Real account number restriction in use?If yes and trading mode do check, else skip and continue
     {
      if(!IsDemo()&& AccountNumber()!=Acc)//Is account real? If yes, do check and see if account number match or not
        {
         Alert("Real account number do not match!");//Alert user if account number don't match
         ExpertRemove();//Remove adviser from chart
         return(INIT_FAILED);//Initiation failed due to wrong account number
        }
     }
//--Adviser will stop working in trading mode when reaching set date
   if(!IsTesting()&& DateRestriction)//Is Date restriction in use and trading mode, if yes do check else skip and continue
     {
      if(TimeCurrent()>ValidTo)//Has current date exceeded set date?If yes continue do alert, else skip and continue
        {
         Alert("Licence Expired");//Alert user if date exceeded
         ExpertRemove();//Remove adviser from chart
         return(INIT_FAILED);//Initiation failed due to exceeded date
        }
     }
//---
   if(!IsTesting())
      _run=false;
//---If checks done and ok then continue this last step
   return(INIT_SUCCEEDED);//Return successful initiation, continue using the adviser
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
//---Run test order?
   if(_run&&CheckPos()==0)
      TestOrder(LotSize(),_take,_stop);
   return;
  }
//--Test order function
void TestOrder(double _vol, int _t, int _s)
  {
   if(CheckMoneyForTrade(Symbol(),OP_BUY,_vol))
      Ticket=OrderSend(Symbol(),OP_BUY,_vol,Ask,3,Bid -_s * Point,Ask+ _t * Point,"Test",12345,0,Green);
   if(Ticket<1)
      Print("OrderSend error : ",GetLastError());
   return;
  }
//--Check trades?
int CheckPos()
  {
   int check=0;
   for(int y = OrdersTotal() - 1; y >= 0; y--)
     {
      if(!OrderSelect(y, SELECT_BY_POS))
         break;
      if(OrderSymbol()!=Symbol()&&OrderMagicNumber()!=12345)
        {
         continue;
        }
      if(OrderCloseTime() == 0 && OrderSymbol()==Symbol() && OrderMagicNumber()==12345)
        {
         if(OrderType() == OP_BUY)
            check = 1;
         if(OrderType() == OP_SELL)
            check = -1;
        }
     }
   return(check);
  }
//--Lot size calc
double LotSize()
  {

   _lots = MathMin(MathMax((MathRound(Lot/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),
                           MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
   return(_lots);
  }
//--Money enough to execute a trade?
bool CheckMoneyForTrade(string symb,int type,double lots)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ",oper," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
   return(true);
  }
//+----------------------------END OF CODE--------------------------------------+
