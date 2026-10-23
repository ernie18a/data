//+------------------------------------------------------------------+
//|                                        PivotPointsLines_v1.0.mq4 |
//|                                         Copyright 2020, NickBixy |
//|             https://www.forexfactory.com/showthread.php?t=904734 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, NickBixy"
#property link      "https://www.forexfactory.com/showthread.php?t=904734"
//#property version   "1.00"
#property strict
#property indicator_chart_window

//--- declaration of constants
#define OP_BUY 0           //Buy 
#define OP_SELL 1          //Sell
#define OP_BUYLIMIT 2      //BUY LIMIT pending order 
#define OP_SELLLIMIT 3     //SELL LIMIT pending order  
#define OP_BUYSTOP 4       //BUY STOP pending order  
#define OP_SELLSTOP 5      //SELL STOP pending order  
//---
#define OBJPROP_TIME1 300
#define OBJPROP_PRICE1 301
#define OBJPROP_TIME2 302
#define OBJPROP_PRICE2 303
#define OBJPROP_TIME3 304
#define OBJPROP_PRICE3 305
//---
#define OBJPROP_RAY 310
#define OBJPROP_FIBOLEVELS 200
//---

#define OBJPROP_FIRSTLEVEL1 211
#define OBJPROP_FIRSTLEVEL2 212
#define OBJPROP_FIRSTLEVEL3 213
#define OBJPROP_FIRSTLEVEL4 214
#define OBJPROP_FIRSTLEVEL5 215
#define OBJPROP_FIRSTLEVEL6 216
#define OBJPROP_FIRSTLEVEL7 217
#define OBJPROP_FIRSTLEVEL8 218
#define OBJPROP_FIRSTLEVEL9 219
#define OBJPROP_FIRSTLEVEL10 220
#define OBJPROP_FIRSTLEVEL11 221
#define OBJPROP_FIRSTLEVEL12 222
#define OBJPROP_FIRSTLEVEL13 223
#define OBJPROP_FIRSTLEVEL14 224
#define OBJPROP_FIRSTLEVEL15 225
#define OBJPROP_FIRSTLEVEL16 226
#define OBJPROP_FIRSTLEVEL17 227
#define OBJPROP_FIRSTLEVEL18 228
#define OBJPROP_FIRSTLEVEL19 229
#define OBJPROP_FIRSTLEVEL20 230
#define OBJPROP_FIRSTLEVEL21 231
#define OBJPROP_FIRSTLEVEL22 232
#define OBJPROP_FIRSTLEVEL23 233
#define OBJPROP_FIRSTLEVEL24 234
#define OBJPROP_FIRSTLEVEL25 235
#define OBJPROP_FIRSTLEVEL26 236
#define OBJPROP_FIRSTLEVEL27 237
#define OBJPROP_FIRSTLEVEL28 238
#define OBJPROP_FIRSTLEVEL29 239
#define OBJPROP_FIRSTLEVEL30 240
#define OBJPROP_FIRSTLEVEL31 241
//---
#define MODE_OPEN 0
#define MODE_CLOSE 3
#define MODE_VOLUME 4
#define MODE_REAL_VOLUME 5
#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
//---
#define DOUBLE_VALUE 0
#define FLOAT_VALUE 1
#define LONG_VALUE INT_VALUE
//---
#define CHART_BAR 0
#define CHART_CANDLE 1
//---
#define MODE_ASCEND 0
#define MODE_DESCEND 1
//---
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33
//---
#define EMPTY -1
//---
#define CharToStr CharToString
#define DoubleToStr DoubleToString
#define StrToDouble StringToDouble
#define StrToInteger (int)StringToInteger
#define StrToTime StringToTime
#define TimeToStr TimeToString
#define StringGetChar StringGetCharacter
#define StringSetChar StringSetCharacter
//+------------------------------------------------------------------+
enum pivotTypes
  {
   Standard,//Standard(Floor) Pivot Formula
   Fibonacci,//Fibonacci Pivot Formula
   Camarilla,//Camarilla Pivot Formula
   Woodie//Woodie Pivot Formula
  };

enum yesnoChoiceToggle
  {
   No,
   Yes
  };

input string Header="----------------- Pivot Point Settings------------------------------------------";//----- Pivot Point Settings
input pivotTypes pivotSelection=Standard;//Pivot Point Formula
input yesnoChoiceToggle drawFloorMidPP=No;//Draw Floor Mid Pivot Points?
input yesnoChoiceToggle showPriceLabel=No;//Show Price In Label?
input ENUM_TIMEFRAMES timeFrame=PERIOD_D1;//TimeFrame
input string Header2="----------------- Pivot Point Line/Label Customize Settings------------------------------------------";//----- Pivot Point Line/Label Customize Settings
input string customMSG="";//Custom Message Before Pivot Name
input yesnoChoiceToggle useShortLines=Yes;//Draw Short Lines
input int Line_Length=15;//Length of Short Line
input ENUM_LINE_STYLE lineStyle=STYLE_SOLID;//Line Style
input int lineWidth=1;//Line Width
input string Font="Arial";//Label Font
input int labelFontSize=8;//Label Font Size
input int ShiftLabel=10;//Label Shift +move right -move left
input yesnoChoiceToggle useSameColorLabelChoice=No;//Label use Same Color?
input color useSameColorLabelColor=clrWhite;//Label Color for Label use Same Color
input color resistantColor=clrDodgerBlue;//Resistant Line/Label Color
input color pivotColor=clrMagenta;//Pivot Line/Label Color
input color supportColor=clrRed;//Support Line/Label PP Color
input color midColor=clrGreen;//Mid PP Line/Label Color


string indiName="PPL"+" "+EnumToString(pivotSelection)+" "+EnumToString(timeFrame);

string camarillaPivotNames[]=
  {
   "PP",
   "S1",
   "S2",
   "S3",
   "S4",
   "R1",
   "R2",
   "R3",
   "R4",
   "R5",
   "S5",
  };
double camarillaValueArray[11];
string standardPivotNames[]=
  {
   "PP",
   "S1",
   "S2",
   "S3",
   "R1",
   "R2",
   "R3",
   "R4",
   "S4",
   "MR4",
   "MR3",
   "MR2",
   "MR1",
   "MS1",
   "MS2",
   "MS3",
   "MS4",
  };
double standardValueArray[17];
string woodiePivotNames[]=
  {
   "PP",
   "S1",
   "S2",
   "R1",
   "R2",
   "S3",
   "S4",
   "R3",
   "R4",
  };
double woodieValueArray[9];
string fibonacciPivotNames[]=
  {
   "PP",
   "R38",
   "R61",
   "R78",
   "R100",
   "R138",
   "R161",
   "R200",
   "S38",
   "S61",
   "S78",
   "S100",
   "S138",
   "S161",
   "S200",
  };
double fibonacciValueArray[15];
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(0,indiName,0,OBJ_TREND) ;
   ObjectsDeleteAll(0,indiName,0,OBJ_TEXT) ;


   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectsDeleteAll(0,indiName,0,OBJ_TREND) ;
   ObjectsDeleteAll(0,indiName,0,OBJ_TEXT) ;
  }
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
   if(pivotSelection==Camarilla)
     {
      camarillaPivotPoint(camarillaValueArray);
      for(int i=0; i<ArraySize(camarillaValueArray); i++)
        {
         DrawPivotLines(camarillaValueArray[i],camarillaPivotNames[i]);
        }
     }
   if(pivotSelection==Standard)
     {

      if(drawFloorMidPP==Yes)
        {
         standardPivotPoint(standardValueArray);
         for(int i=0; i<17; i++)
           {
            DrawPivotLines(standardValueArray[i],standardPivotNames[i]);
           }
        }
      else
        {
         standardPivotPoint(standardValueArray);
         for(int i=0; i<9; i++)
           {
            DrawPivotLines(standardValueArray[i],standardPivotNames[i]);
           }
        }

     }
   if(pivotSelection==Fibonacci)
     {
      fibonacciPivotPoint(fibonacciValueArray);
      for(int i=0; i<ArraySize(fibonacciValueArray); i++)
        {
         DrawPivotLines(fibonacciValueArray[i],fibonacciPivotNames[i]);
        }
     }
   if(pivotSelection==Woodie)
     {
      woodiePivotPoint(woodieValueArray);
      for(int i=0; i<ArraySize(woodieValueArray); i++)
        {
         DrawPivotLines(woodieValueArray[i],woodiePivotNames[i]);
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
void DrawPivotLines(double value,string pivotName)
  {
   int timeframeValue=0;
   switch(Period())                                  // Header of the 'switch'
     {
      // Start of the 'switch' body
      case PERIOD_M1 :
         timeframeValue=1;
         break;// Variations..
      case PERIOD_M2 :
         timeframeValue=2;
         break;// Variations..
      case PERIOD_M3 :
         timeframeValue=3;
         break;// Variations..
      case PERIOD_M4 :
         timeframeValue=4;
         break;// Variations..
      case PERIOD_M5 :
         timeframeValue=5;
         break;// Variations..
      case PERIOD_M6 :
         timeframeValue=6;
         break;// Variations..
      case PERIOD_M10 :
         timeframeValue=10;
         break;// Variations..
      case PERIOD_M12 :
         timeframeValue=12;
         break;// Variations..
      case PERIOD_M15 :
         timeframeValue=15;
         break;// Variations..
      case PERIOD_M20 :
         timeframeValue=20;
         break;// Variations..
      case PERIOD_M30 :
         timeframeValue=30;
         break;// Variations..
      case PERIOD_H1 :
         timeframeValue=60;
         break;// Variations..
      case PERIOD_H2 :
         timeframeValue=240;
         break;// Variations..
      case PERIOD_H3 :
         timeframeValue=180;
         break;// Variations..
      case PERIOD_H4 :
         timeframeValue=240;
         break;// Variations..
      case PERIOD_H6 :
         timeframeValue=360;
         break;// Variations..
      case PERIOD_H8 :
         timeframeValue=480;
         break;// Variations..
      case PERIOD_H12 :
         timeframeValue=720;
         break;// Variations..
      case PERIOD_D1 :
         timeframeValue=1440;
         break;// Variations..
      case PERIOD_W1 :
         timeframeValue=10080;
         break;// Variations..
      case PERIOD_MN1 :
         timeframeValue=43200;
         break;// Variations..
     }


   datetime Time[];
   int count=2;   // number of elements to copy
   ArraySetAsSeries(Time,true);
   CopyTime(_Symbol,_Period,0,count,Time);

   color lineLabelColor=clrNONE;
   string message="Poop";
   if(showPriceLabel==Yes)
     {
      message=customMSG+pivotName+": "+DoubleToString(value,Digits());
     }
   else
     {
      message=customMSG+pivotName;
     }


   if('R'==StringGetCharacter(pivotName,0))
     {
      lineLabelColor=resistantColor;
     }
   else
      if('P'==StringGetCharacter(pivotName,0))
        {
         lineLabelColor=pivotColor;
        }
      else
         if('S'==StringGetCharacter(pivotName,0))
           {
            lineLabelColor=supportColor;
           }
         else
            if('M'==StringGetCharacter(pivotName,0))
              {
               lineLabelColor=midColor;
              }

 

   string nameLine=indiName+" "+EnumToString(pivotSelection)+EnumToString(timeFrame)+pivotName+" Line";
   string nameLabel=indiName+" "+EnumToString(pivotSelection)+EnumToString(timeFrame)+pivotName+" Label";
   if(ObjectFindMQL4(nameLine) != 0)
     {
      if(useShortLines==Yes)
        {
         ObjectCreateMQL4(nameLine, OBJ_TREND, 0, Time[1]+timeframeValue*60, value, Time[0]+timeframeValue*60*Line_Length, value);
         ObjectSetMQL4(nameLine,OBJPROP_RAY,false);
        }
      else
        {
         ObjectCreateMQL4(nameLine,OBJ_TREND,0,iTime(NULL,timeFrame,0),value,Time[0]+timeframeValue*60,value);
         ObjectSetMQL4(nameLine,OBJPROP_RAY,true);
        }
      ObjectSetMQL4(nameLine,OBJPROP_COLOR,lineLabelColor);
      ObjectSetMQL4(nameLine,OBJPROP_STYLE,lineStyle);
      ObjectSetMQL4(nameLine,OBJPROP_WIDTH,lineWidth);
      ObjectSetMQL4(nameLine,OBJPROP_BACK,true);
      ObjectSetMQL4(nameLine,OBJPROP_SELECTED,false);
      ObjectSetMQL4(nameLine,OBJPROP_SELECTABLE,false);
     }
   else
     {
      if(useShortLines==Yes)
        {
         ObjectSetMQL4(nameLine,OBJPROP_RAY,false);
         ObjectMoveMQL4(nameLine, 0, Time[1]+timeframeValue*60, value);
         ObjectMoveMQL4(nameLine, 1, Time[0]+timeframeValue*60*Line_Length, value);
        }
      else
        {
         ObjectSetMQL4(nameLine,OBJPROP_RAY,true);
         ObjectMoveMQL4(nameLine,0,iTime(NULL,timeFrame,0),value);
         ObjectMoveMQL4(nameLine,1,Time[0]+timeframeValue*60,value);
        }

     }
   if(ObjectFindMQL4(nameLabel) != 0)
     {
      ObjectCreateMQL4(nameLabel,OBJ_TEXT,0,Time[0]+timeframeValue*60*ShiftLabel,value);
      if(useSameColorLabelChoice==Yes)
        {
         ObjectSetTextMQL4(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
        }
      else
        {
         ObjectSetTextMQL4(nameLabel,message,labelFontSize,Font,lineLabelColor);
        }
      ObjectSetMQL4(nameLabel,OBJPROP_BACK,true);
      ObjectSetMQL4(nameLabel,OBJPROP_SELECTED,false);
      ObjectSetMQL4(nameLabel,OBJPROP_SELECTABLE,false);
     }
   else
     {
      ObjectMoveMQL4(nameLabel, 0,Time[0]+timeframeValue*60*ShiftLabel,value);
      if(useSameColorLabelChoice==Yes)
        {
         ObjectSetTextMQL4(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
        }
      else
        {
         ObjectSetTextMQL4(nameLabel,message,labelFontSize,Font,lineLabelColor);
        }
     }
   ChartRedraw(0);
  }
//camarilla formula
void camarillaPivotPoint(double &ppArrayRef[])//camrilla pivot point formula
  {

   int shift=1;
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeekMQL4(dayCheck1) == 0)//found sunday
        {
         shift+=1;
        }

      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeekMQL4(dayCheck2) == 6)//found saturday
        {
         shift+=1;
        }
     }

   double camRange= iHigh(NULL,timeFrame,shift)-iLow(NULL,timeFrame,shift);
   double prevHigh=iHigh(NULL,timeFrame,shift);
   double prevLow=iLow(NULL,timeFrame,shift);
   double prevClose=iClose(NULL,timeFrame,shift);
   int symbolDigits=(int)MarketInfoMQL4(NULL,MODE_DIGITS);
   double R1 = ((1.1 / 12) * camRange) + prevClose;
   double R2 = ((1.1 / 6) * camRange) + prevClose;
   double R3 = ((1.1 / 4) * camRange) + prevClose;
   double R4= ((1.1/2) * camRange)+prevClose;
   double S1= prevClose -((1.1/12) * camRange);
   double S2= prevClose -((1.1/6) * camRange);
   double S3 = prevClose - ((1.1 / 4) * camRange);
   double S4 = prevClose - ((1.1 / 2) * camRange);
   double PP = (R4+S4)/2;
   double R5=((prevHigh/prevLow)*prevClose);
   double S5=(prevClose-(R5-prevClose));
   ppArrayRef[0]=PP;
   ppArrayRef[1]=S1;
   ppArrayRef[2]=S2;
   ppArrayRef[3]=S3;
   ppArrayRef[4]=S4;
   ppArrayRef[5]=R1;
   ppArrayRef[6]=R2;
   ppArrayRef[7]=R3;
   ppArrayRef[8]=R4;
   ppArrayRef[9]=R5;
   ppArrayRef[10]=S5;
  }
//+------------------------------------------------------------------+
//standard pivot point formula
void standardPivotPoint(double &ppArrayRef[])//the formula for the standard floor pivot points
  {
   int shift=1;
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeekMQL4(dayCheck1) == 0)//found sunday - skip over
        {
         shift+=1;
        }

      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeekMQL4(dayCheck2) == 6)//found saturday - skip over
        {
         shift+=1;
        }
     }

   double prevHigh = iHigh(NULL,timeFrame,shift);
   double prevLow=iLow(NULL,timeFrame,shift);
   double prevClose=iClose(NULL,timeFrame,shift);
   double PP = (prevHigh+prevLow+prevClose)/3;
   double R1 = (PP * 2)-prevLow;
   double S1 = (PP * 2)-prevHigh;
   double R2 = PP + prevHigh - prevLow;
   double S2 = PP - prevHigh + prevLow;
   double R3 = R1 + (prevHigh-prevLow);
   double S3 = prevLow - 2 * (prevHigh-PP);
   double R4 = R3+(R2-R1);
   double S4 = S3-(S1-S2);
   ppArrayRef[0]=PP;
   ppArrayRef[1]=S1;
   ppArrayRef[2]=S2;
   ppArrayRef[3]=S3;
   ppArrayRef[4]=R1;
   ppArrayRef[5]=R2;
   ppArrayRef[6]=R3;
   ppArrayRef[7]=R4;
   ppArrayRef[8]=S4;

   if(drawFloorMidPP==Yes)
     {
      //mid pivots
      ppArrayRef[9]=(R3+R4)/2;
      ppArrayRef[10]=(R2+R3)/2;
      ppArrayRef[11]=(R1+R2)/2;
      ppArrayRef[12]=(PP+R1)/2;
      ppArrayRef[13]=(PP+S1)/2;
      ppArrayRef[14]=(S1+S2)/2;
      ppArrayRef[15]=(S2+S3)/2;
      ppArrayRef[16]=(S3+S4)/2;
     }
  }
//+------------------------------------------------------------------+
void woodiePivotPoint(double &ppArrayRef[])//woodie pivot point formula
  {
   int shift=1;
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeekMQL4(dayCheck1) == 0)//found sunday
        {
         shift+=1;
        }

      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeekMQL4(dayCheck2) == 6)//found saturday
        {
         shift+=1;
        }
     }

   double prevRange= iHigh(NULL,timeFrame,shift)-iLow(NULL,timeFrame,shift);
   double prevHigh = iHigh(NULL,timeFrame,shift);
   double prevLow=iLow(NULL,timeFrame,shift);
   double prevClose = iClose(NULL, timeFrame,shift);
   double todayOpen = iOpen(NULL, timeFrame,shift-1);
   double PP = (prevHigh+prevLow+(todayOpen*2))/4;
   double R1 = (PP * 2)-prevLow;
   double R2 = PP + prevRange;
   double S1 = (PP * 2)-prevHigh;
   double S2 = PP - prevRange;

   double S3 = (prevLow-2*(prevHigh-PP));
   double S4 = (S3-prevRange);

   double R3 = (prevHigh+2*(PP-prevLow));
   double R4 = (R3+prevRange);

   ppArrayRef[0]=PP;
   ppArrayRef[1]=S1;
   ppArrayRef[2]=S2;
   ppArrayRef[3]=R1;
   ppArrayRef[4]=R2;

   ppArrayRef[5]=S3;
   ppArrayRef[6]=S4;

   ppArrayRef[7]=R3;
   ppArrayRef[8]=R4;
  }
//fibonacci formula
void fibonacciPivotPoint(double &ppArrayRef[])//fibonacchi pivot point formula
  {

   int shift=1;
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */

   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeekMQL4(dayCheck1) == 0)//found sunday
        {
         shift+=1;
        }

      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeekMQL4(dayCheck2) == 6)//found saturday
        {
         shift+=1;
        }
     }

   double prevRange= iHigh(NULL,timeFrame,shift)-iLow(NULL,timeFrame,shift);
   double prevHigh = iHigh(NULL,timeFrame,shift);
   double prevLow=iLow(NULL,timeFrame,shift);
   double prevClose=iClose(NULL,timeFrame,shift);
   double Pivot=(prevHigh+prevLow+prevClose)/3;
   double R38=  Pivot + ((prevRange) * 0.382);
   double R61=  Pivot + ((prevRange) * 0.618);
   double R78=  Pivot + ((prevRange) * 0.786);
   double R100= Pivot + ((prevRange) * 1.000);
   double R138= Pivot + ((prevRange) * 1.382);
   double R161= Pivot + ((prevRange) * 1.618);
   double R200= Pivot + ((prevRange) * 2.000);
   double S38 = Pivot - ((prevRange) * 0.382);
   double S61 = Pivot - ((prevRange) * 0.618);
   double S78 = Pivot -((prevRange)  * 0.786);
   double S100= Pivot - ((prevRange) * 1.000);
   double S138= Pivot - ((prevRange) * 1.382);
   double S161= Pivot - ((prevRange) * 1.618);
   double S200= Pivot - ((prevRange) * 2.000);
   ppArrayRef[0]=Pivot;
   ppArrayRef[1]=R38;
   ppArrayRef[2]=R61;
   ppArrayRef[3]=R78;
   ppArrayRef[4]=R100;
   ppArrayRef[5]=R138;
   ppArrayRef[6]=R161;
   ppArrayRef[7]=R200;
   ppArrayRef[8]=S38;
   ppArrayRef[9]=S61;
   ppArrayRef[10]=S78;
   ppArrayRef[11]=S100;
   ppArrayRef[12]=S138;
   ppArrayRef[13]=S161;
   ppArrayRef[14]=S200;
  }
//+------------------------------------------------------------------+
int ObjectFindMQL4(string name)
  {
   return(ObjectFind(0,name));
  }
//+------------------------------------------------------------------+
bool ObjectSetMQL4(string name,
                   int index,
                   double value)
  {
   switch(index)
     {
      case OBJPROP_TIME1:
         ObjectSetInteger(0,name,OBJPROP_TIME,(int)value);
         return(true);
      case OBJPROP_PRICE1:
         ObjectSetDouble(0,name,OBJPROP_PRICE,value);
         return(true);
      case OBJPROP_TIME2:
         ObjectSetInteger(0,name,OBJPROP_TIME,1,(int)value);
         return(true);
      case OBJPROP_PRICE2:
         ObjectSetDouble(0,name,OBJPROP_PRICE,1,value);
         return(true);
      case OBJPROP_TIME3:
         ObjectSetInteger(0,name,OBJPROP_TIME,2,(int)value);
         return(true);
      case OBJPROP_PRICE3:
         ObjectSetDouble(0,name,OBJPROP_PRICE,2,value);
         return(true);
      case OBJPROP_COLOR:
         ObjectSetInteger(0,name,OBJPROP_COLOR,(int)value);
         return(true);
      case OBJPROP_STYLE:
         ObjectSetInteger(0,name,OBJPROP_STYLE,(int)value);
         return(true);
      case OBJPROP_WIDTH:
         ObjectSetInteger(0,name,OBJPROP_WIDTH,(int)value);
         return(true);
      case OBJPROP_BACK:
         ObjectSetInteger(0,name,OBJPROP_BACK,(int)value);
         return(true);
      case OBJPROP_RAY:
         ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,(int)value);
         return(true);
      case OBJPROP_ELLIPSE:
         ObjectSetInteger(0,name,OBJPROP_ELLIPSE,(int)value);
         return(true);
      case OBJPROP_SCALE:
         ObjectSetDouble(0,name,OBJPROP_SCALE,value);
         return(true);
      case OBJPROP_ANGLE:
         ObjectSetDouble(0,name,OBJPROP_ANGLE,value);
         return(true);
      case OBJPROP_ARROWCODE:
         ObjectSetInteger(0,name,OBJPROP_ARROWCODE,(int)value);
         return(true);
      case OBJPROP_TIMEFRAMES:
         ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,(int)value);
         return(true);
      case OBJPROP_DEVIATION:
         ObjectSetDouble(0,name,OBJPROP_DEVIATION,value);
         return(true);
      case OBJPROP_FONTSIZE:
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(int)value);
         return(true);
      case OBJPROP_CORNER:
         ObjectSetInteger(0,name,OBJPROP_CORNER,(int)value);
         return(true);
      case OBJPROP_XDISTANCE:
         ObjectSetInteger(0,name,OBJPROP_XDISTANCE,(int)value);
         return(true);
      case OBJPROP_YDISTANCE:
         ObjectSetInteger(0,name,OBJPROP_YDISTANCE,(int)value);
         return(true);
      case OBJPROP_FIBOLEVELS:
         ObjectSetInteger(0,name,OBJPROP_LEVELS,(int)value);
         return(true);
      case OBJPROP_LEVELCOLOR:
         ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,(int)value);
         return(true);
      case OBJPROP_LEVELSTYLE:
         ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,(int)value);
         return(true);
      case OBJPROP_LEVELWIDTH:
         ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,(int)value);
         return(true);

      default:
         return(false);
     }
   return(false);
  }
//+------------------------------------------------------------------+
bool ObjectMoveMQL4(string name,
                    int point,
                    datetime time1,
                    double price1)
  {
   return(ObjectMove(0,name,point,time1,price1));
  }
//+------------------------------------------------------------------+
bool ObjectCreateMQL4(string name,
                      ENUM_OBJECT type,
                      int window,
                      datetime time1,
                      double price1,
                      datetime time2=0,
                      double price2=0,
                      datetime time3=0,
                      double price3=0)
  {
   return(ObjectCreate(0,name,type,window,
                       time1,price1,time2,price2,time3,price3));
  }
//+------------------------------------------------------------------+
bool ObjectSetTextMQL4(string name,
                       string text,
                       int font_size,
                       string font="",
                       color text_color=CLR_NONE)
  {
   int tmpObjType=(int)ObjectGetInteger(0,name,OBJPROP_TYPE);
   if(tmpObjType!=OBJ_LABEL && tmpObjType!=OBJ_TEXT)
      return(false);
   if(StringLen(text)>0 && font_size>0)
     {
      if(ObjectSetString(0,name,OBJPROP_TEXT,text)==true
         && ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size)==true)
        {
         if((StringLen(font)>0)
            && ObjectSetString(0,name,OBJPROP_FONT,font)==false)
            return(false);
         if(text_color>-1
            && ObjectSetInteger(0,name,OBJPROP_COLOR,text_color)==false)
            return(false);
         return(true);
        }
      return(false);
     }
   return(false);
  }
//+------------------------------------------------------------------+
int TimeDayOfWeekMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }
//+------------------------------------------------------------------+
double MarketInfoMQL4(string symbol,
                      int type)
  {
   switch(type)
     {
      case MODE_LOW:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTLOW));
      case MODE_HIGH:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTHIGH));
      case MODE_TIME:
         return(SymbolInfoInteger(symbol,SYMBOL_TIME));
      //   case MODE_BID:
      //      return(Bid);
      //  case MODE_ASK:
      //     return(Ask);
      case MODE_POINT:
         return(SymbolInfoDouble(symbol,SYMBOL_POINT));
      case MODE_DIGITS:
         return(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      case MODE_SPREAD:
         return(SymbolInfoInteger(symbol,SYMBOL_SPREAD));
      case MODE_STOPLEVEL:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
      case MODE_LOTSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE));
      case MODE_TICKVALUE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE));
      case MODE_TICKSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
      case MODE_SWAPLONG:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG));
      case MODE_SWAPSHORT:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT));
      case MODE_STARTING:
         return(0);
      case MODE_EXPIRATION:
         return(0);
      case MODE_TRADEALLOWED:
         return(0);
      case MODE_MINLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN));
      case MODE_LOTSTEP:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP));
      case MODE_MAXLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX));
      case MODE_SWAPTYPE:
         return(SymbolInfoInteger(symbol,SYMBOL_SWAP_MODE));
      case MODE_PROFITCALCMODE:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE));
      case MODE_MARGINCALCMODE:
         return(0);
      case MODE_MARGININIT:
         return(0);
      case MODE_MARGINMAINTENANCE:
         return(0);
      case MODE_MARGINHEDGED:
         return(0);
      case MODE_MARGINREQUIRED:
         return(0);
      case MODE_FREEZELEVEL:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL));

      default:
         return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
