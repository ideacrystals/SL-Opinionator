//
//  Second Life Opinionator
//
//  Copyright (c) 2013 Ian Evans, ideacrystals
//
//  Licensed under the MIT license, see LICENSE file for details.
//  All text above must be included in any redistribution.
//

default
{
    link_message(integer sender, integer x, string str, key id) {
        llSetText(str, <0.8,0.8,0.7>, 1.0);
    }
}

