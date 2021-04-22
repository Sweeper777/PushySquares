import UIKit

class NearbyPeerCell: UITableViewCell {

    var peerNameLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        v.textAlignment = .left
        v.font = UIFont(name: "Chalkboard SE", size: 17)
        v.textColor = .black
        v.setContentHuggingPriority(.required, for: .horizontal)
        v.setContentHuggingPriority(.required, for: .vertical)
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        v.setContentCompressionResistancePriority(.required, for: .vertical)
        return v
    }()

    var connectionStatusLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        v.textAlignment = .right
        v.font = UIFont(name: "Chalkboard SE", size: 17)
        v.textColor = .black
        v.setContentHuggingPriority(.required, for: .horizontal)
        v.setContentHuggingPriority(.required, for: .vertical)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        v.setContentCompressionResistancePriority(.required, for: .vertical)
        return v
    }()

    var theStackView: UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .horizontal
        v.alignment = .top
        v.distribution = .fill
        v.spacing = 8
        v.setContentHuggingPriority(.required, for: .vertical)
        v.setContentCompressionResistancePriority(.required, for: .vertical)
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() -> Void {

        contentView.addSubview(theStackView)
        theStackView.addArrangedSubview(peerNameLabel)
        theStackView.addArrangedSubview(connectionStatusLabel)

        let g = contentView.layoutMarginsGuide

        NSLayoutConstraint.activate([
            theStackView.topAnchor.constraint(equalTo: g.topAnchor, constant: 0.0),
            theStackView.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: 0.0),
            theStackView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 0.0),
            theStackView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: 0.0),
        ])

    }

}
