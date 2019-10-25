import ballerina/docker;
import ballerina/http;
import ballerina/io;
import ballerina/log;


http:Client telegramClient = new ("https://api.telegram.org");

string | error apiKey = error("InvalidBotAPIKey", message = "invalid api key of your bot. extract it from botfather");
string chatID = "";

error telegramBadResponse = error("TelegramBadResponse", message = "telegram returns a bad response, your credentials or chatid are incorrect");
error invalidMessage = error("InvalidMessage", message = "your message are empty, write something for your channel");
error invalidChannelID = error("InvalidChannelID", message = "telegram returns a bad response, your credentials or chatid are incorrect");


function sendMessage(@untainted string chatID,@untainted string message) returns error? {
    string chat = chatID;
    if (!chatID.startsWith("@")) {
        chat = "@" + chatID;
    }

    string url = string `/bot${<string>apiKey}/sendMessage?chat_id=${chat}&text=${message}`;
    
    io:println(url);

    var response = telegramClient->get(url);
    if (response is http:Response) {
        if (response.statusCode != http:STATUS_OK) {
            io:println(response.getTextPayload().toString());
            return telegramBadResponse;
        }
    }
}

@docker:Expose {}
listener http:Listener marvinEP = new(3300);

@docker:Config {
    name: "marvin",
    tag: "lasted"
}

@http:ServiceConfig {basePath: "/marvin"}
service marvin on marvinEP {

    @http:ResourceConfig {methods: ["POST"], path: "/"}
    resource function emit(http:Caller caller, http:Request req) {
        var data = req.getJsonPayload();
        if (data is json) {
            http:Response res = new ();

            json | error message = <@untainted>data.message;

            if (message is error) {
                res.setJsonPayload({"error": message.toString()});
                res.statusCode = http:STATUS_BAD_REQUEST;
                checkpanic caller->respond(res);
                return;
            }

            if (message == "") {
                res.setJsonPayload({"error": invalidMessage.toString()});
                res.statusCode = http:STATUS_BAD_REQUEST;
                checkpanic caller->respond(res);
                return;
            }

            if (chatID == "") {
                json | error chat = <@untainted>data.chat;
                if (chat is error) {
                    res.setJsonPayload({"error": message.toString()});
                    res.statusCode = http:STATUS_BAD_REQUEST;
                    checkpanic caller->respond(res);
                    return;
                }
            }

            var err = sendMessage(chatID, <string>message);
            if (err is error) {
                res.setJsonPayload({"error": err.toString()});
                res.statusCode = http:STATUS_BAD_REQUEST;
                checkpanic caller->respond(res);
            }

            res.setJsonPayload({"message": "ok, message sent"});
            res.statusCode = http:STATUS_OK;
            checkpanic caller->respond(res);

        } else {
            string debug = string `Client response: ${data.reason()}`;
            log:printDebug(debug);
        }
    }
}

public function main(string botAPIKey, string chat = "", string message = "", int port = 3300) returns error? {
    if (botAPIKey.length() < 30) {
        if (apiKey is error) {
            return <error?>apiKey;
        }
    }

    apiKey = <@untainted><string | error>botAPIKey;

    io:println(string `I'm here with key=${<string>apiKey} and chat=${chat} and message=${message}`);

    if (chat != "") {
        chatID = <@untainted>chat;
        if (message != "") {
            error? err = sendMessage(<@untainted>chat, <@untainted>message);
            if (err is error) {
                return err;
            }
            return error("OK, message send");
        }

    }
}
