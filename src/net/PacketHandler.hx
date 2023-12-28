package net;

import util.DatabasePacketInstruction;
import models.Channel;
import database.DatabaseManager;
import models.User;
import models.DatabasePacket;
import haxe.Json;
import hx_webserver.HTTPRequest;

class PacketHandler {
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

        switch (packet.instruction) {
            case ADD_USER:
                var user:User = packet.data;

                if (DatabaseManager.getUserByUsername(user.username) != null) {
                    req.replyData("Username taken", "text/plain", 409);
                    return;
                }

                final db = DatabaseManager.read();
                final latestId = db.users[db.users.length - 1].id;

                user.id = latestId + 1;

                DatabaseManager.addUser(user);
            case ADD_CHANNEL:
                var channel:Channel = packet.data;

                final db = DatabaseManager.read();
                final latestId = db.channels[db.channels.length - 1].id;

                channel.id = latestId + 1;

                DatabaseManager.addChannel(channel);
            case EDIT_USER:
            case EDIT_CHANNEL:
            case REMOVE_USER:
            case REMOVE_CHANNEL:
            case GET_USER:
            case GET_CHANNEL:
        }

        req.replyData("Internal server error", "text/plain", 500);
    }
}
