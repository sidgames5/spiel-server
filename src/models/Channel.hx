package models;

import models.Message;
import models.Author;

typedef Channel = {
    id:Int,
    name:String,
    members:Array<Int>,
    owner:Int,
    pictureBytes:String,
    messages:Array<Message>
}
