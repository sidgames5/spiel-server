package models;

import models.Author;

typedef Channel = {
    id:Int,
    name:String,
    members:Array<Int>,
    owner:Int,
    pictureBytes:String
}
