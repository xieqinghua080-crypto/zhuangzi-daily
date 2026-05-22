import Foundation
import StoreKit

// MARK: - StoreKit 订阅服务
@MainActor
class StoreKitService: ObservableObject {

    static let shared = StoreKitService()

    @Published var isSubscribed = false
    @Published var products: [Product] = []
    @Published var isLoading = false

    private let subscriptionID = "com.zhuangzidaily.monthly"

    private init() {
        // 启动时监听交易更新
        Task {
            await checkSubscriptionStatus()
            setupTransactionListener()
        }
    }

    // MARK: - 加载商品

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [subscriptionID])
            await MainActor.run {
                self.products = products.sorted(by: { $0.price < $1.price })
            }
        } catch {
            print("❌ 加载商品失败: \(error.localizedDescription)")
        }
    }

    // MARK: - 购买订阅

    func purchase() async -> Bool {
        guard let product = products.first else {
            await loadProducts()
            guard let product = products.first else { return false }
            return await purchase(product: product)
        }
        return await purchase(product: product)
    }

    private func purchase(product: Product) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await checkSubscriptionStatus()
                return true

            case .userCancelled:
                return false

            case .pending:
                return false

            @unknown default:
                return false
            }
        } catch {
            print("❌ 购买失败: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - 恢复购买

    func restorePurchases() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
            return isSubscribed
        } catch {
            print("❌ 恢复购买失败: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - 检查订阅状态

    func checkSubscriptionStatus() async {
        // 首先检查是否有资格获得介绍性优惠
        do {
            // 获取当前所有交易的收据
            var hasActiveSubscription = false

            for await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else { continue }

                if transaction.productID == subscriptionID &&
                   transaction.revocationDate == nil &&
                   transaction.expirationDate.map({ $0 > Date() }) ?? false {
                    hasActiveSubscription = true
                    break
                }
            }

            await MainActor.run {
                self.isSubscribed = hasActiveSubscription
            }
        }
    }

    // MARK: - 交易监听

    private func setupTransactionListener() {
        Task {
            for await result in Transaction.updates {
                guard let transaction = try? self.checkVerified(result) else { continue }

                if transaction.productID == self.subscriptionID {
                    await MainActor.run {
                        self.isSubscribed = true
                    }
                }

                await transaction.finish()
            }
        }
    }

    // MARK: - 验证助手

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            throw StoreError.verificationFailed(error)
        }
    }

    enum StoreError: Error {
        case verificationFailed(Error)
    }
}
