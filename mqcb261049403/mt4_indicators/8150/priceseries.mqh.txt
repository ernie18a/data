//Version  January 1, 2007
//+------------------------------------------------------------------+
//|                                                  PriceSeries.mqh |
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
// Функция PriceSeries() возвращает входную цену бара по его номеру nPriceSeries.Bar и
// по номеру цены PriceSeries.Input_Price_Customs:
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 
//10-0.5*TRENDFOLLOW, 11-Heiken Ashi High, 12-Heiken Ashi Low, 13-Heiken Ashi Open, 14-Heiken Ashi Close,
// пример: minuse = PriceSeries(Input_Price_Customs, bar) - PriceSeries(Input_Price_Customs, bar+1);
// или;  Momentum = PriceSeries(Input_Price_Customs, bar) - PriceSeries(Input_Price_Customs, bar+Momentum_Period); 
  
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//++++++++++++++++++++++++++++++++++++ <<< PriceSeries >>> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

double PriceSeries(int PriceSeries_Input_Price_Customs, int nPriceSeries_Bar)
 {
  double dPriceSeries;
  switch(PriceSeries_Input_Price_Customs)
   {
    case  0: dPriceSeries = Close[nPriceSeries_Bar];break;
    case  1: dPriceSeries = Open [nPriceSeries_Bar];break;
    case  2: dPriceSeries = High [nPriceSeries_Bar];break;
    case  3: dPriceSeries = Low  [nPriceSeries_Bar];break;
    case  4: dPriceSeries =(High [nPriceSeries_Bar]+Low  [nPriceSeries_Bar])/2;break;
    case  5: dPriceSeries =(Close[nPriceSeries_Bar]+High [nPriceSeries_Bar]+Low[nPriceSeries_Bar])/3;break;
    case  6: dPriceSeries =(Open [nPriceSeries_Bar]+High [nPriceSeries_Bar]+Low[nPriceSeries_Bar]+Close[nPriceSeries_Bar])/4;break;
    case  7: dPriceSeries =(Open [nPriceSeries_Bar]+Close[nPriceSeries_Bar])/2;break;
    case  8: dPriceSeries =(Close[nPriceSeries_Bar]+High [nPriceSeries_Bar]+Low[nPriceSeries_Bar]+Close[nPriceSeries_Bar])/4;break;
    case  9: dPriceSeries = TrendFollow00(nPriceSeries_Bar);break;
    case 10: dPriceSeries = TrendFollow01(nPriceSeries_Bar);break;
    case 11: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",0,nPriceSeries_Bar);break;
    case 12: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",1,nPriceSeries_Bar);break;
    case 13: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",2,nPriceSeries_Bar);break;
    case 14: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",3,nPriceSeries_Bar);break;

    default: dPriceSeries = Close[nPriceSeries_Bar];
   }
  return(dPriceSeries);
 }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//----+ введение функции TrendFollow00. для case 9 --------------------------------------------+
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
double TrendFollow00(int nTrendFollow00_Bar)
 {
  double dTrendFollow00;
  double dTrendFollow00_high= High [nTrendFollow00_Bar];
  double dTrendFollow00_low=  Low  [nTrendFollow00_Bar];
  double dTrendFollow00_open= Open [nTrendFollow00_Bar];
  double dTrendFollow00_close=Close[nTrendFollow00_Bar];

  if(dTrendFollow00_close>dTrendFollow00_open)dTrendFollow00 = dTrendFollow00_high;
  else
  {
  if(dTrendFollow00_close<dTrendFollow00_open)dTrendFollow00 = dTrendFollow00_low;
                                                 else dTrendFollow00 = dTrendFollow00_close;
  }
  return(dTrendFollow00);
 }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//----+ введение функции TrendFollow01. для case 10 -------------------------------------------+
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
double TrendFollow01(int nTrendFollow01_Bar)
 {
  double dTrendFollow01;
  double dTrendFollow01_high= High [nTrendFollow01_Bar];
  double dTrendFollow01_low=  Low  [nTrendFollow01_Bar];
  double dTrendFollow01_open= Open [nTrendFollow01_Bar];
  double dTrendFollow01_close=Close[nTrendFollow01_Bar];

  if(dTrendFollow01_close>dTrendFollow01_open)
                        dTrendFollow01 =(dTrendFollow01_high+dTrendFollow01_close)/2;
  else
   {
  if(dTrendFollow01_close<dTrendFollow01_open)
                        dTrendFollow01 = (dTrendFollow01_low+dTrendFollow01_close)/2;
                   else dTrendFollow01 = dTrendFollow01_close;
   }
  return(dTrendFollow01);
 }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//----+ введение функции PriceSeriesAlert -----------------------------------------------------+
// Функция PriceSeriesAlert() предназначена для индикации недопустимого значения параметра     |
// PriceSeries.Input_Price_Customs передаваемого в функцию PriceSeries().                      |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
void PriceSeriesAlert(int nPriceSeriesAlert_IPC)
 {
  if(nPriceSeriesAlert_IPC< 0)
      Alert("Параметр Input_Price_Customs должен быть не менее  0" 
               + " Вы ввели недопустимое "+(string)nPriceSeriesAlert_IPC+ " будет использовано 0");
  if(nPriceSeriesAlert_IPC>14)
      Alert("Параметр Input_Price_Customs должен быть не более 14" 
               + " Вы ввели недопустимое "+(string)nPriceSeriesAlert_IPC+ " будет использовано 0");
 }
//----+ ---------------------------------------------------------------------------------------+