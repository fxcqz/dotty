module message;

public struct Message {
public:
    string text;
    string sender;
    string eventID;

    Message asCommand(size_t len) const {
        return Message(text[len + 1 .. $], sender, eventID);
    }
}