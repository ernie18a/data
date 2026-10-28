#property copyright "Copyright © 2010, Khlystov Vladimir"
#property link      "cmillion@narod.ru"
#property show_inputs
//--------------------------------------------------------------------
extern bool    SELL        = false,
               BUY         = false;
extern double  Lot         = 0.25;
int     slippage    = 3;
//--------------------------------------------------------------------
int start()
{
   if (BUY) 
   {
      OPENORDER ("Buy", NormalizeDouble(Bid - 70*Point,Digits),NormalizeDouble(Ask + 25*Point,Digits));
      OPENORDER ("Buy", NormalizeDouble(Bid - 70*Point,Digits),NormalizeDouble(Ask + 50*Point,Digits));
      OPENORDER ("Buy", NormalizeDouble(Bid - 70*Point,Digits),NormalizeDouble(Ask + 25*Point,Digits));
      OPENORDER ("Buy", NormalizeDouble(Bid - 70*Point,Digits),0);
   }
   if (SELL)
   {
      OPENORDER ("Sell",NormalizeDouble(Ask + 70*Point,Digits),NormalizeDouble(Bid - 25*Point,Digits));
      OPENORDER ("Sell",NormalizeDouble(Ask + 70*Point,Digits),NormalizeDouble(Bid - 50*Point,Digits));
      OPENORDER ("Sell",NormalizeDouble(Ask + 70*Point,Digits),NormalizeDouble(Bid - 25*Point,Digits));
      OPENORDER ("Sell",NormalizeDouble(Ask + 70*Point,Digits),0);
   }
return(0);
}
//--------------------------------------------------------------------
void OPENORDER(string ord,double SL,double TP)
{
   int error,err;
   while (true)
   {  error=true;
      if (ord=="Buy" ) error=OrderSend(Symbol(),OP_BUY, Lot,NormalizeDouble(Ask,Digits),slippage,SL,TP,"",0,3,Blue);
      if (ord=="Sell") error=OrderSend(Symbol(),OP_SELL,Lot,NormalizeDouble(Bid,Digits),slippage,SL,TP,"",0,3,Red);
      if (error==-1)
      {  
         ShowERROR();
         err++;Sleep(2000);RefreshRates();
      }
      if (error || err >10) return;
   }
return;
}                  
//--------------------------------------------------------------------
void ShowERROR()
{
   int err=GetLastError();
   switch ( err )
   {                  
      case 1:   return;
      default:  Alert("Error  " ,err," ",Symbol());return;
   }
}
//--------------------------------------------------------------------

