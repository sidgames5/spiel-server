package models;

import models.Author;

typedef User = {
    > Author,
    passwordHash:String,
    channels:Array<Int>,
    requests:Array<Int>
}
