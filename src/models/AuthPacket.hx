package models;

typedef AuthPacket = {
    register:Bool,
    username:String,
    passwordHash:String,
    ?phone:String
}
