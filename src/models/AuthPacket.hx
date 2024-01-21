package models;

import models.User;

typedef AuthPacket = {
    register:Bool,
    ?username:String,
    ?passwordHash:String,
    ?user:User
}
