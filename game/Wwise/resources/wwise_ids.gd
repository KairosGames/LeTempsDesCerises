class_name AK

class EVENTS:

	const BARRICADE_DAMAGED : int = 482738278
	const BRICK_FALL : int = 3840667520
	const CANNON_SHOOT : int = 2469499398
	const ENEMY_BULLET_MISS : int = 3787232089
	const ENEMY_SHOOT : int = 1050776119
	const ENEMY_STEPS : int = 3114531655
	const PLAYER_CROUCH : int = 3055475155
	const PLAYER_PRONE : int = 1806823001
	const PLAYER_SPRINT : int = 2500953213
	const PLAYER_UP : int = 4024398754
	const BULLET_HIT : int = 384143791
	const DEAFENING_RECOVER : int = 3687575925
	const PLAYER_ALIVE : int = 2917189548
	const PLAYER_DEATH : int = 3083087645
	const PLAYER_RELOAD : int = 1650679582
	const PLAYER_SHOOT : int = 4004702906
	const PLAYER_STEPS : int = 4272057794
	const RESET_RELOAD : int = 1795565902
	const AMB_CANNONS : int = 3265814676
	const ALLY_BARK : int = 3470134616
	const ALLY_BARK_ALLY_DEAD : int = 3295768610
	const ALLY_BARK_COWARD : int = 1318320503
	const ALLY_BARK_ENEMY_DEAD : int = 3598975830
	const ENEMY_BARK : int = 2802320212

class STATES:

	class BARKS_BARRICADE:
		const GROUP : int = 2280690262
	
		class STATE:
			const NONE : int = 748895195
			const BROKEN : int = 231230354
			const INTACT : int = 3094168564
			const LOW : int = 545371365

	class BARKS_PLAYER_DISTANCE:
		const GROUP : int = 4265991608
	
		class STATE:
			const NONE : int = 748895195
			const CLOSE : int = 1451272583
			const FAR : int = 1183803292

	class PLAYER_AIM:
		const GROUP : int = 1608601952
	
		class STATE:
			const NONE : int = 748895195
			const FALSE : int = 2452206122
			const TRUE : int = 3053630529

	class PLAYER_BREATH:
		const GROUP : int = 314259375
	
		class STATE:
			const NONE : int = 748895195
			const ANXIOUS : int = 3823044812
			const CALM : int = 3753286132

	class PLAYER_COVER:
		const GROUP : int = 219569822
	
		class STATE:
			const NONE : int = 748895195
			const COVERED : int = 2008504509
			const UNCOVERED : int = 2407602878

	class PLAYER_STANCE:
		const GROUP : int = 1343755517
	
		class STATE:
			const NONE : int = 748895195
			const CROUCH : int = 2655407367
			const PRONE : int = 1270007533
			const SPRINT : int = 1296465089
			const STAND : int = 1214700371


class SWITCHES:

	class ALLEGIANCE:
		const GROUP : int = 1922831386
	
		class SWITCH:
			const COMMUNARD : int = 149546059
			const VERSAILLAIS : int = 2495691590

	class CHARACTER_TYPE:
		const GROUP : int = 1117085073
	
		class SWITCH:
			const TYPE1 : int = 408582742
			const TYPE2 : int = 408582741

	class CLOTHING:
		const GROUP : int = 1334157877
	
		class SWITCH:
			const COAT : int = 3469052180

	class DEBRIS:
		const GROUP : int = 459611840
	
		class SWITCH:
			const FIRST : int = 998496889
			const SECOND : int = 3476314365

	class PLAYER_POSITION:
		const GROUP : int = 2221031936
	
		class SWITCH:
			const CROUCH : int = 2655407367
			const PRONE : int = 1270007533
			const UP : int = 1551306158

	class SURFACE:
		const GROUP : int = 1834394558
	
		class SWITCH:
			const BRICK : int = 504532776
			const GLASS : int = 2449969375
			const METAL : int = 2473969246
			const WOOD : int = 2058049674


class GAME_PARAMETERS:

	const CANNONS_PROBABILITY : int = 2576556105
	const DEAFENING : int = 711096812
	const DEATH_FILTER : int = 4205136178
	const DISTANCE : int = 1240670792
	const PLAYER_POSITION : int = 2221031936
	const PLAYER_VELOCITY : int = 1833811084
	const POETIC_LEVEL : int = 3680281974

class TRIGGERS:
	pass

class BANKS:

	const SB_AMB : int = 925885567
	const SB_CANNON : int = 2061449278
	const SB_ENEMY : int = 3827176343
	const SB_PLAYER : int = 2103316850

class AUX_BUSSES:

	const CROSSROAD_REVERB : int = 1865335600
	const REFLECT : int = 243379636
	const STREET_REVERB : int = 2635253023
	const WWISE_MOTION_SEND : int = 214837138

class ACOUSTIC_TEXTURES:

	const ACOUSTIC_BANNER : int = 4168643977
	const ANECHOIC : int = 1873957695
	const BRICK : int = 504532776
	const CARPET : int = 2412606308
	const CONCRETE : int = 841620460
	const CORK_TILES : int = 3195498748
	const CURTAINS : int = 2928161104
	const DRYWALL : int = 3670307564
	const FABRIC : int = 1970351858
	const MOUNTAIN : int = 513139656
	const TILE : int = 2637588553
	const WOOD : int = 2058049674
	const WOOD_BRIGHT : int = 4262522749
	const WOOD_DEEP : int = 1755085759

