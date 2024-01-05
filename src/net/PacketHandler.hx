package net;

import models.Message;
import auth.TokenManager;
import util.DatabasePacketInstruction;
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
            // TODO
        }
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

        // TODO: check if the token is valid and has the correct permissions

        final token = packet.token;
        final isLoggedIn = token != null;
        if (!TokenManager.validate(token)) {
            req.replyData("Invalid token", "text/plain", 401);
            return;
        }

        switch (packet.instruction) {
            case ADD_USER:
                var user:User = packet.data1;

                if (DatabaseManager.getUserByUsername(user.username) != null) {
                    req.replyData("Username taken", "text/plain", 409);
                    return;
                }

                final db = DatabaseManager.read();
                final latestId = db.users[db.users.length - 1].id;

                user.id = latestId + 1;

                DatabaseManager.addUser(user);

                req.replyData("Success", "text/plain", 200);
            case ADD_CHANNEL:
                if (!isLoggedIn) {
                    req.replyData("Must be logged in to do this", "text/plain", 401);
                    return;
                }
                var channel:Channel = packet.data1;

                final db = DatabaseManager.read();
                final latestId = db.channels[db.channels.length - 1].id;

                channel.id = latestId + 1;

                DatabaseManager.addChannel(channel);

                req.replyData("Success", "text/plain", 200);
            case EDIT_USER:
            case EDIT_CHANNEL:
            case REMOVE_USER:
            case REMOVE_CHANNEL:
            case GET_USER:
                var user:User;
                if (Std.isOfType(packet.data1, String)) {
                    user = DatabaseManager.getUserByUsername(packet.data1);
                } else {
                    user = DatabaseManager.getUserById(packet.data1);
                }

                if (user == null) {
                    req.replyData("User not found", "text/plain", 404);
                }

                user.passwordHash = null;

                req.replyData(Json.stringify(user), "text/plain", 200);
            case GET_CHANNEL:
                var channel:Channel;
                channel = DatabaseManager.getChannel(packet.data1);

                // TODO: make sure the user has the correct permissions to access the channel

                if (channel == null) {
                    req.replyData("Channel not found", "text/plain", 404);
                }

                req.replyData(Json.stringify(channel), "text/plain", 200);
        }

        req.replyData("Internal server error", "text/plain", 500);
    }
}
