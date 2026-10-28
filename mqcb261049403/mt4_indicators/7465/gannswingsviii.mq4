//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//-----
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 clrWhite
#property indicator_color2 clrBlue
#property indicator_color3 clrRed
#property indicator_color4 clrAqua
#property indicator_color5 clrHotPink
//----
extern int kind=1;// тип тенденции, 1- малая, 2 - промежуточная, 3 - основная
extern bool MoveLastSwing=false; // если равно true, то кончик хвоста будет сдвигаться ближе к нулевому бару для двух одинаковых баров по High или Low
//---- buffers
double SwingsBuffer[];
double HighsBuffer[];
double LowsBuffer[];
double TrendBuffer[];
double UpCloseOutSideBuffers[];
double DownCloseOutSideBuffers[];
double SwingHigh,SwingLow;
int prevSwing,LastSwing,myBars,lowCounter,highCounter;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(6);
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,SwingsBuffer);
   SetIndexEmptyValue(0,0.0);
   SetIndexBuffer(1,HighsBuffer);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(2,LowsBuffer);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexBuffer(3,UpCloseOutSideBuffers);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,108);
   SetIndexBuffer(4,DownCloseOutSideBuffers);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,108);
   SetIndexBuffer(5,TrendBuffer);
//---
   ArrayInitialize(SwingsBuffer,0.0);
   ArrayInitialize(HighsBuffer,0.0);
   ArrayInitialize(LowsBuffer,0.0);
   ArrayInitialize(TrendBuffer,0.0);
   ArrayInitialize(UpCloseOutSideBuffers,0.0);
   ArrayInitialize(DownCloseOutSideBuffers,0.0);
//---
   SwingHigh=0.0;
   SwingLow=0.0;
   prevSwing=0;
   LastSwing=0.0;
   myBars=0;
   lowCounter=0;
   highCounter=0;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| return shift of last swing                                       |
//+------------------------------------------------------------------+
int GetLastSwing()
  {
//---- 
   int point=1;
   while(SwingsBuffer[point]==0.0 && point<Bars) point++;
//----
   return(point);
  }
//+------------------------------------------------------------------+
//| Check prev swing                                                 |
//+------------------------------------------------------------------+
void SetPrevSwing()
  {
//---- 
   int LastPoint;
   LastPoint=GetLastSwing();
   SwingsBuffer[0]=0.0;
   SwingHigh=High[LastPoint];
   SwingLow=Low[LastPoint];
   LastSwing=LastPoint;
//----
   return;
  }
//+------------------------------------------------------------------+
//| check Out side bar                                               |
//+------------------------------------------------------------------+
bool isOutSideSwingBar(int shift)
  {
   bool res=false;
//---- 
   res=((High[shift]>High[shift+1]) && (Low[shift]<Low[shift+1]));
   if(res)
     {
      if(Close[shift]>Open[shift]) UpCloseOutSideBuffers[shift]=(High[shift]+Low[shift])/2.0;
      else DownCloseOutSideBuffers[shift]=(High[shift]+Low[shift])/2.0;
     }
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Check new low                                                    |
//+------------------------------------------------------------------+
void SetSwings(int shift)
  {
//---- 
//----
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int limit;
   bool nonOutSide;
   if(counted_bars==0)
     {
      limit=Bars-1;
      LowsBuffer[limit]=Low[limit];
      SwingsBuffer[limit]=Low[limit];
      SwingHigh=High[limit];
      SwingLow=Low[limit];
      LastSwing=limit;
      TrendBuffer[limit]=-1.0;
     }
   if(counted_bars>0) limit=Bars-counted_bars;
   if((counted_bars<0) || ((counted_bars>0) && (Bars-myBars>1))) init();
   limit--;
//Print("Bars=",Bars," counted_bars=",counted_bars,);
//---- 
   for(int cnt=limit;cnt>=0;cnt--)
     {
      if(limit<3)Print("cnt=",cnt,"  myBars=",myBars,"  LastSwing=",LastSwing);
      //if (cnt==0) SetPrevSwing();
      nonOutSide=!isOutSideSwingBar(cnt);
      if(High[cnt]>SwingHigh) {highCounter++;SwingHigh=High[cnt];HighsBuffer[cnt]=SwingHigh;}
      if(Low[cnt]<SwingLow) {lowCounter++;SwingLow=Low[cnt];LowsBuffer[cnt]=SwingLow;}
      //isOutSideSwingBar(cnt);
      TrendBuffer[cnt]=TrendBuffer[cnt+1];// если не будут изменений - тренд сохранится
      if((TrendBuffer[cnt+1]==-1.0) && (lowCounter==1))// && nonOutSide) 
        {
         //if (LastSwing=!cnt) 
         if(LastSwing!=Bars-1) SwingsBuffer[LastSwing]=0.0; // затрем предыдущий свинг
         LastSwing=cnt;
         SwingHigh=High[cnt];
         SwingLow=Low[cnt];
         //TrendBuffer[cnt]=-1.0;
         highCounter=0;
         lowCounter=0;
         SwingsBuffer[cnt]=Low[cnt];
         HighsBuffer[cnt]=SwingHigh;
         //Print("продолжение даунтренда");
        }
      else
        {
         if(TrendBuffer[cnt+1]==-1.0 && highCounter==kind)
           {
            //if (LastSwing=!cnt) 
            LastSwing=cnt;
            SwingHigh=High[cnt];
            SwingLow=Low[cnt];
            TrendBuffer[cnt]=1.0;
            highCounter=0;
            lowCounter=0;
            SwingsBuffer[cnt]=High[cnt];
            LowsBuffer[cnt]=SwingLow;
            //Print("разворот даунтренда");
           }
         else
           {
            if(TrendBuffer[cnt+1]==-1.0 && Low[cnt]==SwingLow && MoveLastSwing)
              {
               SwingsBuffer[LastSwing]=0.0;
               LastSwing=cnt;
/*               SwingLow=Low[cnt];
               SwingHigh=High[cnt];
               highCounter=0;
               lowCounter=0;
*/               SwingsBuffer[cnt]=Low[cnt];
              }
           }

        }
      if((TrendBuffer[cnt+1]==1.0) && (highCounter==1))// && nonOutSide) 
        {
         //if (LastSwing=!cnt) 
         if(LastSwing!=Bars-1) SwingsBuffer[LastSwing]=0.0; // затрем предыдущий свинг
         LastSwing=cnt;
         SwingHigh=High[cnt];
         SwingLow=Low[cnt];
         //TrendBuffer[cnt]=1.0;
         highCounter=0;
         lowCounter=0;
         SwingsBuffer[cnt]=High[cnt];
         LowsBuffer[cnt]=SwingLow;
         //Print("продолжение аптренда");
        }
      else
        {
         if(TrendBuffer[cnt+1]==1.0 && lowCounter==kind)
           {
            //if (LastSwing=!cnt) 
            LastSwing=cnt;
            SwingHigh=High[cnt];
            SwingLow=Low[cnt];
            TrendBuffer[cnt]=-1.0;
            highCounter=0;
            lowCounter=0;
            SwingsBuffer[cnt]=Low[cnt];
            HighsBuffer[cnt]=SwingHigh;
            //Print("разворот аптренда");
           }
         else
           {
            if(TrendBuffer[cnt+1]==1.0 && High[cnt]==SwingHigh && MoveLastSwing)
              {
               SwingsBuffer[LastSwing]=0.0;
               LastSwing=cnt;
/*               SwingLow=Low[cnt];
               SwingHigh=High[cnt];
               highCounter=0;
               lowCounter=0;
*/               SwingsBuffer[cnt]=High[cnt];
              }
           }

        }
     }
   myBars=Bars;
//----
   return(0);
  }
//+------------------------------------------------------------------+
