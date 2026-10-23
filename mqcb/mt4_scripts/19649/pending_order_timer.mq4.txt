//+------------------------------------------------------------------+
#property copyright "Copyright 2019, DOKTORCAK"
#property link      "mehmetcak@yandex.com"
#property version   "1.00"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
enum t
  {
   L=0,     //buy
   S=1,     //sell
  };
input t        O                    = L;      //Order Type
extern double price1=0;//Minumum Price (0 = Market Price at StartTime)
extern double price2=0;//Maximum Price
extern double  Lot                  = 0.1;    //Lot
extern int     Stoploss             = 0,      //Stoploss 
               Takeprofit           = 0;     //Takeprofit (0 = Disable)
extern int     TrailingStop         = 20;     //TrailingStop (0 = Disable)
extern int     TrailingStart        = 0;      //TrailingStopStart
extern int     TrailingStep         = 10;      //TrailingStep
extern string  TimeStart            = "03:00"; 
extern string  TimeEnd              = "23:00";
extern int     Magic                = 1923;      //Magic Number
int     slippage=30;
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!IsExpertEnabled()) {Comment("Enable Auto Trading and launch the script again");return;}
   double STOPLEVEL,OSL,OTP,StLo,OOP,SL,TP;
   int n=0,OT;
   string txt=StringConcatenate("\nStoploss = ",Stoploss,"\n",
                                "Takeprofit = ",Takeprofit,"\n",
                                "TrailingStop = ",TrailingStop,"\n",
                                "TrailingStart = ",TrailingStart,"\n",
                                "TrailingStep = ",TrailingStep,"\n",
                                "\nPending Lot = ",Lot," price from ",price1," to ",price2,"\n");
   while(!IsStopped())
     {
      RefreshRates();
      STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
      n=0;
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
              {
               OT=OrderType();
               OSL = NormalizeDouble(OrderStopLoss(),Digits);
               OTP = NormalizeDouble(OrderTakeProfit(),Digits);
               OOP = NormalizeDouble(OrderOpenPrice(),Digits);
               SL=OSL;TP=OTP;
               if(OT==OP_BUY)
                 {
                  if(Stoploss!=0   && Bid<=OOP - Stoploss   * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage,clrNONE)) continue;}
                  if(Takeprofit!=0 && Bid>=OOP + Takeprofit * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage,clrNONE)) continue;}
                  n++;
                  if(OSL==0 && Stoploss>=STOPLEVEL && Stoploss!=0)
                    {
                     SL=NormalizeDouble(OOP-Stoploss  *Point,Digits);
                    }
                  if(OTP==0 && Takeprofit>=STOPLEVEL && Takeprofit!=0)
                    {
                     TP=NormalizeDouble(OOP+Takeprofit*Point,Digits);
                    }
                  if(TrailingStop>=STOPLEVEL && TrailingStop!=0 && (Bid-OOP)/Point>=TrailingStart)
                    {
                     StLo=NormalizeDouble(Bid-TrailingStop*Point,Digits);
                     if(StLo>=OOP && StLo>OSL+TrailingStep*Point) SL=StLo;
                    }
                  if(SL!=OSL || TP!=OTP)
                    {
                     if(!OrderModify(OrderTicket(),OOP,SL,TP,0,clrNONE)) Print("Error OrderModify <<",GetLastError(),">> ");
                    }
                 }
               if(OT==OP_SELL)
                 {
                  if(Stoploss!=0   && Ask>=OOP + Stoploss   * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage,clrNONE)) continue;}
                  if(Takeprofit!=0 && Ask<=OOP - Takeprofit * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage,clrNONE)) continue;}
                  n++;
                  if(OSL==0 && Stoploss>=STOPLEVEL && Stoploss!=0)
                    {
                     SL=NormalizeDouble(OOP+Stoploss  *Point,Digits);
                    }
                  if(OTP==0 && Takeprofit>=STOPLEVEL && Takeprofit!=0)
                    {
                     TP=NormalizeDouble(OOP-Takeprofit*Point,Digits);
                    }
                  if(TrailingStop>=STOPLEVEL && TrailingStop!=0 && (OOP-Ask)/Point>=TrailingStart)
                    {
                     StLo=NormalizeDouble(Ask+TrailingStop*Point,Digits);
                     if(StLo<=OOP && (StLo<OSL-TrailingStep*Point || OSL==0)) SL=StLo;
                    }
                  if(SL!=OSL || TP!=OTP)
                    {
                     if(!OrderModify(OrderTicket(),OOP,SL,TP,0,clrNONE)) Print("Error OrderModify <<",GetLastError(),">> ");
                    }
                 }
              }
           }
        }
      if(Lot!=0)
        {
         if(O==0) Comment("\nThe script  ",WindowExpertName(),"\n\nCurrent Time ",TimeToStr(TimeCurrent(),TIME_SECONDS),txt,"Buy Time from ",TimeStart," to ",TimeEnd);
         if(O==1) Comment("\nThe script  ",WindowExpertName(),"\n\nCurrent Time ",TimeToStr(TimeCurrent(),TIME_SECONDS),txt,"Sell Time from ",TimeStart," to ",TimeEnd);
        }
      else Comment("\nThe script  ",WindowExpertName(),"\n\nCurrent Time ",TimeToStr(TimeCurrent(),TIME_SECONDS),txt,"\nManages ",n," Orders.\n");

      if(Lot==0 && n==0) {Comment("\nThe script  ",WindowExpertName()," has finished operations ",TimeToStr(TimeCurrent(),TIME_SECONDS));return;}

      if(TimeCurrent()>=StrToTime(TimeStart) && TimeCurrent()<=StrToTime(TimeEnd))
        {
         if(O==0 && ((Ask>=price1 && Ask<=price2) || price1==0)) 
            if(OrderSend(Symbol(),OP_BUY,Lot,NormalizeDouble(Ask,Digits),slippage,0,0,NULL,Magic,0,CLR_NONE)!=-1) Lot=0;
         if(O==1 && ((Bid>=price1 && Bid<=price2) || price1==0)) 
            if(OrderSend(Symbol(),OP_SELL,Lot,NormalizeDouble(Bid,Digits),slippage,0,0,NULL,Magic,0,CLR_NONE)!=-1) Lot=0;
        }
     }
  }
//+------------------------------------------------------------------+

