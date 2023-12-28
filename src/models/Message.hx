package models;

import models.Author;

typedef Message = {
    content:String,
    author:Author,
    timestamp:Int,
    uuid:String,
    id:Int,
    channel:Int
}
