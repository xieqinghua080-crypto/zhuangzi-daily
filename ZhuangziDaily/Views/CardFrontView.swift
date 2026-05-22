import SwiftUI

// MARK: - 卡片正面视图
struct CardFrontView: View {

    let sign: Sign

    var body: some View {
        VStack(spacing: 0) {
            // 分类标签
            HStack {
                Text(sign.category.icon)
                    .font(.title3)
                Text(sign.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()

            // 金句区域
            VStack(spacing: 12) {
                Text("「\(sign.quote)」")
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 16)

                Text(sign.translation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Spacer()

            // 分隔线
            Rectangle()
                .fill(Color.primary.opacity(0.15))
                .frame(width: 60, height: 1)

            Spacer()

            // 今日宜忌
            HStack(spacing: 30) {
                // 宜
                VStack(alignment: .leading, spacing: 6) {
                    Label("宜", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                    ForEach(sign.advice.yi, id: \.self) { item in
                        Text("· \(item)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                // 忌
                VStack(alignment: .leading, spacing: 6) {
                    Label("忌", systemImage: "xmark.circle")
                        .font(.caption)
                        .foregroundColor(.red)
                    ForEach(sign.advice.ji, id: \.self) { item in
                        Text("· \(item)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // 寄语
            Text(sign.lesson)
                .font(.caption)
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

            // 底部水印
            Text("🌀 庄子的每日签")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 460)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .primary.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 4)
    }
}
