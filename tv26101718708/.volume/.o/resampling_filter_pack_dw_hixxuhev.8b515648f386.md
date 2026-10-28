Calculation: Filter = Selected filter applied to the selected price source at each selected sample trigger; holds its value between triggers. Triggers are based on bar count, elapsed chart time, or price movement reaching a threshold.
Calculation: Filter direction = 1 when Filter > its prior-bar value; −1 when Filter < its prior-bar value; otherwise retain its prior value.
Long: Filter direction = 1 AND selected price source >= Filter
Short: Filter direction = −1 AND selected price source <= Filter