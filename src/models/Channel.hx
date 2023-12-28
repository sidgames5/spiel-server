package models;

import models.Author;

typedef Channel = {
    id:Int,
    name:String,
    members:Array<Author>,
    owner:Author,
    pictureBytes:String
}
