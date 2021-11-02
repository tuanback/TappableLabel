//
//  TapableLabel.swift
//

import UIKit

class TappableString {
    let text: String
    let action: () -> ()
    
    init(text: String, action: @escaping () -> ()) {
        self.text = text
        self.action = action
    }
}

class TapableLabel: UILabel {

    private let tappableStrings: [TappableString]
    private let containerString: String
    private let normalTextColor: UIColor
    private let tappableTextColor: UIColor
    
    init(tappableStrings: [TappableString],
         containerString: String,
         font: UIFont,
         normalTextColor: UIColor,
         tappableTextColor: UIColor,
         frame: CGRect = .zero) {
        self.tappableStrings = tappableStrings
        self.containerString = containerString
        self.normalTextColor = normalTextColor
        self.tappableTextColor = tappableTextColor
        
        super.init(frame: frame)
        setupViews(font: font)
    }
    
    @available (*, unavailable, message: "Prefer to inject text, not support nib")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(font: UIFont) {
        textColor = normalTextColor
        lineBreakMode = .byWordWrapping
        numberOfLines = 0
        isUserInteractionEnabled = true
        self.font = font
        
        attributedText = getAttributedText()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(agreementTapAction))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func getAttributedText() -> NSAttributedString {
        let agreementAttributedString = NSMutableAttributedString(string: containerString)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        
        let containerRange = (containerString as NSString).range(of: containerString)
        
        agreementAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: containerRange)
        
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.appTintColor,
        ]
        
        for tappableStr in tappableStrings {
            let strRange = (containerString as NSString).range(of: tappableStr.text)
            agreementAttributedString.addAttributes(linkAttributes, range: strRange)
        }
        
        return agreementAttributedString
    }
    
    @objc
    private func agreementTapAction(gesture: UITapGestureRecognizer) {
        handleAgreementTap(gesture: gesture)
    }
    
    private func handleAgreementTap(gesture: UITapGestureRecognizer) {
        
        for tappableStr in tappableStrings {
            if gesture.didTapAttributedTextIn(label: self, inRange: (containerString as NSString).range(of: tappableStr.text)) {
                tappableStr.action()
                return
            }
        }
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextIn(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                    y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
