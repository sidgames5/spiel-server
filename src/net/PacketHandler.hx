package net;

import models.AuthPacket;
import util.ValidationUtils;
import models.Message;
import auth.TokenManager;
import models.Channel;
import database.DatabaseManager;
import models.User;
import models.DatabasePacket;
import haxe.Json;
import hx_webserver.HTTPRequest;

class PacketHandler {
    public static function receivePacket(req:HTTPRequest) {
        var packet = Json.parse(req.postData);
        if (packet.register == null) {
            receiveDatabasePacket(req);
        } else {
            receiveAuthPacket(req);
        }
    }

    public static function receiveAuthPacket(req:HTTPRequest) {
        var packet:AuthPacket = null;
        try {
            packet = Json.parse(req.postData);
        } catch (e) {
            Sys.println("WARN: Invalid request data: " + req.postData);
            req.replyData("Invalid request data", "text/plain", 400);
            return;
        }

        if (packet.register) {
            var user:User = packet.user;

            if (DatabaseManager.getUserByUsername(user.username) != null) {
                req.replyData("Username taken", "text/plain", 409);
                return;
            }

            if (!ValidationUtils.validateUsername(user.username)) {
                req.replyData("Invalid username", "text/plain", 417);
                return;
            }

            final db = DatabaseManager.read();
            var latestId;
            if (db.users.length > 0)
                latestId = db.users[db.users.length - 1].id;
            else
                latestId = 0;

            user.id = latestId + 1;

            DatabaseManager.addUser(user);

            // create a new session token
            var token = TokenManager.generate(user);
            TokenManager.register(user, token);

            req.replyData(token, "text/plain", 200);
            return;
        } else {
            // ensure the password is correct
            var pass = packet.passwordHash;
            var user = DatabaseManager.getUserByUsername(packet.username);
            if (user == null) {
                req.replyData("User not found", "text/plain", 404);
                return;
            }
            if (pass != user.passwordHash) {
                req.replyData("Password incorrect", "text/plain", 401);
                return;
            }

            // create a new session token
            var token = TokenManager.generate(user);
            TokenManager.register(user, token);

            req.replyData(token, "text/plain", 200);
            return;
        }

        req.replyData("Internal server error", "text/plain", 500);
    }

    public static function receiveDatabasePacket(req:HTTPRequest) {
        var packet:DatabasePacket = null;
        try {
            packet = Json.parse(req.postData);
        } catch (e) {
            Sys.println("WARN: Invalid request data: " + req.postData);
            req.replyData("Invalid request data", "text/plain", 400);
            return;
        }

        final token = packet.token;
        final isLoggedIn = token != null;
        try {
            if (token != null) {
                if (TokenManager.isExpired(token)) {
                    req.replyData("Token expired", "text/plain", 401);
                    return;
                }
                if (!TokenManager.validate(token)) {
                    req.replyData("Invalid token", "text/plain", 401);
                    return;
                }
            }
        } catch (e) {
            req.replyData("Invalid token", "text/plain", 401);
            return;
        }

        switch (packet.instruction) {
            case "ADD_USER":
                var user:User = packet.data1;

                if (DatabaseManager.getUserByUsername(user.username) != null) {
                    req.replyData("Username taken", "text/plain", 409);
                    return;
                }

                if (!ValidationUtils.validateUsername(user.username)) {
                    req.replyData("Invalid username", "text/plain", 417);
                    return;
                }

                final db = DatabaseManager.read();
                var latestId;
                if (db.users.length > 0)
                    latestId = db.users[db.users.length - 1].id;
                else
                    latestId = 0;

                user.id = latestId + 1;

                DatabaseManager.addUser(user);

                req.replyData("Success", "text/plain", 200);
                return;
            case "ADD_CHANNEL":
                // TODO: CRITICAL: change the channel members list from authors/users to userids
                if (!isLoggedIn) {
                    req.replyData("Must be logged in to do this", "text/plain", 401);
                    return;
                }
                var channel:Channel = packet.data1;

                final db = DatabaseManager.read();

                var latestId;
                if (db.channels.length > 0) {
                    latestId = db.channels[db.channels.length - 1].id;
                } else {
                    latestId = 0;
                }

                channel.id = latestId + 1;

                DatabaseManager.addChannel(channel);

                req.replyData("Success", "text/plain", 200);

                return;
            case "EDIT_USER":
                var user:User = packet.data1;

                var token = packet.token;

                var tuser = TokenManager.getUser(token);

                if (user == null || tuser == null) {
                    req.replyData("User not found or unauthorized", "text/plain", 401);

                    return;
                }

                if (user.id != tuser.id) {
                    req.replyData("User not found or unauthorized", "text/plain", 401);

                    return;
                }

                DatabaseManager.updateUser(user);

                req.replyData("Success", "text/plain", 200);

                return;
            case "EDIT_CHANNEL":
                var channel:Channel = packet.data1;

                var token = packet.token;
                var user = TokenManager.getUser(token);
                var tchannel = DatabaseManager.getChannel(channel.id);

                if (tchannel == null) {
                    req.replyData("Channel not found", "text/plain", 404);
                    return;
                }

                if (!tchannel.members.contains(user.id)) {
                    req.replyData("You are not allowed to access this channel", "text/plain", 401);
                    return;
                }

                DatabaseManager.updateChannel(channel);

                req.replyData("Success", "text/plain", 200);
                return;
            case "REMOVE_USER":
                // FIXME: not working
                var user:User;
                if (Std.isOfType(packet.data1, Int)) {
                    user = DatabaseManager.getUserById(packet.data1);
                } else {
                    user = DatabaseManager.getUserByUsername(packet.data1);
                }

                var token = packet.token;
                var tuser = TokenManager.getUser(token);

                if (user == null) {
                    req.replyData("User not found", "text/plain", 404);
                    return;
                }

                if (user.id != tuser.id) {
                    req.replyData("You are not allowed to do this", "text/plain", 401);
                    return;
                }

                DatabaseManager.removeUser(user);
                req.replyData("Success", "text/plain", 200);
                return;
            case "REMOVE_CHANNEL":
                // FIXME: not working
                var channel:Channel = null;
                if (Std.isOfType(packet.data1, Int)) {
                    channel = DatabaseManager.getChannel(packet.data1);
                } else {
                    channel = packet.data1;
                }

                var token = packet.token;
                var user = TokenManager.getUser(token);

                if (channel == null) {
                    req.replyData("Channel not found", "text/plain", 404);
                    return;
                }

                if (channel.owner != user.id) {
                    req.replyData("You are not allowed to do this", "text/plain", 401);
                    return;
                }

                DatabaseManager.removeChannel(channel);
                req.replyData("Success", "text/plain", 200);
                return;
            case "GET_USER":
                var user:User;
                if (Std.isOfType(packet.data1, String)) {
                    user = DatabaseManager.getUserByUsername(packet.data1);
                } else {
                    user = DatabaseManager.getUserById(packet.data1);
                }

                if (user == null) {
                    req.replyData("User not found", "text/plain", 404);
                    return;
                }

                user.passwordHash = null;

                req.replyData(Json.stringify(user), "text/plain", 200);
                return;
            case "GET_CHANNEL":
                var channel:Channel;
                channel = DatabaseManager.getChannel(packet.data1);

                var token = packet.token;
                var user = TokenManager.getUser(token);

                if (channel == null) {
                    req.replyData("Channel not found", "text/plain", 404);
                    return;
                }

                if (!channel.members.contains(user.id)) {
                    req.replyData("You do not have permission to access this channel", "text/plain", 401);
                    return;
                }

                req.replyData(Json.stringify(channel), "text/plain", 200);
                return;
            case "GET_REQUESTS":
                // a request will be sent to the user when they are added to a channel by another user
                // this is necessary for the user to know what channels they are in

                var token = packet.token;
                var user = TokenManager.getUser(token);

                if (user == null) {
                    req.replyData("User not found", "text/plain", 404);
                    return;
                }

                req.replyData(Json.stringify(user.requests), "text/plain", 200);
                return;
        }

        req.replyData("Internal server error", "text/plain", 500);
    }
}
