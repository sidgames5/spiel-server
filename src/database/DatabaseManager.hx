package database;

import models.User;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import models.Database;
import models.Channel;

class DatabaseManager {
    public static function init() {
        var tdb:Database = {
            users: [],
            channels: []
        };
        FileSystem.createDirectory(".run/");
        File.saveContent(".run/db.json", Json.stringify(tdb));
    }

    public static function check():Bool {
        return FileSystem.exists(".run/db.json");
    }

    public static function read():Database {
        if (!check())
            init();
        return Json.parse(File.getContent(".run/db.json"));
    }

    public static function write(content:Database) {
        File.saveContent(".run/db.json", Json.stringify(content));
    }

    public static function getChannel(id:Int):Channel {
        final db = read();

        for (channel in db.channels) {
            if (channel.id == id)
                return channel;
        }

        return null;
    }

    public static function getUserById(id:Int):User {
        final db = read();

        for (user in db.users) {
            if (user.id == id)
                return user;
        }

        return null;
    }

    public static function getUserByUsername(username:String):User {
        final db = read();

        for (user in db.users) {
            if (user.username == username)
                return user;
        }

        return null;
    }

    public static function addUser(user:User) {
        var db = read();

        db.users.push(user);

        write(db);
    }

    public static function addChannel(channel:Channel) {
        var db = read();

        db.channels.push(channel);

        write(db);
    }

    public static function updateUser(user:User) {
        var db = read();

        for (i in 0...db.users.length) {
            if (db.users[i].id == user.id) {
                db.users[i] = user;
            }
        }

        write(db);
    }

    public static function updateChannel(channel:Channel) {
        var db = read();

        for (i in 0...db.channels.length) {
            if (db.channels[i].id == channel.id) {
                db.channels[i] = channel;
            }
        }

        write(db);
    }

    public static function removeUser(user:User) {
        var db = read();

        db.users.remove(user);

        write(db);
    }

    public static function removeChannel(channel:Channel) {
        var db = read();

        db.channels.remove(channel);

        write(db);
    }
}
