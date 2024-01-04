package models;

import util.DatabasePacketInstruction;
import models.Channel;
import models.User;
import haxe.extern.EitherType;

typedef DatabasePacket = {
    instruction:DatabasePacketInstruction,
    ?data1:Dynamic,
    ?data2:Dynamic,
    ?token:String
}
