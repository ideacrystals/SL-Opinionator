default
{
    link_message(integer sender, integer x, string str, key id) {
        list params = llParseString2List(str, [","],[]);
        float cutstrt = llList2Float(params, 0);
        float cutend  = llList2Float(params, 1);
        if (cutstrt == cutend) {
            // the size is zero so make the segment invisible
            llSetAlpha(0.0, ALL_SIDES);
        }
        else {
            // set the prim type to change the cut start and end
            // NOTE: This will unsit all avatars on the object
            llSetPrimitiveParams( [PRIM_TYPE, PRIM_TYPE_CYLINDER,
                0, <cutstrt, cutend, 0.0>, 0.0, <0.0, 0.0, 0.0>,
                <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>] );
            // ensure the segment is visible
            llSetAlpha(0.8, ALL_SIDES);
        }
    }
}

