#include <Math\Stat\Math.mqh>
#resource "catmodel propensity matching original.onnx" as uchar ExtModel[]
#resource "catmodel_m propensity matching original.onnx" as uchar ExtModel2[]
int Periods[29] = {10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220,230,240,250,260,270,280,290};

void fill_arays( double &features[]) {
   double pr[], ret[];
   ArrayResize(ret, 1);
   for(int i=ArraySize(Periods)-1; i>=0; i--) {
       CopyClose(NULL,PERIOD_H1,1,Periods[i],pr);
       ret[0] = MathMean(pr) - pr[Periods[i]-1];
       ArrayInsert(features, ret, ArraySize(features), 0, WHOLE_ARRAY); }
   ArraySetAsSeries(features, true);
}

