//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "sanderz"
#property link      "https://login.mql5.com/ru/users/sanderz/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
//---
input string sect1   = "";    // SUPERTREND PARAMETERS
input int    PeriodST=10;     // Supertrend period
input double Multiplier=3;    // Supertrend multiplier
//---
input string sect2   = "";    // TIMEFRAME PARAMETERS
input bool swTF1=false;       // Use TF 1 min
input bool swTF2=false;       // Use TF 2 min 
input bool swTF3=false;       // Use TF 3 min
input bool swTF4=false;       // Use TF 4 min
input bool swTF5=false;       // Use TF 5 min
input bool swTF6=false;       // Use TF 6 min
input bool swTF10=false;      // Use TF 10 min
input bool swTF12=false;      // Use TF 12 min
input bool swTF15=true;       // Use TF 15 min
input bool swTF20=true;       // Use TF 20 min
input bool swTF30=true;       // Use TF 30 min
input bool swTFH1=true;       // Use TF 1 h
input bool swTFH2=false;      // Use TF 2 h
input bool swTFH3=false;      // Use TF 3 h
input bool swTFH4=false;      // Use TF 4 h
input bool swTFH6=false;      // Use TF 6 h
input bool swTFH8=false;      // Use TF 8 h
input bool swTFH12=false;     // Use TF 12 h
input bool swTFD=false;       // Use TF D
input bool swTFW=false;       // Use TF W
input bool swTFM=false;       // Use TF M
//---
input string sect3   = "";    // DESIGN PARAMETERS
input int  sizeFont=8;        // Text size
input int  sizeP=1;           // Price mark size

int handleSTr1=INVALID_HANDLE,handleSTr2=INVALID_HANDLE,handleSTr3=INVALID_HANDLE,handleSTr4=INVALID_HANDLE,
handleSTr5=INVALID_HANDLE,handleSTr6=INVALID_HANDLE,handleSTr10=INVALID_HANDLE,handleSTr12=INVALID_HANDLE,
handleSTr15=INVALID_HANDLE,handleSTr20=INVALID_HANDLE,handleSTr30=INVALID_HANDLE,handleSTrH1=INVALID_HANDLE,
handleSTrH2=INVALID_HANDLE,handleSTrH3=INVALID_HANDLE,handleSTrH4=INVALID_HANDLE,handleSTrH6=INVALID_HANDLE,
handleSTrH8=INVALID_HANDLE,handleSTrH12=INVALID_HANDLE,handleSTrD=INVALID_HANDLE,handleSTrW=INVALID_HANDLE,
handleSTrM=INVALID_HANDLE;

double SuperTr1[],SuperTr2[],SuperTr3[],SuperTr4[],SuperTr5[],SuperTr6[],SuperTr10[],SuperTr12[],
SuperTr15[],SuperTr20[],SuperTr30[],SuperTrH1[],SuperTrH2[],SuperTrH3[],SuperTrH4[],SuperTrH6[],
SuperTrH8[],SuperTrH12[],SuperTrD[],SuperTrW[],SuperTrM[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- 
   handleSTr1=iCustom(_Symbol,PERIOD_M1,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr1==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTr2=iCustom(_Symbol,PERIOD_M2,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr2==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTr3=iCustom(_Symbol,PERIOD_M3,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr3==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTr4=iCustom(_Symbol,PERIOD_M4,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr4==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTr5=iCustom(_Symbol,PERIOD_M5,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr5==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTr6=iCustom(_Symbol,PERIOD_M6,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr6==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTr10=iCustom(_Symbol,PERIOD_M10,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr10==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTr12=iCustom(_Symbol,PERIOD_M12,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr12==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTr15=iCustom(_Symbol,PERIOD_M15,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr15==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTr20=iCustom(_Symbol,PERIOD_M20,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr20==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTr30=iCustom(_Symbol,PERIOD_M30,"SuperTrend",PeriodST,Multiplier);
   if(handleSTr30==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTrH1=iCustom(_Symbol,PERIOD_H1,"SuperTrend",PeriodST,Multiplier);
   if(handleSTrH1==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTrH2=iCustom(_Symbol,PERIOD_H2,"SuperTrend",PeriodST,Multiplier);
   if(handleSTrH2==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTrH3=iCustom(_Symbol,PERIOD_H3,"SuperTrend",PeriodST,Multiplier);
   if(handleSTrH3==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTrH4=iCustom(_Symbol,PERIOD_H4,"SuperTrend",PeriodST,Multiplier);
   if(handleSTrH4==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTrH6=iCustom(_Symbol,PERIOD_H6,"SuperTrend",PeriodST,Multiplier);
   if(handleSTrH6==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTrH8=iCustom(_Symbol,PERIOD_H8,"SuperTrend",PeriodST,Multiplier);
   if(handleSTrH8==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTrH12=iCustom(_Symbol,PERIOD_H12,"SuperTrend",PeriodST,Multiplier);
   if(handleSTrH12==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTrD=iCustom(_Symbol,PERIOD_D1,"SuperTrend",PeriodST,Multiplier);
   if(handleSTrD==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTrW=iCustom(_Symbol,PERIOD_W1,"SuperTrend",PeriodST,Multiplier);
   if(handleSTrW==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
   handleSTrM=iCustom(_Symbol,PERIOD_MN1,"SuperTrend",PeriodST,Multiplier);
   if(handleSTrM==INVALID_HANDLE)
     {//--- Report the failure and return the error number      
      PrintFormat("Failed to create the handle of the Supertrend indicator. Error=",GetLastError());
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(high,true);ArraySetAsSeries(low,true);ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(time,true);ArraySetAsSeries(open,true);ArraySetAsSeries(spread,true);
   ArraySetAsSeries(close,true);ArraySetAsSeries(volume,true);
//---
   if(swTF1)
     {
      ArrayResize(SuperTr1,2);ArrayInitialize(SuperTr1,0.0);
      if(CopyBufferAsSeries(handleSTr1,2,0,2,true,SuperTr1))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr1[0])clr=clrRed;
         if(close[0]>SuperTr1[0])clr=clrGreen;
         if(close[0]==SuperTr1[0]&&close[1]>SuperTr1[1])clr=clrGreen;
         if(close[0]==SuperTr1[0]&&close[1]<SuperTr1[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB1");
         TextDelete(0,"2LPB1");
         TextCreate(0,"2LPB1",0,time[0]+PeriodSeconds(_Period),SuperTr1[0],"M1","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB1",0,time[0]+PeriodSeconds(_Period),SuperTr1[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTF2)
     {
      ArrayResize(SuperTr2,2);ArrayInitialize(SuperTr2,0.0);
      if(CopyBufferAsSeries(handleSTr2,2,0,2,true,SuperTr2))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr2[0])clr=clrRed;
         if(close[0]>SuperTr2[0])clr=clrGreen;
         if(close[0]==SuperTr2[0]&&close[1]>SuperTr2[1])clr=clrGreen;
         if(close[0]==SuperTr2[0]&&close[1]<SuperTr2[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB2");
         TextDelete(0,"2LPB2");
         TextCreate(0,"2LPB2",0,time[0]+PeriodSeconds(_Period),SuperTr2[0],"M2","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB2",0,time[0]+PeriodSeconds(_Period),SuperTr2[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTF3)
     {
      ArrayResize(SuperTr3,2);ArrayInitialize(SuperTr3,0.0);
      if(CopyBufferAsSeries(handleSTr3,2,0,2,true,SuperTr3))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr3[0])clr=clrRed;
         if(close[0]>SuperTr3[0])clr=clrGreen;
         if(close[0]==SuperTr3[0]&&close[1]>SuperTr3[1])clr=clrGreen;
         if(close[0]==SuperTr3[0]&&close[1]<SuperTr3[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB3");
         TextDelete(0,"2LPB3");
         TextCreate(0,"2LPB3",0,time[0]+PeriodSeconds(_Period),SuperTr3[0],"M3","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB3",0,time[0]+PeriodSeconds(_Period),SuperTr3[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTF4)
     {
      ArrayResize(SuperTr4,2);ArrayInitialize(SuperTr4,0.0);
      if(CopyBufferAsSeries(handleSTr4,2,0,2,true,SuperTr4))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr4[0])clr=clrRed;
         if(close[0]>SuperTr4[0])clr=clrGreen;
         if(close[0]==SuperTr4[0]&&close[1]>SuperTr4[1])clr=clrGreen;
         if(close[0]==SuperTr4[0]&&close[1]<SuperTr4[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB4");
         TextDelete(0,"2LPB4");
         TextCreate(0,"2LPB4",0,time[0]+PeriodSeconds(_Period),SuperTr4[0],"M4","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB4",0,time[0]+PeriodSeconds(_Period),SuperTr4[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTF5)
     {
      ArrayResize(SuperTr5,2);ArrayInitialize(SuperTr5,0.0);
      if(CopyBufferAsSeries(handleSTr5,2,0,2,true,SuperTr5))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr5[0])clr=clrRed;
         if(close[0]>SuperTr5[0])clr=clrGreen;
         if(close[0]==SuperTr5[0]&&close[1]>SuperTr5[1])clr=clrGreen;
         if(close[0]==SuperTr5[0]&&close[1]<SuperTr5[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB5");
         TextDelete(0,"2LPB5");
         TextCreate(0,"2LPB5",0,time[0]+PeriodSeconds(_Period),SuperTr5[0],"M5","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB5",0,time[0]+PeriodSeconds(_Period),SuperTr5[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTF6)
     {
      ArrayResize(SuperTr6,2);ArrayInitialize(SuperTr6,0.0);
      if(CopyBufferAsSeries(handleSTr6,2,0,2,true,SuperTr6))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr6[0])clr=clrRed;
         if(close[0]>SuperTr6[0])clr=clrGreen;
         if(close[0]==SuperTr6[0]&&close[1]>SuperTr6[1])clr=clrGreen;
         if(close[0]==SuperTr6[0]&&close[1]<SuperTr6[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB6");
         TextDelete(0,"2LPB6");
         TextCreate(0,"2LPB6",0,time[0]+PeriodSeconds(_Period),SuperTr6[0],"M6","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB6",0,time[0]+PeriodSeconds(_Period),SuperTr6[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTF10)
     {
      ArrayResize(SuperTr10,2);ArrayInitialize(SuperTr10,0.0);
      if(CopyBufferAsSeries(handleSTr10,2,0,2,true,SuperTr10))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr10[0])clr=clrRed;
         if(close[0]>SuperTr10[0])clr=clrGreen;
         if(close[0]==SuperTr10[0]&&close[1]>SuperTr10[1])clr=clrGreen;
         if(close[0]==SuperTr10[0]&&close[1]<SuperTr10[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB10");
         TextDelete(0,"2LPB10");
         TextCreate(0,"2LPB10",0,time[0]+PeriodSeconds(_Period),SuperTr10[0],"M10","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB10",0,time[0]+PeriodSeconds(_Period),SuperTr10[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTF12)
     {
      ArrayResize(SuperTr12,2);ArrayInitialize(SuperTr12,0.0);
      if(CopyBufferAsSeries(handleSTr12,2,0,2,true,SuperTr12))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr12[0])clr=clrRed;
         if(close[0]>SuperTr12[0])clr=clrGreen;
         if(close[0]==SuperTr12[0]&&close[1]>SuperTr12[1])clr=clrGreen;
         if(close[0]==SuperTr12[0]&&close[1]<SuperTr12[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB12");
         TextDelete(0,"2LPB12");
         TextCreate(0,"2LPB12",0,time[0]+PeriodSeconds(_Period),SuperTr12[0],"M12","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB12",0,time[0]+PeriodSeconds(_Period),SuperTr12[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTF15)
     {
      ArrayResize(SuperTr15,2);ArrayInitialize(SuperTr15,0.0);
      if(CopyBufferAsSeries(handleSTr15,2,0,2,true,SuperTr15))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr15[0])clr=clrRed;
         if(close[0]>SuperTr15[0])clr=clrGreen;
         if(close[0]==SuperTr15[0]&&close[1]>SuperTr15[1])clr=clrGreen;
         if(close[0]==SuperTr15[0]&&close[1]<SuperTr15[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB15");
         TextDelete(0,"2LPB15");
         TextCreate(0,"2LPB15",0,time[0]+PeriodSeconds(_Period),SuperTr15[0],"M15","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB15",0,time[0]+PeriodSeconds(_Period),SuperTr15[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTF20)
     {
      ArrayResize(SuperTr20,2);ArrayInitialize(SuperTr20,0.0);
      if(CopyBufferAsSeries(handleSTr20,2,0,2,true,SuperTr20))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr20[0])clr=clrRed;
         if(close[0]>SuperTr20[0])clr=clrGreen;
         if(close[0]==SuperTr20[0]&&close[1]>SuperTr20[1])clr=clrGreen;
         if(close[0]==SuperTr20[0]&&close[1]<SuperTr20[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB20");
         TextDelete(0,"2LPB20");
         TextCreate(0,"2LPB20",0,time[0]+PeriodSeconds(_Period),SuperTr20[0],"M20","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB20",0,time[0]+PeriodSeconds(_Period),SuperTr20[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTF30)
     {
      ArrayResize(SuperTr30,2);ArrayInitialize(SuperTr30,0.0);
      if(CopyBufferAsSeries(handleSTr30,2,0,2,true,SuperTr30))
        {
         color clr=clrBlack;
         if(close[0]<SuperTr30[0])clr=clrRed;
         if(close[0]>SuperTr30[0])clr=clrGreen;
         if(close[0]==SuperTr30[0]&&close[1]>SuperTr30[1])clr=clrGreen;
         if(close[0]==SuperTr30[0]&&close[1]<SuperTr30[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPB30");
         TextDelete(0,"2LPB30");
         TextCreate(0,"2LPB30",0,time[0]+PeriodSeconds(_Period),SuperTr30[0],"M30","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPB30",0,time[0]+PeriodSeconds(_Period),SuperTr30[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTFH1)
     {
      ArrayResize(SuperTrH1,2);ArrayInitialize(SuperTrH1,0.0);
      if(CopyBufferAsSeries(handleSTrH1,2,0,2,true,SuperTrH1))
        {
         color clr=clrBlack;
         if(close[0]<SuperTrH1[0])clr=clrRed;
         if(close[0]>SuperTrH1[0])clr=clrGreen;
         if(close[0]==SuperTrH1[0]&&close[1]>SuperTrH1[1])clr=clrGreen;
         if(close[0]==SuperTrH1[0]&&close[1]<SuperTrH1[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPBH1");
         TextDelete(0,"2LPBH1");
         TextCreate(0,"2LPBH1",0,time[0]+PeriodSeconds(_Period),SuperTrH1[0],"H1","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPBH1",0,time[0]+PeriodSeconds(_Period),SuperTrH1[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTFH2)
     {
      ArrayResize(SuperTrH2,2);ArrayInitialize(SuperTrH2,0.0);
      if(CopyBufferAsSeries(handleSTrH2,2,0,2,true,SuperTrH2))
        {
         color clr=clrBlack;
         if(close[0]<SuperTrH2[0])clr=clrRed;
         if(close[0]>SuperTrH2[0])clr=clrGreen;
         if(close[0]==SuperTrH2[0]&&close[1]>SuperTrH2[1])clr=clrGreen;
         if(close[0]==SuperTrH2[0]&&close[1]<SuperTrH2[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPBH2");
         TextDelete(0,"2LPBH2");
         TextCreate(0,"2LPBH2",0,time[0]+PeriodSeconds(_Period),SuperTrH2[0],"H2","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPBH2",0,time[0]+PeriodSeconds(_Period),SuperTrH2[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTFH3)
     {
      ArrayResize(SuperTrH3,2);ArrayInitialize(SuperTrH3,0.0);
      if(CopyBufferAsSeries(handleSTrH3,2,0,2,true,SuperTrH3))
        {
         color clr=clrBlack;
         if(close[0]<SuperTrH3[0])clr=clrRed;
         if(close[0]>SuperTrH3[0])clr=clrGreen;
         if(close[0]==SuperTrH3[0]&&close[1]>SuperTrH3[1])clr=clrGreen;
         if(close[0]==SuperTrH3[0]&&close[1]<SuperTrH3[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPBH3");
         TextDelete(0,"2LPBH3");
         TextCreate(0,"2LPBH3",0,time[0]+PeriodSeconds(_Period),SuperTrH3[0],"H3","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPBH3",0,time[0]+PeriodSeconds(_Period),SuperTrH3[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTFH4)
     {
      ArrayResize(SuperTrH4,2);ArrayInitialize(SuperTrH4,0.0);
      if(CopyBufferAsSeries(handleSTrH4,2,0,2,true,SuperTrH4))
        {
         color clr=clrBlack;
         if(close[0]<SuperTrH4[0])clr=clrRed;
         if(close[0]>SuperTrH4[0])clr=clrGreen;
         if(close[0]==SuperTrH4[0]&&close[1]>SuperTrH4[1])clr=clrGreen;
         if(close[0]==SuperTrH4[0]&&close[1]<SuperTrH4[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPBH4");
         TextDelete(0,"2LPBH4");
         TextCreate(0,"2LPBH4",0,time[0]+PeriodSeconds(_Period),SuperTrH4[0],"H4","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPBH4",0,time[0]+PeriodSeconds(_Period),SuperTrH4[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTFH6)
     {
      ArrayResize(SuperTrH6,2);ArrayInitialize(SuperTrH6,0.0);
      if(CopyBufferAsSeries(handleSTrH6,2,0,2,true,SuperTrH6))
        {
         color clr=clrBlack;
         if(close[0]<SuperTrH6[0])clr=clrRed;
         if(close[0]>SuperTrH6[0])clr=clrGreen;
         if(close[0]==SuperTrH6[0]&&close[1]>SuperTrH6[1])clr=clrGreen;
         if(close[0]==SuperTrH6[0]&&close[1]<SuperTrH6[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPBH6");
         TextDelete(0,"2LPBH6");
         TextCreate(0,"2LPBH6",0,time[0]+PeriodSeconds(_Period),SuperTrH6[0],"H6","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPBH6",0,time[0]+PeriodSeconds(_Period),SuperTrH6[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTFH8)
     {
      ArrayResize(SuperTrH8,2);ArrayInitialize(SuperTrH8,0.0);
      if(CopyBufferAsSeries(handleSTrH8,2,0,2,true,SuperTrH8))
        {
         color clr=clrBlack;
         if(close[0]<SuperTrH8[0])clr=clrRed;
         if(close[0]>SuperTrH8[0])clr=clrGreen;
         if(close[0]==SuperTrH8[0]&&close[1]>SuperTrH8[1])clr=clrGreen;
         if(close[0]==SuperTrH8[0]&&close[1]<SuperTrH8[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPBH8");
         TextDelete(0,"2LPBH8");
         TextCreate(0,"2LPBH8",0,time[0]+PeriodSeconds(_Period),SuperTrH8[0],"H8","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPBH8",0,time[0]+PeriodSeconds(_Period),SuperTrH8[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTFH12)
     {
      ArrayResize(SuperTrH12,2);ArrayInitialize(SuperTrH12,0.0);
      if(CopyBufferAsSeries(handleSTrH12,2,0,2,true,SuperTrH12))
        {
         color clr=clrBlack;
         if(close[0]<SuperTrH12[0])clr=clrRed;
         if(close[0]>SuperTrH12[0])clr=clrGreen;
         if(close[0]==SuperTrH12[0]&&close[1]>SuperTrH12[1])clr=clrGreen;
         if(close[0]==SuperTrH12[0]&&close[1]<SuperTrH12[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPBH12");
         TextDelete(0,"2LPBH12");
         TextCreate(0,"2LPBH12",0,time[0]+PeriodSeconds(_Period),SuperTrH12[0],"H12","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPBH12",0,time[0]+PeriodSeconds(_Period),SuperTrH12[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTFD)
     {
      ArrayResize(SuperTrD,2);ArrayInitialize(SuperTrD,0.0);
      if(CopyBufferAsSeries(handleSTrD,2,0,2,true,SuperTrD))
        {
         color clr=clrBlack;
         if(close[0]<SuperTrD[0])clr=clrRed;
         if(close[0]>SuperTrD[0])clr=clrGreen;
         if(close[0]==SuperTrD[0]&&close[1]>SuperTrD[1])clr=clrGreen;
         if(close[0]==SuperTrD[0]&&close[1]<SuperTrD[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPBD");
         TextDelete(0,"2LPBD");
         TextCreate(0,"2LPBD",0,time[0]+PeriodSeconds(_Period),SuperTrD[0],"D1","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPBD",0,time[0]+PeriodSeconds(_Period),SuperTrD[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTFW)
     {
      ArrayResize(SuperTrW,2);ArrayInitialize(SuperTrW,0.0);
      if(CopyBufferAsSeries(handleSTrW,2,0,2,true,SuperTrW))
        {
         color clr=clrBlack;
         if(close[0]<SuperTrW[0])clr=clrRed;
         if(close[0]>SuperTrW[0])clr=clrGreen;
         if(close[0]==SuperTrW[0]&&close[1]>SuperTrW[1])clr=clrGreen;
         if(close[0]==SuperTrW[0]&&close[1]<SuperTrW[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPBW");
         TextDelete(0,"2LPBW");
         TextCreate(0,"2LPBW",0,time[0]+PeriodSeconds(_Period),SuperTrW[0],"W1","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPBW",0,time[0]+PeriodSeconds(_Period),SuperTrW[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
   if(swTFM)
     {
      ArrayResize(SuperTrM,2);ArrayInitialize(SuperTrM,0.0);
      if(CopyBufferAsSeries(handleSTrM,2,0,2,true,SuperTrM))
        {
         color clr=clrBlack;
         if(close[0]<SuperTrM[0])clr=clrRed;
         if(close[0]>SuperTrM[0])clr=clrGreen;
         if(close[0]==SuperTrM[0]&&close[1]>SuperTrM[1])clr=clrGreen;
         if(close[0]==SuperTrM[0]&&close[1]<SuperTrM[1])clr=clrRed;
         ArrowRightPriceDelete(0,"LPBM");
         TextDelete(0,"2LPBM");
         TextCreate(0,"2LPBM",0,time[0]+PeriodSeconds(_Period),SuperTrM[0],"MN1","Arial",sizeFont,clr,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         ArrowRightPriceCreate(0,"LPBM",0,time[0]+PeriodSeconds(_Period),SuperTrM[0],clr,STYLE_SOLID,sizeP,false,false,true,0);
         ChartRedraw();
        }
     }
//--- 
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Creating the left price label                                    |
//+------------------------------------------------------------------+
bool ArrowRightPriceCreate(const long           chart_ID=0,         // chart ID
                           const string          name="RightPrice", // the name of the price label
                           const int             sub_window=0,      // subwindow number
                           datetime              time=0,            // time of the anchor point
                           double                price=0,           // price of the anchor point
                           const color           clr=clrRed,        // the color of the price label
                           const ENUM_LINE_STYLE style=STYLE_SOLID, // the style of the bordering line
                           const int             width=1,           // the size of the price label
                           const bool            back=false,        // in the background
                           const bool            selection=true,    // select to move
                           const bool            hidden=true,       // hidden in the list of objects
                           const long            z_order=0)         // priority for mouse click
  {//ArrowLeftPriceCreate(0,"LP",0,time[0],price[0],clr,STYLE_SOLID,1,false,false,true,0);
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create a price label
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_RIGHT_PRICE,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": Failed to create the left price label! Error code = ",GetLastError());
      return(false);
     }
//--- set the label color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the edging line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the label size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete the left price label from the chart                       |
//+------------------------------------------------------------------+
bool ArrowRightPriceDelete(const long   chart_ID=0,// chart ID
                           const string name="RightPrice") // the name of the label
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": Failed to delete the left price label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
// Copies the indicator values into an array, taking into account the indexing order            
bool CopyBufferAsSeries(int _handle,     // indicator handle
                        int bufer,       // the number of the indicator buffer
                        int start,       // where to start
                        int number,      // how many items to copy
                        bool asSeries,   // array indexing order
                        double &M[])     // the array, into which data will be copied
  {
//--- filling in the M array by the current indicator values
   if(CopyBuffer(_handle,bufer,start,number,M)<=0) return(false);
//--- creating the indexing order of the M array
//--- if asSeries=true, then the order of indexing of the M array is that of a timeseries
//--- if asSeries=false, then the default order of indexing of the M array is applied
   ArraySetAsSeries(M,asSeries);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking anchor point values and setting default values          |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+
//| Creating the "Text" object                                       |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // chart ID
                const string            name="Text",              // the name of the object
                const int               sub_window=0,             // subwindow number
                datetime                time=0,                   // time of the anchor point
                double                  price=0,                  // price of the anchor point
                const string            text="Text",              // the text
                const string            font="Arial",             // font
                const int               font_size=10,             // font size
                const color             clr=clrRed,               // color
                const double            angle=0.0,                // slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // select to move
                const bool              hidden=true,              // hidden in the list of objects
                const long              z_order=0)                // priority for mouse click
  {//TextCreate(0,"2LB",0,time[0],price[0],"text","Arial",12,clr,angle,ANCHOR_RIGHT_UPPER,false,false,true,0);
//--- set anchor point coordinates if they are not set
   ChangeTextEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create the \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set the text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the object by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Deleting the "Text" object                                       |
//+------------------------------------------------------------------+
bool TextDelete(const long   chart_ID=0,  // chart ID
                const string name="Text") // object name
  {
//--- reset the error value
   ResetLastError();
//--- delete the object
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking anchor point values and setting default values          |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeTextEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ArrowRightPriceDelete(0,"LPB1");
   ArrowRightPriceDelete(0,"LPB2");
   ArrowRightPriceDelete(0,"LPB3");
   ArrowRightPriceDelete(0,"LPB4");
   ArrowRightPriceDelete(0,"LPB5");
   ArrowRightPriceDelete(0,"LPB6");
   ArrowRightPriceDelete(0,"LPB10");
   ArrowRightPriceDelete(0,"LPB12");
   ArrowRightPriceDelete(0,"LPB15");
   ArrowRightPriceDelete(0,"LPB20");
   ArrowRightPriceDelete(0,"LPB30");
   ArrowRightPriceDelete(0,"LPBH1");
   ArrowRightPriceDelete(0,"LPBH2");
   ArrowRightPriceDelete(0,"LPBH3");
   ArrowRightPriceDelete(0,"LPBH4");
   ArrowRightPriceDelete(0,"LPBH6");
   ArrowRightPriceDelete(0,"LPBH8");
   ArrowRightPriceDelete(0,"LPBH12");
   ArrowRightPriceDelete(0,"LPBD");
   ArrowRightPriceDelete(0,"LPBW");
   ArrowRightPriceDelete(0,"LPBM");
   TextDelete(0,"2LPB1");
   TextDelete(0,"2LPB2");
   TextDelete(0,"2LPB3");
   TextDelete(0,"2LPB4");
   TextDelete(0,"2LPB5");
   TextDelete(0,"2LPB6");
   TextDelete(0,"2LPB10");
   TextDelete(0,"2LPB12");
   TextDelete(0,"2LPB15");
   TextDelete(0,"2LPB20");
   TextDelete(0,"2LPB30");
   TextDelete(0,"2LPBH1");
   TextDelete(0,"2LPBH2");
   TextDelete(0,"2LPBH3");
   TextDelete(0,"2LPBH4");
   TextDelete(0,"2LPBH6");
   TextDelete(0,"2LPBH8");
   TextDelete(0,"2LPBH12");
   TextDelete(0,"2LPBD");
   TextDelete(0,"2LPBW");
   TextDelete(0,"2LPBM");
   ChartRedraw();
  }
//+------------------------------------------------------------------+
