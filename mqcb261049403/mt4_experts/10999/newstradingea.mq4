//+------------------------------------------------------------------+
//|                                 copyright "© 2013 August, HSR    |
//|                                   modified from otiginal version |
//+------------------------------------------------------------------+
#define VERSION "1.2"  //this is public version

#property version     VERSION
#property strict
//#property icon        "\\images\\not2_Uxv_icon.ico"
#property description "Copyright May 2021, Mr_Hu_Gold\n"
#property copyright   "Telegram channel Live Trading (free signal): https://t.me/Mr_Hu_Gold"
#property link        "https://t.me/Mr_Hu_Gold"
#property description "YouTube channel Live Streaming:"
#property description "https://www.youtube.com/channel/UC_P5cwG0FIL8bB_r626YkCQ\n"
#property description "EA for opening BUY and SELL STOP to capture UP or DOWN candle at specified time"
#property description "WARNING:"
#property description "wrong parameter set may have unpredictable result, use with caution!"

//--- input parameters
extern string  StartDate     = "2021.05.21"; //input start date, MUST in format YYYY.MM.DD
extern string  StartTime     = "21:21";      //input start time, MUST in format 24H:MM
extern int     StartStraddle = 0;     //Set Actual start (in minutes) after start date & time
extern int     StopStraddle  = 15;    //Set Stop (in minutes) after Actual start time
extern double  Lots          = 0.01;  //Lots to open
extern int     Distance      = 55;    //Distance PIPS from current price to open BUY & SELL STOP order
extern int     TakeProfit    = 30;    //Take Profit from Distance, 0 No TP!
extern int     StopLoss      = 30;    //Stop Loss from Distance, 0 No SL!
extern int     Expiration    = 20;    //Time (mins) after opening BUY&SELL STOP Order will be deleted
extern int     Slippage      = 3;     //Slippage
extern int     ExpertID      = 7999;  //expert ID for orders

string  ver=VERSION;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   if (StopLoss      <0)  StopLoss=0;
   if (TakeProfit    <0)  TakeProfit=0;
   if (Lots          <=0) Lots=0.01;
   if (Distance      <=0) Distance=50;
   if (StartStraddle <0)  StartStraddle=0;
   if (StopStraddle  <=0) StopStraddle=15;

   start();
   return(0);
  }

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
  
int TotalBuy=0, TotalSell=0;
int TotalBuyStop=0, TotalSellStop=0;
int TicketBuyStop=0, TicketSellStop=0;

void RefreshOrder() {

   TotalBuy=0;      TotalSell=0;
   TotalBuyStop=0;  TotalSellStop=0;
   TicketBuyStop=0; TicketSellStop=0;
   
   int i=OrdersTotal()-1;
   while(i>=0) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderMagicNumber()==ExpertID && OrderSymbol()==Symbol()) {
            switch(OrderType()) {
            case OP_BUY:
               TotalBuy++;
               break;
            case OP_SELL:
               TotalSell++;
               break;
            case OP_BUYSTOP:
               TotalBuyStop++;
               TicketBuyStop=OrderTicket();
               break;
            case OP_SELLSTOP:
               TotalSellStop++;
               TicketSellStop=OrderTicket();
               break;
            }
         }
      }
      i--;
   }  
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//   if(Period() != PERIOD_M15 ) { //this is public version
//      Comment("\nThis EA only can run on 15 minutes chart !"); return(0);
//   }

   datetime STnow=TimeCurrent();
   string   StartDateTime = StringConcatenate(StartDate," ",StartTime);
   datetime Sdatetime = StrToTime(StartDateTime); 
   
   datetime STimeStart = Sdatetime  + StartStraddle*60;
   datetime STimeStop  = STimeStart + StopStraddle *60;
//Comment("Sdatetime: "+TimeToStr(Sdatetime)+"\nStart:"+TimeToStr(STimeStart)+"\nStop:"+TimeToStr(STimeStop));

   string sn=TimeToStr(STnow,TIME_DATE|TIME_MINUTES);
   string s0=TimeToStr(Sdatetime,TIME_DATE|TIME_MINUTES);
   string s1=TimeToStr(STimeStart,TIME_DATE|TIME_MINUTES);
   string s2=TimeToStr(STimeStop,TIME_DATE|TIME_MINUTES);
   string lc=TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES);
   string lt=TimeToStr(Sdatetime,TIME_DATE|TIME_MINUTES);
   string set1=StringConcatenate("\nLots: ",Lots,"  TP: ",TakeProfit,"  SL: ",StopLoss,"  Dis: ",Distance,"  Exp: ",Expiration );
   string ltp = StringConcatenate("\nStart at Local Time: ",lt);
   string IComment = WindowExpertName();
   
   RefreshOrder();

//   if ( STimeStop<STimeStart+300 || STnow<STimeStart || STnow>STimeStop ){  // its ready & waiting
   if ( STimeStop<STimeStart || STnow<STimeStart || STnow>STimeStop ){  // its ready & waiting
      Comment("\nVersion: "+ver+"\nLocal Time: "+lc+"\nServer Time: "+sn+"\n"+ltp+"\nStart at Server on: "+s0+"\nStart  Straddle on:  "+s1+"\nStop  Straddle on:  "+s2+set1+"\n\nReady and waiting...!");
      return(0);
   }   

   double p1,p2;
   int    SL=1, TP=1, os,om,od, Exp=Expiration * 60 ; //pending order expiration time 
   
//   if( STimeStop>STimeStart+300 && STnow>STimeStart && STnow<STimeStop ) {
   if( STimeStop>STimeStart && STnow>STimeStart && STnow<STimeStop ) {
      Comment(Symbol()+"\nVersion: "+ver+"\nLocal Time: "+lc+"\nServer Time: "+sn+"\n"+ltp+"\nStart at Server on: "+s0+"\nStart  Straddle on:  "+s1+"\nStop  Straddle on:  "+s2+set1+" Pnt: "+string(Point)+"\n\nCAUTION: Ready to OPEN order!");
      static int lastbar=0;
      if(lastbar!=Bars) {
         lastbar=Bars;
         p1 = Ask + Distance * Point;  //set BUY  stop at distance from current tick
         p2 = Bid - Distance * Point;  //set SELL stop at distance from current tick
         if (StopLoss  ==0) SL=0;      //set no stop loss
         if (TakeProfit==0) TP=0;      //sey no take profit
         Print ("Try to open order BUY stop:",p1," and SELL stop:",p2);
    //this will set trailing pending order following current tick
         if(TotalBuy==0 && TotalSell==0 && TotalBuyStop==0 && TotalSellStop==0) { //if no open order set order BUY & SELL stop
            os=OrderSend(Symbol(),OP_BUYSTOP, Lots,p1,Slippage,SL*p1-StopLoss*Point,TP*p1+TakeProfit*Point,IComment,ExpertID,TimeCurrent()+Exp,DodgerBlue);
            if (os<0) Print ("order BUY stop ERROR for: ", p1);
            os=OrderSend(Symbol(),OP_SELLSTOP,Lots,p2,Slippage,SL*p2+StopLoss*Point,TP*p2-TakeProfit*Point,IComment,ExpertID,TimeCurrent()+Exp,DeepPink);
            if (os<0) Print ("order SELL stop ERROR for: ",p2);
         } else {
            if(TotalBuyStop>0 && TotalSellStop>0) { //if there is pending order then modify current pending order
               om=OrderModify(TicketBuyStop, p1,SL*p1-StopLoss*Point,TP*p1+TakeProfit*Point,TimeCurrent()+Exp);
               if (!om) Print ("order Modify BUY stop ERROR for #: ",TicketBuyStop, " ",p1);
               om=OrderModify(TicketSellStop,p2,SL*p2+StopLoss*Point,TP*p2-TakeProfit*Point,TimeCurrent()+Exp);
               if (!om) Print ("order Modify SELL stop ERROR for #: ",TicketSellStop, " ",p2);
            } 
         }
      }
      
      if(TotalBuyStop>0 && TotalSellStop==0) {  //if there is only BUY stop order, then delete it
         od=OrderDelete(TicketBuyStop);
         if (!od) Print ("order Delete BUY stop ERROR for #: ", TicketBuyStop);
      } else 
      if(TotalSellStop>0 && TotalBuyStop==0) {  //if there is only SELL stop order, then delete it
         od=OrderDelete(TicketSellStop);
         if (!od) Print ("order Delete SELL stop ERROR for #: ", TicketSellStop);
      }
      
   } else {
    
      if(TotalBuyStop>0 && TotalSellStop==0) {
         od=OrderDelete(TicketBuyStop);
         if (!od) Print ("order Delete BUY stop ERROR for #: ", TicketBuyStop);
      } else 
      if(TotalSellStop>0 && TotalBuyStop==0) {
         od=OrderDelete(TicketSellStop);
         if (!od) Print ("order Delete SELL stop ERROR for #: ", TicketSellStop);
      }
   
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+

