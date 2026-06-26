//
//  ActivityCell.swift
//  CashappSpoof
//
//  Created by Ethan Keiser on 12/14/21.
//

import UIKit

// MARK: - ActivityItem

/// Lightweight value type that carries the data for a single transaction row.
/// Kept here so `ActivityCell` is self-contained and no changes to DataManager
/// are required — callers can construct one from whatever backing store they use.
struct ActivityItem {
    /// Display name of the other party (e.g. "Jane Doe" or "$janedoe").
    let name: String
    /// Formatted amount string, including sign and currency symbol (e.g. "+$25.00").
    let amount: String
    /// Secondary descriptor shown below the name (e.g. date, note, or "Cash Out").
    let subtitle: String
    /// Optional explicit avatar background colour.
    /// Pass `nil` to derive a deterministic colour from `name` automatically.
    let avatarColor: UIColor?

    init(name: String, amount: String, subtitle: String, avatarColor: UIColor? = nil) {
        self.name        = name
        self.amount      = amount
        self.subtitle    = subtitle
        self.avatarColor = avatarColor
    }
}

// MARK: - ActivityCell

class ActivityCell: UITableViewCell {

    // MARK: Outlets

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    /// Container view used as the avatar canvas.  Backed by a plain `UIView`
    /// in the storyboard; `configure(with:)` renders a circular initials image
    /// into it programmatically so no storyboard changes are needed.
    @IBOutlet weak var profileImageView: UIView!

    // MARK: - Tag constants

    /// Stable tag used to identify the `UIImageView` we embed inside
    /// `profileImageView` so we can reuse / replace it on cell reuse.
    private static let avatarImageViewTag = 42

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Configuration

    /// Populates the cell with transaction data and renders a circular initials
    /// avatar inside `profileImageView`.
    ///
    /// - Parameter item: The `ActivityItem` containing all display values.
    func configure(with item: ActivityItem) {
        // -- Text labels -------------------------------------------------
        topLabel.text    = item.name
        amountLabel.text = item.amount
        bottomLabel.text = item.subtitle

        // -- Avatar ------------------------------------------------------
        renderAvatar(name: item.name, avatarColor: item.avatarColor)
    }

    // MARK: - Private

    /// Renders a circular initials avatar into `profileImageView`.
    ///
    /// On every call we either reuse the existing `UIImageView` child (identified
    /// by `avatarImageViewTag`) or create a fresh one — this keeps the method
    /// safe to call repeatedly during cell reuse without leaking subviews.
    private func renderAvatar(name: String, avatarColor: UIColor?) {
        guard let container = profileImageView else { return }

        // Use the container's own bounds for the avatar size, falling back to a
        // sensible default if layout has not yet occurred (e.g. during unit tests).
        let side = container.bounds.width > 0 ? container.bounds.width : 40

        // Generate the initials image using the factory on UIImage.
        let avatarImage = UIImage.makeInitialsAvatar(
            name: name,
            backgroundColor: avatarColor,
            size: side
        )

        // Locate an existing avatar image view or create one.
        let imageView: UIImageView
        if let existing = container.viewWithTag(ActivityCell.avatarImageViewTag) as? UIImageView {
            imageView = existing
        } else {
            let iv = UIImageView()
            iv.tag = ActivityCell.avatarImageViewTag
            iv.contentMode = .scaleAspectFill
            iv.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(iv)
            // Pin to all four edges of the container.
            NSLayoutConstraint.activate([
                iv.topAnchor.constraint(equalTo: container.topAnchor),
                iv.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                iv.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                iv.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            imageView = iv
        }

        imageView.image = avatarImage

        // Make the container (and the image view) clip to a circle.
        container.layer.cornerRadius  = container.bounds.width / 2
        container.clipsToBounds       = true
        imageView.layer.cornerRadius  = container.layer.cornerRadius
        imageView.clipsToBounds       = true
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        // Re-apply corner radius after Auto Layout has resolved final bounds,
        // ensuring the circle stays correct on all device sizes and orientations.
        if let container = profileImageView {
            let radius = container.bounds.width / 2
            container.layer.cornerRadius = radius
            container.clipsToBounds      = true

            if let iv = container.viewWithTag(ActivityCell.avatarImageViewTag) as? UIImageView {
                iv.layer.cornerRadius = radius
                iv.clipsToBounds      = true
            }
        }
    }
}
