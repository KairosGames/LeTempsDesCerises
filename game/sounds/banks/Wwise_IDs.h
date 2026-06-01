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
        static const AkUniqueID ALLY_BARK = 3470134616U;
        static const AkUniqueID ALLY_BARK_ALLY_DEAD = 3295768610U;
        static const AkUniqueID ALLY_BARK_COWARD = 1318320503U;
        static const AkUniqueID ALLY_BARK_ENEMY_DEAD = 3598975830U;
        static const AkUniqueID ALLY_SHOOT = 3252427803U;
        static const AkUniqueID AMB_CANNONS = 3265814676U;
        static const AkUniqueID BARRICADE_DAMAGED = 482738278U;
        static const AkUniqueID BRICK_FALL = 3840667520U;
        static const AkUniqueID BULLET_HIT = 384143791U;
        static const AkUniqueID CANNON_SHOOT = 2469499398U;
        static const AkUniqueID DEAFENING_RECOVER = 3687575925U;
        static const AkUniqueID ENEMY_BARK = 2802320212U;
        static const AkUniqueID ENEMY_BULLET_MISS = 3787232089U;
        static const AkUniqueID ENEMY_SHOOT = 1050776119U;
        static const AkUniqueID ENEMY_STEPS = 3114531655U;
        static const AkUniqueID MUSIC = 3991942870U;
        static const AkUniqueID PLAYER_ALIVE = 2917189548U;
        static const AkUniqueID PLAYER_CROUCH = 3055475155U;
        static const AkUniqueID PLAYER_DEATH = 3083087645U;
        static const AkUniqueID PLAYER_PRONE = 1806823001U;
        static const AkUniqueID PLAYER_RELOAD = 1650679582U;
        static const AkUniqueID PLAYER_SHOOT = 4004702906U;
        static const AkUniqueID PLAYER_SPRINT = 2500953213U;
        static const AkUniqueID PLAYER_STEPS = 4272057794U;
        static const AkUniqueID PLAYER_UP = 4024398754U;
        static const AkUniqueID RESET_RELOAD = 1795565902U;
    } // namespace EVENTS

    namespace STATES
    {
        namespace BARKS_BARRICADE
        {
            static const AkUniqueID GROUP = 2280690262U;

            namespace STATE
            {
                static const AkUniqueID BROKEN = 231230354U;
                static const AkUniqueID INTACT = 3094168564U;
                static const AkUniqueID LOW = 545371365U;
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace BARKS_BARRICADE

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
                static const AkUniqueID PHASE2 = 3630028968U;
                static const AkUniqueID PHASE3 = 3630028969U;
            } // namespace STATE
        } // namespace MUSIC_STATE

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

        namespace CHARACTER_TYPE
        {
            static const AkUniqueID GROUP = 1117085073U;

            namespace SWITCH
            {
                static const AkUniqueID TYPE1 = 408582742U;
                static const AkUniqueID TYPE2 = 408582741U;
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
        static const AkUniqueID DISTANCE = 1240670792U;
        static const AkUniqueID ISPLAYING = 728654205U;
        static const AkUniqueID PLAYER_POSITION = 2221031936U;
        static const AkUniqueID PLAYER_VELOCITY = 1833811084U;
        static const AkUniqueID POETIC_LEVEL = 3680281974U;
        static const AkUniqueID SIDECHAIN = 1883033791U;
    } // namespace GAME_PARAMETERS

    namespace BANKS
    {
        static const AkUniqueID INIT = 1355168291U;
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
        static const AkUniqueID VX_NPC = 1277101407U;
        static const AkUniqueID VX_PLAYER = 1728828729U;
        static const AkUniqueID WWISE_MOTION = 1156359885U;
    } // namespace BUSSES

    namespace AUX_BUSSES
    {
        static const AkUniqueID MUSIC_REV = 2415077256U;
        static const AkUniqueID REFLECT = 243379636U;
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
