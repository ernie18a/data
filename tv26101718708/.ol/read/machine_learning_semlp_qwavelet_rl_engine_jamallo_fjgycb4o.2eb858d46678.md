Calculation: Action scores = outputs of a 16→12→6→3 neural network with LeakyReLU hidden layers (negative values multiplied by 0.01), using z-scored level-1 and level-2 Haar details of open, close, volume, and their 5-bar and 10-bar simple moving averages, plus position and z-scored open-trade return.
Calculation: Selected action = previous action unless the highest action score is greater than the previous action’s score plus a threshold; otherwise select the highest-scoring action, resolving ties in order Buy, Sell, Hold.
Long: position is not long AND selected action is Buy
Short: position is not short AND selected action is Sell
Exit: long or short, selected action is Hold