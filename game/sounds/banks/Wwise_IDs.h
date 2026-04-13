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
        static const AkUniqueID AMB_CANNONS = 3265814676U;
        static const AkUniqueID BULLET_HIT = 384143791U;
        static const AkUniqueID DEAFENING_RECOVER = 3687575925U;
        static const AkUniqueID PLAYER_RELOAD = 1650679582U;
        static const AkUniqueID PLAYER_SHOOT = 4004702906U;
        static const AkUniqueID PLAYER_STEPS = 4272057794U;
    } // namespace EVENTS

    namespace STATES
    {
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

        namespace PLAYER_STANCE
        {
            static const AkUniqueID GROUP = 1343755517U;

            namespace STATE
            {
                static const AkUniqueID CROUCH = 2655407367U;
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID PRONE = 1270007533U;
                static const AkUniqueID UP = 1551306158U;
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

    } // namespace SWITCHES

    namespace GAME_PARAMETERS
    {
        static const AkUniqueID CANNONS_PROBABILITY = 2576556105U;
        static const AkUniqueID DEAFENING = 711096812U;
        static const AkUniqueID PLAYER_POSITION = 2221031936U;
        static const AkUniqueID POETIC_LEVEL = 3680281974U;
    } // namespace GAME_PARAMETERS

    namespace BANKS
    {
        static const AkUniqueID INIT = 1355168291U;
        static const AkUniqueID SB_AMB = 925885567U;
        static const AkUniqueID SB_ENEMY = 3827176343U;
        static const AkUniqueID SB_PLAYER = 2103316850U;
    } // namespace BANKS

    namespace BUSSES
    {
        static const AkUniqueID AMB = 1117531639U;
        static const AkUniqueID MAIN_AUDIO_BUS = 2246998526U;
        static const AkUniqueID SFX = 393239870U;
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
        static const AkUniqueID CROSSROAD_REVERB = 1865335600U;
        static const AkUniqueID REFLECT = 243379636U;
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
