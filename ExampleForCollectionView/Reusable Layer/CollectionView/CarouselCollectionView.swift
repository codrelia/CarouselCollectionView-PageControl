import UIKit

// MARK: - CarouselCollectionViewDataSource

@objc protocol CarouselCollectionViewDataSource {

    var numberOfItems: Int { get }
    var heightCell: Double { get }
    var widthCell: Double { get }
    var lineSpacing: Double { get }

}

// MARK: - CarouselCollectionView

final class CarouselCollectionView: UICollectionView {

    // MARK: - Properties

    public weak var carouselDataSource: CarouselCollectionViewDataSource?
    public weak var pageControlInput: PageControlInput?
    public var isAutoscrollEnabled = true

    // MARK: - Private Properties

    private var initialScrollOffset = 0.0
    private var finalScrollOffset = 0.0
    private var currentPageIndex = 0 {
        didSet(newValue) {
            if currentPageIndex >= fakeNumberOfPages {
                currentPageIndex = fakeNumberOfPages - 1
            }
            if currentPageIndex < 0 {
                currentPageIndex = 0
                initialScrollOffset = 0
                finalScrollOffset = 0
            }
        }
    }

    private var fakeNumberOfPages: Int {
        return (carouselDataSource?.numberOfItems ?? 0) + 2
    }

    private var offsetBetweenScrolls: Double {
        return finalScrollOffset - initialScrollOffset
    }

    private var autoscrollingTimer = Timer()

    // MARK: - Initialization

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupCollectionView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    // MARK: - Methods

    func startTimer() {
        if isAutoscrollEnabled {
            autoscrollingTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(autoscrollToIndex), userInfo: nil, repeats: true)
            RunLoop.main.add(autoscrollingTimer, forMode: .common)
        }
    }

}

// MARK: - Actions

private extension CarouselCollectionView {

    @objc func autoscrollToIndex() {
        scrollToItem(at: [0, currentPageIndex + 1], at: .left, animated: true)
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension CarouselCollectionView: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let width = carouselDataSource?.widthCell, let height = carouselDataSource?.heightCell else {
            return UICollectionViewFlowLayout.automaticSize
        }
        return CGSize(width: width, height: height)
    }

}

// MARK: - UIScrollViewDelegate

extension CarouselCollectionView: UIScrollViewDelegate {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialScrollOffset = scrollView.contentOffset.x
        isAutoscrollEnabled = false
        autoscrollingTimer.invalidate()
    }

    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        targetContentOffset.pointee = scrollView.contentOffset
        changeCurrentPage()
        initialScrollOffset = scrollView.contentOffset.x
        scrollToItem(at: currentPageIndex, animated: true)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if currentPageIndex == carouselDataSource?.numberOfItems {
            scrollToItem(at: 0)
        }
        setupPageControl()
        initialScrollOffset = scrollView.contentOffset.x
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Фиксируем текущее положение контента

        finalScrollOffset = scrollView.contentOffset.x
        guard let width = carouselDataSource?.widthCell, let lineSpacing = carouselDataSource?.lineSpacing else {
            return
        }

        // Проверяем текущий прогресс скролла

        var scrollProgress = offsetBetweenScrolls / (width + lineSpacing)
        if abs(scrollProgress) - floor(abs(scrollProgress)) == 0 {
            scrollProgress = 1
            changeCurrentPage()
            setupPageControl()
            initialScrollOffset = finalScrollOffset
        } else {
            let integerPartScrollProgress = scrollProgress < 0 ? ceil(scrollProgress) : floor(scrollProgress)
            if abs(integerPartScrollProgress) > 0 {
                currentPageIndex = currentPageIndex + (scrollProgress < 0 ? -1 : 1)
                setupPageControl()
                initialScrollOffset = finalScrollOffset
            }
            if currentPageIndex == carouselDataSource?.numberOfItems && integerPartScrollProgress != 0 && scrollProgress > 0 {
                scrollToItem(at: 0)
                setupPageControl()
            }
            scrollProgress -= integerPartScrollProgress
        }

        // Если мы начинаем скроллить влево находясь на 0 элементе,
        // то мы автоматически скроллим к предпоследнему элементу
        
        pageControlInput?.setProgress(scrollProgress)
        if scrollView.contentOffset.x < 0 && currentPageIndex == 0 {
            scrollToItem(at: fakeNumberOfPages - 2)
            setupPageControl()
            initialScrollOffset = finalScrollOffset
        }
    }

}

// MARK: - Private Methods

private extension CarouselCollectionView {
    
    func setupCollectionView() {
        showsHorizontalScrollIndicator = false
        delegate = self
    }
    
    func scrollToItem(at item: Int, at scrollPosition: UICollectionView.ScrollPosition = .left, animated: Bool = false) {
        scrollToItem(at: [0, item], at: scrollPosition, animated: animated)
        currentPageIndex = item
    }
    
    func changeCurrentPage() {
        if offsetBetweenScrolls > 0 {
            currentPageIndex += 1
        } else {
            currentPageIndex -= 1
        }
    }
    
    func setupPageControl() {
        guard let pageControlInput = pageControlInput else {
            return
        }
        pageControlInput.setProgress(1.0)
        if currentPageIndex == 0 {
            pageControlInput.setCurrentPage(2)
        } else if currentPageIndex == 4 {
            pageControlInput.setCurrentPage(0)
        } else {
            pageControlInput.setCurrentPage(currentPageIndex - 1)
        }
    }
    
}
