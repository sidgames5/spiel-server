package auth;

import haxe.Json;
import database.DatabaseManager;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import models.User;

class TokenManager {
    public static function init() {
        FileSystem.createDirectory(".run/");
        File.saveContent(".run/tokens", "");
    }

    public static function check():Bool {
        return FileSystem.exists(".run/tokens");
    }

    public static function generate(user:User):String {
        var raw = "";

        raw += user.id;
        raw += ".";

        var expiry = Date.fromTime(Date.now().getTime() + (30.0 * 24 * 60 * 60 * 1000));

        raw += Math.ceil(Std.int(expiry.getTime() / 1000));
        raw += ".";

        var random = Math.floor(Math.random() * 2147483647);

        raw += random;

        return Base64.encode(Bytes.ofString(raw));
    }

    public static function register(user:User, token:String) {
        if (!FileSystem.exists(".run/tokens")) {
            File.saveContent(".run/tokens", "");
        }

        var tokens = File.getContent(".run/tokens").split("\n");
        tokens.push(user.id + ":" + token);
        File.saveContent(".run/tokens", tokens.join("\n"));
    }

    public static function isExpired(token:String):Bool {
        var t = Base64.decode(token).toString().split(":")[1];
        var expiry = Date.fromTime(Std.parseFloat(t.split(".")[1]));
        return expiry.getTime() > (Date.now().getTime() / 1000);
    }

    public static function validate(token:String):Bool {
        for (line in File.getContent(".run/tokens").split("\n")) {
            var t = line.split(":")[1];
            if (token == t) {
                return !isExpired(token);
            }
        }
        return false;
    }

    public static function getUser(token:String):User {
        var id = Std.parseInt(Base64.decode(token).toString().split(".")[0]);
        return DatabaseManager.getUserById(id);
    }
}
