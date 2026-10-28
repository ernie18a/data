//+------------------------------------------------------------------+
//|                                                  Fibo Bars_3.mq4 |
//|                   Copyright 2005-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2020, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Fibo Bars_3"
#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_minimum 0
#property indicator_maximum 1

#property indicator_color1 clrRed
#property indicator_width1 2
#property indicator_color2 clrGreen
#property indicator_width2 2
#property indicator_color3 clrGold
#property indicator_width3 3



extern int periodFast   = 2;
extern int periodMed    = 19;
extern int periodSlow   = 190;
extern int fiboLevel    = 1;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];

double trandSlow[];
double trandMid[];
double trandFast[];

double level;
#define level1 0.236
#define level2 0.382
#define level3 0.5
#define level4 0.618
#define level5 0.762

datetime barTime = 0;

int init() {
    IndicatorBuffers(6);
 
    SetIndexBuffer(0, ExtMapBuffer1);
    SetIndexBuffer(1, ExtMapBuffer2);
    SetIndexBuffer(2, ExtMapBuffer3);
    SetIndexBuffer(3, trandSlow);
    SetIndexBuffer(4, trandMid);
    SetIndexBuffer(5, trandFast);
    
    SetIndexStyle(0, DRAW_HISTOGRAM, 0);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0);
    SetIndexStyle(2, DRAW_HISTOGRAM, 0);
    
    SetIndexDrawBegin(0, periodSlow);
    SetIndexDrawBegin(1, periodSlow);
    SetIndexDrawBegin(2, periodSlow);
    
    switch(fiboLevel){
    case 1:
        level = level1;
        break;
    case 2:
        level = level2;   
        break;
    case 3:
        level = level3;
        break;
    case 4:
        level = level4;
        break;
    case 5:
        level = level5;
        break;
    default: 
        level = level1;
        break;
    }
    return(0);
}

int deinit(){
    return(0);
}

int start() {
    int indicatorCounted = IndicatorCounted();
    if (indicatorCounted < 0) { 
        return (-1);
    }
    if(indicatorCounted > 0) {
       indicatorCounted--;
    }
   
     int limit = Bars - indicatorCounted -  2;
    for(int i = limit; i >= 0; i--) {
      double maxHigh = High[iHighest(NULL,0,MODE_HIGH, periodSlow, i)];
      double minLow = Low[iLowest(NULL,0,MODE_LOW, periodSlow, i)]; 
      if(Open[i]>Close[i]) {
         if (!(trandSlow[i+1] < 0  && (maxHigh - minLow) * level < (Close[i] - minLow))) 
            trandSlow[i] = 0;
         else
            trandSlow[i] = -1;
      } 
        else {
         if (!(trandSlow[i+1] == 0  && (maxHigh - minLow) * level < (maxHigh - Close[i])))
            trandSlow[i] = -1;
         else
            trandSlow[i] = 0;
      }
        
      maxHigh = High[iHighest(NULL,0,MODE_HIGH, periodMed, i)];
      minLow = Low[iLowest(NULL,0,MODE_LOW, periodMed, i)]; 
      if(Open[i]>Close[i]) {
         if (!(trandMid[i+1] < 0  && (maxHigh - minLow) * level < (Close[i] - minLow))) 
            trandMid[i] = 0;
         else
            trandMid[i] = -1;
      } 
        else {
         if (!(trandMid[i+1] == 0  && (maxHigh - minLow) * level < (maxHigh - Close[i])))
            trandMid[i] = -1;
         else
            trandMid[i] = 0;
      }
    

      maxHigh = High[iHighest(NULL,0,MODE_HIGH, periodFast, i)];
      minLow = Low[iLowest(NULL,0,MODE_LOW, periodFast, i)]; 
      if(Open[i]>Close[i]) {
         if (!(trandFast[i+1] < 0  && (maxHigh - minLow) * level < (Close[i] - minLow))) 
            trandFast[i] = 0;
         else
            trandFast[i] = -1;
      } 
      else {
         if (!(trandFast[i+1] == 0  && (maxHigh - minLow) * level < (maxHigh - Close[i])))
            trandFast[i] = -1;
         else
            trandFast[i] = 0;
      }
    
      if (trandFast[i]==0 && trandMid[i]==0 && trandSlow[i]==0) { //RED
         ExtMapBuffer1[i] = 1;
         ExtMapBuffer2[i] = 0; 
         ExtMapBuffer3[i] = 0; 
      } 
      else 
         if (trandFast[i]==-1 && trandMid[i]==-1 && trandSlow[i]==-1) {//GREEN BAR
            ExtMapBuffer1[i] = 0;
            ExtMapBuffer2[i] = 1; 
            ExtMapBuffer3[i] = 0;  
         } 
         else {
            ExtMapBuffer1[i] = 0;
            ExtMapBuffer2[i] = 0; 
            ExtMapBuffer3[i] = 1;  
         }
    }
    
    return(0);
}