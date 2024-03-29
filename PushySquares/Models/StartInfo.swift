import MultipeerConnectivity
import PushySquaresModel

final class StartInfo : NSObject, NSCoding {
    let turns: [MCPeerID: Color]
    let map: String

    enum Keys: CodingKey {
        case turns
        case map
    }

    init(turns: [MCPeerID: Color], map: String) {
        self.turns = turns
        self.map = map
    }

    func encode(with coder: NSCoder) {
        coder.encode(turns.mapValues(\.rawValue), forKey: Keys.turns.stringValue)
        coder.encode(map, forKey: Keys.map.stringValue)
    }

    convenience init?(coder: NSCoder) {
        guard let turns = coder.decodeObject(of: NSDictionary.self, forKey: Keys.turns.stringValue) as? [MCPeerID: Int] else {
            return nil
        }
        guard let map = coder.decodeObject(of: NSString.self, forKey: Keys.map.stringValue) as String? else {
            return nil
        }
    self.init(turns: turns.mapValues { Color(rawValue: $0)! }, map: map)
    }

    override var description: String {
        "StartInfo(turns: \(turns), map: \(map))"
    }
}
