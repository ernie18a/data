//+------------------------------------------------------------------+
//|                                                    SL_to_Bar.mq4 |
//|                               Copyright © 2009, Vladimir Hlystov |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Vladimir Hlystov"
#property link      "cmillion@narod.ru"
 
#property indicator_chart_window
//+------------------------------------------------------------------+
extern int   BAR            = 200;//searching for in last BAR bar
extern int   minSL          = 25;//it is exposed when 2 bars are not found
extern bool  show_bar       = true;//show bars on which search for SL
extern bool  show_info      = true;//show order on which is not installed by SL
extern color color_BAR      = DarkSlateGray;//colour bar on which search for SL
extern color color_Тек_BAR  = Gray;//colour of the current bar
extern color color_SL       = Gray;//colour of the marks
//+------------------------------------------------------------------+
int per,Ask_Bid;
color colmet;
//+------------------------------------------------------------------+
int init()
  {
      per=Period();
      Ask_Bid = MarketInfo(Symbol(),MODE_STOPLEVEL);
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("SL-UP-bar ");
   ObjectDelete("SL-LO-bar ");
   ObjectDelete("SL-0-bar");
   ObjectDelete("SL for Sell ");
   ObjectDelete("SL for Buy ");
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   double SL_Buy =Stop_Loss( 1);
   double SL_Sell=Stop_Loss(-1);
   string info;
   Drawfoots(SL_Sell,SL_Buy);
   if (show_info)
   {
      for (int i=0; i<OrdersTotal(); i++)
      {
         if((OrderSelect(i, SELECT_BY_POS)==true) && (OrderSymbol()==Symbol()))
         { 
            if (OrderType()<2)  // Buy or Sell
            {
               if (OrderStopLoss()==0)
               {
                  info=info+"Order "+OrderTicket()+" without SL\n";
               }
            }
         }
      }
      Comment(info);
   }
   return(0);
  }
//+------------------------------------------------------------------+
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
//////////////////////////////////////////////////////////////////////
//    Stop_Loss                                                     // 
//    Returns importance SL for operation of the buying or sale     //
//                         "Copyright © 2009, Vladimir Hlystov"     //
//                                          "cmillion@narod.ru"     //
//    direction = 1 Buy           -1 Sell                           //
//                                                                  //
//////////////////////////////////////////////////////////////////////
double Stop_Loss(int direction) 
{  
   if (direction == 0) return (0);
   int i;
   int timeframe,toBar,tf; 
   double SL_toBar,
          max_toBar,
          min_toBar;
   timeframe=next_period(per+1);
   double max_0Bar = iHigh( NULL, timeframe, 0);
   double min_0Bar = iLow ( NULL, timeframe, 0);
   if ( direction ==1 ) //Buy
   {
      SL_toBar=0;
      for (toBar=1; toBar<BAR; toBar++)
      {
         max_toBar = iHigh( NULL, timeframe, toBar);
         min_toBar = iLow ( NULL, timeframe, toBar);
         if ( max_0Bar > max_toBar && min_0Bar > min_toBar)
         {
            SL_toBar = min_toBar-Point*Ask_Bid;
            if (show_bar==true){
               ObjectDelete("SL-UP-bar ");
               ObjectCreate("SL-UP-bar ", OBJ_RECTANGLE, 0, 0,0, 0,0);
               ObjectSet   ("SL-UP-bar ", OBJPROP_STYLE, STYLE_SOLID);
               ObjectSet   ("SL-UP-bar ", OBJPROP_COLOR, color_BAR);
               ObjectSet   ("SL-UP-bar ", OBJPROP_BACK, true);
               ObjectSet   ("SL-UP-bar ", OBJPROP_TIME1 , iTime( NULL, timeframe, toBar-1));
               ObjectSet   ("SL-UP-bar ", OBJPROP_PRICE1, SL_toBar);
               ObjectSet   ("SL-UP-bar ", OBJPROP_TIME2 , iTime( NULL, timeframe, toBar));
               ObjectSet   ("SL-UP-bar ", OBJPROP_PRICE2, max_toBar);}
            break;
         }
      }
      if (SL_toBar==0)//No SL
      {  tf=timeframe;
         for (i=1; i<5; i++)
         {
            tf=next_period(tf+1);
            if ((iLow(NULL,tf,0)-Point*Ask_Bid) < (Bid-Point*minSL))
            {
               SL_toBar=iLow(NULL,tf,0)-Point*Ask_Bid;
               if (show_bar==true){
                  ObjectDelete("SL-UP-bar ");
                  ObjectCreate("SL-UP-bar ", OBJ_RECTANGLE, 0, 0,0, 0,0);
                  ObjectSet   ("SL-UP-bar ", OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet   ("SL-UP-bar ", OBJPROP_COLOR, Red);
                  ObjectSet   ("SL-UP-bar ", OBJPROP_BACK, false);
                  ObjectSet   ("SL-UP-bar ", OBJPROP_TIME1 , iTime( NULL, tf, 0));
                  ObjectSet   ("SL-UP-bar ", OBJPROP_PRICE1, SL_toBar);
                  ObjectSet   ("SL-UP-bar ", OBJPROP_TIME2 , CurTime());
                  ObjectSet   ("SL-UP-bar ", OBJPROP_PRICE2, iHigh( NULL, tf, 0));}
               break;
            }
         }
      }
   }
   if ( direction ==-1 ) //Sell
   {
      SL_toBar=0;
      for (toBar=1; toBar<BAR; toBar++) 
      {
         max_toBar = iHigh( NULL, timeframe, toBar);
         min_toBar = iLow ( NULL, timeframe, toBar);
         if ( max_0Bar < max_toBar && min_0Bar < min_toBar)
         {
            SL_toBar = max_toBar+Point*Ask_Bid;
            if (show_bar==true){
               ObjectDelete("SL-LO-bar ");
               ObjectCreate("SL-LO-bar ", OBJ_RECTANGLE, 0, 0,0, 0,0);
               ObjectSet   ("SL-LO-bar ", OBJPROP_STYLE, STYLE_SOLID);
               ObjectSet   ("SL-LO-bar ", OBJPROP_COLOR, color_BAR);
               ObjectSet   ("SL-LO-bar ", OBJPROP_BACK, true);
               ObjectSet   ("SL-LO-bar ", OBJPROP_TIME1 , iTime( NULL, timeframe, toBar-1));
               ObjectSet   ("SL-LO-bar ", OBJPROP_PRICE1, min_toBar);
               ObjectSet   ("SL-LO-bar ", OBJPROP_TIME2 , iTime( NULL, timeframe, toBar));
               ObjectSet   ("SL-LO-bar ", OBJPROP_PRICE2, SL_toBar);}
            break;
         }
      }
      if (SL_toBar==0)//No SL
      {  tf=timeframe;
         for (i=1; i<5; i++)
         {
            tf=next_period(tf+1);
            if ((iHigh(NULL,tf,0)+Point*Ask_Bid) > (Ask+Point*minSL))
            {
               SL_toBar=iHigh(NULL,tf,0)+Point*Ask_Bid;
               if (show_bar==true){
                  ObjectDelete("SL-LO-bar ");
                  ObjectCreate("SL-LO-bar ", OBJ_RECTANGLE, 0, 0,0, 0,0);
                  ObjectSet   ("SL-LO-bar ", OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet   ("SL-LO-bar ", OBJPROP_COLOR, Red);
                  ObjectSet   ("SL-LO-bar ", OBJPROP_BACK, false);
                  ObjectSet   ("SL-LO-bar ", OBJPROP_TIME1 , iTime( NULL, tf, 0));
                  ObjectSet   ("SL-LO-bar ", OBJPROP_PRICE1, iLow ( NULL, tf, 0));
                  ObjectSet   ("SL-LO-bar ", OBJPROP_TIME2 , CurTime());
                  ObjectSet   ("SL-LO-bar ", OBJPROP_PRICE2, SL_toBar);}
               break;
            }
         }
      }
   }
   if (show_bar==true){
      ObjectDelete("SL-0-bar");
      ObjectCreate("SL-0-bar", OBJ_RECTANGLE, 0, 0,0, 0,0);
      ObjectSet   ("SL-0-bar", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet   ("SL-0-bar", OBJPROP_COLOR, color_Тек_BAR);
      ObjectSet   ("SL-0-bar", OBJPROP_BACK, true);
      ObjectSet   ("SL-0-bar", OBJPROP_TIME1 , iTime( NULL, timeframe, 0));
      ObjectSet   ("SL-0-bar", OBJPROP_PRICE1, min_0Bar);
      ObjectSet   ("SL-0-bar", OBJPROP_TIME2 , iTime( NULL, timeframe, 0)+timeframe*60);
      ObjectSet   ("SL-0-bar", OBJPROP_PRICE2, max_0Bar);}
   return (SL_toBar);   
}
//+------------------------------------------------------------------+
double Drawfoots(double top, double bottom)
{  
   int indention=Time[0]+per*3*60;
   if (show_bar==true)
   {
      colmet=color_SL;
      if (top==0) {top=Ask;colmet=Red;}
      ObjectDelete("SL for Sell ");
      ObjectCreate("SL for Sell ", OBJ_ARROW,0,indention,top,0,0,0,0);
      ObjectSet   ("SL for Sell ", OBJPROP_ARROWCODE,6);
      ObjectSet   ("SL for Sell ", OBJPROP_COLOR,colmet );
      ObjectSet   ("SL for Sell ", OBJPROP_BACK, true);
      colmet=color_SL;
      if (bottom ==0) {bottom =Bid;colmet=Red;}
      ObjectDelete("SL for Buy ");
      ObjectCreate("SL for Buy ", OBJ_ARROW,0,indention,bottom,0,0,0,0);
      ObjectSet   ("SL for Buy ", OBJPROP_ARROWCODE,6);
      ObjectSet   ("SL for Buy ", OBJPROP_COLOR,colmet );
      ObjectSet   ("SL for Buy ", OBJPROP_BACK, true);
   }
}
//+------------------------------------------------------------------+
int next_period(int per)
{
   if (per > 10080)  return(43200); 
   if (per > 1440)   return(10080); 
   if (per > 240)    return(1440); 
   if (per > 60)     return(240); 
   if (per > 30)     return(240);
   if (per > 15)     return(60); 
   if (per > 5)      return(30); 
   if (per > 1)      return(5);   
}
//+------------------------------------------------------------------+