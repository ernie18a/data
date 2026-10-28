//+------------------------------------------------------------------+
//|                                                  CosmoGround.mq5 |
//|                                        Copyright 2012, expforex. |
//|                                          http://www.expforex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, expforex."
#property link      "http://www.expforex.com"
#property version   "1.00"
#property indicator_chart_window

input int CountStars=1000; // Number of stars
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDelete();
   ChartRedraw();
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectsDelete()
  {
   for(int i=ObjectsTotal(0);i>=0;i--)
     {
      if(StringFind(ObjectName(0,i),"Stars")!=-1)ObjectDelete(0,ObjectName(0,i));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   MathSrand(GetTickCount());
   StarsCreate();
   EventSetTimer(1);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StarsActivateLight()
  {
   int Size;
   string name=MathRand()%CountStars;
   Comment(name);
   Size=ObjectGetInteger(0,"Stars"+name,OBJPROP_FONTSIZE);
   int u=MathRand()%2;

   if(u==1)ObjectSetInteger(0,"Stars"+name,OBJPROP_FONTSIZE,Size+1);
   else if(u==0)ObjectSetInteger(0,"Stars"+name,OBJPROP_FONTSIZE,Size-1);
   ChartRedraw();

   int Y=ObjectGetInteger(0,"Stars"+name,OBJPROP_YDISTANCE);
   for(int r=Y;r<ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);r++)
     {
      ObjectSetInteger(0,"Stars"+name,OBJPROP_YDISTANCE,r+1);
      ChartRedraw();Sleep(25);

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StarsCreate()
  {
   int i;
   for(i=0;i<=CountStars;i++)

     {
      SetLabel("Stars"+(string)i,"T",RandomX(),RandomY(),RandomSize(5),RandomColor());

     }

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
//---

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   StarsActivateLight();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RandomX()
  {
   int x;
   x=MathRand()%ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   return(x);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RandomY()
  {
   int y;
   y=MathRand()%ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   return(y);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RandomSize(int si)
  {
   int s;
   s=MathRand()%si;
   return(s);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RandomColor()
  {
   int c;
   c=MathRand()%10;
   if(c==0)return(clrDarkSlateGray);
   if(c==1)return(clrMidnightBlue);
   if(c==2)return(clrMediumBlue);
   if(c==3)return(clrDarkTurquoise);
   if(c==4)return(clrAqua);
   if(c==5)return(clrDodgerBlue);
   if(c==6)return(clrRoyalBlue);
   if(c==7)return(clrLightGray);
   if(c==8)return(clrLightCyan);
   if(c==9)return(clrSnow);
   return(clrLightSkyBlue);
  }
//+------------------------------------------------------------------+
void SetLabel(string nm,string tx,int xd,int yd,int fs,color ct)
  {
   if(fs<1)fs=1;
   ENUM_BASE_CORNER cn;
   ENUM_ANCHOR_POINT cr;
   cn=CORNER_LEFT_UPPER;
   cr=ANCHOR_LEFT_UPPER;
   if(ObjectFind(0,nm)<0)ObjectCreate(0,nm,OBJ_LABEL,0,0,0);  //--- создадим объект Label
   ObjectSetString(0,nm,OBJPROP_TEXT,"*");                    //--- установим текст для объекта Label 
   ObjectSetInteger(0,nm,OBJPROP_CORNER,cn);                  //--- установим привязку к углу графика              
   ObjectSetInteger(0,nm,OBJPROP_ANCHOR,cr);                  //--- установим положение точки привязки графического объекта
   ObjectSetInteger(0,nm,OBJPROP_XDISTANCE,xd);               //--- установим координату X
   ObjectSetInteger(0,nm,OBJPROP_YDISTANCE,yd);               //--- установим координату Y
   ObjectSetString(0,nm,OBJPROP_FONT,"Verdana");                    //--- установим шрифт надписи
   ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,fs);                //--- установим размер шрифта    
   ObjectSetInteger(0,nm,OBJPROP_COLOR,ct);                   //--- зададим цвет текста
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);           //--- запретим выделение объекта мышкой   
  }
//+------------------------------------------------------------------+
