//+------------------------------------------------------------------+
//|                                              KMeans_Clusters.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.28"
#property indicator_chart_window

// --- MQL5 WEBSITE PARSER BYPASS ---
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "MQL5_Bypass"
#property indicator_type1   DRAW_NONE
#property indicator_color1  clrNONE

input group "=== Machine Learning Settings ==="
input int InpLookback = 500;       // Data Sample Size (Bars)
input int InpClusters = 4;         // Number of Clusters (K)
input int InpMaxIter  = 100;       // Max Training Iterations

input group "=== Visual Settings ==="
input color InpLineColor = clrGoldenrod;
input ENUM_LINE_STYLE InpLineStyle = STYLE_DASH;

double DummyBuffer[];
string prefix = "KMEANS_";

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, DummyBuffer, INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst K-Means Clusters");
   Print("Institutional K-Means ML Initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, prefix);
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
   if(rates_total < InpLookback) return(0);

   // Feed the bypass buffer
   DummyBuffer[rates_total - 1] = 0;

   // Only train the K-Means model on a new bar to save CPU
   if(prev_calculated == rates_total) return(rates_total);

   double data[];
   ArrayResize(data, InpLookback);
   
   double max_price = 0;
   double min_price = 999999;

   // 1. Gather Data (Typical Price)
   for(int i = 0; i < InpLookback; i++)
     {
      int index = rates_total - 1 - i;
      data[i] = (high[index] + low[index] + close[index]) / 3.0;
      
      if(data[i] > max_price) max_price = data[i];
      if(data[i] < min_price) min_price = data[i];
     }

   // 2. Initialize Centroids (Evenly spaced across the range)
   double centroids[];
   ArrayResize(centroids, InpClusters);
   double step = (max_price - min_price) / (InpClusters + 1);
   
   for(int k = 0; k < InpClusters; k++)
     {
      centroids[k] = min_price + (step * (k + 1));
     }

   // 3. K-Means Training Loop
   bool changed = true;
   int iterations = 0;
   
   int cluster_counts[];
   double cluster_sums[];
   ArrayResize(cluster_counts, InpClusters);
   ArrayResize(cluster_sums, InpClusters);

   while(changed && iterations < InpMaxIter)
     {
      changed = false;
      ArrayInitialize(cluster_counts, 0);
      ArrayInitialize(cluster_sums, 0.0);
      
      // Assign points to nearest centroid
      for(int i = 0; i < InpLookback; i++)
        {
         int best_cluster = 0;
         double min_dist = 999999;
         
         for(int k = 0; k < InpClusters; k++)
           {
            double dist = MathAbs(data[i] - centroids[k]);
            if(dist < min_dist)
              {
               min_dist = dist;
               best_cluster = k;
              }
           }
           
         cluster_sums[best_cluster] += data[i];
         cluster_counts[best_cluster]++;
        }
        
      // Update Centroids
      for(int k = 0; k < InpClusters; k++)
        {
         if(cluster_counts[k] > 0)
           {
            double new_centroid = cluster_sums[k] / cluster_counts[k];
            if(MathAbs(new_centroid - centroids[k]) > _Point)
              {
               centroids[k] = new_centroid;
               changed = true;
              }
           }
        }
      iterations++;
     }

   // 4. Draw the Machine Learning Centroid Lines
   ObjectsDeleteAll(0, prefix);
   for(int k = 0; k < InpClusters; k++)
     {
      if(cluster_counts[k] > 0)
        {
         string name = prefix + IntegerToString(k);
         ObjectCreate(0, name, OBJ_HLINE, 0, 0, centroids[k]);
         ObjectSetInteger(0, name, OBJPROP_COLOR, InpLineColor);
         ObjectSetInteger(0, name, OBJPROP_STYLE, InpLineStyle);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+