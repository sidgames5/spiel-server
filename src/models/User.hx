package models;

import models.Author;

typedef User = {
    > Author,
    passwordHash:String
}
