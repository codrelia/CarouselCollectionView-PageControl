import Foundation

protocol PageControlInput: AnyObject {

    func setProgress(_ progress: Double)
    func setCurrentPage(_ page: Int)

}
