/////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Audiokinetic Wwise generated include file. Do not edit.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef __WWISE_IDS_H__
#define __WWISE_IDS_H__

#include <AK/SoundEngine/Common/AkTypes.h>

namespace AK
{
    namespace EVENTS
    {
        static const AkUniqueID ALLY_ALLY_DEATH = 1707855831U;
        static const AkUniqueID ALLY_BARRICADE_STATE = 3014529809U;
        static const AkUniqueID ALLY_CANNON_ADVANCE = 535045682U;
        static const AkUniqueID ALLY_CANNON_FIRE = 413417616U;
        static const AkUniqueID ALLY_CANNON_INCOMING = 3186371416U;
        static const AkUniqueID ALLY_PLAYER_FAR = 1337332127U;
        static const AkUniqueID ALLY_PLAYER_HIDDEN = 1135788384U;
        static const AkUniqueID ALLY_PLAYER_KILL = 2988219764U;
        static const AkUniqueID ALLY_SHOOT = 3252427803U;
        static const AkUniqueID ALLY_VOICE_CANCEL = 243533429U;
        static const AkUniqueID AMB_ARSON = 3874446497U;
        static const AkUniqueID AMB_CANNONS = 3265814676U;
        static const AkUniqueID BARRICADE_DAMAGED = 482738278U;
        static const AkUniqueID BRICK_FALL = 3840667520U;
        static const AkUniqueID BRICK_FALL_GROUP = 1055531900U;
        static const AkUniqueID BULLET_HIT = 384143791U;
        static const AkUniqueID CANNON_SHOOT = 2469499398U;
        static const AkUniqueID CHOOSE_FIGHT = 1218331013U;
        static const AkUniqueID CHOOSE_SURRENDER = 2467968637U;
        static const AkUniqueID DEAFENING_RECOVER = 3687575925U;
        static const AkUniqueID DIALOGUE = 3930136735U;
        static const AkUniqueID ENEMY_BARRICADE_STATE = 3457462997U;
        static const AkUniqueID ENEMY_BULLET_MISS = 3787232089U;
        static const AkUniqueID ENEMY_CANNON_ADVANCE = 1807735670U;
        static const AkUniqueID ENEMY_CANNON_FIRE = 378772636U;
        static const AkUniqueID ENEMY_CANNON_INCOMING = 3891079404U;
        static const AkUniqueID ENEMY_SHOOT = 1050776119U;
        static const AkUniqueID ENEMY_STEPS = 3114531655U;
        static const AkUniqueID ENEMY_VOICE_CANCEL = 2376509257U;
        static const AkUniqueID MUSIC = 3991942870U;
        static const AkUniqueID NPC_SHOOT = 1192162266U;
        static const AkUniqueID PAUSE = 3092587493U;
        static const AkUniqueID PLAYER_ALIVE = 2917189548U;
        static const AkUniqueID PLAYER_CROUCH = 3055475155U;
        static const AkUniqueID PLAYER_DEATH = 3083087645U;
        static const AkUniqueID PLAYER_DRYFIRE = 1960899976U;
        static const AkUniqueID PLAYER_PRONE = 1806823001U;
        static const AkUniqueID PLAYER_RELOAD = 1650679582U;
        static const AkUniqueID PLAYER_SHOOT = 4004702906U;
        static const AkUniqueID PLAYER_SPRINT = 2500953213U;
        static const AkUniqueID PLAYER_STEPS = 4272057794U;
        static const AkUniqueID PLAYER_UP = 4024398754U;
        static const AkUniqueID RESET_RELOAD = 1795565902U;
        static const AkUniqueID RESUME = 953277036U;
    } // namespace EVENTS

    namespace STATES
    {
        namespace BARKS_PLAYER_DISTANCE
        {
            static const AkUniqueID GROUP = 4265991608U;

            namespace STATE
            {
                static const AkUniqueID CLOSE = 1451272583U;
                static const AkUniqueID FAR = 1183803292U;
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace BARKS_PLAYER_DISTANCE

        namespace BARRICADE_STATE
        {
            static const AkUniqueID GROUP = 3394146252U;

            namespace STATE
            {
                static const AkUniqueID BROKEN = 231230354U;
                static const AkUniqueID INTACT = 3094168564U;
                static const AkUniqueID LOW = 545371365U;
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace BARRICADE_STATE

        namespace BARRICADEDESTOYED
        {
            static const AkUniqueID GROUP = 3219843997U;

            namespace STATE
            {
                static const AkUniqueID DESTROYED = 1359166010U;
                static const AkUniqueID INTACT = 3094168564U;
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace BARRICADEDESTOYED

        namespace FIGHT_STATE
        {
            static const AkUniqueID GROUP = 1138488279U;

            namespace STATE
            {
                static const AkUniqueID FIGHT = 514064485U;
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID RETREAT = 3967984634U;
            } // namespace STATE
        } // namespace FIGHT_STATE

        namespace MUSIC_STATE
        {
            static const AkUniqueID GROUP = 3826569560U;

            namespace STATE
            {
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID PHASE1 = 3630028971U;
                static const AkUniqueID PHASE1_1 = 3356867611U;
                static const AkUniqueID PHASE2 = 3630028968U;
                static const AkUniqueID PHASE3 = 3630028969U;
                static const AkUniqueID PHASE4 = 3630028974U;
            } // namespace STATE
        } // namespace MUSIC_STATE

        namespace MUSICVOICEPLAYING
        {
            static const AkUniqueID GROUP = 2714575814U;

            namespace STATE
            {
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID P1_1_OB = 2230943412U;
                static const AkUniqueID P1_2_OB_END = 684047543U;
                static const AkUniqueID P1_3_PLAYERDEATH = 1343838104U;
                static const AkUniqueID P2_1_CANON = 4215993583U;
                static const AkUniqueID P2_2_CANNONSHOOT = 2703756389U;
                static const AkUniqueID P3_1_RETREAT = 2260023866U;
                static const AkUniqueID P3_2_ALLIES = 1095445258U;
                static const AkUniqueID P3_3_DISCUSSION = 1519708847U;
                static const AkUniqueID P4_1_FIGHT = 2179381074U;
                static const AkUniqueID P4_2_END = 2334832916U;
            } // namespace STATE
        } // namespace MUSICVOICEPLAYING

        namespace NARRATIVE_STEP
        {
            static const AkUniqueID GROUP = 212893962U;

            namespace STATE
            {
                static const AkUniqueID _0 = 846646256U;
                static const AkUniqueID _1 = 846646257U;
                static const AkUniqueID _2 = 846646258U;
                static const AkUniqueID _3 = 846646259U;
                static const AkUniqueID _4 = 846646260U;
                static const AkUniqueID _5 = 846646261U;
                static const AkUniqueID _6 = 846646262U;
                static const AkUniqueID _7 = 846646263U;
                static const AkUniqueID _8 = 846646264U;
                static const AkUniqueID _9 = 846646265U;
                static const AkUniqueID _10 = 1644366931U;
                static const AkUniqueID _11 = 1644366930U;
                static const AkUniqueID _12 = 1644366929U;
                static const AkUniqueID _13 = 1644366928U;
                static const AkUniqueID _14 = 1644366935U;
                static const AkUniqueID _15 = 1644366934U;
                static const AkUniqueID _16 = 1644366933U;
                static const AkUniqueID _17 = 1644366932U;
                static const AkUniqueID _18 = 1644366939U;
                static const AkUniqueID _19 = 1644366938U;
                static const AkUniqueID _20 = 1661144518U;
                static const AkUniqueID _21 = 1661144519U;
                static const AkUniqueID _22 = 1661144516U;
                static const AkUniqueID _23 = 1661144517U;
                static const AkUniqueID _24 = 1661144514U;
                static const AkUniqueID _25 = 1661144515U;
                static const AkUniqueID _26 = 1661144512U;
                static const AkUniqueID _27 = 1661144513U;
                static const AkUniqueID _28 = 1661144526U;
                static const AkUniqueID _29 = 1661144527U;
                static const AkUniqueID _30 = 1677922233U;
                static const AkUniqueID _31 = 1677922232U;
                static const AkUniqueID _32 = 1677922235U;
                static const AkUniqueID _33 = 1677922234U;
                static const AkUniqueID _34 = 1677922237U;
                static const AkUniqueID _35 = 1677922236U;
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace NARRATIVE_STEP

        namespace PAUSE
        {
            static const AkUniqueID GROUP = 3092587493U;

            namespace STATE
            {
                static const AkUniqueID FALSE = 2452206122U;
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID TRUE = 3053630529U;
            } // namespace STATE
        } // namespace PAUSE

        namespace PLAYER_AIM
        {
            static const AkUniqueID GROUP = 1608601952U;

            namespace STATE
            {
                static const AkUniqueID FALSE = 2452206122U;
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID TRUE = 3053630529U;
            } // namespace STATE
        } // namespace PLAYER_AIM

        namespace PLAYER_BREATH
        {
            static const AkUniqueID GROUP = 314259375U;

            namespace STATE
            {
                static const AkUniqueID ANXIOUS = 3823044812U;
                static const AkUniqueID CALM = 3753286132U;
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace PLAYER_BREATH

        namespace PLAYER_COVER
        {
            static const AkUniqueID GROUP = 219569822U;

            namespace STATE
            {
                static const AkUniqueID COVERED = 2008504509U;
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID UNCOVERED = 2407602878U;
            } // namespace STATE
        } // namespace PLAYER_COVER

        namespace PLAYER_STANCE
        {
            static const AkUniqueID GROUP = 1343755517U;

            namespace STATE
            {
                static const AkUniqueID CROUCH = 2655407367U;
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID PRONE = 1270007533U;
                static const AkUniqueID SPRINT = 1296465089U;
                static const AkUniqueID STAND = 1214700371U;
            } // namespace STATE
        } // namespace PLAYER_STANCE

    } // namespace STATES

    namespace SWITCHES
    {
        namespace ALLEGIANCE
        {
            static const AkUniqueID GROUP = 1922831386U;

            namespace SWITCH
            {
                static const AkUniqueID COMMUNARD = 149546059U;
                static const AkUniqueID VERSAILLAIS = 2495691590U;
            } // namespace SWITCH
        } // namespace ALLEGIANCE

        namespace CHARACTER
        {
            static const AkUniqueID GROUP = 436743010U;

            namespace SWITCH
            {
                static const AkUniqueID FRANCOIS = 3484216754U;
                static const AkUniqueID GEORGES = 2519917785U;
                static const AkUniqueID JULES = 652153290U;
                static const AkUniqueID LOUISE = 2926082704U;
                static const AkUniqueID MARIE = 1274621345U;
                static const AkUniqueID MICHEL = 918100373U;
                static const AkUniqueID NULL = 784127654U;
                static const AkUniqueID OFFICIER = 3942830996U;
            } // namespace SWITCH
        } // namespace CHARACTER

        namespace CHARACTER_TYPE
        {
            static const AkUniqueID GROUP = 1117085073U;

            namespace SWITCH
            {
                static const AkUniqueID TYPE1 = 408582742U;
                static const AkUniqueID TYPE2 = 408582741U;
                static const AkUniqueID TYPE3 = 408582740U;
                static const AkUniqueID TYPE4 = 408582739U;
                static const AkUniqueID TYPE5 = 408582738U;
                static const AkUniqueID TYPE6 = 408582737U;
            } // namespace SWITCH
        } // namespace CHARACTER_TYPE

        namespace CLOTHING
        {
            static const AkUniqueID GROUP = 1334157877U;

            namespace SWITCH
            {
                static const AkUniqueID COAT = 3469052180U;
            } // namespace SWITCH
        } // namespace CLOTHING

        namespace DEBRIS
        {
            static const AkUniqueID GROUP = 459611840U;

            namespace SWITCH
            {
                static const AkUniqueID FIRST = 998496889U;
                static const AkUniqueID SECOND = 3476314365U;
            } // namespace SWITCH
        } // namespace DEBRIS

        namespace GENDER
        {
            static const AkUniqueID GROUP = 1776943274U;

            namespace SWITCH
            {
                static const AkUniqueID F = 84696441U;
                static const AkUniqueID M = 84696434U;
            } // namespace SWITCH
        } // namespace GENDER

        namespace PLAYER_POSITION
        {
            static const AkUniqueID GROUP = 2221031936U;

            namespace SWITCH
            {
                static const AkUniqueID CROUCH = 2655407367U;
                static const AkUniqueID PRONE = 1270007533U;
                static const AkUniqueID UP = 1551306158U;
            } // namespace SWITCH
        } // namespace PLAYER_POSITION

        namespace SHOE_TYPE
        {
            static const AkUniqueID GROUP = 3705103691U;

            namespace SWITCH
            {
                static const AkUniqueID CLOG_SHOES = 1672723819U;
                static const AkUniqueID HEELS = 2632515210U;
                static const AkUniqueID WORN_BOOTS = 755604413U;
            } // namespace SWITCH
        } // namespace SHOE_TYPE

        namespace SURFACE
        {
            static const AkUniqueID GROUP = 1834394558U;

            namespace SWITCH
            {
                static const AkUniqueID BRICK = 504532776U;
                static const AkUniqueID GLASS = 2449969375U;
                static const AkUniqueID METAL = 2473969246U;
                static const AkUniqueID WOOD = 2058049674U;
            } // namespace SWITCH
        } // namespace SURFACE

        namespace VOICE_SEL
        {
            static const AkUniqueID GROUP = 4244338540U;

            namespace SWITCH
            {
                static const AkUniqueID ACCORDEON = 840291561U;
                static const AkUniqueID CLARINETTE = 411987026U;
                static const AkUniqueID CONCERTINA = 2440095465U;
                static const AkUniqueID G1 = 1786192857U;
                static const AkUniqueID G2 = 1786192858U;
                static const AkUniqueID G3 = 1786192859U;
                static const AkUniqueID GUIMBARDE = 697539359U;
                static const AkUniqueID GUITARE = 703172684U;
                static const AkUniqueID SIFFLEMENT = 1064071544U;
                static const AkUniqueID SOLO_ATEA = 2729355702U;
                static const AkUniqueID SOLO_HUGO = 1783951004U;
                static const AkUniqueID SOLO_WANIA = 739772697U;
                static const AkUniqueID SOLO_YDRIS = 3476834350U;
                static const AkUniqueID TAMBOUR = 3360712845U;
                static const AkUniqueID VIELE = 3603862282U;
                static const AkUniqueID VXLEAD = 2994619065U;
            } // namespace SWITCH
        } // namespace VOICE_SEL

    } // namespace SWITCHES

    namespace GAME_PARAMETERS
    {
        static const AkUniqueID BARK_VOLUME = 2103536148U;
        static const AkUniqueID CANNON_SIDECHAIN = 243460359U;
        static const AkUniqueID CANNONS_PROBABILITY = 2576556105U;
        static const AkUniqueID CHOIR_VOLUME = 2909751391U;
        static const AkUniqueID DEAFENING = 711096812U;
        static const AkUniqueID DEATH_FILTER = 4205136178U;
        static const AkUniqueID DIEGETICAMOUNT = 2580242767U;
        static const AkUniqueID DISTANCE = 1240670792U;
        static const AkUniqueID ISPLAYING = 728654205U;
        static const AkUniqueID PLAYER_POSITION = 2221031936U;
        static const AkUniqueID PLAYER_VELOCITY = 1833811084U;
        static const AkUniqueID POETIC_LEVEL = 3680281974U;
        static const AkUniqueID SIDECHAIN = 1883033791U;
        static const AkUniqueID SIDECHAIN_DIALOGUE = 2647762268U;
    } // namespace GAME_PARAMETERS

    namespace BANKS
    {
        static const AkUniqueID INIT = 1355168291U;
        static const AkUniqueID FRANCOIS = 3484216754U;
        static const AkUniqueID GEORGES = 2519917785U;
        static const AkUniqueID JULES = 652153290U;
        static const AkUniqueID LOUISE = 2926082704U;
        static const AkUniqueID MARIE = 1274621345U;
        static const AkUniqueID MICHEL = 918100373U;
        static const AkUniqueID OFFICIER = 3942830996U;
        static const AkUniqueID SB_AMB = 925885567U;
        static const AkUniqueID SB_CANNON = 2061449278U;
        static const AkUniqueID SB_MUSIC = 779753582U;
        static const AkUniqueID SB_NPC = 1278759826U;
        static const AkUniqueID SB_PLAYER = 2103316850U;
    } // namespace BANKS

    namespace BUSSES
    {
        static const AkUniqueID AMB = 1117531639U;
        static const AkUniqueID MAIN_AUDIO_BUS = 2246998526U;
        static const AkUniqueID MUSIC_BUS = 2680856269U;
        static const AkUniqueID SFX = 393239870U;
        static const AkUniqueID SFX_CANNON = 1541696182U;
        static const AkUniqueID SFX_NPC = 161171466U;
        static const AkUniqueID SFX_PLAYER = 217780010U;
        static const AkUniqueID UI = 1551306167U;
        static const AkUniqueID VX = 1534528563U;
        static const AkUniqueID VX_CHARACTERS = 1864612070U;
        static const AkUniqueID VX_NPC = 1277101407U;
        static const AkUniqueID VX_PLAYER = 1728828729U;
        static const AkUniqueID WWISE_MOTION = 1156359885U;
    } // namespace BUSSES

    namespace AUX_BUSSES
    {
        static const AkUniqueID MUSIC_REV = 2415077256U;
        static const AkUniqueID SFX_GUNSHOT_SEND = 3189108374U;
        static const AkUniqueID STREET_REVERB = 2635253023U;
        static const AkUniqueID WWISE_MOTION_SEND = 214837138U;
    } // namespace AUX_BUSSES

    namespace AUDIO_DEVICES
    {
        static const AkUniqueID MOTION = 2012559111U;
        static const AkUniqueID NO_OUTPUT = 2317455096U;
        static const AkUniqueID SYSTEM = 3859886410U;
    } // namespace AUDIO_DEVICES

}// namespace AK

#endif // __WWISE_IDS_H__
