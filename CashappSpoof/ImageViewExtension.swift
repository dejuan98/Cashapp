//
//  ImageViewExtension.swift
//  CashappSpoof
//
//  Created by Ethan Keiser on 12/18/21.
//

import Foundation
import UIKit

// MARK: - UIView Helpers

extension UIView {
    func makeCircle() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.contentMode = UIView.ContentMode.scaleAspectFit
        
    }
    func setFirstLetter(_ letter : String) {
        var letter = letter
        while let f = letter.first, f == "$" {
            letter.removeFirst()
        }
            
        let f = letter.first!
        var found = false
        for subview in self.subviews {
            if subview.tag == 88 {
            found = true
            }
        }
        if !found {
            var offset : CGFloat = 10.0
            var size : CGFloat = 17.0
            if self.bounds.height > 70 {
                size = 30
                offset = 0
            }
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height:( self.bounds.height-offset)))
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: size)
        label.text = String(f)
        label.tag = 88
        label.textColor = .white
        self.addSubview(label)
        }
    }
}

// MARK: - UIImage Initials Avatar Factory

extension UIImage {

    /// Renders a square `UIImage` containing `name`'s initials (up to two characters)
    /// centred on a filled circle of `backgroundColor`.
    ///
    /// - Parameters:
    ///   - name: The display name of the person (e.g. "John Doe" or "$johndoe").
    ///           A leading `$` cashtag prefix is stripped before extracting initials.
    ///   - backgroundColor: The fill colour of the circular background.
    ///                      Pass `nil` to derive a deterministic colour from `name`.
    ///   - size: The width and height of the output image in points. Defaults to 40 pt.
    /// - Returns: A `UIImage` of `size × size` points containing the initials avatar,
    ///            or an empty image if rendering fails.
    static func makeInitialsAvatar(
        name: String,
        backgroundColor: UIColor? = nil,
        size: CGFloat = 40
    ) -> UIImage {

        // ------------------------------------------------------------------
        // 1. Derive initials from name (strip leading '$', take first letter
        //    of each word, cap at two characters).
        // ------------------------------------------------------------------
        let initials = Self.initials(from: name)

        // ------------------------------------------------------------------
        // 2. Choose a background colour — deterministic if none supplied.
        // ------------------------------------------------------------------
        let bgColor = backgroundColor ?? Self.deterministicColor(for: name)

        // ------------------------------------------------------------------
        // 3. Render into a UIImage using the modern UIGraphicsImageRenderer.
        // ------------------------------------------------------------------
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))

        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))

            // Draw filled circle.
            bgColor.setFill()
            ctx.cgContext.fillEllipse(in: rect)

            // Choose font size proportional to the avatar size.
            let fontSize: CGFloat = size * 0.38
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: fontSize),
                .foregroundColor: UIColor.white
            ]

            let text = initials as NSString
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size - textSize.width)  / 2,
                y: (size - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }

        return image
    }

    // MARK: - Private helpers

    /// Extracts up to two initials from `name`, ignoring a leading `$` cashtag prefix.
    private static func initials(from name: String) -> String {
        // Strip leading '$' characters (cashtag prefix).
        var cleaned = name
        while cleaned.hasPrefix("$") { cleaned.removeFirst() }
        cleaned = cleaned.trimmingCharacters(in: .whitespaces)

        guard !cleaned.isEmpty else { return "?" }

        let words = cleaned.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

        switch words.count {
        case 0:
            return "?"
        case 1:
            // Single word: use first character only.
            return String(words[0].prefix(1)).uppercased()
        default:
            // Multiple words: first letter of first and last word.
            let first = String(words.first!.prefix(1))
            let last  = String(words.last!.prefix(1))
            return (first + last).uppercased()
        }
    }

    /// Produces a deterministic `UIColor` by hashing `name` into a hue value,
    /// then using a fixed saturation and brightness suitable for avatar backgrounds.
    private static func deterministicColor(for name: String) -> UIColor {
        // Use a simple hash of the UTF-8 code units to pick a hue in [0, 1).
        let hash = name.utf8.reduce(0) { (acc: UInt64, byte: UInt8) -> UInt64 in
            // FNV-1a–inspired mixing to spread values across the hue wheel.
            (acc &* 31) &+ UInt64(byte)
        }

        // Map to a hue in [0, 1).
        let hue = CGFloat(hash % 360) / 360.0

        // Fixed saturation & brightness chosen to look good on both light and dark
        // backgrounds and to ensure sufficient contrast for white text on top.
        return UIColor(hue: hue, saturation: 0.55, brightness: 0.70, alpha: 1.0)
    }
}
