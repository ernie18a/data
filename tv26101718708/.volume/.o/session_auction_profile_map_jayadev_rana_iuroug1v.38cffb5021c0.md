Calculation: Initial balance high/low = highest high/lowest low during the session’s initial-balance period; after that period, track whether any bar’s high exceeded the initial balance high or any bar’s low fell below the initial balance low.
Calculation: Developing value area high/low = boundaries of the contiguous price bins around the session’s highest-volume bin that contain the selected percentage of profile volume; distribute each bar’s volume evenly across bins touched by its range, using a time count if volume is unavailable. Set bin width from ATR(14) at session open times the selected bin-size multiple.
Long: During the session, the initial balance is complete, its high has been exceeded, and its low has not been exceeded
Long: Close > developing value area high
Short: During the session, the initial balance is complete, its low has been exceeded, and its high has not been exceeded
Short: Close < developing value area low