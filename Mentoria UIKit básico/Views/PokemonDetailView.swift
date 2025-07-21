import UIKit

protocol PokemonDetailViewDelegate: AnyObject {
    func didTapFavorite()
}

class PokemonDetailView: UIView {
    weak var delegate: PokemonDetailViewDelegate?
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        return button
    }()
    
    private var isFavorited = false {
        didSet {
            let imageName = isFavorited ? "heart.fill" : "heart"
            favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        //
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOpacity = 0.2
        iv.layer.shadowOffset = CGSize(width: 0, height: 2)
        iv.layer.shadowRadius = 4
        //
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [heightLabel, weightLabel])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            nameLabel,
            typesStackView,
            infoStackView,
            favoriteButton
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(cardView)
        cardView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            mainStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            
            typesStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func createTypeLabel(for type: PokemonType) -> UILabel {
        let label = UILabel()
        label.text = type.getTitle()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = type.getColor()
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.layoutMargins = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            label.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return label
    }
    
    private func applyBackground(with types: [PokemonType]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        var colors: [CGColor] = []
        if types.isEmpty {
            colors = [UIColor.systemBackground.cgColor, UIColor.systemGray6.cgColor]
        } else if types.count == 1 {
            let typeColor = types[0].getColor()
            colors = [
                typeColor.cgColor,
                typeColor.withAlphaComponent(0.7).cgColor
            ]
        } else {
            colors = types.prefix(2).map { $0.getColor().cgColor }
        }
        
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func configure(with pokemonDetail: PokemonDetail, isFavorited: Bool) {
        nameLabel.text = pokemonDetail.name.capitalized
        imageView.image = UIImage(named: pokemonDetail.imageUrl)
        
        for type in pokemonDetail.types {
            let typeLabel = createTypeLabel(for: type)
            typesStackView.addArrangedSubview(typeLabel)
        }
        
        heightLabel.text = "Height: \(pokemonDetail.height)m"
        weightLabel.text = "Weight: \(pokemonDetail.weight)kg"
        
        if let primaryType = pokemonDetail.types.first {
            backgroundColor = primaryType.getColor()
        }
        
        imageView.loadImage(urlString: pokemonDetail.imageUrl)
        
        applyBackground(with: pokemonDetail.types)
        
        configureButton(isFavorited: isFavorited)
    }
    
    private func configureButton(isFavorited: Bool) {
        self.isFavorited = isFavorited
    }
    
    @objc private func favoriteTapped() {
        isFavorited.toggle()
        delegate?.didTapFavorite()
    }
}
