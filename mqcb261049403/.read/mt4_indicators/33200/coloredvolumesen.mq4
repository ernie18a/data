//+------------------------------------------------------------------+
//| Open code                                                        |
//+------------------------------------------------------------------+
#property strict
#property version     "1.0"
#property copyright   "Roman."
#property link        "romankiverin@yandex.ru"
#property description "If you like the indicator, you can thank the author"
#property description "Webmoney: Z330494414179, R222585888867"
#property description " "
#property description "Thank you very much."
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
extern bool AutoAroundLine = false;//Auto Draw Line Around Volume
extern int  ValueColor = 4;//Level Draw Line Around Volume (pixels)
extern bool AroundLine = true;//Draw Line Around Volume

extern color Lo0 = clrDarkCyan;//Up Candle Color Top Gradient
extern color Hi0 = clrWhiteSmoke;//Up Candle Color Bottom Gradient
extern color Ln0 = clrLime;//Up Candle Color Around Line
extern int   Op0 = 0xA0;//Up Candle Start Opaque (from 0.. to 255)
extern int   OP0 = 0x30;//Up Candle End Opaque (from 0.. to 255)

extern color Lo1 = clrYellow;//Down Candle Color Top Gradient
extern color Hi1 = clrWhiteSmoke;//Down Candle Color Bottom Gradient
extern color Ln1 = clrRed;//Down Candle Color Around Line
extern int   Op1 = 0x90;//Down Candle Start Opaque (from 0.. to 255)
extern int   OP1 = 0x40;//Down Candle End Opaque (from 0.. to 255)

extern double Persent = 15;//% of Screen

struct Gradient
  {
   uint              R[2], G[2], B[2], O[2], Line;
  };

Gradient Storage[2];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   ArrayFree(Storage);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   color IC[2][5];

   IC[0][0] = Lo0;
   IC[0][1] = Hi0;
   IC[0][2] = Ln0;
   IC[0][3] = (color)Op0;
   IC[0][4] = (color)OP0;

   IC[1][0] = Lo1;
   IC[1][1] = Hi1;
   IC[1][2] = Ln1;
   IC[1][3] = (color)Op1;
   IC[1][4] = (color)OP1;

   for(int i = 0; i < 2; i ++)
     {
      for(int j = 0; j < 2; j++)
        {
         Storage[i].B[j] = 0xff & (IC[i][j]>>16);
         Storage[i].G[j] = 0xff & (IC[i][j]>>8);
         Storage[i].R[j] = 0xff & IC[i][j];
         Storage[i].O[j] = (uint)IC[i][3+j];
        }

      Storage[i].Line = IC[i][2];
     }
//---
   return(INIT_SUCCEEDED);
  }

int Y, X, F, Cx, Cy, CxP, Scale;
double MaxVolume = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFirst()
  {
   if(MaxVolume<1)
      return;
   int FVB = ChartFirstVisibleBar(), VB = ChartVisibleBars(), vB = FVB - VB;
   uint MapSrorrage[];
   ObjectDelete(0, "mapD0");

   string D = "mapD0";
   string MasName = "::Maps0";

   int ShVolume = int(((double)Volume[0])*MaxVolume);
   if(ShVolume==0)
      return;

   ChartTimePriceToXY(0,0,Time[0],Low[0],Cx,Cy);
   ChartTimePriceToXY(0,0,Time[1],Low[1],CxP,Cy);

   if(Cx <= 0 || CxP <=0)
      return;

   int LengtOfBar = Cx - CxP;

   ObjectCreate(0,D,OBJ_BITMAP_LABEL,0,0,0);
   ObjectSetString(0,D,OBJPROP_BMPFILE,MasName);
   ObjectSetInteger(0,D,OBJPROP_XDISTANCE,Cx-LengtOfBar/2);

   LengtOfBar = LengtOfBar - Scale;

   ObjectSetInteger(0,D,OBJPROP_YDISTANCE,Y-ShVolume-2);
   ObjectSetInteger(0,D,OBJPROP_BACK,true);

   FillMap(MapSrorrage,LengtOfBar,ShVolume,Close[0]>Open[0]?Storage[0]:Storage[1]);

   ResourceFree(MasName);
   ResourceCreate(MasName,MapSrorrage,LengtOfBar,ShVolume,0,0,0,COLOR_FORMAT_ARGB_NORMALIZE);

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFull()
  {
   int FVB = ChartFirstVisibleBar(), VB = ChartVisibleBars(), vB = FVB - VB;
   uint MapSrorrage[];
   ObjectsDeleteAll(0, "map");
   MaxVolume = 0;

   Scale = (Scale = ChartScaleGet()) != 5? Scale != 4? Scale != 3? Scale != 2? 0: 1: 1: 2: 3;

   for(int i = vB; i <= FVB+3; i ++)
      if(i+1<ArraySize(Volume)&&i>-1)
         MaxVolume   = MathMax((int)Volume[i],MaxVolume);

   if(MaxVolume<1)
      return;

   MaxVolume = ((double)Y*(Persent/100.0f))/MaxVolume;
   for(int i = vB; i <= FVB+3; i ++)
     {
      string D = "mapD" + string(i);
      string MasName = "::Maps" + string(i);
      if(!(i+1<ArraySize(Volume)&&i>-1))
         continue;

      int ShVolume = int(((double)Volume[i])*MaxVolume);
      if(ShVolume==0)
         continue;

      ChartTimePriceToXY(0,0,Time[i],Low[i],Cx,Cy);
      ChartTimePriceToXY(0,0,Time[1+i],Low[1+i],CxP,Cy);

      if(Cx <= 0 || CxP <=0)
         continue;

      int LengtOfBar = Cx - CxP;
      ObjectCreate(0,D,OBJ_BITMAP_LABEL,0,0,0);
      ObjectSetString(0,D,OBJPROP_BMPFILE,MasName);
      ObjectSetInteger(0,D,OBJPROP_XDISTANCE,Cx-LengtOfBar/2);
      ObjectSetInteger(0,D,OBJPROP_YDISTANCE,Y - ShVolume - 2);
      ObjectSetInteger(0,D,OBJPROP_BACK,true);

      LengtOfBar = LengtOfBar - Scale;
      FillMap(MapSrorrage,LengtOfBar,ShVolume,Close[i]>Open[i]?Storage[0]:Storage[1]);

      ResourceFree(MasName);
      ResourceCreate(MasName,MapSrorrage,LengtOfBar,ShVolume,0,0,0,COLOR_FORMAT_ARGB_NORMALIZE);
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FillMap(uint & MapSrorrage[],int iX,int iY,Gradient & gColor)
  {
   ArrayResize(MapSrorrage, iX * iY);
   double dB = gColor.B[1]!=gColor.B[0]?(((((double)gColor.B[1]) - ((double)gColor.B[0]))/(double)(iY))):0;
   double dG = gColor.G[1]!=gColor.G[0]?(((((double)gColor.G[1]) - ((double)gColor.G[0]))/(double)(iY))):0;
   double dR = gColor.R[1]!=gColor.R[0]?(((((double)gColor.R[1]) - ((double)gColor.R[0]))/(double)(iY))):0;
   double dO = gColor.O[1]!=gColor.O[0]?(((((double)gColor.O[1]) - ((double)gColor.O[0]))/(double)(iY))):0;

   if(AutoAroundLine && iX < ValueColor)
      AroundLine = false;
   else
      AroundLine = true;

   if(AroundLine)
     {
      for(int i = iY - 2; i > 0; i--)
        {
         ArrayFill(MapSrorrage, iX * i, iX, ColorToARGB((((gColor.B[0]+uint(dB!=0?(double(i)*dB):0)))<<16)+
                   (((gColor.G[0]+uint(dG!=0?(double(i)*dG):0)))<<8)+
                   ((gColor.R[0]+uint(dR!=0?(double(i)*dR):0))),(uchar)(gColor.O[0]+uchar(dO!=0?(double(i)*dO):0))));
         MapSrorrage[iX * i] = MapSrorrage[iX * i + iX - 1] = ColorToARGB(gColor.Line,(uchar)(gColor.O[0]+uchar(dO!=0?(double(i)*dO):0)));
        }
      ArrayFill(MapSrorrage, 0, iX, ColorToARGB(gColor.Line,(uchar)gColor.O[0]));
      ArrayFill(MapSrorrage, iX * (iY - 1), iX, ColorToARGB(gColor.Line,(uchar)gColor.O[1]));
     }
   else

      for(int i = 0; i < iY; i++)
         ArrayFill(MapSrorrage, iX * i, iX, ColorToARGB((((gColor.B[0]+uint(dB!=0?(double(i)*dB):0)))<<16)+
                   (((gColor.G[0]+uint(dG!=0?(double(i)*dG):0)))<<8)+
                   ((gColor.R[0]+uint(dR!=0?(double(i)*dR):0))),(uchar)(gColor.O[0]+uchar(dO!=0?(double(i)*dO):0))));

  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
bool starts = false;
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
//---

   static datetime tmpTime = 0;
   starts=true;
   if(tmpTime!=time[0])
     {
      DrawFull();
      tmpTime=time[0];
     }
   else
      DrawFirst();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Функция получает номер первого видимого бара на графике.         |
//| Индексация как в таймсерии, последние бары имеют меньшие индексы.|
//+------------------------------------------------------------------+
int ChartFirstVisibleBar(const long chart_ID=0)
  {
//--- подготовим переменную для получения значения свойства
   long result=-1;
//--- сбросим значение ошибки
   ResetLastError();
//--- получим значение свойства
   if(!ChartGetInteger(chart_ID,CHART_FIRST_VISIBLE_BAR,0,result))
     {
      //--- выведем сообщение об ошибке в журнал "Эксперты"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- вернем значение свойства графика
   return((int)result);
  }
//+------------------------------------------------------------------+
//| Функция получает количество баров, которые отображаются (видимы )|
//| в окне графика.                                                  |
//+------------------------------------------------------------------+
int ChartVisibleBars(const long chart_ID=0)
  {
//--- подготовим переменную для получения значения свойства
   long result=-1;
//--- сбросим значение ошибки
   ResetLastError();
//--- получим значение свойства
   if(!ChartGetInteger(chart_ID,CHART_VISIBLE_BARS,0,result))
     {
      //--- выведем сообщение об ошибке в журнал "Эксперты"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- вернем значение свойства графика
   return((int)result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_CHART_CHANGE&&starts)
     {
      Y=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
      X=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      F=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR);
      DrawFull();
     }
  }
//+------------------------------------------------------------------+
int ChartScaleGet(const long chart_ID=0)
  {
//--- подготовим переменную для получения значения свойства
   long result=-1;
//--- сбросим значение ошибки
   ResetLastError();
//--- получим значение свойства
   if(!ChartGetInteger(chart_ID,CHART_SCALE,0,result))
     {
      //--- выведем сообщение об ошибке в журнал "Эксперты"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- вернем значение свойства графика
   return((int)result);
  }
//+------------------------------------------------------------------+
