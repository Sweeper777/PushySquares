public enum Tile {
    case empty
    case void
    case wall
    case square(Color)
    case spawn(Color)
}

public enum Color {
    case color1
    case color2
    case color3
    case color4
    case grey
}
