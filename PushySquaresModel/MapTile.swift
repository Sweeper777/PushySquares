public enum MapTile : Equatable {
    case void
    case ground
    case wall
    case spawnpoint(for: Color)
    case slippery
}
