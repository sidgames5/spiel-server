package models;

import util.DatabasePacketInstruction;
import models.Channel;
import models.User;
import haxe.extern.EitherType;

typedef AuthPacket = {
    register:Bool,
    username:String,
    password:String,
    ?phone:String
}
