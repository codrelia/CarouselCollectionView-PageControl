import UIKit

final class ProgressPageControl: UIView {

    // MARK: - Properties

    var dotWidth: CGFloat = 8.0
    var dotHeight: CGFloat = 4.0
    var dotAddActiveWidth: CGFloat = 16.0
    var dotSpacing: CGFloat = 4.0

    var activeColor: UIColor = UIColor(named: "active") ?? .gray
    var inactiveColor: UIColor = UIColor(named: "inactive") ?? .systemIndigo

    var currentPage: Int = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    var numberOfPages: Int = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    var scrollProgress: Double = 1.0 {
        didSet {
            setNeedsLayout()
        }
    }

    // MARK: - Private Properties

    private var dots: [UIView] = []
    private var cornerRadius: CGFloat = 2.0
    private var nextPage: Int {
        var nextPage = currentPage
        if scrollProgress > 0 && scrollProgress < 1 {
            nextPage += 1
            nextPage %= numberOfPages
        } else if scrollProgress < 0 {
            nextPage -= 1
            if nextPage < 0 {
                nextPage = numberOfPages + nextPage
            }
        } else if scrollProgress == 1 {
            nextPage = currentPage
        }
        return nextPage
    }
    private var totalWidth: CGFloat {
        return CGFloat(numberOfPages - 2) * dotWidth + CGFloat(max(numberOfPages - 1, 0)) * dotSpacing + CGFloat(1) * (dotWidth + dotAddActiveWidth * abs(scrollProgress)) + CGFloat(1) * (dotWidth + dotAddActiveWidth - dotAddActiveWidth * abs(scrollProgress))
    }

    // MARK: - UIPageControl

    public override func layoutSubviews() {
        super.layoutSubviews()
        deleteAllDots()

        // Определяем расположение точек
        var x = (bounds.width - totalWidth) / 2.0
        let y = (bounds.height - dotWidth) / 2.0
        for i in 0..<numberOfPages {
            let currentDotWidth = configureDotWidth(for: i)
            let dot = createDot(for: i, x: x, y: y, width: currentDotWidth)
            addSubview(dot)
            dots.append(dot)
            
            x += currentDotWidth + dotSpacing
        }
    }
    
}

// MARK: - PageControlInput

extension ProgressPageControl: PageControlInput {

    func setProgress(_ progress: Double) {
        scrollProgress = progress
    }
    
    func setCurrentPage(_ page: Int) {
        currentPage = page
    }
    
}

// MARK: - Private Methods

private extension ProgressPageControl {
    
    func deleteAllDots() {
        for dot in dots {
            dot.removeFromSuperview()
        }
        dots.removeAll()
    }
    
    func configureDotWidth(for index: Int) -> CGFloat {
        var dotWidth: CGFloat = 0
        if index == nextPage {
            dotWidth = self.dotWidth + (dotAddActiveWidth * abs(scrollProgress))
        } else if index == currentPage {
            dotWidth = self.dotWidth + dotAddActiveWidth - (dotAddActiveWidth * abs(scrollProgress))
        } else {
            dotWidth = self.dotWidth
        }
        return dotWidth
    }
    
    func createDot(for index: Int, x: Double, y: Double, width: Double) -> UIView {
        let dot = UIView(
            frame: CGRect(
                x: x,
                y: y,
                width: width,
                height: dotHeight
            )
        )
        dot.layer.cornerRadius = cornerRadius
        if index == nextPage {
            dot.backgroundColor = UIColor.interpolate(
                from: inactiveColor,
                to: activeColor,
                with: abs(scrollProgress)
            )
        } else if index == currentPage {
            dot.backgroundColor = UIColor.interpolate(
                from: activeColor,
                to: inactiveColor,
                with: abs(scrollProgress)
            )
        } else {
            dot.backgroundColor = inactiveColor
        }
        return dot
    }

}
