//************************************************************************************************/
//*                                 VR Atr Pro Lite MT 5.mq5                                     */
//*                            Copyright 2018, Trading-go Project.                               */
//*            Author: Voldemar, Version: 19.06.2018, Site https://trading-go.ru                 */
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
//| Full version MetaTrader 4  https://www.mql5.com/ru/market/product/6252
//| Lite version MetaTrader 4  https://www.mql5.com/ru/code/11424
//|
//| Full version MetaTrader 5  https://www.mql5.com/ru/market/product/30086
//| Lite version MetaTrader 5  https://www.mql5.com/ru/code/21149
//************************************************************************************************/
//| All products of the Author https://www.mql5.com/ru/users/voldemar/seller
//************************************************************************************************/
#property copyright   "Copyright 2018, Vladimir Pastushak."
#property link        "https://www.mql5.com/ru/users/voldemar/seller"
#property version     "18.080"
#property description "Calculates the potential for price growth and fall"
#property strict
//************************************************************************************************/
// 19.06.2018                                                                                    */
//************************************************************************************************/
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//************************************************************************************************/
// 19.06.2018                                                                                    */
//************************************************************************************************/
struct ATR_struct
  {
   string            RectName;
   datetime          Time_open;
   datetime          Time_close;
   double            price_higth;
   double            price_open;
   double            price_low;
   double            point_aw_higt;
   double            point_aw_low;
   double            point_higt;
   double            point_low;
  };
ATR_struct atr[];
//************************************************************************************************/
// 19.06.2018                                                                                    */
//************************************************************************************************/
int OnInit()
  {
   Comment(" ");
   ArrayResize(atr,40,100);

   for(int i=0;  i<5;i++)
     {
      atr[i].RectName="Rectangle  "+(string)i;
      RectangleCreate(0,atr[i].RectName,0,NULL,NULL,NULL,NULL,clrBlue,STYLE_SOLID,1,false,false,false,true,0);
     }
   return(INIT_SUCCEEDED);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
   if(NewBar())
     {
      for(int i=1;i<20;i++)
        {
         atr[i].Time_open     = NULL;
         atr[i].Time_close    = NULL;
         atr[i].price_higth   = NULL;
         atr[i].price_open    = NULL;
         atr[i].price_low     = NULL;
         atr[i].point_aw_higt = NULL;
         atr[i].point_aw_low  = NULL;
         atr[i].point_higt    = NULL;
         atr[i].point_low     = NULL;
         //==
         atr[i].Time_open     = iTime(Symbol(),PERIOD_D1,i);
         atr[i].Time_close    = atr[i].Time_open+PeriodSeconds(PERIOD_D1);
         atr[i].price_higth   = iHigh(Symbol(),PERIOD_D1,i);
         atr[i].price_open    = iOpen(Symbol(),PERIOD_D1,i);
         atr[i].price_low     = iLow(Symbol(),PERIOD_D1,i);
         atr[i].point_higt    = atr[i].price_higth - atr[i].price_open;
         atr[i].point_low     = atr[i].price_open  - atr[i].price_low;
        }
      for(int i=1;i<5;i++)
         for(int k=i+1;k<i+1+10;k++)
           {
            atr[i].point_aw_higt += (atr[k].point_higt)/10;
            atr[i].point_aw_low  += (atr[k].point_low )/10;
           }
      for(int i=1;  i<5;i++)
         if(ObjectFind(0,atr[i].RectName)==0 && i!=0)
           {
            ObjectSetInteger(0,atr[i].RectName,OBJPROP_TIME,0,atr[i].Time_open);
            ObjectSetDouble(0,atr[i].RectName,OBJPROP_PRICE,0,atr[i].price_open+atr[i].point_aw_higt);
            ObjectSetInteger(0,atr[i].RectName,OBJPROP_TIME,1,atr[i].Time_close);
            ObjectSetDouble(0,atr[i].RectName,OBJPROP_PRICE,1,atr[i].price_open-atr[i].point_aw_low);
           }
      ChartRedraw(0);
     }

   return(rates_total);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnDeinit(const int reason)
  {
   for(int i=0;  i<5;i++)
     {
      atr[i].RectName="Rectangle  "+(string)i;
      ObjectDelete(0,atr[i].RectName);
     }
   EventKillTimer();
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
bool RectangleCreate(const long            chart_ID=0,        //
                     const string          name="Rectangle",  //
                     const int             sub_window=0,      //
                     datetime              time1=0,           //
                     double                price1=0,          //
                     datetime              time2=0,           //
                     double                price2=0,          //
                     const color           clr=clrRed,        //
                     const ENUM_LINE_STYLE style=STYLE_SOLID, //
                     const int             width=1,           //
                     const bool            fill=false,        //
                     const bool            back=false,        //
                     const bool            selection=true,    //
                     const bool            hidden=true,       //
                     const long            z_order=0)         //
  {
   if(ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
   return(true);
  }
//************************************************************************************************/
//                                                                                               */
//************************************************************************************************/
bool NewBar()
  {
   static datetime old_time=NULL;
   datetime        new_time=iTime(Symbol(),Period(),0);

   if(new_time!=old_time)
     {
      old_time=new_time;
      return true;
     }

   return false;
  }
//************************************************************************************************/
//                                                                                               */
//************************************************************************************************/
