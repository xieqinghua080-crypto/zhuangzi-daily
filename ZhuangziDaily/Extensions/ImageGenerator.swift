import UIKit
import SwiftUI

// MARK: - 卡片图片生成器
enum ImageGenerator {

    /// 将签卡生成分享图片
    static func generateCardImage(sign: Sign) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 390, height: 640))

        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: 390, height: 640)

            // 白色背景
            UIColor.systemBackground.setFill()
            ctx.fill(rect)

            // 顶部装饰线
            ctx.cgContext.setStrokeColor(UIColor.systemGray4.cgColor)
            ctx.cgContext.setLineWidth(1)
            ctx.cgContext.move(to: CGPoint(x: 60, y: 40))
            ctx.cgContext.addLine(to: CGPoint(x: 330, y: 40))
            ctx.cgContext.strokePath()

            // App 名称
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.tertiaryLabel
            ]
            let title = NSAttributedString(string: "🌀 庄子的每日签", attributes: titleAttributes)
            title.draw(at: CGPoint(x: 30, y: 50))

            // 分类 icon + 名称
            let catText = "\(sign.category.icon) \(sign.category.rawValue)"
            let catAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let catString = NSAttributedString(string: catText, attributes: catAttributes)
            catString.draw(at: CGPoint(x: 30, y: 90))

            // 金句
            let quoteAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            paragraphStyle.alignment = .center

            let fullQuote = "「\(sign.quote)」"
            let quoteAttrString = NSAttributedString(string: fullQuote, attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ])
            let quoteRect = CGRect(x: 30, y: 130, width: 330, height: 120)
            quoteAttrString.draw(in: quoteRect)

            // 翻译
            let transAttrString = NSAttributedString(string: sign.translation, attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: paragraphStyle
            ])
            transAttrString.draw(in: CGRect(x: 30, y: 260, width: 330, height: 60))

            // 分隔线
            ctx.cgContext.setStrokeColor(UIColor.systemGray5.cgColor)
            ctx.cgContext.setLineWidth(1)
            ctx.cgContext.move(to: CGPoint(x: 150, y: 340))
            ctx.cgContext.addLine(to: CGPoint(x: 240, y: 340))
            ctx.cgContext.strokePath()

            // 宜
            var yiY: CGFloat = 365
            let yiAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.systemGreen
            ]
            NSAttributedString(string: "宜", attributes: yiAttr).draw(at: CGPoint(x: 60, y: yiY))

            yiY += 24
            for item in sign.advice.yi {
                let itemAttr = NSAttributedString(string: "· \(item)", attributes: [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor.secondaryLabel
                ])
                itemAttr.draw(at: CGPoint(x: 60, y: yiY))
                yiY += 20
            }

            // 忌
            var jiY: CGFloat = 365
            let jiAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.systemRed
            ]
            NSAttributedString(string: "忌", attributes: jiAttr).draw(at: CGPoint(x: 220, y: jiY))

            jiY += 24
            for item in sign.advice.ji {
                let itemAttr = NSAttributedString(string: "· \(item)", attributes: [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor.secondaryLabel
                ])
                itemAttr.draw(at: CGPoint(x: 220, y: jiY))
                jiY += 20
            }

            // 寄语
            let lessonParaStyle = NSMutableParagraphStyle()
            lessonParaStyle.lineSpacing = 6
            lessonParaStyle.alignment = .center

            let lessonAttr = NSAttributedString(string: sign.lesson, attributes: [
                .font: UIFont.italicSystemFont(ofSize: 13),
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: lessonParaStyle
            ])
            lessonAttr.draw(in: CGRect(x: 30, y: 495, width: 330, height: 60))

            // 底部水印
            let footerParaStyle = NSMutableParagraphStyle()
            footerParaStyle.alignment = .center
            let footerAttr = NSAttributedString(string: "下载「庄子的每日签」· 每天一张庄子签", attributes: [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.tertiaryLabel,
                .paragraphStyle: footerParaStyle
            ])
            footerAttr.draw(in: CGRect(x: 30, y: 580, width: 330, height: 20))
        }
    }
}
