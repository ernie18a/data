//+------------------------------------------------------------------+
//|                                                 TimeToEndBar.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"

extern bool   show_Bclk=true;
int   TimeFrame   =0 ;

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
      ObjectsDeleteAll();
 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   // int    counted_bars=IndicatorCounted();
//----
    double i,i1,i2,i3,i4,i5,i6,i7;
   int m,s,k,
   m0, m1,m2,m3,m4,m5,m6,m7,
   s0, s1,s2,s3,s4,s5,s6,s7,
   h,h1,h2,h3,h4,h5,h6,h7;
   if (TimeFrame ==0)TimeFrame=Period();
   m=iTime(NULL,TimeFrame,0)+TimeFrame*60 - TimeCurrent();
   //  m=Time[0]+Period()*60-CurTime();
   m1=iTime(NULL,1440,0)+1440*60-CurTime();
   m2=iTime(NULL,240,0)+240*60-CurTime();
   m3=iTime(NULL,60,0)+60*60-CurTime();
   m4=iTime(NULL,30,0)+30*60-CurTime();
   m5=iTime(NULL,15,0)+15*60-CurTime();
   m6=iTime(NULL,5,0)+5*60-CurTime();
   m7=iTime(NULL,1,0)+1*60-CurTime();
//----
   i=m/60.0;
   i1=m1/60.0;
   i2=m2/60.0;
   i3=m3/60.0;
   i4=m4/60.0;
   i5=m5/60.0;
   i6=m6/60.0;
   i7=m7/60.0;
//----
   s=m%60;
   s0=m%60;
   s1=m1%60;
   s2=m2%60;
   s3=m3%60;
   s4=m4%60;
   s5=m5%60;
   s6=m6%60;
   s7=m7%60;
//----
   m=(m-m%60)/60;
   m0=(m-m%60)/60;
   m1=(m1-m1%60)/60;
   m2=(m2-m2%60)/60;
   m3=(m3-m3%60)/60;
   m4=(m4-m4%60)/60;
   m5=(m5-m5%60)/60;
   m6=(m6-m6%60)/60;
   m7=(m7-m7%60)/60;
//----
   h=m/60;
   h1=m1/60;
   h2=m2/60;
   h3=m3/60;
   h4=m4/60;
   h5=m5/60;
   h6=m6/60;
   h7=m7/60;
//----
   string Bclk=   "                   <"+m+":"+s;
   string M1=  "[M1] "+m7+"m :"+s7;
   string M5=  "[M5] "+m6+"m :"+s6;
   string M15= "[M15] "+m5+"m :"+s5;
   string M30= "[M30] "+m4+"m :"+s4;
   string M60= "[M60] "+m3+"m :"+s3;
   string M240= "[H4] "+m2+"m :"+s2;
   string M1440= "[D1] "+m1+"m :"+s1;
//----

  // if(show_Bclk )
   //  {
     //Comment( m + " minut/y " + s + " sekund/y do koсca њwieczki");}
   ObjectDelete("time");
   if(ObjectFind("time")!=0)
     {
        if(show_Bclk )
        {
        ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0]+ 0.0000);WindowRedraw();}
        if(show_Bclk )
        {
        ObjectSetText("time",StringSubstr((Bclk),0), 9, "Tahoma" ,Lime);WindowRedraw();}
      //ObjectDelete("time");
     }
   else
     {
      ObjectMove("time", 0, Time[0], Close[0]+0.0005);
      //ObjectDelete("time");
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+