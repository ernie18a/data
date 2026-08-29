<!-- tradingview-pine-id: PUB;3aa7b0316fc0436098f2a7cc5446c00f -->
<!-- tradingviewscripts-format: 1 -->
# Daily Verse

Source: https://www.tradingview.com/script/NDuU8jta-Daily-Verse/

## Description

This script displays a bible verse about temptation, greed, and money.

---

## Source Code

````pine
//@version=6
// ============================================================================
//  Daily Verse — 6 categories x 40 passages, one per trading session.
//  Temptation · Money · Greed · Patience · Diligence · Fear
//  Verse text is King James Version (public domain).
//
//  Rotation is dayNum % 6 over trading sessions. 6 and 5 are coprime, so the
//  categories drift across weekdays on a 30-session cycle rather than locking
//  one category to one weekday (which is what 5 categories would have done).
// ============================================================================
indicator("Daily Verse", overlay = true)

NCATS = 6

// ─── Inputs ─────────────────────────────────────────────────────────────────
i_theme   = input.string("All", "Theme",
     options = ["All", "Temptation", "Money", "Greed", "Patience", "Diligence", "Fear"])
i_pos     = input.string("Top Right", "Position",
     options = ["Top Right", "Top Center", "Top Left", "Bottom Right", "Bottom Center", "Bottom Left"])
i_size    = input.string("normal", "Text Size", options = ["tiny", "small", "normal", "large"])
i_wrap    = input.int(48, "Wrap Width (chars)", minval = 20, maxval = 140)
i_guard   = input.int(25, "Guard Band %", minval = 0, maxval = 25,
     tooltip = "How much of each pass is protected from overlapping the previous pass. 25% is the max that still leaves room to swap.")
i_txtCol  = input.color(color.new(#D9D9D9, 0),  "Text Color",      group = "Style")
i_refCol  = input.color(color.new(#E8B54D, 0),  "Reference Color", group = "Style")
i_bgCol   = input.color(color.new(#000000, 80), "Background",      group = "Style")
i_showRef = input.bool(true,  "Show Reference",    group = "Style")
i_showPos = input.bool(false, "Show Pass Counter", group = "Style")
i_quotes  = input.bool(true,  "Wrap In Quotes",    group = "Style")
i_seed    = input.int(0, "Shuffle Seed", tooltip = "Change for a different shuffle of every pass.")

// ─── Verse data (KJV — public domain) ───────────────────────────────────────
// 0 Temptation · 1 Money · 2 Greed · 3 Patience · 4 Diligence · 5 Fear
var array<string> refs   = array.new<string>()
var array<string> verses = array.new<string>()
var array<int>    tids   = array.new<int>()

add(string r, string v, int t) =>
    array.push(refs, r)
    array.push(verses, v)
    array.push(tids, t)
    array.size(refs)

if array.size(tids) == 0
    // ══ Temptation (0) ══
    add("Matthew 26:41", "Watch and pray, that ye enter not into temptation: the spirit indeed is willing, but the flesh is weak.", 0)
    add("1 Corinthians 10:13", "There hath no temptation taken you but such as is common to man: but God is faithful, who will not suffer you to be tempted above that ye are able; but will with the temptation also make a way to escape, that ye may be able to bear it.", 0)
    add("1 Corinthians 10:12", "Wherefore let him that thinketh he standeth take heed lest he fall.", 0)
    add("James 1:12", "Blessed is the man that endureth temptation: for when he is tried, he shall receive the crown of life, which the Lord hath promised to them that love him.", 0)
    add("James 1:13", "Let no man say when he is tempted, I am tempted of God: for God cannot be tempted with evil, neither tempteth he any man.", 0)
    add("James 1:14-15", "But every man is tempted, when he is drawn away of his own lust, and enticed. Then when lust hath conceived, it bringeth forth sin: and sin, when it is finished, bringeth forth death.", 0)
    add("James 4:7", "Submit yourselves therefore to God. Resist the devil, and he will flee from you.", 0)
    add("Hebrews 4:15", "For we have not an high priest which cannot be touched with the feeling of our infirmities; but was in all points tempted like as we are, yet without sin.", 0)
    add("Hebrews 2:18", "For in that he himself hath suffered being tempted, he is able to succour them that are tempted.", 0)
    add("Hebrews 12:1", "Let us lay aside every weight, and the sin which doth so easily beset us, and let us run with patience the race that is set before us.", 0)
    add("1 Peter 5:8", "Be sober, be vigilant; because your adversary the devil, as a roaring lion, walketh about, seeking whom he may devour.", 0)
    add("1 Peter 5:9", "Whom resist stedfast in the faith, knowing that the same afflictions are accomplished in your brethren that are in the world.", 0)
    add("1 Peter 2:11", "Dearly beloved, I beseech you as strangers and pilgrims, abstain from fleshly lusts, which war against the soul.", 0)
    add("2 Peter 2:9", "The Lord knoweth how to deliver the godly out of temptations, and to reserve the unjust unto the day of judgment to be punished.", 0)
    add("Matthew 6:13", "And lead us not into temptation, but deliver us from evil: For thine is the kingdom, and the power, and the glory, for ever. Amen.", 0)
    add("Matthew 4:4", "It is written, Man shall not live by bread alone, but by every word that proceedeth out of the mouth of God.", 0)
    add("Matthew 4:7", "Jesus said unto him, It is written again, Thou shalt not tempt the Lord thy God.", 0)
    add("Matthew 4:10", "Then saith Jesus unto him, Get thee hence, Satan: for it is written, Thou shalt worship the Lord thy God, and him only shalt thou serve.", 0)
    add("Matthew 18:7", "Woe unto the world because of offences! for it must needs be that offences come; but woe to that man by whom the offence cometh!", 0)
    add("Luke 4:13", "And when the devil had ended all the temptation, he departed from him for a season.", 0)
    add("Luke 22:40", "And when he was at the place, he said unto them, Pray that ye enter not into temptation.", 0)
    add("Proverbs 1:10", "My son, if sinners entice thee, consent thou not.", 0)
    add("Proverbs 4:14-15", "Enter not into the path of the wicked, and go not in the way of evil men. Avoid it, pass not by it, turn from it, and pass away.", 0)
    add("Proverbs 6:27", "Can a man take fire in his bosom, and his clothes not be burned?", 0)
    add("Proverbs 16:18", "Pride goeth before destruction, and an haughty spirit before a fall.", 0)
    add("Proverbs 28:26", "He that trusteth in his own heart is a fool: but whoso walketh wisely, he shall be delivered.", 0)
    add("Genesis 4:7", "If thou doest well, shalt thou not be accepted? and if thou doest not well, sin lieth at the door. And unto thee shall be his desire, and thou shalt rule over him.", 0)
    add("Psalm 119:11", "Thy word have I hid in mine heart, that I might not sin against thee.", 0)
    add("Psalm 141:4", "Incline not my heart to any evil thing, to practise wicked works with men that work iniquity: and let me not eat of their dainties.", 0)
    add("Job 31:1", "I made a covenant with mine eyes; why then should I think upon a maid?", 0)
    add("1 John 2:16", "For all that is in the world, the lust of the flesh, and the lust of the eyes, and the pride of life, is not of the Father, but is of the world.", 0)
    add("Galatians 5:16", "This I say then, Walk in the Spirit, and ye shall not fulfil the lust of the flesh.", 0)
    add("Galatians 6:1", "Brethren, if a man be overtaken in a fault, ye which are spiritual, restore such an one in the spirit of meekness; considering thyself, lest thou also be tempted.", 0)
    add("Romans 13:14", "But put ye on the Lord Jesus Christ, and make not provision for the flesh, to fulfil the lusts thereof.", 0)
    add("Romans 6:12", "Let not sin therefore reign in your mortal body, that ye should obey it in the lusts thereof.", 0)
    add("2 Timothy 2:22", "Flee also youthful lusts: but follow righteousness, faith, charity, peace, with them that call on the Lord out of a pure heart.", 0)
    add("Ephesians 6:11", "Put on the whole armour of God, that ye may be able to stand against the wiles of the devil.", 0)
    add("1 Thessalonians 5:22", "Abstain from all appearance of evil.", 0)
    add("2 Corinthians 10:5", "Casting down imaginations, and every high thing that exalteth itself against the knowledge of God, and bringing into captivity every thought to the obedience of Christ.", 0)
    add("Revelation 3:10", "Because thou hast kept the word of my patience, I also will keep thee from the hour of temptation, which shall come upon all the world, to try them that dwell upon the earth.", 0)

if array.size(tids) == 40
    // ══ Money (1) ══
    add("Matthew 6:24", "No man can serve two masters: for either he will hate the one, and love the other; or else he will hold to the one, and despise the other. Ye cannot serve God and mammon.", 1)
    add("Matthew 6:19", "Lay not up for yourselves treasures upon earth, where moth and rust doth corrupt, and where thieves break through and steal.", 1)
    add("Matthew 6:20", "But lay up for yourselves treasures in heaven, where neither moth nor rust doth corrupt, and where thieves do not break through nor steal.", 1)
    add("Matthew 6:21", "For where your treasure is, there will your heart be also.", 1)
    add("Matthew 6:33", "But seek ye first the kingdom of God, and his righteousness; and all these things shall be added unto you.", 1)
    add("1 Timothy 6:10", "For the love of money is the root of all evil: which while some coveted after, they have erred from the faith, and pierced themselves through with many sorrows.", 1)
    add("1 Timothy 5:8", "But if any provide not for his own, and specially for those of his own house, he hath denied the faith, and is worse than an infidel.", 1)
    add("Hebrews 13:5", "Let your conversation be without covetousness; and be content with such things as ye have: for he hath said, I will never leave thee, nor forsake thee.", 1)
    add("Proverbs 22:7", "The rich ruleth over the poor, and the borrower is servant to the lender.", 1)
    add("Proverbs 22:1", "A good name is rather to be chosen than great riches, and loving favour rather than silver and gold.", 1)
    add("Proverbs 3:9-10", "Honour the LORD with thy substance, and with the firstfruits of all thine increase: so shall thy barns be filled with plenty, and thy presses shall burst out with new wine.", 1)
    add("Proverbs 3:27", "Withhold not good from them to whom it is due, when it is in the power of thine hand to do it.", 1)
    add("Malachi 3:10", "Bring ye all the tithes into the storehouse, and prove me now herewith, saith the LORD of hosts, if I will not open you the windows of heaven, and pour you out a blessing, that there shall not be room enough to receive it.", 1)
    add("Malachi 3:8", "Will a man rob God? Yet ye have robbed me. But ye say, Wherein have we robbed thee? In tithes and offerings.", 1)
    add("2 Corinthians 9:7", "Every man according as he purposeth in his heart, so let him give; not grudgingly, or of necessity: for God loveth a cheerful giver.", 1)
    add("2 Corinthians 9:6", "He which soweth sparingly shall reap also sparingly; and he which soweth bountifully shall reap also bountifully.", 1)
    add("Ecclesiastes 5:10", "He that loveth silver shall not be satisfied with silver; nor he that loveth abundance with increase: this is also vanity.", 1)
    add("Luke 16:10", "He that is faithful in that which is least is faithful also in much: and he that is unjust in the least is unjust also in much.", 1)
    add("Luke 16:11", "If therefore ye have not been faithful in the unrighteous mammon, who will commit to your trust the true riches?", 1)
    add("Luke 14:28", "For which of you, intending to build a tower, sitteth not down first, and counteth the cost, whether he have sufficient to finish it?", 1)
    add("Luke 6:38", "Give, and it shall be given unto you; good measure, pressed down, and shaken together, and running over, shall men give into your bosom.", 1)
    add("Proverbs 13:11", "Wealth gotten by vanity shall be diminished: but he that gathereth by labour shall increase.", 1)
    add("Proverbs 13:22", "A good man leaveth an inheritance to his children's children: and the wealth of the sinner is laid up for the just.", 1)
    add("Proverbs 21:5", "The thoughts of the diligent tend only to plenteousness; but of every one that is hasty only to want.", 1)
    add("Proverbs 21:20", "There is treasure to be desired and oil in the dwelling of the wise; but a foolish man spendeth it up.", 1)
    add("Proverbs 10:4", "He becometh poor that dealeth with a slack hand: but the hand of the diligent maketh rich.", 1)
    add("Proverbs 11:24", "There is that scattereth, and yet increaseth; and there is that withholdeth more than is meet, but it tendeth to poverty.", 1)
    add("Proverbs 11:25", "The liberal soul shall be made fat: and he that watereth shall be watered also himself.", 1)
    add("Proverbs 11:1", "A false balance is abomination to the LORD: but a just weight is his delight.", 1)
    add("Proverbs 19:17", "He that hath pity upon the poor lendeth unto the LORD; and that which he hath given will he pay him again.", 1)
    add("Proverbs 27:23-24", "Be thou diligent to know the state of thy flocks, and look well to thy herds. For riches are not for ever: and doth the crown endure to every generation?", 1)
    add("Proverbs 28:19", "He that tilleth his land shall have plenty of bread: but he that followeth after vain persons shall have poverty enough.", 1)
    add("Proverbs 30:8-9", "Give me neither poverty nor riches; feed me with food convenient for me: lest I be full, and deny thee, and say, Who is the LORD? or lest I be poor, and steal, and take the name of my God in vain.", 1)
    add("Deuteronomy 8:18", "But thou shalt remember the LORD thy God: for it is he that giveth thee power to get wealth.", 1)
    add("Psalm 24:1", "The earth is the LORD's, and the fulness thereof; the world, and they that dwell therein.", 1)
    add("Haggai 2:8", "The silver is mine, and the gold is mine, saith the LORD of hosts.", 1)
    add("Romans 13:8", "Owe no man any thing, but to love one another: for he that loveth another hath fulfilled the law.", 1)
    add("Ephesians 4:28", "Let him that stole steal no more: but rather let him labour, working with his hands the thing which is good, that he may have to give to him that needeth.", 1)
    add("2 Thessalonians 3:10", "For even when we were with you, this we commanded you, that if any would not work, neither should he eat.", 1)
    add("Philippians 4:19", "But my God shall supply all your need according to his riches in glory by Christ Jesus.", 1)

if array.size(tids) == 80
    // ══ Greed (2) ══
    add("Luke 12:15", "Take heed, and beware of covetousness: for a man's life consisteth not in the abundance of the things which he possesseth.", 2)
    add("Luke 12:20", "But God said unto him, Thou fool, this night thy soul shall be required of thee: then whose shall those things be, which thou hast provided?", 2)
    add("Luke 12:33", "Sell that ye have, and give alms; provide yourselves bags which wax not old, a treasure in the heavens that faileth not.", 2)
    add("Luke 16:14", "And the Pharisees also, who were covetous, heard all these things: and they derided him.", 2)
    add("Proverbs 15:27", "He that is greedy of gain troubleth his own house; but he that hateth gifts shall live.", 2)
    add("Proverbs 28:20", "A faithful man shall abound with blessings: but he that maketh haste to be rich shall not be innocent.", 2)
    add("Proverbs 28:22", "He that hasteth to be rich hath an evil eye, and considereth not that poverty shall come upon him.", 2)
    add("Proverbs 1:19", "So are the ways of every one that is greedy of gain; which taketh away the life of the owners thereof.", 2)
    add("Proverbs 11:28", "He that trusteth in his riches shall fall: but the righteous shall flourish as a branch.", 2)
    add("Proverbs 11:26", "He that withholdeth corn, the people shall curse him: but blessing shall be upon the head of him that selleth it.", 2)
    add("Proverbs 21:26", "He coveteth greedily all the day long: but the righteous giveth and spareth not.", 2)
    add("Proverbs 22:16", "He that oppresseth the poor to increase his riches, and he that giveth to the rich, shall surely come to want.", 2)
    add("Proverbs 23:4", "Labour not to be rich: cease from thine own wisdom.", 2)
    add("Proverbs 23:5", "Wilt thou set thine eyes upon that which is not? for riches certainly make themselves wings; they fly away as an eagle toward heaven.", 2)
    add("Proverbs 27:20", "Hell and destruction are never full; so the eyes of man are never satisfied.", 2)
    add("Proverbs 30:15", "The horseleach hath two daughters, crying, Give, give.", 2)
    add("Proverbs 16:8", "Better is a little with righteousness than great revenues without right.", 2)
    add("Proverbs 15:16", "Better is little with the fear of the LORD than great treasure and trouble therewith.", 2)
    add("Exodus 20:17", "Thou shalt not covet thy neighbour's house, thou shalt not covet thy neighbour's wife, nor his manservant, nor his maidservant, nor his ox, nor his ass, nor any thing that is thy neighbour's.", 2)
    add("Colossians 3:5", "Mortify therefore your members which are upon the earth; inordinate affection, evil concupiscence, and covetousness, which is idolatry.", 2)
    add("1 Timothy 6:6-8", "But godliness with contentment is great gain. For we brought nothing into this world, and it is certain we can carry nothing out. And having food and raiment let us be therewith content.", 2)
    add("1 Timothy 6:17", "Charge them that are rich in this world, that they be not highminded, nor trust in uncertain riches, but in the living God, who giveth us richly all things to enjoy.", 2)
    add("1 Timothy 6:18", "That they do good, that they be rich in good works, ready to distribute, willing to communicate.", 2)
    add("Mark 8:36", "For what shall it profit a man, if he shall gain the whole world, and lose his own soul?", 2)
    add("Matthew 19:24", "It is easier for a camel to go through the eye of a needle, than for a rich man to enter into the kingdom of God.", 2)
    add("Matthew 23:25", "Ye make clean the outside of the cup and of the platter, but within they are full of extortion and excess.", 2)
    add("James 5:1", "Go to now, ye rich men, weep and howl for your miseries that shall come upon you.", 2)
    add("James 5:3", "Your gold and silver is cankered; and the rust of them shall be a witness against you, and shall eat your flesh as it were fire.", 2)
    add("James 4:2", "Ye lust, and have not: ye kill, and desire to have, and cannot obtain: ye fight and war, yet ye have not, because ye ask not.", 2)
    add("James 4:3", "Ye ask, and receive not, because ye ask amiss, that ye may consume it upon your lusts.", 2)
    add("Ecclesiastes 5:11", "When goods increase, they are increased that eat them: and what good is there to the owners thereof, saving the beholding of them with their eyes?", 2)
    add("Ecclesiastes 5:13", "There is a sore evil which I have seen under the sun, namely, riches kept for the owners thereof to their hurt.", 2)
    add("Ecclesiastes 5:15", "As he came forth of his mother's womb, naked shall he return to go as he came, and shall take nothing of his labour, which he may carry away in his hand.", 2)
    add("Ecclesiastes 4:8", "There is one alone, and there is not a second; yet is there no end of all his labour; neither is his eye satisfied with riches.", 2)
    add("Psalm 62:10", "Trust not in oppression, and become not vain in robbery: if riches increase, set not your heart upon them.", 2)
    add("Psalm 37:16", "A little that a righteous man hath is better than the riches of many wicked.", 2)
    add("Micah 2:2", "And they covet fields, and take them by violence; and houses, and take them away: so they oppress a man and his house.", 2)
    add("Jeremiah 17:11", "As the partridge sitteth on eggs, and hatcheth them not; so he that getteth riches, and not by right, shall leave them in the midst of his days, and at his end shall be a fool.", 2)
    add("Acts 8:20", "Thy money perish with thee, because thou hast thought that the gift of God may be purchased with money.", 2)
    add("1 John 3:17", "But whoso hath this world's good, and seeth his brother have need, and shutteth up his bowels of compassion from him, how dwelleth the love of God in him?", 2)

if array.size(tids) == 120
    // ══ Patience (3) ══
    add("James 1:3", "Knowing this, that the trying of your faith worketh patience.", 3)
    add("James 1:4", "But let patience have her perfect work, that ye may be perfect and entire, wanting nothing.", 3)
    add("James 5:7", "Be patient therefore, brethren, unto the coming of the Lord. Behold, the husbandman waiteth for the precious fruit of the earth, and hath long patience for it, until he receive the early and latter rain.", 3)
    add("James 5:8", "Be ye also patient; stablish your hearts: for the coming of the Lord draweth nigh.", 3)
    add("James 5:11", "Behold, we count them happy which endure. Ye have heard of the patience of Job, and have seen the end of the Lord.", 3)
    add("Romans 5:3-4", "Tribulation worketh patience; and patience, experience; and experience, hope.", 3)
    add("Romans 8:25", "But if we hope for that we see not, then do we with patience wait for it.", 3)
    add("Romans 12:12", "Rejoicing in hope; patient in tribulation; continuing instant in prayer.", 3)
    add("Romans 15:4", "That we through patience and comfort of the scriptures might have hope.", 3)
    add("Romans 2:7", "To them who by patient continuance in well doing seek for glory and honour and immortality, eternal life.", 3)
    add("Galatians 6:9", "And let us not be weary in well doing: for in due season we shall reap, if we faint not.", 3)
    add("Galatians 5:22", "But the fruit of the Spirit is love, joy, peace, longsuffering, gentleness, goodness, faith.", 3)
    add("Hebrews 6:12", "That ye be not slothful, but followers of them who through faith and patience inherit the promises.", 3)
    add("Hebrews 6:15", "And so, after he had patiently endured, he obtained the promise.", 3)
    add("Hebrews 10:36", "For ye have need of patience, that, after ye have done the will of God, ye might receive the promise.", 3)
    add("Psalm 27:14", "Wait on the LORD: be of good courage, and he shall strengthen thine heart: wait, I say, on the LORD.", 3)
    add("Psalm 37:7", "Rest in the LORD, and wait patiently for him: fret not thyself because of him who prospereth in his way.", 3)
    add("Psalm 40:1", "I waited patiently for the LORD; and he inclined unto me, and heard my cry.", 3)
    add("Psalm 62:5", "My soul, wait thou only upon God; for my expectation is from him.", 3)
    add("Psalm 130:5", "I wait for the LORD, my soul doth wait, and in his word do I hope.", 3)
    add("Psalm 33:20", "Our soul waiteth for the LORD: he is our help and our shield.", 3)
    add("Isaiah 40:31", "But they that wait upon the LORD shall renew their strength; they shall mount up with wings as eagles; they shall run, and not be weary; and they shall walk, and not faint.", 3)
    add("Isaiah 28:16", "He that believeth shall not make haste.", 3)
    add("Isaiah 30:18", "And therefore will the LORD wait, that he may be gracious unto you: blessed are all they that wait for him.", 3)
    add("Lamentations 3:25", "The LORD is good unto them that wait for him, to the soul that seeketh him.", 3)
    add("Lamentations 3:26", "It is good that a man should both hope and quietly wait for the salvation of the LORD.", 3)
    add("Habakkuk 2:3", "For the vision is yet for an appointed time, but at the end it shall speak, and not lie: though it tarry, wait for it; because it will surely come, it will not tarry.", 3)
    add("Micah 7:7", "Therefore I will look unto the LORD; I will wait for the God of my salvation: my God will hear me.", 3)
    add("Ecclesiastes 7:8", "Better is the end of a thing than the beginning thereof: and the patient in spirit is better than the proud in spirit.", 3)
    add("Ecclesiastes 3:1", "To every thing there is a season, and a time to every purpose under the heaven.", 3)
    add("Proverbs 14:29", "He that is slow to wrath is of great understanding: but he that is hasty of spirit exalteth folly.", 3)
    add("Proverbs 15:18", "A wrathful man stirreth up strife: but he that is slow to anger appeaseth strife.", 3)
    add("Proverbs 16:32", "He that is slow to anger is better than the mighty; and he that ruleth his spirit than he that taketh a city.", 3)
    add("Proverbs 19:11", "The discretion of a man deferreth his anger; and it is his glory to pass over a transgression.", 3)
    add("Proverbs 19:2", "He that hasteth with his feet sinneth.", 3)
    add("Proverbs 25:15", "By long forbearing is a prince persuaded, and a soft tongue breaketh the bone.", 3)
    add("Colossians 1:11", "Strengthened with all might, according to his glorious power, unto all patience and longsuffering with joyfulness.", 3)
    add("Ephesians 4:2", "With all lowliness and meekness, with longsuffering, forbearing one another in love.", 3)
    add("Luke 21:19", "In your patience possess ye your souls.", 3)
    add("2 Peter 3:9", "The Lord is not slack concerning his promise, as some men count slackness; but is longsuffering to us-ward.", 3)

if array.size(tids) == 160
    // ══ Diligence (4) ══
    add("Proverbs 6:6", "Go to the ant, thou sluggard; consider her ways, and be wise.", 4)
    add("Proverbs 6:9", "How long wilt thou sleep, O sluggard? when wilt thou arise out of thy sleep?", 4)
    add("Proverbs 6:10-11", "Yet a little sleep, a little slumber, a little folding of the hands to sleep: so shall thy poverty come as one that travelleth, and thy want as an armed man.", 4)
    add("Proverbs 12:24", "The hand of the diligent shall bear rule: but the slothful shall be under tribute.", 4)
    add("Proverbs 12:27", "The slothful man roasteth not that which he took in hunting: but the substance of a diligent man is precious.", 4)
    add("Proverbs 12:11", "He that tilleth his land shall be satisfied with bread: but he that followeth vain persons is void of understanding.", 4)
    add("Proverbs 13:4", "The soul of the sluggard desireth, and hath nothing: but the soul of the diligent shall be made fat.", 4)
    add("Proverbs 14:23", "In all labour there is profit: but the talk of the lips tendeth only to penury.", 4)
    add("Proverbs 18:9", "He also that is slothful in his work is brother to him that is a great waster.", 4)
    add("Proverbs 20:4", "The sluggard will not plow by reason of the cold; therefore shall he beg in harvest, and have nothing.", 4)
    add("Proverbs 20:13", "Love not sleep, lest thou come to poverty; open thine eyes, and thou shalt be satisfied with bread.", 4)
    add("Proverbs 22:29", "Seest thou a man diligent in his business? he shall stand before kings; he shall not stand before mean men.", 4)
    add("Proverbs 24:27", "Prepare thy work without, and make it fit for thyself in the field; and afterwards build thine house.", 4)
    add("Proverbs 24:30-31", "I went by the field of the slothful, and by the vineyard of the man void of understanding; and, lo, it was all grown over with thorns.", 4)
    add("Proverbs 26:13", "The slothful man saith, There is a lion in the way; a lion is in the streets.", 4)
    add("Proverbs 26:14", "As the door turneth upon his hinges, so doth the slothful upon his bed.", 4)
    add("Proverbs 27:18", "Whoso keepeth the fig tree shall eat the fruit thereof: so he that waiteth on his master shall be honoured.", 4)
    add("Proverbs 4:23", "Keep thy heart with all diligence; for out of it are the issues of life.", 4)
    add("Proverbs 10:5", "He that gathereth in summer is a wise son: but he that sleepeth in harvest is a son that causeth shame.", 4)
    add("Proverbs 16:3", "Commit thy works unto the LORD, and thy thoughts shall be established.", 4)
    add("Proverbs 16:9", "A man's heart deviseth his way: but the LORD directeth his steps.", 4)
    add("Proverbs 21:31", "The horse is prepared against the day of battle: but safety is of the LORD.", 4)
    add("Ecclesiastes 9:10", "Whatsoever thy hand findeth to do, do it with thy might.", 4)
    add("Ecclesiastes 11:4", "He that observeth the wind shall not sow; and he that regardeth the clouds shall not reap.", 4)
    add("Ecclesiastes 11:6", "In the morning sow thy seed, and in the evening withhold not thine hand: for thou knowest not whether shall prosper, either this or that.", 4)
    add("Ecclesiastes 3:22", "There is nothing better, than that a man should rejoice in his own works; for that is his portion.", 4)
    add("Colossians 3:23", "And whatsoever ye do, do it heartily, as to the Lord, and not unto men.", 4)
    add("Colossians 3:24", "Knowing that of the Lord ye shall receive the reward of the inheritance: for ye serve the Lord Christ.", 4)
    add("1 Corinthians 15:58", "Be ye stedfast, unmoveable, always abounding in the work of the Lord, forasmuch as ye know that your labour is not in vain in the Lord.", 4)
    add("1 Corinthians 9:24", "Know ye not that they which run in a race run all, but one receiveth the prize? So run, that ye may obtain.", 4)
    add("1 Corinthians 9:27", "But I keep under my body, and bring it into subjection.", 4)
    add("Galatians 6:4", "But let every man prove his own work, and then shall he have rejoicing in himself alone, and not in another.", 4)
    add("Galatians 6:5", "For every man shall bear his own burden.", 4)
    add("1 Thessalonians 4:11", "And that ye study to be quiet, and to do your own business, and to work with your own hands.", 4)
    add("2 Timothy 2:15", "Study to shew thyself approved unto God, a workman that needeth not to be ashamed.", 4)
    add("2 Timothy 2:5", "And if a man also strive for masteries, yet is he not crowned, except he strive lawfully.", 4)
    add("Romans 12:11", "Not slothful in business; fervent in spirit; serving the Lord.", 4)
    add("Hebrews 6:11", "And we desire that every one of you do shew the same diligence to the full assurance of hope unto the end.", 4)
    add("2 Peter 1:5", "And beside this, giving all diligence, add to your faith virtue; and to virtue knowledge.", 4)
    add("Nehemiah 6:3", "I am doing a great work, so that I cannot come down.", 4)

if array.size(tids) == 200
    // ══ Fear (5) ══
    add("Isaiah 41:10", "Fear thou not; for I am with thee: be not dismayed; for I am thy God: I will strengthen thee; yea, I will help thee; yea, I will uphold thee with the right hand of my righteousness.", 5)
    add("Isaiah 41:13", "For I the LORD thy God will hold thy right hand, saying unto thee, Fear not; I will help thee.", 5)
    add("Isaiah 43:1", "Fear not: for I have redeemed thee, I have called thee by thy name; thou art mine.", 5)
    add("Isaiah 43:2", "When thou passest through the waters, I will be with thee; and through the rivers, they shall not overflow thee.", 5)
    add("Isaiah 26:3", "Thou wilt keep him in perfect peace, whose mind is stayed on thee: because he trusteth in thee.", 5)
    add("Isaiah 35:4", "Say to them that are of a fearful heart, Be strong, fear not: behold, your God will come.", 5)
    add("Isaiah 12:2", "Behold, God is my salvation; I will trust, and not be afraid.", 5)
    add("Joshua 1:9", "Be strong and of a good courage; be not afraid, neither be thou dismayed: for the LORD thy God is with thee whithersoever thou goest.", 5)
    add("Deuteronomy 31:6", "Be strong and of a good courage, fear not, nor be afraid of them: for the LORD thy God, he it is that doth go with thee; he will not fail thee, nor forsake thee.", 5)
    add("Psalm 23:4", "Yea, though I walk through the valley of the shadow of death, I will fear no evil: for thou art with me.", 5)
    add("Psalm 27:1", "The LORD is my light and my salvation; whom shall I fear? the LORD is the strength of my life; of whom shall I be afraid?", 5)
    add("Psalm 34:4", "I sought the LORD, and he heard me, and delivered me from all my fears.", 5)
    add("Psalm 46:1", "God is our refuge and strength, a very present help in trouble.", 5)
    add("Psalm 46:10", "Be still, and know that I am God.", 5)
    add("Psalm 56:3", "What time I am afraid, I will trust in thee.", 5)
    add("Psalm 55:22", "Cast thy burden upon the LORD, and he shall sustain thee: he shall never suffer the righteous to be moved.", 5)
    add("Psalm 94:19", "In the multitude of my thoughts within me thy comforts delight my soul.", 5)
    add("Psalm 118:6", "The LORD is on my side; I will not fear: what can man do unto me?", 5)
    add("Psalm 112:7", "He shall not be afraid of evil tidings: his heart is fixed, trusting in the LORD.", 5)
    add("Psalm 121:1-2", "I will lift up mine eyes unto the hills, from whence cometh my help. My help cometh from the LORD, which made heaven and earth.", 5)
    add("Psalm 91:5", "Thou shalt not be afraid for the terror by night; nor for the arrow that flieth by day.", 5)
    add("Psalm 4:8", "I will both lay me down in peace, and sleep: for thou, LORD, only makest me dwell in safety.", 5)
    add("Matthew 6:25", "Take no thought for your life, what ye shall eat, or what ye shall drink; nor yet for your body, what ye shall put on.", 5)
    add("Matthew 6:27", "Which of you by taking thought can add one cubit unto his stature?", 5)
    add("Matthew 6:34", "Take therefore no thought for the morrow: for the morrow shall take thought for the things of itself. Sufficient unto the day is the evil thereof.", 5)
    add("Luke 12:32", "Fear not, little flock; for it is your Father's good pleasure to give you the kingdom.", 5)
    add("John 14:27", "Peace I leave with you, my peace I give unto you: not as the world giveth, give I unto you. Let not your heart be troubled, neither let it be afraid.", 5)
    add("John 16:33", "In the world ye shall have tribulation: but be of good cheer; I have overcome the world.", 5)
    add("Mark 4:40", "And he said unto them, Why are ye so fearful? how is it that ye have no faith?", 5)
    add("Philippians 4:6", "Be careful for nothing; but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God.", 5)
    add("Philippians 4:7", "And the peace of God, which passeth all understanding, shall keep your hearts and minds through Christ Jesus.", 5)
    add("1 Peter 5:7", "Casting all your care upon him; for he careth for you.", 5)
    add("2 Timothy 1:7", "For God hath not given us the spirit of fear; but of power, and of love, and of a sound mind.", 5)
    add("Proverbs 3:5-6", "Trust in the LORD with all thine heart; and lean not unto thine own understanding. In all thy ways acknowledge him, and he shall direct thy paths.", 5)
    add("Proverbs 3:25", "Be not afraid of sudden fear, neither of the desolation of the wicked, when it cometh.", 5)
    add("Proverbs 12:25", "Heaviness in the heart of man maketh it stoop: but a good word maketh it glad.", 5)
    add("Proverbs 29:25", "The fear of man bringeth a snare: but whoso putteth his trust in the LORD shall be safe.", 5)
    add("Romans 8:31", "If God be for us, who can be against us?", 5)
    add("Hebrews 13:6", "The Lord is my helper, and I will not fear what man shall do unto me.", 5)
    add("Nahum 1:7", "The LORD is good, a strong hold in the day of trouble; and he knoweth them that trust in him.", 5)

// ─── Buckets (built once, so no function ever takes a series category) ──────
var array<int> b0 = array.new<int>()
var array<int> b1 = array.new<int>()
var array<int> b2 = array.new<int>()
var array<int> b3 = array.new<int>()
var array<int> b4 = array.new<int>()
var array<int> b5 = array.new<int>()

if array.size(b0) == 0 and array.size(tids) > 0
    for i = 0 to array.size(tids) - 1
        int th = array.get(tids, i)
        if th == 0
            array.push(b0, i)
        else if th == 1
            array.push(b1, i)
        else if th == 2
            array.push(b2, i)
        else if th == 3
            array.push(b3, i)
        else if th == 4
            array.push(b4, i)
        else
            array.push(b5, i)

// ─── Scheduling ─────────────────────────────────────────────────────────────
shuffleArr(array<int> a, int seed) =>
    int n = array.size(a)
    if n > 1
        int s = math.abs(seed % 2147483647) + 1
        for i = n - 1 to 1
            s := (s * 1103515245 + 12345) % 2147483648
            int j   = s % (i + 1)
            int tmp = array.get(a, i)
            array.set(a, i, array.get(a, j))
            array.set(a, j, tmp)

inTail(array<int> arr, int val, int g) =>
    int  n   = array.size(arr)
    int  st  = n - g < 0 ? 0 : n - g
    bool hit = false
    for k = st to n - 1
        if array.get(arr, k) == val
            hit := true
            break
    hit

// One full pass through a bucket. Opening slots are swapped clear of whatever
// closed the previous pass; swaps only touch the middle, so the previous
// pass's tail is exactly what the raw shuffle produced.
passOrder(array<int> bucket, int pass, int tid) =>
    array<int> ord  = array.copy(bucket)
    array<int> prev = array.copy(bucket)
    shuffleArr(ord,  pass * 1000 + tid + i_seed)
    shuffleArr(prev, (pass - 1) * 1000 + tid + i_seed)

    int n = array.size(ord)
    int g = math.min(n * i_guard / 100, n / 4)
    if g > 0 and n > 2 * g
        for i = 0 to g - 1
            if inTail(prev, array.get(ord, i), g)
                for j = g to n - g - 1
                    if not inTail(prev, array.get(ord, j), g)
                        int tmp = array.get(ord, i)
                        array.set(ord, i, array.get(ord, j))
                        array.set(ord, j, tmp)
                        break
    ord

// ─── Display helpers ────────────────────────────────────────────────────────
wrapText(string s, int width) =>
    array<string> words = str.split(s, " ")
    string out  = ""
    string line = ""
    for i = 0 to array.size(words) - 1
        string w    = array.get(words, i)
        string cand = line == "" ? w : line + " " + w
        if str.length(cand) > width and line != ""
            out  := out == "" ? line : out + "\n" + line
            line := w
        else
            line := cand
    out := out == "" ? line : out + "\n" + line
    out

tablePos() =>
    switch i_pos
        "Top Right"     => position.top_right
        "Top Center"    => position.top_center
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Center" => position.bottom_center
        => position.bottom_left

textSize() =>
    switch i_size
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        => size.normal

themeName(int t) =>
    switch t
        0 => "Temptation"
        1 => "Money"
        2 => "Greed"
        3 => "Patience"
        4 => "Diligence"
        => "Fear"

// ─── Build & draw ───────────────────────────────────────────────────────────
// Trading-day counter: Sat/Sun fold onto Friday so consecutive sessions differ
// by exactly one and the weekend doesn't burn draws nobody sees.
int rawDay = timestamp(year, month, dayofmonth, 0, 0) / 86400000
int k      = rawDay - 4              // 1970-01-05 was a Monday
int dow    = k % 7                   // 0 = Mon ... 6 = Sun
int dayNum = (k / 7) * 5 + math.min(dow, 4)

var table t = table.new(tablePos(), 1, 2, bgcolor = i_bgCol, border_width = 0, frame_width = 0)

if barstate.islast and array.size(verses) > 0
    int tid = i_theme == "Temptation" ? 0 :
             i_theme == "Money"      ? 1 :
             i_theme == "Greed"      ? 2 :
             i_theme == "Patience"   ? 3 :
             i_theme == "Diligence"  ? 4 :
             i_theme == "Fear"       ? 5 : dayNum % NCATS
    int occ = i_theme == "All" ? dayNum / NCATS : dayNum

    array<int> bucket = tid == 0 ? b0 : tid == 1 ? b1 : tid == 2 ? b2 : tid == 3 ? b3 : tid == 4 ? b4 : b5
    int n   = array.size(bucket)
    int pos = n > 0 ? occ % n : 0
    array<int> ord = passOrder(bucket, n > 0 ? occ / n : 0, tid)
    int idx = array.size(ord) > pos ? array.get(ord, pos) : 0

    string q    = i_quotes ? '"' : ""
    string foot = i_showRef ? "— " + array.get(refs, idx) + " (KJV)" : ""
    if i_showPos
        foot := foot + (foot == "" ? "" : " · ") + themeName(tid) + " " + str.tostring(pos + 1) + "/" + str.tostring(n)

    table.cell(t, 0, 0, q + wrapText(array.get(verses, idx), i_wrap) + q,
         text_color = i_txtCol, bgcolor = i_bgCol, text_size = textSize(), text_halign = text.align_left)
    table.cell(t, 0, 1, foot,
         text_color = i_refCol, bgcolor = i_bgCol, text_size = textSize(), text_halign = text.align_right)
````
