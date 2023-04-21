import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pageControl: ProgressPageControl!
    @IBOutlet weak var collectionView: CarouselCollectionView!

    let data = ["🥝", "🍍", "🍓", "🥝", "🍍"]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.carouselDataSource = self
        collectionView.pageControlInput = pageControl

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 12
            layout.minimumLineSpacing = 12
        }
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CollectionViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
        collectionView.startTimer()
    }


}

extension ViewController: CarouselCollectionViewDataSource {
    var numberOfItems: Int {
        return data.count - 2
    }
    
    var heightCell: Double {
        return 128.0
    }
    
    var widthCell: Double {
        return 256.0
    }
    
    var lineSpacing: Double {
        return 12.0
    }
    
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = data.count - 2
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.nameLabel.text = data[indexPath.row]
        return cell
    }
    
    
}

