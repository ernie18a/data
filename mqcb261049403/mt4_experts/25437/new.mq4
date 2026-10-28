//------------------------------------------------------------------------------------------
// Copyright © 2019, fktika@gmail.com
// ------------------------------------------------------------------------------------------------ 
#property copyright "Copyright © 2019, fktika@gmail.com"
#property link "fktika@gmail.com"
#property version "1.00"
#property strict

extern int     TP                      = 10;
extern int     SL                      = 10;
extern double  Lots                    = 0.1;
extern int     Magic                   = 69;
extern int                NumberOfTrades=10;
extern int distance=10;
double slb,tpb,sls,tps,pt;
int res,wt,wk,tiket,ticet;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if(Digits==3 || Digits==5) pt=10*Point;   else   pt=Point;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  { 
     //--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(Lots<min_volume)
     {
    string  description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(Lots>max_volume)
     {
    string  description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
      
   for(int i=1;i<=NumberOfTrades;i++)
   {
   
      if(totalorder(4)==i-1){res=OrderSend(Symbol(), OP_BUYSTOP,Lots*i , Ask+distance*i*10*Point, 3, Ask+distance*i*10*Point-SL*10*Point,Ask+distance*i*10*Point+TP*10*Point, "", Magic, TimeCurrent()+24*60*60, Blue);}
  
      if(totalorder(5)==i-1){res=OrderSend(Symbol(), OP_SELLSTOP,Lots*i , Bid-distance*i*10*Point, 3, Bid-distance*i*10*Point+SL*10*Point,Bid-distance*i*10*Point-TP*10*Point, "", Magic, TimeCurrent()+24*60*60, Red);}
        
}
   return(0);
  }
//+------------------------------------------------------------------+

int totalorder( int tipe)
{
int total=0;
for( int i=0; i<OrdersTotal(); i++)
  {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic || OrderType()!=tipe) continue;
     total++;
  }

return(total);
}


