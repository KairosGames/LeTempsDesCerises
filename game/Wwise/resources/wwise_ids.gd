class_name AK

class EVENTS:

	const MUSIC : int = 3991942870
	const ALLY_SHOOT : int = 3252427803
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
	const ALLY_ALLY_DEATH : int = 1707855831
	const ALLY_BARRICADE_STATE : int = 3014529809
	const ALLY_CANNON_ADVANCE : int = 535045682
	const ALLY_CANNON_FIRE : int = 413417616
	const ALLY_CANNON_INCOMING : int = 3186371416
	const ALLY_PLAYER_FAR : int = 1337332127
	const ALLY_PLAYER_HIDDEN : int = 1135788384
	const ALLY_PLAYER_KILL : int = 2988219764
	const ALLY_VOICE_CANCEL : int = 243533429
	const ENEMY_BARRICADE_STATE : int = 3457462997
	const ENEMY_CANNON_ADVANCE : int = 1807735670
	const ENEMY_CANNON_FIRE : int = 378772636
	const ENEMY_CANNON_INCOMING : int = 3891079404
	const ENEMY_VOICE_CANCEL : int = 2376509257
	const DIALOGUE : int = 3930136735

class STATES:

	class BARKS_PLAYER_DISTANCE:
		const GROUP : int = 4265991608
	
		class STATE:
			const NONE : int = 748895195
			const CLOSE : int = 1451272583
			const FAR : int = 1183803292

	class BARRICADE_STATE:
		const GROUP : int = 3394146252
	
		class STATE:
			const NONE : int = 748895195
			const BROKEN : int = 231230354
			const INTACT : int = 3094168564
			const LOW : int = 545371365

	class FIGHT_STATE:
		const GROUP : int = 1138488279
	
		class STATE:
			const NONE : int = 748895195
			const FIGHT : int = 514064485
			const RETREAT : int = 3967984634

	class NARRATIVE_STEP:
		const GROUP : int = 212893962
	
		class STATE:
			const NONE : int = 748895195
			const _0 : int = 846646256
			const _1 : int = 846646257
			const _10 : int = 1644366931
			const _11 : int = 1644366930
			const _12 : int = 1644366929
			const _13 : int = 1644366928
			const _14 : int = 1644366935
			const _15 : int = 1644366934
			const _16 : int = 1644366933
			const _17 : int = 1644366932
			const _18 : int = 1644366939
			const _19 : int = 1644366938
			const _2 : int = 846646258
			const _20 : int = 1661144518
			const _3 : int = 846646259
			const _4 : int = 846646260
			const _5 : int = 846646261
			const _6 : int = 846646262
			const _7 : int = 846646263
			const _8 : int = 846646264
			const _9 : int = 846646265

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

	class MUSIC_STATE:
		const GROUP : int = 3826569560
	
		class STATE:
			const NONE : int = 748895195
			const PHASE1 : int = 3630028971
			const PHASE2 : int = 3630028968
			const PHASE3 : int = 3630028969


class SWITCHES:

	class ALLEGIANCE:
		const GROUP : int = 1922831386
	
		class SWITCH:
			const COMMUNARD : int = 149546059
			const VERSAILLAIS : int = 2495691590

	class CHARACTER:
		const GROUP : int = 436743010
	
		class SWITCH:
			const FRANCOIS : int = 3484216754
			const GEORGES : int = 2519917785
			const JULES : int = 652153290
			const NULL : int = 784127654

	class CHARACTER_TYPE:
		const GROUP : int = 1117085073
	
		class SWITCH:
			const TYPE1 : int = 408582742
			const TYPE2 : int = 408582741
			const TYPE3 : int = 408582740
			const TYPE4 : int = 408582739
			const TYPE5 : int = 408582738
			const TYPE6 : int = 408582737

	class CLOTHING:
		const GROUP : int = 1334157877
	
		class SWITCH:
			const COAT : int = 3469052180

	class DEBRIS:
		const GROUP : int = 459611840
	
		class SWITCH:
			const FIRST : int = 998496889
			const SECOND : int = 3476314365

	class GENDER:
		const GROUP : int = 1776943274
	
		class SWITCH:
			const F : int = 84696441
			const M : int = 84696434

	class PLAYER_POSITION:
		const GROUP : int = 2221031936
	
		class SWITCH:
			const CROUCH : int = 2655407367
			const PRONE : int = 1270007533
			const UP : int = 1551306158

	class SHOE_TYPE:
		const GROUP : int = 3705103691
	
		class SWITCH:
			const CLOG_SHOES : int = 1672723819
			const HEELS : int = 2632515210
			const WORN_BOOTS : int = 755604413

	class SURFACE:
		const GROUP : int = 1834394558
	
		class SWITCH:
			const BRICK : int = 504532776
			const GLASS : int = 2449969375
			const METAL : int = 2473969246
			const WOOD : int = 2058049674

	class VOICE_SEL:
		const GROUP : int = 4244338540
	
		class SWITCH:
			const ACCORDEON : int = 840291561
			const G1 : int = 1786192857
			const G2 : int = 1786192858
			const G3 : int = 1786192859
			const GUIMBARDE : int = 697539359
			const GUITARE : int = 703172684
			const SIFFLEMENT : int = 1064071544
			const SOLO_ATEA : int = 2729355702
			const SOLO_HUGO : int = 1783951004
			const SOLO_WANIA : int = 739772697
			const SOLO_YDRIS : int = 3476834350
			const TAMBOUR : int = 3360712845
			const VIELE : int = 3603862282


class GAME_PARAMETERS:

	const BARK_VOLUME : int = 2103536148
	const CANNON_SIDECHAIN : int = 243460359
	const CANNONS_PROBABILITY : int = 2576556105
	const DEAFENING : int = 711096812
	const DEATH_FILTER : int = 4205136178
	const DISTANCE : int = 1240670792
	const PLAYER_POSITION : int = 2221031936
	const PLAYER_VELOCITY : int = 1833811084
	const POETIC_LEVEL : int = 3680281974
	const SIDECHAIN : int = 1883033791
	const CHOIR_VOLUME : int = 2909751391
	const ISPLAYING : int = 728654205

class TRIGGERS:
	pass

class BANKS:

	const FRANCOIS : int = 3484216754
	const GEORGES : int = 2519917785
	const JULES : int = 652153290
	const SB_AMB : int = 925885567
	const SB_CANNON : int = 2061449278
	const SB_NPC : int = 1278759826
	const SB_PLAYER : int = 2103316850
	const SB_MUSIC : int = 779753582

class AUX_BUSSES:

	const SFX_GUNSHOT_SEND : int = 3189108374
	const REFLECT : int = 243379636
	const STREET_REVERB : int = 2635253023
	const WWISE_MOTION_SEND : int = 214837138
	const MUSIC_REV : int = 2415077256

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

