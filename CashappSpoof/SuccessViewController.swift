//
//  SuccessViewController.swift
//  CashappSpoof
//
//  Created by Ethan Keiser on 12/13/21.
//

import UIKit

// MARK: - SuccessViewController

class SuccessViewController: UIViewController {

    // MARK: - Public Properties

    /// The formatted currency string passed in by LoadingViewController, e.g. "$25.00"
    var amount   = ""
    /// The recipient's $cashtag or name passed in by LoadingViewController
    var userName = ""

    // MARK: - IBOutlets

    @IBOutlet weak var topLabel:    UILabel!
    @IBOutlet weak var bottomLabel: UILabel!

    // MARK: - Private Constants

    /// Diameter of the animated circle (matches typical Cash App success badge size)
    private let circleDiameter: CGFloat = 120.0

    /// Stroke colour — Cash App signature green
    private let cashGreen = UIColor(red: 0/255, green: 212/255, blue: 106/255, alpha: 1.0)

    /// Total duration of the full animation sequence
    private let totalDuration: CFTimeInterval = 0.60

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        topLabel.text    = "You sent \(amount)"
        bottomLabel.text = "to \(userName)"

        // Hide labels initially; they fade in after the animation completes
        topLabel.alpha    = 0.0
        bottomLabel.alpha = 0.0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runSuccessAnimation()
    }

    // MARK: - IBActions

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Animation

    /// Builds the circle + checkmark layers and sequences their stroke animations.
    private func runSuccessAnimation() {

        // ── 1. Layout constants ──────────────────────────────────────────────

        let circleDuration:    CFTimeInterval = totalDuration * 0.55  // 0.33 s
        let checkmarkDuration: CFTimeInterval = totalDuration * 0.45  // 0.27 s
        let checkmarkDelay:    CFTimeInterval = circleDuration        // starts when circle finishes

        let containerSize = CGSize(width: circleDiameter, height: circleDiameter)

        // Centre the container above the two text labels
        // Place it roughly in the upper-centre of the view
        let centerX = view.bounds.midX
        let centerY = view.bounds.midY - 80.0   // nudge upward to leave room for labels

        let containerOrigin = CGPoint(
            x: centerX - containerSize.width  / 2,
            y: centerY - containerSize.height / 2
        )

        // ── 2. Container view (clips layers, makes positioning simple) ───────

        let container = UIView(frame: CGRect(origin: containerOrigin, size: containerSize))
        container.backgroundColor = .clear
        view.addSubview(container)

        // ── 3. Circle layer ──────────────────────────────────────────────────

        let circleLayer            = buildCircleLayer(in: container.bounds)
        circleLayer.strokeColor    = cashGreen.cgColor
        circleLayer.fillColor      = cashGreen.cgColor   // filled disc, not just a ring
        container.layer.addSublayer(circleLayer)

        // Stroke animation that draws the circle outline first, then fills
        // We animate the filled disc by treating it as a strokeEnd on a path that
        // is also filled — the disc pops in as the stroke completes because fill
        // is always painted; a scale-in gives the "pop" feel instead.
        circleLayer.transform = CATransform3DMakeScale(0, 0, 1)

        let scaleIn                = CABasicAnimation(keyPath: "transform.scale")
        scaleIn.fromValue          = 0.0
        scaleIn.toValue            = 1.0
        scaleIn.duration           = circleDuration
        scaleIn.timingFunction     = CAMediaTimingFunction(name: .easeOut)
        scaleIn.fillMode           = .forwards
        scaleIn.isRemovedOnCompletion = false
        circleLayer.add(scaleIn, forKey: "circleScaleIn")

        // ── 4. Ring outline (thin white border so it reads on any background) ─

        let ringLayer            = buildCircleLayer(in: container.bounds)
        ringLayer.strokeColor    = UIColor.white.withAlphaComponent(0.25).cgColor
        ringLayer.fillColor      = UIColor.clear.cgColor
        ringLayer.lineWidth      = 2.0
        container.layer.addSublayer(ringLayer)

        // ── 5. Checkmark layer ───────────────────────────────────────────────

        let checkLayer         = buildCheckmarkLayer(in: container.bounds)
        checkLayer.strokeEnd   = 0.0            // hidden until its animation starts
        container.layer.addSublayer(checkLayer)

        let strokeAnim                 = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnim.fromValue           = 0.0
        strokeAnim.toValue             = 1.0
        strokeAnim.beginTime           = CACurrentMediaTime() + checkmarkDelay
        strokeAnim.duration            = checkmarkDuration
        strokeAnim.timingFunction      = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeAnim.fillMode            = .forwards
        strokeAnim.isRemovedOnCompletion = false
        checkLayer.add(strokeAnim, forKey: "checkmarkStroke")

        // ── 6. Fade in labels after both animations complete ─────────────────

        let labelsDelay = checkmarkDelay + checkmarkDuration + 0.05
        UIView.animate(
            withDuration: 0.30,
            delay:        labelsDelay,
            options:      .curveEaseIn,
            animations: { [weak self] in
                self?.topLabel.alpha    = 1.0
                self?.bottomLabel.alpha = 1.0
            }
        )
    }

    // MARK: - Layer Builders

    /// Returns a CAShapeLayer whose path is a circle that fills `rect`.
    private func buildCircleLayer(in rect: CGRect) -> CAShapeLayer {
        let inset: CGFloat = 1.0          // keep stroke inside the container bounds
        let circleRect     = rect.insetBy(dx: inset, dy: inset)
        let circlePath     = UIBezierPath(ovalIn: circleRect)

        let layer          = CAShapeLayer()
        layer.path         = circlePath.cgPath
        layer.fillColor    = UIColor.clear.cgColor
        layer.strokeColor  = UIColor.clear.cgColor
        layer.lineWidth    = 0
        return layer
    }

    /// Returns a CAShapeLayer whose path draws a single-stroke checkmark
    /// centred within `rect`.  The checkmark intentionally matches Cash App's
    /// proportions: a short left leg and a longer right upstroke.
    private func buildCheckmarkLayer(in rect: CGRect) -> CAShapeLayer {
        let w = rect.width
        let h = rect.height

        // Checkmark control points (as fractions of the container size)
        //   start  → the bottom-left of the tick
        //   middle → the valley / bottom tip of the tick
        //   end    → the top-right of the tick
        let startPoint  = CGPoint(x: w * 0.22, y: h * 0.52)
        let middlePoint = CGPoint(x: w * 0.42, y: h * 0.68)
        let endPoint    = CGPoint(x: w * 0.76, y: h * 0.34)

        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: middlePoint)
        path.addLine(to: endPoint)

        let layer             = CAShapeLayer()
        layer.path            = path.cgPath
        layer.fillColor       = UIColor.clear.cgColor
        layer.strokeColor     = UIColor.white.cgColor
        layer.lineWidth       = 7.0
        layer.lineCap         = .round
        layer.lineJoin        = .round
        return layer
    }
}
