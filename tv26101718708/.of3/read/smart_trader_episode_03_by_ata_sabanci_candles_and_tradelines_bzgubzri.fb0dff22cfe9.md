Calculation: BlockHigh(k) = Highest(high, G, R + k * G), where R is the reference bar offset, either the last completed bar or the bar still forming
Calculation: BlockLow(k) = Lowest(low, G, R + k * G)
Calculation: BlockMid(k) = (BlockHigh(k) + BlockLow(k)) / 2
Calculation: SegEnd = smallest k >= 1 with SIGN(BlockMid(k) - BlockMid(k + 1)) != SIGN(BlockMid(0) - BlockMid(1)), or the oldest block if no such k
Calculation: ExtremeSlope(S) = (S(kMax) - S(kMin)) / (G * (kMin - kMax)), where kMax and kMin are the blocks k from 0 through SegEnd at which S(k) is highest and lowest
Calculation: ChannelAngle = DEGREES(ATAN((ExtremeSlope(BlockHigh) + ExtremeSlope(BlockLow)) / 2 * SQRT(SegEnd * G) / (YangZhangVolatility(P) * close))), with YangZhangVolatility and close on the current bar
Long: BlockMid(0) > BlockMid(1) AND ABS(ChannelAngle) > T
Short: BlockMid(0) < BlockMid(1) AND ABS(ChannelAngle) > T