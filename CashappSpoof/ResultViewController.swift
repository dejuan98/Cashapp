//
//  ResultViewController.swift
//  CashappSpoof
//
//  Created by Ethan Keiser on 12/12/21.
//

import UIKit

// MARK: - ResultViewController

/// Displays the final transaction result and lets the user share a screenshot
/// of the receipt card via the system share sheet.
class ResultViewController: UIViewController {

    // MARK: - IBOutlets

    /// The card-style container view that represents the "receipt."
    /// Wire this outlet to the top-level content card in the storyboard so that
    /// only the receipt area is captured — not the full screen chrome (nav bar,
    /// share button, etc.).
    /// If the outlet is not connected, the renderer falls back to capturing the
    /// entire view controller's view.
    @IBOutlet weak var receiptCardView: UIView?

    // MARK: - Private UI

    /// "Share Receipt" button created programmatically so no storyboard edit is
    /// required.  If you prefer to create the button entirely in Interface
    /// Builder, delete the `buildShareButton()` call from `viewDidLoad`, draw
    /// the button in the storyboard, and connect its Touch Up Inside action to
    /// `shareReceiptTapped(_:)`.
    private var shareButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Show a back/close button in the navigation bar
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(close)
        )

        buildShareButton()
    }

    // MARK: - Navigation Bar Action

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Share Button Construction

    /// Programmatically creates and pins the "Share Receipt" button to the
    /// bottom of the safe area.  This keeps the storyboard unchanged while
    /// still producing a fully functional share button.
    private func buildShareButton() {
        let button = UIButton(type: .system)
        button.setTitle("Share Receipt", for: .normal)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)

        // Match Cash App's signature green used throughout the app
        let cashGreen = UIColor(red: 0/255, green: 212/255, blue: 106/255, alpha: 1.0)
        button.backgroundColor  = cashGreen
        button.tintColor        = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)

        // Space the image and title apart slightly
        button.semanticContentAttribute = .forceLeftToRight
        button.imageEdgeInsets  = UIEdgeInsets(top: 0, left: 0,  bottom: 0, right: 10)
        button.titleEdgeInsets  = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)

        button.layer.cornerRadius  = 14
        button.layer.masksToBounds = true

        button.addTarget(self, action: #selector(shareReceiptTapped(_:)), for: .touchUpInside)

        // ── Auto Layout ───────────────────────────────────────────────────────
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,  constant: 24),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,    constant: -20),
            button.heightAnchor.constraint(equalToConstant: 54),
        ])

        shareButton = button
    }

    // MARK: - Share Action

    /// Called when the "Share Receipt" button is tapped (programmatic target) or
    /// when the storyboard button's Touch Up Inside action fires.
    ///
    /// Sequence:
    ///   1. Render the receipt card (or full view) into a `UIImage`.
    ///   2. Present `UIActivityViewController` with that image plus a fallback
    ///      text string so share destinations that can't accept images (e.g.
    ///      plain-text copy) still receive something useful.
    @IBAction func shareReceiptTapped(_ sender: Any) {
        // 1. Determine which view to capture
        let targetView: UIView = receiptCardView ?? view

        // 2. Render the target view into a UIImage at the device's native scale
        let image = renderViewToImage(targetView)

        // 3. Build the activity items:
        //    - The UIImage is the primary shareable item.
        //    - The String acts as a subject / fallback for destinations that
        //      only accept text (e.g. Mail subject, Slack message).
        let activityItems: [Any] = [
            image,
            "Check out my Cash App receipt! 💸"
        ]

        // 4. Present the share sheet
        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )

        // Exclude activity types that are irrelevant for a receipt image
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks,
        ]

        // iPad requires a sourceView / sourceRect or barButtonItem for the
        // popover anchor; on iPhone this is a no-op.
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
            popover.permittedArrowDirections = .down
        }

        present(activityVC, animated: true, completion: nil)
    }

    // MARK: - Image Rendering Helper

    /// Captures `targetView` into a `UIImage` using `UIGraphicsImageRenderer`.
    ///
    /// - Parameter targetView: The view whose visual contents should be rendered.
    /// - Returns: A `UIImage` snapshot of the view at the screen's native scale.
    ///
    /// `UIGraphicsImageRenderer` is the modern, preferred API over the older
    /// `UIGraphicsBeginImageContextWithOptions` pattern.  It automatically
    /// handles the display scale and colour space for the current device,
    /// producing crisp images on all screen densities (1×, 2×, 3×).
    private func renderViewToImage(_ targetView: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(
            size: targetView.bounds.size,
            format: {
                // Use the screen's native display scale so the output is
                // pixel-perfect on Retina / Super Retina displays.
                let fmt = UIGraphicsImageRendererFormat.default()
                fmt.scale = UIScreen.main.scale
                // opaque = false preserves any transparency in the view
                // (e.g. rounded corners showing through to the background).
                fmt.opaque = false
                return fmt
            }()
        )

        let image = renderer.image { rendererContext in
            // `drawHierarchy(in:afterScreenUpdates:)` captures the full
            // rendered layer tree including shadows, borders, and gradients —
            // which is exactly what we want for a receipt card snapshot.
            // `afterScreenUpdates: true` ensures any pending layout / display
            // passes have flushed before we capture.
            targetView.drawHierarchy(in: targetView.bounds, afterScreenUpdates: true)
        }

        return image
    }
}
