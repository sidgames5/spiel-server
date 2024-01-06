package auth;

import database.DatabaseManager;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import models.User;

class TokenManager {
    public static function generate(user:User):String {
        var raw = "";

        raw += user.id;
        raw += ".";

        var expiry = Date.fromTime(Date.now().getTime() + (30 * 24 * 60 * 60 * 1000));

        raw += Math.round(expiry.getTime());
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

    public static function validate(token:String):Bool {
        for (line in File.getContent(".run/tokens").split("\n")) {
            var t = line.split(":")[1];
            if (token == t)
                return true;
        }
        return false;
    }

    public static function getUser(token:String):User {
        for (line in File.getContent(".run/tokens").split("\n")) {
            var t = line.split(":")[1];
            if (token == t)
                return DatabaseManager.getUserById(Std.parseInt(line.split(":")[0]));
        }
        return null;
    }
}
