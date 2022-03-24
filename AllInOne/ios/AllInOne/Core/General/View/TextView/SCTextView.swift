//
//  SCTextView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/7.
//

import UIKit
import SwiftTheme

class SCTextView: UITextView {
    
    var placeholder: String? {
        set {
            self.placeholderLabel.text = newValue
        }
        get {
            return self.placeholderLabel.text
        }
    }
    
    private var textDidChangeBlock: ((String) -> Void)?
    private var beginEditingBlock: (() -> Void)?

    private lazy var placeholderLabel: UILabel = UILabel(textColor: "Global.TextView.placeholderColor", font: "Global.TextView.font", numberLines: 0)

    convenience init(placeholder: String? = nil, beginEditingHandle: (() -> Void)? = nil, textDidChangeHandle: ((String) -> Void)? = nil) {
        self.init(frame: .zero)
        self.placeholderLabel.text = placeholder
        self.beginEditingBlock = beginEditingHandle
        self.textDidChangeBlock = textDidChangeHandle
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.set()
        
        self.delegate = self
        self.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    func set(textColor: ThemeColorPicker = "Global.TextView.textColor", font: ThemeFontPicker = "Global.TextView.font", backgroundColor: ThemeColorPicker = "Global.TextView.backgroundColor", placeholderColor: ThemeColorPicker = "Global.TextView.placeholderColor", placeholderFont: ThemeFontPicker = "Global.TextView.font") {
        self.theme_textColor = textColor
        self.theme_font = font
        self.theme_backgroundColor = backgroundColor
        self.placeholderLabel.theme_textColor = placeholderColor
        self.placeholderLabel.theme_font = placeholderFont
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SCTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.beginEditingBlock?()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        self.placeholderLabel.isHidden = text.count > 0
        self.textDidChangeBlock?(textView.text ?? "")
    }
}
