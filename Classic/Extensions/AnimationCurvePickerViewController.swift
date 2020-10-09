/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

protocol AnimationCurvePickerViewControllerDelegate: class {

  func animationCurvePickerViewController(_ controller: AnimationCurvePickerViewController, didSelectCurve curve: UIView.AnimationCurve)

}

class AnimationCurvePickerViewController: UITableViewController {

  static let cellID = "curveCellID"

  let curves: [UIView.AnimationCurve] = [
    .easeIn,
    .easeOut,
    .easeInOut,
    .linear
  ]

  weak var delegate: AnimationCurvePickerViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: AnimationCurvePickerViewController.cellID)
  }

}

// MARK: UITableViewDataSource
extension AnimationCurvePickerViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return curves.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: AnimationCurvePickerViewController.cellID, for: indexPath)
    cell.textLabel?.text = curves[indexPath.row].title
    return cell
  }

}

// MARK: UITableViewControllerDelegate
extension AnimationCurvePickerViewController {

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.animationCurvePickerViewController(self, didSelectCurve: curves[indexPath.row])
  }

}

// MARK: UIViewAnimationCurve Extensions
// MARK: - An extension that translates `UIView.AnimationCurve` into useful types
extension UIView.AnimationCurve {

  /// Produces a user-displayable title for the curve
  var title: String {
    switch self {
    case .easeIn: return "Ease In"
    case .easeOut: return "Ease Out"
    case .easeInOut: return "Ease In Out"
    case .linear: return "Linear"
    }
  }

  /// Converts this curve into it's corresponding UIView.AnimationOptions value for use in animations
  var animationOption: UIView.AnimationOptions {
    switch self {
    case .easeIn: return .curveEaseIn
    case .easeOut: return .curveEaseOut
    case .easeInOut: return .curveEaseInOut
    case .linear: return .curveLinear
    }
  }

}
