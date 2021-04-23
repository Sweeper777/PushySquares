public enum MapTile : Hashable {
    case void
    case ground
    case wall
    case spawnpoint(for: Color)
    case slippery
}
