{\rtf1\ansi\ansicpg1252\cocoartf1187\cocoasubrtf390
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural

\f0\fs24 \cf0 // NOTE: link the white "direction marker" prim last to make\
// it the root prim (because the sensor rotation is w.r.t\
// this root prim).\
// All other prims can be linked in any order.\
\
// set to TRUE to enable debug output\
// set to FALSE for normal operation\
// print the sensor distance of each avatar to channel 0\
integer DEBUG_SENS_DIST = FALSE;\
// allows the sensor to detect objects as well as avatars\
// (this is useful for testing) \
integer DEBUG_SENS_OBJS = FALSE;\
\
// minimum avatar sensor detection distance (meters)\
float DIST_MIN = 4.5;\
// maximum avatar sensor detection distance (meters)\
float DIST_MAX = 8;\
\
// "heatbeat" timebase period (seconds)\
float g_tbase = 1.0;\
// step position of the sensor\
integer g_segnum;\
// number of steps\
integer NUM_SEGS = 5;\
\
// link numbers for the pie segments\
integer g_seg0;\
integer g_seg1;\
integer g_seg2;\
integer g_seg3;\
integer g_seg4;\
integer g_num_segs = 5;\
\
// link numbers for the target zones\
integer g_targ0;\
integer g_targ1;\
integer g_targ2;\
integer g_targ3;\
integer g_targ4;\
\
// avatar count for the current sensor position\
integer g_avie_count_cur = 0;\
// avatar counts for the 5 target zones\
integer g_avie_count0;\
integer g_avie_count1;\
integer g_avie_count2;\
integer g_avie_count3;\
integer g_avie_count4;\
\
string  g_ncardname = "settings";   // name of notecard\
key     g_ncardqry;                 // notecard query\
integer g_ncardline;\
\
init() \{\
    // if the notecard exists then read it\
    if ( llGetInventoryType(g_ncardname) == INVENTORY_NOTECARD ) \{\
        g_ncardline = 0;\
        // request the first line\
        g_ncardqry = llGetNotecardLine(g_ncardname, g_ncardline);\
    \}\
    else \{\
        llOwnerSay("Notecard missing: \\"" + g_ncardname + "\\"");\
    \}\
    g_segnum = 0;\
    // find the link numbers of the referenced component prims\
    find_link_nums();\
\
    llSetAlpha(0.0,ALL_SIDES);\
\}\
\
// find the link numbers of component prims by matching their names\
// (this allows them to be linked in any order and hence could save\
// development time)\
find_link_nums() \{\
    integer i;\
    // iterate throught the linked prims. llGetNumberOfPrims()\
    // could be too large because it will includes the count of\
    // any seated avies but this doesn't matter\
    for (i=0; i<=llGetNumberOfPrims(); i++) \{\
        string name = llGetLinkName(i);\
        if      (name == "seg0") \{ g_seg0 = i; \}\
        else if (name == "seg1") \{ g_seg1 = i; \}\
        else if (name == "seg2") \{ g_seg2 = i; \}\
        else if (name == "seg3") \{ g_seg3 = i; \}\
        else if (name == "seg4") \{ g_seg4 = i; \}\
        else if (name == "targ0") \{ g_targ0 = i; \}\
        else if (name == "targ1") \{ g_targ1 = i; \}\
        else if (name == "targ2") \{ g_targ2 = i; \}\
        else if (name == "targ3") \{ g_targ3 = i; \}\
        else if (name == "targ4") \{ g_targ4 = i; \}\
    \}\
\}\
\
rotate_sensor_prim() \{\
    if (g_segnum == 0) \{\
        llSetLocalRot( llEuler2Rot(<0, 0, -180.0*DEG_TO_RAD>) );\
    \}\
    else if (g_segnum == 1) \{\
        llSetLocalRot( llEuler2Rot(<0, 0, -240.0*DEG_TO_RAD>) );\
    \}\
    else if (g_segnum == 2) \{\
        llSetLocalRot( llEuler2Rot(<0, 0, -300.0*DEG_TO_RAD>) );\
    \}\
    else if (g_segnum == 3) \{\
        llSetLocalRot( llEuler2Rot(<0, 0, 0.0*DEG_TO_RAD>) );\
    \}\
    else if (g_segnum == 4) \{\
        llSetLocalRot( llEuler2Rot(<0, 0, -60.0*DEG_TO_RAD>) );\
    \}\
\}\
\
display_results() \{\
    float seg_ratio;\
    float cut_start;\
    float cut_end_prev = 1;\
    float cut_end;\
    \
    integer total = g_avie_count0 + g_avie_count1 +\
        g_avie_count2 + g_avie_count3 + g_avie_count4;\
    llSetText("Avatar Total: " + (string)total, <0.8,0.8,0.7>, 1.0);\
    if (total == 0) \{\
        // don't draw the pie chart\
        llMessageLinked(g_seg0, 0, "0,0", NULL_KEY);\
        llMessageLinked(g_seg1, 0, "0,0", NULL_KEY);\
        llMessageLinked(g_seg2, 0, "0,0", NULL_KEY);\
        llMessageLinked(g_seg3, 0, "0,0", NULL_KEY);\
        llMessageLinked(g_seg4, 0, "0,0", NULL_KEY);\
        // update the target segments floating text\
        llMessageLinked(g_targ0, 0, "Avatars: " +\
            (string)g_avie_count0 + "\\n\\(0%\\)", NULL_KEY);\
        llMessageLinked(g_targ1, 0, "Avatars: " +\
            (string)g_avie_count1 + "\\n\\(0%\\)", NULL_KEY);\
        llMessageLinked(g_targ2, 0, "Avatars: " +\
            (string)g_avie_count2 + "\\n\\(0%\\)", NULL_KEY);\
        llMessageLinked(g_targ3, 0, "Avatars: " +\
            (string)g_avie_count3 + "\\n\\(0%\\)", NULL_KEY);\
        llMessageLinked(g_targ4, 0, "Avatars: " +\
            (string)g_avie_count4 + "\\n\\(0%\\)", NULL_KEY);\
    \} else \{\
        seg_ratio = (float)g_avie_count0/(float)total;\
        cut_end = 1.0;\
        cut_start = 1.0 - seg_ratio;\
        // update the pie segment size (and make invisible if zero)\
        llMessageLinked(g_seg0, 0, (string)cut_start + "," +\
            (string)cut_end, NULL_KEY);\
        // update the target segment floating text\
        llMessageLinked(g_targ0, 0, "Avatars: " +\
            (string)g_avie_count0 + "\\n\\(" +\
            (string)llRound((seg_ratio*100)) + "%\\)", NULL_KEY);\
        \
        seg_ratio = (float)g_avie_count1/(float)total;\
        cut_end = cut_start;\
        cut_start = cut_end - seg_ratio;\
        // update the pie segment size (and make invisible if zero)\
        llMessageLinked(g_seg1, 0, (string)cut_start + "," +\
            (string)cut_end, NULL_KEY);\
        // update the target segment floating text\
        llMessageLinked(g_targ1, 0, "Avatars: " +\
            (string)g_avie_count1 + "\\n\\(" + \
            (string)llRound((seg_ratio*100)) + "%\\)", NULL_KEY);\
\
        seg_ratio = (float)g_avie_count2/(float)total;\
        cut_end = cut_start;\
        cut_start = cut_end - seg_ratio;\
        // update the pie segment size (and make invisible if zero)\
        llMessageLinked(g_seg2, 0, (string)cut_start + "," +\
            (string)cut_end, NULL_KEY);\
        // update the target segment floating text\
        llMessageLinked(g_targ2, 0, "Avatars: " +\
            (string)g_avie_count2 + "\\n\\(" +\
            (string)llRound((seg_ratio*100)) + "%\\)", NULL_KEY);\
\
        seg_ratio = (float)g_avie_count3/(float)total;\
        cut_end = cut_start;\
        cut_start = cut_end - seg_ratio;\
        // update the pie segment size (and make invisible if zero)\
        llMessageLinked(g_seg3, 0, (string)cut_start + "," +\
            (string)cut_end, NULL_KEY);\
        // update the target segment floating text\
        llMessageLinked(g_targ3, 0, "Avatars: " +\
            (string)g_avie_count3 + "\\n\\(" +\
            (string)llRound((seg_ratio*100)) + "%\\)", NULL_KEY);\
\
        seg_ratio = (float)g_avie_count4/(float)total;\
        cut_end = cut_start;\
        cut_start = cut_end - seg_ratio;\
        // update the pie segment size (and make invisible if zero)\
        llMessageLinked(g_seg4, 0, (string)cut_start + "," +\
            (string)cut_end, NULL_KEY);\
        // update the target segment floating text\
        llMessageLinked(g_targ4, 0, "Avatars: " +\
            (string)g_avie_count4 + "\\n\\(" +\
            (string)llRound((seg_ratio*100)) + "%\\)", NULL_KEY);\
    \}\
\}\
\
default\
\{\
    state_entry() \{\
        init();\
    \}\
    on_rez(integer start_param) \{\
        init();\
    \}\
    // event called at frequency: g_tbase\
    timer() \{\
        if      (g_segnum == 0) \{g_avie_count0 = g_avie_count_cur;\}\
        else if (g_segnum == 1) \{g_avie_count1 = g_avie_count_cur;\}\
        else if (g_segnum == 2) \{g_avie_count2 = g_avie_count_cur;\}\
        else if (g_segnum == 3) \{g_avie_count3 = g_avie_count_cur;\}\
        else if (g_segnum == 4) \{g_avie_count4 = g_avie_count_cur;\}\
\
        // clear the count ready for the next segment\
        g_avie_count_cur = 0;\
\
        // move to the next segment\
        if (++g_segnum >= NUM_SEGS) \{\
            g_segnum = 0;\
            // redraw the pie chart\
            display_results();\
        \}\
\
        // the sensor works in the direction of it's prim\
        rotate_sensor_prim();\
        // perform the sensor segment scan\
        if (DEBUG_SENS_OBJS == TRUE) \{\
            // sense avatars and objects to allow testing\
            llSensor("", NULL_KEY, (AGENT|PASSIVE|ACTIVE), DIST_MAX,\
                PI/6);\
        \}\
        else \{\
            // only sense avatars\
            llSensor("", NULL_KEY, AGENT, DIST_MAX, PI/6);\
        \}\
    \}\
    sensor(integer num) \{\
        integer i;\
        float distance;\
        vector pos = llGetPos();\
        \
        g_avie_count_cur = num;\
        // llMessageLinked(g_seg_s_dis, 0, "0.8,1.0", NULL_KEY);\
        for(i=0; i<num; i++) \{\
            distance = llVecDist( pos, llDetectedPos(i) );\
            if (DEBUG_SENS_DIST == TRUE) \{\
                llSay(0, "Distance "+(string)i+": "+(string)distance);\
            \}\
            // if the avatar is outside of the target zone\
            if (distance < DIST_MIN) \{\
                // remove the avatar from the count\
                --g_avie_count_cur;\
            \}\
        \}\
    \}\
    dataserver(key query, string data) \{\
        // check if this is a response to our notecard query\
        if (query == g_ncardqry) \{\
            if (data != EOF) \{\
                // handle the returned notecard line\
                g_tbase = (float)data;\
                llOwnerSay("Notecard delay setting: " + (string)g_tbase); \
                // periodic "heatbeat" timer\
                llSetTimerEvent(g_tbase);\
                // get the next line\
                //g_ncardqry = llGetNotecardLine(g_ncardname,\
                //    ++g_ncardline);\
            \}\
            // else all lines have been read\
        \}\
    \}\
\}\
}