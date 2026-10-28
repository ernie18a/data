//+------------------------------------------------------------------+
//|                                                   PS_Magicas.mq5 |
//|                                                        psmarqu3s |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "PS - psmarqu3s@outlook.com"
#property link        "https://forge.mql5.io"
#property version     "1.07"
#property description "PS Magicas - Three moving averages that give target and possible entries"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3

//--- plot pLenta
#property indicator_label1  "Slow"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  4
//--- plot pMedia
#property indicator_label2  "Medium"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrAqua
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- plot pRapida
#property indicator_label3  "Fast"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrLightSeaGreen,clrGreen,clrYellow,clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

//--- input parameters
input int      Rapida=20; //Fast - Usualy 20 ou 21
input ENUM_MA_METHOD RapidaTipo = MODE_SMMA; //Fast MA Type - SMMA Default
input int      Media=90;  //Medium - Usualy 90
input ENUM_MA_METHOD MediaTipo = MODE_SMMA; //Medium MA Type - SMMA Default
input int      Lenta=200; //Slow - Usualy 200
input ENUM_MA_METHOD LentaTipo = MODE_SMMA; 
input bool     HabilitarSinais=false; //Enable Buy or Sell Suggestion(Beta)

//--- indicator buffers
double         pLentaBuffer[];
double         pMediaBuffer[];
double         pRapidaBuffer[];
double         ColorBuffer[];

int ma_rapida;
int ma_media;
int ma_lenta;
datetime lastsignal=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,pLentaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,pMediaBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,pRapidaBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ColorBuffer,INDICATOR_COLOR_INDEX);

   ma_rapida= iMA(Symbol(), 0, Rapida, 0, RapidaTipo,PRICE_CLOSE);
   ma_media = iMA(Symbol(), 0, Media, 0, MediaTipo, PRICE_CLOSE);
   ma_lenta = iMA(Symbol(), 0, Lenta, 0, LentaTipo, PRICE_CLOSE);

   PlotIndexSetInteger(0,0,PLOT_DRAW_BEGIN,Lenta);
   PlotIndexSetInteger(1,0,PLOT_DRAW_BEGIN,Media);
   PlotIndexSetInteger(2,0,PLOT_DRAW_BEGIN,Rapida);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|De Initi                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//EventKillTimer();

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
   int start=prev_calculated==0 ? 0 : prev_calculated-1;
   double preco=0;
   double timeSeries[1];

   //Popular os Buffers das MM
   CopyBuffer(ma_lenta,0,0,rates_total-start,pLentaBuffer);
   CopyBuffer(ma_media,0,0,rates_total-start,pMediaBuffer);
   CopyBuffer(ma_rapida,0,0,rates_total-start,pRapidaBuffer);

   CopyClose(Symbol(),_Period,0,1,timeSeries);
   preco=timeSeries[0];

   double priceLenta=pLentaBuffer[start];
   double priceLenta1=pLentaBuffer[start==0 ? 0 : start-1];

   double priceMedia=pMediaBuffer[start];
   double priceMedia1=pMediaBuffer[start==0 ? 0 : start-1];

   double priceRapida=pRapidaBuffer[start];
   double priceRapida1=pRapidaBuffer[start==0 ? 0 : start-1];

   ColorMediaTick(rates_total,start,high,low);

   if(start>17) 
     {

      //
      //Buy Signal
      //
      if(//Checar a Tendencia
         (priceRapida>priceLenta && 
         priceMedia>priceLenta) && 

         //Checar os Cruzamentos
         ((priceRapida>priceMedia && 
         priceRapida1<priceMedia) || 

         (priceLenta>priceMedia && 
         priceLenta1<priceMedia) || 

         (priceMedia>priceLenta && 
         priceMedia1<priceLenta && 
         priceRapida>priceMedia && 
         close[start]>priceRapida))) 
        {

         if(HabilitarSinais) 
           {
            //Desenhar o sinal
            DrawSignal(0,low[start]);
           }
        }

      //
      //Sell Signal
      //
      else if(//Cehcar a Tendencia
         (priceRapida<priceLenta && 
          priceMedia<priceLenta) && 

          //Cehcar os Cruzamentos
          ((priceRapida<priceMedia && 
          priceRapida1>priceMedia) || 

          (priceLenta<priceMedia && 
          priceLenta1>priceMedia) || 

          (priceMedia<priceLenta && 
          priceMedia1>priceLenta && 
          priceRapida<priceMedia && 
          close[start]<priceRapida))) 
           {

            if(HabilitarSinais) 
              {
               //Desenhar o sinal
               DrawSignal(0,high[start]);
              }
           }
        }

      //--- return value of prev_calculated for next call
      return(rates_total);
     }
//+------------------------------------------------------------------+

   void OnTimer()
     {

     }
//+------------------------------------------------------------------+
//| Draw Signal                                                      |
//+------------------------------------------------------------------+
   void DrawSignal(int tipo,double price)
     {
      datetime dt=TimeTradeServer();
      string name="signal_s"+IntegerToString(dt);

      ResetLastError();

      if(dt - lastsignal < 240) return;

      string tp=tipo==0 ? "compra" : "venda";

      ObjectCreate(0,"signal_"+tp+DoubleToString(price,0),(tipo==0 ? OBJ_ARROW_UP : OBJ_ARROW_DOWN),0,dt,price);
      ObjectSetInteger(0,"signal_"+tp+IntegerToString(tipo)+DoubleToString(price,0),OBJPROP_ANCHOR,(tipo==0 ? ANCHOR_TOP : ANCHOR_BOTTOM));
      ObjectSetInteger(0,"signal_"+tp+IntegerToString(tipo)+DoubleToString(price,0),OBJPROP_WIDTH,3);
      ObjectSetInteger(0,"signal_"+tp+IntegerToString(tipo)+DoubleToString(price,0),OBJPROP_COLOR,(tipo==0 ? clrBlue : clrRed));
      ObjectSetInteger(0,"signal_"+tp+IntegerToString(tipo)+DoubleToString(price,0),OBJPROP_STYLE,STYLE_SOLID);

      //Remember last signal
      lastsignal=dt;
     }
//+------------------------------------------------------------------+
//| Colored Moving Average (Beta)                                    |
//+------------------------------------------------------------------+
   void ColorMediaTick(const int rates_total,
                       const int prev_calculated,
                       const double &high[],
                       const double &low[]) 
     {    
      int limit = prev_calculated == 0 ? prev_calculated + Rapida + 1 : prev_calculated - 1;
      
      for(int i=limit; i<rates_total; i++) {
      
         double precoL = low[i];
         double precoH = high[i];
         double precoRapida=pRapidaBuffer[i];
         
         if(precoL>precoRapida) ColorBuffer[i]=1;
         else if(precoH<precoRapida) ColorBuffer[i]=3;
         else ColorBuffer[i]=2;
      }
     }
//+------------------------------------------------------------------+
