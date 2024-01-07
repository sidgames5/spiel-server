package models;

import models.Channel;
import models.User;
import haxe.extern.EitherType;

typedef DatabasePacket = {
    instruction:String,
    ?data1:Dynamic,
    ?data2:Dynamic,
    ?token:String
}
